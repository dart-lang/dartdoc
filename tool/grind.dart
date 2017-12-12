// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' hide ProcessException;

import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

main([List<String> args]) => grind(args);

final Memoizer tempdirsCache = new Memoizer();

Directory get dartdocDocsDir =>
    tempdirsCache.memoized1(Directory.systemTemp.createTempSync, 'dartdoc');
Directory get sdkDocsDir =>
    tempdirsCache.memoized1(Directory.systemTemp.createTempSync, 'sdkdocs');
Directory get flutterDir =>
    tempdirsCache.memoized1(Directory.systemTemp.createTempSync, 'flutter');

final Directory flutterDirDevTools =
    new Directory(path.join(flutterDir.path, 'dev', 'tools'));

final RegExp quotables = new RegExp(r'[ "\r\n\$]');
// from flutter:dev/tools/dartdoc.dart, modified
void _printStream(Stream<List<int>> stream, Stdout output,
    {String prefix: ''}) {
  assert(prefix != null);
  stream
      .transform(UTF8.decoder)
      .transform(const LineSplitter())
      .listen((String line) {
    output.write('$prefix$line'.trim());
    output.write('\n');
  });
}

/// Creates a throwaway pub cache and returns the environment variables
/// necessary to use it.
Map<String, String> _createThrowawayPubCache() {
  final Directory pubCache = Directory.systemTemp.createTempSync('pubcache');
  final Directory pubCacheBin = new Directory(path.join(pubCache.path, 'bin'));
  pubCacheBin.createSync();
  return new Map.fromIterables([
    'PUB_CACHE',
    'PATH'
  ], [
    pubCache.path,
    [pubCacheBin.path, Platform.environment['PATH']].join(':')
  ]);
}

class _SubprocessLauncher {
  final String context;
  Map<String, String> _environment;

  Map<String, String> get environment => _environment;

  String get prefix => context.isNotEmpty ? '$context: ' : '';

  _SubprocessLauncher(this.context, [Map<String, String> environment]) {
    if (environment == null) this._environment = new Map();
  }

  /// A wrapper around start/await process.exitCode that will display the
  /// output of the executable continuously and fail on non-zero exit codes.
  /// Makes running programs in grinder similar to set -ex for bash, even on
  /// Windows (though some of the bashisms will no longer make sense).
  /// TODO(jcollins-g): move this to grinder?
  Future runStreamed(String executable, List<String> arguments,
      {String workingDirectory}) async {
    stderr.write('$prefix+ ');
    if (workingDirectory != null) stderr.write('cd "$workingDirectory" && ');
    if (environment != null) {
      stderr.write(environment.keys.map((String key) {
        if (environment[key].contains(quotables)) {
          return "$key='${environment[key]}'";
        } else {
          return "$key=${environment[key]}";
        }
      }).join(' '));
      stderr.write(' ');
    }
    stderr.write('$executable');
    if (arguments.isNotEmpty) {
      for (String arg in arguments) {
        if (arg.contains(quotables)) {
          stderr.write(" '$arg'");
        } else {
          stderr.write(" $arg");
        }
      }
    }
    if (workingDirectory != null) stderr.write(')');
    stderr.write('\n');
    Process process = await Process.start(executable, arguments,
        workingDirectory: workingDirectory, environment: environment);

    _printStream(process.stdout, stdout, prefix: prefix);
    _printStream(process.stderr, stderr, prefix: prefix);
    await process.exitCode;

    int exitCode = await process.exitCode;
    if (exitCode != 0) {
      fail("exitCode: $exitCode");
    }
  }
}

