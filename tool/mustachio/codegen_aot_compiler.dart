// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_provider.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:build/build.dart';
import 'package:code_builder/code_builder.dart';
import 'package:collection/collection.dart';
import 'package:dart_style/dart_style.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:dartdoc/src/mustachio/parser.dart';
import 'package:dartdoc/src/mustachio/renderer_base.dart';
import 'package:dartdoc/src/type_utils.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

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
  var buildData = _BuildData(buildStep, typeProvider, typeSystem, format);
  var rendererFunctions = <Method>[];
  var partialRendererFunctions = <_AotCompiler, Method>{};
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
    );
    rendererFunctions.add(await compiler._compileToRenderer());
    partialRendererFunctions.addAll(compiler._compiledPartials);
  }
  partialRendererFunctions =
      await _deduplicateRenderers(partialRendererFunctions, typeSystem);

  var library = Library((b) {
    b.body.addAll(rendererFunctions);
    b.body.addAll(partialRendererFunctions.values);
    b.body.add(Extension((b) => b
      ..on = refer('StringBuffer')
      ..methods.add(Method((b) => b
        ..returns = refer('void')
        ..name = 'writeEscaped'
        ..requiredParameters.add(Parameter((b) => b
          ..type = refer('String?')
          ..name = 'value'))
        ..body = refer('write').call([
          refer('htmlEscape', 'dart:convert')
              .property('convert')
              .call([refer("value ?? ''")])
        ]).statement))));
  });
  return DartFormatter().format('''
// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// There are a few deduplicated render functions which are generated but not
// used.
// TODO(srawlins): Detect these and do not write them.
// ignore_for_file: unused_element
// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable
// ignore_for_file: non_constant_identifier_names, unnecessary_string_escapes
// ignore_for_file: use_super_parameters

${library.accept(DartEmitter.scoped(orderDirectives: true))}
''');
}

/// Deduplicates multiple renderers which are each used to render a partial
/// into a single renderer.
///
/// When a partial is referenced by more than one template, multiple compilers
/// are used to build multiple render functions, because the context stack of
/// types may be different in each case. But it is perfectly logical to expect
/// that these can be deduplicated, as they should be able to use one common
/// context stack of interfaces.
///
/// Attempts to deduplicate the compilers (which build the renderers) by
/// replacing context types in each stack with their collective LUB.
Future<Map<_AotCompiler, Method>> _deduplicateRenderers(
  Map<_AotCompiler, Method> partialRendererFunctions,
  TypeSystem typeSystem,
) async {
  // Map each template (represented by its [AssetId]) to the list of compilers
  // which compile it to a renderer function.
  var compilersPerPartial = <AssetId, List<_AotCompiler>>{};
  for (var compiler in partialRendererFunctions.keys) {
    compilersPerPartial
        .putIfAbsent(compiler._templateAssetId, () => [])
        .add(compiler);
  }
  var partialsToRemove = <_AotCompiler>{};
  for (var assetId in compilersPerPartial.keys) {
    var compilers = compilersPerPartial[assetId]!;
    if (compilers.length < 2) {
      // Nothing to deduplicate.
      continue;
    }
    var firstCompiler = compilers.first;
    var contextStacksLength = firstCompiler._usedContexts.length;
    if (compilers.any((c) => c._usedContexts.length != contextStacksLength)) {
      // The stack lengths are different, it is impossible to deduplicate such
      // partial renderers.
      continue;
    }
    // The new list of context types, each of which is the LUB of the associated
    // context type of each of the compilers.
    var contextStackTypes = <InterfaceType>[];
    for (var i = 0; i < contextStacksLength; i++) {
      var types = compilers.map((c) => c._usedContextStack[i].type);
      var lubType = types.fold<DartType>(types.first,
              (value, type) => typeSystem.leastUpperBound(value, type))
          as InterfaceType;
      contextStackTypes.add(lubType);
    }

    // Each of the render functions generated by a compiler for this asset can
    // be replaced by a more generic renderer which accepts the LUB types. The
    // body of each replaced renderer can perform a simple redirect.
    var rendererName = assetId.path.replaceAll('.', '_').replaceAll('/', '_');
    var lubCompiler = _AotCompiler._(
      contextStackTypes.first,
      '_deduplicated_$rendererName',
      assetId,
      firstCompiler._syntaxTree,
      firstCompiler._buildData,
      contextStack: [
        ...contextStackTypes.map((t) => _VariableLookup(t, 'UNUSED'))
      ],
    );
    Method compiledLubRenderer;
    try {
      compiledLubRenderer = await lubCompiler._compileToRenderer();
      // ignore: avoid_catching_errors
    } on MustachioResolutionError {
      // Oops, switching to the LUB type prevents the renderer from compiling;
      // likely the properties accessed in the partial are not all declared on
      // the LUB type.
      var names = compilers.map((c) => c._rendererName);
      print('Could not deduplicate ${assetId.path} ${names.join(', ')}');
      continue;
    }

    void removeUnusedPartials(_AotCompiler c) {
      for (var p in c._partialCompilers) {
        removeUnusedPartials(p);
      }
      partialsToRemove.add(c);
    }

    for (var compiler in compilers) {
      partialRendererFunctions[compiler] =
          await _redirectingMethod(compiler, lubCompiler);

      for (var c in compiler._partialCompilers) {
        removeUnusedPartials(c);
      }
    }
    partialRendererFunctions[lubCompiler] = compiledLubRenderer;
    partialRendererFunctions.addAll(lubCompiler._compiledPartials);
  }
  for (var c in partialsToRemove) {
    partialRendererFunctions.remove(c);
  }

  return partialRendererFunctions;
}

