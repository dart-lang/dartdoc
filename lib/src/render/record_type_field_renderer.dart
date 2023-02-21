// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/type.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/element_type.dart';

/// Render HTML suitable for a single, wrapped line.
class RecordTypeFieldListHtmlRenderer extends _RecordTypeFieldListRenderer {
  const RecordTypeFieldListHtmlRenderer();

  @override
  String listItem(String item) => item;
  @override
  String orderedList(String listItems) => listItems;
  @override
  String annotation(String name) => '<span>$name</span>';

  @override
  String field(String name) => '<span class="field">$name</span>';
  @override
  String fieldName(String name) => '<span class="field-name">$name</span>';
  @override
  String typeName(String name) => '<span class="type-annotation">$name</span>';
}

class RecordTypeFieldListMdRenderer extends _RecordTypeFieldListRenderer {
  const RecordTypeFieldListMdRenderer();

  @override
  String annotation(String name) => name;

  @override
  String listItem(String item) => item;

  @override
  String orderedList(String listItems) => listItems;

  @override
  String field(String name) => name;

  @override
  String fieldName(String name) => name;

  @override
  String typeName(String name) => name;
}

abstract class _RecordTypeFieldListRenderer {
  const _RecordTypeFieldListRenderer();

  String listItem(String item);
  String orderedList(String listItems);
  String annotation(String name);
  String field(String name);
  String fieldName(String name);
  String typeName(String name);

  String renderLinkedFields(RecordElementType recordElementType) {
    final buffer = StringBuffer();

    void renderLinkedFieldSublist(
      List<RecordTypeField> fields, {
      required bool trailingComma,
      String openBracket = '',
      String closeBracket = '',
    }) {
      fields.forEachIndexed((index, field) {
        var prefix = '';
        var suffix = '';
        if (identical(field, fields.first)) {
          prefix = openBracket;
        }
        if (identical(field, fields.last)) {
          suffix += closeBracket;
          if (trailingComma) suffix += ', ';
        } else {
          suffix += ', ';
        }

        var fieldBuffer = StringBuffer();
        fieldBuffer.write(prefix);
        var modelType = recordElementType.modelBuilder
            .typeFrom(field.type, recordElementType.library);
        var linkedTypeName = typeName(modelType.linkedName);
        if (linkedTypeName.isNotEmpty) {
          fieldBuffer.write(linkedTypeName);
        }
        if (field is RecordTypeNamedField) {
          fieldBuffer.write(' ');
          fieldBuffer.write(fieldName(field.name));
        }
        fieldBuffer.write(suffix);
        buffer.write(listItem(this.field(fieldBuffer.toString())));
      });
    }

    if (recordElementType.positionalFields.isNotEmpty) {
      renderLinkedFieldSublist(
        recordElementType.positionalFields,
        trailingComma: recordElementType.namedFields.isNotEmpty,
      );
    }
    if (recordElementType.namedFields.isNotEmpty) {
      renderLinkedFieldSublist(
        recordElementType.namedFields,
        trailingComma: false,
        openBracket: '{',
        closeBracket: '}',
      );
    }
    return orderedList(buffer.toString());
  }
}
