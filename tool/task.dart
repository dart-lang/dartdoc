// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

import 'src/flutter_repo.dart';
import 'src/io_utils.dart' as io_utils;
import 'src/subprocess_launcher.dart';
import 'src/warnings_collection.dart';

void main(List<String> args) async {
  var parser = ArgParser()
    ..addCommand('analyze')
    ..addCommand('build')
    ..addCommand('buildbot')
    ..addCommand('clean')
    ..addCommand('compare')
    ..addCommand('serve')
    ..addCommand('test')
    ..addCommand('try-publish')
    ..addCommand('validate');
  parser.addCommand('doc')
    ..addOption('name')
    ..addOption('version');

  var results = parser.parse(args);
  var commandResults = results.command;
  if (commandResults == null) {
    return;
  }

  return await switch (commandResults.name) {
    'analyze' => runAnalyze(commandResults),
    'build' => runBuild(commandResults),
    'buildbot' => runBuildbot(),
    'clean' => runClean(),
    'compare' => runCompare(commandResults),
    'doc' => runDoc(commandResults),
    'serve' => runServe(commandResults),
    'test' => runTest(),
    'try-publish' => runTryPublish(),
    'validate' => runValidate(commandResults),
    _ => throw ArgumentError(),
  };
}

String _getPackageVersion() {
  var pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    throw StateError('Cannot find pubspec.yaml in ${Directory.current}');
  }
  var yamlDoc = yaml.loadYaml(pubspec.readAsStringSync()) as yaml.YamlMap;
  return yamlDoc['version'] as String;
}

Directory get testPackage =>
    Directory(path.joinAll(['testing', 'test_package']));

Directory get testPackageExperiments =>
    Directory(path.joinAll(['testing', 'test_package_experiments']));

Future<void> runAnalyze(ArgResults commandResults) async {
  for (var target in commandResults.rest) {
    await switch (target) {
      'package' => analyzePackage(),
      'test-packages' => analyzeTestPackages(),
      _ => throw UnimplementedError('Unknown analyze target: "$target"'),
    };
  }
}

Future<void> analyzePackage() async =>
    await SubprocessLauncher('analyze').runStreamedDartCommand(
      ['analyze', '--fatal-infos', '.'],
    );

Future<void> analyzeTestPackages() async {
  var testPackagePaths = [
    testPackage.path,
    if (Platform.version.contains('dev')) testPackageExperiments.path,
  ];
  for (var testPackagePath in testPackagePaths) {
    await SubprocessLauncher('pub-get').runStreamedDartCommand(
      ['pub', 'get'],
      workingDirectory: testPackagePath,
    );
    await SubprocessLauncher('analyze-test-package').runStreamedDartCommand(
      // TODO(srawlins): Analyze the whole directory by ignoring the pubspec
      // reports.
      ['analyze', 'lib'],
      workingDirectory: testPackagePath,
    );
  }
}

Future<void> runBuild(ArgResults commandResults) async {
  if (commandResults.rest.isEmpty) {
    await buildAll();
  }
  for (var target in commandResults.rest) {
    await switch (target) {
      'renderers' => buildRenderers(),
      'dartdoc-options' => buildDartdocOptions(),
      'web' => buildWeb(),
      _ => throw UnimplementedError('Unknown build target: "$target"'),
    };
  }
}

Future<void> buildAll() async {
  if (Platform.isWindows) {
    // Built files only need to be built on Linux and MacOS, as there are path
    // issues with Windows.
    return;
  }
  await buildWeb();
  await buildRenderers();
  await buildDartdocOptions();
}

Future<void> buildRenderers() async => await SubprocessLauncher('build')
    .runStreamedDartCommand([path.join('tool', 'mustachio', 'builder.dart')]);

Future<void> buildDartdocOptions() async {
  var version = _getPackageVersion();
  var dartdocOptions = File('dartdoc_options.yaml');
  await dartdocOptions.writeAsString('''dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/dartdoc/blob/v$version/%f%#L%l%'
''');
}

Future<void> buildWeb() async {
  await SubprocessLauncher('build').runStreamedDartCommand([
    'compile',
    'js',
    '--output=lib/resources/docs.dart.js',
    'web/docs.dart',
    '-O4',
  ]);
  _delete(File('lib/resources/docs.dart.js.deps'));

  var compileSig = await _calcDartFilesSig(Directory('web'));
  File(path.join('web', 'sig.txt')).writeAsStringSync('$compileSig\n');
}