/// Returns a method body for the render function for [compiler], which simply
/// redirects to the render function for [lubCompiler].
Future<Method> _redirectingMethod(
    _AotCompiler compiler, _AotCompiler lubCompiler) async {
  var typeParameters = <TypeReference>[];
  for (var context in compiler._usedContextStack) {
    for (var typeParameter in context.type.element.typeParameters) {
      var bound = typeParameter.bound;
      if (bound == null) {
        typeParameters
            .add(TypeReference((b) => b..symbol = typeParameter.name));
      } else {
        var boundElement = DartTypeExtension(bound).element!;
        var boundUri = await compiler._elementUri(boundElement);
        typeParameters.add(TypeReference((b) => b
          ..symbol = typeParameter.name
          ..bound = refer(boundElement.name!, boundUri)));
      }
    }
  }

  var parameters = <Parameter>[];
  for (var context in compiler._usedContextStack) {
    var contextElement = context.type.element;
    var contextElementUri = await compiler._elementUri(contextElement);
    parameters.add(Parameter((b) => b
      ..type = TypeReference((b) => b
        ..symbol = contextElement.displayName
        ..url = contextElementUri
        ..types
            .addAll(contextElement.typeParameters.map((tp) => refer(tp.name))))
      ..name = context.name));
  }
  var arguments = parameters.map((p) => refer(p.name));
  return Method((b) => b
    ..returns = refer('String')
    ..name = compiler._rendererName
    ..types.addAll(typeParameters)
    ..requiredParameters.addAll(parameters)
    ..body = refer(lubCompiler._rendererName).call(arguments).code);
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

  /// The set of compilers for all referenced partials.
  ///
  /// This field is only complete after [_compileToRenderer] has run.
  final Set<_AotCompiler> _partialCompilers = {};

  final Map<_AotCompiler, Method> _compiledPartials = {};

  /// The current stack of context objects (as variable lookups).
  final List<_VariableLookup> _contextStack;

  /// The set of context objects which are ultimately used by this compiler.
  final Set<_VariableLookup> _usedContexts = {};

  List<_VariableLookup> get _usedContextStack =>
      [..._contextStack.where(_usedContexts.contains)];

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
    _BuildData buildData, {
    List<_VariableLookup> contextStack = const [],
  }) async {
    var template = await buildData._buildStep.readAsString(templateAssetId);
    var syntaxTree = MustachioParser(template, templateAssetId.uri).parse();
    return _AotCompiler._(
        contextType, rendererName, templateAssetId, syntaxTree, buildData,
        contextStack: contextStack);
  }

  _AotCompiler._(
    this._contextType,
    this._rendererName,
    this._templateAssetId,
    this._syntaxTree,
    this._buildData, {
    required List<_VariableLookup> contextStack,
  })  : _contextStack = _rename(contextStack),
        _contextNameCounter = contextStack.length;

  /// Returns a copy of [original], replacing each variable's name with
  /// `context0` through `contextN` for `N` variables.
  ///
  /// This ensures that each renderer accepts a simple list of context objects
  /// with predictable names.
  static List<_VariableLookup> _rename(List<_VariableLookup> original) {
    var result = <_VariableLookup>[];
    var index = original.length - 1;
    for (var variable in original) {
      result.push(_VariableLookup(variable.type, 'context$index',
          indexInParent: original.indexOf(variable)));
      index--;
    }
    return [...result.reversed];
  }

  Future<Method> _compileToRenderer() async {
    if (_contextStack.isEmpty) {
      var contextVariable = _VariableLookup(_contextType, 'context0');
      _contextStack.push(contextVariable);
      _contextNameCounter++;
    }

    var blockCompiler = _BlockCompiler(this, _contextStack);
    await blockCompiler._compile(_syntaxTree);
    var rendererBody = blockCompiler._buffer.toString();
    _usedContexts.addAll(_contextStack
        .where((c) => blockCompiler._usedContextTypes.contains(c)));

    // Get the type parameters of _each_ of the context types in the stack,
    // including their bounds, concatenate them, and wrap them in angle
    // brackets.
    // TODO(srawlins): This will produce erroneous code if any two context types
    // have type parameters with the same name. Something like:
    //     _renderFoo_partial_bar_1<T, T>(Baz<T> context1, Foo<T> context0)
    // Rename type parameters to some predictable collision-free naming scheme;
    // the body of the function should not reference the type parameters, so
    // this should be perfectly possible.
    var typeParameters = <TypeReference>[];
    for (var context in _usedContexts) {
      for (var typeParameter in context.type.element.typeParameters) {
        var bound = typeParameter.bound;
        if (bound == null) {
          typeParameters
              .add(TypeReference((b) => b..symbol = typeParameter.name));
        } else {
          var boundElement = DartTypeExtension(bound).element!;
          var boundUri = await _elementUri(boundElement);
          typeParameters.add(TypeReference((b) => b
            ..symbol = typeParameter.name
            ..bound = refer(boundElement.name!, boundUri)));
        }
      }
    }

    var parameters = <Parameter>[];
    for (var context in _usedContexts) {
      var contextElement = context.type.element;
      var contextElementUri = await _elementUri(contextElement);
      parameters.add(Parameter((b) => b
        ..type = TypeReference((b) => b
          ..symbol = contextElement.displayName
          ..url = contextElementUri
          ..types.addAll(
              contextElement.typeParameters.map((tp) => refer(tp.name))))
        ..name = context.name));
    }

    var renderFunction = Method((b) => b
      ..returns = refer('String')
      ..name = _rendererName
      ..types.addAll(typeParameters)
      ..requiredParameters.addAll(parameters)
      ..body = Code('''
final buffer = StringBuffer();
$rendererBody
return buffer.toString();
'''));

    return renderFunction;
  }

  /// Returns the URI of [element] for use in generated import directives.
  Future<String> _elementUri(Element element) async {
    var libraryElement = element.library!;
    if (libraryElement.isInSdk) {
      return libraryElement.source.uri.toString();
    }

    var typeAssetId =
        await _buildData._buildStep.resolver.assetIdForElement(libraryElement);
    if (typeAssetId.path.startsWith('lib/')) {
      return typeAssetId.uri.toString();
    } else {
      var entryAssetId = await _buildData._buildStep.resolver
          .assetIdForElement(await _buildData._buildStep.inputLibrary);
      return p.relative(typeAssetId.path, from: p.dirname(entryAssetId.path));
    }
  }
}

