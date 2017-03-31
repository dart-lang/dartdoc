// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async' show Completer, Future, Stream;
import 'dart:io' hide ProcessException;

import 'package:dartdoc/dartdoc.dart' show defaultOutDir;
import 'package:dartdoc/src/io_utils.dart';
import 'package:grinder/grinder.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart' as yaml;

main([List<String> args]) => grind(args);

final Directory docsDir =
    new Directory(path.join('${Directory.systemTemp.path}', defaultOutDir));

@Task('Analyze dartdoc to ensure there are no errors and warnings')
analyze() {
  Analyzer.analyze(['bin/dartdoc.dart', 'lib/dartdoc.dart', 'test/all.dart'],
      fatalWarnings: true);
}

@Task('analyze, test, and self-test dartdoc')
@Depends(analyze, test, testDartdoc)
buildbot() => null;

@Task('Generate docs for the Dart SDK')
Future buildSdkDocs() async {
  delete(docsDir);
  log('building SDK docs');
  Process process = await Process.start(Platform.resolvedExecutable, [
    'bin/dartdoc.dart',
    '--output',
    '${docsDir.path}',
    '--sdk-docs',
    '--show-progress'
  ]);
  stdout.addStream(process.stdout);
  stderr.addStream(process.stderr);

  int exitCode = await process.exitCode;
  if (exitCode != 0) {
    fail("exitCode: $exitCode");
  }
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

@Task('Check links')
checkLinks() {
  bool foundError = false;
  Set<String> visited = new Set();
  final origin = 'testing/test_package_docs/';
  var start = 'index.html';

  _doCheck(origin, visited, start, foundError);
  _doFileCheck(origin, visited, foundError);

  if (foundError) exit(1);
}

@Task('Check sdk links')
checkSdkLinks() {
  bool foundError = false;
  Set<String> visited = new Set();
  final origin = '${docsDir.path}/';
  var start = 'index.html';

  _doCheck(origin, visited, start, foundError);

  if (foundError) exit(1);
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
  await run('pub', arguments: ['publish', '--force']);
}

@Task('Run all the tests.')
test() {
  // this is 5 seconds faster than `pub run test`, so
  // using straight-up VM here
  return Dart.runAsync('test/all.dart', vmArgs: ['--checked']);
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

@Task('update test_package_docs')
updateTestPackageDocs() {
  var options = new RunOptions(workingDirectory: 'testing/test_package');
  delete(getDir('testing/test_package_docs'));
  Dart.run('../../bin/dartdoc.dart',
      arguments: [
        '--no-include-source',
        '--output',
        '../test_package_docs',
        '--example-path-prefix',
        'examples',
        '--auto-include-dependencies',
        '--pretty-index-json'
      ],
      runOptions: options);
}

@Task('Validate the SDK doc build.')
@Depends(buildSdkDocs)
validateSdkDocs() {
  const expectedLibCount = 18;

  File indexHtml = joinFile(docsDir, ['index.html']);
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
      docsDir.listSync().where((fs) => fs.path.contains('dart-')).length;
  if (libsLength != expectedLibCount) {
    fail('docs not generated for all the SDK libraries, '
        'expected $expectedLibCount directories, generated $libsLength directories');
  }
  log('$libsLength dart: libraries found');

  var futureConstFile =
      joinFile(docsDir, [path.join('dart-async', 'Future', 'Future.html')]);
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

Stream<FileSystemEntity> dirContents(String dir) {
  var files = <FileSystemEntity>[];
  var lister = new Directory(dir).list(recursive: true);
  return lister;
}


_doFileCheck(String origin, Set<String> visited, bool error) {
  String normalOrigin = path.normalize(origin);
  dirContents(normalOrigin).toList().then((allFiles) {
    bool foundIndex = false;
    for (FileSystemEntity f in allFiles) {
      if (f is Directory) continue;
      var fullPath = path.normalize(f.path);
      if (fullPath.startsWith("${normalOrigin}/static-assets/")) continue;
      if (fullPath == "${normalOrigin}/index.json") {
        foundIndex = true;
        continue;
      }
      if (visited.contains(fullPath))
        continue;
      log('   * Orphaned: $fullPath');
      error = true;
    }
    if (!foundIndex) {
      log('  * Not found: ${normalOrigin}/index.json');
      error = true;
    }
  });

}

_doCheck(String origin, Set<String> visited, String pathToCheck, bool error,
    [String source]) {
  var fullPath = path.normalize("$origin$pathToCheck");
  if (visited.contains(fullPath)) return;
  visited.add(fullPath);

  File file = new File("$fullPath");
  if (!file.existsSync()) {
    // There is a deliberately broken link in one place.
    if (!fullPath.endsWith("ftp:/ftp.myfakepackage.com/donthidemyschema")) {
      error = true;
      log('  * Not found: $fullPath from $source');
    }
    return;
  }
  Document doc = parse(file.readAsStringSync());
  Element base = doc.querySelector('base');
  String baseHref;
  if (base != null) {
    baseHref = base.attributes['href'];
  }
  List<Element> links = doc.querySelectorAll('a');
  links
      .map((link) => link.attributes['href'])
      .where((href) => href != null)
      .forEach((href) {
    if (!href.startsWith('http') && !href.contains('#')) {
      var full;
      if (baseHref != null) {
        full = '${path.dirname(pathToCheck)}/$baseHref/$href';
      } else {
        full = '${path.dirname(pathToCheck)}/$href';
      }
      var normalized = path.normalize(full);
      _doCheck(origin, visited, normalized, error, pathToCheck);
    }
  });
}
