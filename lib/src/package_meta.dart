// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_meta;

import 'dart:io' show Platform;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
// ignore: implementation_imports
import 'package:analyzer/src/generated/sdk.dart' show DartSdk;
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart';

final Map<String, PackageMeta?> _packageMetaCache = {};

class PackageMetaFailure extends DartdocFailure {
  PackageMetaFailure(super.message);
}

/// For each list in this list, at least one of the given paths must exist
/// for this to be detected as an SDK.  Update [_writeMockSdkBinFiles] in
/// `test/src/utils.dart` if removing any entries here.
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
  messageForMissingPackageMeta: PubPackageMeta.messageForMissingPackageMeta,
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

  final String Function(LibraryElement, DartdocOptionContext)
      _messageForMissingPackageMeta;

  PackageMetaProvider(
    this._fromElement,
    this._fromFilename,
    this._fromDir,
    this.resourceProvider,
    this.defaultSdkDir,
    this.environmentProvider, {
    this.defaultSdk,
    String Function(LibraryElement, DartdocOptionContext)?
        messageForMissingPackageMeta,
  }) : _messageForMissingPackageMeta = messageForMissingPackageMeta ??
            _defaultMessageForMissingPackageMeta;

  PackageMeta? fromElement(LibraryElement library, String s) =>
      _fromElement(library, s, resourceProvider);
  PackageMeta? fromFilename(String s) => _fromFilename(s, resourceProvider);
  PackageMeta? fromDir(Folder dir) => _fromDir(dir, resourceProvider);

  String getMessageForMissingPackageMeta(
          LibraryElement library, DartdocOptionContext optionContext) =>
      _messageForMissingPackageMeta(library, optionContext);

  static String _defaultMessageForMissingPackageMeta(
      LibraryElement library, DartdocOptionContext optionContext) {
    return 'Unknown package for library: ${library.source.fullName}';
  }
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
    var otherMeta = other;
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
  String? sdkType(String? flutterRootPath);

  bool get requiresFlutter;

  String get name;

  /// The hostname that the package is hosted at, usually 'pub.dev', or `null`
  /// if not a hosted pub package.
  String? get hostedAt;

  String get version;

  @Deprecated('This getter will be removed.')
  String get description;

  String get homepage;

  @Deprecated('This getter will be removed.')
  String get repository;

  File? getReadmeContents();

  @Deprecated('This method will be removed.')
  File? getLicenseContents();

  @Deprecated('This method will be removed.')
  File? getChangelogContents();

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
  PubPackageMeta(super.dir, super.resourceProvider);

  static final List<List<String>> _sdkDirFilePaths = Platform.isWindows
      ? [
          for (var paths in _sdkDirFilePathsPosix)
            [
              for (var path in paths)
                p.joinAll(p.Context(style: p.Style.posix).split(path)),
            ],
        ]
      : _sdkDirFilePathsPosix;

  static final _sdkDirParent = <String, Folder?>{};

  /// If [folder] is inside a Dart SDK, returns the directory of the SDK, and `null`
  /// otherwise.
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

  /// Use this instead of fromDir where possible.
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
  /// same object if they are part of the same package.  Returns null
  /// if the directory is not part of a known package.
  static PackageMeta? fromDir(
      Folder folder, ResourceProvider resourceProvider) {
    var pathContext = resourceProvider.pathContext;
    var original =
        resourceProvider.getFolder(pathContext.absolute(folder.path));
    folder = original;
    if (!original.exists) {
      throw PackageMetaFailure(
          'fatal error: unable to locate the input directory at ${original.path}.');
    }

    if (!_packageMetaCache.containsKey(folder.path)) {
      PackageMeta? packageMeta;
      // There are pubspec.yaml files inside the SDK.  Ignore them.
      var parentSdkDir = sdkDirParent(folder, resourceProvider);
      if (parentSdkDir != null) {
        packageMeta = _SdkMeta(parentSdkDir, resourceProvider);
      } else {
        for (var dir in folder.withAncestors) {
          var pubspec = resourceProvider
              .getFile(pathContext.join(dir.path, 'pubspec.yaml'));
          if (pubspec.exists) {
            packageMeta = _FilePackageMeta(dir, resourceProvider);
            break;
          }
        }
      }
      _packageMetaCache[pathContext.absolute(folder.path)] = packageMeta;
    }
    return _packageMetaCache[pathContext.absolute(folder.path)];
  }

  /// Create a helpful user error message for a case where a package can not
  /// be found.
  static String messageForMissingPackageMeta(
      LibraryElement library, DartdocOptionContext optionContext) {
    var libraryString = library.librarySource.fullName;
    var dartOrFlutter = optionContext.flutterRoot == null ? 'dart' : 'flutter';
    return 'Unknown package for library: $libraryString.  Consider `$dartOrFlutter pub get` and/or '
        '`$dartOrFlutter pub global deactivate dartdoc` followed by `$dartOrFlutter pub global activate dartdoc` to fix. '
        'Also, be sure that `$dartOrFlutter analyze` completes without errors.';
  }

  @override
  String? sdkType(String? flutterRootPath) {
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

  @override
  late final String resolvedDir = dir.resolveSymbolicLinksSync().path;
}

