// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:async/async.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:test/test.dart';

import '../src/utils.dart' as utils;
import 'model_test.dart' show testPackageGraph;

// TODO(jcollins-g): switch to late initialization after null safety migration
final _testPackageGraphLookupMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraphLookup async =>
    _testPackageGraphLookupMemo.runOnce(() => utils.bootBasicPackage(
        'testing/test_package',
        pubPackageMetaProvider,
        PhysicalPackageConfigProvider(),
        excludeLibraries: ['css', 'code_in_comments'],
        additionalArguments: ['--no-link-to-remote', '--experimental-reference-lookup']));


void main () {

  for (var packageGraph in [packageGraphBase, packageGraphLookup]) {
    bool isBase() => identical(packageGraph, packageGraphBase);
    bool isLookup() => identical(packageGraph, packageGraphLookup);
    String testParameter = isBase() ? 'base' : 'lookup';


    Library fakeLibrary;
    Class baseForDocComments;
    Method doAwesomeStuff;

    setUpAll(() async {
      fakeLibrary =
          packageGraph.libraries.firstWhere((lib) => lib.name == 'fake');
      baseForDocComments =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseForDocComments');
      doAwesomeStuff = baseForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'doAwesomeStuff');
    });

    test('Verify links to inherited members inside class ($testParameter)', () {
      var
    });




  }
}