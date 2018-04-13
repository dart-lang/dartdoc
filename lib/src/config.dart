// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Legacy dartdoc configuration library.  TODO(jcollins-g): merge with [DartdocOption].
library dartdoc.config;

import 'dart:io';

import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as pathLib;

String _resolveTildePath(String originalPath) {
  if (originalPath == null || !originalPath.startsWith('~/')) {
    return originalPath;
  }

  String homeDir;

  if (Platform.isWindows) {
    homeDir = pathLib.absolute(Platform.environment['USERPROFILE']);
  } else {
    homeDir = pathLib.absolute(Platform.environment['HOME']);
  }

  return pathLib.join(homeDir, originalPath.substring(2));
}

class DartdocConfig {
  final bool addCrossdart;
  final bool autoIncludeDependencies;
  final List<String> dropTextFrom;
  final List<String> excludeLibraries;
  final List<String> excludePackages;
  final String examplePathPrefix;
  List<String> footerFilePaths;
  List<String> footerTextFilePaths;
  List<String> headerFilePaths;
  final String faviconPath;
  final List<String> includeExternals;
  final List<String> includeLibraries;
  final String hostedUrl;
  final bool includeSource;
  final Directory inputDir;
  final List<String> packageOrder;
  final bool prettyIndexJson;
  final double reexportMinConfidence;
  final String relCanonicalPrefix;
  final Directory sdkDir;
  final String sdkVersion;
  final bool showWarnings;
  final bool validateLinks;
  final bool verboseWarnings;
  DartdocConfig._(
    this.addCrossdart,
    this.autoIncludeDependencies,
    this.dropTextFrom,
    this.examplePathPrefix,
    this.excludeLibraries,
    this.excludePackages,
    this.faviconPath,
    this.footerFilePaths,
    this.footerTextFilePaths,
    this.headerFilePaths,
    this.hostedUrl,
    this.includeExternals,
    this.includeLibraries,
    this.includeSource,
    this.inputDir,
    this.packageOrder,
    this.prettyIndexJson,
    this.reexportMinConfidence,
    this.relCanonicalPrefix,
    this.sdkDir,
    this.sdkVersion,
    this.showWarnings,
    this.validateLinks,
    this.verboseWarnings,
  ) {
    if (sdkDir == null || !sdkDir.existsSync()) {
      throw new DartdocFailure("Error: unable to locate the Dart SDK.");
    }

    footerFilePaths = footerFilePaths.map((p) => _resolveTildePath(p)).toList();
    for (String footerFilePath in footerFilePaths) {
      if (!new File(footerFilePath).existsSync()) {
        throw new DartdocFailure(
            "fatal error: unable to locate footer file: ${footerFilePath}.");
      }
    }

    footerTextFilePaths =
        footerTextFilePaths.map((p) => _resolveTildePath(p)).toList();
    for (String footerTextFilePath in footerTextFilePaths) {
      if (!new File(footerTextFilePath).existsSync()) {
        throw new DartdocFailure(
            "fatal error: unable to locate footer-text file: ${footerTextFilePath}.");
      }
    }

    headerFilePaths = headerFilePaths.map((p) => _resolveTildePath(p)).toList();
    for (String headerFilePath in headerFilePaths) {
      if (!new File(headerFilePath).existsSync()) {
        throw new DartdocFailure(
            "fatal error: unable to locate header file: ${headerFilePath}.");
      }
    }
  }

  factory DartdocConfig.fromParameters({
    bool addCrossdart: false,
    bool autoIncludeDependencies: false,
    List<String> dropTextFrom,
    String examplePathPrefix,
    List<String> excludeLibraries,
    List<String> excludePackages,
    String faviconPath,
    List<String> footerFilePaths,
    List<String> footerTextFilePaths,
    List<String> headerFilePaths,
    String hostedUrl,
    List<String> includeExternals,
    List<String> includeLibraries,
    bool includeSource: true,
    Directory inputDir,
    List<String> packageOrder,
    bool prettyIndexJson: false,
    double reexportMinConfidence: 0.1,
    String relCanonicalPrefix,
    Directory sdkDir,
    String sdkVersion,
    bool showWarnings: false,
    bool validateLinks: true,
    bool verboseWarnings: true,
  }) {
    return new DartdocConfig._(
      addCrossdart,
      autoIncludeDependencies,
      dropTextFrom ?? const <String>[],
      examplePathPrefix,
      excludeLibraries ?? const <String>[],
      excludePackages ?? const <String>[],
      faviconPath,
      footerFilePaths ?? const <String>[],
      footerTextFilePaths ?? const <String>[],
      headerFilePaths ?? const <String>[],
      hostedUrl,
      includeExternals ?? const <String>[],
      includeLibraries ?? const <String>[],
      includeSource,
      inputDir,
      packageOrder ?? const <String>[],
      prettyIndexJson,
      reexportMinConfidence,
      relCanonicalPrefix,
      sdkDir ?? defaultSdkDir,
      sdkVersion,
      showWarnings,
      validateLinks,
      verboseWarnings,
    );
  }

  bool isLibraryExcluded(String name) =>
      excludeLibraries.any((pattern) => name == pattern);
  bool isPackageExcluded(String name) =>
      excludePackages.any((pattern) => name == pattern);
}
