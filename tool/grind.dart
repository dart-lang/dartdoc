// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:collection';
import 'dart:io' hide ProcessException;

import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as pathLib;
import 'package:yaml/yaml.dart' as yaml;

main([List<String> args]) => grind(args);

/// Run no more than 6 futures in parallel with this.
final MultiFutureTracker testFutures = new MultiFutureTracker(6);

// Directory.systemTemp is not a constant.  So wrap it.
Directory createTempSync(String prefix) =>
    Directory.systemTemp.createTempSync(prefix);

final Memoizer tempdirsCache = new Memoizer();

Directory get dartdocDocsDir =>
    tempdirsCache.memoized1(createTempSync, 'dartdoc');
Directory get sdkDocsDir => tempdirsCache.memoized1(createTempSync, 'sdkdocs');
Directory get flutterDir => tempdirsCache.memoized1(createTempSync, 'flutter');
Directory get testPackage =>
    new Directory(pathLib.joinAll(['testing', 'test_package']));
Directory get testPackageDocsDir =>
    tempdirsCache.memoized1(createTempSync, 'test_package');

/// Version of dartdoc we should use when making comparisons.
String get dartdocOriginalBranch {
  String branch = 'master';
  if (Platform.environment.containsKey('DARTDOC_ORIGINAL')) {
    branch = Platform.environment['DARTDOC_ORIGINAL'];
    log('using branch/tag: $branch for comparison from \$DARTDOC_ORIGINAL');
  }
  return branch;
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

@Task('Analyze dartdoc to ensure there are no errors and warnings')
analyze() async {
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
@Depends(analyze, test, testDartdoc)
buildbot() => null;

@Task('Generate docs for the Dart SDK')
Future buildSdkDocs() async {
  log('building SDK docs');
  await _buildSdkDocs(
      sdkDocsDir.path, new Future.value(Directory.current.path));
}

class WarningsCollection {
  final String tempDir;
  final Map<String, int> _warningKeyCounts;
  final String branch;
  final String pubCachePath;
  WarningsCollection(this.tempDir, this.pubCachePath, this.branch)
      : this._warningKeyCounts = new Map() {}

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
    _warningKeyCounts.putIfAbsent(key, () => 0);
    _warningKeyCounts[key]++;
  }

  /// Output formatter for comparing warnings.  [this] is the original.
  String getPrintableWarningDelta(String title, WarningsCollection current) {
    StringBuffer printBuffer = new StringBuffer();
    Set<String> quantityChangedOuts = new Set();
    Set<String> onlyOriginal = new Set();
    Set<String> onlyCurrent = new Set();
    Set<String> identical = new Set();
    Set<String> allKeys = new Set.from([]
      ..addAll(_warningKeyCounts.keys)
      ..addAll(current._warningKeyCounts.keys));

    for (String key in allKeys) {
      if (_warningKeyCounts.containsKey(key) &&
          !current._warningKeyCounts.containsKey(key)) {
        onlyOriginal.add(key);
      } else if (!_warningKeyCounts.containsKey(key) &&
          current._warningKeyCounts.containsKey(key)) {
        onlyCurrent.add(key);
      } else if (_warningKeyCounts.containsKey(key) &&
          current._warningKeyCounts.containsKey(key) &&
          _warningKeyCounts[key] != current._warningKeyCounts[key]) {
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
            "* Appeared ${_warningKeyCounts[key]} times in $branch, ${current._warningKeyCounts[key]} in ${current.branch}:");
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
        '--checked',
        pathLib.join('bin', 'dartdoc.dart'),
        '--output',
        '${sdkDocsPath}',
        '--sdk-docs',
        '--json',
        '--show-progress',
      ],
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
        '--checked',
        pathLib.join(cwd, 'bin', 'dartdoc.dart'),
        '--output',
        outputDir,
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--include-source',
        '--json',
        '--pretty-index-json',
        '--exclude',
        'package:meta/meta.dart',
        '--exclude-packages',
        'Dart',
      ],
      workingDirectory: testPackage.absolute.path);
}

@Task('Build generated test package docs (with inherited docs and source code)')
Future buildTestPackageDocs() async {
  await _buildTestPackageDocs(testPackageDocsDir.absolute.path,
      new Future.value(Directory.current.path));
}

