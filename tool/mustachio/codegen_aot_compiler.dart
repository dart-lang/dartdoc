// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'utilities.dart';

/// Compiles all templates specified in [specs] into a Dart library containing
/// a renderer for each template.
Future<String> compileTemplatesToRenderers(
  Set<RendererSpec> specs,
  Uri sourceUri,
  BuildStep buildStep,
  TypeProvider typeProvider,
  TypeSystem typeSystem,
  TemplateFormat format,
) async {
  var buffer = StringBuffer('''
// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable

// It is hard to track exact imports without using package:code_builder.
// ignore_for_file: unused_import

import 'dart:convert' show htmlEscape;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import '${p.basename(sourceUri.path)}';
''');
  var buildData = _BuildData(buildStep, typeProvider, typeSystem, format);
  for (var spec in specs) {
    var templateUri = spec.standardTemplateUris[format];
    if (templateUri == null) continue;
    var templateAsset = templateUri.isAbsolute
        ? AssetId.resolve(templateUri)
        : AssetId.resolve(templateUri, from: buildStep.inputId);
    var compiler = await _AotCompiler._readAndParse(
      spec.contextType,
      spec.name,
      templateAsset,
      buildData,
      buffer,
    );
    await compiler._compileToRenderer();
  }
  return DartFormatter().format(buffer.toString());
}

/// A class which compiles a single template file into a renderer Dart function,
/// and possible support functions for partial templates.
class _AotCompiler {
  /// The template to be compiled.
  final AssetId _templateAssetId;

  /// The context type which is to be rendered into the compiled template.
  final InterfaceType _contextType;

  /// The name of the renderer, which is either a public name (for top-level
  /// renderers specified in a `@Renderer` annotation), or a private name for
  /// a partial.
  final String _rendererName;

  final _BuildData _buildData;

  /// The parsed syntax tree of the template at [_templateAssetId].
  final List<MustachioNode> _syntaxTree;

  /// The output buffer into which the various renderer source code is to be
  /// written.
  final StringBuffer _buffer;

  /// The set of compilers for all referenced partials.
  final Set<_AotCompiler> _partialCompilers = {};

  /// The current stack of context objects (as variable lookups).
  final List<_VariableLookup> _contextStack;

  /// A counter for naming partial render functions.
  ///
  /// Incrementing the counter keeps names unique.
  int _partialCounter = 0;

  /// A counter for naming context variables.
  ///
  /// Incrementing the counter keeps names unique.
  int _contextNameCounter;

  /// Reads the template at [templateAssetId] and parses it into a syntax tree,
  /// returning an [_AotCompiler] with the necessary information to be able to
  /// compile the template into a renderer.
  static Future<_AotCompiler> _readAndParse(
    InterfaceType contextType,
    String rendererName,
    AssetId templateAssetId,
    _BuildData buildData,
    StringBuffer buffer, {
    List<_VariableLookup> contextStack,
  }) async {
    var template = await buildData._buildStep.readAsString(templateAssetId);
    var syntaxTree = MustachioParser(template, templateAssetId.uri).parse();
    return _AotCompiler._(contextType, rendererName, templateAssetId,
        syntaxTree, buildData, buffer,
        contextStack: contextStack);
  }

  _AotCompiler._(
    this._contextType,
    this._rendererName,
    this._templateAssetId,
    this._syntaxTree,
    this._buildData,
    this._buffer, {
    List<_VariableLookup> contextStack,
  })  : _contextStack = _rename(contextStack ?? []),
        _contextNameCounter = contextStack?.length ?? 0;

  /// Returns a copy of [original], replacing each variable's name with
  /// `context0` through `contextN` for `N` variables.
  ///
  /// This ensures that each renderer accepts a simple list of context objects
  /// with predictable names.
  static List<_VariableLookup> _rename(List<_VariableLookup> original) {
    var result = <_VariableLookup>[];
    var index = original.length - 1;
    for (var variable in original) {
      result.push(_VariableLookup(variable.type, 'context$index'));
      index--;
    }
    return [...result.reversed];
  }

  Future<void> _compileToRenderer() async {
    if (_contextStack.isEmpty) {
      var contextName = 'context0';
      var contextVariable = _VariableLookup(_contextType, contextName);
      _contextStack.push(contextVariable);
      _contextNameCounter++;
    }

    // Get the type parameters of _each_ of the context types in the stack,
    // including their bounds, concatenate them, and wrap them in angle
    // brackets.
    // TODO(srawlins): This will produce erroneous code if any two context types
    // have type parameters with the same name. Something like:
    //     _renderFoo_partial_bar_1<T, T>(Baz<T> context1, Foo<T> context0)
    // Rename type parameters to some predictable collision-free naming scheme;
    // the body of the function should not reference the type parameters, so
    // this should be perfectly possible.
    var typeParametersString = asGenerics([
      for (var context in _contextStack)
        ...context.type.element.typeParameters
            .map((tp) => tp.getDisplayString(withNullability: false)),
    ]);
    _buffer.writeln('String $_rendererName$typeParametersString(');
    _buffer.writeln(_contextStack.map((context) {
      var contextElement = context.type.element;
      var contextTypeName = contextElement.displayName;
      var typeVariablesString = contextElement.typeVariablesString;
      return '$contextTypeName$typeVariablesString ${context.name}';
    }).join(','));
    _buffer.writeln(') {');
    _buffer.writeln('  final buffer = StringBuffer();');
    await _BlockCompiler(this, _contextStack)._compile(_syntaxTree);
    _buffer.writeln('  return buffer.toString();');
    _buffer.writeln('}');

    for (var partialRenderer in _partialCompilers) {
      await partialRenderer._compileToRenderer();
      _buffer.write(partialRenderer._buffer.toString());
    }
  }
}

