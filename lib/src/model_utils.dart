// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/ast/utilities.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/element_type.dart';

final Map<String, String> _fileContents = <String, String>{};

String linkedParams(List<Parameter> parameters,
    {bool showMetadata = true,
    bool showNames = true,
    String separator = ', '}) {
  List<Parameter> requiredParams =
      parameters.where((Parameter p) => !p.isOptional).toList();
  List<Parameter> positionalParams =
      parameters.where((Parameter p) => p.isOptionalPositional).toList();
  List<Parameter> namedParams =
      parameters.where((Parameter p) => p.isOptionalNamed).toList();

  StringBuffer builder = StringBuffer();

  // prefix
  if (requiredParams.isEmpty && positionalParams.isNotEmpty) {
    builder.write('[');
  } else if (requiredParams.isEmpty && namedParams.isNotEmpty) {
    builder.write('{');
  }

  // index over params
  for (Parameter param in requiredParams) {
    bool isLast = param == requiredParams.last;
    String ext;
    if (isLast && positionalParams.isNotEmpty) {
      ext = ', [';
    } else if (isLast && namedParams.isNotEmpty) {
      ext = ', {';
    } else {
      ext = isLast ? '' : ', ';
    }
    builder.write(renderParam(param, ext, showMetadata, showNames));
    builder.write(' ');
  }
  for (Parameter param in positionalParams) {
    bool isLast = param == positionalParams.last;
    builder
        .write(renderParam(param, isLast ? '' : ', ', showMetadata, showNames));
    builder.write(' ');
  }
  for (Parameter param in namedParams) {
    bool isLast = param == namedParams.last;
    builder
        .write(renderParam(param, isLast ? '' : ', ', showMetadata, showNames));
    builder.write(' ');
  }

  // suffix
  if (namedParams.isNotEmpty) {
    builder.write('}');
  } else if (positionalParams.isNotEmpty) {
    builder.write(']');
  }

  return builder.toString().trim();
}

String renderParam(
    Parameter param, String suffix, bool showMetadata, bool showNames) {
  StringBuffer buf = StringBuffer();
  ElementType paramModelType = param.modelType;

  buf.write('<span class="parameter" id="${param.htmlId}">');
  if (showMetadata && param.hasAnnotations) {
    param.annotations.forEach((String annotation) {
      buf.write('<span>$annotation</span> ');
    });
  }
  if (param.isCovariant) {
    buf.write('<span>covariant</span> ');
  }
  if (paramModelType is CallableElementTypeMixin ||
      paramModelType.type is FunctionType) {
    String returnTypeName;
    if (paramModelType.isTypedef) {
      returnTypeName = paramModelType.linkedName;
    } else {
      returnTypeName = paramModelType.createLinkedReturnTypeName();
    }
    buf.write('<span class="type-annotation">${returnTypeName}</span>');
    if (showNames) {
      buf.write(' <span class="parameter-name">${param.name}</span>');
    } else if (paramModelType.isTypedef ||
        paramModelType is CallableAnonymousElementType ||
        paramModelType.type is FunctionType) {
      buf.write(' <span class="parameter-name">${paramModelType.name}</span>');
    }
    if (!paramModelType.isTypedef && paramModelType is DefinedElementType) {
      buf.write('(');
      buf.write(linkedParams(paramModelType.element.parameters,
          showNames: showNames, showMetadata: showMetadata));
      buf.write(')');
    }
    if (!paramModelType.isTypedef && paramModelType.type is FunctionType) {
      buf.write('(');
      buf.write(linkedParams(
          (paramModelType as UndefinedElementType).parameters,
          showNames: showNames,
          showMetadata: showMetadata));
      buf.write(')');
    }
  } else if (param.modelType != null) {
    String typeName = paramModelType.linkedName;
    if (typeName.isNotEmpty) {
      buf.write('<span class="type-annotation">$typeName</span>');
    }
    if (typeName.isNotEmpty && showNames && param.name.isNotEmpty) {
      buf.write(' ');
    }
    if (showNames && param.name.isNotEmpty) {
      buf.write('<span class="parameter-name">${param.name}</span>');
    }
  }

  if (param.hasDefaultValue) {
    if (param.isOptionalNamed) {
      buf.write(': ');
    } else {
      buf.write(' = ');
    }
    buf.write('<span class="default-value">${param.defaultValue}</span>');
  }
  buf.write('${suffix}</span>');
  return buf.toString();
}

