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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.htmlBase, ast, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.layoutTitle, ast, parent: r);
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.metaDescription, ast, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Package.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Package.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, parent: r);
          },
        ),
        'self': Property(
          getValue: (CT_ c) => c.self,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Package.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Package.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.self == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.self, ast, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
        ),
        'baseHref': Property(
          getValue: (CT_ c) => c.baseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.baseHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.baseHref, ast, parent: r);
          },
        ),
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
        ),
        'categories': Property(
          getValue: (CT_ c) => c.categories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
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
        ),
        'containerOrder': Property(
          getValue: (CT_ c) => c.containerOrder,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_LibraryContainer.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_LibraryContainer.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.defaultCategory == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_LibraryContainer(c.defaultCategory, ast, parent: r);
          },
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentation, ast, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationAsHtml, ast, parent: r);
          },
        ),
        'documentationFile': Property(
          getValue: (CT_ c) => c.documentationFile,
        ),
        'documentationFrom': Property(
          getValue: (CT_ c) => c.documentationFrom,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'documentedCategories': Property(
          getValue: (CT_ c) => c.documentedCategories,
        ),
        'documentedCategoriesSorted': Property(
          getValue: (CT_ c) => c.documentedCategoriesSorted,
        ),
        'documentedWhere': Property(
          getValue: (CT_ c) => c.documentedWhere,
        ),
        'element': Property(
          getValue: (CT_ c) => c.element,
        ),
        'enclosingElement': Property(
          getValue: (CT_ c) => c.enclosingElement,
        ),
        'enclosingName': Property(
          getValue: (CT_ c) => c.enclosingName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.enclosingName, ast, parent: r);
          },
        ),
        'filePath': Property(
          getValue: (CT_ c) => c.filePath,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.filePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.filePath, ast, parent: r);
          },
        ),
        'fileType': Property(
          getValue: (CT_ c) => c.fileType,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fileType == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fileType, ast, parent: r);
          },
        ),
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedName, ast, parent: r);
          },
        ),
        'hasCategories': Property(
          getValue: (CT_ c) => c.hasCategories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasCategories == true,
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          getValue: (CT_ c) => c.hasDocumentationFile,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          getValue: (CT_ c) => c.hasDocumentedCategories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.href, ast, parent: r);
          },
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isCanonical == true,
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'isFirstPackage': Property(
          getValue: (CT_ c) => c.isFirstPackage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isFirstPackage == true,
        ),
        'isLocal': Property(
          getValue: (CT_ c) => c.isLocal,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isLocal == true,
        ),
        'isPublic': Property(
          getValue: (CT_ c) => c.isPublic,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isPublic == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.kind, ast, parent: r);
          },
        ),
        'location': Property(
          getValue: (CT_ c) => c.location,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.name, ast, parent: r);
          },
        ),
        'nameToCategory': Property(
          getValue: (CT_ c) => c.nameToCategory,
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.oneLineDoc, ast, parent: r);
          },
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Package.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Package.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
        ),
        'packageMeta': Property(
          getValue: (CT_ c) => c.packageMeta,
        ),
        'packagePath': Property(
          getValue: (CT_ c) => c.packagePath,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.packagePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.packagePath, ast, parent: r);
          },
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
        ),
        'toolInvocationIndex': Property(
          getValue: (CT_ c) => c.toolInvocationIndex,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.toolInvocationIndex == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.toolInvocationIndex, ast, parent: r);
          },
        ),
        'usedAnimationIdsByHref': Property(
          getValue: (CT_ c) => c.usedAnimationIdsByHref,
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.enclosingName, ast, parent: r);
          },
        ),
        'hasPublicLibraries': Property(
          getValue: (CT_ c) => c.hasPublicLibraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicLibraries == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'libraries': Property(
          getValue: (CT_ c) => c.libraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
        ),
        'publicLibrariesSorted': Property(
          getValue: (CT_ c) => c.publicLibrariesSorted,
        ),
        'sortKey': Property(
          getValue: (CT_ c) => c.sortKey,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentation, ast, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationAsHtml, ast, parent: r);
          },
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.href, ast, parent: r);
          },
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.kind, ast, parent: r);
          },
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.oneLineDoc, ast, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedName, ast, parent: r);
          },
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.name, ast, parent: r);
          },
        ),
        'namePart': Property(
          getValue: (CT_ c) => c.namePart,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
        'isEmpty': Property(
          getValue: (CT_ c) => c.isEmpty,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isEmpty == true,
        ),
        'isNotEmpty': Property(
          getValue: (CT_ c) => c.isNotEmpty,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isNotEmpty == true,
        ),
        'length': Property(
          getValue: (CT_ c) => c.length,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.bareHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.bareHref, ast, parent: r);
          },
        ),
        'defaultPackage': Property(
          getValue: (CT_ c) => c.defaultPackage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Package.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Package.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.defaultPackage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.defaultPackage, ast, parent: r);
          },
        ),
        'hasFooterVersion': Property(
          getValue: (CT_ c) => c.hasFooterVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.homepage, ast, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.htmlBase, ast, parent: r);
          },
        ),
        'htmlOptions': Property(
          getValue: (CT_ c) => c.htmlOptions,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_TemplateOptions.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_TemplateOptions.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.htmlOptions == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_TemplateOptions(c.htmlOptions, ast, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.layoutTitle, ast, parent: r);
          },
        ),
        'localPackages': Property(
          getValue: (CT_ c) => c.localPackages,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.metaDescription, ast, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isEmptyIterable: (CT_ c) => c.navLinksWithGenerics?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinksWithGenerics) {
              buffer.write(_render_Container(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'parent': Property(
          getValue: (CT_ c) => c.parent,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Documentable.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Documentable.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.parent == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Documentable(c.parent, ast, parent: r);
          },
        ),
        'relCanonicalPrefix': Property(
          getValue: (CT_ c) => c.relCanonicalPrefix,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.relCanonicalPrefix, ast, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.title, ast, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.useBaseHref == true,
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.relCanonicalPrefix, ast, parent: r);
          },
        ),
        'toolVersion': Property(
          getValue: (CT_ c) => c.toolVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.toolVersion == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.toolVersion, ast, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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

String _render_Container(Container context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Container(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Container extends RendererBase<Container> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Container>() => {
        'allElements': Property(
          getValue: (CT_ c) => c.allElements,
        ),
        'allModelElements': Property(
          getValue: (CT_ c) => c.allModelElements,
          isEmptyIterable: (CT_ c) => c.allModelElements?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.allModelElements) {
              buffer.write(_render_ModelElement(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'allModelElementsByNamePart': Property(
          getValue: (CT_ c) => c.allModelElementsByNamePart,
        ),
        'constantFields': Property(
          getValue: (CT_ c) => c.constantFields,
        ),
        'declaredFields': Property(
          getValue: (CT_ c) => c.declaredFields,
        ),
        'declaredMethods': Property(
          getValue: (CT_ c) => c.declaredMethods,
        ),
        'declaredOperators': Property(
          getValue: (CT_ c) => c.declaredOperators,
        ),
        'hasInstanceFields': Property(
          getValue: (CT_ c) => c.hasInstanceFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasInstanceFields == true,
        ),
        'hasPublicConstantFields': Property(
          getValue: (CT_ c) => c.hasPublicConstantFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicConstantFields == true,
        ),
        'hasPublicInstanceFields': Property(
          getValue: (CT_ c) => c.hasPublicInstanceFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicInstanceFields == true,
        ),
        'hasPublicInstanceMethods': Property(
          getValue: (CT_ c) => c.hasPublicInstanceMethods,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicInstanceMethods == true,
        ),
        'hasPublicInstanceOperators': Property(
          getValue: (CT_ c) => c.hasPublicInstanceOperators,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicInstanceOperators == true,
        ),
        'hasPublicStaticFields': Property(
          getValue: (CT_ c) => c.hasPublicStaticFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicStaticFields == true,
        ),
        'hasPublicStaticMethods': Property(
          getValue: (CT_ c) => c.hasPublicStaticMethods,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicStaticMethods == true,
        ),
        'hasPublicVariableStaticFields': Property(
          getValue: (CT_ c) => c.hasPublicVariableStaticFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasPublicVariableStaticFields == true,
        ),
        'instanceAccessors': Property(
          getValue: (CT_ c) => c.instanceAccessors,
        ),
        'instanceFields': Property(
          getValue: (CT_ c) => c.instanceFields,
        ),
        'instanceMethods': Property(
          getValue: (CT_ c) => c.instanceMethods,
        ),
        'instanceOperators': Property(
          getValue: (CT_ c) => c.instanceOperators,
        ),
        'isClass': Property(
          getValue: (CT_ c) => c.isClass,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isClass == true,
        ),
        'isClassOrExtension': Property(
          getValue: (CT_ c) => c.isClassOrExtension,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isClassOrExtension == true,
        ),
        'isEnum': Property(
          getValue: (CT_ c) => c.isEnum,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isEnum == true,
        ),
        'isExtension': Property(
          getValue: (CT_ c) => c.isExtension,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isExtension == true,
        ),
        'isMixin': Property(
          getValue: (CT_ c) => c.isMixin,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isMixin == true,
        ),
        'publicConstantFields': Property(
          getValue: (CT_ c) => c.publicConstantFields,
        ),
        'publicConstantFieldsSorted': Property(
          getValue: (CT_ c) => c.publicConstantFieldsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicInheritedInstanceFields': Property(
          getValue: (CT_ c) => c.publicInheritedInstanceFields,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.publicInheritedInstanceFields == true,
        ),
        'publicInheritedInstanceMethods': Property(
          getValue: (CT_ c) => c.publicInheritedInstanceMethods,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.publicInheritedInstanceMethods == true,
        ),
        'publicInheritedInstanceOperators': Property(
          getValue: (CT_ c) => c.publicInheritedInstanceOperators,
        ),
        'publicInstanceFields': Property(
          getValue: (CT_ c) => c.publicInstanceFields,
        ),
        'publicInstanceFieldsSorted': Property(
          getValue: (CT_ c) => c.publicInstanceFieldsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicInstanceMethods': Property(
          getValue: (CT_ c) => c.publicInstanceMethods,
        ),
        'publicInstanceMethodsSorted': Property(
          getValue: (CT_ c) => c.publicInstanceMethodsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicInstanceOperators': Property(
          getValue: (CT_ c) => c.publicInstanceOperators,
        ),
        'publicInstanceOperatorsSorted': Property(
          getValue: (CT_ c) => c.publicInstanceOperatorsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicStaticFields': Property(
          getValue: (CT_ c) => c.publicStaticFields,
        ),
        'publicStaticFieldsSorted': Property(
          getValue: (CT_ c) => c.publicStaticFieldsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicStaticMethods': Property(
          getValue: (CT_ c) => c.publicStaticMethods,
        ),
        'publicStaticMethodsSorted': Property(
          getValue: (CT_ c) => c.publicStaticMethodsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'publicVariableStaticFields': Property(
          getValue: (CT_ c) => c.publicVariableStaticFields,
        ),
        'publicVariableStaticFieldsSorted': Property(
          getValue: (CT_ c) => c.publicVariableStaticFieldsSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'staticAccessors': Property(
          getValue: (CT_ c) => c.staticAccessors,
        ),
        'staticFields': Property(
          getValue: (CT_ c) => c.staticFields,
        ),
        'staticMethods': Property(
          getValue: (CT_ c) => c.staticMethods,
        ),
        'variableStaticFields': Property(
          getValue: (CT_ c) => c.variableStaticFields,
        ),
        ..._Renderer_ModelElement.propertyMap<CT_>(),
      };

  _Renderer_Container(Container context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Container> getProperty(String key) {
    if (propertyMap<Container>().containsKey(key)) {
      return propertyMap<Container>()[key];
    } else {
      return null;
    }
  }
}

String _render_ModelElement(ModelElement context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_ModelElement(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_ModelElement extends RendererBase<ModelElement> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends ModelElement>() => {
        'allParameters': Property(
          getValue: (CT_ c) => c.allParameters,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'annotations': Property(
          getValue: (CT_ c) => c.annotations,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isEmptyIterable: (CT_ c) => c.annotations?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.annotations) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'canHaveParameters': Property(
          getValue: (CT_ c) => c.canHaveParameters,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.canHaveParameters == true,
        ),
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
        ),
        'canonicalModelElement': Property(
          getValue: (CT_ c) => c.canonicalModelElement,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_ModelElement.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_ModelElement.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.canonicalModelElement == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_ModelElement(c.canonicalModelElement, ast,
                parent: r);
          },
        ),
        'characterLocation': Property(
          getValue: (CT_ c) => c.characterLocation,
        ),
        'commentRefs': Property(
          getValue: (CT_ c) => c.commentRefs,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'compilationUnitElement': Property(
          getValue: (CT_ c) => c.compilationUnitElement,
        ),
        'computeDocumentationFrom': Property(
          getValue: (CT_ c) => c.computeDocumentationFrom,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isEmptyIterable: (CT_ c) =>
              c.computeDocumentationFrom?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.computeDocumentationFrom) {
              buffer.write(_render_ModelElement(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'config': Property(
          getValue: (CT_ c) => c.config,
        ),
        'definingLibrary': Property(
          getValue: (CT_ c) => c.definingLibrary,
        ),
        'displayedCategories': Property(
          getValue: (CT_ c) => c.displayedCategories,
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentation, ast, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationAsHtml, ast, parent: r);
          },
        ),
        'documentationFrom': Property(
          getValue: (CT_ c) => c.documentationFrom,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isEmptyIterable: (CT_ c) => c.documentationFrom?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentationFrom) {
              buffer.write(_render_ModelElement(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentationLocal': Property(
          getValue: (CT_ c) => c.documentationLocal,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.documentationLocal == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.documentationLocal, ast, parent: r);
          },
        ),
        'element': Property(
          getValue: (CT_ c) => c.element,
        ),
        'exportedInLibraries': Property(
          getValue: (CT_ c) => c.exportedInLibraries,
        ),
        'extendedDocLink': Property(
          getValue: (CT_ c) => c.extendedDocLink,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.extendedDocLink == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.extendedDocLink, ast, parent: r);
          },
        ),
        'features': Property(
          getValue: (CT_ c) => c.features,
          isEmptyIterable: (CT_ c) => c.features?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.features) {
              buffer.write(_render_String(e, ast, parent: r));
            }
            return buffer.toString();
          },
        ),
        'featuresAsString': Property(
          getValue: (CT_ c) => c.featuresAsString,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.featuresAsString == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.featuresAsString, ast, parent: r);
          },
        ),
        'fileName': Property(
          getValue: (CT_ c) => c.fileName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fileName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fileName, ast, parent: r);
          },
        ),
        'filePath': Property(
          getValue: (CT_ c) => c.filePath,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.filePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.filePath, ast, parent: r);
          },
        ),
        'fileType': Property(
          getValue: (CT_ c) => c.fileType,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fileType == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fileType, ast, parent: r);
          },
        ),
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedName, ast, parent: r);
          },
        ),
        'fullyQualifiedNameWithoutLibrary': Property(
          getValue: (CT_ c) => c.fullyQualifiedNameWithoutLibrary,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.fullyQualifiedNameWithoutLibrary == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.fullyQualifiedNameWithoutLibrary, ast,
                parent: r);
          },
        ),
        'hasAnnotations': Property(
          getValue: (CT_ c) => c.hasAnnotations,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasAnnotations == true,
        ),
        'hasCategoryNames': Property(
          getValue: (CT_ c) => c.hasCategoryNames,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasCategoryNames == true,
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'hasParameters': Property(
          getValue: (CT_ c) => c.hasParameters,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasParameters == true,
        ),
        'hasSourceHref': Property(
          getValue: (CT_ c) => c.hasSourceHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.hasSourceHref == true,
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.href, ast, parent: r);
          },
        ),
        'htmlId': Property(
          getValue: (CT_ c) => c.htmlId,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.htmlId == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.htmlId, ast, parent: r);
          },
        ),
        'isAsynchronous': Property(
          getValue: (CT_ c) => c.isAsynchronous,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isAsynchronous == true,
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isCanonical == true,
        ),
        'isConst': Property(
          getValue: (CT_ c) => c.isConst,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isConst == true,
        ),
        'isDeprecated': Property(
          getValue: (CT_ c) => c.isDeprecated,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isDeprecated == true,
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'isExecutable': Property(
          getValue: (CT_ c) => c.isExecutable,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isExecutable == true,
        ),
        'isFinal': Property(
          getValue: (CT_ c) => c.isFinal,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isFinal == true,
        ),
        'isLate': Property(
          getValue: (CT_ c) => c.isLate,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isLate == true,
        ),
        'isLocalElement': Property(
          getValue: (CT_ c) => c.isLocalElement,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isLocalElement == true,
        ),
        'isPropertyAccessor': Property(
          getValue: (CT_ c) => c.isPropertyAccessor,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isPropertyAccessor == true,
        ),
        'isPropertyInducer': Property(
          getValue: (CT_ c) => c.isPropertyInducer,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isPropertyInducer == true,
        ),
        'isPublic': Property(
          getValue: (CT_ c) => c.isPublic,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isPublic == true,
        ),
        'isPublicAndPackageDocumented': Property(
          getValue: (CT_ c) => c.isPublicAndPackageDocumented,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isPublicAndPackageDocumented == true,
        ),
        'isStatic': Property(
          getValue: (CT_ c) => c.isStatic,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isStatic == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.kind, ast, parent: r);
          },
        ),
        'library': Property(
          getValue: (CT_ c) => c.library,
        ),
        'linkedName': Property(
          getValue: (CT_ c) => c.linkedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.linkedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.linkedName, ast, parent: r);
          },
        ),
        'linkedParams': Property(
          getValue: (CT_ c) => c.linkedParams,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.linkedParams == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.linkedParams, ast, parent: r);
          },
        ),
        'linkedParamsLines': Property(
          getValue: (CT_ c) => c.linkedParamsLines,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.linkedParamsLines == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.linkedParamsLines, ast, parent: r);
          },
        ),
        'linkedParamsNoMetadata': Property(
          getValue: (CT_ c) => c.linkedParamsNoMetadata,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.linkedParamsNoMetadata == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.linkedParamsNoMetadata, ast, parent: r);
          },
        ),
        'linkedParamsNoMetadataOrNames': Property(
          getValue: (CT_ c) => c.linkedParamsNoMetadataOrNames,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.linkedParamsNoMetadataOrNames == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.linkedParamsNoMetadataOrNames, ast,
                parent: r);
          },
        ),
        'location': Property(
          getValue: (CT_ c) => c.location,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
        'modelNode': Property(
          getValue: (CT_ c) => c.modelNode,
        ),
        'modelType': Property(
          getValue: (CT_ c) => c.modelType,
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.name, ast, parent: r);
          },
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.oneLineDoc, ast, parent: r);
          },
        ),
        'originalMember': Property(
          getValue: (CT_ c) => c.originalMember,
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_Package.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_Package.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
        ),
        'parameters': Property(
          getValue: (CT_ c) => c.parameters,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'pathContext': Property(
          getValue: (CT_ c) => c.pathContext,
        ),
        'sourceCode': Property(
          getValue: (CT_ c) => c.sourceCode,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.sourceCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.sourceCode, ast, parent: r);
          },
        ),
        'sourceFileName': Property(
          getValue: (CT_ c) => c.sourceFileName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.sourceFileName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.sourceFileName, ast, parent: r);
          },
        ),
        'sourceHref': Property(
          getValue: (CT_ c) => c.sourceHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_String.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_String.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.sourceHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_String(c.sourceHref, ast, parent: r);
          },
        ),
        ..._Renderer_Canonicalization.propertyMap<CT_>(),
      };

  _Renderer_ModelElement(ModelElement context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<ModelElement> getProperty(String key) {
    if (propertyMap<ModelElement>().containsKey(key)) {
      return propertyMap<ModelElement>()[key];
    } else {
      return null;
    }
  }
}

