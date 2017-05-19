/// # WOW FAKE PACKAGE IS __BEST__ [PACKAGE][pkg]
///
/// If you don't have this package yet, get it.
/// Don't ask questions.
///
/// Testing code [:true:] and [:false:]
///
/// Testing string escaping: `var s = 'I am a string'`
///
/// My favorite class is [Cool].
///
/// ## I am an h2
///
/// hello there
///
/// ### I am an h3
///
/// hello there
///
/// #### I am an h4
///
/// hello there
///
/// ##### I am an h5
///
/// hello
///
/// *Why should you get this package?*
///
/// * We told you so.
/// * Everyone is doing it.
/// * It smells nice.
///
/// ```
/// class Foo {
///   long line is very long long line is very long long line is very long line long line long line
/// }
/// ```
///
/// Here are some hyperlinks with angle brackets:
///
/// * <https://myfakepackage.com/withapath>
/// * <ftp://ftp.myfakepackage.com/donthidemyschema>
/// * <http://myfakepackage.com/buthidethisone>
///
/// [pkg]: http://example.org
library fake;

import 'dart:async';

import 'dart:collection';

import 'example.dart';

import 'css.dart' as css;

import 'two_exports.dart' show BaseClass;

class HasGenerics<X, Y, Z> {
  HasGenerics(X x, Y y, Z z) {}

  X returnX() => null;

  Z returnZ() => null;

  Z doStuff(String s, X x) => null;

  /// Converts itself to a map.
  Map<X, Y> convertToMap() => null;
}

Map<dynamic, String> mapWithDynamicKeys = {};

/// Useful for annotations.
class Annotation {
  final String value;
  const Annotation(this.value);
}

/// For make-better testing of constants.
///
/// Make one of these neato classes like this:
///
/// `var constant = const ConstantClass('neat')`
///
/// This is a code block
///
///     var x = 'hello';
///     print(x);
class ConstantClass {
  final String value;

  /// Make compile-time constants with this constructor!
  /// Go ahead, it's fun.
  const ConstantClass(this.value);

  /// A named compile-time constant constructor.
  const ConstantClass.isVeryConstant(this.value);

  /// Not actually constant.
  ConstantClass.notConstant(this.value);
}

// No dart docs on purpose. Also, a non-primitive const class.
const ConstantClass CUSTOM_CLASS = const ConstantClass('custom');

/// Up is a direction.
///
/// Getting up in the morning can be hard.
const String UP = 'up';

const String NAME_SINGLEUNDERSCORE = 'yay bug hunting';

const String NAME_WITH_TWO_UNDERSCORES =
    'episode seven better be good; episode seven better be good; episode seven better be good; episode seven better be good';

/// Testing [NAME_WITH_TWO_UNDERSCORES] should not be italicized.
///
/// This name should link correctly: [NAME_SINGLEUNDERSCORE]
void short() {}

/// Dynamic-typed down.
@deprecated
const DOWN = 'down';

/// A constant integer value,
/// which is a bit redundant.
const int ZERO = 0;

/// Takes input, returns output.
@deprecated
typedef String FakeProcesses(String input);

/// A typedef with a type parameter.
typedef T GenericTypedef<T>(T input);

/// A typedef with the new style generic function syntax.
typedef NewGenericTypedef<T> = List<S> Function<S>(T, int, bool);

/// Lots and lots of parameters.
typedef int LotsAndLotsOfParameters(so, many, parameters, it, should, wrap,
    when, converted, to, html, documentation);

/// This class is cool!
class Cool {
  Cool returnCool() {}
}

/// Perfect for mix-ins.
abstract class MixMeIn {}

/// An interface that can be implemented.
abstract class Interface {}

/// Yet another interface that can be implemented.
abstract class AnotherInterface {}

/// A super class, with many powers. Link to [Apple] from another library.
@deprecated
class SuperAwesomeClass {
  /// In the super class.
  List<String> powers;

  /// In the super class.
  ///
  /// Another comment line.
  void fly(int height, Cool superCool, {String msg}) {
    var x = null;
    int i, y;
    for (int z = 0; z < 100; z++) {
      print('hi');
    }
  }

  SuperAwesomeClass operator -(other) {
    return null;
  }
}

typedef void myCoolTypedef(Cool x, bool y);

/// Names are actually wrong in this class, but when we extend it,
/// they are correct.
class ImplicitProperties {
  String implicitGetterExplicitSetter;
  List<int> explicitGetterImplicitSetter;
}

