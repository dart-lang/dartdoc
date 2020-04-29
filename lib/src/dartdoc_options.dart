// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// dartdoc's dartdoc_options.yaml configuration file follows similar loading
/// semantics to that of analysis_options.yaml,
/// [documented here](https://dart.dev/guides/language/analysis-options).
/// It searches parent directories until it finds an analysis_options.yaml file,
/// and uses built-in defaults if one is not found.
///
/// The classes here manage both the dartdoc_options.yaml loading and command
/// line arguments.
///
library dartdoc.dartdoc_options;

import 'dart:async';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/experiment_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

/// Constants to help with type checking, because T is int and so forth
/// don't work in Dart.
const String _kStringVal = '';
const List<String> _kListStringVal = <String>[];
const Map<String, String> _kMapStringVal = <String, String>{};
const int _kIntVal = 0;
const double _kDoubleVal = 0.0;
const bool _kBoolVal = true;

/// Args are computed relative to the current directory at the time the
/// program starts.
final Directory directoryCurrent = Directory.current;
final String directoryCurrentPath = p.canonicalize(Directory.current.path);

class DartdocOptionError extends DartdocFailure {
  DartdocOptionError(String details) : super(details);
}

class DartdocFileMissing extends DartdocOptionError {
  DartdocFileMissing(String details) : super(details);
}

/// Defines the attributes of a category in the options file, corresponding to
/// the 'categories' keyword in the options file, and populated by the
/// [CategoryConfiguration] class.
class CategoryDefinition {
  /// Internal name of the category.
  final String name;

  /// Displayed name of the category in docs, or null if there is none.
  final String _displayName;

  /// Canonical path of the markdown file used to document this category
  /// (or null if undocumented).
  final String documentationMarkdown;

  CategoryDefinition(this.name, this._displayName, this.documentationMarkdown);

  /// Returns the [_displayName], if available, or else simply [name].
  String get displayName => _displayName ?? name;
}

/// A configuration class that can interpret category definitions from a YAML
/// map.
class CategoryConfiguration {
  /// A map of [CategoryDefinition.name] to [CategoryDefinition] objects.
  final Map<String, CategoryDefinition> categoryDefinitions;

  CategoryConfiguration._(this.categoryDefinitions);

  static CategoryConfiguration get empty {
    return CategoryConfiguration._({});
  }

  static CategoryConfiguration fromYamlMap(
      YamlMap yamlMap, p.Context pathContext) {
    var newCategoryDefinitions = <String, CategoryDefinition>{};
    for (var entry in yamlMap.entries) {
      var name = entry.key.toString();
      String displayName;
      String documentationMarkdown;
      var categoryMap = entry.value;
      if (categoryMap is Map) {
        displayName = categoryMap['displayName']?.toString();
        documentationMarkdown = categoryMap['markdown']?.toString();
        if (documentationMarkdown != null) {
          documentationMarkdown =
              pathContext.canonicalize(documentationMarkdown);
          if (!File(documentationMarkdown).existsSync()) {
            throw DartdocFileMissing(
                'In categories definition for ${name}, "markdown" resolves to the missing file $documentationMarkdown');
          }
        }
        newCategoryDefinitions[name] =
            CategoryDefinition(name, displayName, documentationMarkdown);
      }
    }
    return CategoryConfiguration._(newCategoryDefinitions);
  }
}

/// Defines the attributes of a tool in the options file, corresponding to
/// the 'tools' keyword in the options file, and populated by the
/// [ToolConfiguration] class.
class ToolDefinition {
  /// A list containing the command and options to be run for this tool. The
  /// first argument in the command is the tool executable, and will have its
  /// path evaluated relative to the `dartdoc_options.yaml` location. Must not
  /// be an empty list, or be null.
  final List<String> command;

  /// A list containing the command and options to setup phase for this tool.
  /// The first argument in the command is the tool executable, and will have
  /// its path evaluated relative to the `dartdoc_options.yaml` location. May
  /// be null or empty, in which case it will be ignored at setup time.
  final List<String> setupCommand;

  /// A description of the defined tool. Must not be null.
  final String description;

  /// If set, then the setup command has been run once for this tool definition.
  bool setupComplete = false;

  /// Returns true if the given executable path has an extension recognized as a
  /// Dart extension (e.g. '.dart' or '.snapshot').
  static bool isDartExecutable(String executable) {
    var extension = p.extension(executable);
    return extension == '.dart' || extension == '.snapshot';
  }

  /// Creates a ToolDefinition or subclass that is appropriate for the command
  /// given.
  factory ToolDefinition.fromCommand(
      List<String> command, List<String> setupCommand, String description) {
    assert(command != null);
    assert(command.isNotEmpty);
    assert(description != null);
    if (isDartExecutable(command[0])) {
      return DartToolDefinition(command, setupCommand, description);
    } else {
      return ToolDefinition(command, setupCommand, description);
    }
  }

  ToolDefinition(this.command, this.setupCommand, this.description)
      : assert(command != null),
        assert(command.isNotEmpty),
        assert(description != null);

  @override
  String toString() {
    final commandString =
        '${this is DartToolDefinition ? '(Dart) ' : ''}"${command.join(' ')}"';
    if (setupCommand == null) {
      return '$runtimeType: $commandString ($description)';
    } else {
      return '$runtimeType: $commandString, with setup command '
          '"${setupCommand.join(' ')}" ($description)';
    }
  }
}

/// Manages the creation of a single snapshot file in a context where multiple
/// async functions could be trying to use and/or create it.
///
/// To use:
///
/// var s = new Snapshot(...);
///
/// if (s.needsSnapshot) {
///   // create s.snapshotFile, then call:
///   s.snapshotCompleted();
/// } else {
///   await snapshotValid();
///   // use existing s.snapshotFile;
/// }
///
class Snapshot {
  File _snapshotFile;

  File get snapshotFile => _snapshotFile;
  final Completer _snapshotCompleter = Completer();

  Snapshot(Directory snapshotCache, String toolPath, int serial) {
    if (toolPath.endsWith('.snapshot')) {
      _needsSnapshot = false;
      _snapshotFile = File(toolPath);
      snapshotCompleted();
    } else {
      _snapshotFile =
          File(p.join(snapshotCache.absolute.path, 'snapshot_$serial'));
    }
  }

  bool _needsSnapshot = true;

  /// Will return true precisely once, unless [snapshotFile] was already a
  /// snapshot.  In that case, will always return false.
  bool get needsSnapshot {
    if (_needsSnapshot == true) {
      _needsSnapshot = false;
      return true;
    }
    return _needsSnapshot;
  }

  Future<void> snapshotValid() => _snapshotCompleter.future;

  void snapshotCompleted() => _snapshotCompleter.complete();
}

/// A singleton that keeps track of cached snapshot files. The [dispose]
/// function must be called before process exit to clean up snapshots in the
/// cache.
class SnapshotCache {
  static SnapshotCache _instance;

  Directory snapshotCache;
  final Map<String, Snapshot> snapshots = {};
  int _serial = 0;

  SnapshotCache._()
      : snapshotCache =
            Directory.systemTemp.createTempSync('dartdoc_snapshot_cache_');

