// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;

/// The number of public libraries in testing/test_package, minus 2 for
/// the excluded libraries listed in the initializers for _testPackageGraphMemo
/// and minus 1 for the <nodoc> tag in the 'excluded' library.
const int kTestPackagePublicLibraries = 17;

final RegExp quotables = RegExp(r'[ "\r\n\$]');
final RegExp observatoryPortRegexp =
    RegExp(r'^Observatory listening on http://.*:(\d+)');

Directory sdkDir = defaultSdkDir;
PackageMeta sdkPackageMeta = PackageMeta.fromDir(sdkDir);

final _testPackageGraphMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraph => _testPackageGraphMemo.runOnce(() =>
    bootBasicPackage('testing/test_package', ['css', 'code_in_comments'],
        additionalArguments: ['--no-link-to-remote']));

final _testPackageGraphExperimentsMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphExperiments =>
    _testPackageGraphExperimentsMemo.runOnce(() => bootBasicPackage(
            'testing/test_package_experiments', [], additionalArguments: [
          '--enable-experiment',
          'non-nullable',
          '--no-link-to-remote'
        ]));

final _testPackageGraphGinormousMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphGinormous =>
    _testPackageGraphGinormousMemo.runOnce(() => bootBasicPackage(
            'testing/test_package', [
          'css',
          'code_in_commnets',
          'excluded'
        ], additionalArguments: [
          '--auto-include-dependencies',
          '--no-link-to-remote'
        ]));

final _testPackageGraphSmallMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphSmall =>
    _testPackageGraphSmallMemo.runOnce(() => bootBasicPackage(
        'testing/test_package_small', [],
        additionalArguments: ['--no-link-to-remote']));

final _testPackageGraphErrorsMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphErrors =>
    _testPackageGraphErrorsMemo.runOnce(() => bootBasicPackage(
        'testing/test_package_doc_errors',
        ['css', 'code_in_comments', 'excluded'],
        additionalArguments: ['--no-link-to-remote']));

final _testPackageGraphSdkMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphSdk =>
    _testPackageGraphSdkMemo.runOnce(bootSdkPackage);

final Directory testPackageBadDir = Directory('testing/test_package_bad');
final Directory testPackageDir = Directory('testing/test_package');
final Directory testPackageDuplicateDir =
    Directory('testing/test_package_duplicate');
final Directory testPackageExperimentsDir =
    Directory('testing/test_package_experiments');
final Directory testPackageMinimumDir =
    Directory('testing/test_package_minimum');
final Directory testPackageWithEmbedderYaml =
    Directory('testing/test_package_embedder_yaml');
final Directory testPackageWithNoReadme =
    Directory('testing/test_package_small');
final Directory testPackageIncludeExclude =
    Directory('testing/test_package_include_exclude');
final Directory testPackageImportExportError =
    Directory('testing/test_package_import_export_error');
final Directory testPackageOptions = Directory('testing/test_package_options');
final Directory testPackageOptionsImporter =
    Directory('testing/test_package_options_importer');
final Directory testPackageToolError =
    Directory('testing/test_package_tool_error');
final Directory testPackageCustomTemplates =
    Directory('testing/test_package_custom_templates');

/// Convenience factory to build a [DartdocGeneratorOptionContext] and associate
/// it with a [DartdocOptionSet] based on the current working directory and/or
/// the '--input' flag.
Future<DartdocGeneratorOptionContext> generatorContextFromArgv(
    List<String> argv) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions, createGeneratorOptions]);
  optionSet.parseArguments(argv);
  return DartdocGeneratorOptionContext(optionSet, null);
}

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(List<String> argv) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions]);
  optionSet.parseArguments(argv);
  return DartdocOptionContext(optionSet, Directory.current);
}

Future<PackageGraph> bootSdkPackage() async {
  return PackageBuilder(await contextFromArgv(['--input', sdkDir.path]))
      .buildPackageGraph();
}

Future<PackageGraph> bootBasicPackage(
    String dirPath, List<String> excludeLibraries,
    {List<String> additionalArguments}) async {
  var dir = Directory(dirPath);
  additionalArguments ??= <String>[];
  return PackageBuilder(await contextFromArgv([
            '--input',
            dir.path,
            '--sdk-dir',
            sdkDir.path,
            '--exclude',
            excludeLibraries.join(','),
            '--allow-tools',
          ] +
          additionalArguments))
      .buildPackageGraph();
}

