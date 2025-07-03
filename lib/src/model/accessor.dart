// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/element/element2.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ExecutableMember;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';

/// Getters and setters.
class Accessor extends ModelElement {
  @override
  final PropertyAccessorElement2 element;

  /// The combo ([Field] or [TopLevelVariable]) containing this accessor.
  ///
  /// Initialized in [Field]'s constructor and in [TopLevelVariable]'s
  /// constructor.
  // TODO(srawlins): This might be super fragile. This field should somehow be
  // initialized by code inside this library.
  late final GetterSetterCombo enclosingCombo;

  Accessor(this.element, super.library, super.packageGraph,
      {ExecutableMember? super.originalMember});

  @override
  CharacterLocation? get characterLocation => element.isSynthetic
      ? enclosingCombo.characterLocation
      : super.characterLocation;

  @override
  ExecutableMember? get originalMember =>
      super.originalMember as ExecutableMember?;

  late final Callable modelType =
      getTypeFor((originalMember ?? element).type, library) as Callable;

  bool get isSynthetic => element.isSynthetic;

  /// The [enclosingCombo] where this element was defined.
  late final GetterSetterCombo definingCombo =
      getModelForElement(element.variable3!) as GetterSetterCombo;

  String get _sourceCode {
    if (!isSynthetic) {
      return super.sourceCode;
    }
    var modelNode = packageGraph.getModelNodeFor(definingCombo.element);
    return modelNode == null
        ? ''
        : const HtmlEscape().convert(modelNode.sourceCode);
  }

  @override
  String get sourceCode => _sourceCode;

  @override
  late final String documentationComment = () {
    if (isSynthetic) {
      /// Build a documentation comment for this accessor.
      return _hasSyntheticDocumentationComment
          ? definingCombo.documentationComment
          : '';
    }
    // TODO(srawlins): This doesn't seem right... the super value has delimiters
    // (like `///`), but this one doesn't?
    return stripCommentDelimiters(super.documentationComment);
  }();

  /// If this is a getter, assume we want synthetic documentation.
  ///
  /// If the [definingCombo] has a `nodoc` tag, we want synthetic documentation
  /// for a synthetic accessor just in case it is inherited somewhere down the
  /// line due to split inheritance.
  bool get _hasSyntheticDocumentationComment =>
      (isGetter || definingCombo.hasNodoc || _comboDocsAreIndependent) &&
      definingCombo.hasDocumentationComment;

  // If we're a setter, and a getter exists, do not add synthetic documentation
  // if the combo's documentation is actually derived from that getter.
  bool get _comboDocsAreIndependent {
    if (isSetter && definingCombo.hasGetter) {
      if (definingCombo.getter!.isSynthetic ||
          !definingCombo.documentationFrom.contains(this)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool get hasDocumentationComment => isSynthetic
      ? _hasSyntheticDocumentationComment
      : element.documentationComment != null;

  @override
  void warn(
    PackageWarning kind, {
    String? message,
    Iterable<Locatable> referredFrom = const [],
    Iterable<String> extendedDebug = const [],
  }) {
    enclosingCombo.warn(kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  @override
  ModelElement get enclosingElement => switch (element.enclosingElement2) {
        LibraryFragment enclosingCompilationUnit =>
          getModelForElement(enclosingCompilationUnit.element),
        _ => getModelFor(element.enclosingElement2, library)
      };

  @override
  String get filePath => enclosingCombo.filePath;

  @override
  String get aboveSidebarPath {
    final enclosingElement = this.enclosingElement;
    return switch (enclosingElement) {
      Container() => enclosingElement.sidebarPath,
      Library() => enclosingElement.sidebarPath,
      _ => throw StateError(
          'Enclosing element of $this should be Container or Library, but was '
          '${enclosingElement.runtimeType}')
    };
  }

  @override
  String? get belowSidebarPath => null;

  @override
  bool get isCanonical => enclosingCombo.isCanonical;

  @override
  String? get href => enclosingCombo.href;

  bool get isGetter => element is GetterElement;

  bool get isSetter => element is SetterElement;

  @override
  Kind get kind => Kind.accessor;

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  @override
  Map<String, CommentReferable> get referenceChildren =>
      enclosingCombo.referenceChildren;

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  @override
  Iterable<CommentReferable> get referenceParents =>
      enclosingCombo.referenceParents;
}

/// A getter or setter that is a member of a [Container].
class ContainerAccessor extends Accessor with ContainerMember, Inheritable {
  late final Container _enclosingElement;

  @override
  final bool isInherited;

  ContainerAccessor(super.element, super.library, super.packageGraph,
      [Container? enclosingElement])
      : isInherited = false {
    _enclosingElement = enclosingElement ?? super.enclosingElement as Container;
  }

  ContainerAccessor.inherited(
      super.element, super.library, super.packageGraph, this._enclosingElement,
      {super.originalMember})
      : isInherited = true;

  /// The index and values fields are never declared, and must be special cased.
  bool get _isEnumSynthetic =>
      enclosingCombo is EnumField && (name == 'index' || name == 'values');

  @override
  CharacterLocation? get characterLocation {
    if (_isEnumSynthetic) return enclosingElement.characterLocation;
    // TODO(jcollins-g): Remove the enclosingCombo case below once
    // https://github.com/dart-lang/sdk/issues/46154 is fixed.
    if (enclosingCombo is EnumField) return enclosingCombo.characterLocation;
    return super.characterLocation;
  }

  @override
  bool get isCovariant => isSetter && parameters.first.isCovariant;

  @override
  Container get enclosingElement => _enclosingElement;

  @override
  ContainerAccessor? get overriddenElement {
    assert(packageGraph.allLibrariesAdded);
    final parent = element.enclosingElement2;
    if (parent is! InterfaceElement2) {
      return null;
    }
    for (final supertype in parent.allSupertypes) {
      var accessor = isGetter
          ? supertype.getters
              .firstWhereOrNull((e) => e.lookupName == element.lookupName)
              ?.baseElement
          : supertype.setters
              .firstWhereOrNull((e) => e.lookupName == element.lookupName)
              ?.baseElement;
      if (accessor == null) {
        continue;
      }
      final parentContainer =
          getModelForElement(supertype.element3) as InheritingContainer;
      final possibleFields =
          parentContainer.declaredFields.where((f) => !f.isStatic);
      final fieldName = accessor.lookupName?.replaceFirst('=', '');
      final foundField =
          possibleFields.firstWhereOrNull((f) => f.element.name3 == fieldName);
      if (foundField == null) {
        continue;
      }
      final overridden = isGetter ? foundField.getter! : foundField.setter!;
      assert(!overridden.isInherited);
      return overridden;
    }
    return null;
  }
}