  static SnapshotCache get instance {
    _instance ??= SnapshotCache._();
    return _instance;
  }

  Snapshot getSnapshot(String toolPath) {
    if (snapshots.containsKey(toolPath)) {
      return snapshots[toolPath];
    }
    snapshots[toolPath] = Snapshot(snapshotCache, toolPath, _serial);
    _serial++;
    return snapshots[toolPath];
  }

  Future<void> dispose() {
    _instance = null;
    if (snapshotCache != null && snapshotCache.existsSync()) {
      return snapshotCache.delete(recursive: true);
    }
    return null;
  }
}

/// A special kind of tool definition for Dart commands.
class DartToolDefinition extends ToolDefinition {
  /// Takes a list of args to modify, and returns the name of the executable
  /// to run. If no snapshot file existed, then create one and modify the args
  /// so that if they are executed with dart, will result in the snapshot being
  /// built.
  Future<Tuple2<String, Function()>> modifyArgsToCreateSnapshotIfNeeded(
      List<String> args) async {
    assert(args[0] == command.first);
    // Set up flags to create a new snapshot, if needed, and use the first run as the training
    // run.
    var snapshot = SnapshotCache.instance.getSnapshot(command.first);
    var snapshotFile = snapshot.snapshotFile;
    var needsSnapshot = snapshot.needsSnapshot;
    if (needsSnapshot) {
      args.insertAll(0, [
        '--snapshot=${snapshotFile.absolute.path}',
        '--snapshot_kind=app-jit'
      ]);
    } else {
      await snapshot.snapshotValid();
      // replace the first argument with the path to the snapshot.
      args[0] = snapshotFile.absolute.path;
    }
    return Tuple2(Platform.resolvedExecutable,
        needsSnapshot ? snapshot.snapshotCompleted : null);
  }

  DartToolDefinition(
      List<String> command, List<String> setupCommand, String description)
      : super(command, setupCommand, description);
}

/// A configuration class that can interpret [ToolDefinition]s from a YAML map.
class ToolConfiguration {
  final Map<String, ToolDefinition> tools;

  ToolRunner _runner;

  ToolRunner get runner => _runner ??= ToolRunner(this);

  ToolConfiguration._(this.tools);

  static ToolConfiguration get empty {
    return ToolConfiguration._({});
  }

  // TODO(jcollins-g): consider caching these.
  static ToolConfiguration fromYamlMap(YamlMap yamlMap, p.Context pathContext) {
    var newToolDefinitions = <String, ToolDefinition>{};
    for (var entry in yamlMap.entries) {
      var name = entry.key.toString();
      var toolMap = entry.value;
      var description;
      List<String> command;
      List<String> setupCommand;
      if (toolMap is Map) {
        description = toolMap['description']?.toString();
        List<String> findCommand([String prefix = '']) {
          List<String> command;
          // If the command key is given, then it applies to all platforms.
          var commandFrom = toolMap.containsKey('${prefix}command')
              ? '${prefix}command'
              : '$prefix${Platform.operatingSystem}';
          if (toolMap.containsKey(commandFrom)) {
            if (toolMap[commandFrom].value is String) {
              command = [toolMap[commandFrom].toString()];
              if (command[0].isEmpty) {
                throw DartdocOptionError(
                    'Tool commands must not be empty. Tool $name command entry '
                    '"$commandFrom" must contain at least one path.');
              }
            } else if (toolMap[commandFrom] is YamlList) {
              command = (toolMap[commandFrom] as YamlList)
                  .map<String>((node) => node.toString())
                  .toList();
              if (command.isEmpty) {
                throw DartdocOptionError(
                    'Tool commands must not be empty. Tool $name command entry '
                    '"$commandFrom" must contain at least one path.');
              }
            } else {
              throw DartdocOptionError(
                  'Tool commands must be a path to an executable, or a list of '
                  'strings that starts with a path to an executable. '
                  'The tool $name has a $commandFrom entry that is a '
                  '${toolMap[commandFrom].runtimeType}');
            }
          }
          return command;
        }

        command = findCommand();
        setupCommand = findCommand('setup_');
      } else {
        throw DartdocOptionError(
            'Tools must be defined as a map of tool names to definitions. Tool '
            '$name is not a map.');
      }
      if (command == null) {
        throw DartdocOptionError(
            'At least one of "command" or "${Platform.operatingSystem}" must '
            'be defined for the tool $name.');
      }
      bool validateExecutable(String executable) {
        bool isExecutable(int mode) {
          return (0x1 & ((mode >> 6) | (mode >> 3) | mode)) != 0;
        }

        var executableFile = File(executable);
        var exeStat = executableFile.statSync();
        if (exeStat.type == FileSystemEntityType.notFound) {
          throw DartdocOptionError('Command executables must exist. '
              'The file "$executable" does not exist for tool $name.');
        }

        var isDartCommand = ToolDefinition.isDartExecutable(executable);
        // Dart scripts don't need to be executable, because they'll be
        // executed with the Dart binary.
        if (!isDartCommand && !isExecutable(exeStat.mode)) {
          throw DartdocOptionError('Non-Dart commands must be '
              'executable. The file "$executable" for tool $name does not have '
              'execute permission.');
        }
        return isDartCommand;
      }

      var executable = pathContext.canonicalize(command.removeAt(0));
      validateExecutable(executable);
      if (setupCommand != null) {
        var setupExecutable =
            pathContext.canonicalize(setupCommand.removeAt(0));
        var isDartSetupCommand = validateExecutable(executable);
        // Setup commands aren't snapshotted, since they're only run once.
        setupCommand = (isDartSetupCommand
                ? [Platform.resolvedExecutable, setupExecutable]
                : [setupExecutable]) +
            setupCommand;
      }
      newToolDefinitions[name] = ToolDefinition.fromCommand(
          [executable] + command, setupCommand, description);
    }
    return ToolConfiguration._(newToolDefinitions);
  }
}

/// A container class to keep track of where our yaml data came from.
class _YamlFileData {
  /// The map from the yaml file.
  final Map data;

  /// The path to the directory containing the yaml file.
  final String canonicalDirectoryPath;

  _YamlFileData(this.data, this.canonicalDirectoryPath);
}

/// Some DartdocOption subclasses need to keep track of where they
/// got the value from; this class contains those intermediate results
/// so that error messages can be more useful.
class _OptionValueWithContext<T> {
  /// The value of the option at canonicalDirectoryPath.
  final T value;

  /// A canonical path to the directory where this value came from.  May
  /// be different from [DartdocOption.valueAt]'s `dir` parameter.
  String canonicalDirectoryPath;

  /// If non-null, the basename of the configuration file the value came from.
  String definingFile;

  /// A [pathLib.Context] variable initialized with canonicalDirectoryPath.
  p.Context pathContext;

  /// Build a _OptionValueWithContext.
  /// [path] is the path where this value came from (not required to be canonical)
  _OptionValueWithContext(this.value, String path, {String definingFile}) {
    this.definingFile = definingFile;
    canonicalDirectoryPath = p.canonicalize(path);
    pathContext = p.Context(current: canonicalDirectoryPath);
  }

