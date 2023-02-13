// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A class representing a failure during dartdoc execution.
///
/// An instance of this is returned if dartdoc fails in an expected way (for
/// instance, if there is an analysis error in the library).
class DartdocFailure implements Exception {
  final String message;

  DartdocFailure(this.message);

  @override
  String toString() => message;
}
