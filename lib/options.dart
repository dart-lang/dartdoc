import 'dart:io' show stderr, exitCode;

import 'package:analyzer/file_system/file_system.dart';
import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart' show dartdocVersion, programName;
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/package_meta.dart';

/// Helper class that consolidates option contexts for instantiating generators.
class DartdocGeneratorOptionContext extends DartdocOptionContext {
  DartdocGeneratorOptionContext(
      DartdocOptionSet optionSet, Folder dir, ResourceProvider resourceProvider)
      : super(optionSet, dir, resourceProvider);
  DartdocGeneratorOptionContext.fromDefaultContextLocation(
      DartdocOptionSet optionSet, ResourceProvider resourceProvider)
      : super.fromDefaultContextLocation(optionSet, resourceProvider);

  /// Returns the joined contents of any 'header' files specified in options.
  late final String header =
      _joinCustomTextFiles(optionSet['header'].valueAt(context));

  /// Returns the joined contents of any 'footer' files specified in options.
  late final String footer =
      _joinCustomTextFiles(optionSet['footer'].valueAt(context));

  /// Returns the joined contents of any 'footer-text' files specified in
  /// options.
  late final String footerText =
      _joinCustomTextFiles(optionSet['footerText'].valueAt(context));

  String _joinCustomTextFiles(Iterable<String> paths) => paths
      .map((p) => resourceProvider.getFile(p).readAsStringSync())
      .join('\n');

  bool get prettyIndexJson => optionSet['prettyIndexJson'].valueAt(context);

  String? get favicon => optionSet['favicon'].valueAt(context);

  String? get relCanonicalPrefix =>
      optionSet['relCanonicalPrefix'].valueAt(context);

  /// The 'templatesDir' dartdoc option if one was specified; otherwise `null`.
  String? get templatesDir => optionSet['templatesDir'].valueAt(context);

  // TODO(jdkoren): duplicated temporarily so that GeneratorContext is enough for configuration.
  @override
  bool get useBaseHref => optionSet['useBaseHref'].valueAt(context);

  /// The 'resourcesDir' dartdoc option if one was specified; otherwise `null`.
  String? get resourcesDir => optionSet['resourcesDir'].valueAt(context);
}

class DartdocProgramOptionContext extends DartdocGeneratorOptionContext
    with LoggingContext {
  DartdocProgramOptionContext(
      DartdocOptionSet optionSet, Folder dir, ResourceProvider resourceProvider)
      : super(optionSet, dir, resourceProvider);
  DartdocProgramOptionContext.fromDefaultContextLocation(
      DartdocOptionSet optionSet, ResourceProvider resourceProvider)
      : super.fromDefaultContextLocation(optionSet, resourceProvider);

  bool get generateDocs => optionSet['generateDocs'].valueAt(context);
  bool get help => optionSet['help'].valueAt(context);
  bool get version => optionSet['version'].valueAt(context);
}

List<DartdocOption<bool>> createDartdocProgramOptions(
    PackageMetaProvider packageMetaProvider) {
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

DartdocProgramOptionContext? parseOptions(
  PackageMetaProvider packageMetaProvider,
  List<String> arguments, {
  OptionGenerator? additionalOptions,
}) {
  var optionRoot = DartdocOptionRoot.fromOptionGenerators(
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
    optionRoot.parseArguments(arguments);
  } on FormatException catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsage(optionRoot.argParser);
    // Do not use exit() as this bypasses --pause-isolates-on-exit
    exitCode = 64;
    return null;
  }
  if (optionRoot['help'].valueAtCurrent()) {
    _printHelp(optionRoot.argParser);
    exitCode = 0;
    return null;
  }
  if (optionRoot['version'].valueAtCurrent()) {
    _printVersion(optionRoot.argParser);
    exitCode = 0;
    return null;
  }

  DartdocProgramOptionContext config;
  try {
    config = DartdocProgramOptionContext.fromDefaultContextLocation(
        optionRoot, packageMetaProvider.resourceProvider);
  } on DartdocOptionError catch (e) {
    stderr.writeln(' fatal error: ${e.message}');
    stderr.writeln('');
    _printUsage(optionRoot.argParser);
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
  print('dartdoc version: $dartdocVersion');
}
