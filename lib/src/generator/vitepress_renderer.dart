// Copyright (c) 2025, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Pure functions that render dartdoc model objects into VitePress-compatible
/// markdown strings.
///
/// All functions use [StringBuffer] to build markdown. They depend on
/// [VitePressPathResolver] for link/path computation and
/// [VitePressDocProcessor] for documentation processing.
library;

import 'package:dartdoc/src/comment_references/parser.dart' show operatorNames;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/generator/vitepress_doc_processor.dart';
import 'package:dartdoc/src/generator/vitepress_paths.dart';
import 'package:dartdoc/src/model/attribute.dart' show Attribute;
import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

// ---------------------------------------------------------------------------
// Generic name helpers (ADR-7).
// ---------------------------------------------------------------------------

/// Builds a plain-text name with generic type parameters.
///
/// Uses `tp.element.name!` for the type parameter name (NOT `tp.name` which
/// contains HTML) and `tp.boundType?.nameWithGenericsPlain` for the bound.
String plainNameWithGenerics(ModelElement element) {
  if (element is TypeParameters && element.typeParameters.isNotEmpty) {
    final params = element.typeParameters.map((tp) {
      var result = tp.element.name!;
      final bound = tp.boundType;
      if (bound != null) {
        result += ' extends ${bound.nameWithGenericsPlain}';
      }
      return result;
    }).join(', ');
    return '${element.name}<$params>';
  }
  return element.name;
}

/// Escapes angle brackets for use in markdown headings and inline text.
///
/// In code fences and inline code, escaping is NOT needed.
String escapeGenerics(String text) =>
    text.replaceAll('<', r'\<').replaceAll('>', r'\>');

// ---------------------------------------------------------------------------
// Testable string helpers.
// ---------------------------------------------------------------------------

/// Escapes pipe characters in table cell content to prevent breaking the
/// markdown table structure.
@visibleForTesting
String escapeTableCell(String cell) => cell.replaceAll('|', r'\|');

/// Escapes characters that are special in YAML double-quoted string values.
@visibleForTesting
String yamlEscape(String text) => text
    .replaceAll(r'\', r'\\')
    .replaceAll('"', r'\"')
    .replaceAll('\n', r'\n')
    .replaceAll('\r', r'\r');

// ---------------------------------------------------------------------------
// Helper: _MarkdownPageBuilder
// ---------------------------------------------------------------------------

/// A helper class for building VitePress markdown pages with proper
/// frontmatter, consistent formatting, and reusable section patterns.
class _MarkdownPageBuilder {
  final StringBuffer _buffer = StringBuffer();

  /// Writes the YAML frontmatter block.
  ///
  /// Every generated page disables `editLink`, `lastUpdated`, `prev`, and
  /// `next` because these are auto-generated API pages.
  void writeFrontmatter({
    required String title,
    required String description,
    required Object outline, // bool or List<int>
  }) {
    _buffer.writeln('---');
    // Quote the title to handle special characters like `<` and `:`.
    _buffer.writeln('title: "${yamlEscape(title)}"');
    _buffer.writeln('description: "${yamlEscape(description)}"');
    if (outline is bool) {
      _buffer.writeln('outline: $outline');
    } else if (outline is List<int>) {
      _buffer.writeln('outline: [${outline.join(', ')}]');
    }
    _buffer.writeln('editLink: false');
    _buffer.writeln('lastUpdated: false');
    _buffer.writeln('prev: false');
    _buffer.writeln('next: false');
    _buffer.writeln('---');
    _buffer.writeln();
  }

  /// Writes a breadcrumb navigation line above the page title.
  ///
  /// Renders as small muted links: `Library > Kind > Element`.
  void writeBreadcrumbs(List<(String label, String? link)> crumbs) {
    if (crumbs.isEmpty) return;
    final parts = crumbs.map((c) {
      if (c.$2 != null) {
        return '<a href="${c.$2}" style="text-decoration:none;color:var(--vp-c-text-2)">${escapeGenerics(c.$1)}</a>';
      }
      return '<span style="color:var(--vp-c-text-3)">${escapeGenerics(c.$1)}</span>';
    });
    _buffer.writeln(
      '<div style="font-size:0.85em;margin-bottom:0.5em;color:var(--vp-c-text-3)">'
      '${parts.join(" › ")}'
      '</div>',
    );
    _buffer.writeln();
  }

  /// Writes a top-level heading (h1).
  void writeH1(String text, {bool deprecated = false}) {
    if (deprecated) {
      _buffer.writeln('# ~~${escapeGenerics(text)}~~ '
          '<Badge type="warning" text="deprecated" />');
    } else {
      _buffer.writeln('# ${escapeGenerics(text)}');
    }
    _buffer.writeln();
  }

  /// Writes an h2 section heading with an explicit ID to prevent collisions
  /// with member-level anchors (e.g., `## Values` auto-generates `id="values"`
  /// which collides with an enum constant named `values`).
  void writeH2(String text) {
    final slug = text.toLowerCase().replaceAll(' ', '-');
    _buffer.writeln('## $text {#section-$slug}');
    _buffer.writeln();
  }

  /// Writes an h3 member heading with an anchor ID.
  void writeH3WithAnchor(
    String text, {
    required String anchor,
    bool deprecated = false,
  }) {
    final escapedText = escapeGenerics(text);
    if (deprecated) {
      _buffer.writeln('### ~~$escapedText~~ '
          '<Badge type="warning" text="deprecated" /> {#$anchor}');
    } else {
      _buffer.writeln('### $escapedText {#$anchor}');
    }
    _buffer.writeln();
  }

  /// Writes a fenced code block (no escaping needed inside).
  void writeCodeBlock(String code, {String language = 'dart'}) {
    _buffer.writeln('```$language');
    _buffer.writeln(code);
    _buffer.writeln('```');
    _buffer.writeln();
  }

  /// Writes a deprecation warning container.
  void writeDeprecationNotice(String message) {
    _buffer.writeln(':::warning DEPRECATED');
    if (message.isNotEmpty) {
      _buffer.writeln(message);
    }
    _buffer.writeln(':::');
    _buffer.writeln();
  }

  /// Writes a paragraph of text.
  void writeParagraph(String text) {
    if (text.isNotEmpty) {
      _buffer.writeln(text);
      _buffer.writeln();
    }
  }

  /// Writes an "Inherited from" notice.
  void writeInheritedFrom(String className) {
    _buffer.writeln('*Inherited from $className.*');
    _buffer.writeln();
  }

  /// Writes a markdown table with header and rows.
  void writeTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    if (rows.isEmpty) return;
    _buffer.writeln('| ${headers.map(escapeTableCell).join(' | ')} |');
    _buffer.writeln('|${headers.map((_) => '---').join('|')}|');
    for (final row in rows) {
      _buffer.writeln('| ${row.map(escapeTableCell).join(' | ')} |');
    }
    _buffer.writeln();
  }

  /// Writes raw text without any processing.
  void writeRaw(String text) {
    _buffer.write(text);
  }

  @override
  String toString() => _buffer.toString();
}

