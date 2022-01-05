library mylibpub;

void helperFunction(String message, int i) => print(message);

/// Even unresolved references in the same library should be resolved
/// [Apple]
/// [ex.B]
class YetAnotherHelper {
  YetAnotherHelper();

  String getMoreContents() => '';
}
