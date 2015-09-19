// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library containing an abstract documentation generator.
library dartdoc.generator;

import 'dart:async';
import 'dart:io';

import 'src/model.dart' show Package;

/// Called when the generator has generated a file for a thing.
typedef void ProgressCallback(File file);

/// An abstract class that defines a generator that generates documentation for
/// a given package.
///
/// Generators can generate documentation in different formats: html, json etc.
abstract class Generator {
  /// Generate the documentation for the given package in the specified
  /// directory. Completes the returned future when done.
  Future generate(Package package, Directory out,
      {ProgressCallback onProgress});
}
