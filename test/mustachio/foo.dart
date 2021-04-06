@Renderer.forTest(#renderFoo, Context<Foo>(), 'templates/foo.html',
    visibleTypes: {Property1, Property2, Property3})
@Renderer.forTest(#renderBar, Context<Bar>(), 'templates/bar.html')
@Renderer.forTest(#renderBaz, Context<Baz>(), 'templates/baz.html')
library dartdoc.testing.foo;

import 'package:dartdoc/src/mustachio/annotations.dart';

class FooBase<T extends Object> {
  T baz;
}

class Foo extends FooBase<Baz> {
  String s1;
  bool b1;
  List<int> l1;
  @override
  Baz baz;
  Property1 p1;
}

class Bar {
  Foo foo;
  String s2;
  Baz baz;
  bool l1;
}

class Baz {
  Bar bar;
}

class Property1 {
  Property2 p2;
}

class Property2 with Mixin1 {
  String s;
}

mixin Mixin1 {
  Property3 p3;
}

class Property3 {
  String s;
}
