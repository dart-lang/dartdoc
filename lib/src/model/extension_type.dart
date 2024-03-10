// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:meta/meta.dart';

class ExtensionType extends InheritingContainer with Constructable {
  @override
  final ExtensionTypeElement element;

  late final ElementType representationType =
      getTypeFor(element.representation.type, library);

  ExtensionType(this.element, super.library, super.packageGraph);

  @override
  Library get enclosingElement => library;

  @override
  Kind get kind => Kind.extensionType;

  @override
  bool get isAbstract => false;

  @override
  bool get isBase => false;

  @override
  bool get isInterface => false;

  @override
  bool get isMixinClass => false;

  @override
  bool get isSealed => false;

  @override
  late final List<Field> declaredFields = element.fields.map((field) {
    Accessor? getter, setter;
    final fieldGetter = field.getter;
    if (fieldGetter != null) {
      getter = ContainerAccessor(fieldGetter, library, packageGraph);
    }
    final fieldSetter = field.setter;
    if (fieldSetter != null) {
      setter = ContainerAccessor(fieldSetter, library, packageGraph);
    }
    return getModelForPropertyInducingElement(field, library,
        getter: getter, setter: setter) as Field;
  }).toList(growable: false);

  @override
  late final List<ModelElement> allModelElements = [
    ...super.allModelElements,
    ...constructors,
  ];

  @override
  late final List<InheritingContainer> inheritanceChain = [
    this,
    ...interfaceElements.expandInheritanceChain,
  ];

  @override
  String get filePath => '${library.dirName}/${fileStructure.fileName}';

  @override
  String get sidebarPath =>
      '${library.dirName}/$name-extension-type-sidebar.html';

  Map<String, CommentReferable>? _referenceChildren;
  @override
  Map<String, CommentReferable> get referenceChildren {
    return _referenceChildren ??= {
      ...representationType.referenceChildren,
      // Override `representationType` entries with local items.
      ...super.referenceChildren,
    };
  }

  @override
  @visibleForOverriding
  Iterable<MapEntry<String, CommentReferable>> get extraReferenceChildren =>
      const [];

  @override
  String get relationshipsClass => 'clazz-relationships';
}
