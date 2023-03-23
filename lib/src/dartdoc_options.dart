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

import 'dart:io' show Platform, stdout;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:args/args.dart';
import 'package:dartdoc/src/experiment_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/tool_definition.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as p show Context, canonicalize;
import 'package:yaml/yaml.dart';

/// Constants to help with type checking, because T is int and so forth
/// don't work in Dart.
const String _kStringVal = '';
const List<String> _kListStringVal = <String>[];
const Map<String, String> _kMapStringVal = <String, String>{};
const int _kIntVal = 0;
const double _kDoubleVal = 0.0;
const bool _kBoolVal = true;

const String compileArgsTagName = 'compile_args';

int get _usageLineLength => stdout.hasTerminal ? stdout.terminalColumns : 80;

typedef ConvertYamlToType<T> = T Function(YamlMap, String, ResourceProvider);

class DartdocOptionError extends DartdocFailure {
  DartdocOptionError(super.details);
}

class DartdocFileMissing extends DartdocOptionError {
  DartdocFileMissing(super.details);
}

/// Defines the attributes of a category in the options file, corresponding to
/// the 'categories' keyword in the options file, and populated by the
/// [CategoryConfiguration] class.
class CategoryDefinition {
  /// Internal name of the category, or null for the default category.
  final String? name;

  /// Displayed name of the category in docs, or null if there is none.
  final String? _displayName;

  /// Canonical path of the markdown file used to document this category
  /// (or null if undocumented).
  final String? documentationMarkdown;

  CategoryDefinition(this.name, this._displayName, this.documentationMarkdown);

  /// Returns the [_displayName], if available, or else simply [name].
  String get displayName => _displayName ?? name ?? '';
}

/// A configuration class that can interpret category definitions from a YAML
/// map.
class CategoryConfiguration {
  /// A map of [CategoryDefinition.name] to [CategoryDefinition] objects.
  final Map<String, CategoryDefinition> categoryDefinitions;

  CategoryConfiguration._(this.categoryDefinitions);

  static CategoryConfiguration get empty {
    return CategoryConfiguration._(const {});
  }

  static CategoryConfiguration fromYamlMap(YamlMap yamlMap,
      String canonicalYamlPath, ResourceProvider resourceProvider) {
    var newCategoryDefinitions = <String, CategoryDefinition>{};
    for (var entry in yamlMap.entries) {
      var name = entry.key.toString();
      var categoryMap = entry.value;
      if (categoryMap is Map) {
        var displayName = categoryMap['displayName']?.toString();
        var documentationMarkdown = categoryMap['markdown']?.toString();
        if (documentationMarkdown != null) {
          documentationMarkdown = resourceProvider.pathContext.canonicalize(
              resourceProvider.pathContext
                  .join(canonicalYamlPath, documentationMarkdown));
          if (!resourceProvider.getFile(documentationMarkdown).exists) {
            throw DartdocFileMissing(
                'In categories definition for $name, "markdown" resolves to '
                'the missing file $documentationMarkdown');
          }
        }
        newCategoryDefinitions[name] =
            CategoryDefinition(name, displayName, documentationMarkdown);
      }
    }
    return CategoryConfiguration._(newCategoryDefinitions);
  }
}

/// A configuration class that can interpret [ToolDefinition]s from a YAML map.
class ToolConfiguration {
  final Map<String, ToolDefinition> tools;

  final ResourceProvider resourceProvider;

  late ToolRunner runner = ToolRunner(this);

  ToolConfiguration._(this.tools, this.resourceProvider);

  static ToolConfiguration empty(ResourceProvider resourceProvider) {
    return ToolConfiguration._(const {}, resourceProvider);
  }

  // TODO(jcollins-g): consider caching these.
  static ToolConfiguration fromYamlMap(YamlMap yamlMap,
      String canonicalYamlPath, ResourceProvider resourceProvider) {
    var newToolDefinitions = <String, ToolDefinition>{};
    var pathContext = resourceProvider.pathContext;
    for (var entry in yamlMap.entries) {
      var name = entry.key.toString();
      var toolMap = entry.value;
      String? description;
      List<String>? compileArgs;
      List<String>? command;
      List<String>? setupCommand;
      if (toolMap is Map) {
        description = toolMap['description'].toString();
        List<String>? findCommand([String prefix = '']) {
          List<String>? command;
          // If the command key is given, then it applies to all platforms.
          var commandFromKey = toolMap.containsKey('${prefix}command')
              ? '${prefix}command'
              : '$prefix${Platform.operatingSystem}';
          if (toolMap.containsKey(commandFromKey)) {
            var commandFrom = toolMap[commandFromKey] as YamlNode;
            if (commandFrom.value is String) {
              command = [commandFrom.toString()];
              if (command[0].isEmpty) {
                throw DartdocOptionError(
                    'Tool commands must not be empty. Tool $name command entry '
                    '"$commandFromKey" must contain at least one path.');
              }
            } else if (commandFrom is YamlList) {
              command =
                  commandFrom.map<String>((node) => node.toString()).toList();
              if (command.isEmpty) {
                throw DartdocOptionError(
                    'Tool commands must not be empty. Tool $name command entry '
                    '"$commandFromKey" must contain at least one path.');
              }
            } else {
              throw DartdocOptionError(
                  'Tool commands must be a path to an executable, or a list of '
                  'strings that starts with a path to an executable. '
                  'The tool $name has a $commandFromKey entry that is a '
                  '${commandFrom.runtimeType}');
            }
          }
          return command;
        }

        command = findCommand();
        setupCommand = findCommand('setup_');

        List<String>? findArgs() {
          List<String>? args;
          if (toolMap.containsKey(compileArgsTagName)) {
            var compileArgs = toolMap[compileArgsTagName];
            if (compileArgs is String) {
              args = [toolMap[compileArgsTagName].toString()];
            } else if (compileArgs is YamlList) {
              args = compileArgs
                  .map<String>((node) => node.toString())
                  .toList(growable: false);
            } else {
              throw DartdocOptionError(
                  'Tool compile arguments must be a list of strings. The tool '
                  '$name has a $compileArgsTagName entry that is a '
                  '${compileArgs.runtimeType}');
            }
          }
          return args;
        }

        compileArgs = findArgs();
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
        var executableFile = resourceProvider.getFile(executable);
        if (resourceProvider.isNotFound(executableFile)) {
          throw DartdocOptionError('Command executables must exist. '
              'The file "$executable" does not exist for tool $name.');
        }

        var isDartCommand = ToolDefinition.isDartExecutable(executable);
        // Dart scripts don't need to be executable, because they'll be
        // executed with the Dart binary.
        if (!isDartCommand && !resourceProvider.isExecutable(executableFile)) {
          throw DartdocOptionError('Non-Dart commands must be '
              'executable. The file "$executable" for tool $name does not have '
              'execute permission.');
        }
        return isDartCommand;
      }

      var executableRelativePath = command.removeAt(0);
      var executable = pathContext.canonicalize(
          pathContext.join(canonicalYamlPath, executableRelativePath));
      validateExecutable(executable);
      if (setupCommand != null) {
        var setupExecutableRelativePath = setupCommand.removeAt(0);
        var setupExecutable = pathContext.canonicalize(
            pathContext.join(canonicalYamlPath, setupExecutableRelativePath));
        var isDartSetupCommand = validateExecutable(executable);
        // Setup commands aren't snapshotted, since they're only run once.
        setupCommand = (isDartSetupCommand
                ? [Platform.resolvedExecutable, setupExecutable]
                : [setupExecutable]) +
            setupCommand;
      }
      newToolDefinitions[name] = ToolDefinition.fromCommand(
          [executable] + command,
          setupCommand ?? const [],
          description,
          resourceProvider,
          compileArgs: compileArgs ?? const []);
    }
    return ToolConfiguration._(newToolDefinitions, resourceProvider);
  }
}

