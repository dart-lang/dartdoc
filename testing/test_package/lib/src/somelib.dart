library reexport.somelib;

class SomeClass {}

class SomeOtherClass {}

class YetAnotherClass {}

class AUnicornClass {}

/// A private extension.
extension _Unseen on Object {
  void doYouSeeMe() { }
}

/// An extension without a name
extension on List {
  void somethingNew() { }
}

/// [_Unseen] is not seen, but [DocumentMe] is.
extension DocumentThisExtensionOnce on String {
  String get reportOnString => '$this is wonderful';
}