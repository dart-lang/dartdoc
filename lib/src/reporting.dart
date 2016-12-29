library reporting;

import 'config.dart';

void warning(String message) {
  // TODO: Could handle fatal warnings here, or print to stderr, or remember
  // that we had at least one warning, and exit with non-null exit code in this case.
  if (config != null && config.showWarnings) {
    print("warning: ${message}");
  }
}