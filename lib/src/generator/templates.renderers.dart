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
  _Renderer_PackageTemplateData(PackageTemplateData context) : super(context);
}

String _render_Package(Package context, List<MustachioNode> ast) {
  var renderer = _Renderer_Package(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Package extends RendererBase<Package> {
  _Renderer_Package(Package context) : super(context);
}

String _render_LibraryContainer(
    LibraryContainer context, List<MustachioNode> ast) {
  var renderer = _Renderer_LibraryContainer(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_LibraryContainer extends RendererBase<LibraryContainer> {
  _Renderer_LibraryContainer(LibraryContainer context) : super(context);
}

String _render_Object(Object context, List<MustachioNode> ast) {
  var renderer = _Renderer_Object(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Object extends RendererBase<Object> {
  _Renderer_Object(Object context) : super(context);
}

String _render_bool(bool context, List<MustachioNode> ast) {
  var renderer = _Renderer_bool(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_bool extends RendererBase<bool> {
  _Renderer_bool(bool context) : super(context);
}

String _render_List<E>(List<E> context, List<MustachioNode> ast) {
  var renderer = _Renderer_List(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_List<E> extends RendererBase<List<E>> {
  _Renderer_List(List<E> context) : super(context);
}

String _render_String(String context, List<MustachioNode> ast) {
  var renderer = _Renderer_String(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_String extends RendererBase<String> {
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
  _Renderer_TemplateData(TemplateData<T> context) : super(context);
}

String _render_TemplateOptions(
    TemplateOptions context, List<MustachioNode> ast) {
  var renderer = _Renderer_TemplateOptions(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_TemplateOptions extends RendererBase<TemplateOptions> {
  _Renderer_TemplateOptions(TemplateOptions context) : super(context);
}

String _render_Documentable(Documentable context, List<MustachioNode> ast) {
  var renderer = _Renderer_Documentable(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Documentable extends RendererBase<Documentable> {
  _Renderer_Documentable(Documentable context) : super(context);
}

String _render_Nameable(Nameable context, List<MustachioNode> ast) {
  var renderer = _Renderer_Nameable(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Nameable extends RendererBase<Nameable> {
  _Renderer_Nameable(Nameable context) : super(context);
}

String _render_int(int context, List<MustachioNode> ast) {
  var renderer = _Renderer_int(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_int extends RendererBase<int> {
  _Renderer_int(int context) : super(context);
}

String _render_num(num context, List<MustachioNode> ast) {
  var renderer = _Renderer_num(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_num extends RendererBase<num> {
  _Renderer_num(num context) : super(context);
}

String _render_Type(Type context, List<MustachioNode> ast) {
  var renderer = _Renderer_Type(context);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class _Renderer_Type extends RendererBase<Type> {
  _Renderer_Type(Type context) : super(context);
}