// ---------------------------------------------------------------------------
// Pre-compiled regular expressions (avoid re-creating on every call).
// ---------------------------------------------------------------------------

/// Matches HTML tags for stripping in [_annotationPlainText].
final _htmlTagRegExp = RegExp(r'<[^>]*>');

/// Matches a leading `# Title` line in documentation text.
final _leadingH1RegExp = RegExp(r'^#\s+(.+?)(\r?\n|$)');

// ---------------------------------------------------------------------------
// Shared rendering helpers.
// ---------------------------------------------------------------------------

/// Builds a markdown link for a documentable element.
///
/// Returns `[DisplayName](/api/lib/ClassName)` if a URL is available,
/// or just the display name as plain text if not.
String _markdownLink(Documentable element, VitePressPathResolver paths) {
  final url = paths.linkFor(element);
  // Use full name with generics for elements that have type parameters.
  final rawName =
      element is ModelElement ? plainNameWithGenerics(element) : element.name;
  final name = escapeGenerics(rawName);
  if (url == null) return name;
  return '[$name]($url)';
}

/// Extracts the deprecation message from an element's annotations.
///
/// Uses the analyzer's `ElementAnnotation` to find the `@Deprecated` annotation
/// and retrieve its `message` field via `computeConstantValue()`.
String _extractDeprecationMessage(ModelElement element) {
  for (final annotation in element.element.metadata.annotations) {
    if (!annotation.isDeprecated) continue;
    final value = annotation.computeConstantValue();
    if (value == null) continue;
    final message = value.getField('message')?.toStringValue();
    if (message != null && message.isNotEmpty) return message;
  }
  return '';
}

/// Builds the Dart declaration line for a container type
/// (class/enum/mixin/extension type).
///
/// Renders Dart 3 modifiers from `containerModifiers`, plus `extends`,
/// `implements`, and `with` clauses.
String _buildContainerDeclaration(InheritingContainer container) {
  final parts = <String>[];

  // Render modifiers (sealed, abstract, base, interface, final, mixin)
  for (final modifier in container.containerModifiers) {
    // Skip 'abstract' if 'sealed' is present (sealed implies abstract)
    if (modifier == ContainerModifier.abstract &&
        container.containerModifiers.contains(ContainerModifier.sealed)) {
      continue;
    }
    parts.add(modifier.displayName);
  }

  // Add the kind keyword (Mixin and ExtensionType use dedicated declaration
  // builders, so only Class and Enum are handled here).
  if (container is Class) {
    parts.add('class');
  } else if (container is Enum) {
    parts.add('enum');
  }

  // Add name with generics (unescaped -- this goes inside a code block)
  parts.add(plainNameWithGenerics(container));

  // Add extends clause
  final supertype = container.supertype;
  if (supertype != null &&
      supertype.modelElement.name != 'Object' &&
      supertype.modelElement.name != 'Enum') {
    parts.add('extends ${supertype.nameWithGenericsPlain}');
  }

  // Add with clause (for classes and enums with MixedInTypes)
  if (container is MixedInTypes) {
    final mixins = container.publicMixedInTypes.toList();
    if (mixins.isNotEmpty) {
      parts
          .add('with ${mixins.map((m) => m.nameWithGenericsPlain).join(', ')}');
    }
  }

  // Add implements clause
  if (container.publicInterfaces.isNotEmpty) {
    parts.add(
        'implements ${container.publicInterfaces.map((i) => i.nameWithGenericsPlain).join(', ')}');
  }

  return parts.join(' ');
}

