@Renderer(#renderFoo, Context<Foo>())
library dartdoc.testing.foo;

import 'package:dartdoc/src/mustachio/annotations.dart';

class Foo {
  String s1 = 's1';
  bool b1 = true;
}
