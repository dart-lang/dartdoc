class A {
  /// A link to [AB.fromMap], [fromMap], and [AB] and [A].
  factory A.fromMap(Map<String, dynamic> map) => A._A();

  A._A();
}

class AB {
  factory AB.fromMap(Map<String, dynamic> map) => AB._AB();

  AB._AB();
}