/// A container class to keep track of where our yaml data came from.
class _YamlFileData {
  /// The map from the yaml file.
  final Map<Object?, Object?> data;

  /// The path to the directory containing the yaml file.
  final String canonicalDirectoryPath;

  _YamlFileData(this.data, this.canonicalDirectoryPath);
}

/// An enum to specify the multiple different kinds of data an option might
/// represent.
enum OptionKind {
  other, // Make no assumptions about the option data; it may be of any type
  // or semantic.
  file, // Option data references a filename or filenames with strings.
  dir, // Option data references a directory name or names with strings.
  glob, // Option data references globs with strings that may cover many
  // filenames and/or directories.
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
  String? definingFile;

  /// A [pathLib.Context] variable initialized with canonicalDirectoryPath.
  p.Context pathContext;

  /// Build a _OptionValueWithContext.
  ///
  /// [path] is the path where this value came from (not required to be
  /// canonical).
  _OptionValueWithContext(this.value, String path, {this.definingFile})
      : canonicalDirectoryPath = p.canonicalize(path),
        pathContext = p.Context(current: p.canonicalize(path));

  /// Assume value is a path, and attempt to resolve it.
  ///
  /// Throws [UnsupportedError] if [T] isn't a [String] or [List<String>].
  T get resolvedValue {
    final value = this.value;
    if (value is List<String>) {
      return value
          .map((v) => pathContext.canonicalizeWithTilde(v))
          .cast<String>()
          .toList(growable: false) as T;
    } else if (value is String) {
      return pathContext.canonicalizeWithTilde(value) as T;
    } else if (value is Map<String, String>) {
      return value.map<String, String>((String key, String value) {
        return MapEntry(key, pathContext.canonicalizeWithTilde(value));
      }) as T;
    } else {
      throw UnsupportedError('Type $T is not supported for resolvedValue');
    }
  }
}

/// An abstract class for interacting with dartdoc options.
///
/// This class and its implementations allow Dartdoc to declare options that
/// are both defined in a configuration file and specified via the command line,
/// with searching the directory tree for a proper file and overriding file
/// options with the command line built-in.  A number of sanity checks are also
/// built in to these classes so that file existence can be verified, types
/// constrained, and defaults provided.
///
/// This class caches the current working directory from the [ResourceProvider];
/// do not attempt to change it during the life of an instance.
///
/// Use via implementations [DartdocOptionSet], [DartdocOptionArgFile],
/// [DartdocOptionArgOnly], and [DartdocOptionFileOnly].
abstract class DartdocOption<T extends Object?> {
  /// This is the value returned if we couldn't find one otherwise.
  final T? defaultsTo;

  /// Text string for help passed on in command line options.
  final String help;

  /// The name of this option, not including the names of any parents.
  final String name;

  /// Set to true if this option represents the name of a directory.
  bool get isDir => optionIs == OptionKind.dir;

  /// Set to true if this option represents the name of a file.
  bool get isFile => optionIs == OptionKind.file;

  /// Set to true if this option represents a glob.
  bool get isGlob => optionIs == OptionKind.glob;

  final OptionKind optionIs;

  /// Set to true if DartdocOption subclasses should validate that the
  /// directory or file exists.  Does not imply validation of [defaultsTo],
  /// and requires that one of [isDir] or [isFile] is set.
  final bool mustExist;

  final ResourceProvider resourceProvider;

  DartdocOption(this.name, this.defaultsTo, this.help, this.optionIs,
      this.mustExist, this._convertYamlToType, this.resourceProvider) {
    if (isDir || isFile || isGlob) {
      assert(_isString || _isListString || _isMapString);
    }
    if (mustExist) {
      // Globs by definition don't have to exist.
      assert(isDir || isFile);
    }
  }

  /// Closure to convert yaml data into some other structure.
  final ConvertYamlToType<T>? _convertYamlToType;

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

  String get _expectedTypeForDisplay {
    if (_isString) return 'String';
    if (_isListString) return 'list of Strings';
    if (_isMapString) return 'map of String to String';
    if (_isBool) return 'boolean';
    if (_isInt) return 'int';
    if (_isDouble) return 'double';
    assert(false, 'Expecting an unknown type');
    return '<<unknown>>';
  }

  final Map<String, _YamlFileData> __yamlAtCanonicalPathCache = {};

  /// Implementation detail for [DartdocOptionFileOnly].  Make sure we use
  /// the root node's cache.
  Map<String, _YamlFileData> get _yamlAtCanonicalPathCache =>
      root.__yamlAtCanonicalPathCache;

  /// Throw [DartdocFileMissing] with a detailed error message indicating where
  /// the error came from when a file or directory option is missing.
  void _onMissing(
      _OptionValueWithContext<T> valueWithContext, String missingFilename);

  /// Call [_onMissing] for every path that does not exist.
  void _validatePaths(_OptionValueWithContext<T> valueWithContext) {
    if (!mustExist) return;
    assert(isDir || isFile);
    List<String> resolvedPaths;
    var value = valueWithContext.value;
    if (value is String) {
      resolvedPaths = [valueWithContext.resolvedValue as String];
    } else if (value is List<String>) {
      resolvedPaths = valueWithContext.resolvedValue as List<String>;
    } else if (value is Map<String, String>) {
      resolvedPaths = [...(valueWithContext.resolvedValue as Map).values];
    } else {
      assert(
          false,
          'Trying to ensure existence of unsupported type '
          '${valueWithContext.value.runtimeType}');
      return;
    }
    for (var path in resolvedPaths) {
      var f = isDir
          ? resourceProvider.getFolder(path)
          : resourceProvider.getFile(path);
      if (!f.exists) {
        _onMissing(valueWithContext, path);
      }
    }
  }

  /// For a [List<String>] or [String] value, if [isDir] or [isFile] is set,
  /// resolve paths in value relative to canonicalPath.
  T? _handlePathsInContext(_OptionValueWithContext<T>? valueWithContext) {
    if (valueWithContext?.value == null || !(isDir || isFile || isGlob)) {
      return valueWithContext?.value;
    }
    _validatePaths(valueWithContext!);
    return valueWithContext.resolvedValue;
  }

