// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.tool_runner;

import 'dart:io';

import 'package:path/path.dart' as pathLib;

typedef ToolErrorCallback = void Function(String message);
typedef FakeResultCallback = String Function(String tool,
    {List<String> args, String content});

/// A helper class for running external tools.
class ToolRunner {
  /// Creates a new ToolRunner.
  ///
  /// Takes a [toolMap] that describes all of the available tools.
  /// An optional `errorCallback` will be called for each error message
  /// generated by the tool.
  ToolRunner(this.toolMap, [this._errorCallback])
      : temporaryDirectory =
            Directory.systemTemp.createTempSync('dartdoc_tools_');

  final Map<String, String> toolMap;
  final Directory temporaryDirectory;
  final ToolErrorCallback _errorCallback;
  int _temporaryFileCount = 0;

  void _error(String message) {
    if (_errorCallback != null) {
      _errorCallback(message);
    }
  }

  File _createTemporaryFile() {
    _temporaryFileCount++;
    return new File(pathLib.join(
        temporaryDirectory.absolute.path, 'input_$_temporaryFileCount'))
      ..createSync(recursive: true);
  }

  /// Must be called when the ToolRunner is no longer needed. Ideally,
  /// this is called in the finally section of a try/finally.
  ///
  /// This will remove any temporary files created by the tool runner.
  void dispose() {
    if (temporaryDirectory.existsSync())
      temporaryDirectory.deleteSync(recursive: true);
  }

  /// Run a tool.  The name of the tool is the first argument in the [args].
  /// The content to be sent to to the tool is given in the optional [content],
  /// and the stdout of the tool is returned.
  ///
  /// The [args] must not be null, and it must have at least one member (the name
  /// of the tool).
  String run(List<String> args, [String content]) {
    assert(args != null);
    assert(args.isNotEmpty);
    content ??= '';
    String tool = args.removeAt(0);
    if (!toolMap.containsKey(tool)) {
      _error('Unable to find definition for tool "$tool" in tool map. '
          'Did you add it to dartdoc_options.yaml?');
      return '';
    }
    String toolPath = toolMap[tool];
    List<String> toolArgs = <String>[];
    if (pathLib.extension(toolPath) == '.dart') {
      // For dart tools, we want to invoke them with Dart.
      toolArgs = [toolPath];
      toolPath = Platform.resolvedExecutable;
    }

    // Ideally, we would just be able to send the input text into stdin,
    // but there's no way to do that synchronously, and converting dartdoc
    // to an async model of execution is a huge amount of work. Using
    // dart:cli's waitFor feels like a hack (and requires a similar amount
    // of work anyhow to fix order of execution issues). So, instead, we
    // have the tool take a filename as part of its arguments, and write
    // the input to a temporary file before running the tool synchronously.

    // Write the content to a temp file.
    File tmpFile = _createTemporaryFile();
    tmpFile.writeAsStringSync(content);

    // Substitute the temp filename for the "$INPUT" token.
    RegExp fileToken = new RegExp(r'\$INPUT\b');
    List<String> argsWithInput = <String>[];
    for (String arg in args) {
      argsWithInput.add(arg.replaceAll(fileToken, tmpFile.absolute.path));
    }

    argsWithInput = toolArgs + argsWithInput;
    String commandString() => ([toolPath] + argsWithInput).join(' ');
    try {
      ProcessResult result = Process.runSync(toolPath, argsWithInput);
      if (result.exitCode != 0) {
        _error('Tool "$tool" returned non-zero exit code '
            '(${result.exitCode}) when run as '
            '"${commandString()}".\n'
            'Input to $tool was:\n'
            '$content\n'
            'Stderr output was:\n${result.stderr}\n');
        return '';
      } else {
        return result.stdout;
      }
    } on ProcessException catch (exception) {
      _error('Failed to run tool "$tool" as '
          '"${commandString()}": $exception\n'
          'Input to $tool was:\n'
          '$content');
      return '';
    }
  }
}
