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
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends PackageTemplateData>() =>
      {
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.htmlBase, ast, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.layoutTitle, ast, parent: r);
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.metaDescription, ast, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.navLinks?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinks) {
              buffer.write(_render_Documentable(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          getProperties: _Renderer_Package.propertyMap,
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, parent: r);
          },
        ),
        'self': Property(
          getValue: (CT_ c) => c.self,
          getProperties: _Renderer_Package.propertyMap,
          isNullValue: (CT_ c) => c.self == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.self, ast, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.title, ast, parent: r);
          },
        ),
        ..._Renderer_TemplateData.propertyMap<Package, CT_>(),
      };

  _Renderer_PackageTemplateData(
      PackageTemplateData context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<PackageTemplateData> getProperty(String key) {
    if (propertyMap<PackageTemplateData>().containsKey(key)) {
      return propertyMap<PackageTemplateData>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends Package>() => {
        'allLibraries': Property(
          getValue: (CT_ c) => c.allLibraries,
          isEmptyIterable: (CT_ c) => c.allLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.allLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'baseHref': Property(
          getValue: (CT_ c) => c.baseHref,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.baseHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.baseHref, ast, parent: r);
          },
        ),
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
          isNullValue: (CT_ c) => c.canonicalLibrary == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.canonicalLibrary, ast, parent: r);
          },
        ),
        'categories': Property(
          getValue: (CT_ c) => c.categories,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.categories?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'categoriesWithPublicLibraries': Property(
          getValue: (CT_ c) => c.categoriesWithPublicLibraries,
          isEmptyIterable: (CT_ c) =>
              c.categoriesWithPublicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categoriesWithPublicLibraries) {
              buffer.write(_render_LibraryContainer(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'config': Property(
          getValue: (CT_ c) => c.config,
          isNullValue: (CT_ c) => c.config == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.config, ast, parent: r);
          },
        ),
        'containerOrder': Property(
          getValue: (CT_ c) => c.containerOrder,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.containerOrder?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'defaultCategory': Property(
          getValue: (CT_ c) => c.defaultCategory,
          getProperties: _Renderer_LibraryContainer.propertyMap,
          isNullValue: (CT_ c) => c.defaultCategory == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_LibraryContainer(c.defaultCategory, ast, parent: r);
          },
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentation, ast, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationAsHtml, ast, parent: r);
          },
        ),
        'documentationFile': Property(
          getValue: (CT_ c) => c.documentationFile,
          isNullValue: (CT_ c) => c.documentationFile == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.documentationFile, ast, parent: r);
          },
        ),
        'documentationFrom': Property(
          getValue: (CT_ c) => c.documentationFrom,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.documentationFrom?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentationFrom) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategories': Property(
          getValue: (CT_ c) => c.documentedCategories,
          isEmptyIterable: (CT_ c) => c.documentedCategories?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentedCategories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategoriesSorted': Property(
          getValue: (CT_ c) => c.documentedCategoriesSorted,
          isEmptyIterable: (CT_ c) =>
              c.documentedCategoriesSorted?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentedCategoriesSorted) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedWhere': Property(
          getValue: (CT_ c) => c.documentedWhere,
          isNullValue: (CT_ c) => c.documentedWhere == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.documentedWhere, ast, parent: r);
          },
        ),
        'element': Property(
          getValue: (CT_ c) => c.element,
          isNullValue: (CT_ c) => c.element == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.element, ast, parent: r);
          },
        ),
        'enclosingElement': Property(
          getValue: (CT_ c) => c.enclosingElement,
          isNullValue: (CT_ c) => c.enclosingElement == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.enclosingElement, ast, parent: r);
          },
        ),
        'enclosingName': Property(
          getValue: (CT_ c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.enclosingName, ast, parent: r);
          },
        ),
        'filePath': Property(
          getValue: (CT_ c) => c.filePath,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.filePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.filePath, ast, parent: r);
          },
        ),
        'fileType': Property(
          getValue: (CT_ c) => c.fileType,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.fileType == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fileType, ast, parent: r);
          },
        ),
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedName, ast, parent: r);
          },
        ),
        'hasCategories': Property(
          getValue: (CT_ c) => c.hasCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasCategories == true,
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          getValue: (CT_ c) => c.hasDocumentationFile,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          getValue: (CT_ c) => c.hasDocumentedCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.href, ast, parent: r);
          },
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isCanonical == true,
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'isFirstPackage': Property(
          getValue: (CT_ c) => c.isFirstPackage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isFirstPackage == true,
        ),
        'isLocal': Property(
          getValue: (CT_ c) => c.isLocal,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isLocal == true,
        ),
        'isPublic': Property(
          getValue: (CT_ c) => c.isPublic,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isPublic == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.kind, ast, parent: r);
          },
        ),
        'location': Property(
          getValue: (CT_ c) => c.location,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.location == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.location, ast, parent: r);
          },
        ),
        'locationPieces': Property(
          getValue: (CT_ c) => c.locationPieces,
          isEmptyIterable: (CT_ c) => c.locationPieces?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.locationPieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.name, ast, parent: r);
          },
        ),
        'nameToCategory': Property(
          getValue: (CT_ c) => c.nameToCategory,
          isNullValue: (CT_ c) => c.nameToCategory == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.nameToCategory, ast, parent: r);
          },
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.oneLineDoc, ast, parent: r);
          },
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          getProperties: _Renderer_Package.propertyMap,
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
          isNullValue: (CT_ c) => c.packageGraph == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.packageGraph, ast, parent: r);
          },
        ),
        'packageMeta': Property(
          getValue: (CT_ c) => c.packageMeta,
          isNullValue: (CT_ c) => c.packageMeta == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.packageMeta, ast, parent: r);
          },
        ),
        'packagePath': Property(
          getValue: (CT_ c) => c.packagePath,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.packagePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.packagePath, ast, parent: r);
          },
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
          isEmptyIterable: (CT_ c) => c.publicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'toolInvocationIndex': Property(
          getValue: (CT_ c) => c.toolInvocationIndex,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.toolInvocationIndex == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.toolInvocationIndex, ast, parent: r);
          },
        ),
        'usedAnimationIdsByHref': Property(
          getValue: (CT_ c) => c.usedAnimationIdsByHref,
          isNullValue: (CT_ c) => c.usedAnimationIdsByHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.usedAnimationIdsByHref, ast, parent: r);
          },
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.version == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.version, ast, parent: r);
          },
        ),
        ..._Renderer_LibraryContainer.propertyMap<CT_>(),
      };

  _Renderer_Package(Package context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Package> getProperty(String key) {
    if (propertyMap<Package>().containsKey(key)) {
      return propertyMap<Package>()[key];
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
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends LibraryContainer>() =>
      {
        'containerOrder': Property(
          getValue: (CT_ c) => c.containerOrder,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.containerOrder?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'enclosingName': Property(
          getValue: (CT_ c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.enclosingName, ast, parent: r);
          },
        ),
        'hasPublicLibraries': Property(
          getValue: (CT_ c) => c.hasPublicLibraries,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasPublicLibraries == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'libraries': Property(
          getValue: (CT_ c) => c.libraries,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.libraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.libraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
          isNullValue: (CT_ c) => c.packageGraph == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.packageGraph, ast, parent: r);
          },
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
          isEmptyIterable: (CT_ c) => c.publicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'publicLibrariesSorted': Property(
          getValue: (CT_ c) => c.publicLibrariesSorted,
          isEmptyIterable: (CT_ c) => c.publicLibrariesSorted?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibrariesSorted) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'sortKey': Property(
          getValue: (CT_ c) => c.sortKey,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.sortKey == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.sortKey, ast, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_LibraryContainer(
      LibraryContainer context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<LibraryContainer> getProperty(String key) {
    if (propertyMap<LibraryContainer>().containsKey(key)) {
      return propertyMap<LibraryContainer>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends Object>() => {
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
      };

  _Renderer_Object(Object context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<Object>().containsKey(key)) {
      return propertyMap<Object>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends bool>() => {
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_bool(bool context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<bool> getProperty(String key) {
    if (propertyMap<bool>().containsKey(key)) {
      return propertyMap<bool>()[key];
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
  static Map<String, Property<CT_>> propertyMap<E, CT_ extends List<E>>() => {
        'length': Property(
          getValue: (CT_ c) => c.length,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.length == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.length, ast, parent: r);
          },
        ),
        'reversed': Property(
          getValue: (CT_ c) => c.reversed,
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_List(List<E> context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<List<E>> getProperty(String key) {
    if (propertyMap<E, List<E>>().containsKey(key)) {
      return propertyMap<E, List<E>>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends String>() => {
        'codeUnits': Property(
          getValue: (CT_ c) => c.codeUnits,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.codeUnits?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.codeUnits) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
        'isEmpty': Property(
          getValue: (CT_ c) => c.isEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isEmpty == true,
        ),
        'isNotEmpty': Property(
          getValue: (CT_ c) => c.isNotEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isNotEmpty == true,
        ),
        'length': Property(
          getValue: (CT_ c) => c.length,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.length == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.length, ast, parent: r);
          },
        ),
        'runes': Property(
          getValue: (CT_ c) => c.runes,
          isEmptyIterable: (CT_ c) => c.runes?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.runes) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_String(String context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<String> getProperty(String key) {
    if (propertyMap<String>().containsKey(key)) {
      return propertyMap<String>()[key];
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
  static Map<String, Property<CT_>> propertyMap<T extends Documentable,
          CT_ extends TemplateData<T>>() =>
      {
        'bareHref': Property(
          getValue: (CT_ c) => c.bareHref,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.bareHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.bareHref, ast, parent: r);
          },
        ),
        'defaultPackage': Property(
          getValue: (CT_ c) => c.defaultPackage,
          getProperties: _Renderer_Package.propertyMap,
          isNullValue: (CT_ c) => c.defaultPackage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.defaultPackage, ast, parent: r);
          },
        ),
        'hasFooterVersion': Property(
          getValue: (CT_ c) => c.hasFooterVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.htmlBase, ast, parent: r);
          },
        ),
        'htmlOptions': Property(
          getValue: (CT_ c) => c.htmlOptions,
          getProperties: _Renderer_TemplateOptions.propertyMap,
          isNullValue: (CT_ c) => c.htmlOptions == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_TemplateOptions(c.htmlOptions, ast, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.layoutTitle, ast, parent: r);
          },
        ),
        'localPackages': Property(
          getValue: (CT_ c) => c.localPackages,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.localPackages?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.localPackages) {
              buffer.write(_render_Package(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.metaDescription, ast, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.navLinks?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinks) {
              buffer.write(_render_Documentable(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'navLinksWithGenerics': Property(
          getValue: (CT_ c) => c.navLinksWithGenerics,
          getProperties: _Renderer_List.propertyMap,
          isEmptyIterable: (CT_ c) => c.navLinksWithGenerics?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinksWithGenerics) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'parent': Property(
          getValue: (CT_ c) => c.parent,
          getProperties: _Renderer_Documentable.propertyMap,
          isNullValue: (CT_ c) => c.parent == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Documentable(c.parent, ast, parent: r);
          },
        ),
        'relCanonicalPrefix': Property(
          getValue: (CT_ c) => c.relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.relCanonicalPrefix, ast, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.title, ast, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.useBaseHref == true,
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.version == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.version, ast, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_TemplateData(TemplateData<T> context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<TemplateData<T>> getProperty(String key) {
    if (propertyMap<T, TemplateData<T>>().containsKey(key)) {
      return propertyMap<T, TemplateData<T>>()[key];
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
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends TemplateOptions>() =>
      {
        'relCanonicalPrefix': Property(
          getValue: (CT_ c) => c.relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.relCanonicalPrefix, ast, parent: r);
          },
        ),
        'toolVersion': Property(
          getValue: (CT_ c) => c.toolVersion,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.toolVersion == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.toolVersion, ast, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.useBaseHref == true,
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_TemplateOptions(
      TemplateOptions context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<TemplateOptions> getProperty(String key) {
    if (propertyMap<TemplateOptions>().containsKey(key)) {
      return propertyMap<TemplateOptions>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends Documentable>() => {
        'config': Property(
          getValue: (CT_ c) => c.config,
          isNullValue: (CT_ c) => c.config == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.config, ast, parent: r);
          },
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentation, ast, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationAsHtml, ast, parent: r);
          },
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.href, ast, parent: r);
          },
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.kind, ast, parent: r);
          },
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.oneLineDoc, ast, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
          isNullValue: (CT_ c) => c.packageGraph == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return null(c.packageGraph, ast, parent: r);
          },
        ),
        ..._Renderer_Nameable.propertyMap<CT_>(),
      };

  _Renderer_Documentable(Documentable context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Documentable> getProperty(String key) {
    if (propertyMap<Documentable>().containsKey(key)) {
      return propertyMap<Documentable>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends Nameable>() => {
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedName, ast, parent: r);
          },
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.name, ast, parent: r);
          },
        ),
        'namePart': Property(
          getValue: (CT_ c) => c.namePart,
          getProperties: _Renderer_String.propertyMap,
          isNullValue: (CT_ c) => c.namePart == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.namePart, ast, parent: r);
          },
        ),
        'namePieces': Property(
          getValue: (CT_ c) => c.namePieces,
          isEmptyIterable: (CT_ c) => c.namePieces?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.namePieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_Nameable(Nameable context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Nameable> getProperty(String key) {
    if (propertyMap<Nameable>().containsKey(key)) {
      return propertyMap<Nameable>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends int>() => {
        'bitLength': Property(
          getValue: (CT_ c) => c.bitLength,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.bitLength == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.bitLength, ast, parent: r);
          },
        ),
        'isEven': Property(
          getValue: (CT_ c) => c.isEven,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isEven == true,
        ),
        'isOdd': Property(
          getValue: (CT_ c) => c.isOdd,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isOdd == true,
        ),
        'sign': Property(
          getValue: (CT_ c) => c.sign,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.sign == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.sign, ast, parent: r);
          },
        ),
        ..._Renderer_num.propertyMap<CT_>(),
      };

  _Renderer_int(int context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<int> getProperty(String key) {
    if (propertyMap<int>().containsKey(key)) {
      return propertyMap<int>()[key];
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
  static Map<String, Property<CT_>> propertyMap<CT_ extends num>() => {
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
        'isFinite': Property(
          getValue: (CT_ c) => c.isFinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isFinite == true,
        ),
        'isInfinite': Property(
          getValue: (CT_ c) => c.isInfinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isInfinite == true,
        ),
        'isNaN': Property(
          getValue: (CT_ c) => c.isNaN,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isNaN == true,
        ),
        'isNegative': Property(
          getValue: (CT_ c) => c.isNegative,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (CT_ c) => c.isNegative == true,
        ),
        'sign': Property(
          getValue: (CT_ c) => c.sign,
          getProperties: _Renderer_num.propertyMap,
          isNullValue: (CT_ c) => c.sign == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_num(c.sign, ast, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_num(num context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<num> getProperty(String key) {
    if (propertyMap<num>().containsKey(key)) {
      return propertyMap<num>()[key];
    } else {
      return null;
    }
  }
}
