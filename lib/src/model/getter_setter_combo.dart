// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/ast/ast.dart'
    show Expression, InstanceCreationExpression;
import 'package:analyzer/dart/element/element2.dart' show Annotatable;
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/element.dart'
    show ConstVariableElement;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/annotation.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/class.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/constructor.dart';
import 'package:dartdoc/src/model/documentation_comment.dart';
import 'package:dartdoc/src/model/enum.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/parameter.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:meta/meta.dart';

/// Mixin for top-level variables and fields (aka properties).
mixin GetterSetterCombo on ModelElement {
  Accessor? get getter;

  Accessor? get setter;

  @override
  List<Annotation> get annotations => [
        ...super.annotations,
        if (hasGetter) ...getter!.annotations,
        if (hasSetter) ...setter!.annotations,
      ];

  List<Accessor> get allAccessors {
    final getter = this.getter;
    final setter = this.setter;
    if (getter == null) {
      return setter == null ? const [] : [setter];
    } else {
      return setter == null ? [getter] : [getter, setter];
    }
  }

  @protected
  Set<Attribute> get comboAttributes => {
        if (hasExplicitGetter && hasPublicGetter) ...getter!.attributes,
        if (hasExplicitSetter && hasPublicSetter) ...setter!.attributes,
        if (readOnly && !isFinal && !isConst) Attribute.noSetter,
        if (writeOnly) Attribute.noGetter,
        if (readWrite && !isLate) Attribute.getterSetterPair,
      };

  @override
  ModelElement get enclosingElement;

  bool get isInherited;

  @override
  // Food for mustachio; because this is a mixin, mustachio can't figure out
  // that this implicitly has a `name` property.
  String get name;

  @override
  String get fileName => isConst
      ? '$name-constant.html'
      : name == 'index'
          ? '$name-property.html'
          : '$name.html';

  /// Whether this has a constant value which should be displayed.
  bool get hasConstantValueForDisplay => false;

  late final Expression? _constantInitializer =
      (element.firstFragment as ConstVariableElement).constantInitializer;

  String linkifyConstantValue(String original) {
    if (_constantInitializer is! InstanceCreationExpression) return original;

    var e = _constantInitializer.constructorName.element;
    if (e == null) return original;

    var target = getModelForElement(e) as Constructor;
    var enclosingElement = target.enclosingElement;
    if (enclosingElement is! Class) return original;

    // TODO(jcollins-g): this logic really should be integrated into
    // `Constructor`, but that's not trivial because of `linkedName`'s usage.
    if (target.isUnnamedConstructor) {
      var parts = target.linkedNameParts;
      // We don't want the `.new` representation of an unnamed constructor.
      var linkedName = '${parts.tag}${enclosingElement.name}${parts.endTag}';
      return original.replaceAll(enclosingElement.name, linkedName);
    }
    return original.replaceAll('${enclosingElement.name}.${target.name}',
        '${enclosingElement.linkedName}.${target.linkedName}');
  }

  @override
  CharacterLocation? get characterLocation {
    if (enclosingElement is Enum) {
      if (name == 'values') {
        return null;
      } else if (name == 'index') {
        return null;
      }
    }
    // Handle all synthetic possibilities.  Ordinarily, warnings for
    // explicit setters/getters will be handled by those objects, but
    // if a warning comes up for an enclosing synthetic field we have to
    // put it somewhere.  So pick an accessor.
    if (element.isSynthetic) {
      if (hasExplicitGetter) return getter!.characterLocation;
      if (hasExplicitSetter) return setter!.characterLocation;
      assert(false, 'Field and accessors can not all be synthetic: $element');
    }
    return super.characterLocation;
  }

  String get constantValue => linkifyConstantValue(constantValueBase);

  String get constantValueTruncated =>
      linkifyConstantValue(truncateString(constantValueBase, 200));

  /// The base text for this property's constant value as an unlinked String.
  late final String constantValueBase = () {
    if (_constantInitializer == null) {
      return '';
    }

    var initializerString = _constantInitializer.toString();

    final self = this;
    if (self is! EnumField ||
        _constantInitializer is! InstanceCreationExpression) {
      return _htmlEscape.convert(initializerString);
    }

    initializerString = 'const $initializerString';

    var isImplicitConstructorCall =
        _constantInitializer.constructorName.element?.isDefaultConstructor ??
            false;
    if (isImplicitConstructorCall) {
      // For an enum value with an implicit constructor call (like
      // `enum E { one, two; }`), `constantInitializer.toString()` does not
      // include the implicit enum index argument (it is something like
      // `const E()`). We must manually include it. See
      // https://github.com/dart-lang/sdk/issues/54988.
      initializerString =
          initializerString.replaceFirst('()', '(${self.index})');
    }
    return _htmlEscape.convert(initializerString);
  }();

  static const _htmlEscape = HtmlEscape(HtmlEscapeMode.unknown);

  late final bool hasPublicGetter = hasGetter && getter!.isPublic;

  late final bool hasPublicSetter = hasSetter && setter!.isPublic;

  @override
  bool get isPublic => hasPublicGetter || hasPublicSetter;

  @override
  late final List<DocumentationComment> documentationFrom = () {
    var comments = [
      if (hasPublicGetter)
        ...getter!.documentationFrom
      else if (hasPublicSetter)
        ...setter!.documentationFrom,
    ];
    return (comments.isEmpty ||
            comments.every((e) => e.documentationComment == ''))
        ? super.documentationFrom
        : comments;
  }();

  bool get hasAccessorsWithDocs =>
      hasPublicGetter && !getter!.isSynthetic && getter!.hasDocumentation ||
      hasPublicSetter && !setter!.isSynthetic && setter!.hasDocumentation;

  bool get getterSetterBothAvailable =>
      hasPublicGetter &&
      getter!.hasDocumentation &&
      hasPublicSetter &&
      setter!.hasDocumentation;

  @override
  late final String oneLineDoc = () {
    if (!hasAccessorsWithDocs) {
      return super.oneLineDoc;
    } else {
      var buffer = StringBuffer();
      if (hasPublicGetter && getter!.oneLineDoc.isNotEmpty) {
        buffer.write(getter!.oneLineDoc);
      }
      if (hasPublicSetter &&
          setter!.oneLineDoc.isNotEmpty &&
          !getterSetterBothAvailable) {
        buffer.write(setter!.oneLineDoc);
      }
      return buffer.toString();
    }
  }();

  @override
  late final String documentationComment =
      _getterSetterDocumentationComment.isEmpty
          ? (element as Annotatable).documentationComment ?? ''
          : _getterSetterDocumentationComment;

  @override
  bool get hasDocumentationComment =>
      _getterSetterDocumentationComment.isNotEmpty ||
      (element as Annotatable).documentationComment != null;

  /// Derives a documentation comment for the combo by copying documentation
  /// from the [getter] and/or [setter].
  late final String _getterSetterDocumentationComment = () {
    // Check for synthetic before public, always, or stack overflow.
    var getterComment = '';
    if (hasGetter) {
      final getter = this.getter!;
      if (!getter.isSynthetic && getter.isPublic) {
        assert(getter.documentationFrom.length == 1);
        var fromGetter = getter.documentationFrom.first;
        if (fromGetter.hasDocumentationComment) {
          getterComment = fromGetter.documentationComment;
        }
      }
    }

    if (!hasSetter) {
      return getterComment;
    }

    final setter = this.setter!;
    if (setter.isSynthetic || !setter.isPublic) return getterComment;

    assert(setter.documentationFrom.length == 1);
    var fromSetter = setter.documentationFrom.first;
    if (fromSetter.hasDocumentationComment) {
      return getterComment.isEmpty
          ? fromSetter.documentationComment
          : '$getterComment\n\n${fromSetter.documentationComment}';
    } else {
      return getterComment;
    }
  }();

  ElementType get modelType {
    if (hasGetter) return getter!.modelType.returnType;
    return setter!.parameters.first.modelType;
  }

  @override
  bool get isCallable => hasSetter;

  @override
  bool get hasParameters => hasSetter;

  @override
  List<Parameter> get parameters => setter!.parameters;

  @override
  String? get linkedParamsNoMetadata => setter?.linkedParamsNoMetadata;

  bool get hasExplicitGetter => hasPublicGetter && !getter!.isSynthetic;

  bool get hasExplicitSetter => hasPublicSetter && !setter!.isSynthetic;

  bool get hasGetter => getter != null;

  bool get hasGetterOrSetter => hasExplicitGetter || hasExplicitSetter;

  bool get hasSetter => setter != null;

  bool get hasPublicGetterNoSetter => hasPublicGetter && !hasPublicSetter;

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

  // TODO(srawlins): This should be private.
  bool get readOnly => hasPublicGetter && !hasPublicSetter;

  // TODO(srawlins): This should be private.
  bool get readWrite => hasPublicGetter && hasPublicSetter;

  // TODO(srawlins): This should be private.
  bool get writeOnly => hasPublicSetter && !hasPublicGetter;

  @override
  late final Map<String, CommentReferable> referenceChildren = {
    if (hasParameters) ...parameters.explicitOnCollisionWith(this),
    ...modelType.typeArguments.explicitOnCollisionWith(this),
  };
}