  /// Call this with argv to set up the argument overrides.  Applies to all
  /// children.
  void parseArguments(List<String> arguments) =>
      root._parseArguments(arguments);

  ArgResults get _argResults => root.__argResults;

  /// To avoid accessing early, call [add] on the option's parent before
  /// looking up unless this is a [DartdocOptionRoot].
  late final DartdocOption<dynamic> parent;

  /// The [DartdocOptionRoot] containing this object.
  DartdocOptionRoot get root {
    DartdocOption<dynamic> p = this;
    while (p is! DartdocOptionRoot) {
      p = p.parent;
    }
    return p;
  }

  /// All object names starting at the root.
  Iterable<String> get keys {
    var keyList = <String>[];
    DartdocOption<dynamic> option = this;
    while (option is! DartdocOptionRoot) {
      keyList.add(option.name);
      option = option.parent;
    }
    keyList.add(option.name);
    return keyList.reversed;
  }

  /// Direct children of this node, mapped by name.
  final Map<String, DartdocOption> _children = {};

  /// Return the calculated value of this option, given the directory as
  /// context.
  ///
  /// If [isFile] or [isDir] is set, the returned value will be transformed
  /// into a canonical path relative to the current working directory
  /// (for arguments) or the config file from which the value was derived.
  ///
  /// May throw [DartdocOptionError] if a command line argument is of the wrong
  /// type.  If [mustExist] is true, will throw [DartdocFileMissing] for command
  /// line parameters and file paths in config files that don't point to
  /// corresponding files or directories.
  // TODO(jcollins-g): use of dynamic.  https://github.com/dart-lang/dartdoc/issues/2814
  dynamic valueAt(Folder dir);

  /// Calls [valueAt] with the working directory at the start of the program.
  // TODO(jcollins-g): use of dynamic.  https://github.com/dart-lang/dartdoc/issues/2814
  Object? valueAtCurrent() => valueAt(_directoryCurrent);

  late final Folder _directoryCurrent =
      resourceProvider.getFolder(_directoryCurrentPath);
  late final String _directoryCurrentPath =
      resourceProvider.pathContext.current;

  /// Adds a DartdocOption to the children of this DartdocOption.
  void add(DartdocOption option) {
    if (_children.containsKey(option.name)) {
      throw DartdocOptionError(
          'Tried to add two children with the same name: ${option.name}');
    }
    _children[option.name] = option;
    // TODO(jcollins-g): Consider a stronger refactor that doesn't rely on
    // post-construction setup for [parent].
    option.parent = this;
  }

  /// This method is called when parsing options to set up the [ArgParser].
  void _addToArgParser(ArgParser argParser) {}

  /// Adds a list of dartdoc options to the children of this DartdocOption.
  void addAll(Iterable<DartdocOption> options) => options.forEach(add);

  /// Get the immediate child of this node named [name].
  DartdocOption operator [](String name) {
    return _children[name]!;
  }

  /// Get the immediate child of this node named [name] and its value at [dir].
  U getValueAs<U extends Object?>(String name, Folder dir) =>
      _children[name]?.valueAt(dir) as U;

  /// Apply the function [visit] to [this] and all children.
  void traverse(void Function(DartdocOption option) visit) {
    visit(this);
    for (var value in _children.values) {
      value.traverse(visit);
    }
  }
}

/// A class that defaults to a value computed from a closure, but can be
/// overridden by a file.
class DartdocOptionFileSynth<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T>, _DartdocFileOption<T> {
  @override
  final bool parentDirOverridesChild;
  @override
  final T Function(DartdocSyntheticOption<T>, Folder) _compute;

  DartdocOptionFileSynth(
      String name, this._compute, ResourceProvider resourceProvider,
      {bool mustExist = false,
      String help = '',
      OptionKind optionIs = OptionKind.other,
      this.parentDirOverridesChild = false,
      ConvertYamlToType<T>? convertYamlToType})
      : super(name, null, help, optionIs, mustExist, convertYamlToType,
            resourceProvider);

  @override
  T? valueAt(Folder dir) {
    var result = _valueAtFromFile(dir);
    if (result?.definingFile != null) {
      return _handlePathsInContext(result);
    }
    return _valueAtFromSynthetic(dir);
  }

  @override
  void _onMissing(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    if (valueWithContext.definingFile != null) {
      _onMissingFromFiles(valueWithContext, missingPath);
    } else {
      _onMissingFromSynthetic(valueWithContext, missingPath);
    }
  }
}

/// A class that defaults to a value computed from a closure, but can
/// be overridden on the command line.
class DartdocOptionArgSynth<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T>, _DartdocArgOption<T> {
  @override
  final String? abbr;
  @override
  final bool hide;
  @override
  final bool negatable;
  @override
  final bool splitCommas;

  @override
  final T Function(DartdocSyntheticOption<T>, Folder) _compute;

  DartdocOptionArgSynth(
      String name, this._compute, ResourceProvider resourceProvider,
      {this.abbr,
      bool mustExist = false,
      String help = '',
      this.hide = false,
      OptionKind optionIs = OptionKind.other,
      this.negatable = false,
      this.splitCommas = false})
      : assert(T is! Iterable || splitCommas == true),
        super(name, null, help, optionIs, mustExist, null, resourceProvider);

  @override
  void _onMissing(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    _onMissingFromArgs(valueWithContext, missingPath);
  }

  @override
  T? valueAt(Folder dir) {
    if (_argResults.wasParsed(argName)) {
      return _valueAtFromArgs();
    }
    return _valueAtFromSynthetic(dir);
  }
}

/// A synthetic option takes a closure at construction time that computes
/// the value of the configuration option based on other configuration options.
/// Does not protect against closures that self-reference.  If [mustExist] and
/// [isDir] or [isFile] is set, computed values will be resolved to canonical
/// paths.
class DartdocOptionSyntheticOnly<T> extends DartdocOption<T>
    with DartdocSyntheticOption<T> {
  @override
  final T Function(DartdocSyntheticOption<T>, Folder) _compute;

  DartdocOptionSyntheticOnly(
      String name, this._compute, ResourceProvider resourceProvider,
      {bool mustExist = false,
      String help = '',
      OptionKind optionIs = OptionKind.other})
      : super(name, null, help, optionIs, mustExist, null, resourceProvider);
}

abstract class DartdocSyntheticOption<T> implements DartdocOption<T> {
  T Function(DartdocSyntheticOption<T>, Folder) get _compute;

  @override
  T? valueAt(Folder dir) => _valueAtFromSynthetic(dir);

  T? _valueAtFromSynthetic(Folder dir) {
    var context = _OptionValueWithContext<T>(_compute(this, dir), dir.path);
    return _handlePathsInContext(context);
  }

  @override
  void _onMissing(
          _OptionValueWithContext<T> valueWithContext, String missingPath) =>
      _onMissingFromSynthetic(valueWithContext, missingPath);

  void _onMissingFromSynthetic(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    var description = 'Synthetic configuration option $name from <internal>';
    throw DartdocFileMissing(
        '$description, computed as ${valueWithContext.value}, resolves to '
        'missing path: "$missingPath"');
  }
}

