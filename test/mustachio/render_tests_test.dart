// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This test does not need to be run on all platforms.
@OnPlatform({'windows': Skip()})
import 'dart:io';
import 'dart:isolate' show Isolate;

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  test(
      'aot_compiler_render_test has same test cases as runtime_renderer_render_test',
      () async {
    var testCasePattern = RegExp(r'test\(.*,');
    var dartdocLibUri = await Isolate.resolvePackageUri(
        Uri.parse('package:dartdoc/dartdoc.dart'));
    var dartdocPath = p.dirname(p.dirname(dartdocLibUri.path));
    var runtimeRendererRenderTest = File(p.join(dartdocPath, 'test',
            'mustachio', 'runtime_renderer_render_test.dart'))
        .readAsLinesSync();
    var runtimeRendererTestCases = runtimeRendererRenderTest
        .where((line) => line.contains('test('))
        // Ignore tests about the runtime renderers' property maps.
        .where((line) => !line.contains('property map contains'))
        .where((line) => !line.contains('Property returns'))
        .where((line) => !line.contains('isNullValue'))
        // Ignore tests about the Parser.
        .where((line) => !line.contains('Parser '))
        // Ignore tests about the SimpleRenderer.
        .where((line) => !line.contains('SimpleRenderer'))
        .map((line) => testCasePattern.firstMatch(line).group(0))
        .toSet();

    var aotCompilerRenderTest = File(p.join(
            dartdocPath, 'test', 'mustachio', 'aot_compiler_render_test.dart'))
        .readAsLinesSync();
    var aotCompilerTestCases = aotCompilerRenderTest
        .where((line) => testCasePattern.hasMatch(line))
        .map((line) => testCasePattern.firstMatch(line).group(0))
        .toSet();

    var difference = runtimeRendererTestCases.difference(aotCompilerTestCases);
    expect(difference, isEmpty);
  });
}
