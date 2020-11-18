// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// ignore_for_file: camel_case_types, unused_element
import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/mustachio/parser.dart';

String renderIndex(PackageTemplateData context, List<MustachioNode> ast) {
  var renderer = _Renderer_PackageTemplateData(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_PackageTemplateData extends RendererBase<PackageTemplateData> {
  static Map<String, Property<PackageTemplateData>> propertyMap() => {
        'hasHomepage': Property(
          getValue: (PackageTemplateData c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (PackageTemplateData c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (PackageTemplateData c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'htmlBase': Property(
          getValue: (PackageTemplateData c) => c.htmlBase,
          getProperties: _Renderer_String.propertyMap,
        ),
        'includeVersion': Property(
          getValue: (PackageTemplateData c) => c.includeVersion,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (PackageTemplateData c) => c.includeVersion == true,
        ),
        'layoutTitle': Property(
          getValue: (PackageTemplateData c) => c.layoutTitle,
          getProperties: _Renderer_String.propertyMap,
        ),
        'metaDescription': Property(
          getValue: (PackageTemplateData c) => c.metaDescription,
          getProperties: _Renderer_String.propertyMap,
        ),
        'navLinks': Property(
          getValue: (PackageTemplateData c) => c.navLinks,
        ),
        'package': Property(
          getValue: (PackageTemplateData c) => c.package,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'self': Property(
          getValue: (PackageTemplateData c) => c.self,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'title': Property(
          getValue: (PackageTemplateData c) => c.title,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_TemplateData.propertyMap<Package>(),
      };

  _Renderer_PackageTemplateData(PackageTemplateData context) : super(context);
}

String _render_Package(Package context, List<MustachioNode> ast) {
  var renderer = _Renderer_Package(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Package extends RendererBase<Package> {
  static Map<String, Property<Package>> propertyMap() => {
        'allLibraries': Property(
          getValue: (Package c) => c.allLibraries,
        ),
        'baseHref': Property(
          getValue: (Package c) => c.baseHref,
          getProperties: _Renderer_String.propertyMap,
        ),
        'canonicalLibrary': Property(
          getValue: (Package c) => c.canonicalLibrary,
        ),
        'categories': Property(
          getValue: (Package c) => c.categories,
        ),
        'categoriesWithPublicLibraries': Property(
          getValue: (Package c) => c.categoriesWithPublicLibraries,
        ),
        'config': Property(
          getValue: (Package c) => c.config,
        ),
        'containerOrder': Property(
          getValue: (Package c) => c.containerOrder,
        ),
        'defaultCategory': Property(
          getValue: (Package c) => c.defaultCategory,
          getProperties: _Renderer_LibraryContainer.propertyMap,
        ),
        'documentation': Property(
          getValue: (Package c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          getValue: (Package c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationFile': Property(
          getValue: (Package c) => c.documentationFile,
        ),
        'documentationFrom': Property(
          getValue: (Package c) => c.documentationFrom,
        ),
        'documentedCategories': Property(
          getValue: (Package c) => c.documentedCategories,
        ),
        'documentedWhere': Property(
          getValue: (Package c) => c.documentedWhere,
        ),
        'element': Property(
          getValue: (Package c) => c.element,
        ),
        'enclosingElement': Property(
          getValue: (Package c) => c.enclosingElement,
        ),
        'enclosingName': Property(
          getValue: (Package c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'filePath': Property(
          getValue: (Package c) => c.filePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fileType': Property(
          getValue: (Package c) => c.fileType,
          getProperties: _Renderer_String.propertyMap,
        ),
        'fullyQualifiedName': Property(
          getValue: (Package c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasCategories': Property(
          getValue: (Package c) => c.hasCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasCategories == true,
        ),
        'hasDocumentation': Property(
          getValue: (Package c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasDocumentation == true,
        ),
        'hasDocumentationFile': Property(
          getValue: (Package c) => c.hasDocumentationFile,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasDocumentationFile == true,
        ),
        'hasDocumentedCategories': Property(
          getValue: (Package c) => c.hasDocumentedCategories,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasDocumentedCategories == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (Package c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasExtendedDocumentation == true,
        ),
        'hasHomepage': Property(
          getValue: (Package c) => c.hasHomepage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.hasHomepage == true,
        ),
        'homepage': Property(
          getValue: (Package c) => c.homepage,
          getProperties: _Renderer_String.propertyMap,
        ),
        'href': Property(
          getValue: (Package c) => c.href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isCanonical': Property(
          getValue: (Package c) => c.isCanonical,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isCanonical == true,
        ),
        'isDocumented': Property(
          getValue: (Package c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isDocumented == true,
        ),
        'isFirstPackage': Property(
          getValue: (Package c) => c.isFirstPackage,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isFirstPackage == true,
        ),
        'isLocal': Property(
          getValue: (Package c) => c.isLocal,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isLocal == true,
        ),
        'isPublic': Property(
          getValue: (Package c) => c.isPublic,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isPublic == true,
        ),
        'isSdk': Property(
          getValue: (Package c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Package c) => c.isSdk == true,
        ),
        'kind': Property(
          getValue: (Package c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'location': Property(
          getValue: (Package c) => c.location,
          getProperties: _Renderer_String.propertyMap,
        ),
        'locationPieces': Property(
          getValue: (Package c) => c.locationPieces,
        ),
        'name': Property(
          getValue: (Package c) => c.name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'nameToCategory': Property(
          getValue: (Package c) => c.nameToCategory,
        ),
        'oneLineDoc': Property(
          getValue: (Package c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'package': Property(
          getValue: (Package c) => c.package,
          getProperties: _Renderer_Package.propertyMap,
        ),
        'packageGraph': Property(
          getValue: (Package c) => c.packageGraph,
        ),
        'packageMeta': Property(
          getValue: (Package c) => c.packageMeta,
        ),
        'packagePath': Property(
          getValue: (Package c) => c.packagePath,
          getProperties: _Renderer_String.propertyMap,
        ),
        'publicLibraries': Property(
          getValue: (Package c) => c.publicLibraries,
        ),
        'toolInvocationIndex': Property(
          getValue: (Package c) => c.toolInvocationIndex,
          getProperties: _Renderer_int.propertyMap,
        ),
        'usedAnimationIdsByHref': Property(
          getValue: (Package c) => c.usedAnimationIdsByHref,
        ),
        'version': Property(
          getValue: (Package c) => c.version,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_LibraryContainer.propertyMap(),
      };

  _Renderer_Package(Package context) : super(context);
}

String _render_LibraryContainer(
    LibraryContainer context, List<MustachioNode> ast) {
  var renderer = _Renderer_LibraryContainer(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_LibraryContainer extends RendererBase<LibraryContainer> {
  static Map<String, Property<LibraryContainer>> propertyMap() => {
        'containerOrder': Property(
          getValue: (LibraryContainer c) => c.containerOrder,
        ),
        'enclosingName': Property(
          getValue: (LibraryContainer c) => c.enclosingName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasPublicLibraries': Property(
          getValue: (LibraryContainer c) => c.hasPublicLibraries,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (LibraryContainer c) => c.hasPublicLibraries == true,
        ),
        'isSdk': Property(
          getValue: (LibraryContainer c) => c.isSdk,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (LibraryContainer c) => c.isSdk == true,
        ),
        'libraries': Property(
          getValue: (LibraryContainer c) => c.libraries,
        ),
        'packageGraph': Property(
          getValue: (LibraryContainer c) => c.packageGraph,
        ),
        'publicLibraries': Property(
          getValue: (LibraryContainer c) => c.publicLibraries,
        ),
        'sortKey': Property(
          getValue: (LibraryContainer c) => c.sortKey,
          getProperties: _Renderer_String.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_LibraryContainer(LibraryContainer context) : super(context);
}

String _render_Object(Object context, List<MustachioNode> ast) {
  var renderer = _Renderer_Object(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Object extends RendererBase<Object> {
  static Map<String, Property<Object>> propertyMap() => {
        'hashCode': Property(
          getValue: (Object c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
      };

  _Renderer_Object(Object context) : super(context);
}

String _render_bool(bool context, List<MustachioNode> ast) {
  var renderer = _Renderer_bool(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_bool extends RendererBase<bool> {
  static Map<String, Property<bool>> propertyMap() => {
        'hashCode': Property(
          getValue: (bool c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_bool(bool context) : super(context);
}

String _render_List<E>(List<E> context, List<MustachioNode> ast) {
  var renderer = _Renderer_List(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_List<E> extends RendererBase<List<E>> {
  static Map<String, Property<List<E>>> propertyMap<E>() => {
        'length': Property(
          getValue: (List<E> c) => c.length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'reversed': Property(
          getValue: (List<E> c) => c.reversed,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_List(List<E> context) : super(context);
}

String _render_String(String context, List<MustachioNode> ast) {
  var renderer = _Renderer_String(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_String extends RendererBase<String> {
  static Map<String, Property<String>> propertyMap() => {
        'codeUnits': Property(
          getValue: (String c) => c.codeUnits,
        ),
        'hashCode': Property(
          getValue: (String c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEmpty': Property(
          getValue: (String c) => c.isEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (String c) => c.isEmpty == true,
        ),
        'isNotEmpty': Property(
          getValue: (String c) => c.isNotEmpty,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (String c) => c.isNotEmpty == true,
        ),
        'length': Property(
          getValue: (String c) => c.length,
          getProperties: _Renderer_int.propertyMap,
        ),
        'runes': Property(
          getValue: (String c) => c.runes,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_String(String context) : super(context);
}

String _render_TemplateData<T extends Documentable>(
    TemplateData<T> context, List<MustachioNode> ast) {
  var renderer = _Renderer_TemplateData(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateData<T extends Documentable>
    extends RendererBase<TemplateData<T>> {
  static Map<String, Property<TemplateData<T>>>
      propertyMap<T extends Documentable>() => {
            'bareHref': Property(
              getValue: (TemplateData<T> c) => c.bareHref,
              getProperties: _Renderer_String.propertyMap,
            ),
            'defaultPackage': Property(
              getValue: (TemplateData<T> c) => c.defaultPackage,
              getProperties: _Renderer_Package.propertyMap,
            ),
            'hasFooterVersion': Property(
              getValue: (TemplateData<T> c) => c.hasFooterVersion,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (TemplateData<T> c) => c.hasFooterVersion == true,
            ),
            'hasHomepage': Property(
              getValue: (TemplateData<T> c) => c.hasHomepage,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (TemplateData<T> c) => c.hasHomepage == true,
            ),
            'homepage': Property(
              getValue: (TemplateData<T> c) => c.homepage,
              getProperties: _Renderer_String.propertyMap,
            ),
            'htmlBase': Property(
              getValue: (TemplateData<T> c) => c.htmlBase,
              getProperties: _Renderer_String.propertyMap,
            ),
            'htmlOptions': Property(
              getValue: (TemplateData<T> c) => c.htmlOptions,
              getProperties: _Renderer_TemplateOptions.propertyMap,
            ),
            'includeVersion': Property(
              getValue: (TemplateData<T> c) => c.includeVersion,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (TemplateData<T> c) => c.includeVersion == true,
            ),
            'layoutTitle': Property(
              getValue: (TemplateData<T> c) => c.layoutTitle,
              getProperties: _Renderer_String.propertyMap,
            ),
            'localPackages': Property(
              getValue: (TemplateData<T> c) => c.localPackages,
            ),
            'metaDescription': Property(
              getValue: (TemplateData<T> c) => c.metaDescription,
              getProperties: _Renderer_String.propertyMap,
            ),
            'navLinks': Property(
              getValue: (TemplateData<T> c) => c.navLinks,
            ),
            'navLinksWithGenerics': Property(
              getValue: (TemplateData<T> c) => c.navLinksWithGenerics,
            ),
            'parent': Property(
              getValue: (TemplateData<T> c) => c.parent,
              getProperties: _Renderer_Documentable.propertyMap,
            ),
            'relCanonicalPrefix': Property(
              getValue: (TemplateData<T> c) => c.relCanonicalPrefix,
              getProperties: _Renderer_String.propertyMap,
            ),
            'self': Property(
              getValue: (TemplateData<T> c) => c.self,
            ),
            'title': Property(
              getValue: (TemplateData<T> c) => c.title,
              getProperties: _Renderer_String.propertyMap,
            ),
            'useBaseHref': Property(
              getValue: (TemplateData<T> c) => c.useBaseHref,
              getProperties: _Renderer_bool.propertyMap,
              getBool: (TemplateData<T> c) => c.useBaseHref == true,
            ),
            'version': Property(
              getValue: (TemplateData<T> c) => c.version,
              getProperties: _Renderer_String.propertyMap,
            ),
            ..._Renderer_Object.propertyMap(),
          };

  _Renderer_TemplateData(TemplateData<T> context) : super(context);
}

String _render_TemplateOptions(
    TemplateOptions context, List<MustachioNode> ast) {
  var renderer = _Renderer_TemplateOptions(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateOptions extends RendererBase<TemplateOptions> {
  static Map<String, Property<TemplateOptions>> propertyMap() => {
        'relCanonicalPrefix': Property(
          getValue: (TemplateOptions c) => c.relCanonicalPrefix,
          getProperties: _Renderer_String.propertyMap,
        ),
        'toolVersion': Property(
          getValue: (TemplateOptions c) => c.toolVersion,
          getProperties: _Renderer_String.propertyMap,
        ),
        'useBaseHref': Property(
          getValue: (TemplateOptions c) => c.useBaseHref,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (TemplateOptions c) => c.useBaseHref == true,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_TemplateOptions(TemplateOptions context) : super(context);
}

String _render_Documentable(Documentable context, List<MustachioNode> ast) {
  var renderer = _Renderer_Documentable(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Documentable extends RendererBase<Documentable> {
  static Map<String, Property<Documentable>> propertyMap() => {
        'config': Property(
          getValue: (Documentable c) => c.config,
        ),
        'documentation': Property(
          getValue: (Documentable c) => c.documentation,
          getProperties: _Renderer_String.propertyMap,
        ),
        'documentationAsHtml': Property(
          getValue: (Documentable c) => c.documentationAsHtml,
          getProperties: _Renderer_String.propertyMap,
        ),
        'hasDocumentation': Property(
          getValue: (Documentable c) => c.hasDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Documentable c) => c.hasDocumentation == true,
        ),
        'hasExtendedDocumentation': Property(
          getValue: (Documentable c) => c.hasExtendedDocumentation,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Documentable c) => c.hasExtendedDocumentation == true,
        ),
        'href': Property(
          getValue: (Documentable c) => c.href,
          getProperties: _Renderer_String.propertyMap,
        ),
        'isDocumented': Property(
          getValue: (Documentable c) => c.isDocumented,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (Documentable c) => c.isDocumented == true,
        ),
        'kind': Property(
          getValue: (Documentable c) => c.kind,
          getProperties: _Renderer_String.propertyMap,
        ),
        'oneLineDoc': Property(
          getValue: (Documentable c) => c.oneLineDoc,
          getProperties: _Renderer_String.propertyMap,
        ),
        'packageGraph': Property(
          getValue: (Documentable c) => c.packageGraph,
        ),
        ..._Renderer_Nameable.propertyMap(),
      };

  _Renderer_Documentable(Documentable context) : super(context);
}

String _render_Nameable(Nameable context, List<MustachioNode> ast) {
  var renderer = _Renderer_Nameable(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Nameable extends RendererBase<Nameable> {
  static Map<String, Property<Nameable>> propertyMap() => {
        'fullyQualifiedName': Property(
          getValue: (Nameable c) => c.fullyQualifiedName,
          getProperties: _Renderer_String.propertyMap,
        ),
        'name': Property(
          getValue: (Nameable c) => c.name,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePart': Property(
          getValue: (Nameable c) => c.namePart,
          getProperties: _Renderer_String.propertyMap,
        ),
        'namePieces': Property(
          getValue: (Nameable c) => c.namePieces,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_Nameable(Nameable context) : super(context);
}

String _render_int(int context, List<MustachioNode> ast) {
  var renderer = _Renderer_int(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_int extends RendererBase<int> {
  static Map<String, Property<int>> propertyMap() => {
        'bitLength': Property(
          getValue: (int c) => c.bitLength,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isEven': Property(
          getValue: (int c) => c.isEven,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (int c) => c.isEven == true,
        ),
        'isOdd': Property(
          getValue: (int c) => c.isOdd,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (int c) => c.isOdd == true,
        ),
        'sign': Property(
          getValue: (int c) => c.sign,
          getProperties: _Renderer_int.propertyMap,
        ),
        ..._Renderer_num.propertyMap(),
      };

  _Renderer_int(int context) : super(context);
}

String _render_num(num context, List<MustachioNode> ast) {
  var renderer = _Renderer_num(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_num extends RendererBase<num> {
  static Map<String, Property<num>> propertyMap() => {
        'hashCode': Property(
          getValue: (num c) => c.hashCode,
          getProperties: _Renderer_int.propertyMap,
        ),
        'isFinite': Property(
          getValue: (num c) => c.isFinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (num c) => c.isFinite == true,
        ),
        'isInfinite': Property(
          getValue: (num c) => c.isInfinite,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (num c) => c.isInfinite == true,
        ),
        'isNaN': Property(
          getValue: (num c) => c.isNaN,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (num c) => c.isNaN == true,
        ),
        'isNegative': Property(
          getValue: (num c) => c.isNegative,
          getProperties: _Renderer_bool.propertyMap,
          getBool: (num c) => c.isNegative == true,
        ),
        'sign': Property(
          getValue: (num c) => c.sign,
          getProperties: _Renderer_num.propertyMap,
        ),
        ..._Renderer_Object.propertyMap(),
      };

  _Renderer_num(num context) : super(context);
}