/// Delete the given file entity reference.
void _delete(FileSystemEntity entity) {
  if (entity.existsSync()) {
    print('deleting ${entity.path}');
    entity.deleteSync(recursive: true);
  }
}

/// Yields all of the trimmed lines of all of the `.dart` files in [dir].
Stream<String> _dartFileLines(Directory dir) {
  var files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => compareAsciiLowerCase(a.path, b.path));

  return Stream.fromIterable([
    for (var file in files)
      for (var line in file.readAsLinesSync()) line.trim(),
  ]);
}

Future<void> runBuildbot() async {
  await analyzeTestPackages();
  await analyzePackage();
  await validateFormat();
  await validateBuild();
  await runTryPublish();
  await runTest();
  await validateDartdocDocs();
}

Future<void> runClean() async {
  // This involves deleting things, so be careful.
  if (!File(path.join('tool', 'grind.dart')).existsSync()) {
    throw FileSystemException('Wrong CWD, run from root of dartdoc package');
  }
  const pubDataFileNames = {'.dart_tool', '.packages', 'pubspec.lock'};
  var nonRootPubData = Directory('.')
      .listSync(recursive: true)
      .where((e) => path.dirname(e.path) != '.')
      .where((e) => pubDataFileNames.contains(path.basename(e.path)));
  for (var e in nonRootPubData) {
    e.deleteSync(recursive: true);
  }
}

Future<void> runCompare(ArgResults commandResults) async {
  if (commandResults.rest.length != 1) {
    throw ArgumentError('"compare" command requires a single target.');
  }
  var target = commandResults.rest.single;
  await switch (target) {
    'flutter-warnings' => compareFlutterWarnings(),
    'sdk-warnings' => compareSdkWarnings(),
    _ => throw UnimplementedError('Unknown compare target: "$target"'),
  };
}

