// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' hide ProcessException;

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

import 'subprocess_launcher.dart';

void main(List<String> args) => grind(args);

/// Thrown on failure to find something in a file.
class GrindTestFailure implements Exception {
  final String message;

  GrindTestFailure(this.message);

  @override
  String toString() => message;
}

/// Kind of an inefficient grepper for now.
void expectFileContains(String path, List<Pattern> items) {
  var source = File(path);
  if (!source.existsSync()) {
    throw GrindTestFailure('file not found: $path');
  }
  for (var item in items) {
    if (!File(path).readAsStringSync().contains(item)) {
      throw GrindTestFailure('"$item" not found in $path');
    }
  }
}

/// Enable the following experiments for language tests.
final List<String> languageExperiments =
    (Platform.environment['LANGUAGE_EXPERIMENTS'] ?? '').split(RegExp(r'\s+'));

/// The pub cache inherited by grinder.
final String defaultPubCache = Platform.environment['PUB_CACHE'] ??
    p.context.resolveTildePath('~/.pub-cache');

/// Run no more than the number of processors available in parallel.
final TaskQueue testFutures = TaskQueue(
    maxJobs: int.tryParse(Platform.environment['MAX_TEST_FUTURES'] ?? '') ??
        Platform.numberOfProcessors);

// Directory.systemTemp is not a constant.  So wrap it.
Directory createTempSync(String prefix) =>
    Directory.systemTemp.createTempSync(prefix);

/// Global so that the lock is retained for the life of the process.
Future<void>? _lockFuture;
Completer<FlutterRepo>? _cleanFlutterRepo;

/// Returns true if we need to replace the existing flutter.  We never release
/// this lock until the program exits to prevent edge case runs from
/// spontaneously deciding to download a new Flutter SDK in the middle of a run.
// TODO(srawlins): The above comment is outdated.
Future<FlutterRepo> get cleanFlutterRepo async {
  var repoCompleter = _cleanFlutterRepo;
  if (repoCompleter != null) {
    return repoCompleter.future;
  }

  // No await is allowed between check of _cleanFlutterRepo and its assignment,
  // to prevent reentering this function.
  repoCompleter = Completer();

  // Figure out where the repository is supposed to be and lock updates for
  // it.
  await cleanFlutterDir.parent.create(recursive: true);
  assert(_lockFuture == null);
  _lockFuture = File(p.join(cleanFlutterDir.parent.path, 'lock'))
      .openSync(mode: FileMode.write)
      .lock();
  await _lockFuture;
  var lastSynced = File(p.join(cleanFlutterDir.parent.path, 'lastSynced'));
  var newRepo = FlutterRepo.fromPath(cleanFlutterDir.path, {}, 'clean');

  // We have a repository, but is it up to date?
  DateTime? lastSyncedTime;
  if (lastSynced.existsSync()) {
    lastSyncedTime = DateTime.fromMillisecondsSinceEpoch(
        int.parse(lastSynced.readAsStringSync()));
  }
  if (lastSyncedTime == null ||
      DateTime.now().difference(lastSyncedTime) > Duration(hours: 24)) {
    // Rebuild the repository.
    if (cleanFlutterDir.existsSync()) {
      cleanFlutterDir.deleteSync(recursive: true);
    }
    cleanFlutterDir.createSync(recursive: true);
    await newRepo._init();
    await lastSynced
        .writeAsString(DateTime.now().millisecondsSinceEpoch.toString());
  }
  repoCompleter.complete(newRepo);
  _cleanFlutterRepo = repoCompleter;
  return repoCompleter.future;
}

final String _dartdocDocsPath = createTempSync('dartdoc').path;

final Directory _sdkDocsDir = createTempSync('sdkdocs').absolute;

Directory cleanFlutterDir = Directory(
    p.join(p.context.resolveTildePath('~/.dartdoc_grinder'), 'cleanFlutter'));

final Directory _flutterDir = createTempSync('flutter');

final Directory _languageTestPackageDir =
    createTempSync('languageTestPackageDir');

Directory get testPackage => Directory(p.joinAll(['testing', 'test_package']));

Directory get testPackageExperiments =>
    Directory(p.joinAll(['testing', 'test_package_experiments']));

Directory get testPackageFlutterPlugin => Directory(
    p.joinAll(['testing', 'flutter_packages', 'test_package_flutter_plugin']));

final Directory _testPackageDocsDir = createTempSync('test_package');

final Directory _testPackageExperimentsDocsDir =
    createTempSync('test_package_experiments');

final String _pluginPackageDocsPath =
    createTempSync('test_package_flutter_plugin').path;

/// Version of dartdoc we should use when making comparisons.
String get dartdocOriginalBranch {
  var branch = Platform.environment['DARTDOC_ORIGINAL'];
  if (branch == null) {
    return 'master';
  } else {
    log('using branch/tag: $branch for comparison from \$DARTDOC_ORIGINAL');
    return branch;
  }
}

final _whitespacePattern = RegExp(r'\s+');

final List<String> _extraDartdocParameters = [
  ...?Platform.environment['DARTDOC_PARAMS']?.split(_whitespacePattern),
];

final Directory flutterDirDevTools =
    Directory(p.join(_flutterDir.path, 'dev', 'tools'));

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> _createThrowawayPubCache() {
  var pubCache = Directory.systemTemp.createTempSync('pubcache');
  var pubCacheBin = Directory(p.join(pubCache.path, 'bin'));
  var defaultCache = Directory(defaultPubCache);
  if (defaultCache.existsSync()) {
    copy(defaultCache, pubCache);
  } else {
    pubCacheBin.createSync();
  }
  return Map.fromIterables([
    'PUB_CACHE',
    'PATH'
  ], [
    pubCache.path,
    [pubCacheBin.path, Platform.environment['PATH']].join(':')
  ]);
}

