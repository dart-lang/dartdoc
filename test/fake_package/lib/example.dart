/// a library
library ex;

int function1(String s, bool b) => 5;

double number;

get y => 2;

const String COLOR = 'red';

typedef String processMessage(String msg);

/// Sample class [String]
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
  
  List<String> list;
  
  @override
  void m1() {
    var a = 6;
    var b = a * 9;
  }
}

// Do NOT add a doc comment to C. Testing blank comments.

abstract class C {
  
  bool get isImplemented;
}

abstract class E {

}

class D implements C, E {
  
  @override
  bool get isImplemented => true;
  
  List<A> getClassA() {
    return [new A()];
  }
}

