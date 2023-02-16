/// a library. testing string escaping: `var s = 'a string'` <cool>
/// {@category Real Libraries}

// ignore_for_file: unused_element, unused_import

library ex;

import 'dart:async';
import 'dart:math';

import 'src/mylib.dart' show Helper;
import 'package:test_package_imported/main.dart';

export 'package:args/args.dart' show ArgParser;
export 'dart:core' show deprecated, Deprecated;
import 'package:meta/meta.dart' show protected, factory;

export 'fake.dart' show Cool, ClassTemplateOneLiner;
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

/// top level declarations with templates/macros
///
/// {@template ex1}
/// ex2 macro content
/// {@endtemplate}
int myNumber = 3;

/// {@macro ex1}
void testMacro() {}

/// {@template ex2}
/// ex2 macro content
/// {@endtemplate}
bool get isCheck => true;

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
int deprecatedField = 1;

double number = 0.5;

@deprecated
int? get deprecatedGetter => null;

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
  AnotherParameterizedClass<T>? aInheritedField;
  AnotherParameterizedClass<T> get aInheritedGetter;
  ParameterizedClass<T> operator +(ParameterizedClass<T> other);
  set aInheritedSetter(AnotherParameterizedClass<T> thingToSet);
}

class AnotherParameterizedClass<B> {}

/// Class for testing expansion of type from implements clause.
abstract class TemplatedInterface<A> implements ParameterizedClass<List<int>> {
  AnotherParameterizedClass<List<int>> aMethodInterface(A value);
  ParameterizedTypedef<List<String>> aTypedefReturningMethodInterface();
  AnotherParameterizedClass<Stream<List<int>>>? aField;
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
  String? _s2;

  /// The read-write field `m`.
  int m = 0;

  /// <nodoc> no docs
  int? notDocumented;

  ///Constructor
  Apple();

  factory Apple.fromString(String s) {
    return Apple._internal(s);
  }

  Apple._internal(this._s2);

  /// Apple docs for whataclass
  void whataclass(List<Whataclass<bool>> list) {}

  /**
   * The getter for `s`
   */
  String? get s => _s2;

  /**
   * The setter for `s`
   */
  void set s(String? something) {
    _s2 = something;
  }

  operator *(Apple other) => this;

  bool isGreaterThan(int number, {int check = 5}) {
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

  void printMsg(String msg, [bool linebreak = false]) {}

  /**
   * fieldWithTypedef docs here
   */
  final ParameterizedTypedef<bool> fieldWithTypedef =
      (bool a, int b) => 'hello, ${a} ${b}';
}

/// Extension on Apple
extension AppleExtension on Apple {
  /// Can call s on Apple
  void s() {
    print('Extension on Apple');
  }

  /// Do not crash on static const extensions.
  static const int f = 3;
}

class WithGeneric<T> {
  T prop;
  WithGeneric(this.prop);
}

class WithGenericSub extends WithGeneric<Apple> {
  WithGenericSub(Apple prop) : super(prop);
}

/// Extends class [Apple], use [Apple.new] or [Apple.fromString]
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
  late bool autoCompress;

  /**
   * A list of Strings
   */
  List<String>? list;

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

  void writeMsg(String msg, [String transformMsg(String origMsg, bool flag)?]) {
    // do nothing
  }

  @override
  void abstractMethod() {}
}

/// Reference to nullable type: [Apple?] and null-checked variable [myNumber!].
class RefsWithQsAndBangs {}

/// Reference to [FieldAndCtorWithSameName.named()].
class FieldAndCtorWithSameName {
  FieldAndCtorWithSameName.named();

  int? named;
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
class Dog implements Cat, E {
  String? name;

  @deprecated
  int? deprecatedField;

  final int aFinalField = 42;

  static const String aStaticConstField = "A Constant Dog";

  /// Verify link substitution in constants (#1535)
  static const ShortName aName = const ExtendedShortName("hello there");

  @protected
  final int aProtectedFinalField = 84;

  Dog() {
    testMethod([]);
  }

  @deprecated
  Dog.deprecatedCreate(this.name);

  @deprecated
  int? get deprecatedGetter => null;

  @deprecated
  void set deprecatedSetter(int value) {}

  @override
  bool get isImplemented => true;

  int get aGetterReturningRandomThings => (Random()).nextInt(50);

  @override
  operator ==(other) => other is Dog && name == other.name;

  Dog operator +(Dog other) => Dog()..name = name! + other.name!;

  foo() async => 42;

  @deprecated
  List<Apple> getClassA() {
    return [Apple()];
  }

  @Deprecated('before v27.3')
  List<Dog> getAnotherClassD() {
    return [Dog()];
  }

  /// A tasty static + final property.
  static final int somethingTasty = 12;

  static int __staticbacker = 0;
  static int get staticGetterSetter => __staticbacker;
  static void set staticGetterSetter(x) {
    __staticbacker = x;
  }

  /// Macro method
  ///
  /// {@template foo}
  /// Foo macro content
  /// {@endtemplate}
  ///
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

  /// YouTube video method
  ///
  /// {@youtube 560 315 https://www.youtube.com/watch?v=oHg5SJYRHA0}
  /// More docs
  void withYouTubeWatchUrl() {}

  /// YouTube video in one line doc {@youtube 100 100 https://www.youtube.com/watch?v=oHg5SJYRHA0}
  ///
  /// This tests to see that we do the right thing if the animation is in
  /// the one line doc above.
  void withYouTubeInOneLineDoc() {}

