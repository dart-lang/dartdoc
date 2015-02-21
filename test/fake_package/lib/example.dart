/// a library
library ex;

int function1(String s, bool b) => 5;

double number;

get y => 2;

const String COLOR = 'red';

typedef String processMessage(String msg);

/// Sample class [String]
class Apple {
  static const int n = 5;
  static String string = 'hello';
  String s2;
  int m = 0;

  ///Constructor
  Apple();

  String get s => s2;

  /// this is a method
  void m1() {}

  void printMsg(String msg, [bool linebreak]) {}

  bool isGreaterThan(int number, {int check:5}) {
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
  }
}

// Do NOT add a doc comment to C. Testing blank comments.

abstract class Cat {

  bool get isImplemented;
}

/// implements [Cat], [E]
class Dog implements Cat, E {

  @deprecated
    List<Apple> getClassA() {
      return [new Apple()];
    }

  @override
  bool get isImplemented => true;

}

abstract class E {

}

class CatString extends StringBuffer {

}

class MyError extends Error {

}

class MyException implements Exception {

}

class MyErrorImplements implements Error {
  StackTrace get stackTrace => null;
}

class MyExceptionImplements implements Exception {

}

class ForAnnotation {
  final String value;
  const ForAnnotation(this.value);
}

@ForAnnotation('my value')
class HasAnnotation {

}