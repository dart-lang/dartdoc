// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/comment_references/parser.dart' show operatorNames;
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

// ---------------------------------------------------------------------------
// Pre-compiled regular expressions for sanitization methods.
// ---------------------------------------------------------------------------

/// Characters unsafe for file names on Windows/macOS/Linux.
final _unsafeFileChars = RegExp(r'[:<>|?*"/\\]');

/// One or more consecutive hyphens.
final _multiDash = RegExp(r'-+');

/// Leading or trailing hyphen.
final _leadTrailDash = RegExp(r'^-|-$');

/// Any non-alphanumeric character (for anchor sanitization).
final _nonAlphanumeric = RegExp(r'[^a-zA-Z0-9]');

/// Computes VitePress-compatible file paths and URLs for documentation elements.
///
/// This class NEVER reads `element.fileName`, `element.filePath`, or
/// `element.href` as those produce HTML-specific paths. All paths are computed
/// from raw `name` and `library.dirName`.
///
/// In multi-package mode, libraries with conflicting `dirName` values are
/// disambiguated by prefixing with the package name (e.g., `auth_core`
/// instead of just `core`).
class VitePressPathResolver {
  /// Maps library identity to its unique directory name.
  ///
  /// Built by [initFromPackageGraph] to handle multi-package dirName
  /// collisions.
  final Map<Library, String> _libraryDirNames = {};

  /// Initializes the resolver with unique directory names for all libraries.
  ///
  /// Must be called before any path resolution when documenting multiple
  /// packages. Detects dirName collisions and prefixes with package name.
  void initFromPackageGraph(PackageGraph packageGraph) {
    _libraryDirNames.clear();

    // Collect all (library, dirName) pairs.
    final allLibraries = <Library>[];
    final dirNameCounts = <String, int>{};

    for (final package in packageGraph.localPackages) {
      for (final library in package.publicLibrariesSorted) {
        allLibraries.add(library);
        dirNameCounts[library.dirName] =
            (dirNameCounts[library.dirName] ?? 0) + 1;
      }
    }

    // Assign unique dir names: prefix with package name only on collision.
    for (final library in allLibraries) {
      final baseName = library.dirName;
      if (dirNameCounts[baseName]! > 1) {
        _libraryDirNames[library] = '${library.package.name}_$baseName';
      } else {
        _libraryDirNames[library] = baseName;
      }
    }
  }

  /// Returns the collision-safe directory name for [library].
  ///
  /// Uses the mapping from [initFromPackageGraph] if available, otherwise
  /// falls back to [Library.dirName]. This is the public accessor for use
  /// by the sidebar generator.
  String dirNameFor(Library library) => _resolvedDirName(library);

  /// Returns the file path (relative to output root) for a documentation page.
  ///
  /// Returns `null` for member-level elements that do not have their own page
  /// (constructors, methods, fields, operators) -- these are rendered as
  /// anchors on their container's page.
  ///
  /// Also returns `null` for elements that have no page at all (parameters,
  /// type parameters, dynamic, Never).
  ///
  /// Examples:
  /// - Package: `api/index.md`
  /// - Library: `api/modularity_core/index.md`
  /// - Class: `api/modularity_core/SimpleBinder.md`
  /// - Category: `topics/MyTopic.md`
  String? filePathFor(Documentable element) {
    if (element is Package) {
      return 'api/index.md';
    }

    if (element is Category) {
      return 'topics/${sanitizeFileName(element.name)}.md';
    }

    if (element is Library) {
      return 'api/${_resolvedDirName(element)}/index.md';
    }

    // Elements that never have their own pages (parameters, type parameters,
    // dynamic, Never).
    if (element is HasNoPage) {
      return null;
    }

    // Member-level elements do not have their own pages.
    if (_isMemberElement(element)) {
      return null;
    }

    // Container-level and top-level elements get their own pages.
    if (element is ModelElement) {
      final dirName = _libraryDirName(element);
      if (dirName == null) return null;
      final fileName = _safeFileName(element.name, element);
      return 'api/$dirName/$fileName.md';
    }

    return null;
  }

