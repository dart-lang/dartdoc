// Copyright (c) 2026, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(CanonicalForTest);
  });
}

@reflectiveTest
class CanonicalForTest extends DartdocTestBase {
  @override
  String get libraryName => 'canonical_for';

  /// Tests that @canonicalFor correctly overrides the default canonical home
  /// for an element exported by multiple public libraries.
  /// This is the "google_cloud" scenario.
  Future<void> test_canonicalFor_multiPublicExports() async {
    var packageGraph = await bootPackageFromFiles([
      d.file('lib/google_cloud.dart', '''
/// The catch-all export library.
library google_cloud;
export 'src/internal.dart';
export 'http_serving.dart';
'''),
      d.file('lib/http_serving.dart', '''
/// The specific library that SHOULD be canonical.
/// {@canonicalFor http_serving.middleware}
library http_serving;
export 'src/internal.dart';
'''),
      d.file('lib/src/internal.dart', '''
/// The internal implementation.
library internal;
void middleware() {}
'''),
    ]);

    var googleCloud = packageGraph.libraries.named('google_cloud');
    var httpServing = packageGraph.libraries.named('http_serving');
    
    var middleware = packageGraph.libraries.named('google_cloud').functions.named('middleware');
    
    expect(middleware.canonicalLibrary, equals(httpServing));
    expect(middleware.canonicalLibrary, isNot(equals(googleCloud)));
    
    // Ensure the href points to the correct library.
    expect(middleware.href, contains('http_serving/middleware.html'));
    expect(middleware.href, isNot(contains('google_cloud/middleware.html')));
  }

  /// Tests that @canonicalFor matches even if the ModelElement was first 
  /// initialized with a different library name (due to cache).
  Future<void> test_canonicalFor_matchesOriginalName() async {
    // We want to ensure 'google_cloud' is processed first or at least is the
    // initial library for the function.
    var packageGraph = await bootPackageFromFiles([
      d.file('lib/a_first.dart', '''
library a_first;
export 'src/internal.dart';
'''),
      d.file('lib/b_canonical.dart', '''
/// {@canonicalFor b_canonical.someFunc}
library b_canonical;
export 'src/internal.dart';
'''),
      d.file('lib/src/internal.dart', '''
library internal;
void someFunc() {}
'''),
    ]);

    var bCanonical = packageGraph.libraries.named('b_canonical');
    var someFunc = bCanonical.functions.named('someFunc');
    
    expect(someFunc.canonicalLibrary, equals(bCanonical));
    expect(someFunc.href, contains('b_canonical/someFunc.html'));
  }
}