typedef OptionGenerator = List<DartdocOption> Function(PackageMetaProvider);

/// This is a [DartdocOptionSet] used as a root node.
class DartdocOptionRoot extends DartdocOptionSet {
  DartdocOptionRoot(super.name, super.resourceProvider);

  late final ArgParser _argParser =
      ArgParser(usageLineLength: _usageLineLength);

  /// Asynchronous factory that is the main entry point to initialize Dartdoc
  /// options for use.
  ///
  /// [name] is the top level key for the option set.
  /// [optionGenerators] is a sequence of asynchronous functions that return
  /// [DartdocOption]s that will be added to the new option set.
  static DartdocOptionRoot fromOptionGenerators(
      String name,
      Iterable<OptionGenerator> optionGenerators,
      PackageMetaProvider packageMetaProvider) {
    var optionSet =
        DartdocOptionRoot(name, packageMetaProvider.resourceProvider);
    for (var generator in optionGenerators) {
      optionSet.addAll(generator(packageMetaProvider));
    }
    return optionSet;
  }

  ArgParser get argParser => _argParser;

  /// Initialized via [_parseArguments].
  late ArgResults __argResults;

  bool _argParserInitialized = false;

  /// Parse these as string arguments (from argv) with the argument parser.
  /// Call before calling [valueAt] for any [DartdocOptionArgOnly] or
  /// [DartdocOptionArgFile] in this tree.
  void _parseArguments(List<String> arguments) {
    if (!_argParserInitialized) {
      _argParserInitialized = true;
      traverse((DartdocOption option) {
        option._addToArgParser(argParser);
      });
    }
    __argResults = argParser.parse(arguments);
  }

  /// Traverse skips this node, because it doesn't represent a real
  /// configuration object.
  @override
  void traverse(void Function(DartdocOption option) visitor) {
    for (var value in _children.values) {
      value.traverse(visitor);
    }
  }

  @override
  DartdocOption get parent =>
      throw UnsupportedError('Root nodes have no parent');
}

/// A [DartdocOption] that only contains other [DartdocOption]s and is not an
/// option itself.
class DartdocOptionSet extends DartdocOption<void> {
  DartdocOptionSet(String name, ResourceProvider resourceProvider)
      : super(name, null, '', OptionKind.other, false, null, resourceProvider);

  /// [DartdocOptionSet] always has the null value.
  @override
  void valueAt(Folder dir) {}

  /// Since we have no value, [_onMissing] does nothing.
  @override
  void _onMissing(
      _OptionValueWithContext<void> valueWithContext, String missingFilename) {}
}

/// A [DartdocOption] that only exists as a command line argument. `--help` is a
/// good example.
class DartdocOptionArgOnly<T> extends DartdocOption<T>
    with _DartdocArgOption<T> {
  @override
  final String? abbr;
  @override
  final bool hide;
  @override
  final bool negatable;
  @override
  final bool splitCommas;

  DartdocOptionArgOnly(
      String name, T defaultsTo, ResourceProvider resourceProvider,
      {this.abbr,
      bool mustExist = false,
      String help = '',
      this.hide = false,
      OptionKind optionIs = OptionKind.other,
      this.negatable = false,
      this.splitCommas = false})
      : super(name, defaultsTo, help, optionIs, mustExist, null,
            resourceProvider);
}

/// A [DartdocOption] that works with command line arguments and
/// `dartdoc_options` files.
class DartdocOptionArgFile<T> extends DartdocOption<T>
    with _DartdocArgOption<T>, _DartdocFileOption<T> {
  @override
  final String? abbr;
  @override
  final bool hide;
  @override
  final bool negatable;
  @override
  final bool parentDirOverridesChild;
  @override
  final bool splitCommas;

  DartdocOptionArgFile(
      String name, T defaultsTo, ResourceProvider resourceProvider,
      {this.abbr,
      bool mustExist = false,
      String help = '',
      this.hide = false,
      OptionKind optionIs = OptionKind.other,
      this.negatable = false,
      this.parentDirOverridesChild = false,
      this.splitCommas = false})
      : super(name, defaultsTo, help, optionIs, mustExist, null,
            resourceProvider);

  @override
  void _onMissing(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    if (valueWithContext.definingFile != null) {
      _onMissingFromFiles(valueWithContext, missingPath);
    } else {
      _onMissingFromArgs(valueWithContext, missingPath);
    }
  }

  /// Try to find an explicit argument setting this value, and fall back first
  /// to files, then to the default.
  @override
  T? valueAt(Folder dir) =>
      _valueAtFromArgs() ?? _valueAtFromFiles(dir) ?? defaultsTo;
}

class DartdocOptionFileOnly<T> extends DartdocOption<T>
    with _DartdocFileOption<T> {
  @override
  final bool parentDirOverridesChild;

  DartdocOptionFileOnly(
      String name, T defaultsTo, ResourceProvider resourceProvider,
      {bool mustExist = false,
      String help = '',
      OptionKind optionIs = OptionKind.other,
      this.parentDirOverridesChild = false,
      ConvertYamlToType<T>? convertYamlToType})
      : super(name, defaultsTo, help, optionIs, mustExist, convertYamlToType,
            resourceProvider);
}

/// Implements checking for options contained in dartdoc.yaml.
abstract class _DartdocFileOption<T> implements DartdocOption<T> {
  /// If true, the parent directory's value overrides the child's.
  ///
  /// Otherwise, the child's value overrides values in parents.
  bool get parentDirOverridesChild;

