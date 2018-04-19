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
import 'package:stack_trace/stack_trace.dart';

class DartdocProgramOptionContext extends DartdocOptionContext
    with LoggingContext, GeneratorContext {
  DartdocProgramOptionContext(DartdocOptionSet optionSet, Directory dir)
      : super(optionSet, dir);

  bool get help => optionSet['help'].valueAt(context);
  bool get version => optionSet['version'].valueAt(context);
}

Future<List<DartdocOption>> createDartdocProgramOptions() async {
  return <DartdocOption>[
    new DartdocOptionArgOnly<bool>('help', false,
        abbr: 'h', help: 'Show command help.', negatable: false),
    new DartdocOptionArgOnly<bool>('version', false,
        help: 'Display the version for $name.', negatable: false),
  ];
}

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
main(List<String> arguments) async {
  DartdocOptionSet optionSet =
      await DartdocOptionSet.fromOptionGenerators('dartdoc', [
    createDartdocOptions,
    createDartdocProgramOptions,
    createLoggingOptions,
    createGeneratorOptions,
  ]);

  DartdocProgramOptionContext config =
      new DartdocProgramOptionContext(optionSet, Directory.current);

  try {
    optionSet.parseArguments(arguments);
  } on FormatException catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsageAndExit(optionSet.argParser, exitCode: 64);
  } on DartdocOptionError catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsageAndExit(optionSet.argParser, exitCode: 64);
  }
  if (optionSet['help'].valueAt(Directory.current)) {
    _printHelpAndExit(optionSet.argParser);
  }
  if (optionSet['version'].valueAt(Directory.current)) {
    _printHelpAndExit(optionSet.argParser);
  }

  startLogging(config);

  Directory outputDir = new Directory(config.output);
  logInfo("Generating documentation for '${config.packageMeta}' into "
      "${outputDir.absolute.path}${Platform.pathSeparator}");

  Dartdoc dartdoc = await Dartdoc.withDefaultGenerators(config, outputDir);

  dartdoc.onCheckProgress.listen(logProgress);
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
      exit(1);
    } else {
      stderr.writeln('\nGeneration failed: ${e}\n${chain.terse}');
      exit(255);
    }
  });
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