@Task('Analyze dartdoc to ensure there are no errors and warnings')
@Depends(analyzeTestPackages)
void analyze() async {
  await SubprocessLauncher('analyze').runStreamed(
    Platform.resolvedExecutable,
    ['analyze', '--fatal-infos', '.'],
  );
}

@Task('Analyze the test packages')
void analyzeTestPackages() async {
  var testPackagePaths = [testPackage.path];
  if (Platform.version.contains('dev')) {
    testPackagePaths.add(testPackageExperiments.path);
  }
  for (var testPackagePath in testPackagePaths) {
    await SubprocessLauncher('pub-get').runStreamed(
      Platform.resolvedExecutable,
      ['pub', 'get'],
      workingDirectory: testPackagePath,
    );
    await SubprocessLauncher('analyze-test-package').runStreamed(
      Platform.resolvedExecutable,
      // TODO(srawlins): Analyze the whole directory by ignoring the pubspec
      // reports.
      ['analyze', 'lib'],
      workingDirectory: testPackagePath,
    );
  }
}

@Task('Check for dart format cleanliness')
void checkFormat() async {
  if (Platform.version.contains('dev')) {
    var filesToFix = <String>[];
    // Filter out test packages as they always have strange formatting.
    // Passing parameters to dart format for directories to search results in
    // filenames being stripped of the dirname so we have to filter here.
    void addFileToFix(String line) {
      if (!line.startsWith('Changed ')) return;
      var fileName = line.substring(8);
      var pathComponents = p.split(fileName);
      if (pathComponents.isNotEmpty && pathComponents.first == 'testing') {
        return;
      }
      filesToFix.add(fileName);
    }

    log('Validating dart format with version ${Platform.version}');
    await SubprocessLauncher('dart format').runStreamed(
        Platform.resolvedExecutable,
        [
          'format',
          '-o',
          'none',
          'bin',
          'lib',
          'test',
          'tool',
          'web',
        ],
        perLine: addFileToFix);
    if (filesToFix.isNotEmpty) {
      fail(
          'dart format found files needing reformatting. Use this command to reformat:\n'
          'dart format ${filesToFix.map((f) => "'$f'").join(' ')}');
    }
  } else {
    log('Skipping dart format check, requires latest dev version of SDK');
  }
}

@Task('Run quick presubmit checks.')
@Depends(
  analyze,
  checkFormat,
  checkBuild,
  tryPublish,
  smokeTest,
)
void presubmit() {}

@Task('Run long tests, self-test dartdoc, and run the publish test')
@Depends(presubmit, longTest, testDartdoc)
void buildbot() {}

@Task('Run buildbot tests, but without publish test')
@Depends(analyze, checkFormat, checkBuild, smokeTest, longTest, testDartdoc)
void buildbotNoPublish() {}

@Task('Generate docs for the Dart SDK')
Future<void> buildSdkDocs() async {
  log('building SDK docs');
  await _buildSdkDocs(_sdkDocsDir.path, Future.value(Directory.current.path));
}

class WarningsCollection {
  final String tempDir;
  final Map<String, int> warningKeyCounts;
  final String branch;
  final String? pubCachePath;

  WarningsCollection(this.tempDir, this.pubCachePath, this.branch)
      : warningKeyCounts = {};

  static const String kPubCachePathReplacement = '_xxxPubDirectoryxxx_';
  static const String kTempDirReplacement = '_xxxTempDirectoryxxx_';

  String _toKey(String text) {
    var key = text.replaceAll(tempDir, kTempDirReplacement);
    var pubCachePath = this.pubCachePath;
    if (pubCachePath != null) {
      key = key.replaceAll(pubCachePath, kPubCachePathReplacement);
    }
    return key;
  }

  String _fromKey(String text) {
    var key = text.replaceAll(kTempDirReplacement, tempDir);
    if (pubCachePath != null) {
      key = key.replaceAll(kPubCachePathReplacement, pubCachePath!);
    }
    return key;
  }

  void add(String text) {
    var key = _toKey(text);
    warningKeyCounts.update(key, (e) => e + 1, ifAbsent: () => 1);
  }

  /// Output formatter for comparing warnings.  [this] is the original.
  String getPrintableWarningDelta(String title, WarningsCollection current) {
    var printBuffer = StringBuffer();
    var quantityChangedOuts = <String>{};
    var onlyOriginal = <String>{};
    var onlyCurrent = <String>{};
    var identical = <String>{};
    var allKeys = <String>{
      ...warningKeyCounts.keys,
      ...current.warningKeyCounts.keys
    };

    for (var key in allKeys) {
      if (warningKeyCounts.containsKey(key) &&
          !current.warningKeyCounts.containsKey(key)) {
        onlyOriginal.add(key);
      } else if (!warningKeyCounts.containsKey(key) &&
          current.warningKeyCounts.containsKey(key)) {
        onlyCurrent.add(key);
      } else if (warningKeyCounts.containsKey(key) &&
          current.warningKeyCounts.containsKey(key) &&
          warningKeyCounts[key] != current.warningKeyCounts[key]) {
        quantityChangedOuts.add(key);
      } else {
        identical.add(key);
      }
    }

    if (onlyOriginal.isNotEmpty) {
      printBuffer.writeln(
          '*** $title : ${onlyOriginal.length} warnings from $branch, missing in ${current.branch}:');
      for (var key in onlyOriginal) {
        printBuffer.writeln(_fromKey(key));
      }
    }
    if (onlyCurrent.isNotEmpty) {
      printBuffer.writeln(
          '*** $title : ${onlyCurrent.length} new warnings in ${current.branch}, missing in $branch');
      for (var key in onlyCurrent) {
        printBuffer.writeln(current._fromKey(key));
      }
    }
    if (quantityChangedOuts.isNotEmpty) {
      printBuffer.writeln('*** $title : Identical warning quantity changed');
      for (var key in quantityChangedOuts) {
        printBuffer.writeln(
            '* Appeared ${warningKeyCounts[key]} times in $branch, ${current.warningKeyCounts[key]} in ${current.branch}:');
        printBuffer.writeln(current._fromKey(key));
      }
    }
    if (onlyOriginal.isEmpty &&
        onlyCurrent.isEmpty &&
        quantityChangedOuts.isEmpty) {
      printBuffer.writeln(
          '*** $title : No difference in warning output from $branch to ${current.branch}${allKeys.isEmpty ? "" : " (${allKeys.length} warnings found)"}');
    } else if (identical.isNotEmpty) {
      printBuffer.writeln(
          '*** $title : Difference in warning output found for ${allKeys.length - identical.length} warnings (${allKeys.length} warnings found)"');
    }
    return printBuffer.toString();
  }
}

