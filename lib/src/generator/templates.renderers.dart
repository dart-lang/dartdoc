// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, unnecessary_cast, unused_element, unused_import, non_constant_identifier_names
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/warnings.dart';
import 'templates.dart';

String renderIndex(PackageTemplateData context, Template template) {
  return _render_PackageTemplateData(context, template.ast, template);
}

String _render_PackageTemplateData(
    PackageTemplateData context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_PackageTemplateData(context, parent, template);
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
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.homepage, ast, r.template, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlBase, ast, r.template, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.layoutTitle, ast, r.template, parent: r);
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.metaDescription, ast, r.template, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'List<Documentable>'),
          isEmptyIterable: (CT_ c) => c.navLinks?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinks) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
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
            var nextProperty = _Renderer_Package.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, r.template, parent: r);
          },
        ),
        'self': Property(
          getValue: (CT_ c) => c.self,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Package.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.self == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.self, ast, r.template, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.title, ast, r.template, parent: r);
          },
        ),
        ..._Renderer_TemplateData.propertyMap<Package, CT_>(),
      };

  _Renderer_PackageTemplateData(PackageTemplateData context,
      RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<PackageTemplateData> getProperty(String key) {
    if (propertyMap<PackageTemplateData>().containsKey(key)) {
      return propertyMap<PackageTemplateData>()[key];
    } else {
      return null;
    }
  }
}