/// A class which can compile a Mustache block of nodes into Dart source for a
/// renderer.
class _BlockCompiler {
  final _AotCompiler _templateCompiler;

  final List<_VariableLookup> _contextStack;

  _BlockCompiler(this._templateCompiler, this._contextStack);

  void write(String text) => _templateCompiler._buffer.write(text);

  void writeln(String text) => _templateCompiler._buffer.writeln(text);

  InterfaceType get contextType => _contextStack.first.type;

  String get contextName => _contextStack.first.name;

  TemplateFormat get format => _templateCompiler._buildData._format;

  TypeProvider get typeProvider => _templateCompiler._buildData._typeProvider;

  TypeSystem get typeSystem => _templateCompiler._buildData._typeSystem;

  /// Generates a new name for a context variable. Each context variable going
  /// up the stack needs to be accessible, so they each need a unique variable
  /// name.
  String getNewContextName() {
    var newContextName = 'context${_templateCompiler._contextNameCounter}';
    _templateCompiler._contextNameCounter++;
    return newContextName;
  }

  /// The base name of a partial rendering function.
  String get partialBaseName => '_${_templateCompiler._rendererName}_partial';

  Future<void> _compile(List<MustachioNode> syntaxTree) async {
    for (var node in syntaxTree) {
      if (node is Text) {
        _writeText(node.content);
      } else if (node is Variable) {
        var variableLookup = _lookUpGetter(node);
        _writeGetter(variableLookup, escape: node.escape);
      } else if (node is Section) {
        await _compileSection(node);
      } else if (node is Partial) {
        await _compilePartial(node);
      }
    }
  }

  /// Compiles [node] into a renderer's Dart source.
  Future<void> _compilePartial(Partial node) async {
    var extension = format == TemplateFormat.html ? 'html' : 'md';
    var partialAssetId = AssetId.resolve(Uri.parse('_${node.key}.$extension'),
        from: _templateCompiler._templateAssetId);
    var partialRenderer = _templateCompiler._partialCompilers.firstWhere(
        (p) => p._templateAssetId == partialAssetId,
        orElse: () => null);
    if (partialRenderer == null) {
      var name =
          '${partialBaseName}_${node.key}_${_templateCompiler._partialCounter}';
      partialRenderer = await _AotCompiler._readAndParse(contextType, name,
          partialAssetId, _templateCompiler._buildData, StringBuffer(),
          contextStack: _contextStack);
      // Add this partial renderer; to be written later.
      _templateCompiler._partialCompilers.add(partialRenderer);
      _templateCompiler._partialCounter++;
    }
    // Call the partial's renderer function here; the definition of the renderer
    // function is written later.
    write('buffer.write(');
    writeln('${partialRenderer._rendererName}(');
    writeln(_contextStack.map((context) => context.name).join(','));
    writeln('));');
  }

  /// Compiles [node] into a renderer's Dart source.
  Future<void> _compileSection(Section node) async {
    var variableLookup = _lookUpGetter(node);
    if (variableLookup == null) {
      throw MustachioResolutionError(node.keySpan.message(
          "Failed to resolve '${node.key}' as a property on the context type:"
          '$contextType'));
    }
    if (variableLookup.type.isDartCoreBool) {
      // Conditional block.
      await _compileConditionalSection(variableLookup, node.children,
          invert: node.invert);
    } else if (typeSystem.isAssignableTo(
        variableLookup.type, typeProvider.iterableDynamicType)) {
      // Repeated block.
      await _compileRepeatedSection(variableLookup, node.children,
          invert: node.invert);
    } else {
      // Use accessor value as context.
      await _compileValueSection(variableLookup, node.children,
          invert: node.invert);
    }
  }

  /// Compiles a conditional section containing [block] into a renderer's Dart
  /// source.
  Future<void> _compileConditionalSection(
      _VariableLookup variableLookup, List<MustachioNode> block,
      {bool invert = false}) async {
    var variableAccess = variableLookup.name;
    if (invert) {
      writeln('if ($variableAccess != true) {');
    } else {
      writeln('if ($variableAccess == true) {');
    }
    await _BlockCompiler(_templateCompiler, _contextStack)._compile(block);
    writeln('}');
  }

