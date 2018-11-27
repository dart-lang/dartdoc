// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' hide ProcessException;

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:grinder/grinder.dart';
import 'package:io/io.dart';
import 'package:path/path.dart' as pathLib;
import 'package:yaml/yaml.dart' as yaml;

void main([List<String> args]) => grind(args);

/// Thrown on failure to find something in a file.
class GrindTestFailure {
  final String message;
  GrindTestFailure(this.message);
}

/// Kind of an inefficient grepper for now.
void expectFileContains(String path, List<Pattern> items) {
  File source = new File(path);
  if (!source.existsSync())
    throw new GrindTestFailure('file not found: ${path}');
  for (Pattern item in items) {
    if (!new File(path).readAsStringSync().contains(item)) {
      throw new GrindTestFailure('Can not find ${item} in ${path}');
    }
  }
}

/// The pub cache inherited by grinder.
final String defaultPubCache =
    Platform.environment['PUB_CACHE'] ?? resolveTildePath('~/.pub-cache');

/// Run no more than the number of processors available in parallel.
final MultiFutureTracker testFutures = new MultiFutureTracker(
    Platform.environment.containsKey('TRAVIS')
        ? 1
        : Platform.numberOfProcessors);

// Directory.systemTemp is not a constant.  So wrap it.
Directory createTempSync(String prefix) =>
    Directory.systemTemp.createTempSync(prefix);

final Memoizer tempdirsCache = new Memoizer();

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
    _cleanFlutterRepo = new Completer();

    // Figure out where the repository is supposed to be and lock updates for
    // it.
    await cleanFlutterDir.parent.create(recursive: true);
    assert(_lockFuture == null);
    _lockFuture = new File(pathLib.join(cleanFlutterDir.parent.path, 'lock'))
        .openSync(mode: FileMode.write)
        .lock();
    await _lockFuture;
    File lastSynced =
        new File(pathLib.join(cleanFlutterDir.parent.path, 'lastSynced'));
    FlutterRepo newRepo =
        new FlutterRepo.fromPath(cleanFlutterDir.path, {}, 'clean');

    // We have a repository, but is it up to date?
    DateTime lastSyncedTime;
    if (lastSynced.existsSync()) {
      lastSyncedTime = new DateTime.fromMillisecondsSinceEpoch(
          int.parse(lastSynced.readAsStringSync()));
    }
    if (lastSyncedTime == null ||
        new DateTime.now().difference(lastSyncedTime) >
            new Duration(hours: 4)) {
      // Rebuild the repository.
      if (cleanFlutterDir.existsSync()) {
        cleanFlutterDir.deleteSync(recursive: true);
      }
      cleanFlutterDir.createSync(recursive: true);
      await newRepo._init();
      await lastSynced.writeAsString(
          (new DateTime.now()).millisecondsSinceEpoch.toString());
    }
    _cleanFlutterRepo.complete(newRepo);
  }
  return _cleanFlutterRepo.future;
}

Directory get dartdocDocsDir =>
    tempdirsCache.memoized1(createTempSync, 'dartdoc');
Directory get dartdocDocsDirRemote =>
    tempdirsCache.memoized1(createTempSync, 'dartdoc_remote');
Directory get sdkDocsDir => tempdirsCache.memoized1(createTempSync, 'sdkdocs');
Directory cleanFlutterDir = new Directory(
    pathLib.join(resolveTildePath('~/.dartdoc_grinder'), 'cleanFlutter'));
Directory get flutterDir => tempdirsCache.memoized1(createTempSync, 'flutter');
Directory get testPackage =>
    new Directory(pathLib.joinAll(['testing', 'test_package']));
Directory get pluginPackage =>
    new Directory(pathLib.joinAll(['testing', 'test_package_flutter_plugin']));

Directory get testPackageDocsDir =>
    tempdirsCache.memoized1(createTempSync, 'test_package');
Directory get pluginPackageDocsDir =>
    tempdirsCache.memoized1(createTempSync, 'test_package_flutter_plugin');

/// Version of dartdoc we should use when making comparisons.
String get dartdocOriginalBranch {
  String branch = 'master';
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
    final RegExp whitespace = new RegExp(r'\s+');
    _extraDartdocParams = [];
    if (Platform.environment.containsKey('DARTDOC_PARAMS')) {
      _extraDartdocParams
          .addAll(Platform.environment['DARTDOC_PARAMS'].split(whitespace));
    }
  }
  return _extraDartdocParams;
}

