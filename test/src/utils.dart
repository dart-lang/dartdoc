// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';

/// The number of public libraries in testing/test_package, minus 2 for
/// the excluded libraries listed in the initializers for _testPackageGraphMemo
/// and minus 1 for the <nodoc> tag in the 'excluded' library.
const int kTestPackagePublicLibraries = 17;

final _resourceProvider = pubPackageMetaProvider.resourceProvider;
final _pathContext = _resourceProvider.pathContext;

final Folder testPackageToolError = _resourceProvider.getFolder(_pathContext
    .absolute(_pathContext.normalize('testing/test_package_tool_error')));

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(
    List<String> argv, PackageMetaProvider packageMetaProvider) async {
  var resourceProvider = packageMetaProvider.resourceProvider;
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions], packageMetaProvider);
  optionSet.parseArguments(argv);
  return DartdocOptionContext(
      optionSet,
      resourceProvider.getFolder(resourceProvider.pathContext.current),
      pubPackageMetaProvider.resourceProvider);
}

Future<PackageGraph> bootBasicPackage(
    String dirPath,
    List<String> excludeLibraries,
    PackageMetaProvider packageMetaProvider,
    PackageConfigProvider packageConfigProvider,
    {List<String> additionalArguments = const []}) async {
  var resourceProvider = packageMetaProvider.resourceProvider;
  var dir = resourceProvider.getFolder(resourceProvider.pathContext
      .absolute(resourceProvider.pathContext.normalize(dirPath)));
  return PubPackageBuilder(
          await contextFromArgv([
            '--input',
            dir.path,
            '--sdk-dir',
            packageMetaProvider.defaultSdkDir.path,
            '--exclude',
            excludeLibraries.join(','),
            '--allow-tools',
            ...additionalArguments,
          ], packageMetaProvider),
          packageMetaProvider,
          packageConfigProvider)
      .buildPackageGraph();
}