String _render_Package(
    Package context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Package(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Package extends RendererBase<Package> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Package>() => {
        'allLibraries': Property(
          getValue: (CT_ c) => c.allLibraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Set<Library>'),
          isEmptyIterable: (CT_ c) => c.allLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.allLibraries) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'baseHref': Property(
          getValue: (CT_ c) => c.baseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.baseHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.baseHref, ast, r.template, parent: r);
          },
        ),
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Library'),
          isNullValue: (CT_ c) => c.canonicalLibrary == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.canonicalLibrary, ast, r.template, parent: r);
          },
        ),
        'categories': Property(
          getValue: (CT_ c) => c.categories,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'List<Category>'),
          isEmptyIterable: (CT_ c) => c.categories?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categories) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'categoriesWithPublicLibraries': Property(
          getValue: (CT_ c) => c.categoriesWithPublicLibraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'Iterable<LibraryContainer>'),
          isEmptyIterable: (CT_ c) =>
              c.categoriesWithPublicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.categoriesWithPublicLibraries) {
              buffer.write(
                  _render_LibraryContainer(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'config': Property(
          getValue: (CT_ c) => c.config,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'DartdocOptionContext'),
          isNullValue: (CT_ c) => c.config == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.config, ast, r.template, parent: r);
          },
        ),
        'containerOrder': Property(
          getValue: (CT_ c) => c.containerOrder,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'List<String>'),
          isEmptyIterable: (CT_ c) => c.containerOrder?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
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
            var nextProperty =
                _Renderer_LibraryContainer.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.defaultCategory == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_LibraryContainer(c.defaultCategory, ast, r.template,
                parent: r);
          },
        ),
        'documentation': Property(
          getValue: (CT_ c) => c.documentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.documentation == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.documentation, ast, r.template, parent: r);
          },
        ),
        'documentationAsHtml': Property(
          getValue: (CT_ c) => c.documentationAsHtml,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.documentationAsHtml == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.documentationAsHtml, ast, r.template,
                parent: r);
          },
        ),
        'documentationFile': Property(
          getValue: (CT_ c) => c.documentationFile,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'File'),
          isNullValue: (CT_ c) => c.documentationFile == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.documentationFile, ast, r.template,
                parent: r);
          },
        ),
        'documentationFrom': Property(
          getValue: (CT_ c) => c.documentationFrom,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'List<Locatable>'),
          isEmptyIterable: (CT_ c) => c.documentationFrom?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentationFrom) {
              buffer.write(_render_Locatable(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategories': Property(
          getValue: (CT_ c) => c.documentedCategories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'Iterable<Category>'),
          isEmptyIterable: (CT_ c) => c.documentedCategories?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentedCategories) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedCategoriesSorted': Property(
          getValue: (CT_ c) => c.documentedCategoriesSorted,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'Iterable<Category>'),
          isEmptyIterable: (CT_ c) =>
              c.documentedCategoriesSorted?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentedCategoriesSorted) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentedWhere': Property(
          getValue: (CT_ c) => c.documentedWhere,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'DocumentLocation'),
          isNullValue: (CT_ c) => c.documentedWhere == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.documentedWhere, ast, r.template, parent: r);
          },
        ),
        'element': Property(
          getValue: (CT_ c) => c.element,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Element'),
          isNullValue: (CT_ c) => c.element == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.element, ast, r.template, parent: r);
          },
        ),
        'enclosingElement': Property(
          getValue: (CT_ c) => c.enclosingElement,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Warnable.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.enclosingElement == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Warnable(c.enclosingElement, ast, r.template,
                parent: r);
          },
        ),
        'enclosingName': Property(
          getValue: (CT_ c) => c.enclosingName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.enclosingName, ast, r.template, parent: r);
          },
        ),
        'filePath': Property(
          getValue: (CT_ c) => c.filePath,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.filePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.filePath, ast, r.template, parent: r);
          },
        ),
        'fileType': Property(
          getValue: (CT_ c) => c.fileType,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.fileType == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.fileType, ast, r.template, parent: r);
          },
        ),
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.fullyQualifiedName, ast, r.template,
                parent: r);
          },
        ),
        'hasCategories': Property(
          getValue: (CT_ c) => c.hasCategories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasCategories == true,
        ),
        'hasDocumentation': Property(
          getValue: (CT_ c) => c.hasDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          getValue: (CT_ c) => c.hasDocumentationFile,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          getValue: (CT_ c) => c.hasDocumentedCategories,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (CT_ c) => c.hasExtendedDocumentation,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.homepage, ast, r.template, parent: r);
          },
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.href, ast, r.template, parent: r);
          },
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isCanonical == true,
        ),
        'isDocumented': Property(
          getValue: (CT_ c) => c.isDocumented,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isDocumented == true,
        ),
        'isFirstPackage': Property(
          getValue: (CT_ c) => c.isFirstPackage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isFirstPackage == true,
        ),
        'isLocal': Property(
          getValue: (CT_ c) => c.isLocal,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isLocal == true,
        ),
        'isPublic': Property(
          getValue: (CT_ c) => c.isPublic,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isPublic == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'kind': Property(
          getValue: (CT_ c) => c.kind,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.kind == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.kind, ast, r.template, parent: r);
          },
        ),
        'location': Property(
          getValue: (CT_ c) => c.location,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.location == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.location, ast, r.template, parent: r);
          },
        ),
        'locationPieces': Property(
          getValue: (CT_ c) => c.locationPieces,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Set<String>'),
          isEmptyIterable: (CT_ c) => c.locationPieces?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.locationPieces) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.name, ast, r.template, parent: r);
          },
        ),
        'nameToCategory': Property(
          getValue: (CT_ c) => c.nameToCategory,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'Map<String, Category>'),
          isNullValue: (CT_ c) => c.nameToCategory == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.nameToCategory, ast, r.template, parent: r);
          },
        ),
        'oneLineDoc': Property(
          getValue: (CT_ c) => c.oneLineDoc,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.oneLineDoc == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.oneLineDoc, ast, r.template, parent: r);
          },
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Package.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, r.template, parent: r);
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'PackageGraph'),
          isNullValue: (CT_ c) => c.packageGraph == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.packageGraph, ast, r.template, parent: r);
          },
        ),
        'packageMeta': Property(
          getValue: (CT_ c) => c.packageMeta,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'PackageMeta'),
          isNullValue: (CT_ c) => c.packageMeta == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.packageMeta, ast, r.template, parent: r);
          },
        ),
        'packagePath': Property(
          getValue: (CT_ c) => c.packagePath,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.packagePath == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.packagePath, ast, r.template, parent: r);
          },
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'Iterable<Library>'),
          isEmptyIterable: (CT_ c) => c.publicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'toolInvocationIndex': Property(
          getValue: (CT_ c) => c.toolInvocationIndex,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'int'),
          isNullValue: (CT_ c) => c.toolInvocationIndex == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.toolInvocationIndex, ast, r.template,
                parent: r);
          },
        ),
        'usedAnimationIdsByHref': Property(
          getValue: (CT_ c) => c.usedAnimationIdsByHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'Map<String, Set<String>>'),
          isNullValue: (CT_ c) => c.usedAnimationIdsByHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.usedAnimationIdsByHref, ast, r.template,
                parent: r);
          },
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.version == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.version, ast, r.template, parent: r);
          },
        ),
        ..._Renderer_LibraryContainer.propertyMap<CT_>(),
        ..._Renderer_Nameable.propertyMap<CT_>(),
        ..._Renderer_Locatable.propertyMap<CT_>(),
        ..._Renderer_Canonicalization.propertyMap<CT_>(),
        ..._Renderer_Warnable.propertyMap<CT_>(),
      };

  _Renderer_Package(
      Package context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Package> getProperty(String key) {
    if (propertyMap<Package>().containsKey(key)) {
      return propertyMap<Package>()[key];
    } else {
      return null;
    }
  }
}