final Directory flutterDirDevTools =
    new Directory(pathLib.join(flutterDir.path, 'dev', 'tools'));

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> _createThrowawayPubCache() {
  final Directory pubCache = Directory.systemTemp.createTempSync('pubcache');
  final Directory pubCacheBin =
      new Directory(pathLib.join(pubCache.path, 'bin'));
  pubCacheBin.createSync();
  return new Map.fromIterables([
    'PUB_CACHE',
    'PATH'
  ], [
    pubCache.path,
    [pubCacheBin.path, Platform.environment['PATH']].join(':')
  ]);
}

// TODO(jcollins-g): make a library out of this
final FilePath _pkgDir = new FilePath('lib/src/third_party/pkg');
final FilePath _mustache4dartDir =
    new FilePath('lib/src/third_party/pkg/mustache4dart');
final RegExp _mustache4dartPatches =
    new RegExp(r'^\d\d\d-mustache4dart-.*[.]patch$');
@Task('Update third_party forks')
void updateThirdParty() async {
  run('rm', arguments: ['-rf', _mustache4dartDir.path]);
  new Directory(_pkgDir.path).createSync(recursive: true);
  run('git', arguments: [
    'clone',
    '--branch',
    'v2.1.2',
    '--depth=1',
    'git@github.com:valotas/mustache4dart',
    _mustache4dartDir.path,
  ]);
  run('rm', arguments: ['-rf', pathLib.join(_mustache4dartDir.path, '.git')]);
  for (String patchFileName in new Directory(_pkgDir.path)
      .listSync()
      .map((e) => pathLib.basename(e.path))
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
  await new SubprocessLauncher('analyze').runStreamed(
    sdkBin('dartanalyzer'),
    [
      '--fatal-warnings',
      'bin',
      'lib',
      'test',
      'tool',
    ],
  );
}

@Task('analyze, test, and self-test dartdoc')
@Depends(analyze, checkBuild, test, testDartdoc)
void buildbotNoPublish() => null;

@Task('analyze, test, and self-test dartdoc')
@Depends(analyze, checkBuild, test, testDartdoc, tryPublish)
void buildbot() => null;

@Task('Generate docs for the Dart SDK')
Future buildSdkDocs() async {
  log('building SDK docs');
  await _buildSdkDocs(
      sdkDocsDir.path, new Future.value(Directory.current.path));
}

class WarningsCollection {
  final String tempDir;
  final Map<String, int> warningKeyCounts;
  final String branch;
  final String pubCachePath;
  WarningsCollection(this.tempDir, this.pubCachePath, this.branch)
      : this.warningKeyCounts = new Map() {}

  static const String kPubCachePathReplacement = '_xxxPubDirectoryxxx_';
  static const String kTempDirReplacement = '_xxxTempDirectoryxxx_';

  String _toKey(String text) {
    String key = text.replaceAll(tempDir, kTempDirReplacement);
    if (pubCachePath != null)
      key = key.replaceAll(pubCachePath, kPubCachePathReplacement);
    return key;
  }

  String _fromKey(String text) {
    String key = text.replaceAll(kTempDirReplacement, tempDir);
    if (pubCachePath != null)
      key = key.replaceAll(kPubCachePathReplacement, pubCachePath);
    return key;
  }

  void add(String text) {
    String key = _toKey(text);
    warningKeyCounts.putIfAbsent(key, () => 0);
    warningKeyCounts[key]++;
  }

  /// Output formatter for comparing warnings.  [this] is the original.
  String getPrintableWarningDelta(String title, WarningsCollection current) {
    StringBuffer printBuffer = new StringBuffer();
    Set<String> quantityChangedOuts = new Set();
    Set<String> onlyOriginal = new Set();
    Set<String> onlyCurrent = new Set();
    Set<String> identical = new Set();
    Set<String> allKeys = new Set.from([]
      ..addAll(warningKeyCounts.keys)
      ..addAll(current.warningKeyCounts.keys));

    for (String key in allKeys) {
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
      for (String key in quantityChangedOuts) {
        printBuffer.writeln(
            "* Appeared ${warningKeyCounts[key]} times in $branch, ${current.warningKeyCounts[key]} in ${current.branch}:");
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
  WarningsCollection warningTexts =
      new WarningsCollection(tempPath, pubDir, branch);
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
  Directory originalDartdocSdkDocs =
      Directory.systemTemp.createTempSync('dartdoc-comparison-sdkdocs');
  Future originalDartdoc = createComparisonDartdoc();
  Future currentDartdocSdkBuild = _buildSdkDocs(
      sdkDocsDir.path, new Future.value(Directory.current.path), 'current');
  Future originalDartdocSdkBuild =
      _buildSdkDocs(originalDartdocSdkDocs.path, originalDartdoc, 'original');
  WarningsCollection currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocSdkBuild, sdkDocsDir.absolute.path, null, 'HEAD');
  WarningsCollection originalDartdocWarnings = jsonMessageIterableToWarnings(
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
  var launcher = new SubprocessLauncher('create-comparison-dartdoc');
  Directory dartdocClean =
      Directory.systemTemp.createTempSync('dartdoc-comparison');
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
  var launcher = new SubprocessLauncher('create-sdk-dartdoc');
  Directory dartdocSdk = Directory.systemTemp.createTempSync('dartdoc-sdk');
  await launcher
      .runStreamed('git', ['clone', Directory.current.path, dartdocSdk.path]);
  await launcher.runStreamed('git', ['checkout'],
      workingDirectory: dartdocSdk.path);

  Directory sdkClone = Directory.systemTemp.createTempSync('sdk-checkout');
  await launcher.runStreamed('git', [
    'clone',
    '--branch',
    'analyzer-0.33',
    '--depth',
    '1',
    'https://dart.googlesource.com/sdk.git',
    sdkClone.path
  ]);
  File dartdocPubspec = new File(pathLib.join(dartdocSdk.path, 'pubspec.yaml'));
  List<String> pubspecLines = await dartdocPubspec.readAsLines();
  List<String> pubspecLinesFiltered = [];
  for (String line in pubspecLines) {
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
  front_end:
    path: '${sdkClone.path}/pkg/front_end'
  kernel:
    path: '${sdkClone.path}/pkg/kernel'
''', mode: FileMode.append);
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: dartdocSdk.path);
  return dartdocSdk.path;
}

@Task('Run grind tasks with the analyzer SDK.')
Future<void> testWithAnalyzerSdk() async {
  var launcher = new SubprocessLauncher('test-with-analyzer-sdk');
  var sdkDartdoc = await createSdkDartdoc();
  final String defaultGrindParameter =
      Platform.environment['DARTDOC_GRIND_STEP'] ?? 'test';
  await launcher.runStreamed(
      sdkBin('pub'), ['run', 'grinder', defaultGrindParameter],
      workingDirectory: sdkDartdoc);
}

Future<List<Map>> _buildSdkDocs(String sdkDocsPath, Future<String> futureCwd,
    [String label]) async {
  if (label == null) label = '';
  if (label != '') label = '-$label';
  var launcher = new SubprocessLauncher('build-sdk-docs$label');
  String cwd = await futureCwd;
  await launcher.runStreamed(sdkBin('pub'), ['get'], workingDirectory: cwd);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        pathLib.join('bin', 'dartdoc.dart'),
        '--output',
        '${sdkDocsPath}',
        '--sdk-docs',
        '--json',
        '--show-progress',
      ]..addAll(extraDartdocParameters),
      workingDirectory: cwd);
}

Future<List<Map>> _buildTestPackageDocs(
    String outputDir, Future<String> futureCwd,
    [String label]) async {
  if (label == null) label = '';
  if (label != '') label = '-$label';
  var launcher = new SubprocessLauncher('build-test-package-docs$label');
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: testPackage.absolute.path);
  String cwd = await futureCwd;
  await launcher.runStreamed(sdkBin('pub'), ['get'], workingDirectory: cwd);
  return await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        pathLib.join(cwd, 'bin', 'dartdoc.dart'),
        '--output',
        outputDir,
        '--example-path-prefix',
        'examples',
        '--include-source',
        '--json',
        '--pretty-index-json',
      ]..addAll(extraDartdocParameters),
      workingDirectory: testPackage.absolute.path);
}

@Task('Build generated test package docs (with inherited docs and source code)')
Future<void> buildTestPackageDocs() async {
  await _buildTestPackageDocs(testPackageDocsDir.absolute.path,
      new Future.value(Directory.current.path));
}

@Task('Serve test package docs locally with dhttpd on port 8002')
@Depends(buildTestPackageDocs)
Future<void> serveTestPackageDocs() async {
  log('launching dhttpd on port 8002 for SDK');
  var launcher = new SubprocessLauncher('serve-test-package-docs');
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
  var launcher = new SubprocessLauncher(context);
  await launcher.runStreamed(sdkBin('pub'), ['get']);
  await launcher.runStreamed(sdkBin('pub'), ['global', 'activate', 'dhttpd']);
  await launcher.runStreamed(
      sdkBin('pub'), ['run', 'dhttpd', '--port', '$port', '--path', servePath]);
}

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
@Depends(buildSdkDocs)
Future<void> serveSdkDocs() async {
  log('launching dhttpd on port 8000 for SDK');
  var launcher = new SubprocessLauncher('serve-sdk-docs');
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
  Directory originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  Future originalDartdoc = createComparisonDartdoc();
  Map<String, String> envCurrent = _createThrowawayPubCache();
  Map<String, String> envOriginal = _createThrowawayPubCache();
  Future currentDartdocFlutterBuild = _buildFlutterDocs(flutterDir.path,
      new Future.value(Directory.current.path), envCurrent, 'docs-current');
  Future originalDartdocFlutterBuild = _buildFlutterDocs(
      originalDartdocFlutter.path,
      originalDartdoc,
      envOriginal,
      'docs-original');
  WarningsCollection currentDartdocWarnings = jsonMessageIterableToWarnings(
      await currentDartdocFlutterBuild,
      flutterDir.absolute.path,
      envCurrent['PUB_CACHE'],
      'HEAD');
  WarningsCollection originalDartdocWarnings = jsonMessageIterableToWarnings(
      await originalDartdocFlutterBuild,
      originalDartdocFlutter.absolute.path,
      envOriginal['PUB_CACHE'],
      dartdocOriginalBranch);

  print(originalDartdocWarnings.getPrintableWarningDelta(
      'Flutter repo', currentDartdocWarnings));

  if (Platform.environment['SERVE_FLUTTER'] == '1') {
    var launcher = new SubprocessLauncher('serve-flutter-docs');
    await launcher.runStreamed(sdkBin('pub'), ['get']);
    Future original = launcher.runStreamed(sdkBin('pub'), [
      'run',
      'dhttpd',
      '--port',
      '9000',
      '--path',
      pathLib.join(originalDartdocFlutter.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    Future current = launcher.runStreamed(sdkBin('pub'), [
      'run',
      'dhttpd',
      '--port',
      '9001',
      '--path',
      pathLib.join(flutterDir.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    await Future.wait([original, current]);
  }
}

@Task('Serve generated Flutter docs locally with dhttpd on port 8001')
@Depends(buildFlutterDocs)
Future<void> serveFlutterDocs() async {
  log('launching dhttpd on port 8001 for Flutter');
  var launcher = new SubprocessLauncher('serve-flutter-docs');
  await launcher.runStreamed(sdkBin('pub'), ['get']);
  await launcher.runStreamed(sdkBin('pub'), [
    'run',
    'dhttpd',
    '--port',
    '8001',
    '--path',
    pathLib.join(flutterDir.path, 'dev', 'docs', 'doc'),
  ]);
}

@Task('Validate flutter docs')
// TODO(jcollins-g): add buildDartdocFlutterPluginDocs once passing
@Depends(buildFlutterDocs)
void validateFlutterDocs() {}

@Task('Build flutter docs')
Future<void> buildFlutterDocs() async {
  log('building flutter docs into: $flutterDir');
  Map<String, String> env = _createThrowawayPubCache();
  await _buildFlutterDocs(
      flutterDir.path, new Future.value(Directory.current.path), env, 'docs');
  String index = new File(
          pathLib.join(flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
      .readAsStringSync();
  stdout.write(index);
}

/// A class wrapping a flutter SDK.
class FlutterRepo {
  final String flutterPath;
  final Map<String, String> env;
  final String bin = pathLib.join('bin', 'flutter');

  FlutterRepo._(this.flutterPath, this.env, String label) {
    cacheDart =
        pathLib.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
    cachePub =
        pathLib.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'pub');
    env['PATH'] =
        '${pathLib.join(pathLib.canonicalize(flutterPath), "bin")}:${env['PATH'] ?? Platform.environment['PATH']}';
    env['FLUTTER_ROOT'] = flutterPath;
    launcher =
        new SubprocessLauncher('flutter${label == null ? "" : "-$label"}', env);
  }

  Future<void> _init() async {
    new Directory(flutterPath).createSync(recursive: true);
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
  }

  factory FlutterRepo.fromPath(String flutterPath, Map<String, String> env,
      [String label]) {
    FlutterRepo flutterRepo = new FlutterRepo._(flutterPath, env, label);
    return flutterRepo;
  }

  /// Copy an existing, initialized flutter repo.
  static Future<FlutterRepo> copyFromExistingFlutterRepo(
      FlutterRepo origRepo, String flutterPath, Map<String, String> env,
      [String label]) async {
    await copyPath(origRepo.flutterPath, flutterPath);
    FlutterRepo flutterRepo = new FlutterRepo._(flutterPath, env, label);
    return flutterRepo;
  }

  /// Doesn't actually copy the existing repo; use for read-only operations only.
  static Future<FlutterRepo> fromExistingFlutterRepo(FlutterRepo origRepo,
      [String label]) async {
    FlutterRepo flutterRepo =
        new FlutterRepo._(origRepo.flutterPath, {}, label);
    return flutterRepo;
  }

  String cacheDart;
  String cachePub;
  SubprocessLauncher launcher;
}

Future<List<Map>> _buildFlutterDocs(
    String flutterPath, Future<String> futureCwd, Map<String, String> env,
    [String label]) async {
  FlutterRepo flutterRepo = await FlutterRepo.copyFromExistingFlutterRepo(
      await cleanFlutterRepo, flutterPath, env, label);
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cachePub,
    ['get'],
    workingDirectory: pathLib.join(flutterPath, 'dev', 'tools'),
  );
  await flutterRepo.launcher.runStreamed(
    flutterRepo.cachePub,
    ['get'],
    workingDirectory: pathLib.join(flutterPath, 'dev', 'snippets'),
  );
  await flutterRepo.launcher.runStreamed(
      flutterRepo.cachePub, ['global', 'activate', '-spath', '.'],
      workingDirectory: await futureCwd);
  return await flutterRepo.launcher.runStreamed(
    flutterRepo.cacheDart,
    [pathLib.join('dev', 'tools', 'dartdoc.dart'), '-c', '--json'],
    workingDirectory: flutterPath,
  );
}

/// Returns the directory in which we generated documentation.
Future<String> _buildPubPackageDocs(
    String pubPackageName, List<String> dartdocParameters,
    [String version, String label]) async {
  Map<String, String> env = _createThrowawayPubCache();
  var launcher = new SubprocessLauncher(
      'build-${pubPackageName}${version == null ? "" : "-$version"}${label == null ? "" : "-$label"}',
      env);
  List<String> args = <String>['cache', 'add'];
  if (version != null) args.addAll(<String>['-v', version]);
  args.add(pubPackageName);
  await launcher.runStreamed('pub', args);
  Directory cache = new Directory(
      pathLib.join(env['PUB_CACHE'], 'hosted', 'pub.dartlang.org'));
  Directory pubPackageDir =
      cache.listSync().firstWhere((e) => e.path.contains(pubPackageName));
  await launcher.runStreamed('pub', ['get'],
      workingDirectory: pubPackageDir.absolute.path);
  await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        pathLib.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--show-progress',
      ]..addAll(dartdocParameters),
      workingDirectory: pubPackageDir.absolute.path);
  return pathLib.join(pubPackageDir.absolute.path, 'doc', 'api');
}

@Task(
    'Build an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
Future<String> buildPubPackage() async {
  assert(Platform.environment.containsKey('PACKAGE_NAME'));
  String packageName = Platform.environment['PACKAGE_NAME'];
  String version = Platform.environment['PACKAGE_VERSION'];
  return _buildPubPackageDocs(packageName, extraDartdocParameters, version);
}

@Task(
    'Serve an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
Future<void> servePubPackage() async {
  await _serveDocsFrom(await buildPubPackage(), 9000, 'serve-pub-package');
}

@Task('Checks that CHANGELOG mentions current version')
Future<void> checkChangelogHasVersion() async {
  var changelog = new File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    fail('ERROR: No CHANGELOG.md found in ${Directory.current}');
  }

  var version = _getPackageVersion();

  if (!changelog.readAsLinesSync().contains('## ${version}')) {
    fail('ERROR: CHANGELOG.md does not mention version ${version}');
  }
}

String _getPackageVersion() {
  var pubspec = new File('pubspec.yaml');
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
  var launcher = new SubprocessLauncher('build');
  await launcher.runStreamed(sdkBin('pub'),
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
}

/// Paths in this list are relative to lib/.
final _generated_files_list = <String>[
  'src/html/resources.g.dart',
  'src/version.dart',
].map((s) => pathLib.joinAll(pathLib.posix.split(s)));

@Task('Verify generated files are up to date')
Future<void> checkBuild() async {
  var originalFileContents = new Map<String, String>();
  var differentFiles = <String>[];
  var launcher = new SubprocessLauncher('check-build');

  // Load original file contents into memory before running the builder;
  // it modifies them in place.
  for (String relPath in _generated_files_list) {
    String origPath = pathLib.joinAll(['lib', relPath]);
    File oldVersion = new File(origPath);
    if (oldVersion.existsSync()) {
      originalFileContents[relPath] = oldVersion.readAsStringSync();
    }
  }

  await launcher.runStreamed(sdkBin('pub'),
      ['run', 'build_runner', 'build', '--delete-conflicting-outputs']);
  for (String relPath in _generated_files_list) {
    File newVersion = new File(pathLib.join('lib', relPath));
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
        '  ${differentFiles.map((f) => pathLib.join('lib', f)).join("\n  ")}\n'
        'Rebuild them with "grind build" and check the results in.');
  }
}

@Task('Dry run of publish to pub.dartlang')
@Depends(checkChangelogHasVersion)
Future<void> tryPublish() async {
  log('FIXME:  tryPublish() disabled until dependency_override is removed'
      ' (#1765)');
  //var launcher = new SubprocessLauncher('try-publish');
  //await launcher.runStreamed(sdkBin('pub'), ['publish', '-n']);
}

@Task('Run all the tests.')
Future<void> test() async {
  await testDart2();
  await testFutures.wait();
}

List<File> get binFiles => new Directory('bin')
    .listSync(recursive: true)
    .where((e) => e is File && e.path.endsWith('.dart'))
    .cast<File>()
    .toList();

List<File> get testFiles => new Directory('test')
    .listSync(recursive: true)
    .where((e) => e is File && e.path.endsWith('test.dart'))
    .cast<File>()
    .toList();

Future<void> testDart2() async {
  List<String> parameters = ['--enable-asserts'];

  for (File dartFile in testFiles) {
    await testFutures.addFutureFromClosure(() =>
        new SubprocessLauncher('dart2-${pathLib.basename(dartFile.path)}')
            .runStreamed(
                Platform.resolvedExecutable,
                <String>[]
                  ..addAll(parameters)
                  ..add(dartFile.path)));
  }

  for (File dartFile in binFiles) {
    await testFutures.addFutureFromClosure(() => new SubprocessLauncher(
            'dart2-bin-${pathLib.basename(dartFile.path)}-help')
        .runStreamed(
            Platform.resolvedExecutable,
            <String>[]
              ..addAll(parameters)
              ..add(dartFile.path)
              ..add('--help')));
  }
}

@Task('Generate docs for dartdoc')
Future<void> testDartdoc() async {
  var launcher = new SubprocessLauncher('test-dartdoc');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--output',
    dartdocDocsDir.path
  ]);
  expectFileContains(pathLib.join(dartdocDocsDir.path, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  final RegExp object = new RegExp('<li>Object</li>', multiLine: true);
  expectFileContains(
      pathLib.join(dartdocDocsDir.path, 'dartdoc', 'ModelElement-class.html'),
      [object]);
}

@Task('Generate docs for dartdoc with remote linking')
Future<void> testDartdocRemote() async {
  var launcher = new SubprocessLauncher('test-dartdoc-remote');
  final RegExp object = new RegExp(
      '<a href="https://api.dartlang.org/(dev|stable)/[^/]*/dart-core/Object-class.html">Object</a>',
      multiLine: true);
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--link-to-remote',
    '--output',
    dartdocDocsDir.path
  ]);
  expectFileContains(pathLib.join(dartdocDocsDir.path, 'index.html'),
      ['<title>dartdoc - Dart API docs</title>']);
  expectFileContains(
      pathLib.join(dartdocDocsDir.path, 'dartdoc', 'ModelElement-class.html'),
      [object]);
}

@Task('serve docs for a package that requires flutter with remote linking')
@Depends(buildDartdocFlutterPluginDocs)
Future<void> serveDartdocFlutterPluginDocs() async {
  await _serveDocsFrom(
      pluginPackageDocsDir.path, 8005, 'serve-dartdoc-flutter-plugin-docs');
}

Future<WarningsCollection> _buildDartdocFlutterPluginDocs() async {
  FlutterRepo flutterRepo = await FlutterRepo.fromExistingFlutterRepo(
      await cleanFlutterRepo, 'docs-flutter-plugin');

  return jsonMessageIterableToWarnings(
      await flutterRepo.launcher.runStreamed(
          flutterRepo.cacheDart,
          [
            '--enable-asserts',
            pathLib.join(Directory.current.path, 'bin', 'dartdoc.dart'),
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
Future<void> buildDartdocFlutterPluginDocs() async {
  await _buildDartdocFlutterPluginDocs();
}

@Task('Verify docs for a package that requires flutter with remote linking')
Future<void> testDartdocFlutterPlugin() async {
  WarningsCollection warnings = await _buildDartdocFlutterPluginDocs();
  if (!warnings.warningKeyCounts.isEmpty) {
    fail('No warnings should exist in : ${warnings.warningKeyCounts}');
  }
  // Verify that links to Dart SDK and Flutter SDK go to the flutter site.
  expectFileContains(
      pathLib.join(
          pluginPackageDocsDir.path, 'testlib', 'MyAwesomeWidget-class.html'),
      [
        '<a href="https://docs.flutter.io/flutter/widgets/Widget-class.html">Widget</a>',
        '<a href="https://docs.flutter.io/flutter/dart-core/Object-class.html">Object</a>'
      ]);
}

@Task('update test_package_docs')
Future<void> updateTestPackageDocs() async {
  var launcher = new SubprocessLauncher('update-test-package-docs');
  var testPackageDocs = new Directory(pathLib.join(
      'testing',
      Platform.version.split(' ').first.contains('-')
          ? 'test_package_docs_dev'
          : 'test_package_docs'));
  var testPackage = new Directory(pathLib.join('testing', 'test_package'));
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: testPackage.path);
  delete(testPackageDocs);
  // This must be synced with ../test/compare_output_test.dart's
  // "Validate html output of test_package" test.
  await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--enable-asserts',
        pathLib.join('..', '..', 'bin', 'dartdoc.dart'),
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--exclude-packages',
        'Dart,args,matcher,meta,path,stack_trace,quiver',
        '--hide-sdk-text',
        '--no-include-source',
        '--output',
        pathLib.canonicalize(testPackageDocs.path),
        '--pretty-index-json',
      ],
      workingDirectory: testPackage.path);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
void validateSdkDocs() {
  const expectedLibCount = 0;
  const expectedSubLibCount = 19;
  File indexHtml = joinFile(sdkDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) {
    fail('no index.html found for SDK docs');
  }
  log('found index.html');
  String indexContents = indexHtml.readAsStringSync();
  int foundLibs = _findCount(indexContents, '  <li><a href="dart-');
  if (foundLibs != expectedLibCount) {
    fail(
        'expected $expectedLibCount dart: index.html entries, found $foundLibs');
  }
  log('$foundLibs index.html dart: entries found');

  int foundSubLibs =
      _findCount(indexContents, '<li class="section-subitem"><a href="dart-');
  if (foundSubLibs != expectedSubLibCount) {
    fail(
        'expected $expectedSubLibCount dart: index.html entries in categories, found $foundSubLibs');
  }
  log('$foundSubLibs index.html dart: entries in categories found');

  // check for the existence of certain files/dirs
  var libsLength =
      sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (libsLength != expectedLibCount + expectedSubLibCount) {
    fail('docs not generated for all the SDK libraries, '
        'expected ${expectedLibCount + expectedSubLibCount} directories, generated $libsLength directories');
  }
  log('$libsLength dart: libraries found');

  var futureConstFile = joinFile(
      sdkDocsDir, [pathLib.join('dart-async', 'Future', 'Future.html')]);
  if (!futureConstFile.existsSync()) {
    fail('no Future.html found for dart:async Future constructor');
  }
  log('found Future.async ctor');
}

int _findCount(String str, String match) {
  int count = 0;
  int index = str.indexOf(match);
  while (index != -1) {
    count++;
    index = str.indexOf(match, index + match.length);
  }
  return count;
}
