// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:meta/meta.dart';

import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

/// Exception thrown for invalid use of [DartdocTestBase]'s api.
class DartdocTestBaseFailure implements Exception {
  final String message;

  DartdocTestBaseFailure(this.message);

  @override
  String toString() => message;
}

abstract class DartdocTestBase {
  late final PackageMetaProvider packageMetaProvider;
  late final MemoryResourceProvider resourceProvider;
  late final FakePackageConfigProvider packageConfigProvider;
  late final String packagePath;

  String get libraryName;

  String get placeholder => '%%__HTMLBASE_dartdoc_internal__%%';

  String get linkPrefix => '$placeholder$libraryName';

  String get dartCoreUrlPrefix =>
      'https://api.dart.dev/stable/2.16.0/dart-core';

  String get sdkConstraint => '>=2.15.0 <3.0.0';

  List<String> get experiments => [];

  @mustCallSuper
  Future<void> setUp() async {
    packageMetaProvider = testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;
    await setUpPackage(libraryName);
  }

  Future<void> setUpPackage(String name) async {
    var pubspec = d.buildPubspecText(sdkConstraint: sdkConstraint);
    String? analysisOptions;
    if (experiments.isNotEmpty) {
      analysisOptions = '''
analyzer:
  enable-experiment:${experiments.map((experiment) => '\n  - $experiment').join('')}
''';
    }
    packagePath = await d.createPackage(
      name,
      pubspec: pubspec,
      analysisOptions: analysisOptions,
      resourceProvider: resourceProvider,
    );

    packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, name, Uri.file('$packagePath/'));
  }

  Future<PackageGraph> _bootPackageFromFiles(Iterable<d.Descriptor> files,
      {List<String> additionalArguments = const []}) async {
    var packagePathBasename =
        resourceProvider.pathContext.basename(packagePath);
    var packagePathDirname = resourceProvider.pathContext.dirname(packagePath);
    await d
        .dir(packagePathBasename, files)
        .createInMemory(resourceProvider, packagePathDirname);
    return await bootBasicPackage(
      packagePath,
      packageMetaProvider,
      packageConfigProvider,
      additionalArguments: additionalArguments,
    );
  }

  /// Creates a single library named [libraryName], with optional preamble
  /// [libraryPreamble].   Optionally, pass a [FileGenerator] to create
  /// extra files in the package such as `dartdoc_options.yaml`.
  Future<Library> bootPackageWithLibrary(String libraryContent,
      {String libraryPreamble = '',
      Iterable<d.Descriptor> extraFiles = const [],
      List<String> additionalArguments = const []}) async {
    return (await _bootPackageFromFiles([
      d.dir('lib', [
        d.file('lib.dart', '''
$libraryPreamble
library $libraryName;

$libraryContent
'''),
      ]),
      ...extraFiles
    ], additionalArguments: additionalArguments))
        .libraries
        .named(libraryName);
  }

  /// Similar to [bootPackageWithLibrary], but allows for more complex
  /// cases to test the edges of canonicalization.
  ///
  /// - Puts [reexportedContent] in a library named [libraryName]_src in
  ///   `lib/src` (if [reexportPrivate] is true), or 'lib/subdir'.
  /// - Creates a reexporting library named [libraryName]_lib in `lib` that
  ///   reexports [libraryName]_src.
  /// - Creates [libraryName] containing [libraryContent] that can optionally
  ///   import 'lib.dart' to import the reexporting library.
  ///
  /// Optionally, specify [show] or [hide] to change whether the reexport
  /// gives access to the full namespace.
  Future<Library> bootPackageWithReexportedLibrary(
      String reexportedContent, String libraryContent,
      {bool reexportPrivate = false,
      List<String> show = const [],
      List<String> hide = const []}) async {
    final subdir = reexportPrivate ? 'src' : 'subdir';
    if (show.isNotEmpty && hide.isNotEmpty) {
      throw DartdocTestBaseFailure('Can not specify show and hide');
    }
    final showHideString = '${show.isNotEmpty ? 'show ${show.join(', ')}' : ''}'
        '${hide.isNotEmpty ? 'hide ${hide.join(', ')}' : ''}';

    return (await _bootPackageFromFiles([
      d.dir('lib', [
        d.dir(subdir, [
          d.file('lib.dart', '''
library ${libraryName}_src;

$reexportedContent
'''),
        ]),
        d.file('lib.dart', '''
library ${libraryName}_lib;

export '$subdir/lib.dart' $showHideString;
'''),
        d.file('importing_lib.dart', '''
library $libraryName;
$libraryContent
'''),
      ])
    ]))
        .libraries
        .named(libraryName);
  }
}
