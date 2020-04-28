// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' hide ProcessException;

import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:grinder/grinder.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import '../test/src/utils.dart';

void main([List<String> args]) => grind(args);

/// Thrown on failure to find something in a file.
class GrindTestFailure {
  final String message;

  GrindTestFailure(this.message);
}

/// Kind of an inefficient grepper for now.
void expectFileContains(String path, List<Pattern> items) {
  var source = File(path);
  if (!source.existsSync()) {
    throw GrindTestFailure('file not found: ${path}');
  }
  for (var item in items) {
    if (!File(path).readAsStringSync().contains(item)) {
      throw GrindTestFailure('Can not find ${item} in ${path}');
    }
  }
}

/// The pub cache inherited by grinder.
final String defaultPubCache =
    Platform.environment['PUB_CACHE'] ?? resolveTildePath('~/.pub-cache');

/// Run no more than the number of processors available in parallel.
final MultiFutureTracker testFutures =
    MultiFutureTracker(Platform.numberOfProcessors);

// Directory.systemTemp is not a constant.  So wrap it.
Directory createTempSync(String prefix) =>
    Directory.systemTemp.createTempSync(prefix);

/// Global so that the lock is retained for the life of the process.
Future<void> _lockFuture;
Completer<FlutterRepo> _cleanFlutterRepo;

/// Returns true if we need to replace the existing flutter.  We never release
/// this lock until the program exits to prevent edge case runs from
/// spontaneously deciding to download a new Flutter SDK in the middle of a run.
Future<FlutterRepo> get cleanFlutterRepo async {
  if (_cleanFlutterRepo == null) {
    // No await is allowed between check of _cleanFlutterRepo and its assignment,
    // to prevent reentering this function.
    _cleanFlutterRepo = Completer();

    // Figure out where the repository is supposed to be and lock updates for
    // it.
    await cleanFlutterDir.parent.create(recursive: true);
    assert(_lockFuture == null);
    _lockFuture = File(path.join(cleanFlutterDir.parent.path, 'lock'))
        .openSync(mode: FileMode.write)
        .lock();
    await _lockFuture;
    var lastSynced = File(path.join(cleanFlutterDir.parent.path, 'lastSynced'));
    var newRepo = FlutterRepo.fromPath(cleanFlutterDir.path, {}, 'clean');

    // We have a repository, but is it up to date?
    DateTime lastSyncedTime;
    if (lastSynced.existsSync()) {
      lastSyncedTime = DateTime.fromMillisecondsSinceEpoch(
          int.parse(lastSynced.readAsStringSync()));
    }
    if (lastSyncedTime == null ||
        DateTime.now().difference(lastSyncedTime) > Duration(hours: 4)) {
      // Rebuild the repository.
      if (cleanFlutterDir.existsSync()) {
        cleanFlutterDir.deleteSync(recursive: true);
      }
      cleanFlutterDir.createSync(recursive: true);
      await newRepo._init();
      await lastSynced
          .writeAsString((DateTime.now()).millisecondsSinceEpoch.toString());
    }
    _cleanFlutterRepo.complete(newRepo);
  }
  return _cleanFlutterRepo.future;
}

Directory _dartdocDocsDir;

Directory get dartdocDocsDir => _dartdocDocsDir ??= createTempSync('dartdoc');

Directory _dartdocDocsDirRemote;

Directory get dartdocDocsDirRemote =>
    _dartdocDocsDirRemote ??= createTempSync('dartdoc_remote');

Directory _sdkDocsDir;

Directory get sdkDocsDir => _sdkDocsDir ??= createTempSync('sdkdocs');

Directory cleanFlutterDir = Directory(
    path.join(resolveTildePath('~/.dartdoc_grinder'), 'cleanFlutter'));

Directory _flutterDir;

Directory get flutterDir => _flutterDir ??= createTempSync('flutter');

Directory get testPackage =>
    Directory(path.joinAll(['testing', 'test_package']));

Directory get pluginPackage =>
    Directory(path.joinAll(['testing', 'test_package_flutter_plugin']));

