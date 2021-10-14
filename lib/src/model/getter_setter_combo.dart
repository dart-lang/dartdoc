// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.



import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart'
    show Expression, InstanceCreationExpression;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/element.dart'
    show ConstVariableElement;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';

/// Mixin for top-level variables and fields (aka properties)
mixin GetterSetterCombo on ModelElement {
  Accessor? get getter;

  Accessor? get setter;

  @override
  Iterable<Annotation> get annotations => [
        ...super.annotations,
        if (hasGetter) ...getter!.annotations,
        if (hasSetter) ...setter!.annotations,
      ];

  Iterable<Accessor> get allAccessors sync* {
    for (var a in [getter, setter]) {
      if (a != null) yield a;
    }
  }

  @protected
  Set<Feature> get comboFeatures => {
        if (hasExplicitGetter && hasPublicGetter) ...getter!.features,
        if (hasExplicitSetter && hasPublicSetter) ...setter!.features,
        if (readOnly && !isFinal && !isConst) Feature.readOnly,
        if (writeOnly) Feature.writeOnly,
        if (readWrite && !isLate) Feature.readWrite,
      };

  @override
  ModelElement? enclosingElement;

  bool get isInherited;

  Expression? get constantInitializer =>
      (element as ConstVariableElement).constantInitializer;

  String linkifyConstantValue(String original) {
    if (constantInitializer is! InstanceCreationExpression) return original;
    var creationExpression = constantInitializer as InstanceCreationExpression;
    var constructorName = creationExpression.constructorName.toString();
    Element? staticElement = creationExpression.constructorName.staticElement;
    if (staticElement == null) {
      warn(PackageWarning.missingConstantConstructor, message: constructorName);
      return original;
    }
    Constructor target = modelBuilder.fromElement(staticElement) as Constructor;
    Class targetClass = target.enclosingElement as Class;
    // TODO(jcollins-g): this logic really should be integrated into Constructor,
    // but that's not trivial because of linkedName's usage.
    if (targetClass.name == target.name) {
      return original.replaceAll(constructorName, target.linkedName!);
    }
    return original.replaceAll('${targetClass.name}.${target.name}',
        '${targetClass.linkedName}.${target.linkedName}');
  }

  String _buildConstantValueBase() {
    var result = constantInitializer?.toString() ?? '';
    return const HtmlEscape(HtmlEscapeMode.unknown).convert(result);
  }

  @override
  CharacterLocation? get characterLocation {
    // Handle all synthetic possibilities.  Ordinarily, warnings for
    // explicit setters/getters will be handled by those objects, but
    // if a warning comes up for an enclosing synthetic field we have to
    // put it somewhere.  So pick an accessor.
    if (element!.isSynthetic) {
      if (hasExplicitGetter) return getter!.characterLocation;
      if (hasExplicitSetter) return setter!.characterLocation;
      assert(false, 'Field and accessors can not all be synthetic');
    }
    return super.characterLocation;
  }

  String get constantValue => linkifyConstantValue(constantValueBase);

  String get constantValueTruncated =>
      linkifyConstantValue(truncateString(constantValueBase, 200));
  String? _constantValueBase;

  String get constantValueBase =>
      _constantValueBase ??= _buildConstantValueBase();

  bool get hasPublicGetter => hasGetter && getter!.isPublic!;

  bool get hasPublicSetter => hasSetter && setter!.isPublic!;

  @override
  bool get isPublic => hasPublicGetter || hasPublicSetter;

  List<DocumentationComment>? _documentationFrom;

  @override
  List<DocumentationComment>? get documentationFrom {
    if (_documentationFrom == null) {
      _documentationFrom = [];
      if (hasPublicGetter) {
        _documentationFrom!.addAll(getter!.documentationFrom!);
      } else if (hasPublicSetter) {
        _documentationFrom!.addAll(setter!.documentationFrom!);
      }
      if (_documentationFrom!.isEmpty ||
          _documentationFrom!.every((e) => e.documentationComment == '')) {
        _documentationFrom = super.documentationFrom;
      }
    }
    return _documentationFrom;
  }

  bool get hasAccessorsWithDocs =>
      (hasPublicGetter && !getter!.isSynthetic && getter!.hasDocumentation ||
          hasPublicSetter && !setter!.isSynthetic && setter!.hasDocumentation);

  bool get getterSetterBothAvailable => (hasPublicGetter &&
      getter!.hasDocumentation &&
      hasPublicSetter &&
      setter!.hasDocumentation);

  String? _oneLineDoc;

  @override
  String? get oneLineDoc {
    if (_oneLineDoc == null) {
      if (!hasAccessorsWithDocs) {
        _oneLineDoc = super.oneLineDoc;
      } else {
        var buffer = StringBuffer();
        if (hasPublicGetter && getter!.oneLineDoc!.isNotEmpty) {
          buffer.write(getter!.oneLineDoc);
        }
        if (hasPublicSetter && setter!.oneLineDoc!.isNotEmpty) {
          buffer.write(getterSetterBothAvailable ? "" : setter!.oneLineDoc);
        }
        _oneLineDoc = buffer.toString();
      }
    }
    return _oneLineDoc;
  }

  bool _documentationCommentComputed = false;
  String? _documentationComment;
  @override
  String get documentationComment => _documentationCommentComputed
      ? _documentationComment!
      : _documentationComment ??= () {
          _documentationCommentComputed = true;
          var docs = _getterSetterDocumentationComment;
          if (docs.isEmpty) return element!.documentationComment ?? '';
          return docs;
        }();

  @override
  bool get hasDocumentationComment =>
      _getterSetterDocumentationComment.isNotEmpty ||
      element!.documentationComment != null;

  String? __getterSetterDocumentationComment;

  /// Derive a documentation comment for the combo by copying documentation
  /// from the [getter] and/or [setter].
  String get _getterSetterDocumentationComment =>
      __getterSetterDocumentationComment ??= () {
        var buffer = StringBuffer();

        // Check for synthetic before public, always, or stack overflow.
        if (hasGetter && !getter!.isSynthetic && getter!.isPublic!) {
          assert(getter!.documentationFrom!.length == 1);
          var fromGetter = getter!.documentationFrom!.first;
          // We have to check against dropTextFrom here since documentationFrom
          // doesn't yield the real elements for GetterSetterCombos.
          if (!config!.dropTextFrom.contains(fromGetter.element!.library!.name)) {
            if (fromGetter.hasDocumentationComment) {
              buffer.write(fromGetter.documentationComment);
            }
          }
        }

        if (hasSetter && !setter!.isSynthetic && setter!.isPublic!) {
          assert(setter!.documentationFrom!.length == 1);
          var fromSetter = setter!.documentationFrom!.first;
          if (!config!.dropTextFrom.contains(fromSetter.element!.library!.name)) {
            if (fromSetter.hasDocumentationComment) {
              if (buffer.isNotEmpty) buffer.write('\n\n');
              buffer.write(fromSetter.documentationComment);
            }
          }
        }
        return buffer.toString();
      }();

  ElementType get modelType {
    if (hasGetter) return getter!.modelType.returnType;
    return setter!.parameters!.first.modelType;
  }

  @override
  bool get isCallable => hasSetter;

  @override
  bool get hasParameters => hasSetter;

  @override
  List<Parameter>? get parameters => setter!.parameters;

  @override
  String? get linkedParamsNoMetadata {
    if (hasSetter) return setter!.linkedParamsNoMetadata;
    return null;
  }

  bool get hasExplicitGetter => hasPublicGetter && !getter!.isSynthetic;

  bool get hasExplicitSetter => hasPublicSetter && !setter!.isSynthetic;

  bool get hasGetter => getter != null;

  bool get hasNoGetterSetter => !hasGetterOrSetter;

  bool get hasGetterOrSetter => hasExplicitGetter || hasExplicitSetter;

  bool get hasSetter => setter != null;

  bool get hasPublicGetterNoSetter => (hasPublicGetter && !hasPublicSetter);

  String get arrow {
    // →
    if (readOnly) return r'&#8594;';
    // ←
    if (writeOnly) return r'&#8592;';
    // ↔
    if (readWrite) return r'&#8596;';
    throw UnsupportedError(
        'GetterSetterCombo must be one of readOnly, writeOnly, or readWrite');
  }

  bool get readOnly => hasPublicGetter && !hasPublicSetter;

  bool get readWrite => hasPublicGetter && hasPublicSetter;

  bool get writeOnly => hasPublicSetter && !hasPublicGetter;

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    if (_referenceChildren == null) {
      _referenceChildren = {};
      if (hasParameters) {
        _referenceChildren!.addEntries(parameters!.explicitOnCollisionWith(this));
      }
      _referenceChildren!
          .addEntries(modelType.typeArguments.explicitOnCollisionWith(this));
    }
    return _referenceChildren!;
  }
}