/// Renders an [ElementType] as plain text, correctly expanding callable
/// (function) types into their full signature (e.g. `T Function()`).
///
/// For non-callable types, falls back to [ElementType.nameWithGenericsPlain].
/// This is necessary because [nameWithGenericsPlain] for [FunctionTypeElementType]
/// returns only `Function` (the name), omitting the return type and parameters.
String _renderTypePlain(ElementType type) {
  if (type is Callable) {
    final buf = StringBuffer();
    buf.write(_renderTypePlain(type.returnType));
    buf.write(' ');
    buf.write(type.nameWithGenericsPlain);
    buf.write('(');
    buf.write(_buildCallableParameterList(type.parameters));
    buf.write(')');
    if (type.nullabilitySuffix.isNotEmpty) {
      // Wrap in parens for nullable function types: `void Function()?`
      return '($buf)${type.nullabilitySuffix}';
    }
    return buf.toString();
  }
  return type.nameWithGenericsPlain;
}

/// Builds the inner parameter list for a callable type (no brackets, just
/// comma-separated type+name pairs).
String _buildCallableParameterList(List<Parameter> parameters) {
  if (parameters.isEmpty) return '';

  final parts = <String>[];
  var inOptionalPositional = false;
  var inNamed = false;

  for (final param in parameters) {
    final buf = StringBuffer();

    if (param.isOptionalPositional && !inOptionalPositional) {
      inOptionalPositional = true;
      buf.write('[');
    } else if (param.isNamed && !inNamed) {
      inNamed = true;
      buf.write('{');
    }

    if (param.isRequiredNamed) {
      buf.write('required ');
    }

    buf.write(_renderTypePlain(param.modelType));
    // Function type parameters in callable signatures often have no name,
    // but if they do, include it.
    if (param.name.isNotEmpty) {
      buf.write(' ${param.name}');
    }

    final defaultValue = param.defaultValue;
    if (defaultValue != null && defaultValue.isNotEmpty) {
      buf.write(' = $defaultValue');
    }

    parts.add(buf.toString());
  }

  var result = parts.join(', ');
  if (inOptionalPositional) result += ']';
  if (inNamed) result += '}';
  return result;
}

/// Builds the parameter signature string for an element.
///
/// Iterates parameters manually (NOT using `linkedParams` which produces HTML).
String _buildParameterSignature(List<Parameter> parameters) {
  if (parameters.isEmpty) return '()';

  final parts = <String>[];
  var inOptionalPositional = false;
  var inNamed = false;

  for (final param in parameters) {
    final buf = StringBuffer();

    // Opening brackets for optional/named parameters
    if (param.isOptionalPositional && !inOptionalPositional) {
      inOptionalPositional = true;
      buf.write('[');
    } else if (param.isNamed && !inNamed) {
      inNamed = true;
      buf.write('{');
    }

    // Required keyword for required named parameters
    if (param.isRequiredNamed) {
      buf.write('required ');
    }

    // Type and name (use _renderTypePlain to expand callable types)
    buf.write('${_renderTypePlain(param.modelType)} ${param.name}');

    // Default value
    final defaultValue = param.defaultValue;
    if (defaultValue != null && defaultValue.isNotEmpty) {
      buf.write(' = $defaultValue');
    }

    parts.add(buf.toString());
  }

  var result = parts.join(', ');

  // Closing brackets
  if (inOptionalPositional) result += ']';
  if (inNamed) result += '}';

  return '($result)';
}

/// Builds a method/function signature line.
String _buildCallableSignature(ModelElement element) {
  final buf = StringBuffer();

  // Return type (for methods and functions)
  if (element is Method) {
    buf.write('${_renderTypePlain(element.modelType.returnType)} ');
  } else if (element is ModelFunctionTyped) {
    buf.write('${_renderTypePlain(element.modelType.returnType)} ');
  }

  // Name with generics
  buf.write(plainNameWithGenerics(element));

  // Parameters
  buf.write(_buildParameterSignature(element.parameters));

  return buf.toString();
}

/// Builds a constructor signature line.
String _buildConstructorSignature(Constructor constructor) {
  final buf = StringBuffer();

  if (constructor.isConst) buf.write('const ');
  if (constructor.isFactory) buf.write('factory ');

  buf.write(constructor.displayName);
  buf.write(_buildParameterSignature(constructor.parameters));

  return buf.toString();
}

/// Renders the documentation body for a member element.
///
/// This handles the full doc, deprecation notice, and inherited-from marker.
void _renderMemberDocumentation(
  _MarkdownPageBuilder builder,
  ModelElement element,
  VitePressDocProcessor docs,
) {
  // Deprecation warning
  if (element.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(element));
  }

  // Main documentation
  final doc = docs.processDocumentation(element);
  builder.writeParagraph(doc);

  // Inherited-from notice: use the analyzer element's enclosing element name
  // to find the defining class. This avoids accessing `definingEnclosingContainer`
  // which is @protected/@visibleForTesting.
  if (element is Inheritable && element.isInherited) {
    final definingClassName =
        element.element.enclosingElement?.name ?? 'unknown';
    builder.writeInheritedFrom(definingClassName);
  }
}

/// Computes the anchor ID for a member element.
///
/// For operators, maps the symbol to a URL-safe name.
/// For constructors, uses the constructor name lowercased.
/// For other members, uses the element name lowercased.
String _memberAnchor(ModelElement element) {
  if (element is Operator) {
    // The reference name is the raw operator symbol (e.g., '==', '[]')
    final refName = element.referenceName;
    final anchorSuffix = operatorNames[refName] ?? refName.toLowerCase();
    return 'operator-$anchorSuffix';
  }
  if (element is Constructor) {
    if (element.isUnnamedConstructor) {
      // Prefix with 'ctor-' to avoid collision with VitePress auto-generated
      // ID for the class H1 heading (which would also be lowercased class name).
      return 'ctor-${element.enclosingElement.name.toLowerCase()}';
    }
    return element.element.name!.toLowerCase();
  }
  final name = element.name.toLowerCase();
  // Prefix property anchors to avoid collision with methods of the same name
  // (e.g. property `s` and method `s()` would both produce anchor `{#s}`).
  if (element is Field) {
    return 'prop-$name';
  }
  return name;
}

