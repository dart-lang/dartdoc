// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:async' show Future;
import 'dart:io';

import 'package:dartdoc/dartdoc.dart' show defaultOutDir;
import 'package:dartdoc/src/io_utils.dart';
import 'package:den_api/den_api.dart';
import 'package:grinder/grinder.dart';
import 'package:librato/librato.dart';
import 'package:path/path.dart' as path;

final Directory docsDir =
    new Directory(path.join('${Directory.systemTemp.path}', defaultOutDir));

main([List<String> args]) => grind(args);

@Task('Start observatory for a test run')
observe() async {
  delete(docsDir);
  // TODO: Use `Dart.run` when https://github.com/google/grinder.dart/issues/214
  // is fixed.
  // TODO: uncomment all this when https://code.google.com/p/dart/issues/detail?id=23359
  // is fixed
//  runAsync('dart',
//      arguments: ['--pause-isolates-on-exit', '--enable-vm-service=7334',
//      // TODO: we only need --profile on windows
//      '--profile', 'bin/dartdoc.dart', '--output', '${DOCS_DIR.path}']);
//  await new Future.delayed(const Duration(seconds: 1));
//  runAsync('open', arguments: ['http://localhost:7334']);

  print('Copy and paste this into your console:\n');
  print('open http://localhost:7334');
  print('dart --pause-isolates-on-exit --enable-vm-service=7334 '
      '--profile bin/dartdoc.dart --output ${docsDir.path}');
}

@Task('publish to pub.dartlang')
@Depends(bumpVersionBuild)
publish() async {
  Dart.run('pub', arguments: ['publish']);
}

@Task('Run all the tests.')
test() {
  Dart.runAsync('test/all.dart', vmArgs: ['--checked']);
}

@Task('Bump pubspec version and version number in lib/dartdoc.dart')
bumpVersionBuild() async {
  Pubspec pubspec = (await Pubspec.load())
    ..bump(ReleaseType.build)
    ..save();

  var libCode = new File('lib/dartdoc.dart');
  if (!libCode.existsSync()) {
    fail('Cannot find lib/dartdoc.dart');
  }
  String libCodeContents = libCode.readAsStringSync();
  libCodeContents = libCodeContents.replaceFirst(
      new RegExp(r"const String VERSION = '.*';"),
      "const String VERSION = '${pubspec.version}';");
  libCode.writeAsString(libCodeContents);

  log('Version set to ${pubspec.version}');
}

@Task('Generate docs for dartdoc')
testDartdoc() {
  delete(docsDir);
  try {
    log('running dartdoc');
    Dart.run('bin/dartdoc.dart', arguments: ['--output', '${docsDir.path}']);

    File indexHtml = joinFile(docsDir, ['index.html']);
    if (!indexHtml.existsSync()) fail('docs not generated');
    File docFile = joinFile(docsDir, ['index.html']);
    if (!docFile.existsSync()) fail('docs not generated');
  } catch (e) {
    rethrow;
  }
}

@Task('Analyze dartdoc to ensure there are no errors and warnings')
analyze() {
  Analyzer.analyze(['bin/dartdoc.dart', 'lib/dartdoc.dart', 'test/all.dart'],
      fatalWarnings: true);
}

@Task('Generate docs for the Dart SDK')
Future buildSdkDocs() async {
  delete(docsDir);
  log('building SDK docs');
  try {
    int sdkDocsGenTime = await _runAsyncTimed(() {
      return Dart.runAsync('bin/dartdoc.dart',
          arguments: ['--output', '${docsDir.path}', '--sdk-docs']);
    });
    var indexHtml = joinFile(docsDir, ['index.html']);
    if (!indexHtml.existsSync()) {
      fail('no index.html found for SDK docs');
    }
    // check for the existence of certain files/dirs
    var libsLength =
        docsDir.listSync().where((fs) => fs.path.contains('dart_')).length;
    if (libsLength != 17) {
      fail('docs not generated for all the SDK libraries, '
          'expected 17 directories, generated $libsLength directories');
    }
    var futureConstFile =
        joinFile(docsDir, [path.join('dart_async', 'Future', 'Future.html')]);
    if (!futureConstFile.existsSync()) {
      fail('no Future.html found for dart:async Future constructor');
    }

    return _uploadStats(sdkDocsGenTime);
  } catch (e) {
    rethrow;
  }
}

@Task('Make sure all the resource files are present')
indexResources() {
  var sourcePath = path.join('lib', 'resources');
  if (!new Directory(sourcePath).existsSync()) {
    throw new StateError('lib/resources directory not found');
  }
  var outDir = new Directory(path.join('lib'));
  var out = new File(path.join(outDir.path, 'resources.g.dart'));
  out.createSync(recursive: true);
  var buffer = new StringBuffer()
    ..write('// WARNING: This file is auto-generated.\n\n')
    ..write('library resources;\n\n')
    ..write('const List<String> RESOURCE_NAMES = const [\n');
  var packagePaths = [];
  for (var fileName in listDir(sourcePath, recursive: true)) {
    if (!FileSystemEntity.isDirectorySync(fileName)) {
      var packageified = fileName.replaceFirst('lib/', 'package:dartdoc/');
      packagePaths.add(packageified);
    }
  }
  buffer.write(packagePaths.map((p) => "  '$p'").join(',\n'));
  buffer.write('\n];\n');
  out.writeAsString(buffer.toString());
}

@Task('analyze, test, and self-test dartdoc')
@Depends(analyze, test, testDartdoc)
buildbot() => null;

@Task('Push a copy of the dartdoc docs to firebase')
firebase() {
  Map env = Platform.environment;

  if (env['FIREBASE_USER'] == null) return;
  if (env['TRAVIS_DART_VERSION'] != 'stable') return;

  // Build the docs.
  Dart.run('bin/dartdoc.dart');

  // Install the firebase tools.
  run('npm', arguments: ['install', '-g', 'firebase-tools']);

  print('has user = ${env['FIREBASE_USER'] != null}');
  print('has pass = ${env['FIREBASE_PASSWORD'] != null}');

  // Authenticate with firebase.
  run('firebase',
      arguments: [
    'login',
    '--email',
    env['FIREBASE_USER'],
    '--password',
    env['FIREBASE_PASSWORD'],
    '-s'
  ],
      quiet: true);

  // Deploy to firebase.
  run('firebase',
      arguments: ['deploy', '-s', '--message', env['TRAVIS_COMMIT']]);
}

Future<int> _runAsyncTimed(Future callback()) async {
  var stopwatch = new Stopwatch()..start();
  await callback();
  stopwatch.stop();
  return stopwatch.elapsedMilliseconds;
}

Future _uploadStats(int sdkDocsGenTime) async {
  Map env = Platform.environment;

  if (env.containsKey('LIBRATO_USER') && env.containsKey('TRAVIS_COMMIT')) {
    Librato librato = new Librato.fromEnvVars();
    log('Uploading stats to ${librato.baseUrl}');
    LibratoStat sdkDocsGenTimeStat =
        new LibratoStat('sdk-docs-gen-time', sdkDocsGenTime);
    await librato.postStats([sdkDocsGenTimeStat]);
    String commit = env['TRAVIS_COMMIT'];
    LibratoLink link = new LibratoLink(
        'github', 'https://github.com/dart-lang/dart-pad/commit/${commit}');
    LibratoAnnotation annotation = new LibratoAnnotation(commit,
        description: 'Commit ${commit}', links: [link]);
    return librato.createAnnotation('build_ui', annotation);
  }
}
