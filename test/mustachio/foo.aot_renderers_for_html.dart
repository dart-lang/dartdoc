// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Some deduplicated render functions are generated but not used.
// TODO(srawlins): Detect these and do not write them.
// ignore_for_file: unused_element
// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable
// ignore_for_file: non_constant_identifier_names, unnecessary_string_escapes

// ignore_for_file: analyzer_use_new_elements

import 'dart:convert';

import 'foo.dart';

String renderBar() {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderBaz() {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderFoo(Foo context0) {
  final buffer = StringBuffer();
  buffer.write('''<div>
    ''');
  buffer.write(_renderFoo_partial_foo_header_0(context0));
  buffer.writeln();
  buffer.write('''    s1: ''');
  buffer.writeEscaped(context0.s1);
  buffer.writeln();
  buffer.write('''    b1? ''');
  if (context0.b1) {
    buffer.write('''yes''');
  }
  if (!context0.b1) {
    buffer.write('''no''');
  }
  buffer.writeln();
  buffer.write('''    l1:''');
  var context1 = context0.l1;
  for (var context2 in context1) {
    buffer.write('''item: ''');
    buffer.writeEscaped(context2.toString());
  }
  if (context0.l1.isEmpty) {
    buffer.write('''no items''');
  }
  buffer.writeln();
  buffer.write('''    baz:''');
  var context3 = context0.baz;
  if (context3 != null) {
    buffer.writeln();
    buffer.write('''    Baz has a ''');
    buffer.writeEscaped(context3.bar!.s2);
  }
  if (context0.baz == null) {
    buffer.write('''baz is null''');
  }
  buffer.writeln();
  buffer.write('''</div>''');

  return buffer.toString();
}

String _renderFoo_partial_foo_header_0(Foo context0) {
  final buffer = StringBuffer();
  buffer.write('''<div class="partial">
    l1: ''');
  buffer.writeEscaped(context0.l1.toString());
  buffer.writeln();
  buffer.write('''</div>''');

  return buffer.toString();
}

extension on StringBuffer {
  void writeEscaped(String? value) {
    write(htmlEscape.convert(value ?? ''));
  }
}
