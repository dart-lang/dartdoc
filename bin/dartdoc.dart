// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:io';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:args/args.dart';
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

  Directory sdkDir = getSdkDir();
  if (sdkDir == null) {
    stderr.write(" Error: unable to locate the Dart SDK.");
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
    stderr
        .write(" fatal error: unable to locate the SDK description file at $readme.");
    exit(1);
  }

  Directory inputDir = new Directory(args['input']);
  if (!inputDir.existsSync()) {
    stderr.write(
        " fatal error: unable to locate the input directory at ${inputDir.path}.");
    exit(1);
  }

  List<String> excludeLibraries = args['exclude'] as List<String>;
  List<String> includeLibraries = args['include'] as List<String>;
  List<String> includeExternals = args['include-external'] as List<String>;

  String url = args['hosted-url'];

  List<String> headerFilePaths =
      args['header'].map(_resolveTildePath).toList() as List<String>;
  for (String headerFilePath in headerFilePaths) {
    if (!new File(headerFilePath).existsSync()) {
      stderr.write(" fatal error: unable to locate header file: ${headerFilePath}.");
      exit(1);
    }
  }

  List<String> footerFilePaths =
      args['footer'].map(_resolveTildePath).toList() as List<String>;
  for (String footerFilePath in footerFilePaths) {
    if (!new File(footerFilePath).existsSync()) {
      stderr.write(" fatal error: unable to locate footer file: ${footerFilePath}.");
      exit(1);
    }
  }

  List<String> footerTextFilePaths =
      args['footer-text'].map(_resolveTildePath).toList() as List<String>;
  for (String footerFilePath in footerTextFilePaths) {
    if (!new File(footerFilePath).existsSync()) {
      stderr.write(
          " fatal error: unable to locate footer-text file: ${footerFilePath}.");
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
    stderr.write(
        ' fatal error: detected unknown command-line argument(s): $unknownArgs');
    _printUsageAndExit(parser, exitCode: 1);
  }

  PackageMeta packageMeta = sdkDocs
      ? new PackageMeta.fromSdk(sdkDir, sdkReadmePath: readme)
      : new PackageMeta.fromDir(inputDir);

  if (!packageMeta.isValid) {
    stderr.writeln(
        ' fatal error: Unable to generate documentation: ${packageMeta.getInvalidReasons().first}.');
    exit(1);
  }

  if (!packageMeta.isSdk && packageMeta.needsPubGet) {
    try {
      packageMeta.runPubGet();
    } catch (e) {
      stderr.writeln('$e');
      exit(1);
    }
  }

  print("Generating documentation for '${packageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}");
  print('');

  var generators = await initGenerators(url, args['rel-canonical-prefix'],
      headerFilePaths: headerFilePaths,
      footerFilePaths: footerFilePaths,
      footerTextFilePaths: footerTextFilePaths,
      faviconPath: args['favicon'],
      useCategories: args['use-categories'],
      prettyIndexJson: args['pretty-index-json']);

  for (var generator in generators) {
    generator.onFileCreated.listen(_onProgress);
  }

  var addCrossdart = args['add-crossdart'] as bool;
  var includeSource = args['include-source'] as bool;

  DartSdk sdk = new FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
      PhysicalResourceProvider.INSTANCE.getFolder(sdkDir.path));

  setConfig(
      addCrossdart: addCrossdart,
      examplePathPrefix: args['example-path-prefix'],
      showWarnings: args['show-warnings'],
      includeSource: includeSource,
      inputDir: inputDir,
      sdkVersion: sdk.sdkVersion,
      autoIncludeDependencies: args['auto-include-dependencies'],
      categoryOrder: args['category-order']);

  DartDoc dartdoc = new DartDoc(inputDir, excludeLibraries, sdkDir, generators,
      outputDir, packageMeta, includeLibraries,
      includeExternals: includeExternals);

  dartdoc.onCheckProgress.listen(_onProgress);
  /*DartDocResults results = await dartdoc.generateDocs();
  print('\nSuccess! Docs generated into ${results.outDir.absolute.path}');
  */
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
  parser.addFlag('sdk-docs',
      help: 'Generate ONLY the docs for the Dart SDK.', negatable: false);
  parser.addFlag('show-warnings', help: 'Display warnings.', negatable: false, defaultsTo: false);
  parser.addFlag('show-progress',
      help: 'Display progress indications to console stdout', negatable: false);
  parser.addOption('sdk-readme',
      help:
          'Path to the SDK description file; use if generating Dart SDK docs.');
  parser.addOption('input',
      help: 'Path to source directory.', defaultsTo: Directory.current.path);
  parser.addOption('output',
      help: 'Path to output directory.', defaultsTo: defaultOutDir);
  parser.addOption('header',
      allowMultiple: true,
      splitCommas: true,
      help: 'paths to header files containing HTML text.');
  parser.addOption('footer',
      allowMultiple: true,
      splitCommas: true,
      help: 'paths to footer files containing HTML text.');
  parser.addOption('footer-text',
      allowMultiple: true,
      splitCommas: true,
      help: 'paths to footer-text files (optional text next to the copyright).');
  parser.addOption('exclude',
      allowMultiple: true, splitCommas: true, help: 'Library names to ignore.');
  parser.addOption('include',
      allowMultiple: true,
      splitCommas: true,
      help: 'Library names to generate docs for.');
  parser.addOption('include-external',
      allowMultiple: true,
      help: 'Additional (external) dart files to include; use "dir/fileName", '
          'as in lib/material.dart.');
  parser.addOption('hosted-url',
      help:
          'URL where the docs will be hosted (used to generate the sitemap).');
  parser.addOption('example-path-prefix',
      help: 'Prefix for @example paths.\n(defaults to the project root)');
  parser.addOption('rel-canonical-prefix',
      help: 'If provided, add a rel="canonical" prefixed with provided value. '
          'Consider using if\nbuilding many versions of the docs for public '
          'SEO; learn more at https://goo.gl/gktN6F.');
  parser.addFlag('include-source',
      help: 'Show source code blocks.', negatable: true, defaultsTo: true);
  parser.addOption('favicon',
      help: 'A path to a favicon for the generated docs.');
  parser.addFlag('use-categories',
      help: 'Group libraries from the same package into categories.',
      negatable: false,
      defaultsTo: false);
  parser.addOption('category-order',
      help: 'A list of category names to place first when --use-categories is '
          'set.  Unmentioned categories are sorted after these.',
      allowMultiple: true,
      splitCommas: true);
  parser.addFlag('auto-include-dependencies',
      help:
          'Include all the used libraries into the docs, even the ones not in the current package or "include-external"',
      negatable: false,
      defaultsTo: false);
  parser.addFlag('pretty-index-json',
      help:
          "Generates `index.json` with indentation and newlines. The file is larger, but it's also easier to diff.",
      negatable: false,
      defaultsTo: false);
  return parser;
}

int _progressCounter = 0;
void _onProgress(var file) {
  if (_showProgress && _progressCounter % 5 == 0) {
    stdout.write('.');
  }
  _progressCounter += 1;
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
