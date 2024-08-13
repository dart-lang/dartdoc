// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

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
  late String packagePath;

  String get libraryName;

  String get placeholder => '%%__HTMLBASE_dartdoc_internal__%%';

  String get linkPrefix => '$placeholder$libraryName';

  String get dartCoreUrlPrefix => 'https://api.dart.dev/stable/3.2.0/dart-core';

  String get sdkConstraint => '>=3.3.0 <4.0.0';

  List<String> get experiments => ['wildcard-variables'];

  bool get skipUnreachableSdkLibraries => true;

  late StringBuffer outBuffer;
  late StringBuffer errBuffer;

  @mustCallSuper
  Future<void> setUp() async {
    outBuffer = StringBuffer();
    errBuffer = StringBuffer();
    packageMetaProvider = testPackageMetaProvider;
    resourceProvider =
        packageMetaProvider.resourceProvider as MemoryResourceProvider;
    await _setUpPackage();
  }

  Future<void> _setUpPackage() async {
    var pubspec = d.buildPubspecText(sdkConstraint: sdkConstraint);
    String? analysisOptions;
    if (experiments.isNotEmpty) {
      analysisOptions = '''
analyzer:
  enable-experiment:${experiments.map((experiment) => '\n  - $experiment').join('')}
''';
    }
    packagePath = await d.createPackage(
      libraryName,
      pubspec: pubspec,
      analysisOptions: analysisOptions,
      resourceProvider: resourceProvider,
    );

    packageConfigProvider =
        getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
    packageConfigProvider.addPackageToConfigFor(
        packagePath, libraryName, Uri.file('$packagePath/'));
  }

  Future<PackageGraph> bootPackageFromFiles(Iterable<d.Descriptor> files,
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
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
  }

  /// Creates a single library named [libraryName], with optional preamble
  /// [libraryPreamble].  Optionally, pass [extraFiles] such as
  /// `dartdoc_options.yaml`.
  Future<Library> bootPackageWithLibrary(String libraryContent,
      {String libraryPreamble = '',
      Iterable<d.Descriptor> extraFiles = const [],
      List<String> additionalArguments = const []}) async {
    return (await bootPackageFromFiles([
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

  Future<Dartdoc> buildDartdoc({
    List<String> excludeLibraries = const [],
    List<String> additionalArguments = const [],
    bool skipUnreachableSdkLibraries = true,
    bool useJson = false,
  }) async {
    final dir = resourceProvider.getFolder(resourceProvider.pathContext
        .absolute(resourceProvider.pathContext.normalize(packagePath)));
    final context = await generatorContextFromArgv([
      '--input',
      dir.path,
      '--output',
      path.join(packagePath, 'doc'),
      '--sdk-dir',
      packageMetaProvider.defaultSdkDir.path,
      '--exclude',
      excludeLibraries.join(','),
      '--allow-tools',
      '--no-link-to-remote',
      ...additionalArguments,
    ], packageMetaProvider);
    final packageBuilder = PubPackageBuilder(
      context,
      packageMetaProvider,
      packageConfigProvider,
      skipUnreachableSdkLibraries: skipUnreachableSdkLibraries,
    );
    startLogging(
      isJson: useJson,
      isQuiet: true,
      showProgress: true,
      outSink: outBuffer,
      errSink: errBuffer,
    );
    return await Dartdoc.fromContext(context, packageBuilder);
  }

  /// The real offset in a library generated with [bootPackageWithLibrary].
  ///
  /// When a library is written via [bootPackageWithLibrary], the test author
  /// provides `libraryContent`, which is a snippet of Dart library text.
  int realOffsetFor(int offsetInContent) =>
      '\n\nlibrary $libraryName\n\n'.length + offsetInContent;
}