/// Returns a map of warning texts to the number of times each has been seen.
WarningsCollection jsonMessageIterableToWarnings(
    Iterable<Map<Object, Object?>> messageIterable,
    String tempPath,
    String? pubDir,
    String branch) {
  var warningTexts = WarningsCollection(tempPath, pubDir, branch);
  for (final message in messageIterable) {
    if (message.containsKey('level') &&
        message['level'] == 'WARNING' &&
        message.containsKey('data')) {
      var data = message['data'] as Map;
      warningTexts.add(data['text'] as String);
    }
  }
  return warningTexts;
}

@Task('Display delta in SDK warnings')
Future<void> compareSdkWarnings() async {
  var originalDartdocSdkDocs =
      Directory.systemTemp.createTempSync('dartdoc-comparison-sdkdocs');
  var originalDartdoc = createComparisonDartdoc();
  var currentDartdocSdkBuild = _buildSdkDocs(
      _sdkDocsDir.path, Future.value(Directory.current.path), 'current');
  var originalDartdocSdkBuild =
      _buildSdkDocs(originalDartdocSdkDocs.path, originalDartdoc, 'original');
  var currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocSdkBuild, _sdkDocsDir.path, null, 'HEAD');
  var originalDartdocWarnings = jsonMessageIterableToWarnings(
      await originalDartdocSdkBuild,
      originalDartdocSdkDocs.absolute.path,
      null,
      dartdocOriginalBranch);

  print(originalDartdocWarnings.getPrintableWarningDelta(
      'SDK docs', currentDartdocWarnings));
}

/// Helper function to create a clean version of dartdoc (based on the current
/// directory, assumed to be a git repository).  Uses [dartdocOriginalBranch]
/// to checkout a branch or tag.
Future<String> createComparisonDartdoc() async {
  var launcher = SubprocessLauncher('create-comparison-dartdoc');
  var dartdocClean = Directory.systemTemp.createTempSync('dartdoc-comparison');
  await launcher
      .runStreamed('git', ['clone', Directory.current.path, dartdocClean.path]);
  await launcher.runStreamed('git', ['checkout', dartdocOriginalBranch],
      workingDirectory: dartdocClean.path);
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: dartdocClean.path);
  return dartdocClean.path;
}

/// Creates a clean version of dartdoc (based on the current directory, assumed
/// to be a git repository), configured to use packages from the Dart SDK.
///
/// This copy of dartdoc depends on the HEAD versions of various packages
/// developed within the SDK, such as 'analyzer', '_fe_analyzer_shared',
/// and 'meta'.
Future<String> createSdkDartdoc() async {
  var launcher = SubprocessLauncher('create-sdk-dartdoc');
  var dartdocSdk = Directory.systemTemp.createTempSync('dartdoc-sdk');
  await launcher
      .runStreamed('git', ['clone', Directory.current.path, dartdocSdk.path]);
  await launcher.runStreamed('git', ['checkout'],
      workingDirectory: dartdocSdk.path);

  var sdkClone = Directory.systemTemp.createTempSync('sdk-checkout');
  await launcher.runStreamed('git', [
    'clone',
    '--branch',
    'master',
    '--depth',
    '1',
    'https://dart.googlesource.com/sdk.git',
    sdkClone.path
  ]);
  var dartdocPubspec = File(p.join(dartdocSdk.path, 'pubspec.yaml'));
  var pubspecLines = await dartdocPubspec.readAsLines();
  var pubspecLinesFiltered = <String>[];
  for (var line in pubspecLines) {
    if (line.startsWith('dependency_overrides:')) {
      pubspecLinesFiltered.add('#dependency_overrides:');
    } else {
      pubspecLinesFiltered.add(line);
    }
  }

  await dartdocPubspec.writeAsString(pubspecLinesFiltered.join('\n'));
  dartdocPubspec.writeAsStringSync('''

dependency_overrides:
  analyzer:
    path: '${sdkClone.path}/pkg/analyzer'
  _fe_analyzer_shared:
    path: '${sdkClone.path}/pkg/_fe_analyzer_shared'
  meta:
    path: '${sdkClone.path}/pkg/meta'
''', mode: FileMode.append);
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: dartdocSdk.path);
  return dartdocSdk.path;
}

