// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Classes implementing this have a package-public/private distinction.
abstract interface class Privacy {
  /// Whether this is "package-public."
  ///
  /// A "package-public" element satisfies the following requirements:
  /// * is not documented with the `@nodoc` directive,
  /// * for a library, is found in a package's top-level 'lib' directory, and
  ///   not found in it's 'lib/src' directory,
  /// * for a library member, is in a _public_ library's exported namespace, and
  ///   is not privately named, nor an unnamed extension,
  /// * for a container (class, enum, extension, extension type, mixin) member,
  ///   is in a _public_ container, and is not privately named.
  bool get isPublic;
}
