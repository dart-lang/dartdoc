/// a library. testing string escaping: `var s = 'a string'` <cool>
library ex;

import 'dart:async';
import 'src/mylib.dart' show Helper;
export 'src/mylib.dart' show Helper;
export 'dart:core' show deprecated, Deprecated;
export 'fake.dart' show Cool;

int function1(String s, bool b, lastParam) => 5;

double number;

/// top level var <nodoc>
const DO_NOT_DOCUMENT = 'not documented';

get y => 2;

const String COLOR = 'red';
const String COLOR_GREEN = 'green';
const String COLOR_ORANGE = 'orange';
const String COMPLEX_COLOR = 'red' + '-' + 'green' + '-' + 'blue';
const ConstantCat MY_CAT = const ConstantCat('tabby');

typedef String processMessage<T>(String msg);

/// This should [not work].
const incorrectDocReferenceFromEx = 'doh';

/// This is the same name as a top-level const from the fake lib.
const incorrectDocReference = 'same name as const from fake';

@deprecated
int get deprecatedGetter => null;

@deprecated
void set deprecatedSetter(int value) {}

@deprecated
int deprecatedField;

/**
 * class <nodoc>
 */
class unDocumented {
  String s;
}

/// Sample class [String]
class Apple {
  static const int n = 5;
  static String string = 'hello';
  String _s2;

  /// The read-write field `m`.
  int m = 0;

  /// <nodoc> no docs
  int notDocumented;

  ///Constructor
  Apple();

  factory Apple.fromString(String s) {
    return new Apple._internal(s);
  }

  Apple._internal(this._s2);

  /**
   * The getter for `s`
   */
  String get s => _s2;

  /**
   * The setter for `s`
   */
  void set s(String something) {
    _s2 = something;
  }

  /// This is a method.
  ///
  ///     new Apple().m1();
  void m1() {}

  /**
   * <nodoc> method not documented
   */
  void notAPublicMethod() {}

  operator *(Apple other) => this;

  void printMsg(String msg, [bool linebreak]) {}

  bool isGreaterThan(int number, {int check: 5}) {
    return number > check;
  }

  void paramFromExportLib(Helper helper) {}
}

/// Extends class [Apple], use [new Apple] or [new Apple.fromString]
class B extends Apple with Cat {
  /**
   * The default value is `false` (compression disabled).
   * To enable, set `autoCompress` to `true`.
   */
  bool autoCompress;

  /**
   * A list of Strings
   */
  List<String> list;

  bool get isImplemented => false;

  @override
  void m1() {
    var a = 6;
    var b = a * 9;
    b * 2;
  }

  void writeMsg(String msg, [String transformMsg(String origMsg, bool flag)]) {
    // do nothing
  }

  @deprecated
  Future doNothing() async {}
}

// Do NOT add a doc comment to C. Testing blank comments.

abstract class Cat {
  bool get isImplemented;
}

/// implements [Cat], [E]
class Dog implements Cat, E {
  String name;

  Dog();

  @deprecated
  int get deprecatedGetter => null;

  @deprecated
  void set deprecatedSetter(int value) {}

  @deprecated
  int deprecatedField;

  @deprecated
  Dog.deprecatedCreate(this.name);

  @Deprecated("Internal use")
  static Dog createDog(String s) {
    return new Dog.deprecatedCreate(s);
  }

  @deprecated
  List<Apple> getClassA() {
    return [new Apple()];
  }

  @override
  bool get isImplemented => true;

  operator ==(Dog other) => name == other.name;

  foo() async => 42;

  void testMethod(Iterable it) {}

  void testGeneric(Map<String, dynamic> args) {}
}

abstract class E {}

class F<T extends String> extends Dog with _PrivateAbstractClass {
  void methodWithGenericParam([List<Apple> msgs]) {}
}

class CatString extends StringBuffer {}

class MyError extends Error {}

class MyException implements Exception {}

class MyErrorImplements implements Error {
  StackTrace get stackTrace => null;
}

class MyExceptionImplements implements Exception {}

class ForAnnotation {
  final String value;
  const ForAnnotation(this.value);
}

@ForAnnotation('my value')
class HasAnnotation {}

abstract class _PrivateInterface {
  void test();
}

class PublicClassImplementsPrivateInterface implements _PrivateInterface {
  @override
  void test() {}
}

abstract class _PrivateAbstractClass {
  void test() {
    print("Hello World");
  }
}

class PublicClassExtendsPrivateClass extends _PrivateAbstractClass {}

class ConstantCat implements Cat {
  final String name;

  const ConstantCat(this.name);

  bool get isImplemented => true;
}

enum Animal { CAT, DOG, HORSE }

/// A class
class Klass {
  /// A method
  method() {}

  /// Another method
  another() {}

  /// A shadowed method
  toString() {}
}

class _RetainedEnum {
  final String name;

  const _RetainedEnum(this.name);
  String toString() => name;
}

class ShapeType extends _RetainedEnum {
  static const ShapeType rect = const ShapeType._internal("Rect");
  static const ShapeType ellipse = const ShapeType._internal("Ellipse");

  const ShapeType._internal(String name) : super(name);
}

/// For testing a class that extends a class
/// that has some operators
class SpecializedDuration extends Duration {}