@Task('Run grind tasks with the analyzer SDK.')
Future<void> testWithAnalyzerSdk() async {
  var launcher = SubprocessLauncher('test-with-analyzer-sdk');
  // Do not override meta on branches outside of stable.
  var sdkDartdoc = await createSdkDartdoc();
  var defaultGrindParameter =
      Platform.environment['DARTDOC_GRIND_STEP'] ?? 'test';
  // TODO(srawlins): Re-enable sdk-analyzer when dart_style is published using
  // analyzer 3.0.0.
  try {
    await launcher.runStreamed(
        Platform.resolvedExecutable, ['run', 'grinder', defaultGrindParameter],
        workingDirectory: sdkDartdoc);
  } catch (e, st) {
    print('Warning: SDK analyzer job threw "$e":\n$st');
  }
}

Future<Iterable<Map<String, Object?>>> _buildSdkDocs(
    String sdkDocsPath, Future<String> futureCwd,
    [String label = '']) async {
  if (label != '') label = '-$label';
  var launcher = SubprocessLauncher('build-sdk-docs$label');
  var cwd = await futureCwd;
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: cwd);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        p.join('bin', 'dartdoc.dart'),
        '--output',
        sdkDocsPath,
        '--sdk-docs',
        '--json',
        '--show-progress',
        ..._extraDartdocParameters,
      ],
      workingDirectory: cwd);
}

Future<Iterable<Map<String, Object?>>> _buildTestPackageDocs(
    String outputDir, String cwd,
    {List<String> params = const [],
    String label = '',
    String? testPackagePath}) async {
  if (label != '') label = '-$label';
  testPackagePath ??= testPackage.absolute.path;
  var launcher = SubprocessLauncher('build-test-package-docs$label');
  var testPackagePubGet = launcher.runStreamed(
      Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: testPackagePath);
  var dartdocPubGet = launcher.runStreamed(
      Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: cwd);
  await Future.wait([testPackagePubGet, dartdocPubGet]);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        p.join(cwd, 'bin', 'dartdoc.dart'),
        '--output',
        outputDir,
        '--example-path-prefix',
        'examples',
        '--include-source',
        '--json',
        '--link-to-remote',
        '--pretty-index-json',
        ...params,
        ..._extraDartdocParameters,
      ],
      workingDirectory: testPackagePath);
}

@Task('Build generated test package docs from the experiment test package')
@Depends(clean)
Future<void> buildTestExperimentsPackageDocs() async {
  await _buildTestPackageDocs(
      _testPackageExperimentsDocsDir.absolute.path, Directory.current.path,
      testPackagePath: testPackageExperiments.absolute.path,
      params: [
        '--enable-experiment',
        'non-nullable,generic-metadata',
        '--no-link-to-remote'
      ]);
}

@Task('Serve experimental test package on port 8003.')
@Depends(buildTestExperimentsPackageDocs)
Future<void> serveTestExperimentsPackageDocs() async {
  await _serveDocsFrom(_testPackageExperimentsDocsDir.absolute.path, 8003,
      'test-package-docs-experiments');
}

@Task('Build test package docs (HTML) with inherited docs and source code')
@Depends(clean)
Future<void> buildTestPackageDocs() async {
  await _buildTestPackageDocs(
      _testPackageDocsDir.absolute.path, Directory.current.path);
}

@Task('Build test package docs (Markdown) with inherited docs and source code')
@Depends(clean)
Future<void> buildTestPackageDocsMd() async {
  await _buildTestPackageDocs(
      _testPackageDocsDir.absolute.path, Directory.current.path,
      params: ['--format', 'md']);
}

@Task('Serve test package docs locally with dhttpd on port 8002')
@Depends(buildTestPackageDocs)
Future<void> serveTestPackageDocs() async {
  await startTestPackageDocsServer();
}

@Task('Serve test package docs (in Markdown) locally with dhttpd on port 8002')
@Depends(buildTestPackageDocsMd)
Future<void> serveTestPackageDocsMd() async {
  await startTestPackageDocsServer();
}

Future<void> startTestPackageDocsServer() async {
  log('launching dhttpd on port 8002 for SDK');
  var launcher = SubprocessLauncher('serve-test-package-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8002',
    '--path',
    _testPackageDocsDir.absolute.path,
  ]);
}

bool _serveReady = false;

Future<void> _serveDocsFrom(String servePath, int port, String context) async {
  log('launching dhttpd on port $port for $context');
  var launcher = SubprocessLauncher(context);
  if (!_serveReady) {
    await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get']);
    await launcher.runStreamed(
        Platform.resolvedExecutable, ['pub', 'global', 'activate', 'dhttpd']);
    _serveReady = true;
  }
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '$port',
    '--path',
    servePath
  ]);
}

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
@Depends(buildSdkDocs)
Future<void> serveSdkDocs() async {
  log('launching dhttpd on port 8000 for SDK');
  var launcher = SubprocessLauncher('serve-sdk-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8000',
    '--path',
    _sdkDocsDir.path,
  ]);
}