Future<void> compareFlutterWarnings() async {
  var originalDartdocFlutter =
      Directory.systemTemp.createTempSync('dartdoc-comparison-flutter');
  var originalDartdoc = await _createComparisonDartdoc();
  var envCurrent = createThrowawayPubCache();
  var envOriginal = createThrowawayPubCache();
  var currentDartdocFlutterBuild = _docFlutter(
    flutterPath: flutterDir.path,
    cwd: Directory.current.path,
    env: envCurrent,
    label: 'docs-current',
  );
  var originalDartdocFlutterBuild = _docFlutter(
    flutterPath: originalDartdocFlutter.path,
    cwd: originalDartdoc,
    env: envOriginal,
    label: 'docs-original',
  );
  var currentDartdocWarnings = _collectWarnings(
    messages: await currentDartdocFlutterBuild,
    tempPath: flutterDir.absolute.path,
    branch: 'HEAD',
    pubDir: envCurrent['PUB_CACHE'],
  );
  var originalDartdocWarnings = _collectWarnings(
    messages: await originalDartdocFlutterBuild,
    tempPath: originalDartdocFlutter.absolute.path,
    branch: _dartdocOriginalBranch,
    pubDir: envOriginal['PUB_CACHE'],
  );

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
      path.join(originalDartdocFlutter.absolute.path, 'dev', 'docs', 'doc'),
    ]);
    var current = launcher.runStreamed(Platform.resolvedExecutable, [
      'pub',
      'global',
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

Future<void> runDoc(ArgResults commandResults) async {
  if (commandResults.rest.length != 1) {
    throw ArgumentError('"doc" command requires a single target.');
  }
  var target = commandResults.rest.single;
  await switch (target) {
    'flutter' => docFlutter(),
    'package' => _docPackage(commandResults),
    'sdk' => docSdk(),
    'testing-package' => docTestingPackage(),
    _ => throw UnimplementedError('Unknown doc target: "$target"'),
  };
}

Future<void> docFlutter() async {
  print('building flutter docs into: $flutterDir');
  var env = createThrowawayPubCache();
  await _docFlutter(
    flutterPath: flutterDir.path,
    cwd: Directory.current.path,
    env: env,
    label: 'docs',
  );
  var indexContents =
      File(path.join(flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
          .readAsLinesSync();
  print([...indexContents.take(25), '...\n'].join('\n'));
}

Future<Iterable<Map<String, Object?>>> _docFlutter({
  required String flutterPath,
  required String cwd,
  required Map<String, String> env,
  String? label,
}) async {
  var flutterRepo = await FlutterRepo.copyFromExistingFlutterRepo(
      await cleanFlutterRepo, flutterPath, env, label);
  try {
    await flutterRepo.launcher.runStreamed(
      flutterRepo.dartCmd,
      ['pub', 'global', 'deactivate', 'snippets'],
    );
  } on SubprocessException {
    // Ignore failure to deactivate so this works on completely clean bots.
  }
  await flutterRepo.launcher.runStreamed(
    flutterRepo.dartCmd,
    ['pub', 'global', 'activate', 'snippets'],
  );
  // TODO(jcollins-g): flutter's dart SDK pub tries to precompile the universe
  // when using -spath.  Why?
  await flutterRepo.launcher.runStreamed(
    flutterRepo.flutterCmd,
    ['pub', 'global', 'activate', '-spath', '.', '-x', 'dartdoc'],
    workingDirectory: cwd,
  );
  await flutterRepo.launcher.runStreamed(
    flutterRepo.flutterCmd,
    ['pub', 'get'],
    workingDirectory: path.join(flutterPath, 'dev', 'tools'),
  );
  return await flutterRepo.launcher.runStreamed(
    flutterRepo.dartCmd,
    [
      '--disable-dart-dev',
      '--enable-asserts',
      path.join(
        'dev',
        'tools',
        'create_api_docs.dart',
      ),
      '--json',
    ],
    workingDirectory: flutterPath,
  );
}

final Directory flutterDir =
    Directory.systemTemp.createTempSync('flutter').absolute;

Future<void> _docPackage(ArgResults commandResults) async {
  var name = commandResults['name'] as String;
  var version = commandResults['version'] as String?;
  await docPackage(name: name, version: version);
}

Future<String> docPackage(
    {required String name, required String? version}) async {
  var env = createThrowawayPubCache();
  var versionContext = version == null ? '' : '-$version';
  var launcher = SubprocessLauncher('build-$name$versionContext', env);
  await launcher.runStreamedDartCommand([
    'pub',
    'cache',
    'add',
    if (version != null) ...['-v', version],
    name,
  ]);
  var cache = Directory(path.join(env['PUB_CACHE']!, 'hosted', 'pub.dev'));
  var pubPackageDirOrig =
      cache.listSync().firstWhere((e) => e.path.contains(name));
  var pubPackageDir = Directory.systemTemp.createTempSync(name);
  io_utils.copy(pubPackageDirOrig, pubPackageDir);

  if (pubPackageMetaProvider
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
          path.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
          '--json',
          '--link-to-remote',
          '--show-progress',
        ],
        environment: flutterRepo.env,
        workingDirectory: pubPackageDir.absolute.path);
  } else {
    await launcher.runStreamedDartCommand(['pub', 'get'],
        workingDirectory: pubPackageDir.absolute.path);
    await launcher.runStreamedDartCommand(
      [
        '--enable-asserts',
        path.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--link-to-remote',
        '--show-progress',
      ],
      workingDirectory: pubPackageDir.absolute.path,
    );
  }
  return path.join(pubPackageDir.absolute.path, 'doc', 'api');
}

Future<void> docSdk() async => _docSdk(
      sdkDocsPath: _sdkDocsDir.path,
      dartdocPath: Directory.current.path,
    );

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> createThrowawayPubCache() {
  var pubCache = Directory.systemTemp.createTempSync('pubcache');
  var pubCacheBin = Directory(path.join(pubCache.path, 'bin'));
  var defaultCache = Directory(_defaultPubCache);
  if (defaultCache.existsSync()) {
    io_utils.copy(defaultCache, pubCache);
  } else {
    pubCacheBin.createSync();
  }
  return Map.fromIterables([
    'PUB_CACHE',
    'PATH',
  ], [
    pubCache.path,
    [pubCacheBin.path, Platform.environment['PATH']].join(':'),
  ]);
}

final String _defaultPubCache = Platform.environment['PUB_CACHE'] ??
    path.context.resolveTildePath('~/.pub-cache');

Future<void> docTestingPackage() async {
  var testPackagePath = testPackage.absolute.path;
  var launcher = SubprocessLauncher('doc-test-package');
  await launcher.runStreamedDartCommand(['pub', 'get'],
      workingDirectory: testPackagePath);
  await launcher.runStreamedDartCommand(
    [
      '--enable-asserts',
      path.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
      '--output',
      _testingPackageDocsDir.absolute.path,
      '--example-path-prefix',
      'examples',
      '--include-source',
      '--json',
      '--link-to-remote',
      '--pretty-index-json',
    ],
    workingDirectory: testPackagePath,
  );
}

final Directory _testingPackageDocsDir =
    Directory.systemTemp.createTempSync('testing_package');

Future<void> compareSdkWarnings() async {
  var originalDartdocSdkDocs =
      Directory.systemTemp.createTempSync('dartdoc-comparison-sdkdocs');
  var originalDartdoc = await _createComparisonDartdoc();
  var sdkDocsPath =
      Directory.systemTemp.createTempSync('sdkdocs').absolute.path;
  var currentDartdocSdkBuild = _docSdk(
    sdkDocsPath: sdkDocsPath,
    dartdocPath: Directory.current.path,
  );
  var originalDartdocSdkBuild = _docSdk(
    sdkDocsPath: originalDartdocSdkDocs.path,
    dartdocPath: originalDartdoc,
  );
  var currentDartdocWarnings = _collectWarnings(
    messages: await currentDartdocSdkBuild,
    tempPath: sdkDocsPath,
    branch: 'HEAD',
  );
  var originalDartdocWarnings = _collectWarnings(
    messages: await originalDartdocSdkBuild,
    tempPath: originalDartdocSdkDocs.absolute.path,
    branch: _dartdocOriginalBranch,
  );

  print(originalDartdocWarnings.warningDeltaText(
      'SDK docs', currentDartdocWarnings));
}

Future<Iterable<Map<String, Object?>>> _docSdk({
  required String sdkDocsPath,
  required String dartdocPath,
}) async {
  var launcher = SubprocessLauncher('build-sdk-docs');
  await launcher
      .runStreamedDartCommand(['pub', 'get'], workingDirectory: dartdocPath);
  return await launcher.runStreamedDartCommand(
    [
      '--enable-asserts',
      path.join('bin', 'dartdoc.dart'),
      '--output',
      sdkDocsPath,
      '--sdk-docs',
      '--json',
      '--show-progress',
    ],
    workingDirectory: dartdocPath,
  );
}

/// Creates a clean version of dartdoc (based on the current directory, assumed
/// to be a git repository).
///
/// Uses [_dartdocOriginalBranch] to checkout a branch or tag.
Future<String> _createComparisonDartdoc() async {
  var launcher = SubprocessLauncher('create-comparison-dartdoc');
  var dartdocClean = Directory.systemTemp.createTempSync('dartdoc-comparison');
  await launcher
      .runStreamed('git', ['clone', Directory.current.path, dartdocClean.path]);
  await launcher.runStreamed('git', ['checkout', _dartdocOriginalBranch],
      workingDirectory: dartdocClean.path);
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: dartdocClean.path);
  return dartdocClean.path;
}

/// Version of dartdoc we should use when making comparisons.
String get _dartdocOriginalBranch {
  var branch = Platform.environment['DARTDOC_ORIGINAL'] ?? 'main';
  print('using branch/tag: $branch for comparison from \$DARTDOC_ORIGINAL');
  return branch;
}

Future<void> runServe(ArgResults commandResults) async {
  if (commandResults.rest.length != 1) {
    throw ArgumentError('"serve" command requires a single target.');
  }
  var target = commandResults.rest.single;
  await switch (target) {
    'flutter' => serveFlutterDocs(),
    'package' => _servePackageDocs(commandResults),
    'sdk' => serveSdkDocs(),
    'testing-package' => serveTestingPackageDocs(),
    _ => throw UnimplementedError('Unknown serve target: "$target"'),
  };
}

Future<void> serveFlutterDocs() async {
  await docFlutter();
  print('launching dhttpd on port 8001 for Flutter');
  var launcher = SubprocessLauncher('serve-flutter-docs');
  await launcher.runStreamedDartCommand(['pub', 'get']);
  await launcher.runStreamedDartCommand([
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8001',
    '--path',
    path.join(flutterDir.path, 'dev', 'docs', 'doc'),
  ]);
}

Future<void> _servePackageDocs(ArgResults commandResults) async {
  var name = commandResults['name'] as String;
  var version = commandResults['version'] as String?;
  await servePackageDocs(name: name, version: version);
}

Future<void> servePackageDocs(
    {required String name, required String? version}) async {
  var packageDocsPath = await docPackage(name: name, version: version);
  await _serveDocsFrom(packageDocsPath, 9000, 'serve-pub-package');
}

Future<void> serveSdkDocs() async {
  await docSdk();
  print('launching dhttpd on port 8000 for SDK');
  await SubprocessLauncher('serve-sdk-docs').runStreamedDartCommand([
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

bool _serveReady = false;

Future<void> _serveDocsFrom(String servePath, int port, String context) async {
  print('launching dhttpd on port $port for $context');
  var launcher = SubprocessLauncher(context);
  if (!_serveReady) {
    await launcher.runStreamedDartCommand(['pub', 'get']);
    await launcher
        .runStreamedDartCommand(['pub', 'global', 'activate', 'dhttpd']);
    _serveReady = true;
  }
  await launcher.runStreamedDartCommand([
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

Future<void> serveTestingPackageDocs() async {
  print('launching dhttpd on port 8002 for SDK');
  var launcher = SubprocessLauncher('serve-test-package-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    'pub',
    'global',
    'run',
    'dhttpd',
    '--port',
    '8002',
    '--path',
    _testingPackageDocsDir.absolute.path,
  ]);
}

Future<void> runTest() async {
  await analyzeTestPackages();
  await SubprocessLauncher('dart run test')
      .runStreamedDartCommand(['--enable-asserts', 'run', 'test']);
}

Future<void> runTryPublish() async {
  await SubprocessLauncher('try-publish')
      .runStreamed(Platform.resolvedExecutable, ['pub', 'publish', '-n']);
}

Future<void> runValidate(ArgResults commandResults) async {
  for (var target in commandResults.rest) {
    await switch (target) {
      'build' => validateBuild(),
      'dartdoc-docs' => validateDartdocDocs(),
      'format' => validateFormat(),
      'sdk-docs' => validateSdkDocs(),
      _ => throw UnimplementedError('Unknown validation target: "$target"'),
    };
  }
}

Future<void> validateBuild() async {
  var originalFileContents = <String, String>{};
  var differentFiles = <String>[];

  // Load original file contents into memory before running the builder; it
  // modifies them in place.
  for (var relPath in _generatedFilesList) {
    var origPath = path.joinAll(['lib', relPath]);
    var oldVersion = File(origPath);
    if (oldVersion.existsSync()) {
      originalFileContents[relPath] = oldVersion.readAsStringSync();
    }
  }

  await buildAll();

  for (var relPath in _generatedFilesList) {
    var newVersion = File(path.join('lib', relPath));
    if (!newVersion.existsSync()) {
      print('${newVersion.path} does not exist\n');
      differentFiles.add(relPath);
    } else {
      var newVersionText = await newVersion.readAsString();
      if (originalFileContents[relPath] != newVersionText) {
        print('${newVersion.path} has changed to: \n$newVersionText)');
        differentFiles.add(relPath);
      }
    }
  }

  if (differentFiles.isNotEmpty) {
    throw StateError('The following generated files needed to be rebuilt:\n'
        '  ${differentFiles.map((f) => path.join('lib', f)).join("\n  ")}\n'
        'Rebuild them with "grind build" and check the results in.');
  }

  // Verify that the web frontend has been compiled.
  final currentCodeSig = await _calcDartFilesSig(Directory('web'));
  final lastCompileSig =
      File(path.join('web', 'sig.txt')).readAsStringSync().trim();
  if (currentCodeSig != lastCompileSig) {
    print('current files: $currentCodeSig');
    print('cached sig   : $lastCompileSig');
    throw StateError(
        'The web frontend (web/docs.dart) needs to be recompiled; rebuild it '
        'with "grind build-web" or "grind build".');
  }
}

/// Paths in this list are relative to lib/.
final _generatedFilesList = [
  '../dartdoc_options.yaml',
  'src/generator/html_resources.g.dart',
  'src/generator/templates.aot_renderers_for_html.dart',
  'src/generator/templates.aot_renderers_for_md.dart',
  'src/generator/templates.runtime_renderers.dart',
  'src/version.dart',
  '../test/mustachio/foo.dart',
].map((s) => path.joinAll(path.posix.split(s)));

Future<void> validateDartdocDocs() async {
  var launcher = SubprocessLauncher('test-dartdoc');
  await launcher.runStreamedDartCommand([
    '--enable-asserts',
    path.join('bin', 'dartdoc.dart'),
    '--output',
    _dartdocDocsPath,
    '--no-link-to-remote',
  ]);
  _expectFileContains(path.join(_dartdocDocsPath, 'index.html'),
      '<title>dartdoc - Dart API docs</title>');
  var objectText = RegExp('<li>Object</li>', multiLine: true);
  _expectFileContains(
    path.join(_dartdocDocsPath, 'dartdoc', 'PubPackageMeta-class.html'),
    objectText,
  );
}

/// Kind of an inefficient grepper for now.
void _expectFileContains(String filePath, Pattern text) {
  var source = File(filePath);
  if (!source.existsSync()) {
    throw StateError('file not found: $filePath');
  }
  if (!File(filePath).readAsStringSync().contains(text)) {
    throw StateError('"$text" not found in $filePath');
  }
}

final String _dartdocDocsPath =
    Directory.systemTemp.createTempSync('dartdoc').path;

Future<void> validateFormat() async {
  var processResult = Process.runSync(Platform.resolvedExecutable, [
    'format',
    '-o',
    'none',
    'bin',
    'lib',
    'test',
    'tool',
    'web',
  ]);
  if (processResult.exitCode != 0) {
    throw StateError('''
Not all files are formatted:

    ${processResult.stderr}
''');
  }
}

Future<void> validateSdkDocs() async {
  await docSdk();
  const expectedLibCount = 0;
  const expectedSubLibCounts = {19, 20, 21};
  const expectedTotalCounts = {19, 20, 21};
  var indexHtml = File(path.join(_sdkDocsDir.path, 'index.html'));
  if (!indexHtml.existsSync()) {
    throw StateError("No 'index.html' found for the SDK docs");
  }
  print("Found 'index.html'");
  var indexContents = indexHtml.readAsStringSync();
  var foundLibCount = _findCount(indexContents, '  <li><a href="dart-');
  if (expectedLibCount != foundLibCount) {
    throw StateError(
        "Expected $expectedLibCount 'dart:' entries in 'index.html', but "
        'found $foundLibCount');
  }
  print("Found $foundLibCount 'dart:' entries in 'index.html'");

  var foundSubLibCount =
      _findCount(indexContents, '<li class="section-subitem"><a href="dart-');
  if (!expectedSubLibCounts.contains(foundSubLibCount)) {
    throw StateError("Expected $expectedSubLibCounts 'dart:' entries in "
        "'index.html' to be in categories, but found $foundSubLibCount");
  }
  print('$foundSubLibCount index.html dart: entries in categories found');

  // check for the existence of certain files/dirs
  var libsCount =
      _sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (!expectedTotalCounts.contains(libsCount)) {
    throw StateError('Docs not generated for all the SDK libraries; expected '
        '$expectedTotalCounts directories, but $libsCount directories were '
        'generated');
  }
  print("Found $libsCount 'dart:' libraries");

  var futureConstructorFile =
      File(path.join(_sdkDocsDir.path, 'dart-async', 'Future', 'Future.html'));
  if (!futureConstructorFile.existsSync()) {
    throw StateError('No Future.html found for dart:async Future constructor');
  }
  print('Found Future.async constructor');
}

/// A temporary directory into which the SDK can be documented.
final Directory _sdkDocsDir =
    Directory.systemTemp.createTempSync('sdkdocs').absolute;

/// Returns the number of (perhaps overlapping) occurrences of [str] in [match].
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

/// Returns a map of warning texts to the number of times each has been seen.
WarningsCollection _collectWarnings({
  required Iterable<Map<Object, Object?>> messages,
  required String tempPath,
  required String branch,
  String? pubDir,
}) {
  var warningTexts = WarningsCollection(tempPath, pubDir, branch);
  for (final message in messages) {
    if (message.containsKey('level') &&
        message['level'] == 'WARNING' &&
        message.containsKey('data')) {
      var data = message['data'] as Map;
      warningTexts.add(data['text'] as String);
    }
  }
  return warningTexts;
}
