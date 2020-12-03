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
  static Map<String, Property<X_>>
      propertyMap<X_ extends PackageTemplateData>() => {
            'hasHomepage': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.hasHomepage,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (X_ c) => c.hasHomepage == true,
            ),
            'homepage': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.homepage,
              getProperties: _Renderer_String.propertyMap,
            ),
            'htmlBase': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.htmlBase,
              getProperties: _Renderer_String.propertyMap,
            ),
            'includeVersion': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.includeVersion,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (X_ c) => c.includeVersion == true,
            ),
            'layoutTitle': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.layoutTitle,
              getProperties: _Renderer_String.propertyMap,
            ),
            'metaDescription': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.metaDescription,
              getProperties: _Renderer_String.propertyMap,
            ),
            'navLinks': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.navLinks,
              isEmptyIterable: (X_ c) => c.navLinks?.isEmpty ?? false,

              renderIterable:
                  (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
                var buffer = StringBuffer();
                for (var e in c.navLinks) {
                  buffer.write(_render_Documentable(e, ast, parent: r));
                }
                return buffer.toString();
              },
            ),
            'package': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.package,
              getProperties: _Renderer_Package.propertyMap,
            ),
            'self': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.self,
              getProperties: _Renderer_Package.propertyMap,
            ),
            'title': Property(
              // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
              getValue: (X_ c) => c.title,
              getProperties: _Renderer_String.propertyMap,
            ),
            ..._Renderer_TemplateData.propertyMap<Package, X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends Package>() => {
        'allLibraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.allLibraries,
          isEmptyIterable: (X_ c) => c.allLibraries?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.allLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'baseHref': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.baseHref,
          getProperties: _Renderer_String.propertyMap,
        ),
        'canonicalLibrary': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.canonicalLibrary,
        ),
        'categories': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.categories,
          isEmptyIterable: (X_ c) => c.categories?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'categoriesWithPublicLibraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.categoriesWithPublicLibraries,
          isEmptyIterable: (X_ c) =>
              c.categoriesWithPublicLibraries?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categoriesWithPublicLibraries) {
              buffer.write(_render_LibraryContainer(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'config': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.config,
        ),
        'containerOrder': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.containerOrder,
          isEmptyIterable: (X_ c) => c.containerOrder?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'defaultCategory': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.defaultCategory,
          getProperties: _Renderer_LibraryContainer.propertyMap,
        ),
        'documentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationFile': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentationFile,
        ),
        'documentationFrom': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentationFrom,
          isEmptyIterable: (X_ c) => c.documentationFrom?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentationFrom) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategories': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentedCategories,
          isEmptyIterable: (X_ c) => c.documentedCategories?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentedCategories) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategoriesSorted': Property(
          getValue: (Object c) => (c as Package).documentedCategoriesSorted,
        ),
        'documentedWhere': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentedWhere,
        ),
        'element': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.element,
        ),
        'enclosingElement': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.enclosingElement,
        ),
        'enclosingName': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'filePath': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.filePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fileType': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.fileType,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fullyQualifiedName': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasCategories': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasCategories == true,
        ),
        'hasDocumentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasDocumentationFile,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasDocumentedCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'href': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isCanonical': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isCanonical,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isCanonical == true,
        ),
        'isDocumented': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isDocumented == true,
        ),
        'isFirstPackage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isFirstPackage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isFirstPackage == true,
        ),
        'isLocal': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isLocal,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isLocal == true,
        ),
        'isPublic': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isPublic,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isPublic == true,
        ),
        'isSdk': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isSdk == true,
        ),
        'kind': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'location': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.location,
          getProperties: _Renderer_String.propertyMap,
        ),
        'locationPieces': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.locationPieces,
          isEmptyIterable: (X_ c) => c.locationPieces?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.locationPieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'name': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'nameToCategory': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.nameToCategory,
        ),
        'oneLineDoc': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'package': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.package,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'packageGraph': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.packageGraph,
        ),
        'packageMeta': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.packageMeta,
        ),
        'packagePath': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.packagePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'publicLibraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.publicLibraries,
          isEmptyIterable: (X_ c) => c.publicLibraries?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'toolInvocationIndex': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.toolInvocationIndex,
          getProperties: _Renderer_int.propertyMap,
        ),
        'usedAnimationIdsByHref': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.usedAnimationIdsByHref,
        ),
        'version': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.version,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_LibraryContainer.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends LibraryContainer>() =>
      {
        'containerOrder': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.containerOrder,
          isEmptyIterable: (X_ c) => c.containerOrder?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'enclosingName': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasPublicLibraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasPublicLibraries,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasPublicLibraries == true,
        ),
        'isSdk': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isSdk == true,
        ),
        'libraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.libraries,
          isEmptyIterable: (X_ c) => c.libraries?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.libraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'packageGraph': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.packageGraph,
        ),
        'publicLibraries': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.publicLibraries,
          isEmptyIterable: (X_ c) => c.publicLibraries?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'publicLibrariesSorted': Property(
          getValue: (Object c) => (c as LibraryContainer).publicLibrariesSorted,
        ),
        'sortKey': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.sortKey,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends Object>() => {
        'hashCode': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
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
  static Map<String, Property<X_>> propertyMap<X_ extends bool>() => {
        'hashCode': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<E, X_ extends List<E>>() => {
        'length': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'reversed': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.reversed,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends String>() => {
        'codeUnits': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.codeUnits,
          isEmptyIterable: (X_ c) => c.codeUnits?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.codeUnits) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'hashCode': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEmpty': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isEmpty == true,
        ),
        'isNotEmpty': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isNotEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNotEmpty == true,
        ),
        'length': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'runes': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.runes,
          isEmptyIterable: (X_ c) => c.runes?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.runes) {
              buffer.write(_render_int(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<T extends Documentable,
          X_ extends TemplateData<T>>() =>
      {
        'bareHref': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.bareHref,
          getProperties: _Renderer_String.propertyMap,
        ),
        'defaultPackage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.defaultPackage,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'hasFooterVersion': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasFooterVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlBase': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.htmlBase,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlOptions': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.htmlOptions,
          getProperties: _Renderer_TemplateOptions.propertyMap,
        ),
        'includeVersion': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.layoutTitle,
          getProperties: _Renderer_String.propertyMap,
        ),
        'localPackages': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.localPackages,
          isEmptyIterable: (X_ c) => c.localPackages?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.localPackages) {
              buffer.write(_render_Package(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'metaDescription': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.metaDescription,
          getProperties: _Renderer_String.propertyMap,
        ),
        'navLinks': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.navLinks,
          isEmptyIterable: (X_ c) => c.navLinks?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinks) {
              buffer.write(_render_Documentable(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'navLinksWithGenerics': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.navLinksWithGenerics,
          isEmptyIterable: (X_ c) => c.navLinksWithGenerics?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinksWithGenerics) {
              buffer.write(null(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'parent': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.parent,
          getProperties: _Renderer_Documentable.propertyMap,
        ),
        'relCanonicalPrefix': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
        ),
        'title': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.title,
          getProperties: _Renderer_String.propertyMap,
        ),
        'useBaseHref': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.useBaseHref == true,
        ),
        'version': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.version,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends TemplateOptions>() =>
      {
        'relCanonicalPrefix': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
        ),
        'toolVersion': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.toolVersion,
          getProperties: _Renderer_String.propertyMap,
        ),
        'useBaseHref': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.useBaseHref == true,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends Documentable>() => {
        'config': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.config,
        ),
        'documentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasDocumentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.hasExtendedDocumentation == true,
        ),
        'href': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isDocumented': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isDocumented == true,
        ),
        'kind': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'oneLineDoc': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'packageGraph': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.packageGraph,
        ),
        ..._Renderer_Nameable.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends Nameable>() => {
        'fullyQualifiedName': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'name': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePart': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.namePart,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePieces': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.namePieces,
          isEmptyIterable: (X_ c) => c.namePieces?.isEmpty ?? false,

          renderIterable: (X_ c, RendererBase<X_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.namePieces) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends int>() => {
        'bitLength': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.bitLength,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEven': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isEven,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isEven == true,
        ),
        'isOdd': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isOdd,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isOdd == true,
        ),
        'sign': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.sign,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_num.propertyMap<X_>(),
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
  static Map<String, Property<X_>> propertyMap<X_ extends num>() => {
        'hashCode': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isFinite': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isFinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isFinite == true,
        ),
        'isInfinite': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isInfinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isInfinite == true,
        ),
        'isNaN': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isNaN,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNaN == true,
        ),
        'isNegative': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.isNegative,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (X_ c) => c.isNegative == true,
        ),
        'sign': Property(
          // (PackageTemplateData*, Package*, LibraryContainer*, Object, bool, ..., int, num)
          getValue: (X_ c) => c.sign,
          getProperties: _Renderer_num.propertyMap,
        ),
        ..._Renderer_Object.propertyMap<X_>(),
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