/// Keeps track of coverage data automatically for any processes run by this
/// [CoverageSubprocessLauncher].  Requires that these be dart processes.
class CoverageSubprocessLauncher extends SubprocessLauncher {
  CoverageSubprocessLauncher(String context, [Map<String, String> environment])
      : super(context, environment) {
    environment ??= {};
    environment['DARTDOC_COVERAGE_DATA'] = tempDir.path;
  }

  static int nextRun = 0;

  /// Set this to true to enable coverage runs.
  static bool get coverageEnabled =>
      Platform.environment.containsKey('COVERAGE_TOKEN');

  /// A list of all coverage results picked up by all launchers.
  static List<Future<Iterable<Map>>> coverageResults = [];

  static Directory _tempDir;
  static Directory get tempDir {
    if (_tempDir == null) {
      if (Platform.environment['DARTDOC_COVERAGE_DATA'] != null) {
        _tempDir = Directory(Platform.environment['DARTDOC_COVERAGE_DATA']);
      } else {
        _tempDir = Directory.systemTemp.createTempSync('dartdoc_coverage_data');
      }
    }
    return _tempDir;
  }

  static String buildNextCoverageFilename() =>
      path.join(tempDir.path, 'dart-cov-${pid}-${nextRun++}.json');

  /// Call once all coverage runs have been generated by calling runStreamed
  /// on all [CoverageSubprocessLaunchers].
  static Future<void> generateCoverageToFile(File outputFile) async {
    if (!coverageEnabled) return Future.value(null);
    var currentCoverageResults = coverageResults;
    coverageResults = [];
    var launcher = SubprocessLauncher('format_coverage');

    /// Wait for all coverage runs to finish.
    await Future.wait(currentCoverageResults);

    return launcher.runStreamed('pub', [
      'run',
      'coverage:format_coverage',
      '--lcov',
      '-v',
      '-b',
      '.',
      '--packages=.packages',
      '--sdk-root=${path.canonicalize(path.join(path.dirname(Platform.executable), '..'))}',
      '--out=${path.canonicalize(outputFile.path)}',
      '--report-on=bin,lib',
      '-i',
      tempDir.path,
    ]);
  }

  @override
  Future<Iterable<Map>> runStreamed(String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment = true,
      void Function(String) perLine}) async {
    environment ??= {};
    assert(
        executable == Platform.executable ||
            executable == Platform.resolvedExecutable,
        'Must use dart executable for tracking coverage');

    var portAsString = Completer<String>();
    void parsePortAsString(String line) {
      if (!portAsString.isCompleted && coverageEnabled) {
        var m = observatoryPortRegexp.matchAsPrefix(line);
        if (m?.group(1) != null) portAsString.complete(m.group(1));
      } else {
        if (perLine != null) perLine(line);
      }
    }

    Completer<Iterable<Map>> coverageResult;

    if (coverageEnabled) {
      coverageResult = Completer();
      // This must be added before awaiting in this method.
      coverageResults.add(coverageResult.future);
      arguments = [
        '--disable-service-auth-codes',
        '--enable-vm-service:0',
        '--pause-isolates-on-exit',
        ...arguments
      ];
      if (!environment.containsKey('DARTDOC_COVERAGE_DATA')) {
        environment['DARTDOC_COVERAGE_DATA'] = tempDir.path;
      }
    }

    var results = super.runStreamed(executable, arguments,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment,
        workingDirectory: workingDirectory,
        perLine: parsePortAsString);

    if (coverageEnabled) {
      // ignore: unawaited_futures
      super.runStreamed('pub', [
        'run',
        'coverage:collect_coverage',
        '--wait-paused',
        '--resume-isolates',
        '--port=${await portAsString.future}',
        '--out=${buildNextCoverageFilename()}',
      ]).then((r) => coverageResult.complete(r));
    }
    return results;
  }
}

class SubprocessLauncher {
  final String context;
  final Map<String, String> environmentDefaults;

  String get prefix => context.isNotEmpty ? '$context: ' : '';

