// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:cli_util/cli_util.dart' as cli_util;

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
void main(List<String> arguments) {
  var parser = _createArgsParser();
  var args = parser.parse(arguments);

  if (args['help']) {
    _printUsageAndExit(parser);
  }

  if (args['version']) {
    print('$NAME version: $VERSION');
    exit(0);
  }

  Directory sdkDir = cli_util.getSdkDir(arguments);
  if (sdkDir == null) {
    print("Warning: unable to locate the Dart SDK. Please use the --dart-sdk "
        "command line option or set the DART_SDK environment variable.");
    exit(1);
  }

  bool sdkDocs = false;
  if (args['sdk-docs']) {
    sdkDocs = true;
  }

  var readme = args['sdk-readme'];
  if (readme != null && !(new File(readme).existsSync())) {
    print("Warning: unable to locate the SDK description file at $readme.");
    exit(1);
  }

  Directory inputDir = new Directory(args['input']);
  if (!inputDir.existsSync()) {
    print("Warning: unable to locate the input directory at ${inputDir.path}.");
    exit(1);
  }

  List<String> excludeLibraries =
      args['exclude'] == null ? [] : args['exclude'].split(',');
  String url = args['hosted-url'];
  String footerFilePath = _resolveTildePath(args['footer']);
  if (footerFilePath != null && !new File(footerFilePath).existsSync()) {
    print(
        "Warning: unable to locate the file with footer at ${footerFilePath}.");
    exit(1);
  }
  String headerFilePath = _resolveTildePath(args['header']);
  if (headerFilePath != null && !new File(headerFilePath).existsSync()) {
    print(
        "Warning: unable to locate the file with footer at ${headerFilePath}.");
    exit(1);
  }

  var outputDir = new Directory(path.join(Directory.current.path, 'docs'));
  if (args['output'] != null) {
    outputDir = new Directory(_resolveTildePath(args['output']));
  }
  if (outputDir.existsSync()) {
    print("Warning: output directory exists: ${args['output']}");
    exit(1);
  }
  print('Generating Dart API docs into ${outputDir.path}');

  var generators = initGenerators(url, headerFilePath, footerFilePath);

  new DartDoc(inputDir, excludeLibraries, sdkDir, generators, outputDir,
      sdkDocs: sdkDocs, sdkReadmePath: readme)..generateDocs();
}

/// Print help if we are passed the help option or invalid arguments.
void _printUsageAndExit(ArgParser parser) {
  print('Generate HTML documentation for Dart libraries.\n');
  print('Usage: dartdoc [OPTIONS]\n');
  print(parser.usage);
  exit(0);
}

ArgParser _createArgsParser() {
  var parser = new ArgParser();
  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Show command help.');
  parser.addFlag('version',
      help: 'Display the version for $NAME.', negatable: false);
  parser.addFlag('dart-sdk',
      help: "Location of the Dart SDK. Use if SDK isn't automatically located.",
      defaultsTo: false,
      negatable: false);
  parser.addFlag('sdk-docs', help: 'Generate ONLY the docs for the Dart SDK.');
  parser.addOption('sdk-readme',
      help: 'Path to the SDK description file. Use if generating Dart SDK docs.');
  parser.addOption('input',
      help: 'Path to source directory', defaultsTo: Directory.current.path);
  parser.addOption('output',
      help: 'Path to output directory.', defaultsTo: 'docs');
  parser.addOption('header',
      help: 'path to file containing HTML text, inserted into the header of every page.');
  parser.addOption('footer',
      help: 'path to file containing HTML text, inserted into the footer of every page.');
  parser.addOption('exclude',
      help: 'Comma-separated list of library names to ignore.');
  parser.addOption('hosted-url',
      help: 'URL where the docs will be hosted (used to generate the sitemap).');
  return parser;
}

String _resolveTildePath(String originalPath) {
  if (originalPath == null || !originalPath.startsWith('~/')) {
    return originalPath;
  }

  String homeDir;

  if (Platform.isWindows) {
    homeDir = path.absolute(Platform.environment['USERPROFILE']);
  } else {
    homeDir = path.absolute(Platform.environment['HOME']);
  }

  return path.join(homeDir, originalPath.substring(2));
}
