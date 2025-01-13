// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: analyzer_use_new_elements

import 'dart:io' show Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:dartdoc/src/failure.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

final Map<String, PackageMeta?> _packageMetaCache = {};

class PackageMetaFailure extends DartdocFailure {
  PackageMetaFailure(super.message);
}

/// Various relative paths that indicate that a root directory is an SDK (Dart
/// or Flutter).
///
/// For a given directory to be detected as an SDK, at least one of the given
/// paths must exist, for each list of paths.
// Update `_writeMockSdkBinFiles` in `test/src/utils.dart` if removing any
// entries here.
const List<List<String>> _sdkDirFilePathsPosix = [
  ['bin/dart.bat', 'bin/dart.exe', 'bin/dart'],
  ['include/dart_version.h'],
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
      .parent,
  Platform.environment,
);

/// Sets the supported way of constructing [PackageMeta] objects.
///
/// These objects can be constructed from a filename, a directory
/// or a [LibraryElement]. We allow different dartdoc implementations to
/// provide their own [PackageMeta] types.
///
/// By using a different provider, these implementations can control how
/// [PackageMeta] objects are built.
class PackageMetaProvider {
  final PackageMeta? Function(LibraryElement, String, ResourceProvider)
      _fromElement;
  final PackageMeta? Function(String, ResourceProvider) _fromFilename;
  final PackageMeta? Function(Folder, ResourceProvider) _fromDir;

  final ResourceProvider resourceProvider;
  final Folder defaultSdkDir;
  final DartSdk? defaultSdk;
  final Map<String, String> environmentProvider;

  PackageMetaProvider(
    this._fromElement,
    this._fromFilename,
    this._fromDir,
    this.resourceProvider,
    this.defaultSdkDir,
    this.environmentProvider, {
    this.defaultSdk,
  });

  PackageMeta? fromElement(LibraryElement library, String s) =>
      _fromElement(library, s, resourceProvider);
  PackageMeta? fromFilename(String s) => _fromFilename(s, resourceProvider);
  PackageMeta? fromDir(Folder dir) => _fromDir(dir, resourceProvider);
}

/// Describes a single package in the context of `dartdoc`.
///
/// The primary function of this class is to allow canonicalization of packages
/// by returning the same [PackageMeta] for a given filename, library or path
/// if they belong to the same package.
///
/// Overriding this is typically done by overriding factories as rest of
/// `dartdoc` creates this object by calling these static factories.
// This class has a single direct subclass in this package, [PubPackageMeta],
// but has other subclasses in google3.
abstract class PackageMeta {
  final Folder dir;

  final ResourceProvider resourceProvider;

  PackageMeta(this.dir, this.resourceProvider);

  @override
  bool operator ==(Object other) =>
      other is PackageMeta && _pathContext.equals(dir.path, other.dir.path);

  @override
  int get hashCode => _pathContext.hash(_pathContext.absolute(dir.path));

  path.Context get _pathContext => resourceProvider.pathContext;

  /// Whether this represents a 'Dart' SDK.
  ///
  /// A package can be part of Dart and Flutter at the same time, but if this is
  /// part of a Dart SDK, [sdkType] should never return null.
  bool get isSdk;

  /// Returns 'Dart' or 'Flutter' (preferentially, 'Flutter' when the answer is
  /// "both"), or `null` if this package is not part of an SDK.
  String? sdkType(String? flutterRootPath);

  bool get requiresFlutter;

  String get name;

  /// The hostname that the package is hosted at, usually 'pub.dev', or `null`
  /// if not a hosted pub package.
  String? get hostedAt;

  String get version;

  String get homepage;

  File? getReadmeContents();

  /// Whether this is a valid package (valid enough to generate docs).
  bool get isValid => getInvalidReasons().isEmpty;

  String get resolvedDir;

  /// The list of reasons this package is invalid.
  ///
  /// If the list is empty, this package is valid.
  List<String> getInvalidReasons();

  @override
  String toString() => name;
}

