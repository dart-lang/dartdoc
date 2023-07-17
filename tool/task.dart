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
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

import 'src/flutter_repo.dart';
import 'src/io_utils.dart' as io_utils;
import 'src/subprocess_launcher.dart';
import 'src/warnings_collection.dart';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addCommand('build');
  parser.addCommand('doc');
  parser.addCommand('serve');
  parser.addCommand('try-publish');
  var results = parser.parse(args);
  var commandResults = results.command;
  if (commandResults == null) {
    return;
  }

  return switch (commandResults.name) {
    'analyze' => await runAnalyze(commandResults),
    'build' => await runBuild(commandResults),
    'doc' => await runDoc(commandResults),
    // TODO(srawlins): Implement tasks that serve various docs, after generating
    // them.
    'serve' => await runServe(commandResults),
    'test' => await runTest(),
    'try-publish' => await runTryPublish(),
    'validate' => await runValidate(commandResults),
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

Directory get testPackage => Directory(p.joinAll(['testing', 'test_package']));

Directory get testPackageExperiments =>
    Directory(p.joinAll(['testing', 'test_package_experiments']));

Future<void> runAnalyze(ArgResults commandResults) async {
  for (var target in commandResults.rest) {
    // ignore: unnecessary_statements, unnecessary_parenthesis
    (switch (target) {
      'package' => await analyzePackage(),
      'test-packages' => await analyzeTestPackages(),
      _ => throw UnimplementedError('Unknown analyze target: "$target"'),
    });
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
  for (var path in testPackagePaths) {
    await SubprocessLauncher('pub-get').runStreamedDartCommand(
      ['pub', 'get'],
      workingDirectory: path,
    );
    await SubprocessLauncher('analyze-test-package').runStreamedDartCommand(
      // TODO(srawlins): Analyze the whole directory by ignoring the pubspec
      // reports.
      ['analyze', 'lib'],
      workingDirectory: path,
    );
  }
}

Future<void> runBuild(ArgResults commandResults) async {
  for (var target in commandResults.rest) {
    // ignore: unnecessary_statements, unnecessary_parenthesis
    (switch (target) {
      'renderers' => await buildRenderers(),
      'dartdoc-options' => await buildDartdocOptions(),
      'web' => await buildWeb(),
      _ => throw UnimplementedError('Unknown build target: "$target"'),
    });
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
    .runStreamedDartCommand([p.join('tool', 'mustachio', 'builder.dart')]);

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
  delete(File('lib/resources/docs.dart.js.deps'));

  var compileSig = await calcDartFilesSig(Directory('web'));
  File(p.join('web', 'sig.txt')).writeAsStringSync('$compileSig\n');
}

/// Delete the given file entity reference.
void delete(FileSystemEntity entity) {
  if (entity.existsSync()) {
    print('deleting ${entity.path}');
    entity.deleteSync(recursive: true);
  }
}

Future<String> calcDartFilesSig(Directory dir) async {
  final digest = await _dartFileLines(dir)
      .transform(utf8.encoder)
      .transform(crypto.md5)
      .single;

  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();
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

Future<void> runDoc(ArgResults commandResults) async {
  if (commandResults.rest.length != 1) {
    throw ArgumentError('"doc" command requires a single target.');
  }
  var target = commandResults.rest.single;
  // ignore: unnecessary_statements, unnecessary_parenthesis
  (switch (target) {
    'sdk' => await docSdk(),
    'package' => await _docPackage(commandResults),
    _ => throw UnimplementedError('Unknown doc target: "$target"'),
  });
}

/// A temporary directory into which the SDK can be documented.
final Directory sdkDocsDir =
    Directory.systemTemp.createTempSync('sdkdocs').absolute;

Future<void> docSdk() async => _docSdk(
      sdkDocsPath: sdkDocsDir.path,
      dartdocPath: Directory.current.path,
    );

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
  var cache = Directory(p.join(env['PUB_CACHE']!, 'hosted', 'pub.dev'));
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
          p.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
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
        p.join(Directory.current.absolute.path, 'bin', 'dartdoc.dart'),
        '--json',
        '--link-to-remote',
        '--show-progress',
      ],
      workingDirectory: pubPackageDir.absolute.path,
    );
  }
  return p.join(pubPackageDir.absolute.path, 'doc', 'api');
}

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> createThrowawayPubCache() {
  var pubCache = Directory.systemTemp.createTempSync('pubcache');
  var pubCacheBin = Directory(p.join(pubCache.path, 'bin'));
  var defaultCache = Directory(defaultPubCache);
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

final String defaultPubCache = Platform.environment['PUB_CACHE'] ??
    p.context.resolveTildePath('~/.pub-cache');

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
  var currentDartdocWarnings = _jsonMessageIterableToWarnings(
    await currentDartdocSdkBuild,
    tempPath: sdkDocsPath,
    branch: 'HEAD',
  );
  var originalDartdocWarnings = _jsonMessageIterableToWarnings(
    await originalDartdocSdkBuild,
    tempPath: originalDartdocSdkDocs.absolute.path,
    branch: _dartdocOriginalBranch,
  );

  print(originalDartdocWarnings.warningDeltaText(
      'SDK docs', currentDartdocWarnings));
}

