// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.generator;

import 'dart:io';

import 'src/model.dart';

/// An abstract class that defines a generator that generates documentation
/// for a given package. Generators can generate documentation in different
/// formats - html, json etc
abstract class Generator {
  Package package;
  Directory out;

  Generator();

  /// Generate the documentation for the given package in the
  /// speicifed directory.
  void generate(Package package, Directory out);
}