/// Classes with unusual properties?  I don't think they exist.
class ClassWithUnusualProperties extends ImplicitProperties {
  @override
  set implicitGetterExplicitSetter(String x) {}

  @override
  List<int> get explicitGetterImplicitSetter => new List<int>();

  myCoolTypedef _aFunction;

  myCoolTypedef get explicitGetterSetter {
    return _aFunction;
  }

  /// This property is not synthetic, so it might reference [f] -- display it.
  set explicitGetterSetter(myCoolTypedef f) => _aFunction = f;

  /// This property only has a getter and no setter; no parameters to print.
  myCoolTypedef get explicitGetter {
    return _aFunction;
  }

  /// Set to [f], and don't warn about [bar] or [baz].
  set explicitSetter(f(int bar, Cool baz, List<int> macTruck)) {}

  final Set finalProperty = new Set();

  Map implicitReadWrite;

  /// Hey there, more things not to warn about: [f], [x], or [q].
  String aMethod(Function f(Cool x, bool q)) {
    return 'hi';
  }
}

/// This is a very long line spread
/// across... wait for it... two physical lines.
///
/// The rest of this is not in the first paragraph.
@Annotation('value')
class LongFirstLine extends SuperAwesomeClass
    with MixMeIn
    implements Interface, AnotherInterface {
  static const THING = 'yup';
  static const int ANSWER = 42;

  /// An instance string property. Readable and writable.
  String aStringProperty;

  /// A static int property.
  static int meaningOfLife = 42;

  /// The default constructor.
  @deprecated
  LongFirstLine();

  /// Named constructors are awesome.
  ///
  /// The map is a key/value pairs of data that helps create an instance.
  LongFirstLine.fromMap(Map data);

  LongFirstLine.fromHasGenerics(HasGenerics hg);

  /// No params.
  @deprecated
  void noParams() {}

  /// Returns a single string.
  String returnString() => 'cool';

  /// Two params, the first has a type annotation, the second does not.
  int twoParams(String one, two) => 42;

  /// One dynamic param, two named optionals.
  bool optionalParams(first, {second, int third}) => true;

  /// Dynamic getter. Readable only.
  get dynamicGetter => 'could be anything';

  /// Only a setter, with a single param, of type double.
  void set onlySetter(double d) {}

  /// Adds another one of these thingies.
  LongFirstLine operator +(LongFirstLine other) {
    return null;
  }

  /// Multiplies a thingies to this thingie and then returns a new thingie.
  LongFirstLine operator *(LongFirstLine other) {
    return null;
  }

  static int get staticGetter => 11111;

  static void set staticOnlySetter(bool thing) {}

  /// Just a static method with no parameters.
  ///
  /// Returns an int.
  static int staticMethodNoParams() => 42;

  /// A static method that takes a single dynamic thing, and returns void.
  static void staticMethodReturnsVoid(dynamicThing) {}
}

/// My bad!
class Oops implements Exception {
  final String message;
  Oops(this.message);
}

/// Also, my bad.
@deprecated
class Doh extends Error {}

/// An `enum` for ROYGBIV constants.
enum Color {
  /// Red
  RED,

  /// Orange
  ORANGE,
  YELLOW,
  GREEN,

  /// Some constants have long docs.
  ///
  /// Some constants have long docs.
  /// Some constants have long docs.
  BLUE,
  INDIGO,
  VIOLET
}

/// link to method from class [Apple.m]
class Foo2 {
  final int index;
  const Foo2(this.index);

  static const Foo2 BAR = const Foo2(0);
  static const Foo2 BAZ = const Foo2(1);
}

class OtherGenericsThing<A> {
  HasGenerics<A, Cool, String> convert() => null;
}

/// Constant property.
const double PI = 3.14159;

/// Final property.
@deprecated
final int meaningOfLife = 42;

/// Simple property
String simpleProperty;

/// Just a setter. No partner getter.
void set justSetter(int value) {}

/// Just a getter. No partner setter.
bool get justGetter => false;

/// The setter for setAndGet.
void set setAndGet(String thing) {}

/// The getter for setAndGet.
String get setAndGet => 'hello';

/// A dynamic getter.
get dynamicGetter => 'i could be anything';

/// Top-level function 3 params and 1 optional positional param.
///
/// This is the second paragraph.
/// It has two lines.
///
/// The third parameter is a [Cool] object.
///
/// Here is a code snippet:
///
///     var thing = topLevelFunction(1, true, 3.4);
///
/// This snippet has brackets in parameters:
///
///     callMe('alert', ['hello from dart']);
///
/// Thanks for using this function!
@deprecated
String topLevelFunction(int param1, bool param2, Cool coolBeans,
    [double optionalPositional = 0.0]) {
  return null;
}

