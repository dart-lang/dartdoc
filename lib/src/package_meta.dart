// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_meta;

import 'dart:convert';
import 'dart:io' show Platform, Process;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

import 'logging.dart';

Map<String, PackageMeta> _packageMetaCache = {};

Encoding utf8AllowMalformed = Utf8Codec(allowMalformed: true);

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
    PhysicalResourceProvider.INSTANCE,
    PhysicalResourceProvider.INSTANCE
        .getFile(PhysicalResourceProvider.INSTANCE.pathContext
            .absolute(Platform.resolvedExecutable))
        .parent
        .parent);

/// Sets the supported way of constructing [PackageMeta] objects.
///
/// These objects can be constructed from a filename, a directory
/// or a [LibraryElement]. We allow different dartdoc implementations to
/// provide their own [PackageMeta] types.
///
/// By using a different provider, these implementations can control how
/// [PackageMeta] objects is built.
class PackageMetaProvider {
  final ResourceProvider resourceProvider;
  final Folder defaultSdkDir;
  final DartSdk defaultSdk;

  final PackageMeta Function(LibraryElement, String, ResourceProvider)
      _fromElement;
  final PackageMeta Function(String, ResourceProvider) _fromFilename;
  final PackageMeta Function(Folder, ResourceProvider) _fromDir;

  PackageMeta fromElement(LibraryElement library, String s) =>
      _fromElement(library, s, resourceProvider);
  PackageMeta fromFilename(String s) => _fromFilename(s, resourceProvider);
  PackageMeta fromDir(Folder dir) => _fromDir(dir, resourceProvider);

  PackageMetaProvider(this._fromElement, this._fromFilename, this._fromDir,
      this.resourceProvider, this.defaultSdkDir,
      {this.defaultSdk});
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
  final Folder dir;

  final ResourceProvider resourceProvider;

  PackageMeta(this.dir, this.resourceProvider);

  @override
  bool operator ==(Object other) {
    if (other is! PackageMeta) return false;
    PackageMeta otherMeta = other;
    return resourceProvider.pathContext.equals(dir.path, otherMeta.dir.path);
  }

  @override
  int get hashCode => pathContext.hash(pathContext.absolute(dir.path));

  p.Context get pathContext => resourceProvider.pathContext;

  /// Returns true if this represents a 'Dart' SDK.
  ///
  /// A package can be part of Dart and Flutter at the same time, but if we are
  /// part of a Dart SDK, [sdkType] should never return null.
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
  PubPackageMeta(Folder dir, ResourceProvider resourceProvider)
      : super(dir, resourceProvider);

  static List<List<String>> __sdkDirFilePaths;

  static List<List<String>> get _sdkDirFilePaths {
    if (__sdkDirFilePaths == null) {
      __sdkDirFilePaths = [];
      if (Platform.isWindows) {
        for (var paths in __sdkDirFilePathsPosix) {
          var windowsPaths = [
            for (var path in paths)
              p.joinAll(p.Context(style: p.Style.posix).split(path)),
          ];
          __sdkDirFilePaths.add(windowsPaths);
        }
      } else {
        __sdkDirFilePaths = __sdkDirFilePathsPosix;
      }
    }
    return __sdkDirFilePaths;
  }

  static final _sdkDirParent = <String, Folder>{};

  /// If [dir] is inside a Dart SDK, returns the directory of the SDK, and `null`
  /// otherwise.
  static Folder sdkDirParent(Folder dir, ResourceProvider resourceProvider) {
    var pathContext = resourceProvider.pathContext;
    var dirPathCanonical = pathContext.canonicalize(dir.path);
    if (!_sdkDirParent.containsKey(dirPathCanonical)) {
      _sdkDirParent[dirPathCanonical] = null;
      while (dir.exists) {
        if (_sdkDirFilePaths.every((List<String> l) {
          return l.any((f) =>
              resourceProvider.getFile(pathContext.join(dir.path, f)).exists);
        })) {
          _sdkDirParent[dirPathCanonical] = dir;
          break;
        }
        dir = dir.parent;
        if (dir == null) break;
      }
    }
    return _sdkDirParent[dirPathCanonical];
  }

  /// Use this instead of fromDir where possible.
  static PubPackageMeta fromElement(LibraryElement libraryElement,
      String sdkDir, ResourceProvider resourceProvider) {
    if (libraryElement.isInSdk) {
      return PubPackageMeta.fromDir(
          resourceProvider.getFolder(sdkDir), resourceProvider);
    }
    return PubPackageMeta.fromDir(
        resourceProvider
            .getFile(resourceProvider.pathContext
                .canonicalize(libraryElement.source.fullName))
            .parent,
        resourceProvider);
  }

  static PubPackageMeta fromFilename(
      String filename, ResourceProvider resourceProvider) {
    return PubPackageMeta.fromDir(
        resourceProvider.getFile(filename).parent, resourceProvider);
  }

