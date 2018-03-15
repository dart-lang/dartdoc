// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show File;

import 'package:path/path.dart' as p;

import '../generator.dart';
import '../model.dart';
import 'html_generator_instance.dart';
import 'template_data.dart';
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
  final Set<String> writtenFiles = new Set<String>();

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

  /// Actually write out the documentation for [packageGraph].
  /// Stores the HtmlGeneratorInstance so we can access it in [writtenFiles].
  Future generate(PackageGraph packageGraph, String outputDirectoryPath) async {
    assert(_instance == null);

    var enabled = true;
    void write(String filePath, Object content, {bool allowOverwrite}) {
      allowOverwrite ??= false;
      if (!enabled) {
        throw new StateError('`write` was called after `generate` completed.');
      }
      // If you see this assert, we're probably being called to build non-canonical
      // docs somehow.  Check data.self.isCanonical and callers for bugs.
      assert(allowOverwrite || !writtenFiles.contains(filePath));

      var file = new File(p.join(outputDirectoryPath, filePath));
      var parent = file.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }

      if (content is String) {
        file.writeAsStringSync(content);
      } else if (content is List<int>) {
        file.writeAsBytesSync(content);
      } else {
        throw new ArgumentError.value(
            content, 'content', '`content` must be `String` or `List<int>`.');
      }
      _onFileCreated.add(file);
      writtenFiles.add(filePath);
    }

    try {
      _instance =
          new HtmlGeneratorInstance(_options, _templates, packageGraph, write);
      await _instance.generate();
    } finally {
      enabled = false;
    }
  }
}

class HtmlGeneratorOptions implements HtmlOptions {
  final String url;
  final String faviconPath;
  final bool prettyIndexJson;

  @override
  final bool displayAsPackages;

  @override
  final String relCanonicalPrefix;

  @override
  final String toolVersion;

  HtmlGeneratorOptions(
      {this.url,
      this.relCanonicalPrefix,
      this.faviconPath,
      String toolVersion,
      this.displayAsPackages: false,
      this.prettyIndexJson: false})
      : this.toolVersion = toolVersion ?? 'unknown';
}
