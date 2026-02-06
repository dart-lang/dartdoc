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
import 'package:dartdoc/src/generator/vitepress_doc_processor.dart';
import 'package:dartdoc/src/generator/vitepress_paths.dart';
import 'package:dartdoc/src/model/container_modifiers.dart';
import 'package:dartdoc/src/model/model.dart';

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
    _buffer.writeln('title: "${_yamlEscape(title)}"');
    _buffer.writeln('description: "${_yamlEscape(description)}"');
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

  /// Writes an h2 section heading.
  void writeH2(String text) {
    _buffer.writeln('## $text');
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
      _buffer.writeln('### ~~$escapedText~~ {#$anchor} '
          '<Badge type="warning" text="deprecated" />');
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
    _buffer.writeln('| ${headers.join(' | ')} |');
    _buffer.writeln('|${headers.map((_) => '---').join('|')}|');
    for (final row in rows) {
      _buffer.writeln('| ${row.join(' | ')} |');
    }
    _buffer.writeln();
  }

  /// Writes raw text without any processing.
  void writeRaw(String text) {
    _buffer.write(text);
  }

  @override
  String toString() => _buffer.toString();

  /// Escapes characters that are special in YAML double-quoted string values.
  static String _yamlEscape(String text) =>
      text.replaceAll(r'\', r'\\').replaceAll('"', r'\"');
}

// ---------------------------------------------------------------------------
// Shared rendering helpers.
// ---------------------------------------------------------------------------

