// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:async';
import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';

/// The number of public libraries in testing/test_package, minus 2 for
/// the excluded libraries listed in the initializers for _testPackageGraphMemo
/// and minus 1 for the <nodoc> tag in the 'excluded' library.
const int kTestPackagePublicLibraries = 17;

final Directory testPackageToolError =
    Directory('testing/test_package_tool_error');

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(List<String> argv) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators('dartdoc', [
    () => createDartdocOptions(pubPackageMetaProvider),
  ]);
  optionSet.parseArguments(argv);
  return DartdocOptionContext(optionSet, Directory.current);
}

Future<PackageGraph> bootBasicPackage(
    String dirPath, List<String> excludeLibraries,
    {List<String> additionalArguments}) async {
  var dir = Directory(dirPath);
  additionalArguments ??= <String>[];
  return PubPackageBuilder(await contextFromArgv([
            '--input',
            dir.path,
            '--sdk-dir',
            defaultSdkDir.path,
            '--exclude',
            excludeLibraries.join(','),
            '--allow-tools',
          ] +
          additionalArguments))
      .buildPackageGraph();
}