@Task('Analyze dartdoc to ensure there are no errors and warnings')
analyze() async {
  await new _SubprocessLauncher('analyze').runStreamed(
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
  var launcher = new _SubprocessLauncher('build-sdk-docs');
  await launcher.runStreamed(Platform.resolvedExecutable, [
    '--checked',
    'bin/dartdoc.dart',
    '--output',
    '${sdkDocsDir.path}',
    '--sdk-docs',
    '--show-progress'
  ]);
}

@Task('Serve generated SDK docs locally with dhttpd on port 8000')
@Depends(buildSdkDocs)
Future serveSdkDocs() async {
  log('launching dhttpd on port 8000 for SDK');
  var launcher = new _SubprocessLauncher('serve-sdk-docs');
  await launcher.runStreamed(sdkBin('pub'), [
    'run',
    'dhttpd',
    '--port',
    '8000',
    '--path',
    '${sdkDocsDir.path}',
  ]);
}

@Task('Serve generated Flutter docs locally with dhttpd on port 8001')
@Depends(buildFlutterDocs)
Future serveFlutterDocs() async {
  log('launching dhttpd on port 8001 for Flutter');
  var launcher = new _SubprocessLauncher('serve-flutter-docs');
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

@Task('Build flutter docs')
Future buildFlutterDocs() async {
  log('building flutter docs into: $flutterDir');
  var launcher =
      new _SubprocessLauncher('build-flutter-docs', _createThrowawayPubCache());
  await launcher.runStreamed('git',
      ['clone', '--depth', '1', 'https://github.com/flutter/flutter.git', '.'],
      workingDirectory: flutterDir.path);
  String flutterBin = path.join('bin', 'flutter');
  String flutterCacheDart =
      path.join(flutterDir.path, 'bin', 'cache', 'dart-sdk', 'bin', 'dart');
  String flutterCachePub =
      path.join(flutterDir.path, 'bin', 'cache', 'dart-sdk', 'bin', 'pub');
  await launcher.runStreamed(
    flutterBin,
    ['--version'],
    workingDirectory: flutterDir.path,
  );
  await launcher.runStreamed(
    flutterBin,
    ['precache'],
    workingDirectory: flutterDir.path,
  );
  await launcher.runStreamed(
    flutterCachePub,
    ['get'],
    workingDirectory: path.join(flutterDir.path, 'dev', 'tools'),
  );
  await launcher
      .runStreamed(flutterCachePub, ['global', 'activate', '-spath', '.']);
  await launcher.runStreamed(
    flutterCacheDart,
    [path.join('dev', 'tools', 'dartdoc.dart')],
    workingDirectory: flutterDir.path,
  );
  String index =
      new File(path.join(flutterDir.path, 'dev', 'docs', 'doc', 'index.html'))
          .readAsStringSync();
  stdout.write(index);
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
  var sourcePath = path.join('lib', 'resources');
  if (!new Directory(sourcePath).existsSync()) {
    throw new StateError('lib/resources directory not found');
  }
  var outDir = new Directory(path.join('lib'));
  var out = new File(path.join(outDir.path, 'src', 'html', 'resources.g.dart'));
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
  // `pub run test` is a bit slower than running an `test_all.dart` script
  // But it provides more useful output in the case of failures.
  await new _SubprocessLauncher('test')
      .runStreamed(sdkBin('pub'), ['run', 'test']);
}

@Task('Generate docs for dartdoc')
testDartdoc() async {
  var launcher = new _SubprocessLauncher('test-dartdoc');
  await launcher.runStreamed(Platform.resolvedExecutable,
      ['--checked', 'bin/dartdoc.dart', '--output', dartdocDocsDir.path]);
  File indexHtml = joinFile(dartdocDocsDir, ['index.html']);
  if (!indexHtml.existsSync()) fail('docs not generated');
}

@Task('update test_package_docs')
updateTestPackageDocs() async {
  var launcher = new _SubprocessLauncher('update-test-package-docs');
  var testPackageDocs =
      new Directory(path.join('testing', 'test_package_docs'));
  var testPackage = new Directory(path.join('testing', 'test_package'));
  await launcher.runStreamed(sdkBin('pub'), ['get'],
      workingDirectory: testPackage.path);
  delete(testPackageDocs);
  // This must be synced with ../test/compare_output_test.dart's
  // "Validate html output of test_package" test.
  await launcher.runStreamed(
      Platform.resolvedExecutable,
      [
        '--checked',
        path.join('..', '..', 'bin', 'dartdoc.dart'),
        '--auto-include-dependencies',
        '--example-path-prefix',
        'examples',
        '--no-include-source',
        '--pretty-index-json',
        '--hide-sdk-text',
        '--exclude',
        'dart.async,dart.collection,dart.convert,dart.core,dart.math,dart.typed_data,package:meta/meta.dart',
        '--output',
        '../test_package_docs',
      ],
      workingDirectory: testPackage.path);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
validateSdkDocs() {
  const expectedLibCount = 18;

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

  // check for the existence of certain files/dirs
  var libsLength =
      sdkDocsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (libsLength != expectedLibCount) {
    fail('docs not generated for all the SDK libraries, '
        'expected $expectedLibCount directories, generated $libsLength directories');
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
  int count = 0;
  int index = str.indexOf(match);
  while (index != -1) {
    count++;
    index = str.indexOf(match, index + match.length);
  }
  return count;
}
