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
    defineReflectiveTests(CanonicalizationReexportTest);
  });
}

@reflectiveTest
class CanonicalizationReexportTest extends DartdocTestBase {
  @override
  String get libraryName => 'reexport';

  /// Tests that re-exported SDK elements link to the remote SDK when it is
  /// available.
  Future<void> test_reexportFuture_remote() async {
    var packageGraph = await bootPackageFromFiles([
      d.file('lib/reexport.dart', '''
library reexport;
export 'dart:async' show Future;
'''),
    ]);

    var reexportLib = packageGraph.libraries.named('reexport');
    var future = reexportLib.classes.named('Future');

    var asyncLib = packageGraph.libraries.named('dart:async');
    expect(asyncLib.package.documentedWhere, equals(DocumentLocation.remote));

    // With the sameLibrary boost, dart:async wins.
    expect(future.canonicalLibrary, equals(asyncLib));
    expect(future.href, contains('api.dart.dev'));
  }

  /// Tests that re-exported SDK elements are documented locally when the SDK
  /// is not documented (missing).
  Future<void> test_reexportFuture_noRemote() async {
    var packageGraph = await bootPackageFromFiles([
      d.file('lib/reexport.dart', '''
library reexport;
export 'dart:async' show Future;
'''),
    ], additionalArguments: [
      '--no-link-to-remote'
    ]);

    var reexportLib = packageGraph.libraries.named('reexport');
    var future = reexportLib.classes.named('Future');

    var asyncLib = packageGraph.libraries.named('dart:async');
    expect(asyncLib.package.documentedWhere, equals(DocumentLocation.missing));

    // Since dart:async is missing, it is not a candidate, so reexport wins.
    expect(future.canonicalLibrary, equals(reexportLib));
    expect(future.isCanonical, isTrue);
    expect(future.href, contains('reexport/Future-class.html'));
  }

  /// Tests that @canonicalFor can still override the SDK even if it's remote.
  Future<void> test_reexportFuture_canonicalFor() async {
    var packageGraph = await bootPackageFromFiles([
      d.file('lib/reexport.dart', '''
/// {@canonicalFor reexport.Future}
library reexport;
export 'dart:async' show Future;
'''),
    ]);

    var reexportLib = packageGraph.libraries.named('reexport');
    var future = reexportLib.classes.named('Future');

    var asyncLib = packageGraph.libraries.named('dart:async');
    expect(asyncLib.package.documentedWhere, equals(DocumentLocation.remote));

    // @canonicalFor should win over sameLibrary.
    expect(future.canonicalLibrary, equals(reexportLib));
    expect(future.href, contains('reexport/Future-class.html'));
  }
}
