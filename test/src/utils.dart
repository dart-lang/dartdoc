// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:dartdoc/src/config.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/sdk.dart';
import 'package:path/path.dart' as p;

AnalyzerHelper analyzerHelper;
DartSdk sdkDir;
Package testPackage;
Package testPackageGinormous;
Package testPackageSmall;

final Directory testPackageBadDir = new Directory('testing/test_package_bad');
final Directory testPackageDir = new Directory('testing/test_package');
final Directory testPackageWithEmbedderYaml =
    new Directory('testing/test_package_embedder_yaml');
final Directory testPackageWithNoReadme =
    new Directory('testing/test_package_small');

void delete(Directory dir) {
  if (dir.existsSync()) dir.deleteSync(recursive: true);
}

void init() {
  ResourceProvider resourceProvider = PhysicalResourceProvider.INSTANCE;
  sdkDir = new FolderBasedDartSdk(
      resourceProvider, resourceProvider.getFolder(getSdkDir().path));

  setConfig();

  analyzerHelper = new AnalyzerHelper();
  var pathsForTestLib = [
    'lib/example.dart',
    'lib/two_exports.dart',
    'lib/fake.dart',
    'lib/anonymous_library.dart',
    'lib/another_anonymous_lib.dart',
    'lib/is_deprecated.dart',
    'lib/reexport_one.dart',
    'lib/reexport_two.dart',
  ];

  testPackage = _bootPackage(pathsForTestLib, 'testing/test_package', false);
  testPackageGinormous =
      _bootPackage(pathsForTestLib, 'testing/test_package', true);

  testPackageSmall =
      _bootPackage(['lib/main.dart'], 'testing/test_package_small', false);
}

Package _bootPackage(Iterable<String> libPaths, String dirPath,
    bool withAutoIncludedDependencies) {
  String fullDirPath = p.join(Directory.current.path, dirPath);
  Iterable<LibraryElement> libElements = libPaths.map((libFile) {
    Source source = analyzerHelper.addSource(p.join(fullDirPath, libFile));
    return analyzerHelper.resolve(source);
  });

  if (withAutoIncludedDependencies) {
    return Package.withAutoIncludedDependencies(
        libElements,
        new PackageMeta.fromDir(new Directory(dirPath)),
        new PackageWarningOptions());
  } else {
    return new Package(
        libElements,
        new PackageMeta.fromDir(new Directory(dirPath)),
        new PackageWarningOptions());
  }
}

class AnalyzerHelper {
  AnalysisContext context;

  AnalyzerHelper() {
    List<UriResolver> resolvers = [
      new DartUriResolver(sdkDir),
      new ResourceUriResolver(PhysicalResourceProvider.INSTANCE)
    ];

    SourceFactory sourceFactory = new SourceFactory(resolvers);
    AnalysisEngine.instance.processRequiredPlugins();
    context = AnalysisEngine.instance.createAnalysisContext();
    context.sourceFactory = sourceFactory;
  }

  Source addSource(String filePath) {
    Source source = new FileBasedSource(new JavaFile(filePath));
    ChangeSet changeSet = new ChangeSet();
    changeSet.addedSource(source);
    context.applyChanges(changeSet);
    return source;
  }

  LibraryElement resolve(Source librarySource) =>
      context.computeLibraryElement(librarySource);
}
