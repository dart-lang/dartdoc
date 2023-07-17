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
