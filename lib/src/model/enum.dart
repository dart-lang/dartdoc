// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/render/enum_field_renderer.dart';

class Enum extends InheritingContainer with TypeImplementing {
  Enum(ClassElement element, Library? library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  late final List<InheritingContainer?> inheritanceChain = [
    this,
    for (var container in superChain.modelElements)
      ...container.inheritanceChain,
    ...interfaces.expandInheritanceChain,
  ];

  @override
  String get kind => 'enum';

  @override
  String get relationshipsClass => 'eNum-relationships';
}

class EnumField extends Field {
  int? index;

  EnumField(FieldElement element, Library library, PackageGraph packageGraph,
      Accessor? getter, Accessor? setter)
      : super(element, library, packageGraph, getter as ContainerAccessor?,
            setter as ContainerAccessor?);

  EnumField.forConstant(this.index, FieldElement element, Library library,
      PackageGraph packageGraph, Accessor? getter)
      : super(
            element, library, packageGraph, getter as ContainerAccessor?, null);

  @override
  String get constantValueBase => _fieldRenderer.renderValue(this);

  /*@override
  List<DocumentationComment> get documentationFrom {
    if (name == 'values' || name == 'index') return [this];
    return super.documentationFrom;
  }*/

  @override
  String get extendedDocLink {
    // Ordinal members don't get extended doc links. Inherited members
    // (e.g. hashcode) follow the normal rules.
    if (index != null) return '';
    return super.extendedDocLink;
  }

  @override
  String? get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(!(canonicalLibrary == null || canonicalEnclosingContainer == null));
    assert(canonicalLibrary == library);
    assert(canonicalEnclosingContainer == enclosingElement);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.fileName}';
  }

  @override
  String get linkedName => name;

  @override
  bool get isCanonical {
    if (name == 'index') return false;
    // If this is something inherited from Object, e.g. hashCode, let the
    // normal rules apply.
    if (index == null) {
      return super.isCanonical;
    }
    // TODO(jcollins-g): We don't actually document this as a separate entity;
    //                   do that or change this to false and deal with the
    //                   consequences.
    return true;
  }

  @override
  String? get oneLineDoc => documentationAsHtml;

  @override
  Inheritable? get overriddenElement => null;

  EnumFieldRenderer get _fieldRenderer =>
      packageGraph.rendererFactory.enumFieldRenderer;
}
