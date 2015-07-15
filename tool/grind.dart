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
import 'package:yaml/yaml.dart' as yaml;

final Directory docsDir =
    new Directory(path.join('${Directory.systemTemp.path}', defaultOutDir));

final String sep = Platform.pathSeparator;

main([List<String> args]) => grind(args);

@Task('Find transformers used by this project')
findTransformers() async {
  var dotPackages = new File('.packages');
  if (!dotPackages.existsSync()) {
    print('No .packages file found in ${Directory.current}');
    exit(1);
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
        print('${mapping.first} has transformers!');
        foundAnyTransformers = true;
      }
    } else {
      print('No pubspec found for ${mapping.first}, tried ${pubspec}');
    }
  });

  if (!foundAnyTransformers) {
    print('No transformers found');
  }
}

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

@Task('Preflight checks to publish to pub.dartlang')
@Depends(checkChangelogHasVersion, checkVersionMatches)
publishPreflight() {}

@Task('Checks that version is matched in relevant places')
checkVersionMatches() async {
  Pubspec pubspec = await Pubspec.load();

  var libCode = new File('lib/dartdoc.dart');
  if (!libCode.existsSync()) {
    fail('Cannot find lib/dartdoc.dart in ${Directory.current}');
  }
  String libCodeContents = libCode.readAsStringSync();

  if (!libCodeContents
      .contains("const String version = '${pubspec.version}';")) {
    fail('Version string for ${pubspec.version} not found in lib/dartdoc.dart');
  }
}

@Task('Checks that CHANGELOG mentions current version')
checkChangelogHasVersion() async {
  // TODO: use fail() when
  // https://github.com/google/grinder.dart/issues/288 lands

  var changelog = new File('CHANGELOG.md');
  if (!changelog.existsSync()) {
    print('ERROR: No CHANGELOG.md found in ${Directory.current}');
    exit(1);
  }

  Pubspec pubspec = await Pubspec.load();

  if (!changelog.readAsLinesSync().contains('## ${pubspec.version}')) {
    print('ERROR: CHANGELOG.md does not mention version ${pubspec.version}');
    exit(1);
  }
}

@Task('Run all the tests.')
test() {
  // this is 5 seconds faster than `pub run test`, so
  // using straight-up VM here
  Dart.runAsync('test/all.dart', vmArgs: ['--checked']);
}

@Task('Bump build num in pubspec and lib/dartdoc.dart')
bumpVersionBuild() async {
  Pubspec pubspec = (await Pubspec.load())
    ..bump(ReleaseType.build)
    ..save();

  var libCode = new File('lib/dartdoc.dart');
  if (!libCode.existsSync()) {
    fail('Cannot find lib/dartdoc.dart in ${Directory.current}');
  }
  String libCodeContents = libCode.readAsStringSync();
  libCodeContents = libCodeContents.replaceFirst(
      new RegExp(r"const String version = '.*';"),
      "const String version = '${pubspec.version}';");
  libCode.writeAsStringSync(libCodeContents);

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
  var out = new File(path.join(outDir.path, 'src${sep}resources.g.dart'));
  out.createSync(recursive: true);
  var buffer = new StringBuffer()
    ..write('// WARNING: This file is auto-generated.\n\n')
    ..write('library resources;\n\n')
    ..write('const List<String> resource_names = const [\n');
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

  // Authenticate with firebase.
  run('firebase',
      arguments: [
    'login',
    '--email',
    env['FIREBASE_USER'],
    '--password',
    env['FIREBASE_TOKEN'],
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