  /// Returns the URL path for linking to an element's page.
  ///
  /// For member-level elements, returns the URL of their container page
  /// (without anchor). Use [linkFor] for a full URL including anchors.
  ///
  /// Returns `null` for elements that have no page (parameters, type
  /// parameters, dynamic, Never).
  ///
  /// Examples:
  /// - Package: `/api/`
  /// - Library: `/api/modularity_core/`
  /// - Class: `/api/modularity_core/SimpleBinder`
  /// - Category: `/topics/MyTopic`
  String? urlFor(Documentable element) {
    if (element is Package) {
      return '/api/';
    }

    if (element is Category) {
      return '/topics/${sanitizeFileName(element.name)}';
    }

    if (element is Library) {
      return '/api/${_resolvedDirName(element)}/';
    }

    // Elements that never have their own pages.
    if (element is HasNoPage) {
      return null;
    }

    // Member-level elements: return the container's URL.
    if (_isMemberElement(element)) {
      final container = _containerOf(element as ModelElement);
      if (container != null) {
        return urlFor(container);
      }
      return null;
    }

    // Container-level and top-level elements.
    if (element is ModelElement) {
      final dirName = _libraryDirName(element);
      if (dirName == null) return null;
      final fileName = _safeFileName(element.name, element);
      return '/api/$dirName/$fileName';
    }

    return null;
  }

  /// Returns the anchor ID for a member element.
  ///
  /// Strips generic type parameters from the name and converts operator
  /// symbols to human-readable names.
  ///
  /// Examples:
  /// - Method `get`: `#get`
  /// - Method `get<T>`: `#get` (generics stripped)
  /// - Operator `operator ==`: `#operator-equals`
  /// - Constructor `SimpleBinder`: `#simplebinder`
  /// - Constructor `SimpleBinder.named`: `#named`
  String? anchorFor(ModelElement element) {
    if (!_isMemberElement(element)) return null;

    if (element is Operator) {
      // Use referenceName which gives the raw operator symbol (e.g., '==')
      // without the 'operator ' prefix.
      final operatorSymbol = element.referenceName;
      final mappedName = operatorNames[operatorSymbol];
      if (mappedName != null) {
        return '#operator-$mappedName';
      }
      // Fallback: sanitize the operator symbol.
      return '#operator-${sanitizeAnchor(operatorSymbol)}';
    }

    // For constructors, prefix with 'ctor-' for unnamed constructors to avoid
    // collision with VitePress auto-generated ID for the class H1 heading.
    if (element is Constructor) {
      final name = stripGenerics(element.referenceName).toLowerCase();
      if (element.isUnnamedConstructor) {
        return '#ctor-$name';
      }
      return '#$name';
    }

    // For fields, add prop- prefix to match renderer's _memberAnchor().
    if (element is Field) {
      final name = stripGenerics(element.name);
      return '#prop-${name.toLowerCase()}';
    }

    // For methods, strip generics and lowercase.
    final name = stripGenerics(element.name);
    return '#${name.toLowerCase()}';
  }

  /// Returns the full link URL for any element (container or member).
  ///
  /// For containers: `/api/modularity_core/SimpleBinder`
  /// For members: `/api/modularity_core/SimpleBinder#get`
  /// For packages: `/api/`
  /// For libraries: `/api/modularity_core/`
  /// For categories: `/topics/MyTopic`
  ///
  /// Returns `null` for elements that have no page (parameters, type
  /// parameters, dynamic, Never) -- these are rendered as inline code.
  String? linkFor(Documentable element) {
    // Elements that never have their own pages.
    if (element is HasNoPage) {
      return null;
    }

    if (_isMemberElement(element) && element is ModelElement) {
      final containerUrl = _containerUrl(element);
      if (containerUrl == null) return null;
      final anchor = anchorFor(element);
      if (anchor == null) return containerUrl;
      return '$containerUrl$anchor';
    }
    return urlFor(element);
  }

  /// Returns the library directory name for an element, or `null` if the
  /// element's canonical library is not documented locally.
  ///
  /// Uses `canonicalLibrary` with null-safety for re-exported elements.
  /// Falls back to `library` if `canonicalLibrary` is null.
  ///
  /// Returns `null` for elements whose canonical library belongs to a
  /// non-local package (SDK, external pub packages) so that the caller
  /// can fall back to the model's built-in remote `href`.
  String? _libraryDirName(Documentable element) {
    if (element is Library) {
      if (element.package.documentedWhere != DocumentLocation.local) {
        return null;
      }
      return _resolvedDirName(element);
    }
    if (element is ModelElement) {
      final lib = element.canonicalLibrary ?? element.library;
      if (lib == null) return null;
      if (lib.package.documentedWhere != DocumentLocation.local) {
        return null;
      }
      return _resolvedDirName(lib);
    }
    return null;
  }

