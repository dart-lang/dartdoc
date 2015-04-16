// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:async' show Future;

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:dartdoc/src/io_utils.dart';
import 'package:librato/librato.dart';

final Directory DOC_DIR = new Directory('docs');

main([List<String> args]) {
  task('init', defaultInit);
  task('docitself', testDartdoc, ['init']);
  task('analyze', analyze);
  task('indexresources', indexResources);
  task('buildsdkdocs', buildSdkDocs);
  startGrinder(args);
}

/**
 * Run dartdoc and check that the docs are generated.
 */
testDartdoc(GrinderContext context) {
  if (DOC_DIR.existsSync()) DOC_DIR.deleteSync(recursive: true);

  try {
    context.log('running dartdoc');
    runDartScript(context, 'bin/dartdoc.dart');

    File indexHtml = joinFile(DOC_DIR, ['index.html']);
    if (!indexHtml.existsSync()) context.fail('docs not generated');
    File docFile = joinFile(DOC_DIR, ['dartdoc/index.html']);
    if (!docFile.existsSync()) context.fail('docs not generated');
  } catch (e) {
    rethrow;
  }
}

analyze(GrinderContext context) {
  Analyzer.analyzePaths(
      context, ['bin/dartdoc.dart', 'lib/dartdoc.dart', 'test/all.dart'],
      fatalWarnings: true);
}

Future buildSdkDocs(GrinderContext context) async {
  if (DOC_DIR.existsSync()) DOC_DIR.deleteSync(recursive: true);
  context.log('building SDK docs');
  try {
    int sdkDocsGenTime = _runTimed(() {
      runDartScript(context, 'bin/dartdoc.dart', arguments: ['--sdk-docs']);
    });
    var indexHtml = joinFile(DOC_DIR, ['index.html']);
    if (!indexHtml.existsSync()) {
      context.fail('no index.html found for SDK docs');
    }
    // check for the existance of certain files/dirs
    var libsLength =
        DOC_DIR.listSync().where((fs) => fs.path.contains('dart_')).length;
    if (libsLength != 17) {
      context.fail(
          'docs not generated for all the SDK libraries, expected 17 directories, generated $libsLength directories');
    }
    var futureConstFile = joinFile(DOC_DIR, ['dart_async/Future/Future.html']);
    if (!futureConstFile.existsSync()) {
      context.fail('no Future.html found for dart:async Future constructor');
    }

    return _uploadStats(context, sdkDocsGenTime);
  } catch (e) {
    rethrow;
  }
}

indexResources(GrinderContext context) {
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

int _runTimed(callback()) {
  var stopwatch = new Stopwatch()..start();
  callback();
  stopwatch.stop();
  return stopwatch.elapsedMilliseconds;
}

Future _uploadStats(GrinderContext context, int sdkDocsGenTime) async {
  Map env = Platform.environment;

  if (env.containsKey('LIBRATO_USER') && env.containsKey('TRAVIS_COMMIT')) {
    Librato librato = new Librato.fromEnvVars();
    context.log('Uploading stats to ${librato.baseUrl}');
    LibratoStat sdkDocsGenTimeStat =
        new LibratoStat('sdk-docs-gen-time', sdkDocsGenTime);
    await librato.postStats([sdkDocsGenTimeStat]);
    String commit = env['TRAVIS_COMMIT'];
    LibratoLink link = new LibratoLink(
        'github', 'https://github.com/dart-lang/dart-pad/commit/${commit}');
    LibratoAnnotation annotation = new LibratoAnnotation(commit,
        description: 'Commit ${commit}', links: [link]);
    return librato.createAnnotation('build_ui', annotation);
  } else {
    return true;
  }
}
