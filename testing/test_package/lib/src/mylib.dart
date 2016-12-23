library src.mylib;

void helperFunction(String message) => print(message);

/// Even unresolved references in the same library should be resolved
/// [Apple]
/// [ex.B]
class Helper {
  Helper();

  String getContents() => '';
}
