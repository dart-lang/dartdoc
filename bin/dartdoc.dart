// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:io';

import 'package:args/args.dart';
import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
main(List<String> arguments) async {
  var parser = _createArgsParser();
  var args = parser.parse(arguments);

  if (args['help']) {
    _printHelp(parser);
  }

  if (args['version']) {
    print('$name version: $version');
    exit(0);
  }

  Directory sdkDir = cli_util.getSdkDir(arguments);
  if (sdkDir == null) {
    print("Error: unable to locate the Dart SDK. Please use the --dart-sdk "
        "command line option or set the DART_SDK environment variable.");
    exit(1);
  }

  bool sdkDocs = false;
  if (args['sdk-docs']) {
    sdkDocs = true;
  }

  var readme = args['sdk-readme'];
  if (readme != null && !(new File(readme).existsSync())) {
    print("Error: unable to locate the SDK description file at $readme.");
    exit(1);
  }

  Directory inputDir = new Directory(args['input']);
  if (!inputDir.existsSync()) {
    print("Error: unable to locate the input directory at ${inputDir.path}.");
    exit(1);
  }

  List<String> excludeLibraries =
      args['exclude'] == null ? [] : args['exclude'].split(',');
  String url = args['hosted-url'];
  String footerFilePath = _resolveTildePath(args['footer']);
  if (footerFilePath != null && !new File(footerFilePath).existsSync()) {
    print("Error: unable to locate the file with footer at ${footerFilePath}.");
    exit(1);
  }
  String headerFilePath = _resolveTildePath(args['header']);
  if (headerFilePath != null && !new File(headerFilePath).existsSync()) {
    print("Error: unable to locate the file with header at ${headerFilePath}.");
    exit(1);
  }

  Directory outputDir =
      new Directory(path.join(Directory.current.path, defaultOutDir));
  if (args['output'] != null) {
    outputDir = new Directory(_resolveTildePath(args['output']));
  }

  Directory packageRootDir;
  if (args['package-root'] != null) {
    packageRootDir = new Directory(_resolveTildePath(args['package-root']));
  }

  if (args.rest.isNotEmpty) {
    var unknownArgs = args.rest.join(' ');
    print('Error: detected unknown command-line argument(s): $unknownArgs');
    _printUsageAndExit(parser, exitCode: 1);
  }

  PackageMeta packageMeta = sdkDocs
      ? new PackageMeta.fromSdk(sdkDir, sdkReadmePath: readme)
      : new PackageMeta.fromDir(inputDir);

  print("Generating documentation for '${packageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}.");
  print('');

  var generators = initGenerators(url, headerFilePath, footerFilePath);

  var dartdoc = new DartDoc(inputDir, excludeLibraries, sdkDir, generators,
      outputDir, packageRootDir, packageMeta);

  try {
    DartDocResults results = await dartdoc.generateDocs();
    print('\nSuccess! Open file://${results.outDir.absolute.path}/index.html');
  } catch (e, st) {
    if (e is DartDocFailure) {
      stderr.writeln('Generation failed: ${e}.');
      exit(1);
    } else {
      stderr.writeln('Generation failed: ${e}\n${st}');
      exit(255);
    }
  }
}

/// Print help if we are passed the help option.
void _printHelp(ArgParser parser, {int exitCode: 0}) {
  print('Generate HTML documentation for Dart libraries.\n');
  _printUsageAndExit(parser, exitCode: exitCode);
}

void _printUsageAndExit(ArgParser parser, {int exitCode: 0}) {
  print('Usage: dartdoc [OPTIONS]\n');
  print(parser.usage);
  exit(exitCode);
}

ArgParser _createArgsParser() {
  var parser = new ArgParser();
  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Show command help.');
  parser.addFlag('version',
      help: 'Display the version for $name.', negatable: false);
  parser.addOption('dart-sdk',
      help: "Location of the Dart SDK. Use if SDK isn't automatically located.");
  parser.addFlag('sdk-docs',
      help: 'Generate ONLY the docs for the Dart SDK.', negatable: false);
  parser.addOption('sdk-readme',
      help: 'Path to the SDK description file. Use if generating Dart SDK docs.');
  parser.addOption('input',
      help: 'Path to source directory', defaultsTo: Directory.current.path);
  parser.addOption('output',
      help: 'Path to output directory.', defaultsTo: defaultOutDir);
  parser.addOption('header',
      help: 'path to file containing HTML text, inserted into the header of every page.');
  parser.addOption('footer',
      help: 'path to file containing HTML text, inserted into the footer of every page.');
  parser.addOption('package-root', help: 'The path to the package root.');
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
