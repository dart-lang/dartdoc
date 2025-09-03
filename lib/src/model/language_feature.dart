// Copyright (c) 2020, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// An abstraction for a language feature; used to render tags ('chips') to
/// notify the user that the documentation should be specially interpreted.
class LanguageFeature {
  /// The description of this language feature.
  String? description;

  /// A URL containing more information about this feature or `null` if there
  /// is none.
  String? url;

  /// The name of this language feature.
  final String name;

  LanguageFeature(this.name, this.description, this.url);

  /// The rendered label for this language feature.
  String get featureLabel {
    final buffer = StringBuffer();
    final url = this.url;

    if (url != null) {
      buffer.write('<a href="');
      buffer.write(url);
      buffer.write('"');
    } else {
      buffer.write('<span');
    }

    buffer.write(' class="feature feature-');
    buffer.writeAll(name.toLowerCase().split(' '), '-');
    buffer.write('" title="');
    buffer.write(description);
    buffer.write('">');
    buffer.write(name);

    if (url != null) {
      buffer.write('</a>');
    } else {
      buffer.write('</span>');
    }

    return buffer.toString();
  }
}
