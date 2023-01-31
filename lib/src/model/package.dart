// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p show Context;
import 'package:pub_semver/pub_semver.dart';

// All hrefs are emitted as relative paths from the output root. We are unable
// to compute them from the page we are generating, and many properties computed
// using hrefs are memoized anyway. To build complete relative hrefs, we emit
// the href with this placeholder, and then replace it with the current page's
// base href afterwards.
// See https://github.com/dart-lang/dartdoc/issues/2090 for further context.
// TODO: Find an approach that doesn't require doing this.
// Unlikely to be mistaken for an identifier, html tag, or something else that
// might reasonably exist normally.
@internal
const String htmlBasePlaceholder = r'%%__HTMLBASE_dartdoc_internal__%%';

/// A [LibraryContainer] that contains [Library] objects related to a particular
/// package.
class Package extends LibraryContainer
    with
        Nameable,
        Locatable,
        Canonicalization,
        Warnable,
        CommentReferable,
        ModelBuilder
    implements Privacy, Documentable {
  @override
  final String name;

  @override
  final PackageGraph packageGraph;

  // Creates a package, if necessary, and adds it to the [packageGraph].
  factory Package.fromPackageMeta(
      PackageMeta packageMeta, PackageGraph packageGraph) {
    var packageName = packageMeta.name;
    var expectNonLocal = !packageGraph.packageMap.containsKey(packageName) &&
        packageGraph.allLibrariesAdded;
    var packagePath = packageGraph.resourceProvider.pathContext
        .canonicalize(packageMeta.dir.path);
    var package = packageGraph.packageMap.putIfAbsent(
      packageMeta.name,
      () => Package._(
        packageMeta.name,
        packageGraph,
        packageMeta,
        packagePath,
      ),
    );
    // Verify that we don't somehow decide to document locally a package picked
    // up after all documented libraries are added, because that breaks the
    // assumption that we've picked up all documented libraries and packages
    // before allLibrariesAdded is true.
    assert(
        !(expectNonLocal && package.documentedWhere == DocumentLocation.local),
        "Found more libraries to document after 'allLibrariesAdded' was set to "
        'true');
    return package;
  }

  Package._(this.name, this.packageGraph, this.packageMeta, this.packagePath)
      : config = DartdocOptionContext.fromContext(
          packageGraph.config,
          packageGraph.resourceProvider.getFolder(packagePath),
          packageGraph.resourceProvider,
        );

  @override
  bool get isCanonical => true;

  @override
  Library? get canonicalLibrary => null;

  /// Number of times we have invoked a tool for this package.
  int toolInvocationIndex = 0;

  // The animation IDs that have already been used, indexed by the [href] of the
  // object that contains them.
  Map<String?, Set<String>> usedAnimationIdsByHref = {};

  /// Pieces of the location, split to remove 'package:' and slashes.
  @override
  Set<String> get locationPieces => const {};

  /// Holds all libraries added to this package.  May include non-documented
  /// libraries, but is not guaranteed to include a complete list of
  /// non-documented libraries unless they are all referenced by documented ones.
  final Set<Library> allLibraries = {};

  bool get hasHomepage => packageMeta.homepage.isNotEmpty;

  String get homepage => packageMeta.homepage;

  @override
  String get kind => isSdk ? 'SDK' : 'package';

  @override
  List<Locatable> get documentationFrom => [this];

  /// Return true if the code has defined non-default categories for libraries
  /// in this package.
  bool get hasCategories => categories.isNotEmpty;

  @override
  late final String documentationAsHtml = Documentation.forElement(this).asHtml;

  /// The documentation from the README contents.
  @override
  late final String? documentation = () {
    final docFile = packageMeta.getReadmeContents();
    return docFile != null
        ? packageGraph.resourceProvider
            .readAsMalformedAllowedStringSync(docFile)
        : null;
  }();

  @override
  bool get hasDocumentation => documentation?.isNotEmpty == true;

  @override
  String get oneLineDoc => '';

  @override
  bool get isDocumented =>
      isFirstPackage || documentedWhere != DocumentLocation.missing;

  /// If we have public libraries, this is the default package, or we are
  /// auto-including dependencies, this package is public.
  @override
  bool get isPublic =>
      _isLocalPublicByDefault || libraries.any((l) => l.isPublic);

  /// Return true if this is the default package, this is part of an embedder
  /// SDK, or if [DartdocOptionContext.autoIncludeDependencies] is true -- but
  /// only if the package was not excluded on the command line.
  late final bool isLocal = () {
    // Do not document as local if we excluded this package by name.
    if (_isExcluded) return false;
    // Document as local if this is the default package.
    if (_isLocalPublicByDefault) return true;
    // Assume we want to document an embedded SDK as local if it has libraries
    // defined in the default package.
    // TODO(jcollins-g): Handle case where embedder SDKs can be assembled from
    // multiple locations?
    if (!packageGraph.hasEmbedderSdk) return false;
    if (!packageMeta.isSdk) return false;
    final packagePath = packageGraph.packageMeta.dir.path;
    return libraries.any(
        (l) => _pathContext.isWithin(packagePath, l.element.source.fullName));
  }();

  /// True if the global config excludes this package by name.
  bool get _isExcluded => packageGraph.config.isPackageExcluded(name);

  /// True if this is the package being documented by default, or the
  /// global config indicates we are auto-including dependencies.
  bool get _isLocalPublicByDefault =>
      packageMeta == packageGraph.packageMeta ||
      packageGraph.config.autoIncludeDependencies;

  /// Returns the location of documentation for this package, for linkToRemote
  /// and canonicalization decision making.
  late final DocumentLocation documentedWhere = () {
    if (isLocal && isPublic) {
      return DocumentLocation.local;
    }
    if (config.linkToRemote &&
        config.linkToUrl.isNotEmpty &&
        isPublic &&
        !packageGraph.config.isPackageExcluded(name)) {
      return DocumentLocation.remote;
    }
    return DocumentLocation.missing;
  }();

  @override
  String get enclosingName => packageGraph.defaultPackageName;

  String get filePath => 'index.$fileType';

  // TODO(jdkoren): Provide a way to determine file type of a remote package's
  // docs. Perhaps make this configurable through dartdoc options.
  // In theory, a remote package could be documented in any supported format.
  // In practice, devs depend on Dart, Flutter, and/or packages fetched
  // from pub.dev, and we know that all of those use html docs.
  String get fileType => package.documentedWhere == DocumentLocation.remote
      ? 'html'
      : config.format;

  @override
  String get fullyQualifiedName => 'package:$name';

  late final String baseHref = documentedWhere == DocumentLocation.remote
      ? (_remoteBaseHref.endsWith('/') ? _remoteBaseHref : '$_remoteBaseHref/')
      : (config.useBaseHref ? '' : htmlBasePlaceholder);

  String get _remoteBaseHref {
    return config.linkToUrl.replaceAllMapped(_substituteNameVersion, (m) {
      switch (m.group(1)) {
        // Return the prerelease tag of the release if a prerelease, or 'stable'
        // otherwise.  Mostly coded around the Dart SDK's use of dev/stable, but
        // theoretically applicable elsewhere.
        case 'b':
          {
            var version = Version.parse(packageMeta.version);
            var tag = 'stable';
            if (version.isPreRelease) {
              // `version.preRelease` is a `List<dynamic>` with a mix of
              // integers and strings.  Given this, handle
              // "2.8.0-dev.1.0, 2.9.0-1.0.dev", and similar variations.
              tag = version.preRelease.whereType<String>().first;
              // Who knows about non-SDK packages, but SDKs must conform to the
              // known format.
              assert(packageMeta.isSdk == false || int.tryParse(tag) == null,
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
          return '';
      }
    });
  }

  static final _substituteNameVersion = RegExp(r'%([bnv])%');

  @override
  String get href => '$baseHref$filePath';

  @override
  String get location => _pathContext.toUri(packageMeta.resolvedDir).toString();

  @override
  Package get package => this;

  // Workaround for mustache4dart issue where templates do not recognize
  // inherited properties as being in-context.
  @override
  Iterable<Library> get publicLibraries {
    assert(libraries.every((l) => l.packageMeta == packageMeta));
    return super.publicLibraries;
  }

  /// The default, unnamed category.
  ///
  /// This is initialized by [initializeCategories].
  late final Category defaultCategory;

  /// A map of category name to the category itself.
  ///
  /// This is initialized by [initializeCategories].
  late final Map<String?, Category> nameToCategory;

  /// Adds [categorization] to one or more categories in the [nameToCategory]
  /// map, if it is annotated with `{@category}`, or `[defaultCategory], if not,
  /// via the [addTo] callback.
  void addToCategories(
      Categorization categorization, void Function(Category) addTo) {
    if (!categorization.isCanonical) {
      return;
    }
    var categoryNames = categorization.categoryNames;
    if (categoryNames == null || categoryNames.isEmpty) {
      addTo(defaultCategory);
      return;
    }
    for (var category in categoryNames) {
      addTo(nameToCategory.putIfAbsent(
          category, () => Category(category, this, config)));
    }
  }

  /// Initializes the [defaultCategory] and the [nameToCategory] map, with all
  /// appropriate elements.
  void initializeCategories() {
    defaultCategory = Category(null, this, config);
    nameToCategory = {};
    for (var library in libraries) {
      addToCategories(library, (c) => c.libraries.add(library));
      for (var constant in library.constants) {
        addToCategories(constant, (c) => c.constants.add(constant));
      }
      for (var function in library.functions) {
        addToCategories(function, (c) => c.functions.add(function));
      }
      for (var property in library.properties) {
        addToCategories(property, (c) => c.properties.add(property));
      }
      for (var typedef_ in library.typedefs) {
        addToCategories(typedef_, (c) => c.typedefs.add(typedef_));
      }
      for (var extension in library.extensions) {
        addToCategories(extension, (c) => c.extensions.add(extension));
      }
      for (var class_ in library.allClasses) {
        addToCategories(class_, (c) => c.addClass(class_));
      }
      for (var enum_ in library.enums) {
        addToCategories(enum_, (c) => c.enums.add(enum_));
      }
      for (var mixin in library.mixins) {
        addToCategories(mixin, (c) => c.mixins.add(mixin));
      }
    }
  }

  /// The categories, sorted alphabetically by name.
  late final List<Category> categories = [
    defaultCategory,
    ...nameToCategory.values,
  ].where((c) => c.name.isNotEmpty).toList(growable: false)
    ..sort();

  Iterable<Category> get categoriesWithPublicLibraries =>
      categories.where((c) => c.publicLibraries.isNotEmpty);

  Iterable<Category> get documentedCategories =>
      categories.where((c) => c.isDocumented);

  /// The documented categories, sorted either by the 'categoryOrder' option, or
  /// by name.
  ///
  /// In the case that 'categoryOrder' is given, any documented categories which
  /// are not found in 'categoryOrder' are listed after the ones which are,
  /// ordered by name.
  Iterable<Category> get documentedCategoriesSorted {
    if (config.categoryOrder.isNotEmpty) {
      final documentedCategories =
          this.documentedCategories.toList(growable: false);
      return documentedCategories
        ..sort((a, b) {
          var aIndex = config.categoryOrder.indexOf(a.name);
          var bIndex = config.categoryOrder.indexOf(b.name);
          if (aIndex >= 0 && bIndex >= 0) {
            return aIndex.compareTo(bIndex);
          } else if (aIndex < 0 && bIndex >= 0) {
            // `a` is not found in the category order, but `b` is.
            return 1;
          } else if (bIndex < 0 && aIndex >= 0) {
            // `b` is not found in the category order, but `a` is.
            return -1;
          } else {
            // Neither is found in the category order.
            return documentedCategories
                .indexOf(a)
                .compareTo(documentedCategories.indexOf(b));
          }
        });
    } else {
      // Category display order is configurable; leave the category order
      // as defined if the order is specified.
      return documentedCategories;
    }
  }

  bool get hasDocumentedCategories => documentedCategories.isNotEmpty;

  @override
  final DartdocOptionContext config;

  /// Is this the package at the top of the list?  We display the first
  /// package specially (with "Libraries" rather than the package name).
  bool get isFirstPackage =>
      packageGraph.localPackages.isNotEmpty &&
      identical(packageGraph.localPackages.first, this);

  @override
  bool get isSdk => packageMeta.isSdk;

  final String packagePath;

  String get version => packageMeta.version;

  final PackageMeta packageMeta;

  @override
  Element? get element => null;

  @override
  List<String> get containerOrder => config.packageOrder;

  @override
  late final Map<String, CommentReferable> referenceChildren =
      <String, CommentReferable>{
    for (var library in publicLibrariesSorted) library.referenceName: library,
  }
        // Do not override any preexisting data, and insert based on the
        // public library sort order.
        // TODO(jcollins-g): warn when results require package-global
        // lookups like this.
        ..addEntriesIfAbsent(
            publicLibrariesSorted.expand((l) => l.referenceChildren.entries));

  @override
  Iterable<CommentReferable> get referenceParents => [packageGraph];

  p.Context get _pathContext => packageGraph.resourceProvider.pathContext;

  @override
  String get referenceName => 'package:$name';
}