  // from flutter:dev/tools/dartdoc.dart, modified
  static Future<void> _printStream(Stream<List<int>> stream, Stdout output,
      {String prefix = '', Iterable<String> Function(String line) filter}) {
    assert(prefix != null);
    filter ??= (line) => [line];
    return stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .expand(filter)
        .listen((String line) {
      if (line != null) {
        output.write('$prefix$line'.trim());
        output.write('\n');
      }
    }).asFuture();
  }

  SubprocessLauncher(this.context, [Map<String, String> environment])
      : environmentDefaults = environment ?? <String, String>{};

  /// A wrapper around start/await process.exitCode that will display the
  /// output of the executable continuously and fail on non-zero exit codes.
  /// It will also parse any valid JSON objects (one per line) it encounters
  /// on stdout/stderr, and return them.  Returns null if no JSON objects
  /// were encountered, or if DRY_RUN is set to 1 in the execution environment.
  ///
  /// Makes running programs in grinder similar to set -ex for bash, even on
  /// Windows (though some of the bashisms will no longer make sense).
  /// TODO(jcollins-g): refactor to return a stream of stderr/stdout lines
  ///                   and their associated JSON objects.
  Future<Iterable<Map>> runStreamed(String executable, List<String> arguments,
      {String workingDirectory,
      Map<String, String> environment,
      bool includeParentEnvironment = true,
      void Function(String) perLine}) async {
    environment ??= {};
    environment.addAll(environmentDefaults);
    List<Map> jsonObjects;

    /// Allow us to pretend we didn't pass the JSON flag in to dartdoc by
    /// printing what dartdoc would have printed without it, yet storing
    /// json objects into [jsonObjects].
    Iterable<String> jsonCallback(String line) {
      if (perLine != null) perLine(line);
      Map result;
      try {
        result = json.decoder.convert(line);
      } on FormatException {
        // Assume invalid JSON is actually a line of normal text.
      } on TypeError {
        // The convert function returns a String if there is no JSON in the
        // line.  Just ignore it and leave result null.
      }
      if (result != null) {
        jsonObjects ??= [];
        jsonObjects.add(result);
        if (result.containsKey('message')) {
          line = result['message'];
        } else if (result.containsKey('data')) {
          line = result['data']['text'];
        }
      }
      return line.split('\n');
    }

    stderr.write('$prefix+ ');
    if (workingDirectory != null) stderr.write('(cd "$workingDirectory" && ');
    if (environment != null) {
      stderr.write(environment.keys.map((String key) {
        if (environment[key].contains(quotables)) {
          return "$key='${environment[key]}'";
        } else {
          return '$key=${environment[key]}';
        }
      }).join(' '));
      stderr.write(' ');
    }
    stderr.write('$executable');
    if (arguments.isNotEmpty) {
      for (var arg in arguments) {
        if (arg.contains(quotables)) {
          stderr.write(" '$arg'");
        } else {
          stderr.write(' $arg');
        }
      }
    }
    if (workingDirectory != null) stderr.write(')');
    stderr.write('\n');

    if (Platform.environment.containsKey('DRY_RUN')) return null;

    var realExecutable = executable;
    var realArguments = <String>[];
    if (Platform.isLinux) {
      // Use GNU coreutils to force line buffering.  This makes sure that
      // subprocesses that die due to fatal signals do not chop off the
      // last few lines of their output.
      //
      // Dart does not actually do this (seems to flush manually) unless
      // the VM crashes.
      realExecutable = 'stdbuf';
      realArguments.addAll(['-o', 'L', '-e', 'L']);
      realArguments.add(executable);
    }
    realArguments.addAll(arguments);

    var process = await Process.start(realExecutable, realArguments,
        workingDirectory: workingDirectory,
        environment: environment,
        includeParentEnvironment: includeParentEnvironment);
    var stdoutFuture = _printStream(process.stdout, stdout,
        prefix: prefix, filter: jsonCallback);
    var stderrFuture = _printStream(process.stderr, stderr,
        prefix: prefix, filter: jsonCallback);
    await Future.wait([stderrFuture, stdoutFuture, process.exitCode]);

    var exitCode = await process.exitCode;
    if (exitCode != 0) {
      throw ProcessException(executable, arguments,
          'SubprocessLauncher got non-zero exitCode: $exitCode', exitCode);
    }
    return jsonObjects;
  }
}