  /// Compiles a repeated section containing [block] into a renderer's Dart
  /// source.
  Future<void> _compileRepeatedSection(
      _VariableLookup variableLookup, List<MustachioNode> block,
      {bool invert = false}) async {
    var variableAccess = variableLookup.name;
    if (invert) {
      writeln('if ($variableAccess?.isEmpty ?? true) {');
      await _compile(block);
      writeln('}');
    } else {
      var variableAccessResult = getNewContextName();
      writeln('var $variableAccessResult = $variableAccess;');
      var newContextName = getNewContextName();
      writeln('if ($variableAccessResult != null) {');
      writeln('  for (var $newContextName in $variableAccessResult) {');
      // If [loopType] is something like `C<int>` where
      // `class C<T> implements Queue<Future<T>>`, we need the [ClassElement]
      // for [Iterable], and then use [DartType.asInstanceOf] to ultimately
      // determine that the inner type of the loop is, for example,
      // `Future<int>`.
      var iterableElement = typeProvider.iterableElement;
      var iterableType = variableLookup.type.asInstanceOf(iterableElement);
      var innerContextType = iterableType.typeArguments.first;
      var innerContext = _VariableLookup(innerContextType, newContextName);
      _contextStack.push(innerContext);
      await _compile(block);
      _contextStack.pop();
      writeln('  }');
      writeln('}');
    }
  }

  /// Compiles a value section containing [block] into a renderer's Dart source.
  Future<void> _compileValueSection(
      _VariableLookup variableLookup, List<MustachioNode> block,
      {bool invert = false}) async {
    var variableAccess = variableLookup.name;
    if (invert) {
      writeln('if ($variableAccess == null) {');
      await _compile(block);
      writeln('}');
    } else {
      var innerContextName = getNewContextName();
      writeln('var $innerContextName = $variableAccess;');
      writeln('if ($innerContextName != null) {');
      var innerContext = _VariableLookup(variableLookup.type, innerContextName);
      _contextStack.push(innerContext);
      await _compile(block);
      _contextStack.pop();
      writeln('}');
    }
  }

  /// Returns a valid [_VariableLookup] on a Mustache node, [node] by resolving
  /// its key.
  _VariableLookup _lookUpGetter(HasMultiNamedKey node) {
    var key = node.key;

    // '.' is an entirely special case.
    if (key.length == 1 && key[0] == '.') {
      return _VariableLookup(contextType, contextName);
    }

    var primaryName = key[0];

    for (var context in _contextStack) {
      var getter =
          context.type.lookUpGetter2(primaryName, contextType.element.library);
      if (getter == null) {
        continue;
      }

      var type = getter.returnType;
      var contextChain = '${context.name}.$primaryName';
      var remainingNames = [...key.skip(1)];
      for (var secondaryKey in remainingNames) {
        getter = (type as InterfaceType)
            .lookUpGetter2(secondaryKey, type.element.library);
        if (getter == null) {
          throw MustachioResolutionError(node.keySpan.message(
              "Failed to resolve '$secondaryKey' on ${context.type} while "
              'resolving $remainingNames as a property chain on any types in '
              'the context chain: $contextChain, after first resolving '
              "'$primaryName' to a property on $type"));
        }
        type = getter.returnType;
        contextChain = '$contextChain.$secondaryKey';
      }
      return _VariableLookup(type, contextChain);
    }

    var contextTypes = [
      for (var c in _contextStack) c.type,
    ];
    throw MustachioResolutionError(node.keySpan
        .message("Failed to resolve '$key' as a property on any types in the "
            'context chain: $contextTypes'));
  }

  /// Writes [content] to the generated render functions as text, properly
  /// handling newlines, quotes, and other special characters.
  void _writeText(String content) {
    if (content.isEmpty) return;
    if (content == '\n') {
      // Blank lines happen a lot; just indicate them as such.
      writeln('buffer.writeln();');
    } else {
      content = content.replaceAll("'", "\\'").replaceAll(r'$', r'\\$');
      if (RegExp('^[ \\n]+\$').hasMatch(content)) {
        write("buffer.write('");
        write(content.replaceAll('\n', '\\n'));
        writeln("');");
      } else {
        write("buffer.write('''");
        write(content);
        writeln("''');");
      }
    }
  }

  /// Writes a call to [variableLookup] to the renderer.
  ///
  /// The result is HTML-escaped if [escape] is true.
  void _writeGetter(_VariableLookup variableLookup, {bool escape = true}) {
    var variableAccess = variableLookup.name;
    if (escape) {
      writeln('buffer.write(htmlEscape.convert('
          '$variableAccess.toString()));');
    } else {
      writeln('buffer.write($variableAccess.toString());');
    }
  }
}

/// Various static build data to be used for each renderer, including specified
/// renderers and template renderers.
@immutable
class _BuildData {
  final BuildStep _buildStep;

  final TypeProvider _typeProvider;

  final TypeSystem _typeSystem;

  final TemplateFormat _format;

  _BuildData(
      this._buildStep, this._typeProvider, this._typeSystem, this._format);
}

/// Represents a variable lookup via property access chain [name] which returns
/// an object of type [type].
@immutable
class _VariableLookup {
  final InterfaceType type;

  final String name;

  _VariableLookup(this.type, this.name);
}

extension<T> on List<T> {
  void push(T value) => insert(0, value);

  T pop() => removeAt(0);
}
