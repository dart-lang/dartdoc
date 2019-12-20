// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator.dart';
import 'package:dartdoc/src/html/html_generator_instance.dart';
import 'package:dartdoc/src/html/template_data.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

class HtmlGenerator extends Generator {
  final Templates _templates;
  final HtmlGeneratorOptions _options;
  HtmlGeneratorInstance _instance;

  final StreamController<void> _onFileCreated = StreamController(sync: true);

  @override
  Stream<void> get onFileCreated => _onFileCreated.stream;

  @override
  final Map<String, Warnable> writtenFiles = {};

  static Future<HtmlGenerator> create(
      {HtmlGeneratorOptions options,
      List<String> headers,
      List<String> footers,
      List<String> footerTexts}) async {
    var templates;
    String dirname = options?.templatesDir;
    if (dirname != null) {
      Directory templateDir = Directory(dirname);
      templates = await Templates.fromDirectory(templateDir,
          headerPaths: headers,
          footerPaths: footers,
          footerTextPaths: footerTexts);
    } else {
      templates = await Templates.createDefault(
          headerPaths: headers,
          footerPaths: footers,
          footerTextPaths: footerTexts);
    }

    return HtmlGenerator._(options ?? HtmlGeneratorOptions(), templates);
  }

  HtmlGenerator._(this._options, this._templates);

  /// Actually write out the documentation for [packageGraph].
  /// Stores the HtmlGeneratorInstance so we can access it in [writtenFiles].
  @override
  Future generate(PackageGraph packageGraph, String outputDirectoryPath) async {
    assert(_instance == null);

    var enabled = true;
    void write(String filePath, Object content,
        {bool allowOverwrite, Warnable element}) {
      allowOverwrite ??= false;
      if (!enabled) {
        throw StateError('`write` was called after `generate` completed.');
      }
      if (!allowOverwrite) {
        if (writtenFiles.containsKey(filePath)) {
          assert(element != null,
              'Attempted overwrite of ${filePath} without corresponding element');
          Warnable originalElement = writtenFiles[filePath];
          Iterable<Warnable> referredFrom =
              originalElement != null ? [originalElement] : null;
          element?.warn(PackageWarning.duplicateFile,
              message: filePath, referredFrom: referredFrom);
        }
      }

      var file = File(path.join(outputDirectoryPath, filePath));
      var parent = file.parent;
      if (!parent.existsSync()) {
        parent.createSync(recursive: true);
      }

      if (content is String) {
        file.writeAsStringSync(content);
      } else if (content is List<int>) {
        file.writeAsBytesSync(content);
      } else {
        throw ArgumentError.value(
            content, 'content', '`content` must be `String` or `List<int>`.');
      }
      _onFileCreated.add(file);
      writtenFiles[filePath] = element;
    }

    try {
      _instance =
          HtmlGeneratorInstance(_options, _templates, packageGraph, write);
      await _instance.generate();
    } finally {
      enabled = false;
    }
  }
}

class HtmlGeneratorOptions implements HtmlOptions {
  final String faviconPath;
  final bool prettyIndexJson;
  final String templatesDir;

  @override
  final String relCanonicalPrefix;

  @override
  final String toolVersion;

  @override
  final bool useBaseHref;

  HtmlGeneratorOptions(
      {this.relCanonicalPrefix,
      this.faviconPath,
      String toolVersion,
      this.prettyIndexJson = false,
      this.templatesDir,
      this.useBaseHref = false})
      : this.toolVersion = toolVersion ?? 'unknown';
}

/// Initialize and setup the generators.
Future<Generator> initHtmlGenerators(GeneratorContext context) async {
  // TODO(jcollins-g): Rationalize based on GeneratorContext all the way down
  // through the generators.
  HtmlGeneratorOptions options = HtmlGeneratorOptions(
      relCanonicalPrefix: context.relCanonicalPrefix,
      toolVersion: dartdocVersion,
      faviconPath: context.favicon,
      prettyIndexJson: context.prettyIndexJson,
      templatesDir: context.templatesDir,
      useBaseHref: context.useBaseHref);

  return HtmlGenerator.create(
    options: options,
    headers: context.header,
    footers: context.footer,
    footerTexts: context.footerTextPaths,
  );
}