/// Renders a "View source" link for elements that have a source URL.
void _renderSourceLink(_MarkdownPageBuilder builder, ModelElement element) {
  if (element.hasSourceHref) {
    builder.writeParagraph('[View source](${element.sourceHref})');
  }
}

/// Renders annotations for an element (excluding `@Deprecated` which is
/// handled separately as a deprecation notice).
///
/// Uses the source representation of each annotation for plain-text output
/// (the `linkedNameWithParameters` getter produces HTML, which is not
/// suitable for markdown).
void _renderAnnotations(_MarkdownPageBuilder builder, ModelElement element) {
  if (!element.hasAnnotations) return;
  final annotations = element.annotations
      .map(_annotationPlainText)
      .where(
          (text) => text != '@deprecated' && !text.startsWith('@Deprecated('))
      .map((text) => '`$text`')
      .toList();
  if (annotations.isEmpty) return;
  builder.writeParagraph('**Annotations:** ${annotations.join(', ')}');
}

/// Converts an annotation's `linkedNameWithParameters` (which may contain
/// HTML tags and entities) into plain text suitable for markdown output.
String _annotationPlainText(Attribute annotation) {
  return annotation.linkedNameWithParameters
      .replaceAll(_htmlTagRegExp, '') // Strip HTML tags
      .replaceAll('&lt;', '<')
      .replaceAll('&#60;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&#62;', '>')
      .replaceAll('&amp;', '&')
      .replaceAll('&#38;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#34;', '"')
      .replaceAll('&#39;', "'");
}

/// Renders the "Implementers" section for a class/interface.
void _renderImplementors(
  _MarkdownPageBuilder builder,
  InheritingContainer container,
  VitePressPathResolver paths,
) {
  final implementors = container.publicImplementersSorted;
  if (implementors.isEmpty) return;

  builder.writeH2('Implementers');
  for (final impl in implementors) {
    builder.writeParagraph('- ${_markdownLink(impl, paths)}');
  }
}

/// Renders the "Available Extensions" section for a class.
void _renderAvailableExtensions(
  _MarkdownPageBuilder builder,
  InheritingContainer container,
  VitePressPathResolver paths,
) {
  final extensions = container.potentiallyApplicableExtensionsSorted;
  if (extensions.isEmpty) return;

  builder.writeH2('Available Extensions');
  for (final ext in extensions) {
    builder.writeParagraph('- ${_markdownLink(ext, paths)}');
  }
}

/// Renders a library overview table for a specific element kind group.
void _renderLibraryOverviewTable(
  _MarkdownPageBuilder builder,
  String sectionTitle,
  List<Documentable> elements,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  if (elements.isEmpty) return;

  builder.writeH2(sectionTitle);

  final rows = <List<String>>[];
  for (final element in elements) {
    final link = _markdownLink(element, paths);
    final oneLineDoc = element is ModelElement
        ? docs.extractOneLineDoc(element)
        : (element.documentation ?? '');

    final isDeprecated = element is ModelElement && element.isDeprecated;
    final nameCell = isDeprecated ? '~~$link~~' : link;

    final descCell = isDeprecated && oneLineDoc.isNotEmpty
        ? '**Deprecated.** $oneLineDoc'
        : oneLineDoc;

    rows.add([nameCell, descCell]);
  }

  const singularNames = {
    'Classes': 'Class',
    'Exceptions': 'Exception',
    'Enums': 'Enum',
    'Mixins': 'Mixin',
    'Extensions': 'Extension',
    'Extension Types': 'Extension Type',
    'Functions': 'Function',
    'Properties': 'Property',
    'Constants': 'Constant',
    'Typedefs': 'Typedef',
  };
  final singularName = singularNames[sectionTitle] ?? sectionTitle;

  builder.writeTable(
    headers: [singularName, 'Description'],
    rows: rows,
  );
}

// ---------------------------------------------------------------------------
// Container member sections renderer.
// ---------------------------------------------------------------------------

/// Renders all member sections for a container (class, enum, mixin, extension,
/// extension type).
///
/// Section order: Constructors, Properties, Methods, Operators,
/// Static Properties, Static Methods, Constants.
void _renderContainerMembers(
  _MarkdownPageBuilder builder,
  Container container,
  VitePressDocProcessor docs,
) {
  // 1. Constructors
  if (container.hasPublicConstructors) {
    builder.writeH2('Constructors');
    for (final ctor in container.publicConstructorsSorted) {
      _renderConstructorMember(builder, ctor, docs);
    }
  }

  // 2. Properties (instance fields)
  final instanceFields = container.availableInstanceFieldsSorted;
  if (instanceFields.isNotEmpty) {
    builder.writeH2('Properties');
    for (final field in instanceFields) {
      _renderFieldMember(builder, field, docs);
    }
  }

  // 3. Methods (instance methods)
  final instanceMethods = container.availableInstanceMethodsSorted;
  if (instanceMethods.isNotEmpty) {
    builder.writeH2('Methods');
    for (final method in instanceMethods) {
      _renderMethodMember(builder, method, docs);
    }
  }

  // 4. Operators
  final operators = container.availableInstanceOperatorsSorted;
  if (operators.isNotEmpty) {
    builder.writeH2('Operators');
    for (final op in operators) {
      _renderMethodMember(builder, op, docs);
    }
  }

  // 5. Static Properties
  final staticFields = container.publicVariableStaticFieldsSorted;
  if (staticFields.isNotEmpty) {
    builder.writeH2('Static Properties');
    for (final field in staticFields) {
      _renderFieldMember(builder, field, docs);
    }
  }

  // 6. Static Methods
  final staticMethods = container.publicStaticMethodsSorted;
  if (staticMethods.isNotEmpty) {
    builder.writeH2('Static Methods');
    for (final method in staticMethods) {
      _renderMethodMember(builder, method, docs);
    }
  }

  // 7. Constants
  final constants = container.publicConstantFieldsSorted;
  if (constants.isNotEmpty) {
    builder.writeH2('Constants');
    for (final constant in constants) {
      _renderFieldMember(builder, constant, docs);
    }
  }
}