@Task('Compare warnings in Dartdoc for Flutter')
Future<void> compareFlutterWarnings() async {
  var originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  var originalDartdoc = createComparisonDartdoc();
  var envCurrent = _createThrowawayPubCache();
  var envOriginal = _createThrowawayPubCache();
  var currentDartdocFlutterBuild = _buildFlutterDocs(_flutterDir.path,
      Future.value(Directory.current.path), envCurrent, 'docs-current');
  var originalDartdocFlutterBuild = _buildFlutterDocs(
      originalDartdocFlutter.path,
      originalDartdoc,
      envOriginal,
      'docs-original');
  var currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocFlutterBuild,
      _flutterDir.absolute.path,
      envCurrent['PUB_CACHE'],
      'HEAD');
  var originalDartdocWarnings = jsonMessageIterableToWarnings(
      await originalDartdocFlutterBuild,
      originalDartdocFlutter.absolute.path,
      envOriginal['PUB_CACHE'],
      dartdocOriginalBranch);

  print(originalDartdocWarnings.getPrintableWarningDelta(
      'Flutter repo', currentDartdocWarnings));

  if (Platform.environment['SERVE_FLUTTER'] == '1') {
    var launcher = SubprocessLauncher('serve-flutter-docs');
    await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get']);
    var original = launcher.runStreamed(Platform.resolvedExecutable, [
      'pub',
      'global',
      'run',
      'dhttpd',
      '--port',
      '9000',
      '--path',
      p.join(originalDartdocFlutter.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    var current = launcher.runStreamed(Platform.resolvedExecutable, [
      'pub',
      'global',
      'run',
      'dhttpd',
      '--port',
      '9001',
      '--path',
      p.join(_flutterDir.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    await Future.wait([original, current]);
  }
}

@Task('Serve generated Flutter docs locally with dhttpd on port 8001')
@Depends(buildFlutterDocs)
Future<void> serveFlutterDocs() async {
  log('launching dhttpd on port 8001 for Flutter');
  var launcher = SubprocessLauncher('serve-flutter-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get']);
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8001',
    '--path',
    p.join(_flutterDir.path, 'dev', 'docs', 'doc'),
  ]);
}

@Task('Serve language test directory docs on port 8004')
@Depends(buildLanguageTestDocs)
Future<void> serveLanguageTestDocs() async {
  log('launching dhttpd on port 8004 for language tests');
  var launcher = SubprocessLauncher('serve-language-test-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get']);
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8004',
    '--path',
    p.join(_languageTestPackageDir.path, 'doc', 'api'),
  ]);
}

@Task('Build docs for a language test directory in the SDK')
Future<void> buildLanguageTestDocs() async {
  // The path to the base directory for language tests.
  var languageTestPath = Platform.environment['LANGUAGE_TESTS'];
  if (languageTestPath == null) {
    fail(
        'LANGUAGE_TESTS must be set to the SDK language test directory from which to copy tests');
  }
  var launcher = SubprocessLauncher('build-language-test-docs');
  var pubspecFile = File(p.join(_languageTestPackageDir.path, 'pubspec.yaml'));
  pubspecFile.writeAsStringSync('''name: _language_test_package
version: 0.0.1
environment:
  sdk: '>=${Platform.version.split(' ').first}'
''');

  var analyzerOptionsFile =
      File(p.join(_languageTestPackageDir.path, 'analysis_options.yaml'));
  var analyzerOptions = languageExperiments.map((e) => '    - $e').join('\n');
  analyzerOptionsFile.writeAsStringSync('''analyzer:
   enable-experiment:
$analyzerOptions
 ''');

  var libDir = Directory(p.join(_languageTestPackageDir.path, 'lib'))
    ..createSync();
  var languageTestDir = Directory(p.context.resolveTildePath(languageTestPath));
  if (!languageTestDir.existsSync()) {
    fail('language test dir does not exist:  $languageTestDir');
  }

  for (var entry in languageTestDir.listSync(recursive: true)) {
    if (entry is File &&
        entry.existsSync() &&
        !entry.path.endsWith('_error_test.dart') &&
        !entry.path.endsWith('_error_lib.dart')) {
      var destDir = Directory(p.join(
          libDir.path,
          p.dirname(entry.absolute.path
              .replaceFirst(languageTestDir.absolute.path + p.separator, ''))));
      if (!destDir.existsSync()) destDir.createSync(recursive: true);
      copy(entry, destDir);
    }
  }

  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: _languageTestPackageDir.absolute.path);
  await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        p.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--link-to-remote',
        '--show-progress',
        '--enable-experiment',
        languageExperiments.join(','),
        ..._extraDartdocParameters,
      ],
      workingDirectory: _languageTestPackageDir.absolute.path);
}

@Task('Validate flutter docs')
@Depends(buildFlutterDocs, testDartdocFlutterPlugin)
void validateFlutterDocs() {}