class _FilePackageMeta extends PubPackageMeta {
  File? _readme;
  File? _license;
  File? _changelog;

  late final Map<dynamic, dynamic> _pubspec = () {
    var pubspec = dir.getChildAssumingFile('pubspec.yaml');
    assert(pubspec.exists);
    return loadYaml(pubspec.readAsStringSync()) as YamlMap;
  }();

  _FilePackageMeta(super.dir, super.resourceProvider);

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
    if (pathContext.split(pathContext.canonicalize(dir.path)).length >= 3) {
      var pubCacheRoot = dir.parent.parent.parent.path;
      // Check for directory structure too close to root.
      if (pubCacheRoot != dir.parent.parent.path) {
        var hosted = pathContext.canonicalize(dir.parent.parent.path);
        var hostname = pathContext.canonicalize(dir.parent.path);
        if (pathContext.basename(hosted) == 'hosted' &&
            resourceProvider
                .getFolder(pathContext.join(pubCacheRoot, '_temp'))
                .exists) {
          hostedAt = pathContext.basename(hostname);
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
  String get description => _pubspec.getOptionalString('description') ?? '';

  @override
  String get homepage => _pubspec.getOptionalString('homepage') ?? '';

  @override
  String get repository => _pubspec.getOptionalString('repository') ?? '';

  @override
  bool get requiresFlutter =>
      _environment?.containsKey('flutter') == true ||
      _dependencies?.containsKey('flutter') == true;

  YamlMap? get _environment => _pubspec.getOptionalMap('environment');

  YamlMap? get _dependencies => _pubspec.getOptionalMap('dependencies');

  @override
  File? getReadmeContents() =>
      _readme ??= _locate(dir, ['readme.md', 'readme.txt', 'readme']);

  @override
  File? getLicenseContents() =>
      _license ??= _locate(dir, ['license.md', 'license.txt', 'license']);

  @override
  File? getChangelogContents() => _changelog ??=
      _locate(dir, ['changelog.md', 'changelog.txt', 'changelog']);

  /// Returns a list of reasons this package is invalid, or an
  /// empty list if no reasons found.
  @override
  List<String> getInvalidReasons() {
    var reasons = <String>[];
    if (_pubspec.isEmpty) {
      reasons.add('no pubspec.yaml found');
    } else if (!_pubspec.containsKey('name')) {
      reasons.add('no name found in pubspec.yaml');
    }
    return reasons;
  }
}

File? _locate(Folder dir, List<String> fileNames) {
  var files = dir.getChildren().whereType<File>().toList(growable: false);

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
  String get description =>
      'The Dart SDK is a set of tools and libraries for the '
      'Dart programming language.';

  @override
  String get homepage => 'https://github.com/dart-lang/sdk';

  @override
  String get repository => 'https://github.com/dart-lang/sdk';

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

  @override
  File? getLicenseContents() => null;

  // TODO: The changelog doesn't seem to be available in the sdk.
  @override
  File? getChangelogContents() => null;
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
