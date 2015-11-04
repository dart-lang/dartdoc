// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library containing an abstract documentation generator.
library dartdoc.generator;

import 'dart:async' show Stream, Future;
import 'dart:io' show Directory, File;

import 'model.dart' show Package;

/// An abstract class that defines a generator that generates documentation for
/// a given package.
///
/// Generators can generate documentation in different formats: html, json etc.
abstract class Generator {
  /// Generate the documentation for the given package in the specified
  /// directory. Completes the returned future when done.
  Future generate(Package package, Directory out);

  /// Fires when a file is created.
  Stream<File> get onFileCreated;
}
