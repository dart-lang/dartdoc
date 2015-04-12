// Copyright (c) 2015, Google Inc. Please see the AUTHORS file for details.
// All rights reserved. Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:grinder/grinder.dart';

final Directory DOC_DIR = new Directory(DEFAULT_OUTPUT_DIRECTORY);

main([List<String> args]) {
  task('init', defaultInit);
  task('docitself', testDartdoc, ['init']);
  task('analyze', analyze);
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