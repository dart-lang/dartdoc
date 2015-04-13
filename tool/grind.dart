// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as path;
import 'package:dartdoc/src/io_utils.dart';

final Directory DOC_DIR = new Directory(DEFAULT_OUTPUT_DIRECTORY);

main([List<String> args]) {
  task('init', defaultInit);
  task('docitself', testDartdoc, ['init']);
  task('analyze', analyze);
  task('indexresources', indexResources);
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
    var destFileName = fileName.substring(sourcePath.length + 1);
    if (!FileSystemEntity.isDirectorySync(fileName)) {
      var packageified = fileName.replaceFirst('lib/', 'package:dartdoc/');
      packagePaths.add(packageified);
    }
  }
  buffer.write(packagePaths.map((p) => "  '$p'").join(',\n'));
  buffer.write('\n];\n');
  out.writeAsString(buffer.toString());
}