/// A single optional positional param, no type annotation, no default value.
@greatAnnotation
void onlyPositionalWithNoDefaultNoType([@greatestAnnotation anything]) {}

/// Top-level function with 1 param and 2 optional named params, 1 with a
/// default value.
void soIntense(anything, {bool flag: true, int value}) {}

/// [FooBar] comes from another library.
void paramFromAnotherLib(Apple thing) {}

/// An async function. It should look like I return a [Future].
thisIsAsync() async => 42;

/// Explicitly returns a Future and is marked async.
Future thisIsAlsoAsync() async => 43;

/// A generic function with a type parameter.
void myGenericFunction<S>(int a, bool b, S c) {
  return;
}

/// This is a great thing.
const greatAnnotation = 'great';

/// This is the greatest thing.
const greatestAnnotation = 'greatest';

/// This function has two parameters that are functions.
///
/// Check out the [number] parameter. It's the first one.
String functionWithFunctionParameters(int number, void thing(one, two),
        String string, Future asyncThing(three, four, five, six, seven)) =>
    null;

/// These are code syntaxes: [:true:] and [:false:]
const testingCodeSyntaxInOneLiners = 'fantastic';

/// Referencing something that [doesn't exist].
const incorrectDocReference = 'doh';

/// Tests a single field with explict getter and setter.
class WithGetterAndSetter {
  /// Returns a length.
  ///
  /// Throws some exception if used in the fourth dimension.
  int get lengthX => 1;

  /// Sets the length.
  ///
  /// Throws if set to an imaginary number.
  void set lengthX(int _length) {}
}

/// I have a generic and it extends [Foo2]
class HasGenericWithExtends<T extends Foo2> {}

/// Extends [ListBase]
class SpecialList<E> extends ListBase<E> {
  E operator [](int index) {
    return null;
  }

  int get length => 0;

  void set length(int length) {}

  void operator []=(int index, E value) {}
}

/// This inherits operators.
class ExtraSpecialList<E> extends SpecialList {}

class BaseForDocComments {
  /// Takes a [value] and returns a String.
  ///
  /// This methods is inside of [BaseForDocComments] class xx
  ///
  /// Also [NAME_WITH_TWO_UNDERSCORES] which is a top-level const xx
  ///
  /// Also a single underscore: [NAME_SINGLEUNDERSCORE]
  ///
  /// Returns a [String] xx
  ///
  /// Reference to another method in this class [anotherMethod] xx
  ///
  /// Reference to a top-level function in this library [topLevelFunction] xx
  ///
  /// Reference to a top-level function in another library that is imported into this library (example lib) [function1] xx
  ///
  /// Reference to a class in example lib [Apple] xx
  ///
  /// Reference to a top-level const in this library that shares the same
  /// name as a top-level name in another library [incorrectDocReference] xx
  ///
  /// Reference to a top-level const in another library [incorrectDocReferenceFromEx]
  ///
  /// Reference to prefixed-name from another lib [css.theOnlyThingInTheLibrary] xx
  ///
  /// Reference to a name that exists in this package, but is not imported
  /// in this library [doesStuff] xx
  ///
  /// Reference to a name of a class from an import of a library that exported
  /// the name [BaseClass] xx
  String doAwesomeStuff(int value) => null;

  void anotherMethod() {}
}

/// Testing if docs for inherited method are correct.
class SubForDocComments extends BaseForDocComments {
  /// Reference to [foo] and [bar]
  void localMethod(String foo, bar) {}
}

typedef void VoidCallback();

/// Adds a callback.
void addCallback(VoidCallback callback) {}

typedef int Callback2(String);

/// Adds another callback.
void addCallback2(Callback2 callback) {}

const required = 'required';

/// Paints an image into the given rectangle in the canvas.
void paintImage1(
    {@required String canvas,
    @required int rect,
    @required ExtraSpecialList image,
    BaseForDocComments colorFilter,
    String repeat: LongFirstLine.THING}) {
  // nothing to do here -
}

/// Paints an image into the given rectangle in the canvas.
void paintImage2(String fooParam,
    [@required String canvas,
    @required int rect,
    @required ExtraSpecialList image,
    BaseForDocComments colorFilter,
    String repeat = LongFirstLine.THING]) {
  // nothing to do here -
}

/// Test operator references: [OperatorReferenceClass.==].
class OperatorReferenceClass {
  OperatorReferenceClass();

  @override
  bool operator ==(dynamic other) {
    return false;
  }
}