/// Renders a single constructor as an h3 member section.
void _renderConstructorMember(
  _MarkdownPageBuilder builder,
  Constructor constructor,
  VitePressDocProcessor docs,
) {
  final displayName = constructor.displayName;
  final anchor = _memberAnchor(constructor);

  builder.writeH3WithAnchor(
    '$displayName()',
    anchor: anchor,
    deprecated: constructor.isDeprecated,
  );

  builder.writeCodeBlock(_buildConstructorSignature(constructor));

  _renderMemberDocumentation(builder, constructor, docs);
}

/// Renders a single field/property as an h3 member section.
void _renderFieldMember(
  _MarkdownPageBuilder builder,
  Field field,
  VitePressDocProcessor docs,
) {
  final anchor = _memberAnchor(field);

  builder.writeH3WithAnchor(
    field.name,
    anchor: anchor,
    deprecated: field.isDeprecated,
  );

  // Build the field signature
  final sig = StringBuffer();
  if (field.isConst) {
    sig.write('const ');
  } else if (field.isFinal) {
    sig.write('final ');
  }
  if (field.isLate) {
    sig.write('late ');
  }

  // Show get/set for explicit getter/setter fields
  final fieldTypePlain = _renderTypePlain(field.modelType);
  if (field.hasExplicitGetter && !field.hasExplicitSetter) {
    sig.write('$fieldTypePlain get ${field.name}');
  } else if (field.hasExplicitSetter && !field.hasExplicitGetter) {
    sig.write('set ${field.name}($fieldTypePlain value)');
  } else if (field.hasExplicitGetter && field.hasExplicitSetter) {
    sig.write('$fieldTypePlain get ${field.name}');
  } else {
    sig.write('$fieldTypePlain ${field.name}');
  }

  // Show constant value if available
  if (field.isConst && field.hasConstantValueForDisplay) {
    // Use constantValueBase (raw, before HTML linkification).
    // Note: constantValueBase may contain HTML-escaped values for EnumFields;
    // this is acceptable in code blocks where VitePress renders raw text.
    sig.write(' = ${field.constantValueBase}');
  }

  builder.writeCodeBlock(sig.toString());

  _renderMemberDocumentation(builder, field, docs);
}

/// Renders a single method or operator as an h3 member section.
void _renderMethodMember(
  _MarkdownPageBuilder builder,
  Method method,
  VitePressDocProcessor docs,
) {
  final anchor = _memberAnchor(method);

  // Display name: for operators, use the full name like "operator =="
  // For methods, append "()" to indicate it's callable
  final displaySuffix = '()';
  final displayName = '${method.name}$displaySuffix';

  builder.writeH3WithAnchor(
    displayName,
    anchor: anchor,
    deprecated: method.isDeprecated,
  );

  builder.writeCodeBlock(_buildCallableSignature(method));

  _renderMemberDocumentation(builder, method, docs);
}

// ---------------------------------------------------------------------------
// Public rendering functions.
// ---------------------------------------------------------------------------

/// Renders the package overview page (`api/index.md`).
///
/// Lists all documented libraries with their descriptions.
String renderPackagePage(
  Package package,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();

  builder.writeFrontmatter(
    title: package.name,
    description: 'API documentation for the ${package.name} package',
    outline: false,
  );

  builder.writeH1(package.name);

  // Package documentation (strip leading H1 if it matches the package name
  // to avoid a duplicate heading, since README often starts with # PackageName)
  var packageDoc = package.documentation;
  if (packageDoc != null && packageDoc.isNotEmpty) {
    packageDoc = _stripLeadingH1(packageDoc, package.name);
    if (packageDoc.isNotEmpty) {
      builder.writeParagraph(packageDoc);
    }
  }

  // Libraries table
  final libraries = package.libraries
      .where((lib) => lib.isPublic && lib.isDocumented)
      .toList()
    ..sort((a, b) => a.name.compareTo(b.name));

  if (libraries.isNotEmpty) {
    builder.writeH2('Libraries');

    final rows = <List<String>>[];
    for (final lib in libraries) {
      final link = _markdownLink(lib, paths);
      var description = docs.extractOneLineDoc(lib);
      // Fall back to the pubspec.yaml description when the library itself
      // has no doc comment (common for single-library packages).
      if (description.isEmpty) {
        description = package.packageMeta.description;
      }
      rows.add([link, description]);
    }

    builder.writeTable(
      headers: ['Library', 'Description'],
      rows: rows,
    );
  }

  return builder.toString();
}

