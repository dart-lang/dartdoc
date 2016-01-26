library src.mylib;

String topLevelVar = 'hi';

typedef void DoThing();

void helperFunction(String message) => print(message);

/// A helper class in an internal src library.
class Helper {
  Helper();

  String getContents() => '';
}
