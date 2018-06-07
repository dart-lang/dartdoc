/// a library. testing string escaping: `var s = 'a string'` <cool>
/// {@category Real Libraries}
library ex;

import 'dart:async';
import 'dart:math';

import 'src/mylib.dart' show Helper;
import 'package:test_package_imported/main.dart';

export 'dart:core' show deprecated, Deprecated;
import 'package:meta/meta.dart' show protected, factory;

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

/// A custom annotation.
class aThingToDo {
  final String who;
  final String what;

  const aThingToDo(this.who, this.what);
}

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

typedef String ParameterizedTypedef<T>(T msg, int foo);

/// Support class to test inheritance + type expansion from implements clause.
abstract class ParameterizedClass<T> {
  AnotherParameterizedClass<T> aInheritedMethod(int foo);
  ParameterizedTypedef<T> aInheritedTypedefReturningMethod();
  AnotherParameterizedClass<T> aInheritedField;
  AnotherParameterizedClass<T> get aInheritedGetter;
  ParameterizedClass<T> operator +(ParameterizedClass<T> other);
  set aInheritedSetter(AnotherParameterizedClass<T> thingToSet);
}

class AnotherParameterizedClass<B> {}

/// Class for testing expansion of type from implements clause.
abstract class TemplatedInterface<A> implements ParameterizedClass<List<int>> {
  AnotherParameterizedClass<List<int>> aMethodInterface(A value);
  ParameterizedTypedef<List<String>> aTypedefReturningMethodInterface();
  AnotherParameterizedClass<Stream<List<int>>> aField;
  AnotherParameterizedClass<Map<A, List<String>>> get aGetter;
  set aSetter(AnotherParameterizedClass<List<bool>> thingToSet);
}

class TemplatedClass<X> {
  int aMethod(X input) {
    return 5;
  }
}

class ShortName {
  final String aParameter;
  const ShortName(this.aParameter);
}

class ExtendedShortName extends ShortName {
  const ExtendedShortName(String aParameter) : super(aParameter);
}

/// Referencing [processMessage] (or other things) here should not break
/// enum constants ala #1445
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

  /// Apple docs for whataclass
  void whataclass(List<Whataclass<bool>> list) {}

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

  /**
   * fieldWithTypedef docs here
   */
  final ParameterizedTypedef<bool> fieldWithTypedef;
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
  void abstractMethod() {}
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
/// {@example test.dart region=template lang=html}
///
/// {@example test.dart region=}
///
/// {@example test.dart region= lang=}
class Dog implements Cat, E {
  String name;

  @deprecated
  int deprecatedField;

  final int aFinalField;
  static const String aStaticConstField = "A Constant Dog";

  /// Verify link substitution in constants (#1535)
  static const ShortName aName = const ExtendedShortName("hello there");

  @protected
  final int aProtectedFinalField;

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

  int get aGetterReturningRandomThings => (new Random()).nextInt(50);

  @override
  operator ==(other) => other is Dog && name == other.name;

  foo() async => 42;

  @deprecated
  List<Apple> getClassA() {
    return [new Apple()];
  }

  @Deprecated('before v27.3')
  List<Dog> getAnotherClassD() {
    return [new Dog()];
  }

  /// A tasty static + final property.
  static final int somethingTasty;

  static int __staticbacker = 0;
  static int get staticGetterSetter => __staticbacker;
  static int set staticGetterSetter(x) {
    __staticbacker = x;
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

  /// {@template private}
  /// Private macro content
  /// {@endtemplate}
  void _macroDefinedPrivately() {}

  /// Use a privately defined macro: {@macro private}
  void withPrivateMacro() {}

  /// Don't define this:  {@macro ThatDoesNotExist}
  void withUndefinedMacro() {}

  /// Animation method
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4}
  /// More docs
  void withAnimation() {}

