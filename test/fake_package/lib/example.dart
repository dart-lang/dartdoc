/// a library
library ex;

int function1(String s, bool b) => 5;

int number;

get y => 2;

/// Sample class
class A {
  static const int n = 5;
  static String string = 'hello';
  String s2;
  int m = 0;

  ///Constructor
  A();

  String get s => s2;

  void m1() {}
  
  void printMsg(String msg, [bool linebreak]) {}
  
  bool isGreaterThan(int number, {int check:5}) {
    return number > check;
  }
}
/// Extends class [A]
class B extends A {
  @override
  void m1() {
    var a = 6;
    var b = a * 9;
  }
}

abstract class C {}
