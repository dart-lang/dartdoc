// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' hide ProcessException;

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as p;

import 'src/flutter_repo.dart';
import 'src/subprocess_launcher.dart';
import 'src/warnings_collection.dart';
import 'task.dart' as task;

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

// Directory.systemTemp is not a constant.  So wrap it.
Directory createTempSync(String prefix) =>
    Directory.systemTemp.createTempSync(prefix);

final String _dartdocDocsPath = createTempSync('dartdoc').path;

final Directory _flutterDir = createTempSync('flutter');

Directory get testPackageFlutterPlugin => Directory(
    p.joinAll(['testing', 'flutter_packages', 'test_package_flutter_plugin']));

final Directory _testPackageDocsDir = createTempSync('test_package');

final Directory _testPackageExperimentsDocsDir =
    createTempSync('test_package_experiments');

/// Version of dartdoc we should use when making comparisons.
String get dartdocOriginalBranch {
  var branch = Platform.environment['DARTDOC_ORIGINAL'];
  if (branch == null) {
    return 'main';
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

@Task('Analyze dartdoc to ensure there are no errors and warnings')
void analyze() async {
  await task.analyzeTestPackages();
  await task.analyzePackage();
}

@Task('Analyze the test packages')
void analyzeTestPackages() async => task.analyzeTestPackages();

@Task('Check for dart format cleanliness')
void checkFormat() async {
  if (Platform.version.contains('dev')) {
    var filesToFix = <String>[];

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
    );
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
)
void presubmit() async {
  await task.runTryPublish();
  await task.runTest();
}

@Task('Run tests, self-test dartdoc, and run the publish test')
@Depends(presubmit, test, testDartdoc)
void buildbot() {}

@Task('Generate docs for the Dart SDK')
Future<void> buildSdkDocs() async => await task.docSdk();

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
    'main',
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

Future<Iterable<Map<String, Object?>>> _buildTestPackageDocs(
    String outputDir, String cwd,
    {List<String> params = const [],
    String label = '',
    String? testPackagePath}) async {
  if (label != '') label = '-$label';
  testPackagePath ??= task.testPackage.absolute.path;
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
      testPackagePath: task.testPackageExperiments.absolute.path,
      params: [
        '--enable-experiment',
        'non-nullable,generic-metadata',
        '--no-link-to-remote'
      ]);
}

@Task('Serve experimental test package on port 8003.')
@Depends(buildTestExperimentsPackageDocs)
Future<void> serveTestExperimentsPackageDocs() async =>
    await task.servePackageDocs(
      name: Platform.environment['PACKAGE_NAME']!,
      version: Platform.environment['PACKAGE_VERSION'],
    );

@Task('Build test package docs (HTML) with inherited docs and source code')
@Depends(clean)
Future<void> buildTestPackageDocs() async {
  await _buildTestPackageDocs(
      _testPackageDocsDir.absolute.path, Directory.current.path);
}

@Task('Serve test package docs locally with dhttpd on port 8002')
@Depends(buildTestPackageDocs)
Future<void> serveTestPackageDocs() async {
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

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
Future<void> serveSdkDocs() async => await task.serveSdkDocs();

@Task('Compare warnings in Dartdoc for Flutter')
Future<void> compareFlutterWarnings() async {
  var originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  var originalDartdoc = createComparisonDartdoc();
  var envCurrent = task.createThrowawayPubCache();
  var envOriginal = task.createThrowawayPubCache();
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

  print(originalDartdocWarnings.warningDeltaText(
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

@Task('Build flutter docs')
Future<void> buildFlutterDocs() async {
  log('building flutter docs into: $_flutterDir');
  var env = task.createThrowawayPubCache();
  await _buildFlutterDocs(
      _flutterDir.path, Future.value(Directory.current.path), env, 'docs');
  var indexContents =
      File(p.join(_flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
          .readAsLinesSync();
  stdout.write([...indexContents.take(25), '...\n'].join('\n'));
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
  try {
    await flutterRepo.launcher.runStreamed(
      flutterRepo.cacheDart,
      ['pub', 'global', 'deactivate', 'snippets'],
    );
  } on SubprocessException {
    // Ignore failure to deactivate so this works on completely clean bots.
  }
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

@Task(
    'Build an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION '
    'environment variables')
Future<String> buildPubPackage() async => await task.docPackage(
      name: Platform.environment['PACKAGE_NAME']!,
      version: Platform.environment['PACKAGE_VERSION'],
    );

@Task(
    'Serve an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION '
    'environment variables')
Future<void> servePubPackage() async => await task.servePackageDocs(
      name: Platform.environment['PACKAGE_NAME']!,
      version: Platform.environment['PACKAGE_VERSION'],
    );

@Task('Rebuild generated files')
@Depends(clean)
Future<void> build() async {
  if (Platform.isWindows) {
    // Built files only need to be built on Linux and MacOS, as there are path
    // issues with Windows.
    return;
  }
  await task.buildWeb();
  await task.buildRenderers();
  await task.buildDartdocOptions();
}

@Task('Build the web frontend')
Future<void> buildWeb() async => await task.buildWeb();

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
  final currentCodeSig = await task.calcDartFilesSig(Directory('web'));
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
Future<void> tryPublish() async => await task.runTryPublish();

@Task('Run all the tests.')
Future<void> test() async => await task.runTest();

@Task('Clean up test directories and delete build cache')
Future<void> clean() async {
  for (var e in _nonRootPubData) {
    e.deleteSync(recursive: true);
  }
}

Iterable<FileSystemEntity> get _nonRootPubData {
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
      p.join(_dartdocDocsPath, 'dartdoc', 'PubPackageMeta-class.html'),
      [object]);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
void validateSdkDocs() {
  const expectedLibCounts = 0;
  const expectedSubLibCount = {19, 20, 21};
  const expectedTotalCount = {19, 20, 21};
  var indexHtml = joinFile(task.sdkDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) {
    fail("No 'index.html' found for the SDK docs");
  }
  log("Found 'index.html'");
  var indexContents = indexHtml.readAsStringSync();
  var foundLibs = _findCount(indexContents, '  <li><a href="dart-');
  if (expectedLibCounts != foundLibs) {
    fail("Expected $expectedLibCounts 'dart:' entries in 'index.html', but "
        'found $foundLibs');
  }
  log("Found $foundLibs 'dart:' entries in 'index.html'");

  var foundSubLibs =
      _findCount(indexContents, '<li class="section-subitem"><a href="dart-');
  if (!expectedSubLibCount.contains(foundSubLibs)) {
    fail("Expected $expectedSubLibCount 'dart:' entries in 'index.html' to be "
        'in categories, but found $foundSubLibs');
  }
  log('$foundSubLibs index.html dart: entries in categories found');

  // check for the existence of certain files/dirs
  var libsLength = task.sdkDocsDir
      .listSync()
      .where((fs) => fs.path.contains('dart-'))
      .length;
  if (!expectedTotalCount.contains(libsLength)) {
    fail('Docs not generated for all the SDK libraries; expected '
        '$expectedTotalCount directories, but $libsLength directories were '
        'generated');
  }
  log("Found $libsLength 'dart:' libraries");

  var futureConstFile = joinFile(
      task.sdkDocsDir, [p.join('dart-async', 'Future', 'Future.html')]);
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
