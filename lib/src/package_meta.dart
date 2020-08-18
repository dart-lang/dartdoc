// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_meta;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'logging.dart';

Map<String, PackageMeta> _packageMetaCache = {};
Encoding utf8AllowMalformed = Utf8Codec(allowMalformed: true);

Directory get defaultSdkDir {
  var sdkDir = File(Platform.resolvedExecutable).parent.parent;
  assert(p.equals(sdkDir.path, PubPackageMeta.sdkDirParent(sdkDir).path));
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

final PackageMetaProvider pubPackageMetaProvider = PackageMetaProvider(
  PubPackageMeta.fromElement,
  PubPackageMeta.fromFilename,
  PubPackageMeta.fromDir,
);

/// Sets the supported way of constructing [PackageMeta] objects.
///
/// These objects can be constructed from a filename, a directory
/// or a [LibraryElement]. We allow different dartdoc implementations to
/// provide their own [PackageMeta] types.
///
/// By using a different provider, these implementations can control how
/// [PackageMeta] objects is built.
class PackageMetaProvider {
  final PackageMeta Function(LibraryElement, String) fromElement;
  final PackageMeta Function(String) fromFilename;
  final PackageMeta Function(Directory) fromDir;

  PackageMetaProvider(this.fromElement, this.fromFilename, this.fromDir);
}

/// Describes a single package in the context of `dartdoc`.
///
/// The primary function of this class is to allow canonicalization of packages
/// by returning the same [PackageMeta] for a given filename, library or path
/// if they belong to the same package.
///
/// Overriding this is typically done by overriding factories as rest of
/// `dartdoc` creates this object by calling these static factories.
abstract class PackageMeta {
  final Directory dir;

  PackageMeta(this.dir);

  @override
  bool operator ==(Object other) {
    if (other is! PackageMeta) return false;
    PackageMeta otherMeta = other;
    return p.equals(dir.absolute.path, otherMeta.dir.absolute.path);
  }

  @override
  int get hashCode => p.hash(dir.absolute.path);

  /// Returns true if this represents a 'Dart' SDK.  A package can be part of
  /// Dart and Flutter at the same time, but if we are part of a Dart SDK
  /// sdkType should never return null.
  bool get isSdk;

  /// Returns 'Dart' or 'Flutter' (preferentially, 'Flutter' when the answer is
  /// "both"), or null if this package is not part of a SDK.
  String sdkType(String flutterRootPath);

  bool get needsPubGet => false;

  bool get requiresFlutter;

  void runPubGet(String flutterRoot);

  String get name;

  /// null if not a hosted pub package.  If set, the hostname
  /// that the package is hosted at -- usually 'pub.dartlang.org'.
  String get hostedAt;

  String get version;

  String get description;

  String get homepage;

  File getReadmeContents();

  File getLicenseContents();

  File getChangelogContents();

  /// Returns true if we are a valid package, valid enough to generate docs.
  bool get isValid => getInvalidReasons().isEmpty;

  /// Returns resolved directory.
  String get resolvedDir;

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  ///
  /// If the list is empty, this package is valid.
  List<String> getInvalidReasons();

  @override
  String toString() => name;
}

/// Default implementation of [PackageMeta] depends on pub packages.
abstract class PubPackageMeta extends PackageMeta {
  PubPackageMeta(Directory dir) : super(dir);

  static List<List<String>> __sdkDirFilePaths;

  static List<List<String>> get _sdkDirFilePaths {
    if (__sdkDirFilePaths == null) {
      __sdkDirFilePaths = [];
      if (Platform.isWindows) {
        for (var paths in __sdkDirFilePathsPosix) {
          var windowsPaths = <String>[];
          for (var path in paths) {
            windowsPaths
                .add(p.joinAll(p.Context(style: p.Style.posix).split(path)));
          }
          __sdkDirFilePaths.add(windowsPaths);
        }
      } else {
        __sdkDirFilePaths = __sdkDirFilePathsPosix;
      }
    }
    return __sdkDirFilePaths;
  }

  /// Returns the directory of the SDK if the given directory is inside a Dart
  /// SDK.  Returns null if the directory isn't a subdirectory of the SDK.
  static final Map<String, Directory> _sdkDirParent = {};

  static Directory sdkDirParent(Directory dir) {
    var dirPathCanonical = p.canonicalize(dir.path);
    if (!_sdkDirParent.containsKey(dirPathCanonical)) {
      _sdkDirParent[dirPathCanonical] = null;
      while (dir.existsSync()) {
        if (_sdkDirFilePaths.every((List<String> l) {
          return l.any((f) => File(p.join(dir.path, f)).existsSync());
        })) {
          _sdkDirParent[dirPathCanonical] = dir;
          break;
        }
        if (p.equals(dir.path, dir.parent.path)) break;
        dir = dir.parent;
      }
    }
    return _sdkDirParent[dirPathCanonical];
  }

  /// Use this instead of fromDir where possible.
  static PubPackageMeta fromElement(
      LibraryElement libraryElement, String sdkDir) {
    if (libraryElement.isInSdk) {
      return PubPackageMeta.fromDir(Directory(sdkDir));
    }
    return PubPackageMeta.fromDir(
        File(p.canonicalize(libraryElement.source.fullName)).parent);
  }

  static PubPackageMeta fromFilename(String filename) {
    return PubPackageMeta.fromDir(File(filename).parent);
  }

  /// This factory is guaranteed to return the same object for any given
  /// [dir.absolute.path].  Multiple [dir.absolute.path]s will resolve to the
  /// same object if they are part of the same package.  Returns null
  /// if the directory is not part of a known package.
  static PubPackageMeta fromDir(Directory dir) {
    var original = dir.absolute;
    dir = original;
    if (!original.existsSync()) {
      throw PackageMetaFailure(
          'fatal error: unable to locate the input directory at ${original.path}.');
    }

    if (!_packageMetaCache.containsKey(dir.path)) {
      PackageMeta packageMeta;
      // There are pubspec.yaml files inside the SDK.  Ignore them.
      var parentSdkDir = sdkDirParent(dir);
      if (parentSdkDir != null) {
        packageMeta = _SdkMeta(parentSdkDir);
      } else {
        while (dir.existsSync()) {
          var pubspec = File(p.join(dir.path, 'pubspec.yaml'));
          if (pubspec.existsSync()) {
            packageMeta = _FilePackageMeta(dir);
            break;
          }
          // Allow a package to be at root (possible in a Windows setting with
          // drive letter mappings).
          if (p.equals(dir.path, dir.parent.path)) break;
          dir = dir.parent.absolute;
        }
      }
      _packageMetaCache[dir.absolute.path] = packageMeta;
    }
    return _packageMetaCache[dir.absolute.path];
  }

  @override
  String sdkType(String flutterRootPath) {
    if (flutterRootPath != null) {
      var flutterPackages = p.join(flutterRootPath, 'packages');
      var flutterBinCache = p.join(flutterRootPath, 'bin', 'cache');

      /// Don't include examples or other non-SDK components as being the
      /// "Flutter SDK".
      if (p.isWithin(flutterPackages, p.canonicalize(dir.absolute.path)) ||
          p.isWithin(flutterBinCache, p.canonicalize(dir.absolute.path))) {
        return 'Flutter';
      }
    }
    return isSdk ? 'Dart' : null;
  }

  String _resolvedDir;

  @override
  String get resolvedDir {
    _resolvedDir ??= dir.resolveSymbolicLinksSync();
    return _resolvedDir;
  }
}

extension FileContents on File {
  String get contents => readAsStringSync(encoding: utf8AllowMalformed);
}

class _FilePackageMeta extends PubPackageMeta {
  File _readme;
  File _license;
  File _changelog;
  Map<dynamic, dynamic> _pubspec;

  _FilePackageMeta(Directory dir) : super(dir) {
    var f = File(p.join(dir.path, 'pubspec.yaml'));
    if (f.existsSync()) {
      _pubspec = loadYaml(f.readAsStringSync());
    } else {
      _pubspec = <dynamic, dynamic>{};
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
      if (p.split(p.canonicalize(dir.path)).length >= 3) {
        var pubCacheRoot = dir.parent.parent.parent.path;
        var hosted = p.canonicalize(dir.parent.parent.path);
        var hostname = p.canonicalize(dir.parent.path);
        if (p.basename(hosted) == 'hosted' &&
            Directory(p.join(pubCacheRoot, '_temp')).existsSync()) {
          _hostedAt = p.basename(hostname);
        }
      }
    }
    return _hostedAt;
  }

  @override
  bool get isSdk => false;

  @override
  bool get needsPubGet =>
      !(File(p.join(dir.path, '.dart_tool', 'package_config.json'))
          .existsSync());

  @override
  void runPubGet(String flutterRoot) {
    String binPath;
    List<String> parameters;
    if (requiresFlutter) {
      binPath = p.join(flutterRoot, 'bin', 'flutter');
      parameters = ['pub', 'get'];
    } else {
      binPath = p.join(p.dirname(Platform.resolvedExecutable), 'pub');
      parameters = ['get'];
    }
    if (Platform.isWindows) binPath += '.bat';

    var result =
        Process.runSync(binPath, parameters, workingDirectory: dir.path);

    var trimmedStdout = (result.stdout as String).trim();
    if (trimmedStdout.isNotEmpty) {
      logInfo(trimmedStdout);
    }

    if (result.exitCode != 0) {
      var buf = StringBuffer();
      buf.writeln('${result.stdout}');
      buf.writeln('${result.stderr}');
      throw DartdocFailure('pub get failed: ${buf.toString().trim()}');
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
      _pubspec['environment']?.containsKey('flutter') == true ||
      _pubspec['dependencies']?.containsKey('flutter') == true;

  @override
  File getReadmeContents() =>
      _readme ??= _locate(dir, ['readme.md', 'readme.txt', 'readme']);

  @override
  File getLicenseContents() =>
      _license ??= _locate(dir, ['license.md', 'license.txt', 'license']);

  @override
  File getChangelogContents() => _changelog ??=
      _locate(dir, ['changelog.md', 'changelog.txt', 'changelog']);

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  @override
  List<String> getInvalidReasons() {
    var reasons = <String>[];
    if (_pubspec == null || _pubspec.isEmpty) {
      reasons.add('no pubspec.yaml found');
    } else if (!_pubspec.containsKey('name')) {
      reasons.add('no name found in pubspec.yaml');
    }
    return reasons;
  }
}

File _locate(Directory dir, List<String> fileNames) {
  var files = dir.listSync().whereType<File>().toList();

  for (var name in fileNames) {
    for (var f in files) {
      var baseName = p.basename(f.path).toLowerCase();
      if (baseName == name) return f;
      if (baseName.startsWith(name)) return f;
    }
  }

  return null;
}

class _SdkMeta extends PubPackageMeta {
  String sdkReadmePath;

  _SdkMeta(Directory dir) : super(dir) {
    sdkReadmePath = p.join(dir.path, 'lib', 'api_readme.md');
  }

  @override
  String get hostedAt => null;

  @override
  bool get isSdk => true;

  @override
  void runPubGet(String flutterRoot) {
    throw 'unsupported operation';
  }

  @override
  String get name => 'Dart';

  @override
  String get version {
    var versionFile = File(p.join(dir.path, 'version'));
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
  File getReadmeContents() {
    var f = File(p.join(dir.path, 'lib', 'api_readme.md'));
    if (!f.existsSync()) {
      f = File(p.join(dir.path, 'api_readme.md'));
    }
    return f.existsSync() ? f : null;
  }

  @override
  List<String> getInvalidReasons() => [];

  @override
  File getLicenseContents() => null;

  // TODO: The changelog doesn't seem to be available in the sdk.
  @override
  File getChangelogContents() => null;
}
