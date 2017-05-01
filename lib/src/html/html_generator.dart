// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File;

import '../generator.dart';
import '../model.dart';
import 'html_generator_instance.dart';
import 'templates.dart';

typedef String Renderer(String input);

// Generation order for libraries:
//   constants
//   typedefs
//   properties
//   functions
//   enums
//   classes
//   exceptions
//
// Generation order for classes:
//   constants
//   static properties
//   static methods
//   properties
//   constructors
//   operators
//   methods

class HtmlGenerator extends Generator {
  final Templates _templates;
  final HtmlGeneratorOptions _options;
  HtmlGeneratorInstance _instance;

  final StreamController<File> _onFileCreated =
      new StreamController(sync: true);

  @override
  Stream<File> get onFileCreated => _onFileCreated.stream;

  @override
  Set<String> get writtenFiles => _instance.writtenFiles;

  /// [url] - optional URL for where the docs will be hosted.
  static Future<HtmlGenerator> create(
      {HtmlGeneratorOptions options,
      List<String> headers,
      List<String> footers,
      List<String> footerTexts}) async {
    var templates = await Templates.create(
        headerPaths: headers,
        footerPaths: footers,
        footerTextPaths: footerTexts);

    return new HtmlGenerator._(
        options ?? new HtmlGeneratorOptions(), templates);
  }

  HtmlGenerator._(this._options, this._templates);

  @override
  Future generate(Package package, Directory out) {
    _instance = new HtmlGeneratorInstance(
        _options, _templates, package, out, _onFileCreated);
    return _instance.generate();
  }
}

class HtmlGeneratorOptions {
  final String url;
  final String relCanonicalPrefix;
  final String faviconPath;
  final String toolVersion;
  final bool useCategories;
  final bool prettyIndexJson;

  HtmlGeneratorOptions(
      {this.url,
      this.relCanonicalPrefix,
      this.faviconPath,
      String toolVersion,
      this.useCategories: false,
      this.prettyIndexJson: false})
      : this.toolVersion = toolVersion ?? 'unknown';
}
