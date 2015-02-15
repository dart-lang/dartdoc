/// # WOW FAKE PACKAGE IS __BEST__ [PACKAGE][pkg]
///
/// If you don't have this package yet, get it.
/// Don't ask questions.
///
/// My favorite class is [Cool].
///
/// *Why should you get this package?*
///
/// * We told you so.
/// * Everyone is doing it.
/// * It smells nice.
///
/// [pkg]: http://example.org
library fake;

import 'example.dart';

class ConstantClass {
  final String value;
  const ConstantClass(this.value);
}

// No dart docs on purpose. Also, a non-primitive const class.
const ConstantClass CUSTOM_CLASS = const ConstantClass('custom');

/// Up is a direction.
///
/// Getting up in the morning can be hard.
const String UP = 'up';

/// Dynamic-typed down.
const DOWN = 'down';

/// A constant integer value,
/// which is a bit redundant.
const int ZERO = 0;

/// Takes input, returns output.
typedef String FakeProcesses(String input);

/// A typedef with a type parameter.
typedef T GenericTypedef<T>(T input);

/// This class is cool!
class Cool {

}

/// An interface that can be implemented.
abstract class Interface {

}

/// Yet another interface that can be implemented.
abstract class AnotherInterface {

}

/// This is a very long line spread
/// across... wait for it... two physical lines.
///
/// The rest of this is not in the first paragraph.
class LongFirstLine implements Interface, AnotherInterface {

  /// The default constructor.
  LongFirstLine();

  /// Named constructors are awesome.
  ///
  /// The map is a key/value pairs of data that helps create an instance.
  LongFirstLine.fromMap(Map data);
}

/// My bad!
class Oops implements Exception {
  final String message;
  Oops(this.message);
}

/// Also, my bad.
class Doh extends Error {

}

/// ROYGBIV
enum Color {
  RED, ORANGE, YELLOW, GREEN, BLUE, INDIGO, VIOLET
}

/// Constant property.
const double PI = 3.14159;

/// Final property.
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

/// Top-level function 2 params and 1 optional positional param.
String topLevelFunction(int param1, bool param2, [double optionalPositional = 0.0]) {}

/// A single optional positional param, no type annotation, no default value.

void onlyPositionalWithNoDefaultNoType([anything]) {}

/// Top-level function with 1 param and 2 optional named params, 1 with a
/// default value.
void soIntense(anything, {bool flag: true, int value}) {  }

/// [A] comes from another library.
void paramFromAnotherLib(A thing) {}