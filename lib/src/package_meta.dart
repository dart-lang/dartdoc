// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_meta;

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as pathLib;
import 'package:yaml/yaml.dart';

import 'logging.dart';

Map<String, PackageMeta> _packageMetaCache = {};

Directory get defaultSdkDir {
  Directory sdkDir = new File(Platform.resolvedExecutable).parent.parent;
  assert(pathLib.equals(sdkDir.path, PackageMeta.sdkDirParent(sdkDir).path));
  return sdkDir;
}

class PackageMetaFailure extends DartdocFailure {
  PackageMetaFailure(String message) : super(message);
}

/// For each list in this list, at least one of the given paths must exist
/// for this to be detected as an SDK.
final List<List<String>> __sdkDirFilePathsPosix = [
  ['bin/dart.bat', 'bin/dart.exe', 'bin/dart'],
  ['bin/pub.bat', 'bin/pub'],
  ['lib/core/core.dart'],
];

abstract class PackageMeta {
  final Directory dir;

  PackageMeta(this.dir);

  static List<List<String>> get _sdkDirFilePaths {
    List<List<String>> platformSdkDirFilePaths = [];
    if (Platform.isWindows) {
      for (List<String> paths in __sdkDirFilePathsPosix) {
        List<String> windowsPaths = [];
        for (String path in paths) {
          windowsPaths.add(pathLib.joinAll(
              new pathLib.Context(style: pathLib.Style.posix).split(path)));
        }
        platformSdkDirFilePaths.add(windowsPaths);
      }
    } else {
      platformSdkDirFilePaths = __sdkDirFilePathsPosix;
    }
    return platformSdkDirFilePaths;
  }

  /// Returns the directory of the SDK if the given directory is inside a Dart
  /// SDK.  Returns null if the directory isn't a subdirectory of the SDK.
  static Directory sdkDirParent(Directory dir) {
    while (dir.existsSync()) {
      if (_sdkDirFilePaths.every((List<String> l) {
        return l.any((f) => new File(pathLib.join(dir.path, f)).existsSync());
      })) {
        return dir;
      }
      if (pathLib.equals(dir.path, dir.parent.path)) break;
      dir = dir.parent;
    }
    return null;
  }

  @override
  bool operator ==(other) {
    if (other is! PackageMeta) return false;
    return pathLib.equals(dir.absolute.path, other.dir.absolute.path);
  }

  @override
  int get hashCode => pathLib.hash(dir.absolute.path);

  /// Use this instead of fromDir where possible.
  factory PackageMeta.fromElement(
      LibraryElement libraryElement, DartdocOptionContext config) {
    // [config] is only here for sdkDir, and it's OK that it is the wrong
    // context since sdkDir is argOnly and this is supposed to be a temporary
    // workaround.
    if (libraryElement.isInSdk)
      return new PackageMeta.fromDir(new Directory(config.sdkDir));
    return new PackageMeta.fromDir(
        new File(pathLib.canonicalize(libraryElement.source.fullName)).parent);
  }

  factory PackageMeta.fromFilename(String filename) {
    return new PackageMeta.fromDir(new File(filename).parent);
  }

  /// This factory is guaranteed to return the same object for any given
  /// [dir.absolute.path].  Multiple [dir.absolute.path]s will resolve to the
  /// same object if they are part of the same package.  Returns null
  /// if the directory is not part of a known package.
  factory PackageMeta.fromDir(Directory dir) {
    Directory original = dir.absolute;
    dir = original;
    if (!original.existsSync()) {
      throw new PackageMetaFailure(
          "fatal error: unable to locate the input directory at ${original.path}.");
    }

    if (!_packageMetaCache.containsKey(dir.path)) {
      PackageMeta packageMeta;
      // There are pubspec.yaml files inside the SDK.  Ignore them.
      Directory parentSdkDir = sdkDirParent(dir);
      if (parentSdkDir != null) {
        packageMeta = new _SdkMeta(parentSdkDir);
      } else {
        while (dir.existsSync()) {
          File pubspec = new File(pathLib.join(dir.path, 'pubspec.yaml'));
          if (pubspec.existsSync()) {
            packageMeta = new _FilePackageMeta(dir);
            break;
          }
          // Allow a package to be at root (possible in a Windows setting with
          // drive letter mappings).
          if (pathLib.equals(dir.path, dir.parent.path)) break;
          dir = dir.parent.absolute;
        }
      }
      _packageMetaCache[dir.absolute.path] = packageMeta;
    }
    return _packageMetaCache[dir.absolute.path];
  }

  /// Returns true if this represents a 'Dart' SDK.  A package can be part of
  /// Dart and Flutter at the same time, but if we are part of a Dart SDK
  /// sdkType should never return null.
  bool get isSdk;

