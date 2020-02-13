// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_frontend.dart';
import 'package:dartdoc/src/generator/html_generator_backend.dart';

Future<Generator> initHtmlGenerator(
    DartdocGeneratorOptionContext context) async {
  var backend = await HtmlGeneratorBackend.fromContext(context);
  return GeneratorFrontEnd(backend);
}
