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
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/element_type.dart';

final Map<String, String> _fileContents = <String, String>{};

/// Render HTML in an extended vertical format using <ol> tag.
class ParameterRendererHtmlList extends ParameterRendererHtml {
  ParameterRendererHtmlList({bool showMetadata = true, bool showNames = true})
      : super(showMetadata: showMetadata, showNames: showNames);
  @override
  String listItem(String listItem) => '<li>$listItem</li>\n';
  @override
  // TODO(jcollins-g): consider comma separated lists and more advanced css.
  String orderedList(String listItems) =>
      '<ol class="parameter-list">$listItems</ol>\n';
}

/// Render HTML suitable for a single, wrapped line.
class ParameterRendererHtml extends ParameterRenderer {
  @override
  final bool showMetadata;
  @override
  final bool showNames;
  ParameterRendererHtml({this.showMetadata = true, this.showNames = true});

  @override
  String listItem(String listItem) => '${listItem}<wbr>';
  @override
  String orderedList(String listItems) => listItems;
  @override
  String annotation(String annotation) => '<span>$annotation</span>';
  @override
  String covariant(String covariant) => '<span>$covariant</span>';
  @override
  String defaultValue(String defaultValue) =>
      '<span class="default-value">$defaultValue</span>';
  @override
  String parameter(String parameter, String htmlId) =>
      '<span class="parameter" id="${htmlId}">$parameter</span>';
  @override
  String parameterName(String parameterName) =>
      '<span class="parameter-name">$parameterName</span>';
  @override
  String typeName(String typeName) =>
      '<span class="type-annotation">$typeName</span>';
  @override
  String required(String required) => '<span>$required</span>';
}

abstract class ParameterRenderer {
  bool get showMetadata;
  bool get showNames;

  String listItem(String item);
  String orderedList(String listItems);
  String annotation(String annotation);
  String covariant(String covariant);
  String defaultValue(String defaultValue);
  String parameter(String parameter, String id);
  String parameterName(String parameterName);
  String typeName(String typeName);
  String required(String required);

  String _linkedParameterSublist(List<Parameter> parameters, bool trailingComma,
      {String thisOpenBracket = '', String thisCloseBracket = ''}) {
    StringBuffer builder = StringBuffer();
    parameters.forEach((p) {
      String prefix = '';
      String suffix = '';
      if (identical(p, parameters.first)) {
        prefix = thisOpenBracket;
      }
      if (identical(p, parameters.last)) {
        suffix += thisCloseBracket;
        if (trailingComma) suffix += ', ';
      } else {
        suffix += ', ';
      }
      builder.write(
          listItem(parameter(prefix + renderParam(p) + suffix, p.htmlId)));
    });
    return builder.toString();
  }

  String linkedParams(List<Parameter> parameters) {
    List<Parameter> positionalParams =
        parameters.where((Parameter p) => p.isRequiredPositional).toList();
    List<Parameter> optionalPositionalParams =
        parameters.where((Parameter p) => p.isOptionalPositional).toList();
    List<Parameter> namedParams =
        parameters.where((Parameter p) => p.isNamed).toList();

    String positional = '', optional = '', named = '';
    if (positionalParams.isNotEmpty) {
      positional = _linkedParameterSublist(positionalParams,
          optionalPositionalParams.isNotEmpty || namedParams.isNotEmpty);
    }
    if (optionalPositionalParams.isNotEmpty) {
      optional = orderedList(_linkedParameterSublist(
          optionalPositionalParams, namedParams.isNotEmpty,
          thisOpenBracket: '[', thisCloseBracket: ']'));
    }
    if (namedParams.isNotEmpty) {
      named = orderedList(_linkedParameterSublist(namedParams, false,
          thisOpenBracket: '{', thisCloseBracket: '}'));
    }
    return (orderedList(positional + optional + named));
  }

  String renderParam(Parameter param) {
    StringBuffer buf = StringBuffer();
    ElementType paramModelType = param.modelType;

    if (showMetadata && param.hasAnnotations) {
      buf.write(param.annotations.map(annotation).join(' ') + ' ');
    }
    if (param.isRequiredNamed) {
      buf.write(required('required') + ' ');
    }
    if (param.isCovariant) {
      buf.write(covariant('covariant') + ' ');
    }
    if (paramModelType is CallableElementTypeMixin ||
        paramModelType.type is FunctionType) {
      String returnTypeName;
      if (paramModelType.isTypedef) {
        returnTypeName = paramModelType.linkedName;
      } else {
        returnTypeName = paramModelType.createLinkedReturnTypeName();
      }
      buf.write(typeName(returnTypeName));
      if (showNames) {
        buf.write(' ${parameterName(param.name)}');
      } else if (paramModelType.isTypedef ||
          paramModelType is CallableAnonymousElementType ||
          paramModelType.type is FunctionType) {
        buf.write(' ${parameterName(paramModelType.name)}');
      }
      if (!paramModelType.isTypedef && paramModelType is DefinedElementType) {
        buf.write('(');
        buf.write(linkedParams(paramModelType.element.parameters));
        buf.write(')');
      }
      if (!paramModelType.isTypedef && paramModelType.type is FunctionType) {
        buf.write('(');
        buf.write(
            linkedParams((paramModelType as UndefinedElementType).parameters));
        buf.write(')');
      }
    } else if (param.modelType != null) {
      String linkedTypeName = paramModelType.linkedName;
      if (linkedTypeName.isNotEmpty) {
        buf.write(typeName(linkedTypeName));
        if (showNames && param.name.isNotEmpty) {
          buf.write(' ');
        }
      }
      if (showNames && param.name.isNotEmpty) {
        buf.write(parameterName(param.name));
      }
    }

    if (param.hasDefaultValue) {
      if (param.isNamed) {
        buf.write(': ');
      } else {
        buf.write(' = ');
      }
      buf.write(defaultValue(param.defaultValue));
    }
    return buf.toString();
  }
}

String linkedParams(List<Parameter> parameters,
    {showMetadata = true, showNames = true, asList = false}) {
  if (asList) {
    return ParameterRendererHtmlList(
            showMetadata: showMetadata, showNames: showNames)
        .linkedParams(parameters);
  }
  return ParameterRendererHtml(showMetadata: showMetadata, showNames: showNames)
      .linkedParams(parameters);
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
