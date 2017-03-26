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

String dartdocVersion = 'unknown';

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
  final String _url;
  final String _relCanonicalPrefix;
  final Templates _templates;
  final String _toolVersion;
  final String faviconPath;
  final bool useCategories;
  final bool prettyIndexJson;

  final StreamController<File> _onFileCreated =
      new StreamController(sync: true);

  @override
  Stream<File> get onFileCreated => _onFileCreated.stream;

  /// [url] - optional URL for where the docs will be hosted.
  static Future<HtmlGenerator> create(
      {String url,
      List<String> headers,
      List<String> footers,
      String relCanonicalPrefix,
      String toolVersion,
      String faviconPath,
      bool useCategories: false,
      bool prettyIndexJson: false}) async {
    var templates =
        await Templates.create(headerPaths: headers, footerPaths: footers);

    if (toolVersion == null) {
      toolVersion = 'unknown';
    }

    return new HtmlGenerator._(url, relCanonicalPrefix, templates, toolVersion,
        faviconPath: faviconPath,
        useCategories: useCategories,
        prettyIndexJson: prettyIndexJson);
  }

  HtmlGenerator._(
      this._url, this._relCanonicalPrefix, this._templates, this._toolVersion,
      {this.faviconPath, this.useCategories, this.prettyIndexJson: false});

  @override
  Future generate(Package package, Directory out) {
    return new HtmlGeneratorInstance(_toolVersion, _url, _templates, package,
            out, _onFileCreated, _relCanonicalPrefix,
            faviconPath: faviconPath,
            useCategories: useCategories,
            prettyIndexJson: prettyIndexJson)
        .generate();
  }
}
