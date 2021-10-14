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
  /// The combo ([Field] or [TopLevelVariable] containing this accessor.
  /// Initialized by the combo's constructor.
  late final GetterSetterCombo enclosingCombo;

  Accessor(PropertyAccessorElement? element, Library? library,
      PackageGraph packageGraph,
      [ExecutableMember? originalMember])
      : super(element, library, packageGraph, originalMember);

  @override
  CharacterLocation? get characterLocation {
    if (element!.nameOffset < 0) {
      assert(element!.isSynthetic, 'Invalid offset for non-synthetic element');
      // TODO(jcollins-g): switch to [element.nonSynthetic] after analyzer 1.8
      return enclosingCombo!.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  PropertyAccessorElement? get element => super.element as PropertyAccessorElement?;

  @override
  ExecutableMember? get originalMember => super.originalMember as ExecutableMember?;

  Callable? _modelType;
  Callable get modelType => (_modelType ??=
      modelBuilder.typeFrom((originalMember ?? element)!.type, library!) as Callable?)!;

  bool get isSynthetic => element!.isSynthetic;

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  GetterSetterCombo? _definingCombo;
  // The [enclosingCombo] where this element was defined.
  GetterSetterCombo? get definingCombo {
    if (_definingCombo == null) {
      var variable = element!.variable;
      _definingCombo = modelBuilder.fromElement(variable) as GetterSetterCombo?;
      assert(_definingCombo != null, 'Unable to find defining combo');
    }
    return _definingCombo;
  }

  String? _sourceCode;

  @override
  String? get sourceCode {
    if (_sourceCode == null) {
      if (isSynthetic) {
        _sourceCode = _sourceCodeRenderer.renderSourceCode(
            packageGraph.getModelNodeFor(definingCombo!.element)!.sourceCode!);
      } else {
        _sourceCode = super.sourceCode;
      }
    }
    return _sourceCode;
  }

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
          return definingCombo!.documentationComment ?? '';
        }
        return '';
      } ();

  /// If this is a getter, assume we want synthetic documentation.
  /// If the definingCombo has a nodoc tag, we want synthetic documentation
  /// for a synthetic accessor just in case it is inherited somewhere
  /// down the line due to split inheritance.
  bool get _hasSyntheticDocumentationComment =>
      (isGetter || definingCombo!.hasNodoc! || _comboDocsAreIndependent()) &&
      definingCombo!.hasDocumentationComment;

  // If we're a setter, and a getter exists, do not add synthetic
  // documentation if the combo's documentation is actually derived
  // from that getter.
  bool _comboDocsAreIndependent() {
    if (isSetter && definingCombo!.hasGetter) {
      if (definingCombo!.getter!.isSynthetic ||
          !definingCombo!.documentationFrom!.contains(this)) {
        return true;
      }
    }
    return false;
  }

  @override
  bool get hasDocumentationComment => isSynthetic
      ? _hasSyntheticDocumentationComment
      : element!.documentationComment != null;

  @override
  void warn(
    PackageWarning kind, {
    String? message,
    Iterable<Locatable> referredFrom = const [],
    Iterable<String> extendedDebug = const [],
  }) {
    enclosingCombo!.warn(kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  @override
  ModelElement? get enclosingElement {
    if (element!.enclosingElement is CompilationUnitElement) {
      return modelBuilder
          .fromElement(element!.enclosingElement.enclosingElement!);
    }

    return modelBuilder.from(element!.enclosingElement, library!);
  }

  @override
  String? get filePath => enclosingCombo!.filePath;

  @override
  bool get isCanonical => enclosingCombo!.isCanonical;

  @override
  String? get href {
    return enclosingCombo!.href;
  }

  bool get isGetter => element!.isGetter;

  bool get isSetter => element!.isSetter;

  @override
  String get kind => 'accessor';

  String? _namePart;

  @override
  String? get namePart {
    _namePart ??= super.namePart!.split('=').first;
    return _namePart;
  }

  @override

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  Map<String, CommentReferable> get referenceChildren =>
      enclosingCombo!.referenceChildren;

  @override

  /// Accessors should never be participating directly in comment reference
  /// lookups.
  Iterable<CommentReferable> get referenceParents =>
      enclosingCombo!.referenceParents;
}

/// A getter or setter that is a member of a [Container].
class ContainerAccessor extends Accessor with ContainerMember, Inheritable {
  /// The index and values fields are never declared, and must be special cased.
  bool get _isEnumSynthetic =>
      enclosingCombo is EnumField && (name == 'index' || name == 'values');

  @override
  CharacterLocation? get characterLocation {
    if (_isEnumSynthetic) return enclosingElement!.characterLocation;
    // TODO(jcollins-g): Remove the enclosingCombo case below once
    // https://github.com/dart-lang/sdk/issues/46154 is fixed.
    if (enclosingCombo is EnumField) return enclosingCombo!.characterLocation;
    return super.characterLocation;
  }

  ModelElement? _enclosingElement;
  bool _isInherited = false;

  @override
  bool get isCovariant => isSetter && parameters!.first.isCovariant;

  ContainerAccessor(PropertyAccessorElement? element, Library? library,
      PackageGraph packageGraph)
      : super(element, library, packageGraph);

  ContainerAccessor.inherited(PropertyAccessorElement element, Library? library,
      PackageGraph packageGraph, this._enclosingElement,
      {ExecutableMember? originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  Container? get enclosingElement {
    _enclosingElement ??= super.enclosingElement;
    return _enclosingElement as Container?;
  }

  bool _overriddenElementIsSet = false;
  ModelElement? _overriddenElement;

  @override
  ContainerAccessor? get overriddenElement {
    assert(packageGraph.allLibrariesAdded);
    if (!_overriddenElementIsSet) {
      _overriddenElementIsSet = true;
      var parent = element!.enclosingElement;
      if (parent is ClassElement) {
        for (var t in parent.allSupertypes) {
          Element? accessor =
              isGetter ? t.getGetter(element!.name) : t.getSetter(element!.name);
          if (accessor != null) {
            accessor = accessor.declaration;
            InheritingContainer parentContainer =
                modelBuilder.fromElement(t.element) as InheritingContainer;
            var possibleFields = <Field>[];
            possibleFields.addAll(parentContainer.instanceFields);
            possibleFields.addAll(parentContainer.staticFields);
            var fieldName = accessor!.name!.replaceFirst('=', '');
            var foundField = possibleFields.firstWhereOrNull(
                (f) => f.element!.name == fieldName);
            if (foundField != null) {
              if (isGetter) {
                _overriddenElement = foundField.getter;
              } else {
                _overriddenElement = foundField.setter;
              }
              assert(!(_overriddenElement as ContainerAccessor).isInherited);
              break;
            }
          }
        }
      }
    }
    return _overriddenElement as ContainerAccessor?;
  }
}
