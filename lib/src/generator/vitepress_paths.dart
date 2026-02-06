// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/comment_references/parser.dart' show operatorNames;
import 'package:dartdoc/src/model/model.dart';

/// Computes VitePress-compatible file paths and URLs for documentation elements.
///
/// This class NEVER reads `element.fileName`, `element.filePath`, or
/// `element.href` as those produce HTML-specific paths. All paths are computed
/// from raw `name` and `library.dirName`.
class VitePressPathResolver {
  /// Returns the file path (relative to output root) for a documentation page.
  ///
  /// Returns `null` for member-level elements that do not have their own page
  /// (constructors, methods, fields, operators) -- these are rendered as
  /// anchors on their container's page.
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
      return 'topics/${element.name}.md';
    }

    if (element is Library) {
      return 'api/${element.dirName}/index.md';
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
      return '/topics/${element.name}';
    }

    if (element is Library) {
      return '/api/${element.dirName}/';
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
  /// - Constructor `SimpleBinder.named`: `#simplebinder.named`
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
      return '#operator-${_sanitizeAnchor(operatorSymbol)}';
    }

    // For constructors, use the constructor's reference name which is either
    // the class name (for unnamed constructors) or the named part.
    if (element is Constructor) {
      final name = element.referenceName;
      return '#${_stripGenerics(name).toLowerCase()}';
    }

    // For methods and fields, strip generics and lowercase.
    final name = _stripGenerics(element.name);
    return '#${name.toLowerCase()}';
  }

  /// Returns the full link URL for any element (container or member).
  ///
  /// For containers: `/api/modularity_core/SimpleBinder`
  /// For members: `/api/modularity_core/SimpleBinder#get`
  /// For packages: `/api/`
  /// For libraries: `/api/modularity_core/`
  /// For categories: `/topics/MyTopic`
  String? linkFor(Documentable element) {
    if (_isMemberElement(element) && element is ModelElement) {
      final containerUrl = _containerUrl(element);
      if (containerUrl == null) return null;
      final anchor = anchorFor(element);
      if (anchor == null) return containerUrl;
      return '$containerUrl$anchor';
    }
    return urlFor(element);
  }

  /// Returns the library directory name for an element.
  ///
  /// Uses `canonicalLibrary` with null-safety for re-exported elements.
  /// Falls back to `library` if `canonicalLibrary` is null.
  String? _libraryDirName(Documentable element) {
    if (element is Library) {
      return element.dirName;
    }
    if (element is ModelElement) {
      // Prefer canonicalLibrary for re-exported elements.
      final lib = element.canonicalLibrary ?? element.library;
      return lib!.dirName;
    }
    return null;
  }

  /// Determines if a file name needs a type suffix to avoid collision with
  /// `index.md` (which is used for library overview pages).
  ///
  /// Elements named "index" (case-sensitive) would collide with the library's
  /// `index.md`, so they get a kind-based suffix appended.
  ///
  /// Examples:
  /// - Class named "index" -> `index-class`
  /// - Function named "index" -> `index-function`
  /// - Class named "MyClass" -> `MyClass` (no suffix needed)
  String _safeFileName(String name, Documentable element) {
    if (name.toLowerCase() != 'index') {
      return name;
    }
    // Collision avoidance: append element kind suffix.
    return '$name-${_kindSuffix(element)}';
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
  bool _isMemberElement(Documentable element) {
    return element is Method ||
        element is Constructor ||
        element is Field ||
        element is Operator;
  }

  /// Returns the enclosing container of a member element.
  Container? _containerOf(ModelElement element) {
    if (element is ContainerMember) {
      return element.enclosingElement;
    }
    if (element is Constructor) {
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
  String _stripGenerics(String name) {
    final angleBracketIndex = name.indexOf('<');
    if (angleBracketIndex == -1) return name;
    return name.substring(0, angleBracketIndex);
  }

  /// Sanitizes a string for use as an anchor ID.
  ///
  /// Replaces non-alphanumeric characters with hyphens and lowercases.
  String _sanitizeAnchor(String value) {
    return value
        .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '')
        .toLowerCase();
  }
}