  /// Assume value is a path, and attempt to resolve it.  Throws [UnsupportedError]
  /// if [T] isn't a [String] or [List<String>].
  T get resolvedValue {
    if (value is List<String>) {
      return (value as List<String>)
          .map((v) => pathContext.canonicalize(resolveTildePath(v)))
          .cast<String>()
          .toList() as T;
    } else if (value is String) {
      return pathContext.canonicalize(resolveTildePath(value as String)) as T;
    } else if (value is Map<String, String>) {
      return (value as Map<String, String>)
          .map<String, String>((String key, String value) {
        return MapEntry(key, pathContext.canonicalize(resolveTildePath(value)));
      }) as T;
    } else {
      throw UnsupportedError('Type $T is not supported for resolvedValue');
    }
  }
}

/// An abstract class for interacting with dartdoc options.
///
/// This class and its implementations allow Dartdoc to declare options
/// that are both defined in a configuration file and specified via the
/// command line, with searching the directory tree for a proper file
/// and overriding file options with the command line built-in.  A number
/// of sanity checks are also built in to these classes so that file existence
/// can be verified, types constrained, and defaults provided.
///
/// Use via implementations [DartdocOptionSet], [DartdocOptionArgFile],
/// [DartdocOptionArgOnly], and [DartdocOptionFileOnly].
abstract class DartdocOption<T> {
  /// This is the value returned if we couldn't find one otherwise.
  final T defaultsTo;

  /// Text string for help passed on in command line options.
  final String help;

  /// The name of this option, not including the names of any parents.
  final String name;

  /// Set to true if this option represents the name of a directory.
  final bool isDir;

  /// Set to true if this option represents the name of a file.
  final bool isFile;

  /// Set to true if DartdocOption subclasses should validate that the
  /// directory or file exists.  Does not imply validation of [defaultsTo],
  /// and requires that one of [isDir] or [isFile] is set.
  final bool mustExist;

  DartdocOption(this.name, this.defaultsTo, this.help, this.isDir, this.isFile,
      this.mustExist, this._convertYamlToType) {
    assert(!(isDir && isFile));
    if (isDir || isFile) assert(_isString || _isListString || _isMapString);
    if (mustExist) {
      assert(isDir || isFile);
    }
  }

  /// Closure to convert yaml data into some other structure.
  T Function(YamlMap, p.Context) _convertYamlToType;

  // The choice not to use reflection means there's some ugly type checking,
  // somewhat more ugly than we'd have to do anyway to automatically convert
  // command line arguments and yaml data to real types.
  //
  // Condense the ugly all in one place, this set of getters.
  bool get _isString => _kStringVal is T;

  bool get _isListString => _kListStringVal is T;

  bool get _isMapString => _kMapStringVal is T;

  bool get _isBool => _kBoolVal is T;

  bool get _isInt => _kIntVal is T;

  bool get _isDouble => _kDoubleVal is T;

  DartdocOption _parent;

  /// The parent of this DartdocOption, or null if this is the root.
  DartdocOption get parent => _parent;

  final Map<String, _YamlFileData> __yamlAtCanonicalPathCache = {};

  /// Implementation detail for [DartdocOptionFileOnly].  Make sure we use
  /// the root node's cache.
  Map<String, _YamlFileData> get _yamlAtCanonicalPathCache =>
      root.__yamlAtCanonicalPathCache;

  final ArgParser __argParser = ArgParser(usageLineLength: 80);

  ArgParser get argParser => root.__argParser;

  ArgResults __argResults;

  /// Parse these as string arguments (from argv) with the argument parser.
  /// Call before calling [valueAt] for any [DartdocOptionArgOnly] or
  /// [DartdocOptionArgFile] in this tree.
  void _parseArguments(List<String> arguments) {
    __argResults = argParser.parse(arguments);
  }

  /// Throw [DartdocFileMissing] with a detailed error message indicating where
  /// the error came from when a file or directory option is missing.
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingFilename);

  /// Call [_onMissing] for every path that does not exist.
  void _validatePaths(_OptionValueWithContext valueWithContext) {
    if (!mustExist) return;
    assert(isDir || isFile);
    List<String> resolvedPaths;
    if (valueWithContext.value is String) {
      resolvedPaths = [valueWithContext.resolvedValue];
    } else if (valueWithContext.value is List<String>) {
      resolvedPaths = valueWithContext.resolvedValue.toList();
    } else if (valueWithContext.value is Map<String, String>) {
      resolvedPaths = valueWithContext.resolvedValue.values.toList();
    } else {
      assert(
          false,
          'Trying to ensure existence of unsupported type '
          '${valueWithContext.value.runtimeType}');
    }
    for (var path in resolvedPaths) {
      var f = isDir ? Directory(path) : File(path);
      if (!f.existsSync()) {
        _onMissing(valueWithContext, path);
      }
    }
  }

  /// For a [List<String>] or [String] value, if [isDir] or [isFile] is set,
  /// resolve paths in value relative to canonicalPath.
  T _handlePathsInContext(_OptionValueWithContext valueWithContext) {
    if (valueWithContext?.value == null || !(isDir || isFile)) {
      return valueWithContext?.value;
    }
    _validatePaths(valueWithContext);
    return valueWithContext.resolvedValue;
  }

  /// Call this with argv to set up the argument overrides.  Applies to all
  /// children.
  void parseArguments(List<String> arguments) =>
      root._parseArguments(arguments);

  ArgResults get _argResults => root.__argResults;

  /// Set the parent of this [DartdocOption].  Do not call more than once.
  set parent(DartdocOption newParent) {
    assert(_parent == null);
    _parent = newParent;
  }

  /// The root [DartdocOption] containing this object, or [this] if the object
  /// has no parent.
  DartdocOption get root {
    DartdocOption p = this;
    while (p.parent != null) {
      p = p.parent;
    }
    return p;
  }

  /// All object names starting at the root.
  Iterable<String> get keys {
    var keyList = <String>[];
    DartdocOption option = this;
    while (option?.name != null) {
      keyList.add(option.name);
      option = option.parent;
    }
    return keyList.reversed;
  }

  /// Direct children of this node, mapped by name.
  final Map<String, DartdocOption> _children = {};

  /// Return the calculated value of this option, given the directory as context.
  ///
  /// If [isFile] or [isDir] is set, the returned value will be transformed
  /// into a canonical path relative to the current working directory
  /// (for arguments) or the config file from which the value was derived.
  ///
  /// May throw [DartdocOptionError] if a command line argument is of the wrong
  /// type.  If [mustExist] is true, will throw [DartdocFileMissing] for command
  /// line parameters and file paths in config files that don't point to
  /// corresponding files or directories.
  T valueAt(Directory dir);

  /// Calls [valueAt] with the working directory at the start of the program.
  T valueAtCurrent() => valueAt(directoryCurrent);

  /// Calls [valueAt] on the directory this element is defined in.
  T valueAtElement(Element element) =>
      valueAt(Directory(p.canonicalize(p.basename(element.source.fullName))));

  /// Adds a DartdocOption to the children of this DartdocOption.
  void add(DartdocOption option) {
    if (_children.containsKey(option.name)) {
      throw DartdocOptionError(
          'Tried to add two children with the same name: ${option.name}');
    }
    _children[option.name] = option;
    option.parent = this;
    option.traverse((option) => option._onAdd());
  }

  /// This method is guaranteed to be called when [this] or any parent is added.
  void _onAdd() {}

  /// Adds a list of dartdoc options to the children of this DartdocOption.
  void addAll(Iterable<DartdocOption> options) =>
      options.forEach((o) => add(o));

  /// Get the immediate child of this node named [name].
  DartdocOption operator [](String name) {
    return _children[name];
  }

  /// Apply the function [visit] to [this] and all children.
  void traverse(void Function(DartdocOption option) visit) {
    visit(this);
    _children.values.forEach((d) => d.traverse(visit));
  }
}

