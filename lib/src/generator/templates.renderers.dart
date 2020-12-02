// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, unnecessary_cast, unused_element, unused_import
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'templates.dart';

String renderIndex(PackageTemplateData context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_PackageTemplateData(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_PackageTemplateData extends RendererBase<PackageTemplateData> {
  static Map<String, Property> propertyMap() => {
        'hasHomepage': Property(
          getValue: (Object c) => (c as PackageTemplateData).hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as PackageTemplateData).hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (Object c) => (c as PackageTemplateData).homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlBase': Property(
          getValue: (Object c) => (c as PackageTemplateData).htmlBase,
          getProperties: _Renderer_String.propertyMap,
        ),
        'includeVersion': Property(
          getValue: (Object c) => (c as PackageTemplateData).includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) =>
              (c as PackageTemplateData).includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (Object c) => (c as PackageTemplateData).layoutTitle,
          getProperties: _Renderer_String.propertyMap,
        ),
        'metaDescription': Property(
          getValue: (Object c) => (c as PackageTemplateData).metaDescription,
          getProperties: _Renderer_String.propertyMap,
        ),
        'navLinks': Property(
          getValue: (Object c) => (c as PackageTemplateData).navLinks,
          isEmptyIterable: (Object c) =>
              (c as PackageTemplateData).navLinks?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<PackageTemplateData> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as PackageTemplateData).navLinks) {
              buffer.write(_render_Documentable(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'package': Property(
          getValue: (Object c) => (c as PackageTemplateData).package,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'self': Property(
          getValue: (Object c) => (c as PackageTemplateData).self,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'title': Property(
          getValue: (Object c) => (c as PackageTemplateData).title,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_TemplateData.propertyMap<Package>(),
      };

  _Renderer_PackageTemplateData(
      PackageTemplateData context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_Package(Package context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Package(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Package extends RendererBase<Package> {
  static Map<String, Property> propertyMap() => {
        'allLibraries': Property(
          getValue: (Object c) => (c as Package).allLibraries,
          isEmptyIterable: (Object c) =>
              (c as Package).allLibraries?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).allLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'baseHref': Property(
          getValue: (Object c) => (c as Package).baseHref,
          getProperties: _Renderer_String.propertyMap,
        ),
        'canonicalLibrary': Property(
          getValue: (Object c) => (c as Package).canonicalLibrary,
        ),
        'categories': Property(
          getValue: (Object c) => (c as Package).categories,
          isEmptyIterable: (Object c) =>
              (c as Package).categories?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).categories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'categoriesWithPublicLibraries': Property(
          getValue: (Object c) => (c as Package).categoriesWithPublicLibraries,
          isEmptyIterable: (Object c) =>
              (c as Package).categoriesWithPublicLibraries?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).categoriesWithPublicLibraries) {
              buffer.write(_render_LibraryContainer(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'config': Property(
          getValue: (Object c) => (c as Package).config,
        ),
        'containerOrder': Property(
          getValue: (Object c) => (c as Package).containerOrder,
          isEmptyIterable: (Object c) =>
              (c as Package).containerOrder?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'defaultCategory': Property(
          getValue: (Object c) => (c as Package).defaultCategory,
          getProperties: _Renderer_LibraryContainer.propertyMap,
        ),
        'documentation': Property(
          getValue: (Object c) => (c as Package).documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          getValue: (Object c) => (c as Package).documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationFile': Property(
          getValue: (Object c) => (c as Package).documentationFile,
        ),
        'documentationFrom': Property(
          getValue: (Object c) => (c as Package).documentationFrom,
          isEmptyIterable: (Object c) =>
              (c as Package).documentationFrom?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).documentationFrom) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategories': Property(
          getValue: (Object c) => (c as Package).documentedCategories,
          isEmptyIterable: (Object c) =>
              (c as Package).documentedCategories?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).documentedCategories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategoriesSorted': Property(
          getValue: (Object c) => (c as Package).documentedCategoriesSorted,
        ),
        'documentedWhere': Property(
          getValue: (Object c) => (c as Package).documentedWhere,
        ),
        'element': Property(
          getValue: (Object c) => (c as Package).element,
        ),
        'enclosingElement': Property(
          getValue: (Object c) => (c as Package).enclosingElement,
        ),
        'enclosingName': Property(
          getValue: (Object c) => (c as Package).enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'filePath': Property(
          getValue: (Object c) => (c as Package).filePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fileType': Property(
          getValue: (Object c) => (c as Package).fileType,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fullyQualifiedName': Property(
          getValue: (Object c) => (c as Package).fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasCategories': Property(
          getValue: (Object c) => (c as Package).hasCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).hasCategories == true,
        ),
        'hasDocumentation': Property(
          getValue: (Object c) => (c as Package).hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          getValue: (Object c) => (c as Package).hasDocumentationFile,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          getValue: (Object c) => (c as Package).hasDocumentedCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (Object c) => (c as Package).hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) =>
              (c as Package).hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          getValue: (Object c) => (c as Package).hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (Object c) => (c as Package).homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'href': Property(
          getValue: (Object c) => (c as Package).href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isCanonical': Property(
          getValue: (Object c) => (c as Package).isCanonical,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isCanonical == true,
        ),
        'isDocumented': Property(
          getValue: (Object c) => (c as Package).isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isDocumented == true,
        ),
        'isFirstPackage': Property(
          getValue: (Object c) => (c as Package).isFirstPackage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isFirstPackage == true,
        ),
        'isLocal': Property(
          getValue: (Object c) => (c as Package).isLocal,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isLocal == true,
        ),
        'isPublic': Property(
          getValue: (Object c) => (c as Package).isPublic,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isPublic == true,
        ),
        'isSdk': Property(
          getValue: (Object c) => (c as Package).isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Package).isSdk == true,
        ),
        'kind': Property(
          getValue: (Object c) => (c as Package).kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'location': Property(
          getValue: (Object c) => (c as Package).location,
          getProperties: _Renderer_String.propertyMap,
        ),
        'locationPieces': Property(
          getValue: (Object c) => (c as Package).locationPieces,
          isEmptyIterable: (Object c) =>
              (c as Package).locationPieces?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).locationPieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'name': Property(
          getValue: (Object c) => (c as Package).name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'nameToCategory': Property(
          getValue: (Object c) => (c as Package).nameToCategory,
        ),
        'oneLineDoc': Property(
          getValue: (Object c) => (c as Package).oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'package': Property(
          getValue: (Object c) => (c as Package).package,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'packageGraph': Property(
          getValue: (Object c) => (c as Package).packageGraph,
        ),
        'packageMeta': Property(
          getValue: (Object c) => (c as Package).packageMeta,
        ),
        'packagePath': Property(
          getValue: (Object c) => (c as Package).packagePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'publicLibraries': Property(
          getValue: (Object c) => (c as Package).publicLibraries,
          isEmptyIterable: (Object c) =>
              (c as Package).publicLibraries?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Package> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Package).publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'toolInvocationIndex': Property(
          getValue: (Object c) => (c as Package).toolInvocationIndex,
          getProperties: _Renderer_int.propertyMap,
        ),
        'usedAnimationIdsByHref': Property(
          getValue: (Object c) => (c as Package).usedAnimationIdsByHref,
        ),
        'version': Property(
          getValue: (Object c) => (c as Package).version,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_LibraryContainer.propertyMap(),
      };

  _Renderer_Package(Package context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_LibraryContainer(
    LibraryContainer context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_LibraryContainer(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_LibraryContainer extends RendererBase<LibraryContainer> {
  static Map<String, Property> propertyMap() => {
        'containerOrder': Property(
          getValue: (Object c) => (c as LibraryContainer).containerOrder,
          isEmptyIterable: (Object c) =>
              (c as LibraryContainer).containerOrder?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<LibraryContainer> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as LibraryContainer).containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'enclosingName': Property(
          getValue: (Object c) => (c as LibraryContainer).enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasPublicLibraries': Property(
          getValue: (Object c) => (c as LibraryContainer).hasPublicLibraries,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) =>
              (c as LibraryContainer).hasPublicLibraries == true,
        ),
        'isSdk': Property(
          getValue: (Object c) => (c as LibraryContainer).isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as LibraryContainer).isSdk == true,
        ),
        'libraries': Property(
          getValue: (Object c) => (c as LibraryContainer).libraries,
          isEmptyIterable: (Object c) =>
              (c as LibraryContainer).libraries?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<LibraryContainer> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as LibraryContainer).libraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'packageGraph': Property(
          getValue: (Object c) => (c as LibraryContainer).packageGraph,
        ),
        'publicLibraries': Property(
          getValue: (Object c) => (c as LibraryContainer).publicLibraries,
          isEmptyIterable: (Object c) =>
              (c as LibraryContainer).publicLibraries?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<LibraryContainer> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as LibraryContainer).publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'publicLibrariesSorted': Property(
          getValue: (Object c) => (c as LibraryContainer).publicLibrariesSorted,
        ),
        'sortKey': Property(
          getValue: (Object c) => (c as LibraryContainer).sortKey,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_LibraryContainer(
      LibraryContainer context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_Object(Object context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Object(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Object extends RendererBase<Object> {
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as Object).hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
      };

  _Renderer_Object(Object context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_bool(bool context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_bool(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_bool extends RendererBase<bool> {
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as bool).hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_bool(bool context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_List<E>(List<E> context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_List(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_List<E> extends RendererBase<List<E>> {
  static Map<String, Property> propertyMap<E>() => {
        'length': Property(
          getValue: (Object c) => (c as List<E>).length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'reversed': Property(
          getValue: (Object c) => (c as List<E>).reversed,
          isEmptyIterable: (Object c) =>
              (c as List<E>).reversed?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<List<E>> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as List<E>).reversed) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_List(List<E> context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<E>().containsKey(key)) {
      return propertyMap<E>()[key];
    } else {
      return null;
    }
  }
}

String _render_String(String context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_String(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_String extends RendererBase<String> {
  static Map<String, Property> propertyMap() => {
        'codeUnits': Property(
          getValue: (Object c) => (c as String).codeUnits,
          isEmptyIterable: (Object c) =>
              (c as String).codeUnits?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<String> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as String).codeUnits) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'hashCode': Property(
          getValue: (Object c) => (c as String).hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEmpty': Property(
          getValue: (Object c) => (c as String).isEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as String).isEmpty == true,
        ),
        'isNotEmpty': Property(
          getValue: (Object c) => (c as String).isNotEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as String).isNotEmpty == true,
        ),
        'length': Property(
          getValue: (Object c) => (c as String).length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'runes': Property(
          getValue: (Object c) => (c as String).runes,
          isEmptyIterable: (Object c) => (c as String).runes?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<String> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as String).runes) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_String(String context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_TemplateData<T extends Documentable>(
    TemplateData<T> context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateData(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateData<T extends Documentable>
    extends RendererBase<TemplateData<T>> {
  static Map<String, Property> propertyMap<T extends Documentable>() => {
        'bareHref': Property(
          getValue: (Object c) => (c as TemplateData<T>).bareHref,
          getProperties: _Renderer_String.propertyMap,
        ),
        'defaultPackage': Property(
          getValue: (Object c) => (c as TemplateData<T>).defaultPackage,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'hasFooterVersion': Property(
          getValue: (Object c) => (c as TemplateData<T>).hasFooterVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) =>
              (c as TemplateData<T>).hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          getValue: (Object c) => (c as TemplateData<T>).hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as TemplateData<T>).hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (Object c) => (c as TemplateData<T>).homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlBase': Property(
          getValue: (Object c) => (c as TemplateData<T>).htmlBase,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlOptions': Property(
          getValue: (Object c) => (c as TemplateData<T>).htmlOptions,
          getProperties: _Renderer_TemplateOptions.propertyMap,
        ),
        'includeVersion': Property(
          getValue: (Object c) => (c as TemplateData<T>).includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as TemplateData<T>).includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (Object c) => (c as TemplateData<T>).layoutTitle,
          getProperties: _Renderer_String.propertyMap,
        ),
        'localPackages': Property(
          getValue: (Object c) => (c as TemplateData<T>).localPackages,
          isEmptyIterable: (Object c) =>
              (c as TemplateData<T>).localPackages?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<TemplateData<T>> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as TemplateData<T>).localPackages) {
              buffer.write(_render_Package(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'metaDescription': Property(
          getValue: (Object c) => (c as TemplateData<T>).metaDescription,
          getProperties: _Renderer_String.propertyMap,
        ),
        'navLinks': Property(
          getValue: (Object c) => (c as TemplateData<T>).navLinks,
          isEmptyIterable: (Object c) =>
              (c as TemplateData<T>).navLinks?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<TemplateData<T>> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as TemplateData<T>).navLinks) {
              buffer.write(_render_Documentable(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'navLinksWithGenerics': Property(
          getValue: (Object c) => (c as TemplateData<T>).navLinksWithGenerics,
          isEmptyIterable: (Object c) =>
              (c as TemplateData<T>).navLinksWithGenerics?.isEmpty ?? false,
          renderIterable: (Object c, RendererBase<TemplateData<T>> r,
              List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as TemplateData<T>).navLinksWithGenerics) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'parent': Property(
          getValue: (Object c) => (c as TemplateData<T>).parent,
          getProperties: _Renderer_Documentable.propertyMap,
        ),
        'relCanonicalPrefix': Property(
          getValue: (Object c) => (c as TemplateData<T>).relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
        ),
        'self': Property(
          getValue: (Object c) => (c as TemplateData<T>).self,
        ),
        'title': Property(
          getValue: (Object c) => (c as TemplateData<T>).title,
          getProperties: _Renderer_String.propertyMap,
        ),
        'useBaseHref': Property(
          getValue: (Object c) => (c as TemplateData<T>).useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as TemplateData<T>).useBaseHref == true,
        ),
        'version': Property(
          getValue: (Object c) => (c as TemplateData<T>).version,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_TemplateData(TemplateData<T> context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<T>().containsKey(key)) {
      return propertyMap<T>()[key];
    } else {
      return null;
    }
  }
}

String _render_TemplateOptions(TemplateOptions context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateOptions(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateOptions extends RendererBase<TemplateOptions> {
  static Map<String, Property> propertyMap() => {
        'relCanonicalPrefix': Property(
          getValue: (Object c) => (c as TemplateOptions).relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
        ),
        'toolVersion': Property(
          getValue: (Object c) => (c as TemplateOptions).toolVersion,
          getProperties: _Renderer_String.propertyMap,
        ),
        'useBaseHref': Property(
          getValue: (Object c) => (c as TemplateOptions).useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as TemplateOptions).useBaseHref == true,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_TemplateOptions(
      TemplateOptions context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_Documentable(Documentable context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Documentable(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Documentable extends RendererBase<Documentable> {
  static Map<String, Property> propertyMap() => {
        'config': Property(
          getValue: (Object c) => (c as Documentable).config,
        ),
        'documentation': Property(
          getValue: (Object c) => (c as Documentable).documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          getValue: (Object c) => (c as Documentable).documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasDocumentation': Property(
          getValue: (Object c) => (c as Documentable).hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Documentable).hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (Object c) => (c as Documentable).hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) =>
              (c as Documentable).hasExtendedDocumentation == true,
        ),
        'href': Property(
          getValue: (Object c) => (c as Documentable).href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isDocumented': Property(
          getValue: (Object c) => (c as Documentable).isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as Documentable).isDocumented == true,
        ),
        'kind': Property(
          getValue: (Object c) => (c as Documentable).kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'oneLineDoc': Property(
          getValue: (Object c) => (c as Documentable).oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'packageGraph': Property(
          getValue: (Object c) => (c as Documentable).packageGraph,
        ),
        ..._Renderer_Nameable.propertyMap(),
      };

  _Renderer_Documentable(Documentable context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_Nameable(Nameable context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Nameable(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Nameable extends RendererBase<Nameable> {
  static Map<String, Property> propertyMap() => {
        'fullyQualifiedName': Property(
          getValue: (Object c) => (c as Nameable).fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'name': Property(
          getValue: (Object c) => (c as Nameable).name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePart': Property(
          getValue: (Object c) => (c as Nameable).namePart,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePieces': Property(
          getValue: (Object c) => (c as Nameable).namePieces,
          isEmptyIterable: (Object c) =>
              (c as Nameable).namePieces?.isEmpty ?? false,
          renderIterable:
              (Object c, RendererBase<Nameable> r, List<WhiskersNode> ast) {
            var buffer = StringBuffer();
            for (var e in (c as Nameable).namePieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_Nameable(Nameable context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_int(int context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_int(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_int extends RendererBase<int> {
  static Map<String, Property> propertyMap() => {
        'bitLength': Property(
          getValue: (Object c) => (c as int).bitLength,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEven': Property(
          getValue: (Object c) => (c as int).isEven,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as int).isEven == true,
        ),
        'isOdd': Property(
          getValue: (Object c) => (c as int).isOdd,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as int).isOdd == true,
        ),
        'sign': Property(
          getValue: (Object c) => (c as int).sign,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_num.propertyMap(),
      };

  _Renderer_int(int context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}

String _render_num(num context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_num(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_num extends RendererBase<num> {
  static Map<String, Property> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => (c as num).hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isFinite': Property(
          getValue: (Object c) => (c as num).isFinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isFinite == true,
        ),
        'isInfinite': Property(
          getValue: (Object c) => (c as num).isInfinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isInfinite == true,
        ),
        'isNaN': Property(
          getValue: (Object c) => (c as num).isNaN,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isNaN == true,
        ),
        'isNegative': Property(
          getValue: (Object c) => (c as num).isNegative,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Object c) => (c as num).isNegative == true,
        ),
        'sign': Property(
          getValue: (Object c) => (c as num).sign,
          getProperties: _Renderer_num.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_num(num context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap().containsKey(key)) {
      return propertyMap()[key];
    } else {
      return null;
    }
  }
}
