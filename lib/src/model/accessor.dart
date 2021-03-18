// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show ExecutableMember;
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';

/// Getters and setters.
class Accessor extends ModelElement implements EnclosedElement {
  GetterSetterCombo enclosingCombo;

  Accessor(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph,
      [ExecutableMember /*?*/ originalMember])
      : super(element, library, packageGraph, originalMember);

  @override
  PropertyAccessorElement get element => super.element;

  @override
  ExecutableMember get originalMember => super.originalMember;

  CallableElementTypeMixin _modelType;
  CallableElementTypeMixin get modelType => _modelType ??=
      ElementType.from((originalMember ?? element).type, library, packageGraph);

  bool get isSynthetic => element.isSynthetic;

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  GetterSetterCombo _definingCombo;
  // The [enclosingCombo] where this element was defined.
  GetterSetterCombo get definingCombo {
    if (_definingCombo == null) {
      var variable = element.variable;
      _definingCombo = ModelElement.fromElement(variable, packageGraph);
      assert(_definingCombo != null, 'Unable to find defining combo');
    }
    return _definingCombo;
  }

  String _sourceCode;

  @override
  String get sourceCode {
    if (_sourceCode == null) {
      if (isSynthetic) {
        _sourceCode = _sourceCodeRenderer.renderSourceCode(
            packageGraph.getModelNodeFor(definingCombo.element).sourceCode);
      } else {
        _sourceCode = super.sourceCode;
      }
    }
    return _sourceCode;
  }

  @override
  String computeDocumentationComment() {
    if (isSynthetic) {
      // If we're a setter, only display something if we have something different than the getter.
      // TODO(jcollins-g): modify analyzer to do this itself?
      if (isGetter ||
          definingCombo.hasNodoc ||
          (isSetter &&
              definingCombo.hasGetter &&
              definingCombo.getter.documentationComment !=
                  definingCombo.documentationComment)) {
        return stripComments(definingCombo.documentationComment);
      } else {
        return '';
      }
    }
    return stripComments(super.computeDocumentationComment());
  }

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    enclosingCombo.warn(kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  @override
  ModelElement get enclosingElement {
    if (element.enclosingElement is CompilationUnitElement) {
      return packageGraph.findButDoNotCreateLibraryFor(
          element.enclosingElement.enclosingElement);
    }

    return ModelElement.from(element.enclosingElement, library, packageGraph);
  }

  @override
  String get filePath => enclosingCombo.filePath;

  @override
  bool get isCanonical => enclosingCombo.isCanonical;

  @override
  String get href {
    return enclosingCombo.href;
  }

  bool get isGetter => element.isGetter;

  bool get isSetter => element.isSetter;

  @override
  String get kind => 'accessor';

  String _namePart;

  @override
  String get namePart {
    _namePart ??= super.namePart.split('=').first;
    return _namePart;
  }
}

/// A getter or setter that is a member of a [Container].
class ContainerAccessor extends Accessor with ContainerMember, Inheritable {
  /// Factory will return an [ContainerAccessor] with isInherited = true
  /// if [element] is in [inheritedAccessors].
  factory ContainerAccessor.from(PropertyAccessorElement element,
      Set<PropertyAccessorElement> inheritedAccessors, Class enclosingClass) {
    ContainerAccessor accessor;
    if (element == null) return null;
    if (inheritedAccessors.contains(element)) {
      accessor = ModelElement.from(
          element, enclosingClass.library, enclosingClass.packageGraph,
          enclosingContainer: enclosingClass);
    } else {
      accessor = ModelElement.from(
          element, enclosingClass.library, enclosingClass.packageGraph);
    }
    return accessor;
  }

  ModelElement _enclosingElement;
  bool _isInherited = false;

  @override
  bool get isCovariant => isSetter && parameters.first.isCovariant;

  ContainerAccessor(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph)
      : super(element, library, packageGraph);

  ContainerAccessor.inherited(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph, this._enclosingElement,
      {ExecutableMember originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  Container get enclosingElement {
    _enclosingElement ??= super.enclosingElement;
    return _enclosingElement;
  }

  bool _overriddenElementIsSet = false;
  ModelElement _overriddenElement;

  @override
  ContainerAccessor get overriddenElement {
    assert(packageGraph.allLibrariesAdded);
    if (!_overriddenElementIsSet) {
      _overriddenElementIsSet = true;
      var parent = element.enclosingElement;
      if (parent is ClassElement) {
        for (var t in parent.allSupertypes) {
          Element accessor =
              isGetter ? t.getGetter(element.name) : t.getSetter(element.name);
          if (accessor != null) {
            accessor = accessor.declaration;
            Class parentClass =
                ModelElement.fromElement(t.element, packageGraph);
            var possibleFields = <Field>[];
            possibleFields.addAll(parentClass.instanceFields);
            possibleFields.addAll(parentClass.staticFields);
            var fieldName = accessor.name.replaceFirst('=', '');
            var foundField = possibleFields.firstWhere(
                (f) => f.element.name == fieldName,
                orElse: () => null);
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
    return _overriddenElement;
  }
}
