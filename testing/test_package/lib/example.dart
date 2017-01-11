/// a library. testing string escaping: `var s = 'a string'` <cool>
library ex;

import 'dart:async';

import 'src/mylib.dart' show Helper;

export 'dart:core' show deprecated, Deprecated;

export 'fake.dart' show Cool;
export 'src/mylib.dart' show Helper;

const String COLOR = 'red';

const String COLOR_GREEN = 'green';

const String COLOR_ORANGE = 'orange';

const String COMPLEX_COLOR = 'red' + '-' + 'green' + '-' + 'blue';

/// top level var <nodoc>
const DO_NOT_DOCUMENT = 'not documented';

/// This is the same name as a top-level const from the fake lib.
const incorrectDocReference = 'same name as const from fake';

/// This should [not work].
const incorrectDocReferenceFromEx = 'doh';

const ConstantCat MY_CAT = const ConstantCat('tabby');
const List<String> PRETTY_COLORS = const <String>[
  COLOR_GREEN,
  COLOR_ORANGE,
  'blue'
];
@deprecated
int deprecatedField;

double number;

@deprecated
int get deprecatedGetter => null;

@deprecated
void set deprecatedSetter(int value) {}

get y => 2;

int function1(String s, bool b, lastParam) => 5;

T genericFunction<T>(T arg) {
  return arg;
}

typedef String processMessage<T>(String msg);

enum Animal {
  /// Single line docs.
  CAT,

  /// Multi line docs.
  ///
  /// [Dog] needs lots of docs.
  DOG,

  HORSE
}

/**
 * Sample class [String]
 *
 * <pre>
 *   A
 *    B
 * </pre>
 */

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

  operator *(Apple other) => this;

  bool isGreaterThan(int number, {int check: 5}) {
    return number > check;
  }

  /// This is a method.
  ///
  ///     new Apple().m1();
  void m1() {}

  void methodWithTypedefParam(processMessage p) {}

  /**
   * <nodoc> method not documented
   */
  void notAPublicMethod() {}

  void paramFromExportLib(Helper helper) {}

  void printMsg(String msg, [bool linebreak]) {}
}

class WithGeneric<T> {
  T prop;
  WithGeneric(this.prop);
}

class WithGenericSub extends WithGeneric<Apple> {
  WithGenericSub(Apple prop) : super(prop);
}

/// Extends class [Apple], use [new Apple] or [new Apple.fromString]
///
/// <pre>
///  B extends A
///  B implements C
///  </pre>
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

  @override
  bool get isImplemented => false;

  @override
  String get s => "123";

  @deprecated
  Future doNothing() async {}

  @override
  void m1() {
    var a = 6;
    var b = a * 9;
    b * 2;
  }

  void writeMsg(String msg, [String transformMsg(String origMsg, bool flag)]) {
    // do nothing
  }

  @override
  void abstractMethod() { }
}

// Do NOT add a doc comment to C. Testing blank comments.

abstract class Cat {
  bool get isImplemented;

  void abstractMethod();
}

class CatString extends StringBuffer {}

class ConstantCat implements Cat {
  final String name;

  const ConstantCat(this.name);

  @override
  bool get isImplemented => true;

  @override
  void abstractMethod() {
    // do nothing
  }
}

/// implements [Cat], [E]
///
/// {@example dog/food}
/// {@example dog/food.txt region=meat}
///
/// {@example test.html}
///
/// {@example test.dart region=template lang=html}
///
/// {@example test.dart region=}
///
/// {@example test.dart region= lang=}
class Dog implements Cat, E {
  String name;

  @deprecated
  int deprecatedField;

  Dog() {
    testMethod([]);
  }

  @deprecated
  Dog.deprecatedCreate(this.name);

  @deprecated
  int get deprecatedGetter => null;

  @deprecated
  void set deprecatedSetter(int value) {}

  @override
  bool get isImplemented => true;

  @override
  operator ==(other) => other is Dog && name == other.name;

  foo() async => 42;

  @deprecated
  List<Apple> getClassA() {
    return [new Apple()];
  }

  /// Macro method
  ///
  /// {@template foo}
  /// Foo macro content
  /// {@endtemplate}
  ///
  /// {@macro foo}
  /// More docs
  void withMacro() {}

  /// {@macro foo}
  void withMacro2() {}

  void testGeneric(Map<String, dynamic> args) {}

  void testMethod(Iterable it) {}

  T testGenericMethod<T>(T arg) {
    return arg;
  }

  @Deprecated("Internal use")
  static Dog createDog(String s) {
    return new Dog.deprecatedCreate(s);
  }

  @override
  void abstractMethod() { }
}

abstract class E {}

class F<T extends String> extends Dog with _PrivateAbstractClass {
  void methodWithGenericParam([List<Apple> msgs]) {}
}

class ForAnnotation {
  final String value;
  const ForAnnotation(this.value);
}

@ForAnnotation('my value')
class HasAnnotation {}

/// A class
class Klass {
  /// Another method
  another() {}

  /// A method
  method() {}

  /// A shadowed method
  @override
  toString() {}
}

class MyError extends Error {}

class MyErrorImplements implements Error {
  @override
  StackTrace get stackTrace => null;
}

class MyException implements Exception {}

class MyExceptionImplements implements Exception {}

class PublicClassExtendsPrivateClass extends _PrivateAbstractClass {}

class PublicClassImplementsPrivateInterface implements _PrivateInterface {
  @override
  void test() {}
}

/// Foo bar.
///
/// 3. All references should be hyperlinks. [MyError] and
///    [ShapeType] and [MyError] and [MyException] and
///    [MyError] and [MyException] and
///    [List<int>] foo bar.
class ShapeType extends _RetainedEnum {
  static const ShapeType rect = const ShapeType._internal("Rect");
  static const ShapeType ellipse = const ShapeType._internal("Ellipse");

  const ShapeType._internal(String name) : super(name);
}

/// For testing a class that extends a class
/// that has some operators
class SpecializedDuration extends Duration {}

/**
 * class <nodoc>
 */
class unDocumented {
  String s;
}

/// @nodoc
class unDocumented2 {
  String s;
}

abstract class _PrivateAbstractClass {
  void test() {
    print("Hello World");
  }
}

abstract class _PrivateInterface {
  void test();
}

class _RetainedEnum {
  final String name;

  const _RetainedEnum(this.name);
  @override
  String toString() => name;
}