@Task('Build flutter docs')
Future<void> buildFlutterDocs() async {
  log('building flutter docs into: $_flutterDir');
  var env = _createThrowawayPubCache();
  await _buildFlutterDocs(
      _flutterDir.path, Future.value(Directory.current.path), env, 'docs');
  var indexContents =
      File(p.join(_flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
          .readAsLinesSync();
  stdout.write([...indexContents.take(25), '...\n'].join('\n'));
}

/// A class wrapping a flutter SDK.
class FlutterRepo {
  final String flutterPath;
  final Map<String, String> env;
  final String flutterCmd = p.join('bin', 'flutter');

  final String cacheDart;
  final SubprocessLauncher launcher;

  FlutterRepo._(this.flutterPath, this.env, this.cacheDart, this.launcher);

  Future<void> _init() async {
    Directory(flutterPath).createSync(recursive: true);
    await launcher.runStreamed(
        'git', ['clone', 'https://github.com/flutter/flutter.git', '.'],
        workingDirectory: flutterPath);
    await launcher.runStreamed(
      flutterCmd,
      ['--version'],
      workingDirectory: flutterPath,
    );
    await launcher.runStreamed(
      flutterCmd,
      ['update-packages'],
      workingDirectory: flutterPath,
    );
  }

  factory FlutterRepo.fromPath(String flutterPath, Map<String, String> env,
      [String? label]) {
    var cacheDart =
        p.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
    env['PATH'] =
        '${p.join(p.canonicalize(flutterPath), "bin")}:${env['PATH'] ?? Platform.environment['PATH']}';
    env['FLUTTER_ROOT'] = flutterPath;
    var launcher =
        SubprocessLauncher('flutter${label == null ? "" : "-$label"}', env);
    return FlutterRepo._(flutterPath, env, cacheDart, launcher);
  }

  /// Copy an existing, initialized flutter repo.
  static Future<FlutterRepo> copyFromExistingFlutterRepo(
      FlutterRepo origRepo, String flutterPath, Map<String, String> env,
      [String? label]) async {
    copy(Directory(origRepo.flutterPath), Directory(flutterPath));
    var flutterRepo = FlutterRepo.fromPath(flutterPath, env, label);
    return flutterRepo;
  }

  /// Doesn't actually copy the existing repo; use for read-only operations
  /// only.
  static Future<FlutterRepo> fromExistingFlutterRepo(FlutterRepo origRepo,
      [String? label]) async {
    return FlutterRepo.fromPath(origRepo.flutterPath, {}, label);
  }
}

Future<Iterable<Map<String, Object?>>> _buildFlutterDocs(
    String flutterPath, Future<String> futureCwd, Map<String, String> env,
    [String? label]) async {
  var flutterRepo = await FlutterRepo.copyFromExistingFlutterRepo(
      await cleanFlutterRepo, flutterPath, env, label);
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cacheDart,
    ['pub', 'get'],
    workingDirectory: p.join(flutterPath, 'dev', 'tools'),
  );
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cacheDart,
    ['pub', 'global', 'activate', 'snippets'],
  );
  // TODO(jcollins-g): flutter's dart SDK pub tries to precompile the universe
  // when using -spath.  Why?
  await flutterRepo.launcher.runStreamed(flutterRepo.cacheDart,
      ['pub', 'global', 'activate', '-spath', '.', '-x', 'dartdoc'],
      workingDirectory: await futureCwd);
  return await flutterRepo.launcher.runStreamed(
    flutterRepo.cacheDart,
    [p.join('dev', 'tools', 'dartdoc.dart'), '-c', '--json'],
    workingDirectory: flutterPath,
  );
}

/// Returns the directory in which we generated documentation.
Future<String> _buildPubPackageDocs(
  String pubPackageName,
  List<String> dartdocParameters,
  PackageMetaProvider packageMetaProvider, [
  String? version,
  String? label,
]) async {
  var env = _createThrowawayPubCache();
  var versionContext = version == null ? '' : '-$version';
  var labelContext = label == null ? '' : '-$label';
  var launcher = SubprocessLauncher(
      'build-$pubPackageName$versionContext$labelContext', env);
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'cache',
    'add',
    if (version != null) ...['-v', version],
    pubPackageName,
  ]);
  var pubHost =
      Platform.version.contains('2.18') ? 'pub.dartlang.org' : 'pub.dev';
  var cache = Directory(p.join(env['PUB_CACHE']!, 'hosted', pubHost));
  var pubPackageDirOrig =
      cache.listSync().firstWhere((e) => e.path.contains(pubPackageName));
  var pubPackageDir = Directory.systemTemp.createTempSync(pubPackageName);
  copy(pubPackageDirOrig, pubPackageDir);

  if (packageMetaProvider
      .fromDir(PhysicalResourceProvider.INSTANCE.getFolder(pubPackageDir.path))!
      .requiresFlutter) {
    var flutterRepo =
        await FlutterRepo.fromExistingFlutterRepo(await cleanFlutterRepo);
    await launcher.runStreamed(flutterRepo.cacheDart, ['pub', 'get'],
        environment: flutterRepo.env,
        workingDirectory: pubPackageDir.absolute.path);
    await launcher.runStreamed(
        flutterRepo.cacheDart,
        [
          '--enable-asserts',
          p.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
          '--json',
          '--link-to-remote',
          '--show-progress',
          ...dartdocParameters,
        ],
        environment: flutterRepo.env,
        workingDirectory: pubPackageDir.absolute.path);
  } else {
    await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
        workingDirectory: pubPackageDir.absolute.path);
    await launcher.runStreamed(
        Platform.resolvedExecutable,
        [
          '--enable-asserts',
          p.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
          '--json',
          '--link-to-remote',
          '--show-progress',
          ...dartdocParameters,
        ],
        workingDirectory: pubPackageDir.absolute.path);
  }
  return p.join(pubPackageDir.absolute.path, 'doc', 'api');
}

@Task(
    'Build an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
Future<String> buildPubPackage() async {
  var packageName = Platform.environment['PACKAGE_NAME']!;
  var version = Platform.environment['PACKAGE_VERSION'];
  return _buildPubPackageDocs(
    packageName,
    _extraDartdocParameters,
    pubPackageMetaProvider,
    version,
  );
}

@Task(
    'Serve an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
Future<void> servePubPackage() async {
  await _serveDocsFrom(await buildPubPackage(), 9000, 'serve-pub-package');
}

@Task('Checks that CHANGELOG mentions current version')
Future<void> checkChangelogHasVersion() async {
  var changelog = File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    fail('ERROR: No CHANGELOG.md found in ${Directory.current}');
  }

  var version = _getPackageVersion();

  if (!changelog.readAsLinesSync().contains('## $version')) {
    fail('ERROR: CHANGELOG.md does not mention version $version');
  }
}

String _getPackageVersion() {
  var pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    fail('Cannot find pubspec.yaml in ${Directory.current}');
  }
  var yamlDoc = yaml.loadYaml(pubspec.readAsStringSync()) as yaml.YamlMap;
  return yamlDoc['version'] as String;
}