  /// This factory is guaranteed to return the same object for any given
  /// [dir.absolute.path].  Multiple [dir.absolute.path]s will resolve to the
  /// same object if they are part of the same package.  Returns null
  /// if the directory is not part of a known package.
  static PubPackageMeta fromDir(Folder dir, ResourceProvider resourceProvider) {
    var pathContext = resourceProvider.pathContext;
    var original = resourceProvider.getFolder(pathContext.absolute(dir.path));
    dir = original;
    if (!original.exists) {
      throw PackageMetaFailure(
          'fatal error: unable to locate the input directory at ${original.path}.');
    }

    if (!_packageMetaCache.containsKey(dir.path)) {
      PackageMeta packageMeta;
      // There are pubspec.yaml files inside the SDK.  Ignore them.
      var parentSdkDir = sdkDirParent(dir, resourceProvider);
      if (parentSdkDir != null) {
        packageMeta = _SdkMeta(parentSdkDir, resourceProvider);
      } else {
        while (dir.exists) {
          var pubspec = resourceProvider
              .getFile(pathContext.join(dir.path, 'pubspec.yaml'));
          if (pubspec.exists) {
            packageMeta = _FilePackageMeta(dir, resourceProvider);
            break;
          }
          // Allow a package to be at root (possible in a Windows setting with
          // drive letter mappings).
          if (dir.parent == null) break;
          // TODO(srawlins): or just... `.parent`?
          dir =
              resourceProvider.getFolder(pathContext.absolute(dir.parent.path));
        }
      }
      _packageMetaCache[pathContext.absolute(dir.path)] = packageMeta;
    }
    return _packageMetaCache[pathContext.absolute(dir.path)];
  }

  @override
  String sdkType(String flutterRootPath) {
    if (flutterRootPath != null) {
      var flutterPackages = pathContext.join(flutterRootPath, 'packages');
      var flutterBinCache = pathContext.join(flutterRootPath, 'bin', 'cache');

      /// Don't include examples or other non-SDK components as being the
      /// "Flutter SDK".
      var canonicalizedDir = pathContext
          .canonicalize(resourceProvider.pathContext.absolute(dir.path));
      if (pathContext.isWithin(flutterPackages, canonicalizedDir) ||
          pathContext.isWithin(flutterBinCache, canonicalizedDir)) {
        return 'Flutter';
      }
    }
    return isSdk ? 'Dart' : null;
  }

  String _resolvedDir;

  @override
  String get resolvedDir {
    _resolvedDir ??= dir.resolveSymbolicLinksSync().path;
    return _resolvedDir;
  }
}

class _FilePackageMeta extends PubPackageMeta {
  File _readme;
  File _license;
  File _changelog;
  Map<dynamic, dynamic> _pubspec;

  _FilePackageMeta(Folder dir, ResourceProvider resourceProvider)
      : super(dir, resourceProvider) {
    var pubspec = dir.getChildAssumingFile('pubspec.yaml');
    assert(pubspec.exists);
    _pubspec = loadYaml(pubspec.readAsStringSync());
  }

  bool _setHostedAt = false;
  String _hostedAt;

  @override
  String get hostedAt {
    if (!_setHostedAt) {
      _setHostedAt = true;
      // Search for 'hosted/host.domain' as the immediate parent directories,
      // and verify that a directory "_temp" exists alongside "hosted".  Those
      // seem to be the only guaranteed things to exist if we're from a pub
      // cache.
      //
      // TODO(jcollins-g): This is a funky heuristic.  Make this better somehow,
      // possibly by calculating hosting directly from pubspec.yaml or importing
      // a pub library to do this.
      // People could have a pub cache at root with Windows drive mappings.
      if (pathContext.split(pathContext.canonicalize(dir.path)).length >= 3) {
        var pubCacheRoot = dir.parent.parent.parent?.path;
        if (pubCacheRoot != null) {
          var hosted = pathContext.canonicalize(dir.parent.parent.path);
          var hostname = pathContext.canonicalize(dir.parent.path);
          if (pathContext.basename(hosted) == 'hosted' &&
              resourceProvider
                  .getFolder(pathContext.join(pubCacheRoot, '_temp'))
                  .exists) {
            _hostedAt = pathContext.basename(hostname);
          }
        }
      }
    }
    return _hostedAt;
  }

  @override
  bool get isSdk => false;

  @override
  bool get needsPubGet => !(resourceProvider
      .getFile(pathContext.join(dir.path, '.dart_tool', 'package_config.json'))
      .exists);

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

File _locate(Folder dir, List<String> fileNames) {
  var files = dir.getChildren().whereType<File>().toList();

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

  _SdkMeta(Folder dir, ResourceProvider resourceProvider)
      : super(dir, resourceProvider) {
    sdkReadmePath =
        resourceProvider.pathContext.join(dir.path, 'lib', 'api_readme.md');
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
    var versionFile = resourceProvider
        .getFile(resourceProvider.pathContext.join(dir.path, 'version'));
    if (versionFile.exists) return versionFile.readAsStringSync().trim();
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
    var f = resourceProvider.getFile(
        resourceProvider.pathContext.join(dir.path, 'lib', 'api_readme.md'));
    if (!f.exists) {
      f = resourceProvider.getFile(
          resourceProvider.pathContext.join(dir.path, 'api_readme.md'));
    }
    return f.exists ? f : null;
  }

  @override
  List<String> getInvalidReasons() => [];

  @override
  File getLicenseContents() => null;

  // TODO: The changelog doesn't seem to be available in the sdk.
  @override
  File getChangelogContents() => null;
}

@visibleForTesting
void clearPackageMetaCache() {
  _packageMetaCache.clear();
}
