// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';

final RegExp substituteNameVersion = RegExp(r'%([bnv])%');

// All hrefs are emitted as relative paths from the output root. We are unable
// to compute them from the page we are generating, and many properties computed
// using hrefs are memoized anyway. To build complete relative hrefs, we emit
// the href with this placeholder, and then replace it with the current page's
// base href afterwards.
// See https://github.com/dart-lang/dartdoc/issues/2090 for further context.
// TODO: Find an approach that doesn't require doing this.
// Unlikely to be mistaken for an identifier, html tag, or something else that
// might reasonably exist normally.
final String HTMLBASE_PLACEHOLDER = '\%\%__HTMLBASE_dartdoc_internal__\%\%';

/// A [LibraryContainer] that contains [Library] objects related to a particular
/// package.
class Package extends LibraryContainer
    with Nameable, Locatable, Canonicalization, Warnable
    implements Privacy, Documentable {
  String _name;
  PackageGraph _packageGraph;

  final Map<String, Category> _nameToCategory = {};

  // Creates a package, if necessary, and adds it to the [packageGraph].
  factory Package.fromPackageMeta(
      PackageMeta packageMeta, PackageGraph packageGraph) {
    var packageName = packageMeta.name;

    var expectNonLocal = false;

    if (!packageGraph.packageMap.containsKey(packageName) &&
        packageGraph.allLibrariesAdded) expectNonLocal = true;
    packageGraph.packageMap.putIfAbsent(
        packageName, () => Package._(packageName, packageGraph, packageMeta));
    // Verify that we don't somehow decide to document locally a package picked
    // up after all documented libraries are added, because that breaks the
    // assumption that we've picked up all documented libraries and packages
    // before allLibrariesAdded is true.
    assert(
        !(expectNonLocal &&
            packageGraph.packageMap[packageName].documentedWhere ==
                DocumentLocation.local),
        'Found more libraries to document after allLibrariesAdded was set to true');
    return packageGraph.packageMap[packageName];
  }

  Package._(this._name, this._packageGraph, this._packageMeta);

  @override
  bool get isCanonical => true;

  @override
  Library get canonicalLibrary => null;

  /// Number of times we have invoked a tool for this package.
  int toolInvocationIndex = 0;

  // The animation IDs that have already been used, indexed by the [href] of the
  // object that contains them.
  Map<String, Set<String>> usedAnimationIdsByHref = {};

  /// Pieces of the location, split to remove 'package:' and slashes.
  @override
  Set<String> get locationPieces => {};

  /// Holds all libraries added to this package.  May include non-documented
  /// libraries, but is not guaranteed to include a complete list of
  /// non-documented libraries unless they are all referenced by documented ones.
  /// Not sorted.
  final Set<Library> allLibraries = {};

  bool get hasHomepage =>
      packageMeta.homepage != null && packageMeta.homepage.isNotEmpty;

  String get homepage => packageMeta.homepage;

  String get kind => (isSdk) ? 'SDK' : 'package';

  @override
  List<Locatable> get documentationFrom => [this];

  /// Return true if the code has defined non-default categories for libraries
  /// in this package.
  bool get hasCategories => categories.isNotEmpty;

  LibraryContainer get defaultCategory => nameToCategory[null];

  String _documentationAsHtml;

  @override
  String get documentationAsHtml {
    if (_documentationAsHtml != null) return _documentationAsHtml;
    _documentationAsHtml = Documentation.forElement(this).asHtml;

    return _documentationAsHtml;
  }

  @override
  String get documentation {
    return hasDocumentationFile ? documentationFile.contents : null;
  }

  @override
  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  @override
  bool get hasExtendedDocumentation => documentation.isNotEmpty;

  // TODO: Clients should use [documentationFile] so they can act differently on
  // plain text or markdown.
  bool get hasDocumentationFile => documentationFile != null;

  FileContents get documentationFile => packageMeta.getReadmeContents();

  @override
  String get oneLineDoc => '';

  @override
  bool get isDocumented =>
      isFirstPackage || documentedWhere != DocumentLocation.missing;

  @override
  Warnable get enclosingElement => null;

  bool _isPublic;

  @override
  bool get isPublic {
    _isPublic ??= libraries.any((l) => l.isPublic);
    return _isPublic;
  }

  bool _isLocal;

  /// Return true if this is the default package, this is part of an embedder
  /// SDK, or if [DartdocOptionContext.autoIncludeDependencies] is true -- but
  /// only if the package was not excluded on the command line.
  bool get isLocal {
    _isLocal ??= (
            // Document as local if this is the default package.
            packageMeta == packageGraph.packageMeta ||
                // Assume we want to document an embedded SDK as local if
                // it has libraries defined in the default package.
                // TODO(jcollins-g): Handle case where embedder SDKs can be
                // assembled from multiple locations?
                packageGraph.hasEmbedderSdk &&
                    packageMeta.isSdk &&
                    libraries.any((l) => path.isWithin(
                        packageGraph.packageMeta.dir.path,
                        (l.element.source.fullName))) ||
                // autoIncludeDependencies means everything is local.
                packageGraph.config.autoIncludeDependencies) &&
        // Regardless of the above rules, do not document as local if
        // we excluded this package by name.
        !packageGraph.config.isPackageExcluded(name);
    return _isLocal;
  }

  DocumentLocation get documentedWhere {
    if (isLocal) {
      if (isPublic) {
        return DocumentLocation.local;
      } else {
        // Possible if excludes result in a "documented" package not having
        // any actual documentation.
        return DocumentLocation.missing;
      }
    } else {
      if (config.linkToRemote && config.linkToUrl.isNotEmpty && isPublic) {
        return DocumentLocation.remote;
      } else {
        return DocumentLocation.missing;
      }
    }
  }

  @override
  String get enclosingName => packageGraph.defaultPackageName;

  String get filePath => 'index.$fileType';

  String get fileType {
    // TODO(jdkoren): Provide a way to determine file type of a remote package's
    // docs. Perhaps make this configurable through dartdoc options.
    // In theory, a remote package could be documented in any supported format.
    // In practice, devs depend on Dart, Flutter, and/or packages fetched
    // from pub.dev, and we know that all of those use html docs.
    if (package.documentedWhere == DocumentLocation.remote) {
      return 'html';
    }
    return config.format;
  }

  @override
  String get fullyQualifiedName => 'package:$name';

  String _baseHref;

  String get baseHref {
    if (_baseHref == null) {
      if (documentedWhere == DocumentLocation.remote) {
        _baseHref =
            config.linkToUrl.replaceAllMapped(substituteNameVersion, (m) {
          switch (m.group(1)) {
            // Return the prerelease tag of the release if a prerelease,
            // or 'stable' otherwise. Mostly coded around
            // the Dart SDK's use of dev/stable, but theoretically applicable
            // elsewhere.
            case 'b':
              {
                var version = Version.parse(packageMeta.version);
                var tag = 'stable';
                if (version.isPreRelease) {
                  // version.preRelease is a List<dynamic> with a mix of
                  // integers and strings.  Given this, handle
                  // 2.8.0-dev.1.0, 2.9.0-1.0.dev, and similar
                  // variations.
                  tag = version.preRelease.whereType<String>().first;
                  // Who knows about non-SDK packages, but assert that SDKs
                  // must conform to the known format.
                  assert(
                      packageMeta.isSdk == false || int.tryParse(tag) == null,
                      'Got an integer as string instead of the expected "dev" tag');
                }
                return tag;
              }
            case 'n':
              return name;
            // The full version string of the package.
            case 'v':
              return packageMeta.version;
            default:
              assert(false, 'Unsupported case: ${m.group(1)}');
              return null;
          }
        });
        if (!_baseHref.endsWith('/')) _baseHref = '${_baseHref}/';
      } else {
        _baseHref = config.useBaseHref ? '' : HTMLBASE_PLACEHOLDER;
      }
    }
    return _baseHref;
  }

  @override
  String get href => '$baseHref$filePath';

  @override
  String get location => path.toUri(packageMeta.resolvedDir).toString();

  @override
  String get name => _name;

  @override
  Package get package => this;

  @override
  PackageGraph get packageGraph => _packageGraph;

  // Workaround for mustache4dart issue where templates do not recognize
  // inherited properties as being in-context.
  @override
  Iterable<Library> get publicLibraries {
    assert(libraries.every((l) => l.packageMeta == _packageMeta));
    return super.publicLibraries;
  }

  /// A map of category name to the category itself.
  Map<String, Category> get nameToCategory {
    if (_nameToCategory.isEmpty) {
      Category categoryFor(String category) {
        _nameToCategory.putIfAbsent(
            category, () => Category(category, this, config));
        return _nameToCategory[category];
      }

      _nameToCategory[null] = Category(null, this, config);
      for (var c in libraries.expand(
          (l) => l.allCanonicalModelElements.whereType<Categorization>())) {
        if (c.hasCategoryNames) {
          for (var category in c.categoryNames) {
            categoryFor(category).addItem(c);
          }
        } else {
          // Add to the default category.
          categoryFor(null).addItem(c);
        }
      }
    }
    return _nameToCategory;
  }

  List<Category> _categories;

  List<Category> get categories {
    _categories ??= nameToCategory.values.where((c) => c.name != null).toList()
      ..sort();
    return _categories;
  }

  Iterable<LibraryContainer> get categoriesWithPublicLibraries =>
      categories.where((c) => c.publicLibraries.isNotEmpty);

  Iterable<Category> get documentedCategories =>
      categories.where((c) => c.isDocumented);

  bool get hasDocumentedCategories => documentedCategories.isNotEmpty;

  DartdocOptionContext _config;

  @override
  DartdocOptionContext get config {
    _config ??= DartdocOptionContext.fromContext(
        packageGraph.config, Directory(packagePath));
    return _config;
  }

  /// Is this the package at the top of the list?  We display the first
  /// package specially (with "Libraries" rather than the package name).
  bool get isFirstPackage =>
      packageGraph.localPackages.isNotEmpty &&
      identical(packageGraph.localPackages.first, this);

  @override
  bool get isSdk => packageMeta.isSdk;

  String _packagePath;

  String get packagePath {
    _packagePath ??= path.canonicalize(packageMeta.dir.path);
    return _packagePath;
  }

  String get version => packageMeta.version ?? '0.0.0-unknown';

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    packageGraph.warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  final PackageMeta _packageMeta;

  PackageMeta get packageMeta => _packageMeta;

  @override
  Element get element => null;

  @override
  List<String> get containerOrder => config.packageOrder;
}