@Task('Rebuild generated files')
@Depends(clean, buildWeb)
Future<void> build() async {
  var launcher = SubprocessLauncher('build');
  await launcher.runStreamed(Platform.resolvedExecutable,
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);

  // TODO(jcollins-g): port to build system?
  var version = _getPackageVersion();
  var dartdocOptions = File('dartdoc_options.yaml');
  await dartdocOptions.writeAsString('''dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/dartdoc/blob/v$version/%f%#L%l%'
''');
}

@Task('Build the web frontend')
Future<void> buildWeb() async {
  // Compile the web app.
  var launcher = SubprocessLauncher('build');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'compile',
    'js',
    '--output=lib/resources/docs.dart.js',
    'web/docs.dart',
    '-O4',
  ]);
  delete(File('lib/resources/docs.dart.js.deps'));

  final compileSig = await _calcDartFilesSig(Directory('web'));
  File(p.join('web', 'sig.txt')).writeAsStringSync('$compileSig\n');
}

/// Paths in this list are relative to lib/.
final _generatedFilesList = <String>[
  '../dartdoc_options.yaml',
  'src/generator/html_resources.g.dart',
  'src/generator/templates.aot_renderers_for_html.dart',
  'src/generator/templates.aot_renderers_for_md.dart',
  'src/generator/templates.runtime_renderers.dart',
  'src/version.dart',
  '../test/mustachio/foo.dart',
].map((s) => p.joinAll(p.posix.split(s)));

@Task('Verify generated files are up to date')
@Depends(clean)
Future<void> checkBuild() async {
  var originalFileContents = <String, String>{};
  var differentFiles = <String>[];

  // Load original file contents into memory before running the builder; it
  // modifies them in place.
  for (var relPath in _generatedFilesList) {
    var origPath = p.joinAll(['lib', relPath]);
    var oldVersion = File(origPath);
    if (oldVersion.existsSync()) {
      originalFileContents[relPath] = oldVersion.readAsStringSync();
    }
  }

  await build();

  for (var relPath in _generatedFilesList) {
    var newVersion = File(p.join('lib', relPath));
    if (!newVersion.existsSync()) {
      log('${newVersion.path} does not exist\n');
      differentFiles.add(relPath);
    } else if (originalFileContents[relPath] !=
        await newVersion.readAsString()) {
      log('${newVersion.path} has changed to: \n${newVersion.readAsStringSync()})');
      differentFiles.add(relPath);
    }
  }

  if (differentFiles.isNotEmpty) {
    fail('The following generated files needed to be rebuilt:\n'
        '  ${differentFiles.map((f) => p.join('lib', f)).join("\n  ")}\n'
        'Rebuild them with "grind build" and check the results in.');
  }

  // Verify that the web frontend has been compiled.
  final currentCodeSig = await _calcDartFilesSig(Directory('web'));
  final lastCompileSig =
      File(p.join('web', 'sig.txt')).readAsStringSync().trim();
  if (currentCodeSig != lastCompileSig) {
    log('current files: $currentCodeSig');
    log('cached sig   : $lastCompileSig');
    fail('The web frontend (web/docs.dart) needs to be recompiled; rebuild it '
        'with "grind build-web" or "grind build".');
  }
}

@Task('Dry run of publish to pub.dev')
@Depends(checkChangelogHasVersion)
Future<void> tryPublish() async {
  var launcher = SubprocessLauncher('try-publish');
  await launcher
      .runStreamed(Platform.resolvedExecutable, ['pub', 'publish', '-n']);
}

@Task('Run a smoke test, only')
@Depends(clean)
Future<void> smokeTest() async {
  await testDart(smokeTestFiles);
  await testFutures.tasksComplete;
}

@Task('Run non-smoke tests, only')
@Depends(clean)
Future<void> longTest() async {
  await testDart(testFiles);
  await testFutures.tasksComplete;
}

@Task('Run all the tests.')
@Depends(clean)
Future<void> test() async {
  await testDart(smokeTestFiles.followedBy(testFiles));
  await testFutures.tasksComplete;
}

@Task('Clean up test directories and delete build cache')
Future<void> clean() async {
  var toDelete = [...nonRootPubData, ...buildCacheDirectories];
  for (var e in toDelete) {
    e.deleteSync(recursive: true);
  }
}

Iterable<FileSystemEntity> get nonRootPubData {
  // This involves deleting things, so be careful.
  if (!File(p.join('tool', 'grind.dart')).existsSync()) {
    throw FileSystemException('wrong CWD, run from root of dartdoc package');
  }
  return Directory('.')
      .listSync(recursive: true)
      .where((e) => p.dirname(e.path) != '.')
      .where((e) => <String>['.dart_tool', '.packages', 'pubspec.lock']
          .contains(p.basename(e.path)));
}

Iterable<Directory> get buildCacheDirectories => Directory('.dart_tool')
    .listSync(recursive: false)
    .whereType<Directory>()
    .where((e) => ['build', 'build_resolvers'].contains(p.basename(e.path)));

List<File> get smokeTestFiles => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((e) => p.basename(e.path) == 'model_test.dart')
    .toList(growable: false);

List<File> get testFiles => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((e) => e.path.endsWith('test.dart'))
    .where((e) => p.basename(e.path) != 'model_test.dart')
    .toList(growable: false);

Future<void> testDart(Iterable<File> tests) async {
  var parameters = <String>['--enable-asserts'];

  for (var dartFile in tests) {
    await testFutures.add(() =>
        CoverageSubprocessLauncher('dart-${p.basename(dartFile.path)}')
            .runStreamed(Platform.resolvedExecutable,
                <String>[...parameters, dartFile.path]));
  }

  return CoverageSubprocessLauncher.generateCoverageToFile(
      PhysicalResourceProvider.INSTANCE.getFile(p.canonicalize('lcov.info')),
      PhysicalResourceProvider.INSTANCE);
}