Directory _testPackageDocsDir;

Directory get testPackageDocsDir =>
    _testPackageDocsDir ??= createTempSync('test_package');

Directory _pluginPackageDocsDir;

Directory get pluginPackageDocsDir =>
    _pluginPackageDocsDir ??= createTempSync('test_package_flutter_plugin');

/// Version of dartdoc we should use when making comparisons.
String get dartdocOriginalBranch {
  var branch = 'master';
  if (Platform.environment.containsKey('DARTDOC_ORIGINAL')) {
    branch = Platform.environment['DARTDOC_ORIGINAL'];
    log('using branch/tag: $branch for comparison from \$DARTDOC_ORIGINAL');
  }
  return branch;
}

List<String> _extraDartdocParams;

/// If DARTDOC_PARAMS is set, add given parameters to the list.
List<String> get extraDartdocParameters {
  if (_extraDartdocParams == null) {
    var whitespace = RegExp(r'\s+');
    _extraDartdocParams = [];
    if (Platform.environment.containsKey('DARTDOC_PARAMS')) {
      _extraDartdocParams
          .addAll(Platform.environment['DARTDOC_PARAMS'].split(whitespace));
    }
  }
  return _extraDartdocParams;
}

final Directory flutterDirDevTools =
    Directory(path.join(flutterDir.path, 'dev', 'tools'));

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> _createThrowawayPubCache() {
  var pubCache = Directory.systemTemp.createTempSync('pubcache');
  var pubCacheBin = Directory(path.join(pubCache.path, 'bin'));
  pubCacheBin.createSync();
  return Map.fromIterables([
    'PUB_CACHE',
    'PATH'
  ], [
    pubCache.path,
    [pubCacheBin.path, Platform.environment['PATH']].join(':')
  ]);
}

// TODO(jcollins-g): make a library out of this
final FilePath _pkgDir = FilePath('lib/src/third_party/pkg');
final FilePath _mustache4dartDir =
    FilePath('lib/src/third_party/pkg/mustache4dart');
final RegExp _mustache4dartPatches =
    RegExp(r'^\d\d\d-mustache4dart-.*[.]patch$');

@Task('Update third_party forks')
void updateThirdParty() async {
  run('rm', arguments: ['-rf', _mustache4dartDir.path]);
  Directory(_pkgDir.path).createSync(recursive: true);
  run('git', arguments: [
    'clone',
    '--branch',
    'v2.1.2',
    '--depth=1',
    'git@github.com:valotas/mustache4dart',
    _mustache4dartDir.path,
  ]);
  run('rm', arguments: ['-rf', path.join(_mustache4dartDir.path, '.git')]);
  for (var patchFileName in Directory(_pkgDir.path)
      .listSync()
      .map((e) => path.basename(e.path))
      .where((String filename) => _mustache4dartPatches.hasMatch(filename))
      .toList()
        ..sort()) {
    run('patch',
        arguments: [
          '-p0',
          '-i',
          patchFileName,
        ],
        workingDirectory: _pkgDir.path);
  }
}

@Task('Analyze dartdoc to ensure there are no errors and warnings')
void analyze() async {
  await SubprocessLauncher('analyze').runStreamed(
    sdkBin('dartanalyzer'),
    [
      '--fatal-infos',
      '--options',
      'analysis_options_presubmit.yaml',
      'bin',
      'lib',
      'test',
      'tool',
    ],
  );
}

@Task('Check for dartfmt cleanliness')
void dartfmt() async {
  if (Platform.version.contains('dev')) {
    var filesToFix = <String>[];
    // Filter out test packages as they always have strange formatting.
    // Passing parameters to dartfmt for directories to search results in
    // filenames being stripped of the dirname so we have to filter here.
    void addFileToFix(String fileName) {
      if (path.split(fileName).first == 'testing') return;
      filesToFix.add(fileName);
    }

    log('Validating dartfmt with version ${Platform.version}');
    await SubprocessLauncher('dartfmt').runStreamed(
        sdkBin('dartfmt'),
        [
          '-n',
          '.',
        ],
        perLine: addFileToFix);
    if (filesToFix.isNotEmpty) {
      fail(
          'dartfmt found files needing reformatting. Use this command to reformat:\n'
          'dartfmt -w ${filesToFix.map((f) => "\'$f\'").join(' ')}');
    }
  } else {
    log('Skipping dartfmt check, requires latest dev version of SDK');
  }
}

