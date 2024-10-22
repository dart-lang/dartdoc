// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' show Platform;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/tool_definition.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:yaml/yaml.dart';

/// A configuration class that can interpret [ToolDefinition]s from a YAML map.
class ToolConfiguration {
  final Map<String, ToolDefinition> tools;

  final ResourceProvider resourceProvider;

  late final ToolRunner runner = ToolRunner(this);

  ToolConfiguration._(this.tools, this.resourceProvider);

  static ToolConfiguration empty(ResourceProvider resourceProvider) {
    return ToolConfiguration._(const {}, resourceProvider);
  }

  // TODO(jcollins-g): consider caching these.
  static ToolConfiguration fromYamlMap(YamlMap yamlMap,
      String canonicalYamlPath, ResourceProvider resourceProvider) {
    var newToolDefinitions = <String, ToolDefinition>{};
    var pathContext = resourceProvider.pathContext;
    for (var MapEntry(:key, value: toolMap) in yamlMap.entries) {
      var name = key.toString();
      if (toolMap is! Map) {
        throw DartdocOptionError(
            'Tools must be defined as a map of tool names to definitions. Tool '
            '$name is not a map.');
      }

      var description = toolMap['description'].toString();

      List<String>? findCommand([String prefix = '']) {
        // If the command key is given, then it applies to all platforms.
        var commandFromKey = toolMap.containsKey('${prefix}command')
            ? '${prefix}command'
            : '$prefix${Platform.operatingSystem}';
        if (!toolMap.containsKey(commandFromKey)) {
          return null;
        }
        var commandFrom = toolMap[commandFromKey] as YamlNode;
        List<String> command;
        if (commandFrom.value is String) {
          command = [commandFrom.toString()];
        } else if (commandFrom is YamlList) {
          command = commandFrom.map((node) => node.toString()).toList();
        } else {
          throw DartdocOptionError(
              'Tool commands must be a path to an executable, or a list of '
              'strings that starts with a path to an executable. The tool '
              "'$name' has a '$commandFromKey' entry that is a "
              '${commandFrom.runtimeType}');
        }
        if (command.isEmpty || command[0].isEmpty) {
          throw DartdocOptionError(
              'Tool commands must not be empty. Tool $name command entry '
              '"$commandFromKey" must contain at least one path.');
        }
        return command;
      }

      var command = findCommand();
      if (command == null) {
        throw DartdocOptionError(
            'At least one of "command" or "${Platform.operatingSystem}" must '
            'be defined for the tool $name.');
      }
      var setupCommand = findCommand('setup_');

      var rawCompileArgs = toolMap[compileArgsTagName];
      var compileArgs = switch (rawCompileArgs) {
        null => const <String>[],
        String() => [toolMap[compileArgsTagName].toString()],
        YamlList() =>
          rawCompileArgs.map((node) => node.toString()).toList(growable: false),
        _ => throw DartdocOptionError(
            'Tool compile arguments must be a list of strings. The tool '
            "'$name' has a '$compileArgsTagName' entry that is a "
            '${rawCompileArgs.runtimeType}',
          ),
      };

      /// Validates [executable] and returns whether it is a Dart script.
      bool isDartScript(String executable) {
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
      var isDartSetupScript = isDartScript(executable);
      if (setupCommand != null) {
        var setupExecutableRelativePath = setupCommand.removeAt(0);
        var setupExecutable = pathContext.canonicalize(
            pathContext.join(canonicalYamlPath, setupExecutableRelativePath));
        // Setup commands aren't snapshotted, since they're only run once.
        setupCommand = [
          if (isDartSetupScript) Platform.resolvedExecutable,
          setupExecutable,
          ...setupCommand,
        ];
      }
      newToolDefinitions[name] = ToolDefinition.fromCommand(
          [executable, ...command],
          setupCommand ?? const [],
          description,
          resourceProvider,
          compileArgs: compileArgs);
    }
    return ToolConfiguration._(newToolDefinitions, resourceProvider);
  }
}
