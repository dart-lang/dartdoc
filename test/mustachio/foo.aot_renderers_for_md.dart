// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable

import 'dart:convert' as _i2;

import 'foo.dart' as _i1;

String renderFoo(_i1.Foo context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFoo_partial_foo_header_0(context0));
  buffer.write('''

s1: ''');
  buffer.writeEscaped(context0.s1.toString());
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
      buffer.writeEscaped(context2.toString());
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
    buffer.writeEscaped(context3.bar.s2.toString());
  }
  if (context0.baz == null) {
    buffer.write('''baz is null''');
  }

  return buffer.toString();
}

String _renderFoo_partial_foo_header_0(_i1.Foo context0) {
  final buffer = StringBuffer();
  buffer.write('''l1: ''');
  buffer.writeEscaped(context0.l1.toString());

  return buffer.toString();
}

String renderBar(_i1.Bar context0) {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderBaz(_i1.Baz context0) {
  final buffer = StringBuffer();

  return buffer.toString();
}

extension on StringBuffer {
  void writeEscaped(String value) {
    write(_i2.htmlEscape.convert(value));
  }
}
