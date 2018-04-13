// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

///
/// dartdoc's dartdoc_options.yaml configuration file follows similar loading
/// semantics to that of analysis_options.yaml,
/// [documented here](https://www.dartlang.org/guides/language/analysis-options).
/// It searches parent directories until it finds an analysis_options.yaml file,
/// and uses built-in defaults if one is not found.
///
/// The classes here manage both the dartdoc_options.yaml loading and command
/// line arguments.
///
library dartdoc.dartdoc_options;

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as pathLib;
import 'package:yaml/yaml.dart';

import 'logging.dart';

/// Constants to help with type checking, because T is int and so forth
/// don't work in Dart.
const String _kStringVal = '';
const List<String> _kListStringVal = const <String>[];
const Map<String, String> _kMapStringVal = const <String, String>{};
const int _kIntVal = 0;
const double _kDoubleVal = 0.0;
const bool _kBoolVal = true;

class DartdocOptionError extends DartDocFailure {
  DartdocOptionError(String details) : super(details);
}

class DartdocFileMissing extends DartdocOptionError {
  DartdocFileMissing(String details) : super(details);
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
  pathLib.Context pathContext;

  /// Build a _OptionValueWithContext.
  /// [path] is the path where this value came from (not required to be canonical)
  _OptionValueWithContext(this.value, String path, {String definingFile}) {
    this.definingFile = definingFile;
    canonicalDirectoryPath = pathLib.canonicalize(path);
    pathContext = new pathLib.Context(current: canonicalDirectoryPath);
  }