  /// The name of the option, with nested options joined by `.`.  For example:
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
          _OptionValueWithContext<T> valueWithContext, String missingPath) =>
      _onMissingFromFiles(valueWithContext, missingPath);

  void _onMissingFromFiles(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    var dartdocYaml = resourceProvider.pathContext.join(
        valueWithContext.canonicalDirectoryPath, valueWithContext.definingFile);
    throw DartdocFileMissing('Field $fieldName from $dartdocYaml, set to '
        '${valueWithContext.value}, resolves to missing path: "$missingPath"');
  }

  @override

  /// Searches for a value in configuration files relative to [dir], and if not
  /// found, returns [defaultsTo].
  T? valueAt(Folder dir) => _valueAtFromFiles(dir) ?? defaultsTo;

  /// The backing store for [_valueAtFromFiles].
  final Map<String, T?> __valueAtFromFiles = {};

  // The value of this option from files will not change unless files are
  // modified during execution (not allowed in Dartdoc).
  T? _valueAtFromFiles(Folder dir) {
    var key = resourceProvider.pathContext.canonicalize(dir.path);
    if (!__valueAtFromFiles.containsKey(key)) {
      _OptionValueWithContext<T>? valueWithContext;
      if (parentDirOverridesChild) {
        valueWithContext = _valueAtFromFilesLastFound(dir);
      } else {
        valueWithContext = _valueAtFromFilesFirstFound(dir);
      }
      __valueAtFromFiles[key] = _handlePathsInContext(valueWithContext);
    }
    return __valueAtFromFiles[key];
  }

  /// Searches all dartdoc_options files through parent directories, starting at
  /// [dir], for the option and returns one once found.
  _OptionValueWithContext<T>? _valueAtFromFilesFirstFound(Folder folder) {
    _OptionValueWithContext<T>? value;
    for (var dir in folder.withAncestors) {
      value = _valueAtFromFile(dir);
      if (value != null) break;
    }
    return value;
  }

  /// Searches all dartdoc_options files for the option, and returns the value
  /// in the top-most parent directory `dartdoc_options.yaml` file it is
  /// mentioned in.
  _OptionValueWithContext<T>? _valueAtFromFilesLastFound(Folder folder) {
    _OptionValueWithContext<T>? value;
    for (var dir in folder.withAncestors) {
      var tmpValue = _valueAtFromFile(dir);
      if (tmpValue != null) value = tmpValue;
    }
    return value;
  }

  /// Returns null if not set in the YAML file in this directory (or its
  /// parents).
  _OptionValueWithContext<T>? _valueAtFromFile(Folder dir) {
    var yamlFileData = _yamlAtDirectory(dir);
    var contextPath = yamlFileData.canonicalDirectoryPath;
    Object yamlData = yamlFileData.data;
    for (var key in keys) {
      if (yamlData is Map && !yamlData.containsKey(key)) return null;
      yamlData = (yamlData as Map)[key] ?? {};
    }

    Object? returnData;
    if (_isListString) {
      if (yamlData is YamlList) {
        returnData = [
          for (var item in yamlData) item.toString(),
        ];
      }
    } else if (yamlData is YamlMap) {
      var convertYamlToType = _convertYamlToType;
      // TODO(jcollins-g): This special casing is unfortunate.  Consider
      // a refactor to extract yaml data conversion into closures 100% of the
      // time or find a cleaner way to do this.
      //
      // A refactor probably would integrate resolvedValue for
      // _OptionValueWithContext into the return data here, and would not have
      // that be separate.
      if (_isMapString && convertYamlToType == null) {
        convertYamlToType = (YamlMap yamlMap, String canonicalYamlPath,
            ResourceProvider resourceProvider) {
          var returnData = <String, String>{};
          for (var entry in yamlMap.entries) {
            returnData[entry.key.toString()] = entry.value.toString();
          }
          return returnData as T;
        };
      }
      if (convertYamlToType == null) {
        throw UnsupportedError(
            '$fieldName: convertYamlToType method not defined');
      }
      var canonicalDirectoryPath =
          resourceProvider.pathContext.canonicalize(contextPath);
      returnData =
          convertYamlToType(yamlData, canonicalDirectoryPath, resourceProvider);
    } else if (_isDouble) {
      if (yamlData is num) {
        returnData = yamlData.toDouble();
      }
    } else if (_isInt || _isString || _isBool) {
      if (yamlData is T) {
        returnData = yamlData;
      }
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
    if (returnData == null) {
      throw DartdocOptionError('Error in dartdoc_options.yaml, $fieldName: '
          'expecting a $_expectedTypeForDisplay, got `$yamlData`');
    }
    return _OptionValueWithContext(returnData as T, contextPath,
        definingFile: 'dartdoc_options.yaml');
  }

  _YamlFileData _yamlAtDirectory(Folder folder) {
    var canonicalPaths = <String>[];
    var yamlData = _YamlFileData({}, _directoryCurrentPath);

    for (var dir in folder.withAncestors) {
      var canonicalPath =
          resourceProvider.pathContext.canonicalize(folder.path);
      if (_yamlAtCanonicalPathCache.containsKey(canonicalPath)) {
        yamlData = _yamlAtCanonicalPathCache[canonicalPath]!;
        break;
      }
      canonicalPaths.add(canonicalPath);
      if (dir.exists) {
        var dartdocOptionsFile = resourceProvider.getFile(resourceProvider
            .pathContext
            .join(dir.path, 'dartdoc_options.yaml'));
        if (dartdocOptionsFile.exists) {
          final yaml = loadYaml(dartdocOptionsFile.readAsStringSync());
          // [loadYaml] will return `null` for empty (or all comment) YAML
          // files, so we must check for that case.
          if (yaml != null) {
            yamlData = _YamlFileData(
                yaml, resourceProvider.pathContext.canonicalize(dir.path));
          }
          break;
        }
      }
    }
    for (var canonicalPath in canonicalPaths) {
      _yamlAtCanonicalPathCache[canonicalPath] = yamlData;
    }
    return yamlData;
  }
}

/// Mixin class implementing command-line arguments for [DartdocOption].
abstract class _DartdocArgOption<T> implements DartdocOption<T> {
  /// For [ArgParser], set to true if the argument can be negated with `--no` on
  /// the command line.
  bool get negatable;

  /// For [ArgParser], set to true if a single string argument will be broken
  /// into a list on commas.
  bool get splitCommas;

  /// For [ArgParser], set to true to hide this from the help menu.
  bool get hide;

  /// For [ArgParser], set to a single character to have a short version of the
  /// command line argument.
  String? get abbr;

  /// valueAt for arguments ignores the [dir] parameter and only uses command
  /// line arguments and the current working directory to resolve the result.
  @override
  T? valueAt(Folder dir) => _valueAtFromArgs() ?? defaultsTo;

  /// For passing in to [int.parse] and [double.parse] `onError'.
  void _throwErrorForTypes(String value) {
    String example;
    if (defaultsTo is Map) {
      example = 'key::value';
    } else if (_isInt) {
      example = '32';
    } else if (_isDouble) {
      example = '0.76';
    } else {
      throw UnimplementedError(
          'Type for $name is not implemented in $_throwErrorForTypes');
    }
    throw DartdocOptionError(
        'Invalid argument value: --$argName, set to "$value", must be a '
        '$T.  Example:  --$argName $example');
  }

  /// Returns null if no argument was given on the command line.
  T? _valueAtFromArgs() {
    var valueWithContext = _valueAtFromArgsWithContext();
    return _handlePathsInContext(valueWithContext);
  }

  @override
  void _onMissing(
          _OptionValueWithContext<T> valueWithContext, String missingPath) =>
      _onMissingFromArgs(valueWithContext, missingPath);

  void _onMissingFromArgs(
      _OptionValueWithContext<T> valueWithContext, String missingPath) {
    throw DartdocFileMissing(
        'Argument --$argName, set to ${valueWithContext.value}, resolves to '
        'missing path: "$missingPath"');
  }