@Task('Run quick presubmit checks.')
@Depends(
  analyze,
  checkBuild,
  smokeTest,
  dartfmt, /*tryPublish*/
)
void presubmit() => null;

@Task('Run long tests, self-test dartdoc, and run the publish test')
@Depends(presubmit, test, testDartdoc)
void buildbot() => null;

@Task('Generate docs for the Dart SDK')
Future buildSdkDocs() async {
  log('building SDK docs');
  await _buildSdkDocs(sdkDocsDir.path, Future.value(Directory.current.path));
}

class WarningsCollection {
  final String tempDir;
  final Map<String, int> warningKeyCounts;
  final String branch;
  final String pubCachePath;

  WarningsCollection(this.tempDir, this.pubCachePath, this.branch)
      : warningKeyCounts = {};

  static const String kPubCachePathReplacement = '_xxxPubDirectoryxxx_';
  static const String kTempDirReplacement = '_xxxTempDirectoryxxx_';

  String _toKey(String text) {
    var key = text.replaceAll(tempDir, kTempDirReplacement);
    if (pubCachePath != null) {
      key = key.replaceAll(pubCachePath, kPubCachePathReplacement);
    }
    return key;
  }

  String _fromKey(String text) {
    var key = text.replaceAll(kTempDirReplacement, tempDir);
    if (pubCachePath != null) {
      key = key.replaceAll(kPubCachePathReplacement, pubCachePath);
    }
    return key;
  }

  void add(String text) {
    var key = _toKey(text);
    warningKeyCounts.putIfAbsent(key, () => 0);
    warningKeyCounts[key]++;
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
      onlyOriginal.forEach((key) => printBuffer.writeln(_fromKey(key)));
    }
    if (onlyCurrent.isNotEmpty) {
      printBuffer.writeln(
          '*** $title : ${onlyCurrent.length} new warnings in ${current.branch}, missing in $branch');
      onlyCurrent.forEach((key) => printBuffer.writeln(current._fromKey(key)));
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
WarningsCollection jsonMessageIterableToWarnings(Iterable<Map> messageIterable,
    String tempPath, String pubDir, String branch) {
  var warningTexts = WarningsCollection(tempPath, pubDir, branch);
  if (messageIterable == null) return warningTexts;
  for (Map<String, dynamic> message in messageIterable) {
    if (message.containsKey('level') &&
        message['level'] == 'WARNING' &&
        message.containsKey('data')) {
      warningTexts.add(message['data']['text']);
    }
  }
  return warningTexts;
}

@Task('Display delta in SDK warnings')
Future compareSdkWarnings() async {
  var originalDartdocSdkDocs =
      Directory.systemTemp.createTempSync('dartdoc-comparison-sdkdocs');
  Future originalDartdoc = createComparisonDartdoc();
  Future currentDartdocSdkBuild = _buildSdkDocs(
      sdkDocsDir.path, Future.value(Directory.current.path), 'current');
  Future originalDartdocSdkBuild =
      _buildSdkDocs(originalDartdocSdkDocs.path, originalDartdoc, 'original');
  var currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocSdkBuild, sdkDocsDir.absolute.path, null, 'HEAD');
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
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: dartdocClean.path);
  return dartdocClean.path;
}

