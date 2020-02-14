/// # WOW FAKE PACKAGE IS __BEST__ [PACKAGE][pkg]
/// {@category Real Libraries}
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
// Make sure dartdoc ignores invalid prefixes imports (#1896)
// ignore: uri_does_not_exist
import 'dart:json' as invalidPrefix;
import 'package:meta/meta.dart' show Required;
import 'csspub.dart' as css;
import 'csspub.dart' as renamedLib2;
import 'example.dart';
import 'mylibpub.dart' as renamedLib;
import 'mylibpub.dart' as renamedLib2;
import 'two_exports.dart' show BaseClass;
export 'src/notadotdartfile';

// ignore: uri_does_not_exist
export 'package:test_package_imported/categoryExporting.dart'
    show IAmAClassWithCategories;

export 'src/tool.dart';

// Explicitly export ourselves, because why not.
// ignore: uri_does_not_exist
export 'package:test_package/fake.dart';

/// Does not render with emoji 3ffe:2a00:100:7031::1
const int hasMarkdownInDoc = 1;

abstract class ImplementingThingy implements BaseThingy {}

abstract class BaseThingy {
  // ignore: public_member_api_docs
  ImplementingThingy get aImplementingThingy;
  ImplementingThingy aImplementingThingyField;
  void aImplementingThingyMethod(ImplementingThingy parameter);
}

abstract class ImplementingThingy2 implements BaseThingy2, ImplementingThingy {}

/// Test for MultiplyInheritedExecutableElement handling.
abstract class BaseThingy2 implements BaseThingy {
  /// BaseThingy2's doc for aImplementingThingy.
  @override
  ImplementingThingy2 get aImplementingThingy;
}

/// This function has a link to a renamed library class member.
///
/// Link to library: [renamedLib]
/// Link to constructor (implied): [new renamedLib.YetAnotherHelper()]
/// Link to constructor (implied, no new): [renamedLib.YetAnotherHelper()]
/// Link to class: [renamedLib.YetAnotherHelper]
/// Link to constructor (direct): [renamedLib.YetAnotherHelper.YetAnotherHelper]
/// Link to class member: [renamedLib.YetAnotherHelper.getMoreContents]
/// Link to function: [renamedLib.helperFunction]
/// Link to overlapping prefix: [renamedLib2.theOnlyThingInTheLibrary]
void aFunctionUsingRenamedLib() {
  renamedLib.helperFunction('hello', 3);
}

class ConstructorTester<A, B> {
  ConstructorTester(String param1) {}
  ConstructorTester.fromSomething(A foo) {}
}

class HasGenerics<X, Y, Z> {
  HasGenerics(X x, Y y, Z z) {}

  X returnX() => null;

  Z returnZ() => null;

  Z doStuff(String s, X x) => null;

  /// Converts itself to a map.
  Map<X, Y> convertToMap() => null;
}

/// Coderef to ambiguous parameter of function parameter should not crash us.
/// (#1835)
///
/// Here is a coderef: [aThingParameter]
void doAComplicatedThing(int x,
    {void doSomething(int aThingParameter, String anotherThing),
    void doSomethingElse(int aThingParameter, double somethingElse)}) {}

/// Bullet point documentation.
///
/// This top level constant has bullet points.
///
/// * A bullet point.
/// * Another even better bullet point.
/// * A bullet point that wraps onto a second line, without creating a new
///   bullet point or paragraph.
/// * A fourth bullet point.
const String bulletDoced = 'Foo bar baz';

/// This class uses a pragma annotation.
@pragma('Hello world')
class HasPragma {}

const dynamic aDynamicAnnotation = 4;

@aDynamicAnnotation

/// This class has a dynamic annotation.
class HasDynamicAnnotation {}

/// This is a class with a table.
///
/// It has multiple sentences before the table.  Because testing is a good
/// idea.
///
/// | Component | Symbol | Short Form   | Long Form         | Numeric   | 2-digit   |
/// |-----------|:------:|--------------|-------------------|-----------|-----------|
/// | era       |   G    | G (AD)       | GGGG (Anno Domini)| -         | -         |
/// | year      |   y    | -            | -                 | y (2015)  | yy (15)   |
/// | month     |   M    | MMM (Sep)    | MMMM (September)  | M (9)     | MM (09)   |
/// | day       |   d    | -            | -                 | d (3)     | dd (03)   |
/// | weekday   |   E    | EEE (Sun)    | EEEE (Sunday)     | -         | -         |
/// | hour      |   j    | -            | -                 | j (13)    | jj (13)   |
/// | hour12    |   h    | -            | -                 | h (1 PM)  | hh (01 PM)|
/// | hour24    |   H    | -            | -                 | H (13)    | HH (13)   |
/// | minute    |   m    | -            | -                 | m (5)     | mm (05)   |
/// | second    |   s    | -            | -                 | s (9)     | ss (09)   |
/// | timezone  |   z    | -            | z (Pacific Standard Time)| -  | -         |
/// | timezone  |   Z    | Z (GMT-8:00) | -                 | -         | -         |
///
/// It also has a short table with embedded links.
///
/// | [DocumentWithATable] | [Annotation] | [aMethod] |
/// |----------------------|--------------|-----------|
/// | [foo]                | Not really   | "blah"    |
/// | [bar]                | Maybe        | "stuff"   |
class DocumentWithATable {
  static const DocumentWithATable foo = DocumentWithATable();
  static const DocumentWithATable bar = DocumentWithATable();