  /// Generates an _OptionValueWithContext using the value of the argument from
  /// the [argParser] and the working directory from [_directoryCurrent].
  ///
  /// Throws [UnsupportedError] if [T] is not a supported type.
  _OptionValueWithContext<T>? _valueAtFromArgsWithContext() {
    if (!_argResults.wasParsed(argName)) return null;

    // Unlike in _DartdocFileOption, we throw here on inputs being invalid
    // rather than silently proceeding.  This is because the user presumably
    // typed something wrong on the command line and can therefore fix it.
    // dartdoc_option.yaml files from other packages may not be fully in the
    // user's control.
    if (_isBool || _isListString || _isString) {
      return _OptionValueWithContext(
          _argResults[argName], _directoryCurrentPath);
    } else if (_isInt) {
      var value = int.tryParse(_argResults[argName]);
      if (value == null) _throwErrorForTypes(_argResults[argName]);
      return _OptionValueWithContext(value as T, _directoryCurrentPath);
    } else if (_isDouble) {
      var value = double.tryParse(_argResults[argName]);
      if (value == null) _throwErrorForTypes(_argResults[argName]);
      return _OptionValueWithContext(value as T, _directoryCurrentPath);
    } else if (_isMapString) {
      var value = <String, String>{};
      for (String pair in _argResults[argName]) {
        var pairList = pair.split('::');
        if (pairList.length != 2) {
          _throwErrorForTypes(pair);
        }
        value[pairList.first] = pairList.last;
      }
      return _OptionValueWithContext(value as T, _directoryCurrentPath);
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }

  /// The name of this option as a command line argument.
  String get argName => _keysToArgName(keys);

  /// Turns ['foo', 'somethingBar', 'over_the_hill'] into
  /// 'something-bar-over-the-hill' (with default skip).
  /// This allows argument names to reflect nested structure.
  static String _keysToArgName(Iterable<String> keys, [int skip = 1]) {
    var argName = keys.skip(skip).join('-');
    argName = argName.replaceAll('_', '-');
    // Do not consume the lowercase character after the uppercase one, to handle
    // two character words.
    final camelCaseRegexp = RegExp(r'([a-z])([A-Z])(?=([a-z]))');
    argName = argName.replaceAllMapped(camelCaseRegexp, (Match m) {
      var before = m.group(1);
      // Group 2 is not optional.
      var after = m.group(2)!.toLowerCase();
      return '$before-$after';
    });
    return argName;
  }

  /// If this argument is added to a larger tree of DartdocOptions, call
  /// [ArgParser.addFlag], [ArgParser.addOption], or [ArgParser.addMultiOption]
  /// as appropriate for [T].
  @override
  void _addToArgParser(ArgParser argParser) {
    if (_isBool) {
      argParser.addFlag(argName,
          abbr: abbr,
          defaultsTo: defaultsTo as bool?,
          help: help,
          hide: hide,
          negatable: negatable);
    } else if (_isInt || _isDouble || _isString) {
      argParser.addOption(argName,
          abbr: abbr,
          defaultsTo: defaultsTo?.toString(),
          help: help,
          hide: hide);
    } else if (_isListString || _isMapString) {
      if (defaultsTo == null) {
        argParser.addMultiOption(argName,
            abbr: abbr,
            defaultsTo: null,
            help: help,
            hide: hide,
            splitCommas: splitCommas);
      } else {
        List<String> defaultsToList;
        if (_isListString) {
          defaultsToList = defaultsTo as List<String>;
        } else {
          defaultsToList = (defaultsTo as Map<String, String>)
              .entries
              .map((m) => '${m.key}::${m.value}')
              .toList(growable: false);
        }
        argParser.addMultiOption(argName,
            abbr: abbr,
            defaultsTo: defaultsToList,
            help: help,
            hide: hide,
            splitCommas: splitCommas);
      }
    } else {
      throw UnsupportedError('Type $T is not supported');
    }
  }
}

/// All DartdocOptionContext mixins should implement this, as well as any other
/// DartdocOptionContext mixins they use for calculating synthetic options.
abstract class DartdocOptionContextBase {
  DartdocOptionSet get optionSet;

