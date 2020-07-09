import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';

class DartdocProgramOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocProgramOptionContext(DartdocOptionSet optionSet, Directory dir)
      : super(optionSet, dir);

  bool get generateDocs => optionSet['generateDocs'].valueAt(context);
  bool get help => optionSet['help'].valueAt(context);
  bool get version => optionSet['version'].valueAt(context);
}

Future<List<DartdocOption<bool>>> createDartdocProgramOptions() async {
  return [
    DartdocOptionArgOnly<bool>('generateDocs', true,
        help:
            'Generate docs into the output directory (or only display warnings if false).',
        negatable: true),
    DartdocOptionArgOnly<bool>('help', false,
        abbr: 'h', help: 'Show command help.', negatable: false),
    DartdocOptionArgOnly<bool>('version', false,
        help: 'Display the version for $programName.', negatable: false),
  ];
}

Future<DartdocProgramOptionContext> parseOptions(
  PackageMetaProvider packageMetaProvider,
  List<String> arguments, {
  OptionGenerator additionalOptions,
}) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators('dartdoc', [
    () => createDartdocOptions(packageMetaProvider),
    createDartdocProgramOptions,
    createLoggingOptions,
    createGeneratorOptions,
    if (additionalOptions != null) additionalOptions,
  ]);

  try {
    optionSet.parseArguments(arguments);
  } on FormatException catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsage(optionSet.argParser);
    // Do not use exit() as this bypasses --pause-isolates-on-exit
    exitCode = 64;
    return null;
  }
  if (optionSet['help'].valueAt(Directory.current)) {
    _printHelp(optionSet.argParser);
    exitCode = 0;
    return null;
  }
  if (optionSet['version'].valueAt(Directory.current)) {
    _printVersion(optionSet.argParser);
    exitCode = 0;
    return null;
  }

  DartdocProgramOptionContext config;
  try {
    config = DartdocProgramOptionContext(optionSet, null);
  } on DartdocOptionError catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    await stderr.flush();
    _printUsage(optionSet.argParser);
    exitCode = 64;
    return null;
  }
  startLogging(config);
  return config;
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