/// Returns a map of warning texts to the number of times each has been seen.
WarningsCollection _jsonMessageIterableToWarnings(
  Iterable<Map<Object, Object?>> messageIterable, {
  required String tempPath,
  required String branch,
  String? pubDir,
}) {
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
      p.join('bin', 'dartdoc.dart'),
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
  // ignore: unnecessary_statements, unnecessary_parenthesis
  (switch (target) {
    'sdk' => await serveSdkDocs(),
    'package' => await _servePackageDocs(commandResults),
    _ => throw UnimplementedError('Unknown serve target: "$target"'),
  });
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
    sdkDocsDir.path,
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
    // ignore: unnecessary_statements, unnecessary_parenthesis
    (switch (target) {
      'build' => await validateBuild(),
      'dartdoc-docs' => await validateDartdocDocs(),
      'format' => await validateFormat(),
      'sdk-docs' => await validateSdkDocs(),
      _ => throw UnimplementedError('Unknown validation target: "$target"'),
    });
  }
}

Future<void> validateBuild() async {
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

  await buildAll();

  for (var relPath in _generatedFilesList) {
    var newVersion = File(p.join('lib', relPath));
    if (!newVersion.existsSync()) {
      print('${newVersion.path} does not exist\n');
      differentFiles.add(relPath);
    } else if (originalFileContents[relPath] !=
        await newVersion.readAsString()) {
      print(
          '${newVersion.path} has changed to: \n${newVersion.readAsStringSync()})');
      differentFiles.add(relPath);
    }
  }

  if (differentFiles.isNotEmpty) {
    throw StateError('The following generated files needed to be rebuilt:\n'
        '  ${differentFiles.map((f) => p.join('lib', f)).join("\n  ")}\n'
        'Rebuild them with "grind build" and check the results in.');
  }

  // Verify that the web frontend has been compiled.
  final currentCodeSig = await calcDartFilesSig(Directory('web'));
  final lastCompileSig =
      File(p.join('web', 'sig.txt')).readAsStringSync().trim();
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
].map((s) => p.joinAll(p.posix.split(s)));

Future<void> validateDartdocDocs() async {
  var launcher = SubprocessLauncher('test-dartdoc');
  await launcher.runStreamedDartCommand([
    '--enable-asserts',
    'bin/dartdoc.dart',
    '--output',
    _dartdocDocsPath,
    '--no-link-to-remote',
  ]);
  _expectFileContains(p.join(_dartdocDocsPath, 'index.html'),
      '<title>dartdoc - Dart API docs</title>');
  var objectText = RegExp('<li>Object</li>', multiLine: true);
  _expectFileContains(
    p.join(_dartdocDocsPath, 'dartdoc', 'PubPackageMeta-class.html'),
    objectText,
  );
}

/// Kind of an inefficient grepper for now.
void _expectFileContains(String path, Pattern text) {
  var source = File(path);
  if (!source.existsSync()) {
    throw StateError('file not found: $path');
  }
  if (!File(path).readAsStringSync().contains(text)) {
    throw StateError('"$text" not found in $path');
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
  var indexHtml = File(p.join(sdkDocsDir.path, 'index.html'));
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
      sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (!expectedTotalCounts.contains(libsCount)) {
    throw StateError('Docs not generated for all the SDK libraries; expected '
        '$expectedTotalCounts directories, but $libsCount directories were '
        'generated');
  }
  print("Found $libsCount 'dart:' libraries");

  var futureConstructorFile =
      File(p.join(sdkDocsDir.path, 'dart-async', 'Future', 'Future.html'));
  if (!futureConstructorFile.existsSync()) {
    throw StateError('No Future.html found for dart:async Future constructor');
  }
  print('Found Future.async constructor');
}

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