/// Default implementation of [PackageMeta] depends on pub packages.
abstract class PubPackageMeta extends PackageMeta {
  PubPackageMeta(super.dir, super.resourceProvider);

  static final List<List<String>> _sdkDirFilePaths = Platform.isWindows
      ? [
          for (var filePaths in _sdkDirFilePathsPosix)
            [
              for (var filePath in filePaths)
                path.joinAll(path.posix.split(filePath)),
            ],
        ]
      : _sdkDirFilePathsPosix;

  static final _sdkDirParent = <String, Folder?>{};

  /// If [folder] is inside a Dart SDK, returns the directory of the SDK, and
  /// `null` otherwise.
  static Folder? sdkDirParent(
      Folder folder, ResourceProvider resourceProvider) {
    var pathContext = resourceProvider.pathContext;
    var dirPathCanonical = pathContext.canonicalize(folder.path);
    if (!_sdkDirParent.containsKey(dirPathCanonical)) {
      _sdkDirParent[dirPathCanonical] = null;
      for (var dir in folder.withAncestors) {
        if (_sdkDirFilePaths.every((List<String> l) {
          return l.any((f) =>
              resourceProvider.getFile(pathContext.join(dir.path, f)).exists);
        })) {
          _sdkDirParent[dirPathCanonical] = dir;
          break;
        }
      }
    }
    return _sdkDirParent[dirPathCanonical];
  }

  /// Use this instead of [fromDir] where possible.
  static PackageMeta? fromElement(LibraryElement libraryElement, String sdkDir,
      ResourceProvider resourceProvider) {
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

  static PackageMeta? fromFilename(
      String filename, ResourceProvider resourceProvider) {
    return PubPackageMeta.fromDir(
        resourceProvider.getFile(filename).parent, resourceProvider);
  }

  /// This factory is guaranteed to return the same object for any given
  /// `dir.absolute.path`.  Multiple `dir.absolute.path`s will resolve to the
  /// same object if they are part of the same package.  Returns `null` if the
  /// directory is not part of a known package.
  static PackageMeta? fromDir(
      Folder folder, ResourceProvider resourceProvider) {
    var pathContext = resourceProvider.pathContext;
    folder = resourceProvider.getFolder(pathContext.absolute(folder.path));
    if (!folder.exists) {
      throw PackageMetaFailure(
        'fatal error: unable to locate the input directory at '
        "'${folder.path}'.",
      );
    }

    return _packageMetaCache.putIfAbsent(pathContext.absolute(folder.path), () {
      // There are pubspec.yaml files inside the SDK.  Ignore them.
      var parentSdkDir = sdkDirParent(folder, resourceProvider);
      if (parentSdkDir != null) {
        return _SdkMeta(parentSdkDir, resourceProvider);
      } else {
        for (var dir in folder.withAncestors) {
          var pubspec = resourceProvider
              .getFile(pathContext.join(dir.path, 'pubspec.yaml'));
          if (pubspec.exists) {
            return _FilePackageMeta(dir, resourceProvider);
          }
        }
      }
      return null;
    });
  }

  @override
  String? sdkType(String? flutterRootPath) {
    if (flutterRootPath != null) {
      var flutterPackages = _pathContext.join(flutterRootPath, 'packages');
      var flutterBinCache = _pathContext.join(flutterRootPath, 'bin', 'cache');

      /// Don't include examples or other non-SDK components as being the
      /// "Flutter SDK".
      var canonicalizedDir = _pathContext
          .canonicalize(resourceProvider.pathContext.absolute(dir.path));
      if (_pathContext.isWithin(flutterPackages, canonicalizedDir) ||
          _pathContext.isWithin(flutterBinCache, canonicalizedDir)) {
        return 'Flutter';
      }
    }
    return isSdk ? 'Dart' : null;
  }

  @override
  late final String resolvedDir = dir.resolveSymbolicLinksSync().path;
}

class _FilePackageMeta extends PubPackageMeta {
  File? _readme;

  final Map<dynamic, dynamic> _pubspec;