/// Renders a workspace overview page (`api/index.md`) when multiple local
/// packages are being documented together.
///
/// Shows each local package as a section with its pubspec description and
/// a table of its public libraries.
String renderWorkspaceOverview(
  PackageGraph packageGraph,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final workspaceName = packageGraph.defaultPackageName;

  builder.writeFrontmatter(
    title: workspaceName,
    description: 'API documentation for the $workspaceName workspace',
    outline: [2, 3],
  );

  builder.writeH1(workspaceName);
  builder.writeParagraph(
    'This workspace contains the following packages.',
  );

  // Sort packages by name for deterministic output.
  final localPackages = [...packageGraph.localPackages]
    ..sort((a, b) => a.name.compareTo(b.name));

  builder.writeH2('Packages');

  for (final package in localPackages) {
    // Package sub-heading (h3 with anchor).
    final anchor = package.name.toLowerCase().replaceAll(' ', '-');
    builder.writeH3WithAnchor(package.name, anchor: anchor);

    // Package description from pubspec.yaml.
    final description = package.packageMeta.description;
    if (description.isNotEmpty) {
      builder.writeParagraph(description);
    }

    // Libraries table for this package.
    final libraries = package.libraries
        .where((lib) => lib.isPublic && lib.isDocumented)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (libraries.isNotEmpty) {
      final rows = <List<String>>[];
      for (final lib in libraries) {
        final link = _markdownLink(lib, paths);
        var libDescription = docs.extractOneLineDoc(lib);
        if (libDescription.isEmpty) {
          libDescription = package.packageMeta.description;
        }
        rows.add([link, libDescription]);
      }

      builder.writeTable(
        headers: ['Library', 'Description'],
        rows: rows,
      );
    }
  }

  return builder.toString();
}

/// Renders a library overview page (`api/<dirName>/index.md`).
///
/// Groups elements by kind (Classes, Exceptions, Enums, etc.) with tables
/// using `extractOneLineDoc()` for descriptions.
String renderLibraryPage(
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();

  builder.writeFrontmatter(
    title: library.name,
    description: 'API documentation for the ${library.name} library',
    outline: [2, 3],
  );

  builder.writeH1(library.name);

  // Library documentation (strip leading H1 if it matches the library name
  // to avoid a duplicate heading, since library doc comments sometimes start
  // with `# LibraryName`).
  var libDoc = docs.processDocumentation(library);
  if (libDoc.isNotEmpty) {
    libDoc = _stripLeadingH1(libDoc, library.name);
    builder.writeParagraph(libDoc);
  }

  // Element groups in specified order
  _renderLibraryOverviewTable(
    builder,
    'Classes',
    library.publicClassesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Exceptions',
    library.publicExceptionsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Enums',
    library.publicEnumsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Mixins',
    library.publicMixinsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  // Extensions: include "on Type" column
  _renderExtensionsTable(builder, library.publicExtensionsSorted, paths, docs);

  _renderLibraryOverviewTable(
    builder,
    'Extension Types',
    library.publicExtensionTypesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Functions',
    library.publicFunctionsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Properties',
    library.publicPropertiesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Constants',
    library.publicConstantsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Typedefs',
    library.publicTypedefsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  return builder.toString();
}

/// Renders a class page with all members embedded.
String renderClassPage(
  Class clazz,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(clazz);

  builder.writeFrontmatter(
    title: nameWithGenerics,
    description:
        'API documentation for $nameWithGenerics class from ${library.name}',
    outline: [2, 3],
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Classes', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: clazz.isDeprecated);

  // Declaration line
  builder.writeCodeBlock(_buildContainerDeclaration(clazz));

  // Deprecation notice
  if (clazz.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(clazz));
  }

  // Annotations
  _renderAnnotations(builder, clazz);

  // Documentation
  final doc = docs.processDocumentation(clazz);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, clazz);

  // Implementers
  _renderImplementors(builder, clazz, paths);

  // Available Extensions
  _renderAvailableExtensions(builder, clazz, paths);

  // All members
  _renderContainerMembers(builder, clazz, docs);

  return builder.toString();
}

/// Renders an enum page with enum values and all members embedded.
String renderEnumPage(
  Enum enumeration,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(enumeration);

  builder.writeFrontmatter(
    title: nameWithGenerics,
    description:
        'API documentation for $nameWithGenerics enum from ${library.name}',
    outline: [2, 3],
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Enums', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: enumeration.isDeprecated);

  // Declaration line
  builder.writeCodeBlock(_buildContainerDeclaration(enumeration));

  // Deprecation notice
  if (enumeration.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(enumeration));
  }

  // Annotations
  _renderAnnotations(builder, enumeration);

  // Documentation
  final doc = docs.processDocumentation(enumeration);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, enumeration);

  // Implementers
  _renderImplementors(builder, enumeration, paths);

  // Available Extensions
  _renderAvailableExtensions(builder, enumeration, paths);

  // Enum values section (before other members)
  final enumValues = enumeration.publicEnumValues;
  if (enumValues.isNotEmpty) {
    builder.writeH2('Values');
    for (final value in enumValues) {
      final anchor = 'value-${value.name.toLowerCase()}';
      builder.writeH3WithAnchor(
        value.name,
        anchor: anchor,
        deprecated: value.isDeprecated,
      );
      if (value.isDeprecated) {
        builder.writeDeprecationNotice(_extractDeprecationMessage(value));
      }
      final valueDoc = docs.processDocumentation(value);
      builder.writeParagraph(valueDoc);
    }
  }

  // Standard container members
  _renderContainerMembers(builder, enumeration, docs);

  return builder.toString();
}