  const DocumentWithATable();
  void aMethod(String parameter) {}
}

/// A doc reference mentioning [dynamic].
dynamic get mustGetThis => null;

Map<dynamic, String> mapWithDynamicKeys = {};

Required useSomethingInAnotherPackage;
String useSomethingInTheSdk;

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

class _APrivateConstClass {
  const _APrivateConstClass();
}

class AClassWithFancyProperties {
  /// This property is quite fancy, and requires sample code to understand.
  ///
  /// ```dart
  /// AClassWithFancyProperties x = new AClassWithFancyProperties();
  ///
  /// if (x.aProperty.contains('Hello')) {
  ///   print("I am indented!");
  ///   if (x.aProperty.contains('World')) {
  ///     print ("I am indented even more!!!");
  ///   }
  /// }
  /// ```
  String aProperty;
}

const _APrivateConstClass CUSTOM_CLASS_PRIVATE = _APrivateConstClass();

/// Type inference mixing with anonymous functions.
final importantComputations = {
  1: (List<num> a) => a[0] + a[1],
  2: (List<num> a) => a[0] - a[1],
  3: (List<num> a) => a[0] * a[1],
  4: (List<num> a) => -a[0]
};

// No dart docs on purpose. Also, a non-primitive const class.
const ConstantClass CUSTOM_CLASS = ConstantClass('custom');

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

/// A complicated type parameter to ATypeTakingClass.
ATypeTakingClass<String Function(int)> get complicatedReturn => null;

/// Lots and lots of parameters.
typedef int LotsAndLotsOfParameters(so, many, parameters, it, should, wrap,
    when, converted, to, html, documentation);

/// This class is cool!
class Cool {
  // ignore: missing_return
  Cool returnCool() {}
}

/// A map initialization making use of optional const.
const Map<int, String> myMap = {1: "hello"};

/// A variable initalization making use of optional new.
Cool aCoolVariable = Cool();

/// Perfect for mix-ins.
abstract class MixMeIn {}

/// An interface that can be implemented.
abstract class Interface {}

/// Yet another interface that can be implemented.
abstract class AnotherInterface {}

class NotAMixin {
  String get superString => "A string that's clearly important";
}

class AMixinCallingSuper extends NotAMixin {
  @override
  String get superString => "${super.superString} but not as important as this";
}

/// I am a new style mixin using the new mixin syntax.
mixin NewStyleMixinCallingSuper on NotAMixin {
  @override

  /// I have documentation for an overridden method named [superString],
  /// different from [NotAMixin.superString].
  String get superString =>
      "${super.superString} but moderately less important than this";
}

/// Verify super-mixins don't break Dartdoc.
// ignore: mixin_inherits_from_not_object, mixin_references_super
class AClassUsingASuperMixin extends AnotherInterface with AMixinCallingSuper {}

/// A class mixing in a single new-style mixin.
class AClassUsingNewStyleMixin extends NotAMixin
    with NewStyleMixinCallingSuper {}

/// A generic class for testing type inference.
class GenericClass<T> {
  T member;

  /// Destined to be overridden by [ModifierClass].
  T overrideByModifierClass;

  /// Destined to be overridden by [GenericMixin].
  T overrideByGenericMixin;

  /// Destined to be overridden by [ModifierClass] and [GenericMixin], both.
  T overrideByBoth;

  /// Destined to be overridden by everything.
  T overrideByEverything;
}

/// A class extending a generic class.
class ModifierClass<T> extends GenericClass<T> {
  T modifierMember;

  @override
  T overrideByModifierClass;

  @override
  T overrideByBoth;

  @override
  T overrideByEverything;
}

/// A generic mixin that requires GenericClass as a superclass.
mixin GenericMixin<T> on GenericClass<T> {
  T mixinMember;

  @override
  T overrideByGenericMixin;

  @override
  T overrideByBoth;

  @override
  T overrideByEverything;
}