  _FilePackageMeta(super.dir, super.resourceProvider)
      : _pubspec = loadYaml(
                dir.getChildAssumingFile('pubspec.yaml').readAsStringSync())
            as YamlMap;

  @override
  late final String? hostedAt = () {
    String? hostedAt;
    // Search for 'hosted/host.domain' as the immediate parent directories,
    // and verify that a directory "_temp" exists alongside "hosted".  Those
    // seem to be the only guaranteed things to exist if we're from a pub
    // cache.
    //
    // TODO(jcollins-g): This is a funky heuristic.  Make this better somehow,
    // possibly by calculating hosting directly from pubspec.yaml or importing
    // a pub library to do this.
    // People could have a pub cache at root with Windows drive mappings.
    if (_pathContext.split(_pathContext.canonicalize(dir.path)).length >= 3) {
      var pubCacheRoot = dir.parent.parent.parent.path;
      // Check for directory structure too close to root.
      if (pubCacheRoot != dir.parent.parent.path) {
        var hosted = _pathContext.canonicalize(dir.parent.parent.path);
        var hostname = _pathContext.canonicalize(dir.parent.path);
        if (_pathContext.basename(hosted) == 'hosted' &&
            resourceProvider
                .getFolder(_pathContext.join(pubCacheRoot, '_temp'))
                .exists) {
          hostedAt = _pathContext.basename(hostname);
        }
      }
    }
    return hostedAt;
  }();

  @override
  bool get isSdk => false;

  @override
  String get name => _pubspec.getOptionalString('name') ?? '';

  @override
  String get version =>
      _pubspec.getOptionalString('version') ?? '0.0.0-unknown';

  @override
  String get homepage => _pubspec.getOptionalString('homepage') ?? '';

  @override
  bool get requiresFlutter =>
      _environment?.containsKey('flutter') == true ||
      _dependencies?.containsKey('flutter') == true;

  YamlMap? get _environment => _pubspec.getOptionalMap('environment');

  YamlMap? get _dependencies => _pubspec.getOptionalMap('dependencies');

  @override
  File? getReadmeContents() =>
      _readme ??= _locate(dir, ['readme.md', 'readme.txt', 'readme']);

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  @override
  List<String> getInvalidReasons() {
    return [
      if (_pubspec.isEmpty) 'no pubspec.yaml found',
      if (!_pubspec.containsKey('name')) "no 'name' field found in pubspec.yaml"
    ];
  }
}

File? _locate(Folder dir, List<String> fileNames) {
  var files = dir.getChildren().whereType<File>().toList(growable: false);

  for (var name in fileNames) {
    for (var f in files) {
      var baseName = path.basename(f.path).toLowerCase();
      if (baseName == name) return f;
      if (baseName.startsWith(name)) return f;
    }
  }

  return null;
}

class _SdkMeta extends PubPackageMeta {
  late final String sdkReadmePath =
      resourceProvider.pathContext.join(dir.path, 'lib', 'api_readme.md');

  _SdkMeta(super.dir, super.resourceProvider);

  @override
  String? get hostedAt => null;

  @override
  bool get isSdk => true;

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
  String get homepage => 'https://github.com/dart-lang/sdk';

  @override
  bool get requiresFlutter => false;

  @override
  File? getReadmeContents() {
    var f = resourceProvider.getFile(
        resourceProvider.pathContext.join(dir.path, 'lib', 'api_readme.md'));
    if (!f.exists) {
      f = resourceProvider.getFile(
          resourceProvider.pathContext.join(dir.path, 'api_readme.md'));
    }
    return f.exists ? f : null;
  }

  @override
  List<String> getInvalidReasons() => const [];
}

@visibleForTesting
void clearPackageMetaCache() {
  _packageMetaCache.clear();
}

/// Extensions for a Map of YAML data, like a pubspec.
extension on Map<dynamic, dynamic> {
  /// Gets the value for [key], casting to a nullable [YamlMap].
  YamlMap? getOptionalMap(dynamic key) => this[key] as YamlMap?;

  /// Gets the value for [key], casting to a nullable [String].
  String? getOptionalString(dynamic key) => this[key] as String?;
}