/// Renders a mixin page with superclass constraints and all members embedded.
String renderMixinPage(
  Mixin mixin_,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(mixin_);

  builder.writeFrontmatter(
    title: nameWithGenerics,
    description:
        'API documentation for $nameWithGenerics mixin from ${library.name}',
    outline: [2, 3],
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Mixins', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: mixin_.isDeprecated);

  // Declaration line
  final declaration = _buildMixinDeclaration(mixin_);
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (mixin_.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(mixin_));
  }

  // Annotations
  _renderAnnotations(builder, mixin_);

  // Documentation
  final doc = docs.processDocumentation(mixin_);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, mixin_);

  // Implementers
  _renderImplementors(builder, mixin_, paths);

  // Available Extensions
  _renderAvailableExtensions(builder, mixin_, paths);

  // Superclass constraints
  final constraints = mixin_.publicSuperclassConstraints.toList();
  if (constraints.isNotEmpty) {
    builder.writeH2('Superclass Constraints');
    for (final constraint in constraints) {
      builder.writeParagraph(
          '- ${escapeGenerics(constraint.nameWithGenericsPlain)}');
    }
  }

  // Standard container members
  _renderContainerMembers(builder, mixin_, docs);

  return builder.toString();
}

/// Renders an extension page with extended type and all members embedded.
String renderExtensionPage(
  Extension ext,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(ext);

  builder.writeFrontmatter(
    title: nameWithGenerics,
    description:
        'API documentation for $nameWithGenerics extension from ${library.name}',
    outline: [2, 3],
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Extensions', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: ext.isDeprecated);

  // Declaration line
  final declaration = 'extension $nameWithGenerics on '
      '${ext.extendedElement.nameWithGenericsPlain}';
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (ext.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(ext));
  }

  // Annotations
  _renderAnnotations(builder, ext);

  // Documentation
  final doc = docs.processDocumentation(ext);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, ext);

  // All members
  _renderContainerMembers(builder, ext, docs);

  return builder.toString();
}

/// Renders an extension type page with representation type and all members
/// embedded.
String renderExtensionTypePage(
  ExtensionType et,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(et);

  builder.writeFrontmatter(
    title: nameWithGenerics,
    description: 'API documentation for $nameWithGenerics extension type '
        'from ${library.name}',
    outline: [2, 3],
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Extension Types', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: et.isDeprecated);

  // Declaration line
  final declaration = _buildExtensionTypeDeclaration(et);
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (et.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(et));
  }

  // Annotations
  _renderAnnotations(builder, et);

  // Documentation
  final doc = docs.processDocumentation(et);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, et);

  // Implementers
  _renderImplementors(builder, et, paths);

  // All members (including constructors via Constructable)
  _renderContainerMembers(builder, et, docs);

  return builder.toString();
}

/// Renders a top-level function page.
String renderFunctionPage(
  ModelFunction func,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(func);

  builder.writeFrontmatter(
    title: '$nameWithGenerics function',
    description: 'API documentation for the $nameWithGenerics function '
        'from ${library.name}',
    outline: false,
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Functions', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: func.isDeprecated);

  // Signature
  builder.writeCodeBlock(_buildCallableSignature(func));

  // Deprecation notice
  if (func.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(func));
  }

  // Annotations
  _renderAnnotations(builder, func);

  // Documentation
  final doc = docs.processDocumentation(func);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, func);

  return builder.toString();
}

/// Renders a top-level property or constant page.
String renderPropertyPage(
  TopLevelVariable prop,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();

  final kindLabel = prop.isConst ? 'constant' : 'property';

  builder.writeFrontmatter(
    title: '${prop.name} $kindLabel',
    description: 'API documentation for the ${prop.name} $kindLabel '
        'from ${library.name}',
    outline: false,
  );

  final sidebarKind = prop.isConst ? 'Constants' : 'Properties';
  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    (sidebarKind, null),
    (prop.name, null),
  ]);

  builder.writeH1(prop.name, deprecated: prop.isDeprecated);

  // Signature
  final sig = StringBuffer();
  if (prop.isConst) {
    sig.write('const ');
  } else if (prop.isFinal) {
    sig.write('final ');
  }
  sig.write('${_renderTypePlain(prop.modelType)} ${prop.name}');

  if (prop.isConst && prop.hasConstantValueForDisplay) {
    sig.write(' = ${prop.constantValueBase}');
  }

  builder.writeCodeBlock(sig.toString());

  // Deprecation notice
  if (prop.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(prop));
  }

  // Annotations
  _renderAnnotations(builder, prop);

  // Documentation
  final doc = docs.processDocumentation(prop);
  builder.writeParagraph(doc);

  // Source link
  _renderSourceLink(builder, prop);

  return builder.toString();
}