/// A class that defaults to a value computed from a closure, but can be
/// overridden by a file.
class DartdocOptionFileSynth<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T>, _DartdocFileOption<T> {
  bool _parentDirOverridesChild;
  @override
  final T Function(DartdocSyntheticOption<T>, Directory) _compute;

  DartdocOptionFileSynth(String name, this._compute,
      {bool mustExist = false,
      String help = '',
      bool isDir = false,
      bool isFile = false,
      bool parentDirOverridesChild,
      T Function(YamlMap, p.Context) convertYamlToType})
      : super(name, null, help, isDir, isFile, mustExist, convertYamlToType) {
    _parentDirOverridesChild = parentDirOverridesChild;
  }

  @override
  T valueAt(Directory dir) {
    var result = _valueAtFromFile(dir);
    if (result?.definingFile != null) {
      return _handlePathsInContext(result);
    }
    return _valueAtFromSynthetic(dir);
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    if (valueWithContext.definingFile != null) {
      _onMissingFromFiles(valueWithContext, missingPath);
    } else {
      _onMissingFromSynthetic(valueWithContext, missingPath);
    }
  }

  @override
  bool get parentDirOverridesChild => _parentDirOverridesChild;
}

/// A class that defaults to a value computed from a closure, but can
/// be overridden on the command line.
class DartdocOptionArgSynth<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T>, _DartdocArgOption<T> {
  String _abbr;
  bool _hide;
  bool _negatable;
  bool _splitCommas;

  @override
  final T Function(DartdocSyntheticOption<T>, Directory) _compute;

  DartdocOptionArgSynth(String name, this._compute,
      {String abbr,
      bool mustExist = false,
      String help = '',
      bool hide = false,
      bool isDir = false,
      bool isFile = false,
      bool negatable = false,
      bool splitCommas})
      : super(name, null, help, isDir, isFile, mustExist, null) {
    _hide = hide;
    _negatable = negatable;
    _splitCommas = splitCommas;
    _abbr = abbr;
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    _onMissingFromArgs(valueWithContext, missingPath);
  }

  @override
  T valueAt(Directory dir) {
    if (_argResults.wasParsed(argName)) {
      return _valueAtFromArgs();
    }
    return _valueAtFromSynthetic(dir);
  }

  @override
  String get abbr => _abbr;

  @override
  bool get hide => _hide;

  @override
  bool get negatable => _negatable;

  @override
  bool get splitCommas => _splitCommas;
}

/// A synthetic option takes a closure at construction time that computes
/// the value of the configuration option based on other configuration options.
/// Does not protect against closures that self-reference.  If [mustExist] and
/// [isDir] or [isFile] is set, computed values will be resolved to canonical
/// paths.
class DartdocOptionSyntheticOnly<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T> {
  @override
  final T Function(DartdocSyntheticOption<T>, Directory) _compute;

  DartdocOptionSyntheticOnly(String name, this._compute,
      {bool mustExist = false,
      String help = '',
      bool isDir = false,
      bool isFile = false})
      : super(name, null, help, isDir, isFile, mustExist, null);
}

abstract class DartdocSyntheticOption<T> implements DartdocOption<T> {
  T Function(DartdocSyntheticOption<T>, Directory) get _compute;

  @override
  T valueAt(Directory dir) => _valueAtFromSynthetic(dir);

  T _valueAtFromSynthetic(Directory dir) {
    _OptionValueWithContext context =
        _OptionValueWithContext<T>(_compute(this, dir), dir.path);
    return _handlePathsInContext(context);
  }

  @override
  void _onMissing(
          _OptionValueWithContext valueWithContext, String missingPath) =>
      _onMissingFromSynthetic(valueWithContext, missingPath);

  void _onMissingFromSynthetic(
      _OptionValueWithContext valueWithContext, String missingPath) {
    var description = 'Synthetic configuration option ${name} from <internal>';
    throw DartdocFileMissing(
        '$description, computed as ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }
}

typedef OptionGenerator = Future<List<DartdocOption>> Function();

/// A [DartdocOption] that only contains other [DartdocOption]s and is not an option itself.
class DartdocOptionSet extends DartdocOption<Null> {
  DartdocOptionSet(String name)
      : super(name, null, null, false, false, false, null);

  /// Asynchronous factory that is the main entry point to initialize Dartdoc
  /// options for use.
  ///
  /// [name] is the top level key for the option set.
  /// [optionGenerators] is a sequence of asynchronous functions that return
  /// [DartdocOption]s that will be added to the new option set.
  static Future<DartdocOptionSet> fromOptionGenerators(
      String name, Iterable<OptionGenerator> optionGenerators) async {
    var optionSet = DartdocOptionSet(name);
    for (var generator in optionGenerators) {
      optionSet.addAll(await generator());
    }
    return optionSet;
  }

  /// [DartdocOptionSet] always has the null value.
  @override
  Null valueAt(Directory dir) => null;

  /// Since we have no value, [_onMissing] does nothing.
  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingFilename) {}

  /// Traverse skips this node, because it doesn't represent a real configuration object.
  @override
  void traverse(void Function(DartdocOption option) visitor) {
    _children.values.forEach((d) => d.traverse(visitor));
  }
}

/// A [DartdocOption] that only exists as a command line argument. --help would
/// be a good example.
class DartdocOptionArgOnly<T> extends DartdocOption<T>
    with _DartdocArgOption<T> {
  String _abbr;
  bool _hide;
  bool _negatable;
  bool _splitCommas;

  DartdocOptionArgOnly(String name, T defaultsTo,
      {String abbr,
      bool mustExist = false,
      String help = '',
      bool hide = false,
      bool isDir = false,
      bool isFile = false,
      bool negatable = false,
      bool splitCommas})
      : super(name, defaultsTo, help, isDir, isFile, mustExist, null) {
    _hide = hide;
    _negatable = negatable;
    _splitCommas = splitCommas;
    _abbr = abbr;
  }

  @override
  String get abbr => _abbr;

  @override
  bool get hide => _hide;

  @override
  bool get negatable => _negatable;

  @override
  bool get splitCommas => _splitCommas;
}

/// A [DartdocOption] that works with command line arguments and dartdoc_options files.
class DartdocOptionArgFile<T> extends DartdocOption<T>
    with _DartdocArgOption<T>, _DartdocFileOption<T> {
  String _abbr;
  bool _hide;
  bool _negatable;
  bool _parentDirOverridesChild;
  bool _splitCommas;

  DartdocOptionArgFile(String name, T defaultsTo,
      {String abbr,
      bool mustExist = false,
      String help = '',
      bool hide = false,
      bool isDir = false,
      bool isFile = false,
      bool negatable = false,
      bool parentDirOverridesChild = false,
      bool splitCommas})
      : super(name, defaultsTo, help, isDir, isFile, mustExist, null) {
    _abbr = abbr;
    _hide = hide;
    _negatable = negatable;
    _parentDirOverridesChild = parentDirOverridesChild;
    _splitCommas = splitCommas;
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    if (valueWithContext.definingFile != null) {
      _onMissingFromFiles(valueWithContext, missingPath);
    } else {
      _onMissingFromArgs(valueWithContext, missingPath);
    }
  }

  /// Try to find an explicit argument setting this value, but if not, fall back to files
  /// finally, the default.
  @override
  T valueAt(Directory dir) {
    var value = _valueAtFromArgs();
    value ??= _valueAtFromFiles(dir);
    value ??= defaultsTo;
    return value;
  }

  @override
  String get abbr => _abbr;

  @override
  bool get hide => _hide;

  @override
  bool get negatable => _negatable;

  @override
  bool get parentDirOverridesChild => _parentDirOverridesChild;

  @override
  bool get splitCommas => _splitCommas;
}

class DartdocOptionFileOnly<T> extends DartdocOption<T>
    with _DartdocFileOption<T> {
  bool _parentDirOverridesChild;

  DartdocOptionFileOnly(String name, T defaultsTo,
      {bool mustExist = false,
      String help = '',
      bool isDir = false,
      bool isFile = false,
      bool parentDirOverridesChild = false,
      T Function(YamlMap, p.Context) convertYamlToType})
      : super(name, defaultsTo, help, isDir, isFile, mustExist,
            convertYamlToType) {
    _parentDirOverridesChild = parentDirOverridesChild;
  }

  @override
  bool get parentDirOverridesChild => _parentDirOverridesChild;
}

/// Implements checking for options contained in dartdoc.yaml.
abstract class _DartdocFileOption<T> implements DartdocOption<T> {
  /// If true, the parent directory's value overrides the child's.  Otherwise, the child's
  /// value overrides values in parents.
  bool get parentDirOverridesChild;

