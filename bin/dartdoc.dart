// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:io';

import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/sdk_io.dart';
import 'package:args/args.dart';
import 'package:cli_util/cli_util.dart' as cli_util;
import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as path;
import 'package:stack_trace/stack_trace.dart';

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
main(List<String> arguments) async {
  var parser = _createArgsParser();
  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    print(e.message);
    print('');
    // http://linux.die.net/include/sysexits.h
    // #define EX_USAGE	64	/* command line usage error */
    _printUsageAndExit(parser, exitCode: 64);
  }

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

  if (args['show-progress']) {
    _showProgress = true;
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

  List<String> excludeLibraries = args['exclude'];
  List<String> includeLibraries = args['include'];
  List<String> includeExternals = args['include-external'];

  String url = args['hosted-url'];
  List<String> footerFilePaths = args['footer'].map(_resolveTildePath).toList();
  for (String footerFilePath in footerFilePaths) {
    if (!new File(footerFilePath).existsSync()) {
      print("Error: unable to locate footer file: ${footerFilePath}.");
      exit(1);
    }
  }
  List<String> headerFilePaths = args['header'].map(_resolveTildePath).toList();
  for (String headerFilePath in footerFilePaths) {
    if (!new File(headerFilePath).existsSync()) {
      print("Error: unable to locate header file: ${headerFilePath}.");
      exit(1);
    }
  }

  Directory outputDir =
      new Directory(path.join(Directory.current.path, defaultOutDir));
  if (args['output'] != null) {
    outputDir = new Directory(_resolveTildePath(args['output']));
  }

  if (args.rest.isNotEmpty) {
    var unknownArgs = args.rest.join(' ');
    print('Error: detected unknown command-line argument(s): $unknownArgs');
    _printUsageAndExit(parser, exitCode: 1);
  }

  PackageMeta packageMeta = sdkDocs
      ? new PackageMeta.fromSdk(sdkDir, sdkReadmePath: readme)
      : new PackageMeta.fromDir(inputDir);

  if (!packageMeta.isValid) {
    print('Unable to generate documentation.');
    packageMeta.getInvalidReasons().map((r) => '* $r').forEach(print);
    exit(1);
  }

  print("Generating documentation for '${packageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}");
  print('');

  var generators = await initGenerators(
      url, headerFilePaths, footerFilePaths, args['rel-canonical-prefix'],
      faviconPath: args['favicon'], useCategories: args['use-categories']);

  for (var generator in generators) {
    generator.onFileCreated.listen(_onProgress);
  }

  var addCrossdart = args['add-crossdart'] as bool;
  var includeSource = args['include-source'] as bool;

  DartSdk sdk = new DirectoryBasedDartSdk(new JavaFile(sdkDir.path));

  initializeConfig(
      addCrossdart: addCrossdart,
      includeSource: includeSource,
      inputDir: inputDir,
      sdkVersion: sdk.sdkVersion);

  var dartdoc = new DartDoc(inputDir, excludeLibraries, sdkDir, generators,
      outputDir, packageMeta, includeLibraries,
      includeExternals: includeExternals);

  Chain.capture(() async {
    DartDocResults results = await dartdoc.generateDocs();
    print('\nSuccess! Docs generated into ${results.outDir.absolute.path}');
  }, onError: (e, Chain chain) {
    if (e is DartDocFailure) {
      stderr.writeln('Generation failed: ${e}.');
      exit(1);
    } else {
      stderr.writeln('Generation failed: ${e}\n${chain.terse}');
      exit(255);
    }
  });
}

bool _showProgress = false;

ArgParser _createArgsParser() {
  var parser = new ArgParser();
  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Show command help.');
  parser.addFlag('version',
      help: 'Display the version for $name.', negatable: false);
  parser.addFlag('add-crossdart',
      help: 'Add Crossdart links to the source code pieces.',
      negatable: false,
      defaultsTo: false);
  parser.addOption('dart-sdk',
      help:
          "Location of the Dart SDK. Use if SDK isn't automatically located.");
  parser.addFlag('sdk-docs',
      help: 'Generate ONLY the docs for the Dart SDK.', negatable: false);
  parser.addFlag('show-progress',
      help: 'Display progress indications to console stdout', negatable: false);
  parser.addOption('sdk-readme',
      help:
          'Path to the SDK description file. Use if generating Dart SDK docs.');
  parser.addOption('input',
      help: 'Path to source directory', defaultsTo: Directory.current.path);
  parser.addOption('output',
      help: 'Path to output directory.', defaultsTo: defaultOutDir);
  parser.addOption('header',
      allowMultiple: true, help: 'path to file containing HTML text.');
  parser.addOption('footer',
      allowMultiple: true, help: 'path to file containing HTML text.');
  parser.addOption('exclude',
      allowMultiple: true, help: 'library names to ignore');
  parser.addOption('include',
      allowMultiple: true, help: 'library names to generate docs for');
  parser.addOption('include-external',
      allowMultiple: true, help: 'additional (external) libraries to include');
  parser.addOption('hosted-url',
      help:
          'URL where the docs will be hosted (used to generate the sitemap).');
  parser.addOption('rel-canonical-prefix',
      help:
          'If provided, add a rel="canonical" prefixed with provided value. \n'
          'Consider using if building many versions of the docs for public SEO. '
          'Learn more at https://goo.gl/gktN6F.');
  parser.addFlag('include-source',
      help: 'Show source code blocks', negatable: true, defaultsTo: true);
  parser.addOption('favicon',
      help: 'A path to a favicon for the generated docs');
  parser.addFlag('use-categories',
      help: 'Group libraries from the same package into categories',
      negatable: false,
      defaultsTo: false);
  return parser;
}

void _onProgress(File file) {
  if (_showProgress) stdout.write('.');
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