  /// YouTube video inline in text.
  ///
  /// Tests to see that an inline {@youtube 100 100 https://www.youtube.com/watch?v=oHg5SJYRHA0} works as expected.
  void withYouTubeInline() {}

  /// Animation in one line doc {@animation 100 100 http://host/path/to/video.mp4}
  ///
  /// This tests to see that we do the right thing if the animation is in
  /// the one line doc above.
  void withAnimationInOneLineDoc() {}

  /// Animation inline in text.
  ///
  /// Tests to see that an inline {@animation 100 100 http://host/path/to/video.mp4} works as expected.
  void withAnimationInline() {}

  void testGeneric(Map<String, dynamic> args) {}

  void testMethod(Iterable it) {}

  T testGenericMethod<T>(T arg) {
    return arg;
  }

  @override
  void abstractMethod() {}
}

abstract class E {}

class F<T extends String> extends Dog with _PrivateAbstractClass {
  void methodWithGenericParam([List<Apple>? msgs]) {}
}

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
  imAFactoryNoReally() => Klass();

  /// A shadowed method
  @override
  toString() => '';

  /// A method with a custom annotation
  @aThingToDo('from', 'thing')
  anotherMethod() {}
}

class MyError extends Error {}

class MyErrorImplements implements Error {
  @override
  StackTrace? get stackTrace => null;
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
  static const ShapeType rect = ShapeType._internal("Rect");
  static const ShapeType ellipse = ShapeType._internal("Ellipse");

  const ShapeType._internal(String name) : super(name);
}

/// For testing a class that extends a class
/// that has some operators
class SpecializedDuration extends Duration {}

/**
 * class <nodoc>
 */
class unDocumented {
  String? s;
}

/// @nodoc
class unDocumented2 {
  String? s;
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

abstract class ToolUser {
  /// Invokes a tool.
  ///
  /// {@tool drill --file="$INPUT" --source="$(SOURCE_PATH)_$(SOURCE_LINE)_$SOURCE_COLUMN" --package-path=$PACKAGE_PATH --package-name=$PACKAGE_NAME --library-name=$LIBRARY_NAME --element-name=$(ELEMENT_NAME) --special=" |\[]!@#\"'$%^&*()_+"}
  /// Yes it is a [Dog]!
  /// Ok, fine it isn't.
  /// {@end-tool}
  void invokeTool();

  /// Invokes a tool without the $INPUT token or args.
  ///
  /// {@tool drill}
  /// This text should not appear in the output, even if it references [Dog].
  /// {@end-tool}
  void invokeToolNoInput();

  /// Invokes more than one tool in the same comment block.
  ///
  /// {@tool drill --file=$INPUT}
  /// This text should appear in the output.
  /// {@end-tool}
  /// {@tool drill --file=$INPUT}
  /// This text should also appear in the output.
  /// {@end-tool}
  void invokeToolMultipleSections();
}

abstract class HtmlInjection {
  /// Injects some HTML.
  /// {@inject-html}
  ///    <div style="opacity: 0.5;">[HtmlInjection]</div>
  /// {@end-inject-html}
  void injectSimpleHtml();

  /// Invokes more than one tool in the same comment block, and injects HTML.
  ///
  /// {@tool drill --file=$INPUT --html}
  /// This text should appear in the output.
  /// {@end-tool}
  /// {@tool drill --file=$INPUT --html}
  /// This text should also appear in the output.
  /// {@end-tool}
  void injectHtmlFromTool();
}

/// Just a class with a synthetic constructor.
class WithSyntheticConstructor {}

/// Extension on a class defined in the package
extension AnExtension<Q> on WithGeneric<Q> {
  int call(String s) => 0;
}

class AnExtendableThing {
  int? aMember;
}

extension SimpleStringExtension on AnExtendableThing {
  /// Print this and [another].
  /// Refer to [aMember], from [AnExtendableThing].
  /// Also refer to [extensionNumber].
  void doStuff(String another) {}

  int get extensionNumber => 3;
}

class ExtensionUser {
  /// Refer to [aMember], which we use here.
  void doSomeStuff(String things) {}
}

/// Extension on List
extension FancyList<Z> on List<Z> {
  int get doubleLength => this.length * 2;
  List<Z> operator -() => this.reversed.toList();
  List<List<Z>> split(int at) =>
      <List<Z>>[this.sublist(0, at), this.sublist(at)];
  static List<Z?> big() => List.filled(100, null);
}

extension SymDiff<Q> on Set<Q> {
  Set<Q> symmetricDifference(Set<Q> other) =>
      this.difference(other).union(other.difference(this));
}

/// Extensions can be made specific.
extension IntSet on Set<int> {
  int sum() => this.fold(0, (prev, element) => prev + element);
}

// Extensions can be private.
extension _Shhh on Object {
  void secret() {}
}

// Extension with no name
extension on Object {
  void bar() {}
}

extension StaticFieldExtension on Object {
  static int? aStatic;
}

/// This class has nothing to do with [_Shhh], [FancyList], or [AnExtension.call],
/// but should not crash because we referenced them.
/// We should be able to find [DocumentThisExtensionOnce], too.
class ExtensionReferencer {}

class ToolPrintingMacroWhichInjectsHtml {
  /// Text.
  /// {@template html-macro}
  /// {@inject-html}<div class="title">Title</div>{@end-inject-html}
  /// {@endtemplate}
  int a = 1;

  /// Text.
  ///
  /// {@tool print_macro}
  /// Text for tool.
  /// {@end-tool}
  int b = 2;
}