  /// Returns the unique directory name for [library], using the collision-safe
  /// mapping from [initFromPackageGraph] if available, otherwise falling back
  /// to the library's own [Library.dirName].
  String _resolvedDirName(Library library) {
    return _libraryDirNames[library] ?? library.dirName;
  }

  /// Returns a safe file name for an element.
  ///
  /// 1. Sanitizes characters that are invalid on common file systems
  ///    (Windows, macOS, Linux).
  /// 2. Avoids collision with `index.md` (used for library overview pages)
  ///    by appending a kind-based suffix.
  ///
  /// Examples:
  /// - Class named "index" -> `index-class`
  /// - Class named "MyClass" -> `MyClass` (no suffix needed)
  /// - Class named `Foo<Bar>` -> `Foo` (generics stripped)
  String _safeFileName(String name, Documentable element) {
    var safe = sanitizeFileName(name);
    if (safe.toLowerCase() == 'index') {
      // Collision avoidance: append element kind suffix.
      safe = '$safe-${_kindSuffix(element)}';
    }
    return safe;
  }

  /// Sanitizes a string for use as a file name.
  ///
  /// Replaces characters that are invalid or problematic on common file
  /// systems with hyphens, then collapses runs of hyphens.
  @visibleForTesting
  static String sanitizeFileName(String name) {
    // Strip generic type parameters first (e.g., `Foo<Bar>` -> `Foo`).
    final angleBracketIndex = name.indexOf('<');
    if (angleBracketIndex != -1) {
      name = name.substring(0, angleBracketIndex);
    }
    // Replace chars problematic on Windows/macOS/Linux: : < > | ? * " / \
    return name
        .replaceAll(_unsafeFileChars, '-')
        .replaceAll(_multiDash, '-')
        .replaceAll(_leadTrailDash, '');
  }

  /// Returns a kind-based suffix string for collision avoidance.
  String _kindSuffix(Documentable element) {
    if (element is Class) return 'class';
    if (element is Enum) return 'enum';
    if (element is Mixin) return 'mixin';
    if (element is Extension) return 'extension';
    if (element is ExtensionType) return 'extension-type';
    if (element is ModelFunction) return 'function';
    if (element is TopLevelVariable) return 'property';
    if (element is Typedef) return 'typedef';
    return 'element';
  }

  /// Returns true if the element is a member-level element that should be
  /// rendered as an anchor on its container's page rather than having its
  /// own page.
  ///
  /// Includes [Accessor] (getters/setters) which are resolved via bracket
  /// references like `[imports]` and should link to the corresponding field's
  /// anchor on the container page.
  bool _isMemberElement(Documentable element) {
    return element is Method ||
        element is Constructor ||
        element is Field ||
        element is Accessor;
  }

  /// Returns the enclosing container of a member element.
  Container? _containerOf(ModelElement element) {
    if (element is ContainerMember) {
      return element.enclosingElement;
    }
    return null;
  }

  /// Returns the URL for the container page of a member element.
  String? _containerUrl(ModelElement element) {
    final container = _containerOf(element);
    if (container == null) return null;
    return urlFor(container);
  }

  /// Strips generic type parameters from a name.
  ///
  /// `get<T>` -> `get`
  /// `Map<String, int>` -> `Map`
  /// `SimpleBinder` -> `SimpleBinder` (unchanged)
  @visibleForTesting
  static String stripGenerics(String name) {
    final angleBracketIndex = name.indexOf('<');
    if (angleBracketIndex == -1) return name;
    return name.substring(0, angleBracketIndex);
  }

  /// Sanitizes a string for use as an anchor ID.
  ///
  /// Replaces non-alphanumeric characters with hyphens and lowercases.
  @visibleForTesting
  static String sanitizeAnchor(String value) {
    return value
        .replaceAll(_nonAlphanumeric, '-')
        .replaceAll(_multiDash, '-')
        .replaceAll(_leadTrailDash, '')
        .toLowerCase();
  }
}