  /// The name of the option, with nested options joined by [.].  For example:
  ///
  /// ```yaml
  /// dartdoc:
  ///   stuff:
  ///     things:
  /// ```
  /// would have the name `things` and the fieldName `dartdoc.stuff.things`.
  String get fieldName => keys.join('.');

  @override
  void _onMissing(
          _OptionValueWithContext valueWithContext, String missingPath) =>
      _onMissingFromFiles(valueWithContext, missingPath);

  void _onMissingFromFiles(
      _OptionValueWithContext valueWithContext, String missingPath) {
    var dartdocYaml = p.join(
        valueWithContext.canonicalDirectoryPath, valueWithContext.definingFile);
    throw DartdocFileMissing(
        'Field ${fieldName} from ${dartdocYaml}, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  @override

  /// Searches for a value in configuration files relative to [dir], and if not
  /// found, returns [defaultsTo].
  T valueAt(Directory dir) {
    return _valueAtFromFiles(dir) ?? defaultsTo;
  }

  final Map<String, T> __valueAtFromFiles = {};

  // The value of this option from files will not change unless files are
  // modified during execution (not allowed in Dartdoc).
  T _valueAtFromFiles(Directory dir) {
    var key = p.canonicalize(dir.path);
    if (!__valueAtFromFiles.containsKey(key)) {
      _OptionValueWithContext valueWithContext;
      if (parentDirOverridesChild) {
        valueWithContext = _valueAtFromFilesLastFound(dir);
      } else {
        valueWithContext = _valueAtFromFilesFirstFound(dir);
      }
      __valueAtFromFiles[key] = _handlePathsInContext(valueWithContext);
    }
    return __valueAtFromFiles[key];
  }

  /// Searches all dartdoc_options files through parent directories,
  /// starting at [dir], for the option and returns one once
  /// found.
  _OptionValueWithContext _valueAtFromFilesFirstFound(Directory dir) {
    _OptionValueWithContext value;
    while (true) {
      value = _valueAtFromFile(dir);
      if (value != null || p.equals(dir.parent.path, dir.path)) break;
      dir = dir.parent;
    }
    return value;
  }

  /// Searches all dartdoc_options files for the option, and returns the
  /// value in the top-most parent directory dartdoc_options.yaml file it is
  /// mentioned in.
  _OptionValueWithContext _valueAtFromFilesLastFound(Directory dir) {
    _OptionValueWithContext value;
    while (true) {
      var tmpValue = _valueAtFromFile(dir);
      if (tmpValue != null) value = tmpValue;
      if (p.equals(dir.parent.path, dir.path)) break;
      dir = dir.parent;
    }
    return value;
  }

  /// Returns null if not set in the yaml file in this directory (or its
  /// parents).
  _OptionValueWithContext _valueAtFromFile(Directory dir) {
    var yamlFileData = _yamlAtDirectory(dir);
    var contextPath = yamlFileData.canonicalDirectoryPath;
    dynamic yamlData = yamlFileData.data;
    for (var key in keys) {
      if (!yamlData.containsKey(key)) return null;
      yamlData = yamlData[key];
    }

    var returnData;
    if (_isListString) {
      if (yamlData is YamlList) {
        returnData = <String>[];
        for (var item in yamlData) {
          returnData.add(item.toString());
        }
      }
    } else if (yamlData is YamlMap) {
      // TODO(jcollins-g): This special casing is unfortunate.  Consider
      // a refactor to extract yaml data conversion into closures 100% of the
      // time or find a cleaner way to do this.
      //
      // A refactor probably would integrate resolvedValue for
      // _OptionValueWithContext into the return data here, and would not have
      // that be separate.
      if (_isMapString && _convertYamlToType == null) {
        _convertYamlToType = (YamlMap yamlMap, p.Context pathContext) {
          var returnData = <String, String>{};
          for (var entry in yamlMap.entries) {
            returnData[entry.key.toString()] = entry.value.toString();
          }
          return returnData as T;
        };
      }
      if (_convertYamlToType == null) {
        throw DartdocOptionError(
            'Unable to convert yaml to type for option: $fieldName, method not defined');
      }
      var canonicalDirectoryPath = p.canonicalize(contextPath);
      returnData = _convertYamlToType(
          yamlData, p.Context(current: canonicalDirectoryPath));
    } else if (_isDouble) {
      if (yamlData is num) {
        returnData = yamlData.toDouble();
      }
    } else if (_isInt || _isString || _isBool) {
      if (yamlData is T) {
        returnData = yamlData;
      }
    } else {
      throw UnsupportedError('Type ${T} is not supported');
    }
    return _OptionValueWithContext(returnData as T, contextPath,
        definingFile: 'dartdoc_options.yaml');
  }

  _YamlFileData _yamlAtDirectory(Directory dir) {
    var canonicalPaths = <String>[p.canonicalize(dir.path)];
    if (!_yamlAtCanonicalPathCache.containsKey(canonicalPaths.first)) {
      var yamlData = _YamlFileData({}, directoryCurrentPath);
      if (dir.existsSync()) {
        File dartdocOptionsFile;

        while (true) {
          dartdocOptionsFile = File(p.join(dir.path, 'dartdoc_options.yaml'));
          if (dartdocOptionsFile.existsSync() ||
              p.equals(dir.parent.path, dir.path)) break;
          dir = dir.parent;
          canonicalPaths.add(p.canonicalize(dir.path));
        }
        if (dartdocOptionsFile.existsSync()) {
          yamlData = _YamlFileData(
              loadYaml(dartdocOptionsFile.readAsStringSync()),
              p.canonicalize(dir.path));
        }
      }
      canonicalPaths.forEach((p) => _yamlAtCanonicalPathCache[p] = yamlData);
    }
    return _yamlAtCanonicalPathCache[canonicalPaths.first];
  }
}

/// Mixin class implementing command-line arguments for [DartdocOption].
abstract class _DartdocArgOption<T> implements DartdocOption<T> {
  /// For [ArgParser], set to true if the argument can be negated with --no on the command line.
  bool get negatable;

  /// For [ArgParser], set to true if a single string argument will be broken into a list on commas.
  bool get splitCommas;

  /// For [ArgParser], set to true to hide this from the help menu.
  bool get hide;

  /// For [ArgParser], set to a single character to have a short version of the command line argument.
  String get abbr;

  /// valueAt for arguments ignores the [dir] parameter and only uses command
  /// line arguments and the current working directory to resolve the result.
  @override
  T valueAt(Directory dir) => _valueAtFromArgs() ?? defaultsTo;

  /// For passing in to [int.parse] and [double.parse] `onError'.
  void _throwErrorForTypes(String value) {
    String example;
    if (defaultsTo is Map) {
      example = 'key::value';
    } else if (_isInt) {
      example = '32';
    } else if (_isDouble) {
      example = '0.76';
    }
    throw DartdocOptionError(
        'Invalid argument value: --${argName}, set to "${value}", must be a ${T}.  Example:  --${argName} ${example}');
  }

  /// Returns null if no argument was given on the command line.
  T _valueAtFromArgs() {
    var valueWithContext = _valueAtFromArgsWithContext();
    return _handlePathsInContext(valueWithContext);
  }

  @override
  void _onMissing(
          _OptionValueWithContext valueWithContext, String missingPath) =>
      _onMissingFromArgs(valueWithContext, missingPath);

  void _onMissingFromArgs(
      _OptionValueWithContext valueWithContext, String missingPath) {
    throw DartdocFileMissing(
        'Argument --${argName}, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  /// Generates an _OptionValueWithContext using the value of the argument from
  /// the [argParser] and the working directory from [directoryCurrent].
  ///
  /// Throws [UnsupportedError] if [T] is not a supported type.
  _OptionValueWithContext _valueAtFromArgsWithContext() {
    if (!_argResults.wasParsed(argName)) return null;

    T retval;
    // Unlike in _DartdocFileOption, we throw here on inputs being invalid rather
    // than silently proceeding.  TODO(jcollins-g): throw on input formatting for
    // files too?
    if (_isBool || _isListString || _isString) {
      retval = _argResults[argName];
    } else if (_isInt) {
      retval = int.tryParse(_argResults[argName]) as T;
      if (retval == null) _throwErrorForTypes(_argResults[argName]);
    } else if (_isDouble) {
      retval = double.tryParse(_argResults[argName]) as T;
      if (retval == null) _throwErrorForTypes(_argResults[argName]);
    } else if (_isMapString) {
      retval = <String, String>{} as T;
      for (String pair in _argResults[argName]) {
        var pairList = pair.split('::');
        if (pairList.length != 2) {
          _throwErrorForTypes(pair);
        }
        assert(pairList.length == 2);
        (retval as Map<String, String>)[pairList.first] = pairList.last;
      }
    } else {
      throw UnsupportedError('Type ${T} is not supported');
    }
    return _OptionValueWithContext(retval, directoryCurrentPath);
  }

  /// The name of this option as a command line argument.
  String get argName => _keysToArgName(keys);

  /// Turns ['foo', 'somethingBar', 'over_the_hill'] into
  /// 'something-bar-over-the-hill' (with default skip).
  /// This allows argument names to reflect nested structure.
  static String _keysToArgName(Iterable<String> keys, [int skip = 1]) {
    var argName = "${keys.skip(skip).join('-')}";
    argName = argName.replaceAll('_', '-');
    // Do not consume the lowercase character after the uppercase one, to handle
    // two character words.
    final camelCaseRegexp = RegExp(r'([a-z])([A-Z])(?=([a-z]))');
    argName = argName.replaceAllMapped(camelCaseRegexp, (Match m) {
      var before = m.group(1);
      var after = m.group(2).toLowerCase();
      return '${before}-${after}';
    });
    return argName;
  }

  /// If this argument is added to a larger tree of DartdocOptions, call
  /// [ArgParser.addFlag], [ArgParser.addOption], or [ArgParser.addMultiOption]
  /// as appropriate for [T].
  @override
  void _onAdd() {
    if (_isBool) {
      argParser.addFlag(argName,
          abbr: abbr,
          defaultsTo: defaultsTo as bool,
          help: help,
          hide: hide,
          negatable: negatable ?? false);
    } else if (_isInt || _isDouble || _isString) {
      argParser.addOption(argName,
          abbr: abbr,
          defaultsTo: defaultsTo?.toString(),
          help: help,
          hide: hide);
    } else if (_isListString || _isMapString) {
      var defaultsToList = <String>[];
      if (_isListString) {
        defaultsToList = defaultsTo as List<String>;
      } else {
        defaultsToList.addAll((defaultsTo as Map<String, String>)
            .entries
            .map((m) => '${m.key}::${m.value}'));
      }
      argParser.addMultiOption(argName,
          abbr: abbr,
          defaultsTo: defaultsToList,
          help: help,
          hide: hide,
          splitCommas: splitCommas);
    } else {
      throw UnsupportedError('Type ${T} is not supported');
    }
  }
}

/// All DartdocOptionContext mixins should implement this, as well as any other
/// DartdocOptionContext mixins they use for calculating synthetic options.
abstract class DartdocOptionContextBase {
  DartdocOptionSet get optionSet;

  Directory get context;
}

/// An [DartdocOptionSet] wrapped in nice accessors specific to Dartdoc, which
/// automatically passes in the right directory for a given context.  Usually,
/// a single [ModelElement], [Package], [Category] and so forth has a single context
/// and so this can be made a member variable of those structures.
class DartdocOptionContext extends DartdocOptionContextBase
    with
        DartdocExperimentOptionContext,
        PackageWarningOptionContext,
        SourceLinkerOptionContext {
  @override
  final DartdocOptionSet optionSet;
  @override
  Directory context;

  // TODO(jcollins-g): Allow passing in structured data to initialize a
  // [DartdocOptionContext]'s arguments instead of having to parse strings
  // via optionSet.
  /// If [entity] is null, assume this is the initialization case and use
  /// the inputDir flag to determine the context.
  DartdocOptionContext(this.optionSet, FileSystemEntity entity) {
    if (entity == null) {
      String inputDir = optionSet['inputDir'].valueAt(directoryCurrent) ??
          directoryCurrentPath;
      context = Directory(inputDir);
    } else {
      context = Directory(
          p.canonicalize(entity is File ? entity.parent.path : entity.path));
    }
  }

  /// Build a DartdocOptionContext from an analyzer element (using its source
  /// location).
  factory DartdocOptionContext.fromElement(
      DartdocOptionSet optionSet, Element element) {
    return DartdocOptionContext(optionSet, File(element.source.fullName));
  }

  /// Build a DartdocOptionContext from an existing [DartdocOptionContext] and a new analyzer [Element].
  factory DartdocOptionContext.fromContextElement(
      DartdocOptionContext optionContext, Element element) {
    return DartdocOptionContext.fromElement(optionContext.optionSet, element);
  }

  /// Build a DartdocOptionContext from an existing [DartdocOptionContext].
  factory DartdocOptionContext.fromContext(
      DartdocOptionContext optionContext, FileSystemEntity entity) {
    return DartdocOptionContext(optionContext.optionSet, entity);
  }

  // All values defined in createDartdocOptions should be exposed here.
  bool get allowTools => optionSet['allowTools'].valueAt(context);

  double get ambiguousReexportScorerMinConfidence =>
      optionSet['ambiguousReexportScorerMinConfidence'].valueAt(context);

  bool get autoIncludeDependencies =>
      optionSet['autoIncludeDependencies'].valueAt(context);

  List<String> get categoryOrder => optionSet['categoryOrder'].valueAt(context);

  CategoryConfiguration get categories =>
      optionSet['categories'].valueAt(context);

  List<String> get dropTextFrom => optionSet['dropTextFrom'].valueAt(context);

  String get examplePathPrefix =>
      optionSet['examplePathPrefix'].valueAt(context);

  List<String> get exclude => optionSet['exclude'].valueAt(context);

  List<String> get excludePackages =>
      optionSet['excludePackages'].valueAt(context);

  String get flutterRoot => optionSet['flutterRoot'].valueAt(context);

  bool get hideSdkText => optionSet['hideSdkText'].valueAt(context);

  List<String> get include => optionSet['include'].valueAt(context);

  List<String> get includeExternal =>
      optionSet['includeExternal'].valueAt(context);

  bool get includeSource => optionSet['includeSource'].valueAt(context);

  bool get injectHtml => optionSet['injectHtml'].valueAt(context);

  bool get excludeFooterVersion =>
      optionSet['excludeFooterVersion'].valueAt(context);

  ToolConfiguration get tools => optionSet['tools'].valueAt(context);

  /// _input is only used to construct synthetic options.
  // ignore: unused_element
  String get _input => optionSet['input'].valueAt(context);

  String get inputDir => optionSet['inputDir'].valueAt(context);

  bool get linkToRemote => optionSet['linkTo']['remote'].valueAt(context);

  String get linkToUrl => optionSet['linkTo']['url'].valueAt(context);

  /// _linkToHosted is only used to construct synthetic options.
  // ignore: unused_element
  String get _linkToHosted => optionSet['linkTo']['hosted'].valueAt(context);

  String get output => optionSet['output'].valueAt(context);

  PackageMeta get packageMeta => optionSet['packageMeta'].valueAt(context);

  List<String> get packageOrder => optionSet['packageOrder'].valueAt(context);

  bool get sdkDocs => optionSet['sdkDocs'].valueAt(context);

  String get sdkDir => optionSet['sdkDir'].valueAt(context);

  bool get showUndocumentedCategories =>
      optionSet['showUndocumentedCategories'].valueAt(context);

  PackageMeta get topLevelPackageMeta =>
      optionSet['topLevelPackageMeta'].valueAt(context);

  bool get useCategories => optionSet['useCategories'].valueAt(context);

  bool get validateLinks => optionSet['validateLinks'].valueAt(context);

  bool isLibraryExcluded(String name) =>
      exclude.any((pattern) => name == pattern);

  bool isPackageExcluded(String name) =>
      excludePackages.any((pattern) => name == pattern);

  /// Output format, e.g. 'html', 'md'
  String get format => optionSet['format'].valueAt(context);

  // TODO(jdkoren): temporary while we confirm href base behavior doesn't break important clients
  bool get useBaseHref => optionSet['useBaseHref'].valueAt(context);
}

/// Instantiate dartdoc's configuration file and options parser with the
/// given command line arguments.
Future<List<DartdocOption>> createDartdocOptions() async {
  return <DartdocOption>[
    DartdocOptionArgOnly<bool>('allowTools', false,
        help: 'Execute user-defined tools to fill in @tool directives.',
        negatable: true),
    DartdocOptionArgFile<double>('ambiguousReexportScorerMinConfidence', 0.1,
        help: 'Minimum scorer confidence to suppress warning on ambiguous '
            'reexport.'),
    DartdocOptionArgOnly<bool>('autoIncludeDependencies', false,
        help: 'Include all the used libraries into the docs, even the ones not '
            'in the current package or "include-external"',
        negatable: true),
    DartdocOptionArgFile<List<String>>('categoryOrder', [],
        help:
            "A list of categories (not package names) to place first when grouping symbols on dartdoc's sidebar. "
            'Unmentioned categories are sorted after these.'),
    DartdocOptionFileOnly<CategoryConfiguration>(
        'categories', CategoryConfiguration.empty,
        convertYamlToType: CategoryConfiguration.fromYamlMap,
        help: 'A list of all categories, their display names, and markdown '
            'documentation in the order they are to be displayed.'),
    DartdocOptionSyntheticOnly<List<String>>('dropTextFrom',
        (DartdocSyntheticOption<List<String>> option, Directory dir) {
      if (option.parent['hideSdkText'].valueAt(dir)) {
        return [
          'dart.async',
          'dart.collection',
          'dart.convert',
          'dart.core',
          'dart.developer',
          'dart.html',
          'dart.indexed_db',
          'dart.io',
          'dart.lisolate',
          'dart.js',
          'dart.js_util',
          'dart.math',
          'dart.mirrors',
          'dart.svg',
          'dart.typed_data',
          'dart.web_audio'
        ];
      }
      return [];
    }, help: 'Remove text from libraries with the following names.'),
    DartdocOptionArgFile<String>('examplePathPrefix', null,
        isDir: true,
        help: 'Prefix for @example paths.\n(defaults to the project root)',
        mustExist: true),
    DartdocOptionArgFile<List<String>>('exclude', [],
        help: 'Library names to ignore.', splitCommas: true),
    DartdocOptionArgOnly<List<String>>('excludePackages', [],
        help: 'Package names to ignore.', splitCommas: true),
    // This could be a ArgOnly, but trying to not provide too many ways
    // to set the flutter root.
    DartdocOptionSyntheticOnly<String>(
        'flutterRoot',
        (DartdocSyntheticOption<String> option, Directory dir) =>
            resolveTildePath(Platform.environment['FLUTTER_ROOT']),
        isDir: true,
        help: 'Root of the Flutter SDK, specified from environment.',
        mustExist: true),
    DartdocOptionArgOnly<bool>('hideSdkText', false,
        hide: true,
        help: 'Drop all text for SDK components.  Helpful for integration '
            'tests for dartdoc, probably not useful for anything else.',
        negatable: true),
    DartdocOptionArgFile<List<String>>('include', [],
        help: 'Library names to generate docs for.', splitCommas: true),
    DartdocOptionArgFile<List<String>>('includeExternal', null,
        isFile: true,
        help:
            'Additional (external) dart files to include; use "dir/fileName", '
            'as in lib/material.dart.',
        mustExist: true,
        splitCommas: true),
    DartdocOptionArgOnly<bool>('includeSource', true,
        help: 'Show source code blocks.', negatable: true),
    DartdocOptionArgOnly<bool>('injectHtml', false,
        help: 'Allow the use of the {@inject-html} directive to inject raw '
            'HTML into dartdoc output.'),
    DartdocOptionArgOnly<String>('input', directoryCurrentPath,
        isDir: true, help: 'Path to source directory', mustExist: true),
    DartdocOptionSyntheticOnly<String>('inputDir',
        (DartdocSyntheticOption<String> option, Directory dir) {
      if (option.parent['sdkDocs'].valueAt(dir)) {
        return option.parent['sdkDir'].valueAt(dir);
      }
      return option.parent['input'].valueAt(dir);
    },
        help: 'Path to source directory (with override if --sdk-docs)',
        isDir: true,
        mustExist: true),
    DartdocOptionSet('linkTo')
      ..addAll([
        DartdocOptionArgOnly<Map<String, String>>('hosted',
            {'pub.dartlang.org': 'https://pub.dev/documentation/%n%/%v%'},
            help: 'Specify URLs for hosted pub packages'),
        DartdocOptionArgOnly<Map<String, String>>(
          'sdks',
          {
            'Dart': 'https://api.dart.dev/%b%/%v%',
            'Flutter': 'https://api.flutter.dev/flutter',
          },
          help: 'Specify URLs for SDKs.',
        ),
        DartdocOptionFileSynth<String>('url',
            (DartdocSyntheticOption<String> option, Directory dir) {
          PackageMeta packageMeta =
              option.parent.parent['packageMeta'].valueAt(dir);
          // Prefer SDK check first, then pub cache check.
          var inSdk = packageMeta
              .sdkType(option.parent.parent['flutterRoot'].valueAt(dir));
          if (inSdk != null) {
            Map<String, String> sdks = option.parent['sdks'].valueAt(dir);
            if (sdks.containsKey(inSdk)) return sdks[inSdk];
          }
          var hostedAt = packageMeta.hostedAt;
          if (hostedAt != null) {
            Map<String, String> hostMap = option.parent['hosted'].valueAt(dir);
            if (hostMap.containsKey(hostedAt)) return hostMap[hostedAt];
          }
          return '';
        }, help: 'Url to use for this particular package.'),
        DartdocOptionArgOnly<bool>('remote', true,
            help: 'Allow links to be generated for packages outside this one.',
            negatable: true),
      ]),
    DartdocOptionArgOnly<String>('output', p.join('doc', 'api'),
        isDir: true, help: 'Path to output directory.'),
    DartdocOptionSyntheticOnly<PackageMeta>(
      'packageMeta',
      (DartdocSyntheticOption<PackageMeta> option, Directory dir) {
        var packageMeta = PackageMeta.fromDir(dir);
        if (packageMeta == null) {
          throw DartdocOptionError(
              'Unable to determine package for directory: ${dir.path}');
        }
        return packageMeta;
      },
    ),
    DartdocOptionArgOnly<List<String>>('packageOrder', [],
        help:
            'A list of package names to place first when grouping libraries in packages. '
            'Unmentioned packages are sorted after these.'),
    DartdocOptionArgOnly<bool>('sdkDocs', false,
        help: 'Generate ONLY the docs for the Dart SDK.'),
    DartdocOptionArgSynth<String>('sdkDir',
        (DartdocSyntheticOption<String> option, Directory dir) {
      if (!option.parent['sdkDocs'].valueAt(dir) &&
          (option.root['topLevelPackageMeta'].valueAt(dir) as PackageMeta)
              .requiresFlutter) {
        String flutterRoot = option.root['flutterRoot'].valueAt(dir);
        return p.join(flutterRoot, 'bin', 'cache', 'dart-sdk');
      }
      return defaultSdkDir.absolute.path;
    }, help: 'Path to the SDK directory.', isDir: true, mustExist: true),
    DartdocOptionArgFile<bool>('showUndocumentedCategories', false,
        help: "Label categories that aren't documented", negatable: true),
    DartdocOptionSyntheticOnly<PackageMeta>('topLevelPackageMeta',
        (DartdocSyntheticOption<PackageMeta> option, Directory dir) {
      var packageMeta = PackageMeta.fromDir(
          Directory(option.parent['inputDir'].valueAt(dir)));
      if (packageMeta == null) {
        throw DartdocOptionError(
            'Unable to generate documentation: no package found');
      }
      if (!packageMeta.isValid) {
        final firstError = packageMeta.getInvalidReasons().first;
        throw DartdocOptionError('Package is invalid: $firstError');
      }
      return packageMeta;
    }, help: 'PackageMeta object for the default package.'),
    DartdocOptionArgOnly<bool>('useCategories', true,
        help: 'Display categories in the sidebar of packages'),
    DartdocOptionArgOnly<bool>('validateLinks', true,
        help:
            'Runs the built-in link checker to display Dart context aware warnings for broken links (slow)',
        negatable: true),
    DartdocOptionArgOnly<bool>('verboseWarnings', true,
        help: 'Display extra debugging information and help with warnings.',
        negatable: true),
    DartdocOptionFileOnly<bool>('excludeFooterVersion', false,
        help: 'Excludes the package version number in the footer text'),
    DartdocOptionFileOnly<ToolConfiguration>('tools', ToolConfiguration.empty,
        convertYamlToType: ToolConfiguration.fromYamlMap,
        help: 'A map of tool names to executable paths. Each executable must '
            'exist. Executables for different platforms are specified by '
            'giving the platform name as a key, and a list of strings as the '
            'command.'),
    DartdocOptionArgOnly<bool>('useBaseHref', false,
        help:
            'Use <base href> in generated files (legacy behavior). This option '
            'is temporary and support will be removed in the future. Use only '
            'if the default behavior breaks links between your documentation '
            'pages, and please file an issue on Github.',
        negatable: false,
        hide: true),
    // TODO(jdkoren): Unhide when we have good support for another format.
    DartdocOptionArgOnly<String>('format', 'html', hide: true),
    // TODO(jcollins-g): refactor so there is a single static "create" for
    // each DartdocOptionContext that traverses the inheritance tree itself.
    ...await createExperimentOptions(),
    ...await createPackageWarningOptions(),
    ...await createSourceLinkerOptions(),
  ];
}
