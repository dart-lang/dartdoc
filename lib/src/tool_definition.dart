// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:path/path.dart' as p show extension;

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
      List<String> command,
      List<String> setupCommand,
      String description,
      ResourceProvider resourceProvider,
      {List<String> compileArgs}) {
    assert(command != null);
    assert(command.isNotEmpty);
    assert(description != null);
    if (isDartExecutable(command[0])) {
      return DartToolDefinition(
          command, setupCommand, description, resourceProvider,
          compileArgs: compileArgs ?? const []);
    } else {
      if (compileArgs != null && compileArgs.isNotEmpty) {
        throw DartdocOptionError(
            'Compile arguments may only be specified for Dart tools, but '
            '$compileArgsTagName of $compileArgs were specified for '
            '$command.');
      }
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

  Future<ToolStateForArgs> toolStateForArgs(List<String> args) async {
    var commandPath = args.removeAt(0);
    return ToolStateForArgs(commandPath, args, null);
  }
}

/// A special kind of tool definition for Dart commands.
class DartToolDefinition extends ToolDefinition {
  final ResourceProvider _resourceProvider;

  /// A list of arguments to add to the snapshot compilation arguments.
  final List<String> compileArgs;

  /// Takes a list of args to modify, and returns the name of the executable
  /// to run.
  ///
  /// If no snapshot file existed, then creates one and modify the args
  /// so that if they are executed with dart, will result in the snapshot being
  /// built.
  @override
  Future<ToolStateForArgs> toolStateForArgs(List<String> args) async {
    assert(args[0] == command.first);
    // Set up flags to create a new snapshot, if needed, and use the first run
    // as the training run.
    SnapshotCache.createInstance(_resourceProvider);
    var snapshot = SnapshotCache.instance.getSnapshot(command.first);
    var snapshotPath =
        _resourceProvider.pathContext.absolute(snapshot._snapshotFile.path);
    var needsSnapshot = snapshot.needsSnapshot;
    if (needsSnapshot) {
      return ToolStateForArgs(
          _resourceProvider.resolvedExecutable,
          [
            // TODO(jcollins-g): remove ignore and verbosity resets once
            // https://dart-review.googlesource.com/c/sdk/+/181421 is safely
            // in the rearview mirror in dev/Flutter.
            '--ignore-unrecognized-flags',
            '--verbosity=error',
            '--snapshot=$snapshotPath',
            '--snapshot_kind=app-jit',
            ...compileArgs,
            ...args,
          ],
          snapshot._snapshotCompleted);
    } else {
      await snapshot._snapshotValid();
      // replace the first argument with the path to the snapshot.
      args[0] = snapshotPath;
      return ToolStateForArgs(_resourceProvider.resolvedExecutable, args, null);
    }
  }

  DartToolDefinition(List<String> command, List<String> setupCommand,
      String description, this._resourceProvider,
      {this.compileArgs = const []})
      : assert(compileArgs != null),
        super(command, setupCommand, description);
}

/// Manages the creation of a single snapshot file in a context where multiple
/// async functions could be trying to use and/or create it.
///
/// To use:
///
/// ```dart
/// var s = new Snapshot(...);
///
/// if (s.needsSnapshot) {
///   // create s.snapshotFile, then call:
///   s.snapshotCompleted();
/// } else {
///   await snapshotValid();
///   // use existing s.snapshotFile;
/// }
/// ```
///
class _Snapshot {
  final File _snapshotFile;

  final Completer<void> _snapshotCompleter = Completer();

  factory _Snapshot(Folder snapshotCache, String toolPath, int serial,
      ResourceProvider resourceProvider) {
    if (toolPath.endsWith('.snapshot')) {
      return _Snapshot.existing(toolPath, resourceProvider);
    } else {
      return _Snapshot.create(resourceProvider.getFile(
          resourceProvider.pathContext.join(
              resourceProvider.pathContext.absolute(snapshotCache.path),
              'snapshot_$serial')));
    }
  }

  _Snapshot.existing(String toolPath, ResourceProvider resourceProvider)
      : _needsSnapshot = false,
        _snapshotFile = resourceProvider.getFile(toolPath) {
    _snapshotCompleted();
  }

  _Snapshot.create(this._snapshotFile);

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

  Future<void> _snapshotValid() => _snapshotCompleter.future;

  void _snapshotCompleted() => _snapshotCompleter.complete();
}

/// A singleton that keeps track of cached snapshot files. The [dispose]
/// function must be called before process exit to clean up snapshots in the
/// cache.
class SnapshotCache {
  static SnapshotCache _instance;

  final Folder snapshotCache;
  final ResourceProvider _resourceProvider;
  final Map<String, _Snapshot> snapshots = {};
  int _serial = 0;

  SnapshotCache._(this._resourceProvider)
      : snapshotCache =
            _resourceProvider.createSystemTemp('dartdoc_snapshot_cache_');

  static SnapshotCache get instance => _instance;

  static SnapshotCache createInstance(ResourceProvider resourceProvider) =>
      _instance ??= SnapshotCache._(resourceProvider);

  _Snapshot getSnapshot(String toolPath) {
    if (snapshots.containsKey(toolPath)) {
      return snapshots[toolPath];
    }
    snapshots[toolPath] =
        _Snapshot(snapshotCache, toolPath, _serial, _resourceProvider);
    _serial++;
    return snapshots[toolPath];
  }

  void dispose() {
    _instance = null;
    if (snapshotCache != null && snapshotCache.exists) {
      return snapshotCache.delete();
    }
    return null;
  }
}

class ToolStateForArgs {
  final String commandPath;
  final List<String> args;
  final void Function() onProcessComplete;

  ToolStateForArgs(this.commandPath, this.args, this.onProcessComplete);
}