/// A class verifying type inference across new-style mixins.
class TypeInferenceMixedIn extends ModifierClass<int> with GenericMixin {
  @override
  int overrideByEverything;
}

GenericMixin<T> aMixinReturningFunction<T>() => null;

functionUsingMixinReturningFunction() {
  GenericClass<int> using = aMixinReturningFunction();
}

/// A super class, with many powers. Link to [Apple] from another library.
@deprecated
class SuperAwesomeClass {
  /// In the super class.
  List<String> powers;

  /// In the super class.
  ///
  /// Another comment line.
  void fly(int height, Cool superCool, {String msg}) {
    // ignore: unused_local_variable, avoid_init_to_null
    var x = null;
    // ignore: unused_local_variable
    int i, y;
    for (int z = 0; z < 100; z++) {
      print('hi');
    }
  }

  SuperAwesomeClass operator -(other) {
    return null;
  }
}

class TypedefUsingClass {
  ParameterizedTypedef<double> x;
  TypedefUsingClass(this.x);
}

typedef void myCoolTypedef(Cool x, bool y);

/// This function returns Future<void>
Future<void> returningFutureVoid() async {}

/// This function requires a Future<void> as a parameter
void aVoidParameter(Future<void> p1) {}

/// This class extends Future<void>
abstract class ExtendsFutureVoid extends Future<void> {
  // ignore: missing_return
  factory ExtendsFutureVoid(FutureOr<void> computation()) {}
}

/// This class implements Future<void>
abstract class ImplementsFutureVoid implements Future<void> {}

/// This class takes a type, and it might be void.
class ATypeTakingClass<T> {
  // ignore: missing_return
  T aMethodMaybeReturningVoid() {}
}

class ABaseClass {}

class ATypeTakingClassMixedIn extends ABaseClass with ATypeTakingClass<void> {}

/// Names are actually wrong in this class, but when we extend it,
/// they are correct.
class ImplicitProperties {
  /// Docs for implicitGetterExplicitSetter from ImplicitProperties.
  String implicitGetterExplicitSetter;

  /// Docs for explicitGetterImplicitSetter from ImplicitProperties.
  List<int> explicitGetterImplicitSetter;

  /// A simple property to inherit.
  int forInheriting;

  /// @nodoc for you
  String get explicitNonDocumentedGetter => "something";

  /// @nodoc for you but check downstream
  String get explicitNonDocumentedInBaseClassGetter => "something else";

  /// but documented here.
  double get explicitPartiallyDocumentedField => 1.3;

  /// @nodoc here, you should never see this
  set explicitPartiallyDocumentedField(double foo) {}

  /// @nodoc here, you should never see this
  String documentedPartialFieldInSubclassOnly;

  /// Explicit getter for inheriting.
  int get explicitGetterSetterForInheriting => 12;

  /// Explicit setter for inheriting.
  set explicitGetterSetterForInheriting(int foo) {}
}

/// Classes with unusual properties?  I don't think they exist.
///
/// Or rather, dartdoc used to think they didn't exist.  Check the variations
/// on inheritance and overrides here.
class ClassWithUnusualProperties extends ImplicitProperties {
  /// This getter is documented, so we should see a read-only property here.
  @override
  String get documentedPartialFieldInSubclassOnly => "overridden getter";

  @override

  /// Docs for setter of implicitGetterExplicitSetter.
  set implicitGetterExplicitSetter(String x) {}

  @override

  /// Getter doc for explicitGetterImplicitSetter
  List<int> get explicitGetterImplicitSetter => List<int>();

  myCoolTypedef _aFunction;

  /// Since I have a different doc, I should be documented.
  @override
  String get explicitNonDocumentedInBaseClassGetter => "something else";

  /// Getter doc for explicitGetterSetter.
  @Annotation('a Getter Annotation')
  myCoolTypedef get explicitGetterSetter {
    return _aFunction;
  }

  /// @nodoc for a simple hidden property.
  String simpleHidden;

  /// @nodoc on setter
  set explicitNodocGetterSetter(String s) {}

  /// @nodoc on getter
  String get explicitNodocGetterSetter => "something";

  /// This property is not synthetic, so it might reference [f] -- display it.
  @Annotation('a Setter Annotation')
  set explicitGetterSetter(myCoolTypedef f) => _aFunction = f;

  /// This property only has a getter and no setter; no parameters to print.
  myCoolTypedef get explicitGetter {
    return _aFunction;
  }

  /// Set to [f], and don't warn about [bar] or [baz].
  set explicitSetter(f(int bar, Cool baz, List<int> macTruck)) {}