/// Helper function to create a clean version of dartdoc (based on the current
/// directory, assumed to be a git repository), configured to use the head
/// version of the Dart SDK for analyzer, front-end, and kernel.
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
  var dartdocPubspec = File(path.join(dartdocSdk.path, 'pubspec.yaml'));
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
''', mode: FileMode.append);
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: dartdocSdk.path);
  return dartdocSdk.path;
}

@Task('Run grind tasks with the analyzer SDK.')
Future<void> testWithAnalyzerSdk() async {
  var launcher = SubprocessLauncher('test-with-analyzer-sdk');
  var sdkDartdoc = await createSdkDartdoc();
  var defaultGrindParameter =
      Platform.environment['DARTDOC_GRIND_STEP'] ?? 'test';
  await launcher.runStreamed(
      sdkBin('pub'), ['run', 'grinder', defaultGrindParameter],
      workingDirectory: sdkDartdoc);
}

Future<List<Map>> _buildSdkDocs(String sdkDocsPath, Future<String> futureCwd,
    [String label]) async {
  label ??= '';
  if (label != '') label = '-$label';
  var launcher = SubprocessLauncher('build-sdk-docs$label');
  var cwd = await futureCwd;
  await launcher.runStreamed(sdkBin('pub'), ['get'], workingDirectory: cwd);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        path.join('bin', 'dartdoc.dart'),
        '--output',
        '${sdkDocsPath}',
        '--sdk-docs',
        '--json',
        '--show-progress',
        ...extraDartdocParameters,
      ],
      workingDirectory: cwd);
}

Future<List<Map>> _buildTestPackageDocs(
    String outputDir, Future<String> futureCwd,
    [String label]) async {
  label ??= '';
  if (label != '') label = '-$label';
  var launcher = SubprocessLauncher('build-test-package-docs$label');
  Future testPackagePubGet = launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: testPackage.absolute.path);
  var cwd = await futureCwd;
  Future dartdocPubGet =
      launcher.runStreamed(sdkBin('pub'), ['get'], workingDirectory: cwd);
  await Future.wait([testPackagePubGet, dartdocPubGet]);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        path.join(cwd, 'bin', 'dartdoc.dart'),
        '--output',
        outputDir,
        '--example-path-prefix',
        'examples',
        '--include-source',
        '--json',
        '--link-to-remote',
        '--pretty-index-json',
        ...extraDartdocParameters,
      ],
      workingDirectory: testPackage.absolute.path);
}

@Task('Build generated test package docs (with inherited docs and source code)')
@Depends(clean)
Future<void> buildTestPackageDocs() async {
  await _buildTestPackageDocs(
      testPackageDocsDir.absolute.path, Future.value(Directory.current.path));
}

@Task('Serve test package docs locally with dhttpd on port 8002')
@Depends(buildTestPackageDocs)
Future<void> serveTestPackageDocs() async {
  log('launching dhttpd on port 8002 for SDK');
  var launcher = SubprocessLauncher('serve-test-package-docs');
  await launcher.runStreamed(sdkBin('pub'), [
    'run',
    'dhttpd',
    '--port',
    '8002',
    '--path',
    '${testPackageDocsDir.absolute.path}',
  ]);
}

Future<void> _serveDocsFrom(String servePath, int port, String context) async {
  log('launching dhttpd on port $port for $context');
  var launcher = SubprocessLauncher(context);
  await launcher.runStreamed(sdkBin('pub'), ['get']);
  await launcher.runStreamed(sdkBin('pub'), ['global', 'activate', 'dhttpd']);
  await launcher.runStreamed(
      sdkBin('pub'), ['run', 'dhttpd', '--port', '$port', '--path', servePath]);
}

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
@Depends(buildSdkDocs)
Future<void> serveSdkDocs() async {
  log('launching dhttpd on port 8000 for SDK');
  var launcher = SubprocessLauncher('serve-sdk-docs');
  await launcher.runStreamed(sdkBin('pub'), [
    'run',
    'dhttpd',
    '--port',
    '8000',
    '--path',
    '${sdkDocsDir.path}',
  ]);
}

@Task('Compare warnings in Dartdoc for Flutter')
Future<void> compareFlutterWarnings() async {
  var originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  Future originalDartdoc = createComparisonDartdoc();
  var envCurrent = _createThrowawayPubCache();
  var envOriginal = _createThrowawayPubCache();
  Future currentDartdocFlutterBuild = _buildFlutterDocs(flutterDir.path,
      Future.value(Directory.current.path), envCurrent, 'docs-current');
  Future originalDartdocFlutterBuild = _buildFlutterDocs(
      originalDartdocFlutter.path,
      originalDartdoc,
      envOriginal,
      'docs-original');
  var currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocFlutterBuild,
      flutterDir.absolute.path,
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
    await launcher.runStreamed(sdkBin('pub'), ['get']);
    Future original = launcher.runStreamed(sdkBin('pub'), [
      'run',
      'dhttpd',
      '--port',
      '9000',
      '--path',
      path.join(originalDartdocFlutter.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    Future current = launcher.runStreamed(sdkBin('pub'), [
      'run',
      'dhttpd',
      '--port',
      '9001',
      '--path',
      path.join(flutterDir.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    await Future.wait([original, current]);
  }
}

@Task('Serve generated Flutter docs locally with dhttpd on port 8001')
@Depends(buildFlutterDocs)
Future<void> serveFlutterDocs() async {
  log('launching dhttpd on port 8001 for Flutter');
  var launcher = SubprocessLauncher('serve-flutter-docs');
  await launcher.runStreamed(sdkBin('pub'), ['get']);
  await launcher.runStreamed(sdkBin('pub'), [
    'run',
    'dhttpd',
    '--port',
    '8001',
    '--path',
    path.join(flutterDir.path, 'dev', 'docs', 'doc'),
  ]);
}

@Task('Validate flutter docs')
@Depends(buildFlutterDocs, testDartdocFlutterPlugin)
void validateFlutterDocs() {}

@Task('Build flutter docs')
Future<void> buildFlutterDocs() async {
  log('building flutter docs into: $flutterDir');
  var env = _createThrowawayPubCache();
  await _buildFlutterDocs(
      flutterDir.path, Future.value(Directory.current.path), env, 'docs');
  var index =
      File(path.join(flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
          .readAsStringSync();
  stdout.write(index);
}

/// A class wrapping a flutter SDK.
class FlutterRepo {
  final String flutterPath;
  final Map<String, String> env;
  final String bin = path.join('bin', 'flutter');

  FlutterRepo._(this.flutterPath, this.env, String label) {
    cacheDart =
        path.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
    cachePub = path.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'pub');
    env['PATH'] =
        '${path.join(path.canonicalize(flutterPath), "bin")}:${env['PATH'] ?? Platform.environment['PATH']}';
    env['FLUTTER_ROOT'] = flutterPath;
    launcher =
        SubprocessLauncher('flutter${label == null ? "" : "-$label"}', env);
  }

  Future<void> _init() async {
    Directory(flutterPath).createSync(recursive: true);
    await launcher.runStreamed(
        'git', ['clone', 'https://github.com/flutter/flutter.git', '.'],
        workingDirectory: flutterPath);
    await launcher.runStreamed(
      bin,
      ['--version'],
      workingDirectory: flutterPath,
    );
    await launcher.runStreamed(
      bin,
      ['precache'],
      workingDirectory: flutterPath,
    );
    await launcher.runStreamed(
      bin,
      ['update-packages'],
      workingDirectory: flutterPath,
    );
  }

  factory FlutterRepo.fromPath(String flutterPath, Map<String, String> env,
      [String label]) {
    var flutterRepo = FlutterRepo._(flutterPath, env, label);
    return flutterRepo;
  }

  /// Copy an existing, initialized flutter repo.
  static Future<FlutterRepo> copyFromExistingFlutterRepo(
      FlutterRepo origRepo, String flutterPath, Map<String, String> env,
      [String label]) async {
    await copyPath(origRepo.flutterPath, flutterPath);
    var flutterRepo = FlutterRepo._(flutterPath, env, label);
    return flutterRepo;
  }

  /// Doesn't actually copy the existing repo; use for read-only operations only.
  static Future<FlutterRepo> fromExistingFlutterRepo(FlutterRepo origRepo,
      [String label]) async {
    var flutterRepo = FlutterRepo._(origRepo.flutterPath, {}, label);
    return flutterRepo;
  }

  String cacheDart;
  String cachePub;
  SubprocessLauncher launcher;
}

Future<List<Map>> _buildFlutterDocs(
    String flutterPath, Future<String> futureCwd, Map<String, String> env,
    [String label]) async {
  var flutterRepo = await FlutterRepo.copyFromExistingFlutterRepo(
      await cleanFlutterRepo, flutterPath, env, label);
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cachePub,
    ['get'],
    workingDirectory: path.join(flutterPath, 'dev', 'tools'),
  );
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cachePub,
    ['get'],
    workingDirectory: path.join(flutterPath, 'dev', 'snippets'),
  );
  await flutterRepo.launcher.runStreamed(
      flutterRepo.cachePub, ['global', 'activate', '-spath', '.'],
      workingDirectory: await futureCwd);
  return await flutterRepo.launcher.runStreamed(
    flutterRepo.cacheDart,
    [path.join('dev', 'tools', 'dartdoc.dart'), '-c', '--json'],
    workingDirectory: flutterPath,
  );
}

/// Returns the directory in which we generated documentation.
Future<String> _buildPubPackageDocs(
    String pubPackageName, List<String> dartdocParameters,
    [String version, String label]) async {
  var env = _createThrowawayPubCache();
  var launcher = SubprocessLauncher(
      'build-${pubPackageName}${version == null ? "" : "-$version"}${label == null ? "" : "-$label"}',
      env);
  var args = <String>['cache', 'add'];
  if (version != null) args.addAll(<String>['-v', version]);
  args.add(pubPackageName);
  await launcher.runStreamed('pub', args);
  var cache =
      Directory(path.join(env['PUB_CACHE'], 'hosted', 'pub.dartlang.org'));
  Directory pubPackageDir =
      cache.listSync().firstWhere((e) => e.path.contains(pubPackageName));
  if (PackageMeta.fromDir(pubPackageDir).requiresFlutter) {
    var flutterRepo =
        await FlutterRepo.fromExistingFlutterRepo(await cleanFlutterRepo);
    await launcher.runStreamed(flutterRepo.cachePub, ['get'],
        environment: flutterRepo.env,
        workingDirectory: pubPackageDir.absolute.path);
    await launcher.runStreamed(
        flutterRepo.cacheDart,
        [
          '--enable-asserts',
          path.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
          '--json',
          '--link-to-remote',
          '--show-progress',
          ...dartdocParameters,
        ],
        environment: flutterRepo.env,
        workingDirectory: pubPackageDir.absolute.path);
  } else {
    await launcher.runStreamed('pub', ['get'],
        workingDirectory: pubPackageDir.absolute.path);
    await launcher.runStreamed(
        Platform.resolvedExecutable,
        [
          '--enable-asserts',
          path.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
          '--json',
          '--link-to-remote',
          '--show-progress',
          ...dartdocParameters,
        ],
        workingDirectory: pubPackageDir.absolute.path);
  }
  return path.join(pubPackageDir.absolute.path, 'doc', 'api');
}

@Task(
    'Build an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
Future<String> buildPubPackage() async {
  assert(Platform.environment.containsKey('PACKAGE_NAME'));
  var packageName = Platform.environment['PACKAGE_NAME'];
  var version = Platform.environment['PACKAGE_VERSION'];
  return _buildPubPackageDocs(packageName, extraDartdocParameters, version);
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

  if (!changelog.readAsLinesSync().contains('## ${version}')) {
    fail('ERROR: CHANGELOG.md does not mention version ${version}');
  }
}

String _getPackageVersion() {
  var pubspec = File('pubspec.yaml');
  var yamlDoc;
  if (pubspec.existsSync()) {
    yamlDoc = yaml.loadYaml(pubspec.readAsStringSync());
  }
  if (yamlDoc == null) {
    fail('Cannot find pubspec.yaml in ${Directory.current}');
  }
  var version = yamlDoc['version'];
  return version;
}

@Task('Rebuild generated files')
Future<void> build() async {
  var launcher = SubprocessLauncher('build');
  await launcher.runStreamed(sdkBin('pub'),
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);

  // TODO(jcollins-g): port to build system?
  var version = _getPackageVersion();
  var dartdoc_options = File('dartdoc_options.yaml');
  await dartdoc_options.writeAsString('''dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/dartdoc/blob/v${version}/%f%#L%l%'
