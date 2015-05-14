/// a library
library ex;

export 'src/mylib.dart' show Helper;

int function1(String s, bool b, lastParam) => 5;

double number;

get y => 2;

const String COLOR = 'red';
const String COLOR_GREEN = 'green';
const String COLOR_ORANGE = 'orange';
const String COMPLEX_COLOR = 'red' + '-' + 'green' + '-' + 'blue';
const ConstantCat MY_CAT = const ConstantCat('tabby');

typedef String processMessage(String msg);

/// Sample class [String]
class Apple {
  static const int n = 5;
  static String string = 'hello';
  String _s2;
  int m = 0;

  ///Constructor
  Apple();

  String get s => _s2;

  /// this is a method
  void m1() {}

  operator *(Apple other) => this;

  void printMsg(String msg, [bool linebreak]) {}

  bool isGreaterThan(int number, {int check: 5}) {
    return number > check;
  }
}
/// Extends class [Apple]
class B extends Apple with Cat {
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
}

// Do NOT add a doc comment to C. Testing blank comments.

abstract class Cat {
  bool get isImplemented;
}

/// implements [Cat], [E]
class Dog implements Cat, E {
  String name;

  @deprecated
  List<Apple> getClassA() {
    return [new Apple()];
  }

  @override
  bool get isImplemented => true;

  operator ==(Dog other) => name == other.name;

  foo() async => 42;

  void testMethod(Iterable it) {}
}

abstract class E {}

class F extends Dog with _PrivateAbstractClass {
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