/// Returns the [AstNode] for a given [Element].
///
/// Uses a precomputed map of [element.source.fullName] to [CompilationUnit]
/// to avoid linear traversal in [ResolvedLibraryElementImpl.getElementDeclaration].
AstNode getAstNode(
    Element element, Map<String, CompilationUnit> compilationUnitMap) {
  if (element?.source?.fullName != null &&
      !element.isSynthetic &&
      element.nameOffset != -1) {
    CompilationUnit unit = compilationUnitMap[element.source.fullName];
    if (unit != null) {
      var locator = NodeLocator2(element.nameOffset);
      return (locator.searchWithin(unit)?.parent);
    }
  }
  return null;
}

/// Remove elements that aren't documented.
Iterable<T> filterNonDocumented<T extends Documentable>(
    Iterable<T> maybeDocumentedItems) {
  return maybeDocumentedItems.where((me) => me.isDocumented);
}

/// Returns an iterable containing only public elements from [privacyItems].
Iterable<T> filterNonPublic<T extends Privacy>(Iterable<T> privacyItems) {
  return privacyItems.where((me) => me.isPublic);
}

/// Finds canonical classes for all classes in the iterable, if possible.
/// If a canonical class can not be found, returns the original class.
Iterable<Class> findCanonicalFor(Iterable<Class> classes) {
  return classes.map((c) =>
      c.packageGraph.findCanonicalModelElementFor(c.element) as Class ?? c);
}

String getFileContentsFor(Element e) {
  var location = e.source.fullName;
  if (!_fileContents.containsKey(location)) {
    var contents = File(location).readAsStringSync();
    _fileContents.putIfAbsent(location, () => contents);
  }
  return _fileContents[location];
}

final RegExp slashes = RegExp('[\/]');
bool hasPrivateName(Element e) {
  if (e.name == null) return false;

  if (e.name.startsWith('_')) {
    return true;
  }
  // GenericFunctionTypeElements have the name we care about in the enclosing
  // element.
  if (e is GenericFunctionTypeElement) {
    if (e.enclosingElement.name.startsWith('_')) {
      return true;
    }
  }
  if (e is LibraryElement &&
      (e.identifier.startsWith('dart:_') ||
          e.identifier.startsWith('dart:nativewrappers/') ||
          ['dart:nativewrappers'].contains(e.identifier))) {
    return true;
  }
  if (e is LibraryElement) {
    List<String> locationParts = e.location.components[0].split(slashes);
    // TODO(jcollins-g): Implement real cross package detection
    if (locationParts.length >= 2 &&
        locationParts[0].startsWith('package:') &&
        locationParts[1] == 'src') return true;
  }
  return false;
}

bool hasPublicName(Element e) => !hasPrivateName(e);

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  String remainer = source.trimLeft();
  HtmlEscape sanitizer = const HtmlEscape();
  bool lineComments = remainer.startsWith('///') ||
      remainer.startsWith(sanitizer.convert('///'));
  bool blockComments = remainer.startsWith('/**') ||
      remainer.startsWith(sanitizer.convert('/**'));

  return source.split('\n').where((String line) {
    if (lineComments) {
      if (line.startsWith('///') || line.startsWith(sanitizer.convert('///'))) {
        return false;
      }
      lineComments = false;
      return true;
    } else if (blockComments) {
      if (line.contains('*/') || line.contains(sanitizer.convert('*/'))) {
        blockComments = false;
        return false;
      }
      if (line.startsWith('/**') || line.startsWith(sanitizer.convert('/**'))) {
        return false;
      }
      return false;
    }

    return true;
  }).join('\n');
}

/// Strip the common indent from the given source fragment.
String stripIndentFromSource(String source) {
  String remainer = source.trimLeft();
  String indent = source.substring(0, source.length - remainer.length);
  return source.split('\n').map((line) {
    line = line.trimRight();
    return line.startsWith(indent) ? line.substring(indent.length) : line;
  }).join('\n');
}