  /// This property has some docs, too.
  final Set finalProperty = Set();

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
// ignore: deprecated_member_use
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

  static const Foo2 BAR = Foo2(0);
  static const Foo2 BAZ = Foo2(1);
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

/// Simple @nodoc property.
String simplePropertyHidden;

/// Setter docs should be shown.
set getterSetterNodocGetter(int value) {}

/// @nodoc on getter.
int get getterSetterNodocGetter => 3;

/// @nodoc on setter
set getterSetterNodocSetter(int value) {}

/// Getter docs should be shown.
int get getterSetterNodocSetter => 4;

/// @nodoc on the setter
set getterSetterNodocBoth(String value) {}

/// And @nodoc on the getter, so entire TopLevelVariable should be invisible.
String get getterSetterNodocBoth => "I do not exist";

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

/// Explicitly return a `FutureOr`.
FutureOr thisIsFutureOr() => null;

/// Explicitly return a `FutureOr<Null>`.
FutureOr<Null> thisIsFutureOrNull() => null;

/// Explicitly return a `FutureOr<T>`.
FutureOr<T> thisIsFutureOrT<T>() => null;

/// Has a parameter explicitly typed `FutureOr<Null>`.
void paramOfFutureOrNull(FutureOr<Null> future) {}

/// Has a type parameter bound to `FutureOr<List>`.
void typeParamOfFutureOr<T extends FutureOr<List>>() {}

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

/// Test that we can properly handle covariant member parameters.
class CovariantMemberParams {
  covariant int covariantField;

  set covariantSetter(covariant int x) {}

  void applyCovariantParams(
      covariant num aNumber, covariant dynamic aDynamic) {}
}

/// I have a generic and it extends [Foo2]
class HasGenericWithExtends<T extends Foo2> {}

/// Extends [ListBase]
class SpecialList<E> extends ListBase<E> {
  // ignore: annotate_overrides
  E operator [](int index) {
    return null;
  }

  // ignore: annotate_overrides
  int get length => 0;

  // ignore: annotate_overrides
  void set length(int length) {}

  // ignore: annotate_overrides
  void operator []=(int index, E value) {}
}

/// This inherits operators.
class ExtraSpecialList<E> extends SpecialList {}

/// Category information should not follow inheritance.
///
/// {@category Excellent}
/// {@category Unreal}
/// {@category More Excellence}
/// {@subCategory Things and Such}
/// {@image https://flutter.io/images/catalog-widget-placeholder.png}
/// {@samples https://flutter.io}
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
  // ignore: deprecated_member_use
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
  ///
  /// Reference to a bracket operator within this class [operator []] xxx
  ///
  /// Reference to a bracket operator in another class [SpecialList.operator []] xxx
  ///
  /// Reference containing a type parameter [ExtraSpecialList<Object>]
  ///
  /// Reference to something that doesn't exist containing a type parameter [ThisIsNotHereNoWay<MyType>]
  ///
  /// Link to a nonexistent file (erroneously expects base href): [link](SubForDocComments/localMethod.html)
  ///
  /// Link to an existing file: [link](../SubForDocComments/localMethod.html)
  String doAwesomeStuff(int value) => null;

  void anotherMethod() {}

  /// Some really great topics.
  bool get getterWithDocs => true;

  String operator [](String key) => "${key}'s value";
}

/// Verify that we can define and use macros inside accessors.
enum MacrosFromAccessors {
  /// Define a macro.
  /// {@template test_package_docs:accessorMacro}
  /// This is a macro defined in an Enum accessor.
  /// {@endtemplate}
  macroDefinedHere,

  /// Reference a macro.
  /// {@macro test_package_docs:accessorMacro}
  macroReferencedHere,
}

/// Testing if docs for inherited method are correct.
/// {@category NotSoExcellent}
class SubForDocComments extends BaseForDocComments {
  /// Reference to [foo] and [bar]
  void localMethod(String foo, bar) {}

  @override
  final bool getterWithDocs = false;
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

/// This is to test referring to a constructor.
///
/// This should refer to a class: [ReferToADefaultConstructor].
/// This should refer to the constructor: [ReferToADefaultConstructor.ReferToADefaultConstructor].
class ReferToADefaultConstructor {
  /// A default constructor.
  ReferToADefaultConstructor();
}

/// Test operator references: [OperatorReferenceClass.==].
class OperatorReferenceClass {
  OperatorReferenceClass();