/// Builds a markdown link for a documentable element.
///
/// Returns `[DisplayName](/api/lib/ClassName)` if a URL is available,
/// or just the display name as plain text if not.
String _markdownLink(Documentable element, VitePressPathResolver paths) {
  final url = paths.linkFor(element);
  final name = element.name;
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

  // Add the kind keyword
  if (container is Class) {
    parts.add('class');
  } else if (container is Enum) {
    parts.add('enum');
  } else if (container is Mixin) {
    parts.add('mixin');
  } else if (container is ExtensionType) {
    parts.add('extension type');
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

    // Type and name
    buf.write('${param.modelType.nameWithGenericsPlain} ${param.name}');

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
    buf.write('${element.modelType.returnType.nameWithGenericsPlain} ');
  } else if (element is ModelFunctionTyped) {
    buf.write('${element.modelType.returnType.nameWithGenericsPlain} ');
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
      return element.enclosingElement.name.toLowerCase();
    }
    return element.element.name!.toLowerCase();
  }
  return element.name.toLowerCase();
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

  builder.writeTable(
    headers: ['Name', 'Description'],
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
  sig.write('${field.modelType.nameWithGenericsPlain} ');
  sig.write(field.name);

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
  final displaySuffix = method is Operator ? '' : '()';
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

  // Package documentation
  final packageDoc = package.documentation;
  if (packageDoc != null && packageDoc.isNotEmpty) {
    builder.writeParagraph(packageDoc);
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
      final libDoc = lib.documentation;
      final description =
          libDoc.isNotEmpty ? _extractFirstParagraph(libDoc) : '';
      rows.add([link, description]);
    }

    builder.writeTable(
      headers: ['Library', 'Description'],
      rows: rows,
    );
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

  // Library documentation
  final libDoc = library.documentation;
  if (libDoc.isNotEmpty) {
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
    'Constants',
    library.publicConstantsSorted.cast<Documentable>(),
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
    'Functions',
    library.publicFunctionsSorted.cast<Documentable>(),
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

  builder.writeH1(nameWithGenerics, deprecated: clazz.isDeprecated);

  // Declaration line
  builder.writeCodeBlock(_buildContainerDeclaration(clazz));

  // Deprecation notice
  if (clazz.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(clazz));
  }

  // Documentation
  final doc = docs.processDocumentation(clazz);
  builder.writeParagraph(doc);

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

  builder.writeH1(nameWithGenerics, deprecated: enumeration.isDeprecated);

  // Declaration line
  builder.writeCodeBlock(_buildContainerDeclaration(enumeration));

  // Deprecation notice
  if (enumeration.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(enumeration));
  }

  // Documentation
  final doc = docs.processDocumentation(enumeration);
  builder.writeParagraph(doc);

  // Enum values section (before other members)
  final enumValues = enumeration.publicEnumValues;
  if (enumValues.isNotEmpty) {
    builder.writeH2('Values');
    for (final value in enumValues) {
      final anchor = value.name.toLowerCase();
      builder.writeH3WithAnchor(
        value.name,
        anchor: anchor,
        deprecated: value.isDeprecated,
      );
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

  builder.writeH1(nameWithGenerics, deprecated: mixin_.isDeprecated);

  // Declaration line
  final declaration = _buildMixinDeclaration(mixin_);
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (mixin_.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(mixin_));
  }

  // Documentation
  final doc = docs.processDocumentation(mixin_);
  builder.writeParagraph(doc);

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

  builder.writeH1(nameWithGenerics, deprecated: ext.isDeprecated);

  // Declaration line
  final declaration = 'extension $nameWithGenerics on '
      '${ext.extendedElement.nameWithGenericsPlain}';
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (ext.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(ext));
  }

  // Documentation
  final doc = docs.processDocumentation(ext);
  builder.writeParagraph(doc);

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

  builder.writeH1(nameWithGenerics, deprecated: et.isDeprecated);

  // Declaration line
  final declaration = _buildExtensionTypeDeclaration(et);
  builder.writeCodeBlock(declaration);

  // Deprecation notice
  if (et.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(et));
  }

  // Documentation
  final doc = docs.processDocumentation(et);
  builder.writeParagraph(doc);

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

  builder.writeH1(nameWithGenerics, deprecated: func.isDeprecated);

  // Signature
  builder.writeCodeBlock(_buildCallableSignature(func));

  // Deprecation notice
  if (func.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(func));
  }

  // Documentation
  final doc = docs.processDocumentation(func);
  builder.writeParagraph(doc);

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

  builder.writeH1(prop.name, deprecated: prop.isDeprecated);

  // Signature
  final sig = StringBuffer();
  if (prop.isConst) {
    sig.write('const ');
  } else if (prop.isFinal) {
    sig.write('final ');
  }
  sig.write('${prop.modelType.nameWithGenericsPlain} ${prop.name}');

  if (prop.isConst && prop.hasConstantValueForDisplay) {
    sig.write(' = ${prop.constantValueBase}');
  }

  builder.writeCodeBlock(sig.toString());

  // Deprecation notice
  if (prop.isDeprecated) {
    builder.writeDeprecationNotice(_extractDeprecationMessage(prop));
  }

  // Documentation
  final doc = docs.processDocumentation(prop);
  builder.writeParagraph(doc);

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

  builder.writeH1(nameWithGenerics, deprecated: td.isDeprecated);

  // Typedef declaration
  final sig = StringBuffer('typedef $nameWithGenerics = ');

  if (td is FunctionTypedef) {
    // Function typedef: show the return type and parameter types
    sig.write(td.modelType.returnType.nameWithGenericsPlain);
    sig.write(' Function');
    sig.write(_buildParameterSignature(td.parameters));
  } else {
    // Type alias (ClassTypedef, GeneralizedTypedef)
    sig.write(td.modelType.nameWithGenericsPlain);
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

  // Category documentation (from markdown file)
  final catDoc = cat.documentation;
  if (catDoc != null && catDoc.isNotEmpty) {
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
    'Constants',
    cat.publicConstantsSorted.cast<Documentable>(),
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
    'Functions',
    cat.publicFunctionsSorted.cast<Documentable>(),
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
    rows.add([nameCell, onType, descCell]);
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

/// Extracts the first paragraph from documentation text.
///
/// Takes text up to the first blank line and collapses it to a single line.
String _extractFirstParagraph(String text) {
  if (text.isEmpty) return '';
  final firstPara = text.split(RegExp(r'\n\s*\n')).first.trim();
  return firstPara.replaceAll('\n', ' ');
}
