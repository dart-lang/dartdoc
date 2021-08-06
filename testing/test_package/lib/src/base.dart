// @dart=2.9

library two_exports.src.base;

import '../fake.dart';

import 'local_scope.dart';

class BaseClass extends WithGetterAndSetter {}

class BaseWithMembers {
  int aField;

  /// Here is some documentation that links to [aNotReexportedVariable]
  /// for documentationFrom processing.
  bool anotherField;

  static aStaticMethod() {}

  static String aStaticField;

  BaseWithMembers() {}

  BaseWithMembers.aConstructor() {}
}