  @override
  bool operator ==(dynamic other) {
    return false;
  }
}

class _PrivateClassDefiningSomething {
  bool aMethod() {
    return false;
  }
}

class InheritingClassOne extends _PrivateClassDefiningSomething {}

class InheritingClassTwo extends _PrivateClassDefiningSomething {}

class ReferringClass {
  /// Here I am referring by full names, to [fake.InheritingClassOne.aMethod],
  /// and to [fake.InheritingClassTwo.aMethod].  With luck, both of these
  /// two resolve correctly.
  bool notAMethodFromPrivateClass() {
    return false;
  }
}

//
// Test classes for extension discovery.
//

extension Arm on Megatron<int> {
  bool get hasLeftArm => true;
}

extension Leg on Megatron<String> {
  bool get hasRightLeg => true;
}

class Megatron<T> {}

class SuperMegaTron<T extends String> extends Megatron<String> {}

extension Uphill on AnotherExtended<SubclassBaseTest> {
  bool get hasDirection => false;
}

class SubclassBaseTest extends BaseTest {}

class BaseTest {}

class AnotherExtended<T extends BaseTest> extends BaseTest {}

class BigAnotherExtended extends AnotherExtended<SubclassBaseTest> {}

extension ExtensionCheckLeft on Implemented1 {
  int get left => 3;
}

extension ExtensionCheckRight on Implemented2 {
  int get right => 4;
}

extension ExtensionCheckCenter on BaseExtended {
  bool get center => true;
}

class BaseExtended {}

class Implemented1 {}

class Implemented2 {}

class Implementor extends BaseExtended
    implements Implemented1, Implemented2, Implementor2 {}

extension ExtensionCheckImplementor2 on Implementor2 {
  int get test => 1;
}

class Implementor2 implements Implemented1 {}

class OldSchoolMixin {
  aThing() {}
}

mixin NewSchoolMixin {}

extension OnNewSchool on NewSchoolMixin {
  String get bar => 'hello';
}

extension OnOldSchool on OldSchoolMixin {
  int get foo => 4;
}

class School with OldSchoolMixin, NewSchoolMixin {}

//
//
//

/// Test an edge case for cases where inherited ExecutableElements can come
/// both from private classes and public interfaces.  The test makes sure the
/// class still takes precedence (#1561).
abstract class MIEEMixinWithOverride<K, V> = MIEEBase<K, V>
    with _MIEEPrivateOverride<K, V>;

abstract class _MIEEPrivateOverride<K, V> implements MIEEThing<K, V> {
  // ignore: annotate_overrides
  void operator []=(K key, V value) {
    throw UnsupportedError("Never use this");
  }
}

abstract class MIEEBase<K, V> extends MIEEMixin<K, V> {}

abstract class MIEEMixin<K, V> implements MIEEThing<K, V> {
  // ignore: annotate_overrides
  operator []=(K key, V value);
}

abstract class MIEEThing<K, V> {
  void operator []=(K key, V value);
}

abstract class _NonCanonicalToolUser {
  /// Invokes a tool without the $INPUT token or args.
  ///
  /// {@tool drill}
  /// Some text in the drill that references [noInvokeTool].
  /// {@end-tool}
  void invokeToolNonCanonical();
}

abstract class CanonicalToolUser extends _NonCanonicalToolUser {}

abstract class ImplementingClassForTool {
  /// Invokes a tool from inherited documentation via `implemented`
  ///
  /// {@tool drill}
  /// This is some drill text right here.
  /// {@end-tool}
  void invokeToolParentDoc();
}

/// The method [invokeToolParentDoc] gets its documentation from an interface class.
abstract class CanonicalPrivateInheritedToolUser
    implements ImplementingClassForTool {
  @override
  void invokeToolParentDoc() {
    print('hello, tool world');
  }
}

/*
 * Complex extension methods + typedefs case.
 *
 * TODO(jcollins-g): add unit tests around behavior when #2701 is implemented.
 * Until #2701 is fixed we mostly are testing that we don't crash because
 * DoSomething2X is declared.
 */

typedef R Function1<A, R>(A a);
typedef R Function2<A, B, R>(A a, B b);

extension DoSomething2X<A, B, R> on Function1<A, Function1<B, R>> {
  Function2<A, B, R> something() => (A first, B second) => this(first)(second);
}

/// Extensions might exist on types defined by the language.
extension ExtensionOnDynamic on dynamic {
  void youCanAlwaysCallMe() {}
}

extension ExtensionOnVoid on void {
  void youCanStillAlwaysCallMe() {}
}

extension ExtensionOnNull on Null {
  void youCanOnlyCallMeOnNulls() {}
}

/// Extensions might exist on unbound type parameters.
extension ExtensionOnTypeParameter<T> on T {
  T aFunctionReturningT(T other) => other;
}
