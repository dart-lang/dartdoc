@Renderer(#renderFoo, Context<Foo>())
@Renderer(#renderBar, Context<Bar>())
library dartdoc.testing.foo;

import 'package:dartdoc/src/mustachio/annotations.dart';

class Foo {
  String s1;
  bool b1;
  List<int> l1;
}

class Bar {
  Foo foo;
  String s2;
}
