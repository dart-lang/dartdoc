/// library with extensions
library ext;

class Apple<M> {
  final String name = 'name';

  bool get isImplemented => true;
}

class _Private {
  void sIs() {}
}

/// Extension on a class defined in the package
extension AnExtension on Apple {
  int call(String s) => 0;
}

/// Extension on List
extension FancyList<Z> on List<Z> {
  int get doubleLength => this.length * 2;
  List<Z> operator-() => this.reversed.toList();
  List<List<Z>> split(int at) =>
  <List<Z>>[this.sublist(0, at), this.sublist(at)];
  static List<Z> big() => List(1000000);
}

extension SymDiff<T> on Set<T> {
  Set<T> symmetricDifference(Set<T> other) =>
  this.difference(other).union(other.difference(this));
}

/// Extensions can be made specific.
extension IntSet on Set<int> {
  int sum() => this.fold(0, (prev, element) => prev + element);
}

// Extensions can be private.
extension _Shhh on Object {
  void secret() { }
}

// Or unnamed!
extension on Object {
  void bar() { }
}

extension Bar on Object {
  void bar() { }
}


