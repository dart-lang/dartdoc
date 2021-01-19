// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, unnecessary_cast, unused_element, unused_import
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'templates.dart';

String _simpleResolveErrorMessage(List<String> key, String type) =>
    'Failed to resolve $key property chain on $type using a simple renderer; '
    'expose the properties of $type by adding it to the @Renderer '
    "annotation's 'visibleTypes' list";

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
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.homepage, ast, r.template, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlBase, ast, r.template, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.layoutTitle, ast, r.template, parent: r);
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.metaDescription, ast, r.template, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(_simpleResolveErrorMessage(
                  remainingNames, 'List<Documentable*>*'));
            }
          },
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
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'Package*'));
            }
          },
          isNullValue: (CT_ c) => c.package == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.package, ast, r.template, parent: r);
          },
        ),
        'self': Property(
          getValue: (CT_ c) => c.self,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'Package*'));
            }
          },
          isNullValue: (CT_ c) => c.self == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.self, ast, r.template, parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
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
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'int'));
            }
          },
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
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.bareHref == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.bareHref, ast, r.template, parent: r);
          },
        ),
        'defaultPackage': Property(
          getValue: (CT_ c) => c.defaultPackage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'Package*'));
            }
          },
          isNullValue: (CT_ c) => c.defaultPackage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.defaultPackage, ast, r.template, parent: r);
          },
        ),
        'hasFooterVersion': Property(
          getValue: (CT_ c) => c.hasFooterVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.hasFooterVersion == true,
        ),
        'hasHomepage': Property(
          getValue: (CT_ c) => c.hasHomepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (CT_ c) => c.homepage,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.homepage == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.homepage, ast, r.template, parent: r);
          },
        ),
        'htmlBase': Property(
          getValue: (CT_ c) => c.htmlBase,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.htmlBase == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlBase, ast, r.template, parent: r);
          },
        ),
        'htmlOptions': Property(
          getValue: (CT_ c) => c.htmlOptions,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(_simpleResolveErrorMessage(
                  remainingNames, 'TemplateOptions*'));
            }
          },
          isNullValue: (CT_ c) => c.htmlOptions == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.htmlOptions, ast, r.template, parent: r);
          },
        ),
        'includeVersion': Property(
          getValue: (CT_ c) => c.includeVersion,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (CT_ c) => c.layoutTitle,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.layoutTitle == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.layoutTitle, ast, r.template, parent: r);
          },
        ),
        'localPackages': Property(
          getValue: (CT_ c) => c.localPackages,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(_simpleResolveErrorMessage(
                  remainingNames, 'List<Package*>*'));
            }
          },
          isEmptyIterable: (CT_ c) => c.localPackages?.isEmpty ?? true,
          renderIterable:
              (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            var buffer = StringBuffer();
            for (var e in c.localPackages) {
              buffer.write(renderSimple(e, ast, r.template, parent: r));
            }
            return buffer.toString();
          },
        ),
        'metaDescription': Property(
          getValue: (CT_ c) => c.metaDescription,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.metaDescription == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.metaDescription, ast, r.template, parent: r);
          },
        ),
        'navLinks': Property(
          getValue: (CT_ c) => c.navLinks,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(_simpleResolveErrorMessage(
                  remainingNames, 'List<Documentable*>*'));
            }
          },
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
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(_simpleResolveErrorMessage(
                  remainingNames, 'List<Container*>*'));
            }
          },
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
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'Documentable*'));
            }
          },
          isNullValue: (CT_ c) => c.parent == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.parent, ast, r.template, parent: r);
          },
        ),
        'relCanonicalPrefix': Property(
          getValue: (CT_ c) => c.relCanonicalPrefix,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.relCanonicalPrefix == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.relCanonicalPrefix, ast, r.template,
                parent: r);
          },
        ),
        'title': Property(
          getValue: (CT_ c) => c.title,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
          isNullValue: (CT_ c) => c.title == null,
          renderValue: (CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
            return renderSimple(c.title, ast, r.template, parent: r);
          },
        ),
        'useBaseHref': Property(
          getValue: (CT_ c) => c.useBaseHref,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'bool*'));
            }
          },
          getBool: (CT_ c) => c.useBaseHref == true,
        ),
        'version': Property(
          getValue: (CT_ c) => c.version,
          renderVariable:
              (CT_ c, Property<CT_> self, List<String> remainingNames) {
            if (remainingNames.isEmpty) {
              return self.getValue(c).toString();
            } else {
              throw MustachioResolutionError(
                  _simpleResolveErrorMessage(remainingNames, 'String*'));
            }
          },
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