String _render_Canonicalization(
    Canonicalization context, List<MustachioNode> ast,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Canonicalization(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Canonicalization extends RendererBase<Canonicalization> {
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends Canonicalization>() =>
      {
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
        ),
        'commentRefs': Property(
          getValue: (CT_ c) => c.commentRefs,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_List.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_List.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isCanonical == true,
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
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_Canonicalization(
      Canonicalization context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Canonicalization> getProperty(String key) {
    if (propertyMap<Canonicalization>().containsKey(key)) {
      return propertyMap<Canonicalization>()[key];
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.bitLength == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.bitLength, ast, parent: r);
          },
        ),
        'isEven': Property(
          getValue: (CT_ c) => c.isEven,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isEven == true,
        ),
        'isOdd': Property(
          getValue: (CT_ c) => c.isOdd,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isOdd == true,
        ),
        'sign': Property(
          getValue: (CT_ c) => c.sign,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_int.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_int.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_int(c.hashCode, ast, parent: r);
          },
        ),
        'isFinite': Property(
          getValue: (CT_ c) => c.isFinite,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isFinite == true,
        ),
        'isInfinite': Property(
          getValue: (CT_ c) => c.isInfinite,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isInfinite == true,
        ),
        'isNaN': Property(
          getValue: (CT_ c) => c.isNaN,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isNaN == true,
        ),
        'isNegative': Property(
          getValue: (CT_ c) => c.isNegative,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_bool.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_bool.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
          getBool: (CT_ c) => c.isNegative == true,
        ),
        'sign': Property(
          getValue: (CT_ c) => c.sign,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            if (_Renderer_num.propertyMap().containsKey(name)) {
              var nextProperty = _Renderer_num.propertyMap()[name];
              return nextProperty.renderVariable(
                  self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
            } else {
              throw MustachioResolutionError();
            }
          },
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
