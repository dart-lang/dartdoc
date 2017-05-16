// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_meta;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

abstract class PackageMeta {
  final Directory dir;
  final bool useCategories;

  PackageMeta(this.dir, {this.useCategories: false});

  factory PackageMeta.fromDir(Directory dir) => new _FilePackageMeta(dir);
  factory PackageMeta.fromSdk(Directory sdkDir,
          {String sdkReadmePath, bool useCategories}) =>
      new _SdkMeta(sdkDir,
          sdkReadmePath: sdkReadmePath, useCategories: useCategories);

  bool get isSdk;
  bool get needsPubGet => false;

  void runPubGet();

  String get name;
  String get version;
  String get description;
  String get homepage;

  String _resolvedDir;
  String get resolvedDir {
    if (_resolvedDir == null) {
      _resolvedDir = dir.resolveSymbolicLinksSync();
    }
    return _resolvedDir;
  }

  FileContents getReadmeContents();
  FileContents getLicenseContents();
  FileContents getChangelogContents();

  /// Returns true if we are a valid package, valid enough to generate docs.
  bool get isValid;

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  ///
  /// If the list is empty, this package is valid.
  List<String> getInvalidReasons();

  @override
  String toString() => name;
}

class FileContents {
  final File file;

  FileContents._(this.file);

  factory FileContents(File file) =>
      file == null ? null : new FileContents._(file);

  String get contents => file.readAsStringSync();

  bool get isMarkdown => file.path.toLowerCase().endsWith('.md');

  @override
  String toString() => file.path;
}

class _FilePackageMeta extends PackageMeta {
  FileContents _readme;
  FileContents _license;
  FileContents _changelog;
  Map _pubspec;

  _FilePackageMeta(Directory dir) : super(dir) {
    File f = new File(path.join(dir.path, 'pubspec.yaml'));
    if (f.existsSync()) {
      _pubspec = loadYaml(f.readAsStringSync());
    } else {
      _pubspec = {};
    }
  }

  @override
  bool get isSdk => false;

  @override
  bool get needsPubGet =>
      !(new File(path.join(dir.path, '.packages')).existsSync());

  @override
  void runPubGet() {
    String pubPath =
        path.join(path.dirname(Platform.resolvedExecutable), 'pub');
    if (Platform.isWindows) pubPath += '.bat';

    ProcessResult result =
        Process.runSync(pubPath, ['get'], workingDirectory: dir.path);

    if (result.stdout.isNotEmpty) {
      print(result.stdout.trim());
    }

    if (result.exitCode != 0) {
      StringBuffer buf = new StringBuffer();
      buf.writeln('${result.stdout}');
      buf.writeln('${result.stderr}');
      throw buf.toString().trim();
    }
  }

  @override
  String get name => _pubspec['name'];
  @override
  String get version => _pubspec['version'];
  @override
  String get description => _pubspec['description'];
  @override
  String get homepage => _pubspec['homepage'];

  @override
  FileContents getReadmeContents() {
    if (_readme != null) return _readme;
    _readme =
        new FileContents(_locate(dir, ['readme.md', 'readme.txt', 'readme']));
    return _readme;
  }

  @override
  FileContents getLicenseContents() {
    if (_license != null) return _license;
    _license = new FileContents(
        _locate(dir, ['license.md', 'license.txt', 'license']));
    return _license;
  }

  @override
  FileContents getChangelogContents() {
    if (_changelog != null) return _changelog;
    _changelog = new FileContents(
        _locate(dir, ['changelog.md', 'changelog.txt', 'changelog']));
    return _changelog;
  }

  @override
  bool get isValid => getInvalidReasons().isEmpty;

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  @override
  List<String> getInvalidReasons() {
    List<String> reasons = <String>[];
    if (_pubspec == null || _pubspec.isEmpty) {
      reasons.add('no pubspec.yaml found');
    } else if (!_pubspec.containsKey('name')) {
      reasons.add('no name found in pubspec.yaml');
    }
    return reasons;
  }
}

File _locate(Directory dir, List<String> fileNames) {
  List<File> files =
      new List<File>.from(dir.listSync().where((f) => f is File));

  for (String name in fileNames) {
    for (File f in files) {
      String baseName = path.basename(f.path).toLowerCase();
      if (baseName == name) return f;
      if (baseName.startsWith(name)) return f;
    }
  }

  return null;
}

class _SdkMeta extends PackageMeta {
  final String sdkReadmePath;

  _SdkMeta(Directory dir, {this.sdkReadmePath, bool useCategories})
      : super(dir, useCategories: useCategories);

  @override
  bool get isSdk => true;

  @override
  void runPubGet() {
    throw 'unsupported operation';
  }

  @override
  String get name => 'Dart SDK';
  @override
  String get version =>
      new File(path.join(dir.path, 'version')).readAsStringSync().trim();
  @override
  String get description =>
      'The Dart SDK is a set of tools and libraries for the '
      'Dart programming language.';
  @override
  String get homepage => 'https://github.com/dart-lang/sdk';

  @override
  FileContents getReadmeContents() {
    File f = sdkReadmePath != null
        ? new File(sdkReadmePath)
        : new File(path.join(dir.path, 'lib', 'api_readme.md'));
    return f.existsSync() ? new FileContents(f) : null;
  }

  @override
  bool get isValid => true;

  @override
  List<String> getInvalidReasons() => [];

  @override
  FileContents getLicenseContents() => null;

  // TODO: The changelog doesn't seem to be available in the sdk.
  @override
  FileContents getChangelogContents() => null;
}