  /// Returns 'Dart' or 'Flutter' (preferentially, 'Flutter' when the answer is
  /// "both"), or null if this package is not part of a SDK.
  String sdkType(String flutterRootPath) {
    if (flutterRootPath != null) {
      String flutterPackages = pathLib.join(flutterRootPath, 'packages');
      String flutterBinCache = pathLib.join(flutterRootPath, 'bin', 'cache');

      /// Don't include examples or other non-SDK components as being the
      /// "Flutter SDK".
      if (pathLib.isWithin(
              flutterPackages, pathLib.canonicalize(dir.absolute.path)) ||
          pathLib.isWithin(
              flutterBinCache, pathLib.canonicalize(dir.absolute.path))) {
        return 'Flutter';
      }
    }
    return isSdk ? 'Dart' : null;
  }

  bool get needsPubGet => false;

  bool get requiresFlutter;

  void runPubGet();

  String get name;

  /// null if not a hosted pub package.  If set, the hostname
  /// that the package is hosted at -- usually 'pub.dartlang.org'.
  String get hostedAt;
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
  bool get isValid => getInvalidReasons().isEmpty;

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
    File f = new File(pathLib.join(dir.path, 'pubspec.yaml'));
    if (f.existsSync()) {
      _pubspec = loadYaml(f.readAsStringSync());
    } else {
      _pubspec = {};
    }
  }

  bool _setHostedAt = false;
  String _hostedAt;
  @override
  String get hostedAt {
    if (!_setHostedAt) {
      _setHostedAt = true;
      // Search for 'hosted/host.domain' as the immediate parent directories,
      // and verify that a directory _temp exists alongside hosted.  Those
      // seem to be the only guaranteed things to exist if we're from a pub
      // cache.
      //
      // TODO(jcollins-g): This is a funky heuristic.  Make this better somehow,
      // possibly by calculating hosting directly from pubspec.yaml or importing
      // a pub library to do this.
      // People could have a pub cache at root with Windows drive mappings.
      if (pathLib.split(pathLib.canonicalize(dir.path)).length >= 3) {
        String pubCacheRoot = dir.parent.parent.parent.path;
        String hosted = pathLib.canonicalize(dir.parent.parent.path);
        String hostname = pathLib.canonicalize(dir.parent.path);
        if (pathLib.basename(hosted) == 'hosted' &&
            new Directory(pathLib.join(pubCacheRoot, '_temp')).existsSync()) {
          _hostedAt = pathLib.basename(hostname);
        }
      }
    }
    return _hostedAt;
  }

  @override
  bool get isSdk => false;

  @override
  bool get needsPubGet =>
      !(new File(pathLib.join(dir.path, '.packages')).existsSync());

  @override
  void runPubGet() {
    String pubPath =
        pathLib.join(pathLib.dirname(Platform.resolvedExecutable), 'pub');
    if (Platform.isWindows) pubPath += '.bat';

    ProcessResult result =
        Process.runSync(pubPath, ['get'], workingDirectory: dir.path);

    var trimmedStdout = (result.stdout as String).trim();
    if (trimmedStdout.isNotEmpty) {
      logInfo(trimmedStdout);
    }

    if (result.exitCode != 0) {
      StringBuffer buf = new StringBuffer();
      buf.writeln('${result.stdout}');
      buf.writeln('${result.stderr}');
      throw new DartdocFailure('pub get failed: ${buf.toString().trim()}');
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
  bool get requiresFlutter =>
      _pubspec['environment']?.containsKey('flutter') == true;

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
      String baseName = pathLib.basename(f.path).toLowerCase();
      if (baseName == name) return f;
      if (baseName.startsWith(name)) return f;
    }
  }

  return null;
}

class _SdkMeta extends PackageMeta {
  String sdkReadmePath;

  _SdkMeta(Directory dir) : super(dir) {
    sdkReadmePath = pathLib.join(dir.path, 'lib', 'api_readme.md');
  }

  @override
  String get hostedAt => null;

  @override
  bool get isSdk => true;

  @override
  void runPubGet() {
    throw 'unsupported operation';
  }

  @override
  String get name => 'Dart';
  @override
  String get version {
    File versionFile = new File(pathLib.join(dir.path, 'version'));
    if (versionFile.existsSync()) return versionFile.readAsStringSync().trim();
    return 'unknown';
  }

  @override
  String get description =>
      'The Dart SDK is a set of tools and libraries for the '
      'Dart programming language.';
  @override
  String get homepage => 'https://github.com/dart-lang/sdk';

  @override
  bool get requiresFlutter => false;

  @override
  FileContents getReadmeContents() {
    File f = new File(pathLib.join(dir.path, 'lib', 'api_readme.md'));
    if (!f.existsSync()) {
      f = new File(pathLib.join(dir.path, 'api_readme.md'));
    }
    return f.existsSync() ? new FileContents(f) : null;
  }

  @override
  List<String> getInvalidReasons() => [];

  @override
  FileContents getLicenseContents() => null;

  // TODO: The changelog doesn't seem to be available in the sdk.
  @override
  FileContents getChangelogContents() => null;
}