/// Renders a typedef page.
String renderTypedefPage(
  Typedef td,
  Library library,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();
  final nameWithGenerics = plainNameWithGenerics(td);

  builder.writeFrontmatter(
    title: '$nameWithGenerics typedef',
    description: 'API documentation for the $nameWithGenerics typedef '
        'from ${library.name}',
    outline: false,
  );

  final libraryUrl = '/api/${paths.dirNameFor(library)}/';
  builder.writeBreadcrumbs([
    (library.name, libraryUrl),
    ('Typedefs', null),
    (nameWithGenerics, null),
  ]);

  builder.writeH1(nameWithGenerics, deprecated: td.isDeprecated);

  // Typedef declaration
  final sig = StringBuffer('typedef $nameWithGenerics = ');

  if (td is FunctionTypedef) {
    // Function typedef: show the return type and parameter types
    sig.write(_renderTypePlain(td.modelType.returnType));
    sig.write(' Function');
    sig.write(_buildParameterSignature(td.parameters));
  } else {
    // Type alias (ClassTypedef, GeneralizedTypedef)
    sig.write(_renderTypePlain(td.modelType));
  }

  builder.writeCodeBlock(sig.toString());

  // Deprecation notice
  if (td.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(td));
  }

  // Documentation
  final doc = docs.processDocumentation(td);
  builder.writeParagraph(doc);

  return builder.toString();
}

/// Renders a category/topic page.
String renderCategoryPage(
  Category cat,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  final builder = _MarkdownPageBuilder();

  builder.writeFrontmatter(
    title: cat.name,
    description: 'API documentation for the ${cat.name} topic',
    outline: [2, 3],
  );

  builder.writeH1(cat.name);

  // Category documentation (processed through doc processor for directives)
  final catDoc = docs.processRawDocumentation(cat.documentation);
  if (catDoc.isNotEmpty) {
    builder.writeParagraph(catDoc);
  }

  // Element groups (same order as library pages)
  _renderLibraryOverviewTable(
    builder,
    'Classes',
    cat.publicClassesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Exceptions',
    cat.publicExceptionsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Enums',
    cat.publicEnumsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Mixins',
    cat.publicMixinsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderExtensionsTable(builder, cat.publicExtensionsSorted, paths, docs);

  _renderLibraryOverviewTable(
    builder,
    'Extension Types',
    cat.publicExtensionTypesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Functions',
    cat.publicFunctionsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Properties',
    cat.publicPropertiesSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Constants',
    cat.publicConstantsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  _renderLibraryOverviewTable(
    builder,
    'Typedefs',
    cat.publicTypedefsSorted.cast<Documentable>(),
    paths,
    docs,
  );

  return builder.toString();
}

// ---------------------------------------------------------------------------
// Private helpers.
// ---------------------------------------------------------------------------

/// Renders an extensions table with the special "on Type" column.
void _renderExtensionsTable(
  _MarkdownPageBuilder builder,
  List<Extension> extensions,
  VitePressPathResolver paths,
  VitePressDocProcessor docs,
) {
  if (extensions.isEmpty) return;

  builder.writeH2('Extensions');
  final rows = <List<String>>[];
  for (final ext in extensions) {
    final link = _markdownLink(ext, paths);
    final onType = ext.extendedElement.nameWithGenericsPlain;
    final oneLineDoc = docs.extractOneLineDoc(ext);
    final isDeprecated = ext.isDeprecated;
    final nameCell = isDeprecated ? '~~$link~~' : link;
    final descCell = isDeprecated && oneLineDoc.isNotEmpty
        ? '**Deprecated.** $oneLineDoc'
        : oneLineDoc;
    rows.add([nameCell, escapeGenerics(onType), descCell]);
  }
  builder.writeTable(
    headers: ['Extension', 'on', 'Description'],
    rows: rows,
  );
}

/// Builds the mixin declaration string.
String _buildMixinDeclaration(Mixin mixin_) {
  final parts = <String>[];

  // Modifiers
  for (final modifier in mixin_.containerModifiers) {
    parts.add(modifier.displayName);
  }

  parts.add('mixin');
  parts.add(plainNameWithGenerics(mixin_));

  // Superclass constraints ("on" clause)
  final constraints = mixin_.publicSuperclassConstraints.toList();
  if (constraints.isNotEmpty) {
    parts.add(
        'on ${constraints.map((c) => c.nameWithGenericsPlain).join(', ')}');
  }

  // Implements clause
  if (mixin_.publicInterfaces.isNotEmpty) {
    parts.add(
        'implements ${mixin_.publicInterfaces.map((i) => i.nameWithGenericsPlain).join(', ')}');
  }

  return parts.join(' ');
}

/// Builds the extension type declaration string.
String _buildExtensionTypeDeclaration(ExtensionType et) {
  final parts = <String>[];

  parts.add('extension type');
  parts.add(plainNameWithGenerics(et));
  parts.add('(${et.representationType.nameWithGenericsPlain})');

  // Implements clause
  if (et.publicInterfaces.isNotEmpty) {
    parts.add(
        'implements ${et.publicInterfaces.map((i) => i.nameWithGenericsPlain).join(', ')}');
  }

  return parts.join(' ');
}

/// Strips or downgrades a leading `# title` from documentation text.
///
/// If the H1 matches [expectedTitle], it is stripped entirely to avoid
/// duplication (README files often start with `# PackageName`).
/// If the H1 does NOT match, it is downgraded to H2 (`##`) to prevent
/// multiple H1 headings on the page (only the generator's own H1 should
/// remain as the page title).
String _stripLeadingH1(String text, String expectedTitle) {
  final match = _leadingH1RegExp.firstMatch(text);
  if (match == null) return text;

  final title = match.group(1)!.trim();
  if (title == expectedTitle) {
    // Exact duplicate — strip entirely.
    return text.substring(match.end).trimLeft();
  }
  // Different H1 from user content — downshift to H2.
  return '## ${match.group(1)}${text.substring(match.end)}';
}
