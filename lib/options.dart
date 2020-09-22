import 'dart:io' show stderr, exitCode;

import 'package:analyzer/file_system/file_system.dart';
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';

class DartdocProgramOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocProgramOptionContext(
      DartdocOptionSet optionSet, Folder dir, ResourceProvider resourceProvider)
      : super(optionSet, dir, resourceProvider);

  bool get generateDocs => optionSet['generateDocs'].valueAt(context);
  bool get help => optionSet['help'].valueAt(context);
  bool get version => optionSet['version'].valueAt(context);
}

Future<List<DartdocOption<bool>>> createDartdocProgramOptions(
    PackageMetaProvider packageMetaProvider) async {
  var resourceProvider = packageMetaProvider.resourceProvider;
  return [
    DartdocOptionArgOnly<bool>('generateDocs', true, resourceProvider,
        help:
            'Generate docs into the output directory (or only display warnings '
            'if false).',
        negatable: true),
    DartdocOptionArgOnly<bool>('help', false, resourceProvider,
        abbr: 'h', help: 'Show command help.', negatable: false),
    DartdocOptionArgOnly<bool>('version', false, resourceProvider,
        help: 'Display the version for $programName.', negatable: false),
  ];
}

Future<DartdocProgramOptionContext> parseOptions(
  PackageMetaProvider packageMetaProvider,
  List<String> arguments, {
  OptionGenerator additionalOptions,
}) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc',
      [
        createDartdocOptions,
        createDartdocProgramOptions,
        createLoggingOptions,
        createGeneratorOptions,
        if (additionalOptions != null) additionalOptions,
      ],
      packageMetaProvider);

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
  if (optionSet['help'].valueAtCurrent()) {
    _printHelp(optionSet.argParser);
    exitCode = 0;
    return null;
  }
  if (optionSet['version'].valueAtCurrent()) {
    _printVersion(optionSet.argParser);
    exitCode = 0;
    return null;
  }

  DartdocProgramOptionContext config;
  try {
    config = DartdocProgramOptionContext(
        optionSet, null, packageMetaProvider.resourceProvider);
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