''');
}

/// Paths in this list are relative to lib/.
final _generated_files_list = <String>[
  '../dartdoc_options.yaml',
  'src/generator/html_resources.g.dart',
  'src/version.dart',
].map((s) => path.joinAll(path.posix.split(s)));

@Task('Verify generated files are up to date')
Future<void> checkBuild() async {
  var originalFileContents = <String, String>{};
  var differentFiles = <String>[];

  // Load original file contents into memory before running the builder;
  // it modifies them in place.
  for (var relPath in _generated_files_list) {
    var origPath = path.joinAll(['lib', relPath]);
    var oldVersion = File(origPath);
    if (oldVersion.existsSync()) {
      originalFileContents[relPath] = oldVersion.readAsStringSync();
    }
  }

  await build();
  for (var relPath in _generated_files_list) {
    var newVersion = File(path.join('lib', relPath));
    if (!await newVersion.exists()) {
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
        '  ${differentFiles.map((f) => path.join('lib', f)).join("\n  ")}\n'
        'Rebuild them with "grind build" and check the results in.');
  }
}

@Task('Dry run of publish to pub.dartlang')
@Depends(checkChangelogHasVersion)
Future<void> tryPublish() async {
  var launcher = SubprocessLauncher('try-publish');
  await launcher.runStreamed(sdkBin('pub'), ['publish', '-n']);
}

@Task('Run a smoke test, only')
@Depends(clean)
Future<void> smokeTest() async {
  await testDart2(smokeTestFiles);
  await testFutures.wait();
}

@Task('Run non-smoke tests, only')
@Depends(clean)
Future<void> longTest() async {
  await testDart2(testFiles);
  await testFutures.wait();
}

@Task('Run all the tests.')
@Depends(clean)
Future<void> test() async {
  await testDart2(smokeTestFiles.followedBy(testFiles));
  await testFutures.wait();
}

@Task('Clean up pub data from test directories')
Future<void> clean() async {
  var toDelete = nonRootPubData;
  toDelete.forEach((e) => e.deleteSync(recursive: true));
}

Iterable<FileSystemEntity> get nonRootPubData {
  // This involves deleting things, so be careful.
  if (!File(path.join('tool', 'grind.dart')).existsSync()) {
    throw FileSystemException('wrong CWD, run from root of dartdoc package');
  }
  return Directory('.')
      .listSync(recursive: true)
      .where((e) => path.dirname(e.path) != '.')
      .where((e) => <String>['.dart_tool', '.packages', 'pubspec.lock']
          .contains(path.basename(e.path)));
}

List<File> get smokeTestFiles => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((e) => path.basename(e.path) == 'model_test.dart')
    .toList();

List<File> get testFiles => Directory('test')
    .listSync(recursive: true)
    .whereType<File>()
    .where((e) => e.path.endsWith('test.dart'))
    .where((e) => path.basename(e.path) != 'model_test.dart')
    .toList();

Future<void> testDart2(Iterable<File> tests) async {
  var parameters = <String>['--enable-asserts'];

  for (var dartFile in tests) {
    await testFutures.addFutureFromClosure(() =>
        CoverageSubprocessLauncher('dart2-${path.basename(dartFile.path)}')
            .runStreamed(Platform.resolvedExecutable,
                <String>[...parameters, dartFile.path]));
  }

  return CoverageSubprocessLauncher.generateCoverageToFile(File('lcov.info'));
}

@Task('Generate docs for dartdoc without link-to-remote')
Future<void> testDartdoc() async {
  var launcher = SubprocessLauncher('test-dartdoc');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--output',
    dartdocDocsDir.path,
    '--no-link-to-remote',
  ]);
  expectFileContains(path.join(dartdocDocsDir.path, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  var object = RegExp('<li>Object</li>', multiLine: true);
  expectFileContains(
      path.join(dartdocDocsDir.path, 'dartdoc', 'ModelElement-class.html'),
      [object]);
}

@Task('Generate docs for dartdoc with remote linking')
Future<void> testDartdocRemote() async {
  var launcher = SubprocessLauncher('test-dartdoc-remote');
  var object = RegExp(
      '<a href="https://api.dart.dev/(dev|stable|beta|edge)/[^/]*/dart-core/Object-class.html">Object</a>',
      multiLine: true);
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--output',
    dartdocDocsDir.path
  ]);
  expectFileContains(path.join(dartdocDocsDir.path, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  expectFileContains(
      path.join(dartdocDocsDir.path, 'dartdoc', 'ModelElement-class.html'),
      [object]);
}

@Task('serve docs for a package that requires flutter with remote linking')
@Depends(buildDartdocFlutterPluginDocs)
Future<void> serveDartdocFlutterPluginDocs() async {
  await _serveDocsFrom(
      pluginPackageDocsDir.path, 8005, 'serve-dartdoc-flutter-plugin-docs');
}

Future<WarningsCollection> _buildDartdocFlutterPluginDocs() async {
  var flutterRepo = await FlutterRepo.fromExistingFlutterRepo(
      await cleanFlutterRepo, 'docs-flutter-plugin');

  return jsonMessageIterableToWarnings(
      await flutterRepo.launcher.runStreamed(
          flutterRepo.cacheDart,
          [
            '--enable-asserts',
            path.join(Directory.current.path, 'bin', 'dartdoc.dart'),
            '--exclude-packages',
            'Dart', // TODO(jcollins-g): dart-lang/dartdoc#1431
            '--json',
            '--link-to-remote',
            '--output',
            pluginPackageDocsDir.path
          ],
          workingDirectory: pluginPackage.path),
      pluginPackageDocsDir.path,
      defaultPubCache,
      'HEAD');
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
      path.join(
          pluginPackageDocsDir.path, 'testlib', 'MyAwesomeWidget-class.html'),
      [
        '<a href="https://api.flutter.dev/flutter/widgets/Widget-class.html">Widget</a>',
        '<a href="https://api.flutter.dev/flutter/dart-core/Object-class.html">Object</a>'
      ]);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
void validateSdkDocs() {
  // TODO(jcollins-g): Remove flexibility in library counts once dev build
  // includes https://dart-review.googlesource.com/c/sdk/+/93160
  const expectedLibCounts = [0, 1];
  const expectedSubLibCount = [19, 20];
  const expectedTotalCount = [19, 20];
  var indexHtml = joinFile(sdkDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) {
    fail('no index.html found for SDK docs');
  }
  log('found index.html');
  var indexContents = indexHtml.readAsStringSync();
  var foundLibs = _findCount(indexContents, '  <li><a href="dart-');
  if (!expectedLibCounts.contains(foundLibs)) {
    fail(
        'expected $expectedTotalCount dart: index.html entries, found $foundLibs');
  }
  log('$foundLibs index.html dart: entries found');

  var foundSubLibs =
      _findCount(indexContents, '<li class="section-subitem"><a href="dart-');
  if (!expectedSubLibCount.contains(foundSubLibs)) {
    fail(
        'expected $expectedSubLibCount dart: index.html entries in categories, found $foundSubLibs');
  }
  log('$foundSubLibs index.html dart: entries in categories found');

  // check for the existence of certain files/dirs
  var libsLength =
      sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (!expectedTotalCount.contains(libsLength)) {
    fail('docs not generated for all the SDK libraries, '
        'expected ${expectedTotalCount + expectedTotalCount} directories, generated $libsLength directories');
  }
  log('$libsLength dart: libraries found');

  var futureConstFile =
      joinFile(sdkDocsDir, [path.join('dart-async', 'Future', 'Future.html')]);
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
