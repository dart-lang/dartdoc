// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable

// It is hard to track exact imports without using package:code_builder.
// ignore_for_file: unused_import

import 'dart:convert' show htmlEscape;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'foo.dart';

String renderFoo(Foo context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFoo_partial_foo_header_0(context0));
  buffer.write('''

s1: ''');
  buffer.write(htmlEscape.convert(context0.s1.toString()));
  buffer.write('''
b1? ''');
  if (context0.b1 == true) {
    buffer.write('''yes''');
  }
  if (context0.b1 != true) {
    buffer.write('''no''');
  }
  buffer.write('''
l1:''');
  var context1 = context0.l1;
  if (context1 != null) {
    for (var context2 in context1) {
      buffer.write('''item: ''');
      buffer.write(htmlEscape.convert(context2.toString()));
    }
  }
  if (context0.l1?.isEmpty ?? true) {
    buffer.write('''no items''');
  }
  buffer.write('''
baz:''');
  var context3 = context0.baz;
  if (context3 != null) {
    buffer.write('''
Baz has a ''');
    buffer.write(htmlEscape.convert(context3.bar.s2.toString()));
  }
  if (context0.baz == null) {
    buffer.write('''baz is null''');
  }
  return buffer.toString();
}

String _renderFoo_partial_foo_header_0(Foo context0) {
  final buffer = StringBuffer();
  buffer.write('''l1: ''');
  buffer.write(htmlEscape.convert(context0.l1.toString()));
  return buffer.toString();
}

String renderBar(Bar context0) {
  final buffer = StringBuffer();
  return buffer.toString();
}

String renderBaz(Baz context0) {
  final buffer = StringBuffer();
  return buffer.toString();
}