@Task('Serve test package docs locally with dhttpd on port 8002')
@Depends(buildTestPackageDocs)
Future serveTestPackageDocs() async {
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

_serveDocsFrom(String servePath, int port, String context) async {
  log('launching dhttpd on port $port for $context');
  var launcher = new SubprocessLauncher(context);
  await launcher.runStreamed(sdkBin('pub'), ['get']);
  await launcher.runStreamed(sdkBin('pub'), ['global', 'activate', 'dhttpd']);
  await launcher.runStreamed(
      sdkBin('pub'), ['run', 'dhttpd', '--port', '$port', '--path', servePath]);
}

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
@Depends(buildSdkDocs)
Future serveSdkDocs() async {
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
Future compareFlutterWarnings() async {
  Directory originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  Future originalDartdoc = createComparisonDartdoc();
  Map<String, String> envCurrent = _createThrowawayPubCache();
  Map<String, String> envOriginal = _createThrowawayPubCache();
  Future currentDartdocFlutterBuild = _buildFlutterDocs(flutterDir.path,
      new Future.value(Directory.current.path), envCurrent, 'current');
  Future originalDartdocFlutterBuild = _buildFlutterDocs(
      originalDartdocFlutter.path, originalDartdoc, envOriginal, 'original');
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
Future serveFlutterDocs() async {
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

@Task('Build flutter docs')
Future buildFlutterDocs() async {
  log('building flutter docs into: $flutterDir');
  Map<String, String> env = _createThrowawayPubCache();
  await _buildFlutterDocs(
      flutterDir.path, new Future.value(Directory.current.path), env);
  String index = new File(
          pathLib.join(flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
      .readAsStringSync();
  stdout.write(index);
}

Future<List<Map>> _buildFlutterDocs(
    String flutterPath, Future<String> futureCwd, Map<String, String> env,
    [String label]) async {
  env['PATH'] = '${pathLib.join(flutterPath, "bin")}:${env['PATH']}';
  var launcher = new SubprocessLauncher(
      'build-flutter-docs${label == null ? "" : "-$label"}', env);
  await launcher.runStreamed(
      'git', ['clone', 'https://github.com/flutter/flutter.git', '.'],
      workingDirectory: flutterPath);
  String flutterBin = pathLib.join('bin', 'flutter');
  String flutterCacheDart =
      pathLib.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
  String flutterCachePub =
      pathLib.join(flutterPath, 'bin', 'cache', 'dart-sdk', 'bin', 'pub');
  await launcher.runStreamed(
    flutterBin,
    ['--version'],
    workingDirectory: flutterPath,
  );
  await launcher.runStreamed(
    flutterBin,
    ['precache'],
    workingDirectory: flutterPath,
  );
  await launcher.runStreamed(
    flutterCachePub,
    ['get'],
    workingDirectory: pathLib.join(flutterPath, 'dev', 'tools'),
  );
  await launcher.runStreamed(
      flutterCachePub, ['global', 'activate', '-spath', '.'],
      workingDirectory: await futureCwd);
  return await launcher.runStreamed(
    flutterCacheDart,
    [pathLib.join('dev', 'tools', 'dartdoc.dart'), '-c', '--json'],
    workingDirectory: flutterPath,
  );
}

/// Returns the directory in which we generated documentation.
Future<String> _buildPubPackageDocs(String pubPackageName,
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
        '--checked',
        pathLib.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--show-progress',
      ],
      workingDirectory: pubPackageDir.absolute.path);
  return pathLib.join(pubPackageDir.absolute.path, 'doc', 'api');
}

@Task(
    'Serve an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION environment variables')
servePubPackage() async {
  assert(Platform.environment.containsKey('PACKAGE_NAME'));
  String packageName = Platform.environment['PACKAGE_NAME'];
  String version = Platform.environment['PACKAGE_VERSION'];
  _serveDocsFrom(await _buildPubPackageDocs(packageName, version), 9000,
      'serve-pub-package');
}

@Task('Checks that CHANGELOG mentions current version')
checkChangelogHasVersion() async {
  var changelog = new File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    fail('ERROR: No CHANGELOG.md found in ${Directory.current}');
  }

  var version = _getPackageVersion();

  if (!changelog.readAsLinesSync().contains('## ${version}')) {
    fail('ERROR: CHANGELOG.md does not mention version ${version}');
  }
}

_getPackageVersion() {
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

@Task('Checks that version is matched in relevant places')
checkVersionMatches() async {
  var version = _getPackageVersion();
  var libCode = new File('lib/dartdoc.dart');
  if (!libCode.existsSync()) {
    fail('Cannot find lib/dartdoc.dart in ${Directory.current}');
  }
  String libCodeContents = libCode.readAsStringSync();

  if (!libCodeContents.contains("const String version = '${version}';")) {
    fail('Version string for ${version} not found in lib/dartdoc.dart');
  }
}

@Task('Find transformers used by this project')
findTransformers() async {
  var dotPackages = new File('.packages');
  if (!dotPackages.existsSync()) {
    fail('No .packages file found in ${Directory.current}');
  }

  var foundAnyTransformers = false;

  dotPackages
      .readAsLinesSync()
      .where((line) => !line.startsWith('#'))
      .map((line) => line.split(':file://'))
      .forEach((List<String> mapping) {
    var pubspec = new File(mapping.last.replaceFirst('lib/', 'pubspec.yaml'));
    if (pubspec.existsSync()) {
      var yamlDoc = yaml.loadYaml(pubspec.readAsStringSync());
      if (yamlDoc['transformers'] != null) {
        log('${mapping.first} has transformers!');
        foundAnyTransformers = true;
      }
    } else {
      log('No pubspec found for ${mapping.first}, tried ${pubspec}');
    }
  });

  if (!foundAnyTransformers) {
    log('No transformers found');
  }
}

@Task('Make sure all the resource files are present')
indexResources() {
  var sourcePath = pathLib.join('lib', 'resources');
  if (!new Directory(sourcePath).existsSync()) {
    throw new StateError('lib/resources directory not found');
  }
  var outDir = new Directory(pathLib.join('lib'));
  var out =
      new File(pathLib.join(outDir.path, 'src', 'html', 'resources.g.dart'));
  out.createSync(recursive: true);
  var buffer = new StringBuffer()
    ..write('// WARNING: This file is auto-generated. Do not taunt.\n\n')
    ..write('library dartdoc.html.resources;\n\n')
    ..write('const List<String> resource_names = const [\n');
  var packagePaths = [];
  for (var fileName in listDir(sourcePath, recursive: true)) {
    if (!FileSystemEntity.isDirectorySync(fileName)) {
      var packageified = fileName.replaceFirst('lib/', 'package:dartdoc/');
      packagePaths.add(packageified);
    }
  }
  packagePaths.sort();
  buffer.write(packagePaths.map((p) => "  '$p'").join(',\n'));
  buffer.write('\n];\n');
  out.writeAsString(buffer.toString());
}

@Task('Publish to pub.dartlang')
@Depends(checkChangelogHasVersion, checkVersionMatches)
publish() async {
  log('run : pub publish');
}

@Task('Run all the tests.')
test() async {
  await testPreviewDart2();
  await testDart1();
  await testFutures.wait();
}

List<File> get testFiles => new Directory('test')
    .listSync(recursive: true)
    .where((e) => e is File && e.path.endsWith('test.dart'))
    .cast<File>()
      ..toList();

testPreviewDart2() async {
  List<String> parameters = ['--preview-dart-2', '--enable-asserts'];

  // sdk#32901 is really bad on Windows.
  for (File dartFile in testFiles.where((f) =>
      !f.path.endsWith('html_generator_test.dart') && !Platform.isWindows)) {
    // absolute path to work around dart-lang/sdk#32901
    await testFutures.addFuture(new SubprocessLauncher(
            'dart2-${pathLib.basename(dartFile.absolute.path)}')
        .runStreamed(
            Platform.resolvedExecutable,
            <String>[]
              ..addAll(parameters)
              ..add(dartFile.absolute.path)));
  }
}

testDart1() async {
  List<String> parameters = ['--checked'];

  for (File dartFile in testFiles) {
    // absolute path to work around dart-lang/sdk#32901
    await testFutures.addFuture(new SubprocessLauncher(
            'dart1-${pathLib.basename(dartFile.absolute.path)}')
        .runStreamed(
            Platform.resolvedExecutable,
            <String>[]
              ..addAll(parameters)
              ..add(dartFile.absolute.path)));
  }
}

@Task('Generate docs for dartdoc')
testDartdoc() async {
  var launcher = new SubprocessLauncher('test-dartdoc');
  await launcher.runStreamed(Platform.resolvedExecutable,
      ['--checked', 'bin/dartdoc.dart', '--output', dartdocDocsDir.path]);
  File indexHtml = joinFile(dartdocDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) fail('docs not generated');
}

@Task('update test_package_docs')
updateTestPackageDocs() async {
  var launcher = new SubprocessLauncher('update-test-package-docs');
  var testPackageDocs =
      new Directory(pathLib.join('testing', 'test_package_docs'));
  var testPackage = new Directory(pathLib.join('testing', 'test_package'));
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: testPackage.path);
  delete(testPackageDocs);
  // This must be synced with ../test/compare_output_test.dart's
  // "Validate html output of test_package" test.
  await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--checked',
        pathLib.join('..', '..', 'bin', 'dartdoc.dart'),
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--no-include-source',
        '--pretty-index-json',
        '--hide-sdk-text',
        '--exclude',
        'package:meta/meta.dart',
        '--exclude-packages',
        'Dart',
        '--output',
        '../test_package_docs',
      ],
      workingDirectory: testPackage.path);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
validateSdkDocs() {
  const expectedLibCount = 7;
  const expectedSubLibCount = 12;
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