@Task('Generate docs for dartdoc without link-to-remote')
Future<void> testDartdoc() async {
  var launcher = SubprocessLauncher('test-dartdoc');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--output',
    _dartdocDocsPath,
    '--no-link-to-remote',
  ]);
  expectFileContains(p.join(_dartdocDocsPath, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  var object = RegExp('<li>Object</li>', multiLine: true);
  expectFileContains(
      p.join(_dartdocDocsPath, 'dartdoc', 'ModelElement-class.html'), [object]);
}

@Task('Generate docs for dartdoc with remote linking')
Future<void> testDartdocRemote() async {
  var launcher = SubprocessLauncher('test-dartdoc-remote');
  var object = RegExp(
      '<a href="https://api.dart.dev/(dev|stable|beta|edge)/[^/]*/dart-core/Object-class.html">Object</a>',
      multiLine: true);
  await launcher.runStreamed(Platform.resolvedExecutable,
      ['--enable-asserts', 'bin/dartdoc.dart', '--output', _dartdocDocsPath]);
  expectFileContains(p.join(_dartdocDocsPath, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  expectFileContains(
      p.join(_dartdocDocsPath, 'dartdoc', 'ModelElement-class.html'), [object]);
}

@Task('serve docs for a package that requires flutter with remote linking')
@Depends(buildDartdocFlutterPluginDocs)
Future<void> serveDartdocFlutterPluginDocs() async {
  await _serveDocsFrom(
      _pluginPackageDocsPath, 8005, 'serve-dartdoc-flutter-plugin-docs');
}

Future<WarningsCollection> _buildDartdocFlutterPluginDocs() async {
  var flutterRepo = await FlutterRepo.fromExistingFlutterRepo(
      await cleanFlutterRepo, 'docs-flutter-plugin');

  await flutterRepo.launcher.runStreamed(flutterRepo.cacheDart, ['pub', 'get'],
      workingDirectory: testPackageFlutterPlugin.path);

  return jsonMessageIterableToWarnings(
    await flutterRepo.launcher.runStreamed(
      flutterRepo.cacheDart,
      [
        '--enable-asserts',
        p.join(Directory.current.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--link-to-remote',
        '--output',
        _pluginPackageDocsPath
      ],
      workingDirectory: testPackageFlutterPlugin.path,
    ),
    _pluginPackageDocsPath,
    defaultPubCache,
    'HEAD',
  );
}

@Task('Build docs for a package that requires flutter with remote linking')
@Depends(clean)
Future<void> buildDartdocFlutterPluginDocs() async {
  await _buildDartdocFlutterPluginDocs();
}

@Task('Verify docs for a package that requires flutter with remote linking')
Future<void> testDartdocFlutterPlugin() async {
  var warnings = await _buildDartdocFlutterPluginDocs();
  if (warnings.warningKeyCounts.isNotEmpty) {
    fail('No warnings should exist in : ${warnings.warningKeyCounts}');
  }
  // Verify that links to Dart SDK and Flutter SDK go to the flutter site.
  expectFileContains(
      p.join(_pluginPackageDocsPath, 'testlib', 'MyAwesomeWidget-class.html'), [
    '<a href="https://api.flutter.dev/flutter/widgets/Widget-class.html">Widget</a>',
    '<a href="https://api.flutter.dev/flutter/dart-core/Object-class.html">Object</a>'
  ]);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
void validateSdkDocs() {
  const expectedLibCounts = 0;
  const expectedSubLibCount = {18, 19};
  const expectedTotalCount = {18, 19};
  var indexHtml = joinFile(_sdkDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) {
    fail('no index.html found for SDK docs');
  }
  log('found index.html');
  var indexContents = indexHtml.readAsStringSync();
  var foundLibs = _findCount(indexContents, '  <li><a href="dart-');
  if (expectedLibCounts != foundLibs) {
    fail('expected $expectedLibCounts "dart:" index.html entries, found '
        '$foundLibs');
  }
  log('$foundLibs index.html dart: entries found');

  var foundSubLibs =
      _findCount(indexContents, '<li class="section-subitem"><a href="dart-');
  if (!expectedSubLibCount.contains(foundSubLibs)) {
    fail('expected $expectedSubLibCount "dart:" index.html entries in '
        'categories, found $foundSubLibs');
  }
  log('$foundSubLibs index.html dart: entries in categories found');

  // check for the existence of certain files/dirs
  var libsLength =
      _sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (!expectedTotalCount.contains(libsLength)) {
    fail('docs not generated for all the SDK libraries, '
        'expected $expectedTotalCount directories, generated $libsLength directories');
  }
  log('$libsLength dart: libraries found');

  var futureConstFile =
      joinFile(_sdkDocsDir, [p.join('dart-async', 'Future', 'Future.html')]);
  if (!futureConstFile.existsSync()) {
    fail('no Future.html found for dart:async Future constructor');
  }
  log('found Future.async ctor');
}

int _findCount(String str, String match) {
  var count = 0;
  var index = str.indexOf(match);
  while (index != -1) {
    count++;
    index = str.indexOf(match, index + match.length);
  }
  return count;
}

Future<String> _calcDartFilesSig(Directory dir) async {
  final digest = await _dartFileLines(dir)
      .transform(utf8.encoder)
      .transform(crypto.md5)
      .single;

  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();
}

/// Yields all of the trimmed lines of all of the `.dart` files in [dir].
Stream<String> _dartFileLines(Directory dir) async* {
  final files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => compareAsciiLowerCase(a.path, b.path));

  for (var file in files) {
    for (var line in file.readAsLinesSync()) {
      yield line.trim();
    }
  }
}