  /// Animation method with name
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id=namedAnimation}
  /// More docs
  void withNamedAnimation() {}

  /// Animation method with quoted name
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id="quotedNamedAnimation"}
  /// {@animation 100 100 http://host/path/to/video.mp4 id='quotedNamedAnimation2'}
  /// More docs
  void withQuotedNamedAnimation() {}

  /// Animation method with invalid name
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id=2isNot-A-ValidName}
  /// More docs
  void withInvalidNamedAnimation() {}

  /// Deprecated animation method format.
  ///
  /// {@animation deprecatedAnimation 100 100 http://host/path/to/video.mp4}
  /// More docs
  void withDeprecatedAnimation() {}

  /// Non-Unique Animation method (between methods)
  ///
  /// {@animation 100 100 http://host/path/to/video.mp4 id=barHerderAnimation}
  /// {@animation 100 100 http://host/path/to/video.mp4n id=barHerderAnimation}
  /// More docs
  void withAnimationNonUnique() {}

  /// Non-Unique deprecated Animation method (between methods)
  ///
  /// {@animation fooHerderAnimation 100 100 http://host/path/to/video.mp4}
  /// {@animation fooHerderAnimation 100 100 http://host/path/to/video.mp4}
  /// More docs
  void withAnimationNonUniqueDeprecated() {}

  /// Malformed Animation method with wrong parameters
  ///
  /// {@animation http://host/path/to/video.mp4}
  /// More docs
  void withAnimationWrongParams() {}

  /// Malformed Animation method with non-integer width
  ///
  /// {@animation 100px 100 http://host/path/to/video.mp4 id=badWidthAnimation}
  /// More docs
  void withAnimationBadWidth() {}

  /// Malformed Animation method with non-integer height
  ///
  /// {@animation 100 100px http://host/path/to/video.mp4 id=badHeightAnimation}
  /// More docs
  void withAnimationBadHeight() {}

  /// Animation in one line doc {@animation 100 100 http://host/path/to/video.mp4}
  ///
  /// This tests to see that we do the right thing if the animation is in
  /// the one line doc above.
  void withAnimationInOneLineDoc() {}

  /// Animation inline in text.
  ///
  /// Tests to see that an inline {@animation 100 100 http://host/path/to/video.mp4} works as expected.
  void withAnimationInline() {}

  /// Animation with out-of-order id argument.
  ///
  /// Tests to see that out of order arguments work.
  /// {@animation 100 100 id=outOfOrder http://host/path/to/video.mp4}
  /// works as expected.
  void withAnimationOutOfOrder() {}

  /// Animation with an argument that is not the id.
  ///
  /// Tests to see that it gives an error when arguments that are not
  /// recognized are added.
  /// {@animation 100 100 http://host/path/to/video.mp4 name=theName}
  void withAnimationUnknownArg() {}

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
  void abstractMethod() {}
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

  /// A protected method
  @protected
  imProtected() {}

  /// Not really a factory, but...
  @factory
  imAFactoryNoReally() {}

  /// A shadowed method
  @override
  toString() {}

  /// A method with a custom annotation
  @aThingToDo('from', 'thing')
  anotherMethod() {}
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

/// Someone might do this some day.
typedef aComplexTypedef<A1, A2, A3> = void Function(A1, A2, A3) Function(
    A3, String);

/// This class has a complicated type situation.
abstract class TypedFunctionsWithoutTypedefs {
  /// Returns a function that returns a void with some generic types sprinkled in.
  void Function(T1, T2) getAFunctionReturningVoid<T1, T2>(
      void callback(T1 argument1, T2 argument2));

  /// This helps us make sure we get both the empty and the non-empty
  /// case right for anonymous functions.
  bool Function<T4>(String, T1, T4) getAFunctionReturningBool<T1, T2, T3>();

  /// Returns a complex typedef that includes some anonymous typed functions.
  aComplexTypedef getAComplexTypedef<A4, A5, A6>();
}
