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

/// Takes input, returns output.
typedef String FakeProcesses(String input);

/// A typedef with a type parameter.
typedef T GenericTypedef<T>(T input);

/// This class is cool!
class Cool {

}

/// This is a very long line spread
/// across... wait for it... two physical lines.
///
/// The rest of this is not in the first paragraph.
class LongFirstLine {

}

/// My bad!
class Oops implements Exception {
  final String message;
  Oops(this.message);
}

/// Also, my bad.
class Doh extends Error {

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