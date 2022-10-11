// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
// ignore: implementation_imports
import 'package:analyzer/src/dart/element/member.dart' show ExecutableMember;
import 'package:collection/collection.dart' show IterableExtension;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';

/// Getters and setters.
class Accessor extends ModelElement implements EnclosedElement {
  @override
  final PropertyAccessorElement element;

  /// The combo ([Field] or [TopLevelVariable]) containing this accessor.
  /// Initialized by the combo's constructor.
  late final GetterSetterCombo enclosingCombo;

  Accessor(this.element, super.library, super.packageGraph,
      [ExecutableMember? super.originalMember]);

  @override
  CharacterLocation? get characterLocation {
    if (element.nameOffset < 0) {
      assert(element.isSynthetic, 'Invalid offset for non-synthetic element');
      // TODO(jcollins-g): switch to [element.nonSynthetic] after analyzer 1.8
      return enclosingCombo.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  ExecutableMember? get originalMember =>
      super.originalMember as ExecutableMember?;

  late final Callable modelType = modelBuilder.typeFrom(
      (originalMember ?? element).type, library) as Callable;

  bool get isSynthetic => element.isSynthetic;

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  // The [enclosingCombo] where this element was defined.
  late final GetterSetterCombo definingCombo =
      modelBuilder.fromElement(element.variable) as GetterSetterCombo;

  late final String _sourceCode = isSynthetic
      ? _sourceCodeRenderer.renderSourceCode(
          packageGraph.getModelNodeFor(definingCombo.element)!.sourceCode)
      : super.sourceCode;

  @override
  String get sourceCode => _sourceCode;

  bool _documentationCommentComputed = false;
  String? _documentationComment;
  @override
  String get documentationComment => _documentationCommentComputed
      ? _documentationComment!
      : _documentationComment ??= () {
          _documentationCommentComputed = true;
          if (isSynthetic) {
            return _syntheticDocumentationComment;
          }
          return stripComments(super.documentationComment);
        }();

  /// Build a documentation comment for this accessor assuming it is synthetic.
  /// Value here is not useful if [isSynthetic] is false.
  late final String _syntheticDocumentationComment = () {
    if (_hasSyntheticDocumentationComment) {
      return definingCombo.documentationComment;
    }
    return '';
  }();

  /// If this is a getter, assume we want synthetic documentation.
  /// If the definingCombo has a nodoc tag, we want synthetic documentation
  /// for a synthetic accessor just in case it is inherited somewhere
  /// down the line due to split inheritance.
  bool get _hasSyntheticDocumentationComment =>
      (isGetter || definingCombo.hasNodoc || _comboDocsAreIndependent) &&
      definingCombo.hasDocumentationComment;

  // If we're a setter, and a getter exists, do not add synthetic
  // documentation if the combo's documentation is actually derived
  // from that getter.
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
  ModelElement get enclosingElement {
    if (element.enclosingElement3 is CompilationUnitElement) {
      return modelBuilder
          .fromElement(element.enclosingElement3.enclosingElement3!);
    }

    return modelBuilder.from(element.enclosingElement3, library);
  }

  @override
  String? get filePath => enclosingCombo.filePath;

  @override
  bool get isCanonical => enclosingCombo.isCanonical;

  @override
  String? get href {
    return enclosingCombo.href;
  }

  bool get isGetter => element.isGetter;

  bool get isSetter => element.isSetter;

  @override
  String get kind => 'accessor';

  late final String _namePart = super.namePart.split('=').first;

  @override
  String get namePart => _namePart;

  @override

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  Map<String, CommentReferable> get referenceChildren =>
      enclosingCombo.referenceChildren;

  @override

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  Iterable<CommentReferable> get referenceParents =>
      enclosingCombo.referenceParents;
}

/// A getter or setter that is a member of a [Container].
class ContainerAccessor extends Accessor with ContainerMember, Inheritable {
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

  late final Container _enclosingElement;
  bool _isInherited = false;

  @override
  bool get isCovariant => isSetter && parameters.first.isCovariant;

  ContainerAccessor(super.element, super.library, super.packageGraph) {
    _enclosingElement = super.enclosingElement as Container;
  }

  ContainerAccessor.inherited(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph, this._enclosingElement,
      {ExecutableMember? originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  Container get enclosingElement => _enclosingElement;

  @override
  late final ContainerAccessor? overriddenElement = () {
    assert(packageGraph.allLibrariesAdded);
    var parent = element.enclosingElement3;
    if (parent is InterfaceElement) {
      for (var t in parent.allSupertypes) {
        var accessor =
            isGetter ? t.getGetter(element.name) : t.getSetter(element.name);
        if (accessor != null) {
          accessor = accessor.declaration;
          var parentContainer =
              modelBuilder.fromElement(t.element2) as InheritingContainer;
          var possibleFields = [
            ...parentContainer.instanceFields,
            ...parentContainer.staticFields,
          ];
          var fieldName = accessor.name.replaceFirst('=', '');
          var foundField = possibleFields
              .firstWhereOrNull((f) => f.element.name == fieldName);
          if (foundField != null) {
            final ContainerAccessor element;
            if (isGetter) {
              element = foundField.getter!;
            } else {
              element = foundField.setter!;
            }
            assert(!element.isInherited);
            return element;
          }
        }
      }
    }
  }();
}