  /// Assume value is a path, and attempt to resolve it.  Throws [UnsupportedError]
  /// if [T] isn't a [String] or [List<String>].
  T get resolvedValue {
    if (value is List<String>) {
      return (value as List<String>).map((v) => pathContext.canonicalize(v))
          as T;
    } else if (value is String) {
      return pathContext.canonicalize(value as String) as T;
    } else {
      throw new UnsupportedError("Type $T is not supported for resolvedValue");
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
/// Use via implementations [DartdocOptionSet], [DartdocOptionBoth],
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

  DartdocOption._(this.name, this.defaultsTo, this.help, this.isDir,
      this.isFile, this.mustExist) {
    assert(!(isDir && isFile));
    if (isDir || isFile) assert(_isString || _isListString);
    if (mustExist) {
      assert(isDir || isFile);
    }
  }

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

  final ArgParser __argParser = new ArgParser();
  ArgParser get argParser => root.__argParser;

  ArgResults __argResults;

  /// Parse these as string arguments (from argv) with the argument parser.
  /// Call before calling [valueAt] for any [DartdocOptionArgOnly] or
  /// [DartdocOptionBoth] in this tree.
  void _parseArguments(List<String> arguments) {
    __argResults = argParser.parse(arguments);
  }

  /// Throw [DartdocFileMissing] with a detailed error message indicating where
  /// the error came from when a file or directory option is missing.
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingFilename);

  /// Call [_onMissing] for every path that does not exist.  Returns true if
  /// all paths exist or [mustExist] == false.
  void _validatePaths(_OptionValueWithContext valueWithContext) {
    if (!mustExist) return;
    assert(isDir || isFile);
    List<String> resolvedPaths;
    if (valueWithContext.value is String) {
      resolvedPaths = [valueWithContext.resolvedValue];
    } else {
      resolvedPaths = valueWithContext.resolvedValue.toList();
    }
    for (String path in resolvedPaths) {
      FileSystemEntity f = isDir ? new Directory(path) : new File(path);
      if (!f.existsSync()) {
        _onMissing(valueWithContext, path);
      }
    }
  }

  /// For a [List<String>] or [String] value, if [isDir] or [isFile] is set,
  /// resolve paths in value relative to canonicalPath.
  T _handlePathsInContext(_OptionValueWithContext valueWithContext) {
    if (valueWithContext?.value == null || !(isDir || isFile))
      return valueWithContext?.value;
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
    List<String> keyList = [];
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

  /// Calls [valueAt] with the current working directory.
  T valueAtCurrent() => valueAt(Directory.current);

  /// Calls [valueAt] on the directory this element is defined in.
  T valueAtElement(Element element) => valueAt(new Directory(pathLib.canonicalize(pathLib.basename(element.source.fullName))));

  /// Adds a DartdocOption to the children of this DartdocOption.
  void add(DartdocOption option) {
    if (_children.containsKey(option.name))
      throw new DartdocOptionError(
          'Tried to add two children with the same name: ${option.name}');
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
  void traverse(void visit(DartdocOption)) {
    visit(this);
    _children.values.forEach((d) => d.traverse(visit));
  }
}

/// A [DartdocOption] that only contains other [DartdocOption]s and is not an option itself.
class DartdocOptionSet extends DartdocOption<Null> {
  DartdocOptionSet(String name)
      : super._(name, null, null, false, false, false);

  /// [DartdocOptionSet] always has the null value.
  @override
  Null valueAt(Directory dir) => null;

  /// Since we have no value, [_onMissing] does nothing.
  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingFilename) {}

  @override

  /// Traverse skips this node, because it doesn't represent a real configuration object.
  void traverse(void visitor(DartdocOption)) {
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
      help: '',
      bool hide,
      bool isDir = false,
      bool isFile = false,
      bool negatable,
      bool splitCommas})
      : super._(name, defaultsTo, help, isDir, isFile, mustExist) {
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
class DartdocOptionBoth<T> extends DartdocOption<T>
    with _DartdocArgOption<T>, _DartdocFileOption<T> {
  String _abbr;
  bool _hide;
  bool _negatable;
  bool _parentDirOverridesChild;
  bool _splitCommas;

  DartdocOptionBoth(String name, T defaultsTo,
      {String abbr,
      bool mustExist = false,
      String help: '',
      bool hide,
      bool isDir = false,
      bool isFile = false,
      bool negatable,
      bool parentDirOverridesChild: false,
      bool splitCommas})
      : super._(name, defaultsTo, help, isDir, isFile, mustExist) {
    _abbr = abbr;
    _hide = hide;
    _negatable = negatable;
    _parentDirOverridesChild = parentDirOverridesChild;
    _splitCommas = splitCommas;
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    String dartdocYaml;
    String description;
    if (valueWithContext.definingFile != null) {
      dartdocYaml = pathLib.canonicalize(pathLib.join(
          valueWithContext.canonicalDirectoryPath,
          valueWithContext.definingFile));
      description = "Field ${fieldName} from ${dartdocYaml}";
    } else {
      description = "Argument --${argName}";
    }
    throw new DartdocFileMissing(
        '$description, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  @override

  /// Try to find an explicit argument setting this value, but if not, fall back to files
  /// finally, the default.
  T valueAt(Directory dir) {
    T value = _valueAtFromArgs();
    if (value == null) value = _valueAtFromFiles(dir);
    if (value == null) value = defaultsTo;
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
      String help: '',
      bool isDir = false,
      bool isFile = false,
      bool parentDirOverridesChild: false})
      : super._(name, defaultsTo, help, isDir, isFile, mustExist) {
    _parentDirOverridesChild = parentDirOverridesChild;
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    String dartdocYaml = pathLib.canonicalize(pathLib.join(
        valueWithContext.canonicalDirectoryPath,
        valueWithContext.definingFile));
    throw new DartdocFileMissing(
        'Field ${fieldName} from ${dartdocYaml}, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  @override
  bool get parentDirOverridesChild => _parentDirOverridesChild;
}

/// Implements checking for options
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
      _OptionValueWithContext valueWithContext, String missingPath) {
    String dartdocYaml = pathLib.join(
        valueWithContext.canonicalDirectoryPath, valueWithContext.definingFile);
    throw new DartdocFileMissing(
        'Field ${fieldName} from ${dartdocYaml}, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  @override

  /// Searches for a value in configuration files relative to [dir], and if not
  /// found, returns [defaultsTo].
  T valueAt(Directory dir) {
    return _valueAtFromFiles(dir) ?? defaultsTo;
  }

  T _valueAtFromFiles(Directory dir) {
    _OptionValueWithContext valueWithContext;
    if (parentDirOverridesChild) {
      valueWithContext = _valueAtFromFilesLastFound(dir);
    } else {
      valueWithContext = _valueAtFromFilesFirstFound(dir);
    }
    return _handlePathsInContext(valueWithContext);
  }

  /// Searches all dartdoc_options files through parent directories,
  /// starting at [dir], for the option and returns one once
  /// found.
  _OptionValueWithContext _valueAtFromFilesFirstFound(Directory dir) {
    _OptionValueWithContext value;
    while (true) {
      value = _valueAtFromFile(dir);
      if (value != null || pathLib.equals(dir.parent.path, dir.path)) break;
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
      _OptionValueWithContext tmpValue = _valueAtFromFile(dir);
      if (tmpValue != null) value = tmpValue;
      if (pathLib.equals(dir.parent.path, dir.path)) break;
      dir = dir.parent;
    }
    return value;
  }

  /// Returns null if not set in the yaml file in this directory (or its
  /// parents).
  _OptionValueWithContext _valueAtFromFile(Directory dir) {
    _YamlFileData yamlFileData = _yamlAtDirectory(dir);
    String contextPath = yamlFileData.canonicalDirectoryPath;
    var yamlData = yamlFileData.data;
    for (String key in keys) {
      if (!yamlData.containsKey(key)) return null;
      yamlData = yamlData[key];
    }

    var returnData;
    if (_isListString) {
      if (yamlData is YamlList) {
        returnData = <String>[];
        for (var item in yamlData as YamlList) {
          returnData.add(item.toString());
        }
      }
    } else if (_isMapString) {
      if (yamlData is YamlMap) {
        returnData = <String, String>{};
        for (MapEntry entry in yamlData.entries) {
          returnData[entry.key.toString()] = entry.value.toString();
        }
      }
    } else if (_isDouble) {
      if (yamlData is num) {
        returnData = (yamlData as num).toDouble();
      }
    } else if (_isInt || _isString || _isBool) {
      if (yamlData is T) {
        returnData = yamlData;
      }
    } else {
      throw new UnsupportedError("Type ${T} is not supported");
    }
    return new _OptionValueWithContext(returnData as T, contextPath,
        definingFile: 'dartdoc_options.yaml');
  }

  _YamlFileData _yamlAtDirectory(Directory dir) {
    List<String> canonicalPaths = [pathLib.canonicalize(dir.path)];
    if (!_yamlAtCanonicalPathCache.containsKey(canonicalPaths.first)) {
      _YamlFileData yamlData = new _YamlFileData(
          new Map(), pathLib.canonicalize(Directory.current.path));
      if (dir.existsSync()) {
        File dartdocOptionsFile;

        while (true) {
          dartdocOptionsFile =
              new File(pathLib.join(dir.path, 'dartdoc_options.yaml'));
          if (dartdocOptionsFile.existsSync() ||
              pathLib.equals(dir.parent.path, dir.path)) break;
          dir = dir.parent;
          canonicalPaths.add(pathLib.canonicalize(dir.path));
        }
        if (dartdocOptionsFile.existsSync()) {
          yamlData = new _YamlFileData(
              loadYaml(dartdocOptionsFile.readAsStringSync()),
              pathLib.canonicalize(dir.path));
        }
      }
      canonicalPaths.forEach((p) => _yamlAtCanonicalPathCache[p] = yamlData);
    }
    return _yamlAtCanonicalPathCache[canonicalPaths.first];
  }
}

/// Mixin class implementing command-line arguments for [DartdocOption].
abstract class _DartdocArgOption<T> implements DartdocOption<T> {
  /// For [ArgsParser], set to true if the argument can be negated with --no on the command line.
  bool get negatable;

  /// For [ArgsParser], set to true if a single string argument will be broken into a list on commas.
  bool get splitCommas;

  /// For [ArgsParser], set to true to hide this from the help menu.
  bool get hide;

  /// For [ArgsParser], set to a single character to have a short version of the command line argument.
  String get abbr;

  /// valueAt for arguments ignores the [dir] parameter and only uses command
  /// line arguments and the current working directory to resolve the result.
  @override
  T valueAt(Directory dir) => _valueAtFromArgs() ?? defaultsTo;

  /// For passing in to [int.parse] and [double.parse] `onError'.
  _throwErrorForTypes(String value) {
    String example;
    if (defaultsTo is Map) {
      example = "key::value";
    } else if (_isInt) {
      example = "32";
    } else if (_isDouble) {
      example = "0.76";
    }
    throw new DartdocOptionError(
        'Invalid argument value: --${argName}, set to "${value}", must be a ${T}.  Example:  --${argName} ${example}');
  }

  /// Returns null if no argument was given on the command line.
  T _valueAtFromArgs() {
    _OptionValueWithContext valueWithContext = _valueAtFromArgsWithContext();
    return _handlePathsInContext(valueWithContext);
  }

  @override
  void _onMissing(
      _OptionValueWithContext valueWithContext, String missingPath) {
    throw new DartdocFileMissing(
        'Argument --${argName}, set to ${valueWithContext.value}, resolves to missing path: "${missingPath}"');
  }

  /// Generates an _OptionValueWithContext using the value of the argument from
  /// the [argParser] and the working directory from [Directory.current].
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
      retval =
          int.parse(_argResults[argName], onError: _throwErrorForTypes) as T;
    } else if (_isDouble) {
      retval = double.parse(_argResults[argName], _throwErrorForTypes) as T;
    } else if (_isMapString) {
      retval = {} as T;
      for (String pair in _argResults[argName]) {
        List<String> pairList = pair.split('::');
        if (pairList.length != 2) {
          _throwErrorForTypes(pair);
        }
        assert(pairList.length == 2);
        (retval as Map<String, String>)[pairList.first] = pairList.last;
      }
    } else {
      throw UnsupportedError('Type ${T} is not supported');
    }
    return new _OptionValueWithContext(retval, Directory.current.path);
  }

  /// The name of this option as a command line argument.
  String get argName => _keysToArgName(keys);

  /// Turns ['foo', 'somethingBar', 'over_the_hill'] into
  /// 'something-bar-over-the-hill' (with default skip).
  /// This allows argument names to reflect nested structure.
  static String _keysToArgName(Iterable<String> keys, [int skip = 1]) {
    String argName = "${keys.skip(skip).join('-')}";
    argName = argName.replaceAll('_', '-');
    // Do not consume the lowercase character after the uppercase one, to handle
    // two character words.
    final camelCaseRegexp = new RegExp(r'([a-z])([A-Z])(?=([a-z]))');
    argName = argName.replaceAllMapped(camelCaseRegexp, (Match m) {
      String before = m.group(1);
      String after = m.group(2).toLowerCase();
      return "${before}-${after}";
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
          negatable: negatable);
    } else if (_isInt || _isDouble || _isString) {
      argParser.addOption(argName,
          abbr: abbr,
          defaultsTo: defaultsTo.toString(),
          help: help,
          hide: hide);
    } else if (_isListString || _isMapString) {
      List<String> defaultsToList = [];
      if (_isListString) {
        defaultsToList = defaultsTo as List<String>;
      } else {
        defaultsToList.addAll((defaultsTo as Map<String, String>)
            .entries
            .map((m) => "${m.key}::${m.value}"));
      }
      argParser.addMultiOption(argName,
          abbr: abbr,
          defaultsTo: defaultsToList,
          help: help,
          hide: hide,
          splitCommas: splitCommas);
    } else {
      throw new UnsupportedError('Type ${T} is not supported');
    }
  }
}

final Map<String, DartdocOptions> _dartdocOptionsCache = {};

/// Legacy dartdoc options class.  TODO(jcollins-g): merge with [DartdocOption].
abstract class DartdocOptions {
  DartdocOptions();

  /// Path to the dartdoc options file, or '<default>' if this object is the
  /// default setting. Intended for printing only.
  String get _path;

  /// A list indicating the preferred subcategory sorting order.
  List<String> get categoryOrder;

  factory DartdocOptions.fromDir(Directory dir) {
    if (!_dartdocOptionsCache.containsKey(dir.absolute.path)) {
      _dartdocOptionsCache[dir.absolute.path] =
          new DartdocOptions._fromDir(dir);
    }
    return _dartdocOptionsCache[dir.absolute.path];
  }

  /// Search for a dartdoc_options file in this and parent directories.
  factory DartdocOptions._fromDir(Directory dir) {
    if (!dir.existsSync()) return new _DefaultDartdocOptions();

    File f;
    dir = dir.absolute;

    while (true) {
      f = new File(pathLib.join(dir.path, 'dartdoc_options.yaml'));
      if (f.existsSync() || dir.parent.path == dir.path) break;
      dir = dir.parent.absolute;
    }

    DartdocOptions parent;
    if (dir.parent.path != dir.path) {
      parent = new DartdocOptions.fromDir(dir.parent);
    } else {
      parent = new _DefaultDartdocOptions();
    }
    if (f.existsSync()) {
      return new _FileDartdocOptions(f);
    }
    return parent;
  }
}

class _DefaultDartdocOptions extends DartdocOptions {
  _DefaultDartdocOptions() : super();

  @override
  String get _path => '<default>';

  @override
  List<String> get categoryOrder => new List.unmodifiable([]);
}

class _FileDartdocOptions extends DartdocOptions {
  File dartdocOptionsFile;
  Map _dartdocOptions;
  _FileDartdocOptions(this.dartdocOptionsFile) : super() {
    Map allDartdocOptions = loadYaml(dartdocOptionsFile.readAsStringSync());
    if (allDartdocOptions.containsKey('dartdoc')) {
      _dartdocOptions = allDartdocOptions['dartdoc'];
    } else {
      _dartdocOptions = {};
      logWarning("${_path}: must contain 'dartdoc' section");
    }
  }

  @override
  String get _path => dartdocOptionsFile.path;

  List<String> _categoryOrder;
  @override
  List<String> get categoryOrder {
    if (_categoryOrder == null) {
      _categoryOrder = [];
      if (_dartdocOptions.containsKey('categoryOrder')) {
        if (_dartdocOptions['categoryOrder'] is YamlList) {
          _categoryOrder.addAll(_dartdocOptions['categoryOrder']);
        } else {
          logWarning("${_path}: categoryOrder must be a list (ignoring)");
        }
      }
      _categoryOrder = new List.unmodifiable(_categoryOrder);
    }
    return _categoryOrder;
  }
}
