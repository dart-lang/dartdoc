// This library does not exist.
import 'foo.dart';

/// Some sample `dartdoc` comments here.
void myTestFunction() {
  print('one');
  print('two');
  // This class cannot be found.
  Foo foo = Foo('three');
}
