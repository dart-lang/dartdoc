// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/html/html_generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/tool_runner.dart';
import 'package:stack_trace/stack_trace.dart';

class DartdocProgramOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocProgramOptionContext(DartdocOptionSet optionSet, Directory dir)
      : super(optionSet, dir);

  bool get asyncStackTraces => optionSet['asyncStackTraces'].valueAt(context);
  bool get help => optionSet['help'].valueAt(context);
  bool get version => optionSet['version'].valueAt(context);
}

Future<List<DartdocOption>> createDartdocProgramOptions() async {
  return <DartdocOption>[
    new DartdocOptionArgOnly<bool>('asyncStackTraces', false,
        help: 'Display coordinated asynchronous stack traces (slow)',
        negatable: true),
    new DartdocOptionArgOnly<bool>('help', false,
        abbr: 'h', help: 'Show command help.', negatable: false),
    new DartdocOptionArgOnly<bool>('version', false,
        help: 'Display the version for $name.', negatable: false),
  ];
}

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
Future<void> main(List<String> arguments) async {
  DartdocOptionSet optionSet =
      await DartdocOptionSet.fromOptionGenerators('dartdoc', [
    createDartdocOptions,
    createDartdocProgramOptions,
    createLoggingOptions,
    createGeneratorOptions,
  ]);

  try {
    optionSet.parseArguments(arguments);
  } on FormatException catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsage(optionSet.argParser);
    // Do not use exit() as this bypasses --pause-isolates-on-exit
    // TODO(jcollins-g): use exit once dart-lang/sdk#31747 is fixed.
    exitCode = 64;
    return;
  } on DartdocOptionError catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsage(optionSet.argParser);
    exitCode = 64;
    return;
  }
  if (optionSet['help'].valueAt(Directory.current)) {
    _printHelp(optionSet.argParser);
    exitCode = 0;
    return;
  }
  if (optionSet['version'].valueAt(Directory.current)) {
    _printVersion(optionSet.argParser);
    exitCode = 0;
    return;
  }

  DartdocProgramOptionContext config =
      new DartdocProgramOptionContext(optionSet, null);
  startLogging(config);

  Directory outputDir = new Directory(config.output);
  logInfo("Generating documentation for '${config.topLevelPackageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}");

  Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(config);

  dartdoc.onCheckProgress.listen(logProgress);
  try {
    await Chain.capture(() async {
      await runZoned(() async {
        DartdocResults results = await dartdoc.generateDocs();
        logInfo('Success! Docs generated into ${results.outDir.absolute.path}');
      },
          zoneSpecification: new ZoneSpecification(
              print: (Zone self, ZoneDelegate parent, Zone zone, String line) =>
                  logPrint(line)));
    }, onError: (e, Chain chain) {
      if (e is DartdocFailure) {
        stderr.writeln('\nGeneration failed: ${e}.');
        exitCode = 1;
        return;
      } else {
        stderr.writeln('\nGeneration failed: ${e}\n${chain.terse}');
        exitCode = 255;
        return;
      }
    }, when: config.asyncStackTraces);
  } finally {
    // Clear out any cached tool snapshots and temporary directories.
    // ignore: unawaited_futures
    SnapshotCache.instance.dispose();
    // ignore: unawaited_futures
    ToolTempFileTracker.instance.dispose();
  }
  exitCode = 0;
  return;
}

/// Print help if we are passed the help option.
void _printHelp(ArgParser parser) {
  print('Generate HTML documentation for Dart libraries.\n');
  print(parser.usage);
}

/// Print usage information on invalid command lines.
void _printUsage(ArgParser parser) {
  print('Usage: dartdoc [OPTIONS]\n');
  print(parser.usage);
}

/// Print version information.
void _printVersion(ArgParser parser) {
  print('dartdoc version: ${dartdocVersion}');
}