  Folder get context;
}

/// An [DartdocOptionSet] wrapped in nice accessors specific to Dartdoc, which
/// automatically passes in the right directory for a given context.
///
/// Usually, a single [ModelElement], [Package], [Category] and so forth has a
/// single context and so this can be made a member variable of those
/// structures.
class DartdocOptionContext extends DartdocOptionContextBase
    with
        DartdocExperimentOptionContext,
        PackageWarningOptionContext,
        SourceLinkerOptionContext {
  @override
  final DartdocOptionSet optionSet;
  @override
  final Folder context;

  // TODO(jcollins-g): Allow passing in structured data to initialize a
  // [DartdocOptionContext]'s arguments instead of having to parse strings
  // via optionSet.
  DartdocOptionContext(this.optionSet, Resource contextLocation,
      ResourceProvider resourceProvider)
      : context = resourceProvider.getFolder(resourceProvider.pathContext
            .canonicalize(contextLocation is File
                ? contextLocation.parent.path
                : contextLocation.path));

  /// Build a DartdocOptionContext via the 'inputDir' command line option.
  DartdocOptionContext.fromDefaultContextLocation(
      this.optionSet, ResourceProvider resourceProvider)
      : context = resourceProvider.getFolder(optionSet['inputDir'].valueAt(
                resourceProvider
                    .getFolder(resourceProvider.pathContext.current)) ??
            resourceProvider.pathContext.current);

  /// Build a DartdocOptionContext from an analyzer element (using its source
  /// location).
  factory DartdocOptionContext.fromElement(DartdocOptionSet optionSet,
      LibraryElement libraryElement, ResourceProvider resourceProvider) {
    return DartdocOptionContext(
        optionSet,
        resourceProvider.getFile(libraryElement.source.fullName),
        resourceProvider);
  }

  /// Build a DartdocOptionContext from an existing [DartdocOptionContext] and a
  /// new analyzer [Element].
  factory DartdocOptionContext.fromContextElement(
      DartdocOptionContext optionContext,
      LibraryElement libraryElement,
      ResourceProvider resourceProvider) {
    return DartdocOptionContext.fromElement(
        optionContext.optionSet, libraryElement, resourceProvider);
  }

  /// Build a DartdocOptionContext from an existing [DartdocOptionContext].
  factory DartdocOptionContext.fromContext(DartdocOptionContext optionContext,
      Resource resource, ResourceProvider resourceProvider) {
    return DartdocOptionContext(
        optionContext.optionSet, resource, resourceProvider);
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

  late final Set<String> dropTextFrom =
      Set.of(optionSet['dropTextFrom'].valueAt(context));

  String? get examplePathPrefix =>
      optionSet['examplePathPrefix'].valueAt(context);

  // TODO(srawlins): This memoization saved a lot of time in unit testing, but
  // is the first value in this class to be memoized. Memoize others?
  late final Set<String> exclude =
      Set.of(optionSet['exclude'].valueAt(context));

  Set<String> get _excludePackages =>
      {...optionSet['excludePackages'].valueAt(context)};

  String? get flutterRoot => optionSet['flutterRoot'].valueAt(context);

  bool get hideSdkText => optionSet['hideSdkText'].valueAt(context);

  late final Set<String> include =
      Set.of(optionSet['include'].valueAt(context));

  List<String> get includeExternal =>
      optionSet['includeExternal'].valueAt(context);

  bool get includeSource => optionSet['includeSource'].valueAt(context);

  bool get injectHtml => optionSet['injectHtml'].valueAt(context);

  bool get sanitizeHtml => optionSet['sanitizeHtml'].valueAt(context);

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

  List<String> get nodoc => optionSet['nodoc'].valueAt(context);

  String get output => optionSet['output'].valueAt(context);

  PackageMeta get packageMeta => optionSet['packageMeta'].valueAt(context);

  List<String> get packageOrder => optionSet['packageOrder'].valueAt(context);

  bool get sdkDocs => optionSet['sdkDocs'].valueAt(context);

  ResourceProvider get resourceProvider => optionSet.resourceProvider;

  String get sdkDir => optionSet['sdkDir'].valueAt(context);

  bool get showUndocumentedCategories =>
      optionSet['showUndocumentedCategories'].valueAt(context);

  PackageMeta get topLevelPackageMeta =>
      optionSet['topLevelPackageMeta'].valueAt(context);

  bool get useCategories => optionSet['useCategories'].valueAt(context);

  bool get validateLinks => optionSet['validateLinks'].valueAt(context);

  bool isLibraryExcluded(String name) =>
      exclude.any((pattern) => name == pattern);

  bool isPackageExcluded(String name) => _excludePackages.contains(name);

  bool get showStats => optionSet['showStats'].valueAt(context);

  /// Output format, e.g. 'html', 'md'
  String get format => optionSet['format'].valueAt(context);

  // TODO(jdkoren): temporary while we confirm href base behavior doesn't break
  // important clients
  bool get useBaseHref => optionSet['useBaseHref'].valueAt(context);

  int get maxFileCount =>
      int.parse(optionSet['maxFileCount'].valueAt(context) ?? '0');
  int get maxTotalSize =>
      int.parse(optionSet['maxTotalSize'].valueAt(context) ?? '0');
}

/// Instantiate dartdoc's configuration file and options parser with the
/// given command line arguments.
List<DartdocOption> createDartdocOptions(
  PackageMetaProvider packageMetaProvider,
) {
  var resourceProvider = packageMetaProvider.resourceProvider;
  return [
    DartdocOptionArgOnly<bool>('allowTools', false, resourceProvider,
        help: 'Execute user-defined tools to fill in @tool directives.',
        negatable: true),
    DartdocOptionArgFile<double>(
        'ambiguousReexportScorerMinConfidence', 0.1, resourceProvider,
        help: 'Minimum scorer confidence to suppress warning on ambiguous '
            'reexport.'),
    DartdocOptionArgOnly<bool>(
        'autoIncludeDependencies', false, resourceProvider,
        help: 'Include all the used libraries into the docs, even the ones not '
            'in the current package or "include-external"',
        negatable: true),
    DartdocOptionArgFile<List<String>>(
        'categoryOrder', const [], resourceProvider,
        splitCommas: true,
        help: 'A list of categories (not package names) to place first when '
            "grouping symbols on dartdoc's sidebar. Unmentioned categories are "
            'sorted after these.'),
    DartdocOptionFileOnly<CategoryConfiguration>(
        'categories', CategoryConfiguration.empty, resourceProvider,
        convertYamlToType: CategoryConfiguration.fromYamlMap,
        help: 'A list of all categories, their display names, and markdown '
            'documentation in the order they are to be displayed.'),
    DartdocOptionSyntheticOnly<List<String>>('dropTextFrom',
        (DartdocSyntheticOption<List<String>> option, Folder dir) {
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
          'dart.isolate',
          'dart.js',
          'dart.js_util',
          'dart.math',
          'dart.mirrors',
          'dart.svg',
          'dart.typed_data',
          'dart.web_audio'
        ];
      }
      return const [];
    }, resourceProvider,
        help: 'Remove text from libraries with the following names.'),
    DartdocOptionArgFile<String?>('examplePathPrefix', null, resourceProvider,
        optionIs: OptionKind.dir,
        help: 'Prefix for @example paths.\n(defaults to the project root)',
        mustExist: true),
    DartdocOptionArgFile<List<String>>('exclude', [], resourceProvider,
        help: 'Library names to ignore.', splitCommas: true),
    DartdocOptionArgOnly<List<String>>('excludePackages', [], resourceProvider,
        help: 'Package names to ignore.', splitCommas: true),
    DartdocOptionSyntheticOnly<String?>('flutterRoot',
        (DartdocSyntheticOption<String?> option, Folder dir) {
      var flutterRootEnv =
          packageMetaProvider.environmentProvider['FLUTTER_ROOT'];
      if (flutterRootEnv == null) return null;
      return resourceProvider.pathContext.resolveTildePath(flutterRootEnv);
    }, resourceProvider,
        optionIs: OptionKind.dir,
        help: 'Root of the Flutter SDK, specified from environment.',
        mustExist: true),
    DartdocOptionArgOnly<bool>('hideSdkText', false, resourceProvider,
        hide: true,
        help: 'Drop all text for SDK components.  Helpful for integration '
            'tests for dartdoc, probably not useful for anything else.',
        negatable: true),
    DartdocOptionArgFile<List<String>>('include', [], resourceProvider,
        help: 'Library names to generate docs for.', splitCommas: true),
    DartdocOptionArgFile<List<String>>('includeExternal', [], resourceProvider,
        optionIs: OptionKind.file,
        help:
            'Additional (external) dart files to include; use "dir/fileName", '
            'as in lib/material.dart.',
        mustExist: true,
        splitCommas: true),
    DartdocOptionArgOnly<bool>('includeSource', true, resourceProvider,
        help: 'Show source code blocks.', negatable: true),
    DartdocOptionArgOnly<bool>('injectHtml', false, resourceProvider,
        help: 'Allow the use of the {@inject-html} directive to inject raw '
            'HTML into dartdoc output.'),
    DartdocOptionArgOnly<bool>('sanitizeHtml', false, resourceProvider,
        hide: true,
        help: 'Sanitize HTML generated from markdown, {@tool} and '
            '{@inject-html} directives.'),
    DartdocOptionArgOnly<String>(
        'input', resourceProvider.pathContext.current, resourceProvider,
        optionIs: OptionKind.dir,
        help: 'Path to source directory',
        mustExist: true),
    DartdocOptionSyntheticOnly<String>('inputDir',
        (DartdocSyntheticOption<String> option, Folder dir) {
      if (option.parent['sdkDocs'].valueAt(dir)) {
        return option.parent['sdkDir'].valueAt(dir);
      }
      return option.parent['input'].valueAt(dir);
    }, resourceProvider,
        help: 'Path to source directory (with override if --sdk-docs)',
        optionIs: OptionKind.dir,
        mustExist: true),
    DartdocOptionSet('linkTo', resourceProvider)
      ..addAll([
        DartdocOptionArgOnly<Map<String, String>>(
            'hosted',
            {
              'pub.dartlang.org': 'https://pub.dev/documentation/%n%/%v%',
              'pub.dev': 'https://pub.dev/documentation/%n%/%v%',
            },
            resourceProvider,
            help: 'Specify URLs for hosted pub packages'),
        DartdocOptionArgOnly<Map<String, String>>(
          'sdks',
          {
            'Dart': 'https://api.dart.dev/%b%/%v%',
            'Flutter': 'https://api.flutter.dev/flutter',
          },
          resourceProvider,
          help: 'Specify URLs for SDKs.',
        ),
        DartdocOptionFileSynth<String>('url',
            (DartdocSyntheticOption<String> option, Folder dir) {
          PackageMeta packageMeta =
              option.parent.parent['packageMeta'].valueAt(dir);
          // Prefer SDK check first, then pub cache check.
          var inSdk = packageMeta
              .sdkType(option.parent.parent['flutterRoot'].valueAt(dir));
          // Analyzer may be confused because package_meta still needs
          // migrating.  It can definitely return null.
          if (inSdk != null) {
            Map<String, String> sdks = option.parent['sdks'].valueAt(dir);
            var inSdkVal = sdks[inSdk];
            if (inSdkVal != null) return inSdkVal;
          }
          var hostedAt = packageMeta.hostedAt;
          if (hostedAt != null) {
            Map<String, String> hostMap = option.parent['hosted'].valueAt(dir);
            var hostedAtVal = hostMap[hostedAt];
            if (hostedAtVal != null) return hostedAtVal;
          }
          return '';
        }, resourceProvider, help: 'Url to use for this particular package.'),
        DartdocOptionArgOnly<bool>('remote', true, resourceProvider,
            help: 'Allow links to be generated for packages outside this one.',
            negatable: true),
      ]),
    DartdocOptionFileOnly<List<String>>('nodoc', [], resourceProvider,
        optionIs: OptionKind.glob,
        help: 'Dart symbols declared in these '
            'files will be treated as though they have the @nodoc flag added to '
            'their documentation comment.'),
    DartdocOptionArgOnly<String>('output',
        resourceProvider.pathContext.join('doc', 'api'), resourceProvider,
        optionIs: OptionKind.dir, help: 'Path to output directory.'),
    DartdocOptionSyntheticOnly<PackageMeta>(
      'packageMeta',
      (DartdocSyntheticOption<PackageMeta> option, Folder dir) {
        var packageMeta = packageMetaProvider.fromDir(dir);
        if (packageMeta == null) {
          throw DartdocOptionError(
              'Unable to determine package for directory: ${dir.path}');
        }
        return packageMeta;
      },
      resourceProvider,
    ),
    DartdocOptionArgOnly<List<String>>('packageOrder', [], resourceProvider,
        splitCommas: true,
        help:
            'A list of package names to place first when grouping libraries in '
            'packages. Unmentioned packages are sorted after these.'),
    DartdocOptionArgOnly<String?>('resourcesDir', null, resourceProvider,
        help: "An absolute path to dartdoc's resources directory.", hide: true),
    DartdocOptionArgOnly<bool>('sdkDocs', false, resourceProvider,
        help: 'Generate ONLY the docs for the Dart SDK.'),
    DartdocOptionArgSynth<String?>('sdkDir',
        (DartdocSyntheticOption<String?> option, Folder dir) {
      if (!(option.parent['sdkDocs'].valueAt(dir) as bool) &&
          (option.root['topLevelPackageMeta'].valueAt(dir) as PackageMeta)
              .requiresFlutter) {
        String? flutterRoot = option.root['flutterRoot'].valueAt(dir);
        if (flutterRoot == null) {
          // For now, return null. An error is reported in
          // [PackageBuilder.buildPackageGraph].
          return null;
        }
        return resourceProvider.pathContext
            .join(flutterRoot, 'bin', 'cache', 'dart-sdk');
      }
      return packageMetaProvider.defaultSdkDir.path;
    }, packageMetaProvider.resourceProvider,
        help: 'Path to the SDK directory.',
        optionIs: OptionKind.dir,
        mustExist: true),
    DartdocOptionArgFile<bool>(
        'showUndocumentedCategories', false, resourceProvider,
        help: "Label categories that aren't documented", negatable: true),
    DartdocOptionSyntheticOnly<PackageMeta>('topLevelPackageMeta',
        (DartdocSyntheticOption<PackageMeta> option, Folder dir) {
      var packageMeta = packageMetaProvider.fromDir(
          resourceProvider.getFolder(option.parent['inputDir'].valueAt(dir)));
      if (packageMeta == null) {
        throw DartdocOptionError(
            'Unable to generate documentation: no package found');
      }
      if (!packageMeta.isValid) {
        final firstError = packageMeta.getInvalidReasons().first;
        throw DartdocOptionError('Package is invalid: $firstError');
      }
      return packageMeta;
    }, resourceProvider, help: 'PackageMeta object for the default package.'),
    DartdocOptionArgOnly<bool>('useCategories', true, resourceProvider,
        help: 'Display categories in the sidebar of packages'),
    DartdocOptionArgOnly<bool>('validateLinks', true, resourceProvider,
        help: 'Runs the built-in link checker to display Dart context aware '
            'warnings for broken links (slow)',
        negatable: true),
    DartdocOptionArgOnly<bool>('verboseWarnings', true, resourceProvider,
        help: 'Display extra debugging information and help with warnings.',
        negatable: true),
    DartdocOptionFileOnly<bool>('excludeFooterVersion', false, resourceProvider,
        help: 'Excludes the package version number in the footer text'),
    DartdocOptionFileOnly<ToolConfiguration>(
        'tools', ToolConfiguration.empty(resourceProvider), resourceProvider,
        convertYamlToType: ToolConfiguration.fromYamlMap,
        help: 'A map of tool names to executable paths. Each executable must '
            'exist. Executables for different platforms are specified by '
            'giving the platform name as a key, and a list of strings as the '
            'command.'),
    DartdocOptionArgOnly<bool>('useBaseHref', false, resourceProvider,
        help:
            'Use <base href> in generated files (legacy behavior). This option '
            'is temporary and support will be removed in the future. Use only '
            'if the default behavior breaks links between your documentation '
            'pages, and please file an issue on GitHub.',
        negatable: false,
        hide: true),
    DartdocOptionArgOnly<bool>('showStats', false, resourceProvider,
        help: 'Show statistics useful for debugging.', hide: true),
    DartdocOptionArgOnly<String>('format', 'html', resourceProvider,
        help: 'The format of documentation to generate: `md` for markdown, '
            '`html` for html.',
        hide: false),
    DartdocOptionArgOnly<String>('maxFileCount', '0', resourceProvider,
        help:
            'The maximum number of files dartdoc is allowed to create (0 for no limit).',
        hide: true),
    DartdocOptionArgOnly<String>('maxTotalSize', '0', resourceProvider,
        help:
            'The maximum total size (in bytes) dartdoc is allowed to write (0 for no limit).',
        hide: true),
    // TODO(jcollins-g): refactor so there is a single static "create" for
    // each DartdocOptionContext that traverses the inheritance tree itself.
    ...createExperimentOptions(resourceProvider),
    ...createPackageWarningOptions(packageMetaProvider),
    ...createSourceLinkerOptions(resourceProvider),
  ];
}
