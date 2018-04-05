// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate' show Isolate;

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:logging/logging.dart' as logging;
import 'package:path/path.dart' as pathLib;
import 'package:stack_trace/stack_trace.dart';

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
main(List<String> arguments) async {
  var parser = _createArgsParser();
  ArgResults args;
  try {
    args = parser.parse(arguments);
  } on FormatException catch (e) {
    stderr.writeln(e.message);
    stderr.writeln('');
    // http://linux.die.net/include/sysexits.h
    // #define EX_USAGE	64	/* command line usage error */
    _printUsageAndExit(parser, exitCode: 64);
  }

  if (args['help']) {
    _printHelpAndExit(parser);
  }

  if (args['version']) {
    print('$name version: $version');
    exit(0);
  }

  Directory sdkDir = getSdkDir();
  if (sdkDir == null) {
    stderr.writeln(" Error: unable to locate the Dart SDK.");
    exit(1);
  }

  final bool sdkDocs = args['sdk-docs'];
  final bool showProgress = args['show-progress'];

  Directory inputDir;
  if (sdkDocs) {
    inputDir = sdkDir;
  } else if (args['input'] == null) {
    inputDir = Directory.current;
  } else {
    inputDir = args['input'];
  }

  if (!inputDir.existsSync()) {
    stderr.writeln(
        " fatal error: unable to locate the input directory at ${inputDir
            .path}.");
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
      stderr.writeln(
          " fatal error: unable to locate header file: ${headerFilePath}.");
      exit(1);
    }
  }

  List<String> footerFilePaths =
      args['footer'].map(_resolveTildePath).toList() as List<String>;
  for (String footerFilePath in footerFilePaths) {
    if (!new File(footerFilePath).existsSync()) {
      stderr.writeln(
          " fatal error: unable to locate footer file: ${footerFilePath}.");
      exit(1);
    }
  }

  List<String> footerTextFilePaths =
      args['footer-text'].map(_resolveTildePath).toList() as List<String>;

  // If we're generating docs for the Dart SDK, we insert a copyright footer.
  if (sdkDocs) {
    Uri footerCopyrightUri = await Isolate.resolvePackageUri(
        Uri.parse('package:dartdoc/resources/sdk_footer_text.html'));
    footerTextFilePaths = [footerCopyrightUri.toFilePath()];
  }

  for (String footerFilePath in footerTextFilePaths) {
    if (!new File(footerFilePath).existsSync()) {
      stderr.writeln(
          " fatal error: unable to locate footer-text file: ${footerFilePath}.");
      exit(1);
    }
  }

  Directory outputDir =
      new Directory(pathLib.join(Directory.current.path, defaultOutDir));
  if (args['output'] != null) {
    outputDir = new Directory(_resolveTildePath(args['output']));
  }

  if (args.rest.isNotEmpty) {
    var unknownArgs = args.rest.join(' ');
    stderr.writeln(
        ' fatal error: detected unknown command-line argument(s): $unknownArgs');
    _printUsageAndExit(parser, exitCode: 1);
  }

  final logJson = args['json'] as bool;

  // By default, get all log output at `progressLevel` or greater.
  // This allows us to capture progress events and print `...`.
  logging.Logger.root.level = progressLevel;

  if (logJson) {
    logging.Logger.root.onRecord.listen((record) {
      if (record.level == progressLevel) {
        return;
      }

      var output = <String, dynamic>{'level': record.level.name};

      if (record.object is Jsonable) {
        output['data'] = record.object;
      } else {
        output['message'] = record.message;
      }

      print(json.encode(output));
    });
  } else {
    final stopwatch = new Stopwatch()..start();

    // Used to track if we're printing `...` to show progress.
    // Allows unified new-line tracking
    var writingProgress = false;

    logging.Logger.root.onRecord.listen((record) {
      if (record.level == progressLevel) {
        if (showProgress && stopwatch.elapsed.inMilliseconds > 250) {
          writingProgress = true;
          stdout.write('.');
          stopwatch.reset();
        }
        return;
      }

      stopwatch.reset();
      if (writingProgress) {
        // print a new line after progress dots...
        print('');
        writingProgress = false;
      }
      var message = record.message;
      assert(message == message.trimRight());
      assert(message.isNotEmpty);

      if (record.level < logging.Level.WARNING) {
        if (showProgress && message.endsWith('...')) {
          // Assume there may be more progress to print, so omit the trailing
          // newline
          writingProgress = true;
          stdout.write(message);
        } else {
          print(message);
        }
      } else {
        stderr.writeln(message);
      }
    });
  }

  PackageMeta packageMeta = new PackageMeta.fromDir(inputDir);

  if (packageMeta == null) {
    stderr.writeln(
        ' fatal error: Unable to generate documentation: no pubspec.yaml found');
    exit(1);
  }

  if (!packageMeta.isValid) {
    final String firstError = packageMeta.getInvalidReasons().first;
    stderr.writeln(
        ' fatal error: Unable to generate documentation: $firstError.');
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

  logInfo("Generating documentation for '${packageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}");

  var generators = await initGenerators(url, args['rel-canonical-prefix'],
      headerFilePaths: headerFilePaths,
      footerFilePaths: footerFilePaths,
      footerTextFilePaths: footerTextFilePaths,
      faviconPath: args['favicon'],
      prettyIndexJson: args['pretty-index-json']);

  for (var generator in generators) {
    generator.onFileCreated.listen(logProgress);
  }

  DartSdk sdk = new FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
      PhysicalResourceProvider.INSTANCE.getFolder(sdkDir.path));

  List<String> dropTextFrom = [];
  if (args['hide-sdk-text']) {
    dropTextFrom.addAll([
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
    ]);
  }

  DartDocConfig config = new DartDocConfig.fromParameters(
      addCrossdart: args['add-crossdart'],
      examplePathPrefix: args['example-path-prefix'],
      showWarnings: args['show-warnings'],
      includeSource: args['include-source'],
      inputDir: inputDir,
      sdkVersion: sdk.sdkVersion,
      autoIncludeDependencies: args['auto-include-dependencies'],
      packageOrder: args['package-order'].isEmpty
          ? args['category-order']
          : args['package-order'],
      reexportMinConfidence:
          double.parse(args['ambiguous-reexport-scorer-min-confidence']),
      verboseWarnings: args['verbose-warnings'],
      excludePackages: args['exclude-packages'],
      dropTextFrom: dropTextFrom,
      validateLinks: args['validate-links']);

  DartDoc dartdoc = new DartDoc(config, excludeLibraries, sdkDir, generators,
      outputDir, packageMeta, includeLibraries, includeExternals);

  dartdoc.onCheckProgress.listen(logProgress);
  await Chain.capture(() async {
    await runZoned(() async {
      DartDocResults results = await dartdoc.generateDocs();
      logInfo('Success! Docs generated into ${results.outDir.absolute.path}');
    },
        zoneSpecification: new ZoneSpecification(
            print: (Zone self, ZoneDelegate parent, Zone zone, String line) =>
                logPrint(line)));
  }, onError: (e, Chain chain) {
    if (e is DartDocFailure) {
      stderr.writeln('\nGeneration failed: ${e}.');
      exit(1);
    } else {
      stderr.writeln('\nGeneration failed: ${e}\n${chain.terse}');
      exit(255);
    }
  });
}

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
  parser.addFlag('show-warnings',
      help: 'Display warnings.', negatable: false, defaultsTo: false);
  parser.addFlag('show-progress',
      help: 'Display progress indications to console stdout', negatable: false);
  parser.addOption('sdk-readme',
      help: 'Path to the SDK description file.  Deprecated (ignored)');
  parser.addOption('input', help: 'Path to source directory.');
  parser.addOption('output',
      help: 'Path to output directory.', defaultsTo: defaultOutDir);
  parser.addMultiOption('header',
      splitCommas: true, help: 'paths to header files containing HTML text.');
  parser.addMultiOption('footer',
      splitCommas: true, help: 'paths to footer files containing HTML text.');
  parser.addMultiOption('footer-text',
      splitCommas: true,
      help: 'paths to footer-text files '
          '(optional text next to the package name and version).');
  parser.addMultiOption('exclude',
      splitCommas: true, help: 'Library names to ignore.');
  parser.addMultiOption('exclude-packages',
      splitCommas: true, help: 'Package names to ignore.');
  parser.addMultiOption('include',
      splitCommas: true, help: 'Library names to generate docs for.');
  parser.addMultiOption('include-external',
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
      help:
          'Group libraries from the same package in the libraries sidebar. (deprecated, ignored)',
      negatable: false,
      defaultsTo: false);
  parser.addMultiOption('category-order',
      help:
          'A list of package names to place first when grouping libraries in packages. '
          'Unmentioned categories are sorted after these. (deprecated, replaced by package-order)',
      splitCommas: true);
  parser.addMultiOption('package-order',
      help:
          'A list of package names to place first when grouping libraries in packages. '
          'Unmentioned categories are sorted after these.',
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
  parser.addOption('ambiguous-reexport-scorer-min-confidence',
      help:
          'Minimum scorer confidence to suppress warning on ambiguous reexport.',
      defaultsTo: "0.1",
      hide: true);
  parser.addFlag('verbose-warnings',
      help: 'Display extra debugging information and help with warnings.',
      negatable: true,
      defaultsTo: true);
  parser.addFlag('hide-sdk-text',
      help:
          "Drop all text for SDK components.  Helpful for integration tests for dartdoc, probably not useful for anything else.",
      negatable: true,
      defaultsTo: false,
      hide: true);
  parser.addFlag('json',
      help: 'Prints out progress JSON maps. One entry per line.',
      defaultsTo: false,
      negatable: true);
  parser.addFlag('validate-links',
      help:
          'Runs the built-in link checker to display Dart context aware warnings for broken links (slow)',
      negatable: true,
      defaultsTo: true);
  return parser;
}

/// Print help if we are passed the help option.
void _printHelpAndExit(ArgParser parser, {int exitCode: 0}) {
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
    homeDir = pathLib.absolute(Platform.environment['USERPROFILE']);
  } else {
    homeDir = pathLib.absolute(Platform.environment['HOME']);
  }

  return pathLib.join(homeDir, originalPath.substring(2));
}