/// A class which can compile a Mustache block of nodes into Dart source for a
/// renderer.
class _BlockCompiler {
  final _AotCompiler _templateCompiler;

  final List<_VariableLookup> _contextStack;

  final Set<_VariableLookup> _usedContextTypes = {};

  final _buffer = StringBuffer();

  _BlockCompiler(this._templateCompiler, this._contextStack);

  void write(String text) => _buffer.write(text);

  void writeln(String text) => _buffer.writeln(text);

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
    var path = node.key.split('/');
    var fileName = path.removeLast();
    path.add('_$fileName.$extension');
    var partialAssetId = AssetId.resolve(Uri.parse(path.join('/')),
        from: _templateCompiler._templateAssetId);
    var partialCompiler = _templateCompiler._partialCompilers
        .firstWhereOrNull((p) => p._templateAssetId == partialAssetId);
    if (partialCompiler == null) {
      var sanitizedKey = node.key.replaceAll('.', '_').replaceAll('/', '_');
      var name = '${partialBaseName}_'
          '${sanitizedKey}_'
          '${_templateCompiler._partialCounter}';
      partialCompiler = await _AotCompiler._readAndParse(
          contextType, name, partialAssetId, _templateCompiler._buildData,
          contextStack: _contextStack);
      // Add this partial renderer; to be written later.
      _templateCompiler._partialCompilers.add(partialCompiler);
      _templateCompiler._partialCounter++;
      _templateCompiler._compiledPartials[partialCompiler] =
          await partialCompiler._compileToRenderer();
      _templateCompiler._compiledPartials
          .addAll(partialCompiler._compiledPartials);
    }
    // Call the partial's renderer function here; the definition of the renderer
    // function is written later.
    write('buffer.write(');
    writeln('${partialCompiler._rendererName}(');
    var usedContextStack = partialCompiler._usedContexts
        .map((context) => context.indexInParent!)
        .map((index) => _contextStack[index]);
    writeln(usedContextStack.map((c) => c.name).join(','));
    _usedContextTypes.addAll(usedContextStack);
    writeln('));');
  }

  /// Compiles [node] into a renderer's Dart source.
  Future<void> _compileSection(Section node) async {
    var variableLookup = _lookUpGetter(node);
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
    await _compile(block);
    writeln('}');
  }

  /// Compiles a repeated section containing [block] into a renderer's Dart
  /// source.
  Future<void> _compileRepeatedSection(
      _VariableLookup variableLookup, List<MustachioNode> block,
      {bool invert = false}) async {
    var variableIsPotentiallyNullable =
        typeSystem.isPotentiallyNullable(variableLookup.type);
    var variableAccess = variableLookup.name;
    if (invert) {
      if (variableIsPotentiallyNullable) {
        writeln('if ($variableAccess?.isEmpty ?? true) {');
      } else {
        writeln('if ($variableAccess.isEmpty) {');
      }
      await _compile(block);
      writeln('}');
    } else {
      var variableAccessResult = getNewContextName();
      writeln('var $variableAccessResult = $variableAccess;');
      var newContextName = getNewContextName();
      if (variableIsPotentiallyNullable) {
        writeln('if ($variableAccessResult != null) {');
      }
      writeln('  for (var $newContextName in $variableAccessResult) {');
      // If [loopType] is something like `C<int>` where
      // `class C<T> implements Queue<Future<T>>`, we need the [ClassElement]
      // for [Iterable], and then use [DartType.asInstanceOf] to ultimately
      // determine that the inner type of the loop is, for example,
      // `Future<int>`.
      var iterableElement = typeProvider.iterableElement;
      var iterableType = variableLookup.type.asInstanceOf(iterableElement)!;
      var innerContextType = iterableType.typeArguments.first as InterfaceType;
      var innerContext = _VariableLookup(innerContextType, newContextName);
      _contextStack.push(innerContext);
      await _compile(block);
      _contextStack.pop();
      writeln('  }');
      if (variableIsPotentiallyNullable) {
        writeln('}');
      }
    }
  }

  /// Compiles a value section containing [block] into a renderer's Dart source.
  Future<void> _compileValueSection(
      _VariableLookup variableLookup, List<MustachioNode> block,
      {bool invert = false}) async {
    var variableAccess = variableLookup.name;
    var variableIsPotentiallyNullable =
        typeSystem.isPotentiallyNullable(variableLookup.type);
    if (invert) {
      writeln('if ($variableAccess == null) {');
      await _compile(block);
      writeln('}');
    } else {
      var innerContextName = getNewContextName();
      writeln('var $innerContextName = $variableAccess;');
      if (variableIsPotentiallyNullable) {
        writeln('if ($innerContextName != null) {');
      }
      var innerContext = _VariableLookup(
          typeSystem.promoteToNonNull(variableLookup.type) as InterfaceType,
          innerContextName);
      _contextStack.push(innerContext);
      await _compile(block);
      _contextStack.pop();
      if (variableIsPotentiallyNullable) {
        writeln('}');
      }
    }
  }

  /// Returns a valid [_VariableLookup] on a Mustache node, [node] by resolving
  /// its key.
  _VariableLookup _lookUpGetter(HasMultiNamedKey node) {
    var key = node.key;

    // '.' is an entirely special case.
    if (key.length == 1 && key[0] == '.') {
      _usedContextTypes.add(_contextStack.first);
      return _VariableLookup(contextType, contextName);
    }

    var primaryName = key[0];

    late _VariableLookup context;
    PropertyAccessorElement? getter;
    for (var c in _contextStack) {
      getter = c.type.lookUpGetter2(primaryName, contextType.element.library);
      if (getter != null) {
        context = c;
        _usedContextTypes.add(c);
        break;
      }
    }
    if (getter == null) {
      var contextTypes = [for (var c in _contextStack) c.type];
      throw MustachioResolutionError(node.keySpan
          .message("Failed to resolve '$key' as a property on any types in the "
              'context chain: $contextTypes'));
    }

    var type = getter.returnType as InterfaceType;
    var contextChain = typeSystem.isPotentiallyNullable(context.type)
        // This is imperfect; the idea is that in our templates, we may have
        // `{{foo.bar.baz}}` and `foo.bar` may be nullably typed. Mustache
        // (and Mustachio) does not have a null-aware property access
        // operator, nor a null-check operator. This code translates
        // `foo.bar.baz` to `foo.bar!.baz` for nullable `foo.bar`.
        ? '${context.name}!.$primaryName'
        : '${context.name}.$primaryName';
    var remainingNames = [...key.skip(1)];
    for (var secondaryKey in remainingNames) {
      getter = type.lookUpGetter2(secondaryKey, type.element.library);
      if (getter == null) {
        throw MustachioResolutionError(node.keySpan.message(
            "Failed to resolve '$secondaryKey' on ${context.type} while "
            'resolving $remainingNames as a property chain on any types in '
            'the context chain: $contextChain, after first resolving '
            "'$primaryName' to a property on $type"));
      }
      contextChain = typeSystem.isPotentiallyNullable(type)
          ? '$contextChain!.$secondaryKey'
          : '$contextChain.$secondaryKey';
      type = getter.returnType as InterfaceType;
    }
    return _VariableLookup(type, contextChain);
  }

  /// Writes [content] to the generated render functions as text, properly
  /// handling newlines, quotes, and other special characters.
  void _writeText(String content) {
    if (content.isEmpty) return;
    if (content == '\n') {
      // Blank lines happen a lot; just indicate them as such.
      writeln('buffer.writeln();');
    } else {
      content = content
          .replaceAll(r'\', r'\\')
          .replaceAll("'", r"\'")
          .replaceAll(r'$', r'\$');
      if (_multipleWhitespacePattern.hasMatch(content)) {
        write("buffer.write('");
        write(content.replaceAll('\n', '\\n'));
        writeln("');");
      } else {
        if (content[0] == '\n') {
          write('buffer.writeln();');
        }
        write("buffer.write('''");
        write(content);
        writeln("''');");
      }
    }
  }

  /// A pattern for a String containing only space and newlines, more than one.
  static final RegExp _multipleWhitespacePattern = RegExp('^[ \\n]+\$');

  /// Writes a call to [variableLookup] to the renderer.
  ///
  /// The result is HTML-escaped if [escape] is true.
  void _writeGetter(_VariableLookup variableLookup, {bool escape = true}) {
    var variableAccess = variableLookup.name;
    var toString = variableLookup.type.isDartCoreString
        ? variableAccess
        : typeSystem.isPotentiallyNullable(variableLookup.type)
            ? '$variableAccess?.toString()'
            : '$variableAccess.toString()';
    writeln(escape
        ? 'buffer.writeEscaped($toString);'
        : 'buffer.write($toString);');
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

  /// The index of this variable in the declaring compiler's parent compiler's
  /// context stack, if it was declared in the construction of a compiler.
  final int? indexInParent;

  _VariableLookup(this.type, this.name, {this.indexInParent});
}

extension<T> on List<T> {
  void push(T value) => insert(0, value);

  T pop() => removeAt(0);
}