String _render_Nameable(
    Nameable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Nameable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Nameable extends RendererBase<Nameable> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Nameable>() => {
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.fullyQualifiedName, ast, r.template,
                parent: r);
          },
        ),
        'name': Property(
          getValue: (CT_ c) => c.name,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.name == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.name, ast, r.template, parent: r);
          },
        ),
        'namePart': Property(
          getValue: (CT_ c) => c.namePart,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.namePart == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.namePart, ast, r.template, parent: r);
          },
        ),
        'namePieces': Property(
          getValue: (CT_ c) => c.namePieces,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Set<String>'),
          isEmptyIterable: (CT_ c) => c.namePieces?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.namePieces) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_Nameable(
      Nameable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Nameable> getProperty(String key) {
    if (propertyMap<Nameable>().containsKey(key)) {
      return propertyMap<Nameable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Locatable(
    Locatable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Locatable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Locatable extends RendererBase<Locatable> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Locatable>() => {
        'documentationFrom': Property(
          getValue: (CT_ c) => c.documentationFrom,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'List<Locatable>'),
          isEmptyIterable: (CT_ c) => c.documentationFrom?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.documentationFrom) {
              buffer.write(_render_Locatable(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'documentationIsLocal': Property(
          getValue: (CT_ c) => c.documentationIsLocal,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.documentationIsLocal == true,
        ),
        'fullyQualifiedName': Property(
          getValue: (CT_ c) => c.fullyQualifiedName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.fullyQualifiedName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.fullyQualifiedName, ast, r.template,
                parent: r);
          },
        ),
        'href': Property(
          getValue: (CT_ c) => c.href,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.href == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.href, ast, r.template, parent: r);
          },
        ),
        'location': Property(
          getValue: (CT_ c) => c.location,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.location == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.location, ast, r.template, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_Locatable(
      Locatable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Locatable> getProperty(String key) {
    if (propertyMap<Locatable>().containsKey(key)) {
      return propertyMap<Locatable>()[key];
    } else {
      return null;
    }
  }
}

String _render_Canonicalization(
    Canonicalization context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Canonicalization(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Canonicalization extends RendererBase<Canonicalization> {
  static Map<String, Property<CT_>> propertyMap<
          CT_ extends Canonicalization>() =>
      {
        'canonicalLibrary': Property(
          getValue: (CT_ c) => c.canonicalLibrary,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Library'),
          isNullValue: (CT_ c) => c.canonicalLibrary == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.canonicalLibrary, ast, r.template, parent: r);
          },
        ),
        'commentRefs': Property(
          getValue: (CT_ c) => c.commentRefs,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'List<ModelCommentReference>'),
          isEmptyIterable: (CT_ c) => c.commentRefs?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.commentRefs) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'isCanonical': Property(
          getValue: (CT_ c) => c.isCanonical,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isCanonical == true,
        ),
        'locationPieces': Property(
          getValue: (CT_ c) => c.locationPieces,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Set<String>'),
          isEmptyIterable: (CT_ c) => c.locationPieces?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.locationPieces) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_Canonicalization(
      Canonicalization context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Canonicalization> getProperty(String key) {
    if (propertyMap<Canonicalization>().containsKey(key)) {
      return propertyMap<Canonicalization>()[key];
    } else {
      return null;
    }
  }
}

String _render_Warnable(
    Warnable context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Warnable(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Warnable extends RendererBase<Warnable> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Warnable>() => {
        'element': Property(
          getValue: (CT_ c) => c.element,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Element'),
          isNullValue: (CT_ c) => c.element == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.element, ast, r.template, parent: r);
          },
        ),
        'enclosingElement': Property(
          getValue: (CT_ c) => c.enclosingElement,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Warnable.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.enclosingElement == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Warnable(c.enclosingElement, ast, r.template,
                parent: r);
          },
        ),
        'package': Property(
          getValue: (CT_ c) => c.package,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Package.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.package, ast, r.template, parent: r);
          },
        ),
      };

  _Renderer_Warnable(
      Warnable context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Warnable> getProperty(String key) {
    if (propertyMap<Warnable>().containsKey(key)) {
      return propertyMap<Warnable>()[key];
    } else {
      return null;
    }
  }
}

String _render_LibraryContainer(
    LibraryContainer context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_LibraryContainer(context, parent, template);
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
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'List<String>'),
          isEmptyIterable: (CT_ c) => c.containerOrder?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.containerOrder) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'enclosingName': Property(
          getValue: (CT_ c) => c.enclosingName,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.enclosingName == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.enclosingName, ast, r.template, parent: r);
          },
        ),
        'hasPublicLibraries': Property(
          getValue: (CT_ c) => c.hasPublicLibraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasPublicLibraries == true,
        ),
        'isSdk': Property(
          getValue: (CT_ c) => c.isSdk,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.isSdk == true,
        ),
        'libraries': Property(
          getValue: (CT_ c) => c.libraries,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'List<Library>'),
          isEmptyIterable: (CT_ c) => c.libraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.libraries) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'packageGraph': Property(
          getValue: (CT_ c) => c.packageGraph,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'PackageGraph'),
          isNullValue: (CT_ c) => c.packageGraph == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.packageGraph, ast, r.template, parent: r);
          },
        ),
        'publicLibraries': Property(
          getValue: (CT_ c) => c.publicLibraries,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'Iterable<Library>'),
          isEmptyIterable: (CT_ c) => c.publicLibraries?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibraries) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'publicLibrariesSorted': Property(
          getValue: (CT_ c) => c.publicLibrariesSorted,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'Iterable<Library>'),
          isEmptyIterable: (CT_ c) => c.publicLibrariesSorted?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.publicLibrariesSorted) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'sortKey': Property(
          getValue: (CT_ c) => c.sortKey,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.sortKey == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.sortKey, ast, r.template, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_LibraryContainer(
      LibraryContainer context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<LibraryContainer> getProperty(String key) {
    if (propertyMap<LibraryContainer>().containsKey(key)) {
      return propertyMap<LibraryContainer>()[key];
    } else {
      return null;
    }
  }
}

String _render_Object(
    Object context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_Object(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Object extends RendererBase<Object> {
  static Map<String, Property<CT_>> propertyMap<CT_ extends Object>() => {
        'hashCode': Property(
          getValue: (CT_ c) => c.hashCode,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'int'),
          isNullValue: (CT_ c) => c.hashCode == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.hashCode, ast, r.template, parent: r);
          },
        ),
      };

  _Renderer_Object(
      Object context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Object> getProperty(String key) {
    if (propertyMap<Object>().containsKey(key)) {
      return propertyMap<Object>()[key];
    } else {
      return null;
    }
  }
}

String _render_TemplateData<T extends Documentable>(
    TemplateData<T> context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_TemplateData(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateData<T extends Documentable>
    extends RendererBase<TemplateData<T>> {
  static Map<String, Property<CT_>> propertyMap<T extends Documentable,
          CT_ extends TemplateData>() =>
      {
        'bareHref': Property(
          getValue: (CT_ c) => c.bareHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.bareHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.bareHref, ast, r.template, parent: r);
          },
        ),
        'defaultPackage': Property(
          getValue: (CT_ c) => c.defaultPackage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) return self.getValue(c).toString();
            var name = remainingNames.first;
            var nextProperty = _Renderer_Package.propertyMap().getValue(name);
            return nextProperty.renderVariable(
                self.getValue(c), nextProperty, [...remainingNames.skip(1)]);
          },
          isNullValue: (CT_ c) => c.defaultPackage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return _render_Package(c.defaultPackage, ast, r.template,
                parent: r);
          },
        ),
        'hasFooterVersion': Property(
          getValue: (CT_ c) => c.hasFooterVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.homepage, ast, r.template, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlBase, ast, r.template, parent: r);
          },
        ),
        'htmlOptions': Property(
          getValue: (CT_ c) => c.htmlOptions,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'TemplateOptions'),
          isNullValue: (CT_ c) => c.htmlOptions == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlOptions, ast, r.template, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.layoutTitle, ast, r.template, parent: r);
          },
        ),
        'localPackages': Property(
          getValue: (CT_ c) => c.localPackages,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'List<Package>'),
          isEmptyIterable: (CT_ c) => c.localPackages?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.localPackages) {
              buffer.write(_render_Package(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.metaDescription, ast, r.template, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(
                      c, remainingNames, 'List<Documentable>'),
          isEmptyIterable: (CT_ c) => c.navLinks?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinks) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'navLinksWithGenerics': Property(
          getValue: (CT_ c) => c.navLinksWithGenerics,
          renderVariable: (CT_ c, Property<CT_> self,
                  List<String> remainingNames) =>
              self.renderSimpleVariable(c, remainingNames, 'List<Container>'),
          isEmptyIterable: (CT_ c) => c.navLinksWithGenerics?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.navLinksWithGenerics) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'parent': Property(
          getValue: (CT_ c) => c.parent,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'Documentable'),
          isNullValue: (CT_ c) => c.parent == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.parent, ast, r.template, parent: r);
          },
        ),
        'relCanonicalPrefix': Property(
          getValue: (CT_ c) => c.relCanonicalPrefix,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.relCanonicalPrefix, ast, r.template,
                parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.title, ast, r.template, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'bool'),
          getBool: (CT_ c) => c.useBaseHref == true,
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) =>
                  self.renderSimpleVariable(c, remainingNames, 'String'),
          isNullValue: (CT_ c) => c.version == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.version, ast, r.template, parent: r);
          },
        ),
        ..._Renderer_Object.propertyMap<CT_>(),
      };

  _Renderer_TemplateData(
      TemplateData<T> context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<TemplateData<T>> getProperty(String key) {
    if (propertyMap<T, TemplateData>().containsKey(key)) {
      return propertyMap<T, TemplateData>()[key];
    } else {
      return null;
    }
  }
}
