// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_generator;

import 'dart:async' show Future, StreamController, Stream;
import 'dart:io' show Directory, File;
import 'dart:isolate';

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/empty_generator.dart';
import 'package:dartdoc/src/generator.dart';
import 'package:dartdoc/src/html/html_generator_instance.dart';
import 'package:dartdoc/src/html/template_data.dart';
import 'package:dartdoc/src/html/templates.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

typedef Renderer = String Function(String input);

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

  @override

  /// Actually write out the documentation for [packageGraph].
  /// Stores the HtmlGeneratorInstance so we can access it in [writtenFiles].
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

Future<List<Generator>> initEmptyGenerators(DartdocOptionContext config) async {
  return [EmptyGenerator()];
}

/// Initialize and setup the generators.
Future<List<Generator>> initGenerators(
    DartdocGeneratorOptionContext config) async {
  // TODO(jcollins-g): Rationalize based on GeneratorContext all the way down
  // through the generators.
  HtmlGeneratorOptions options = HtmlGeneratorOptions(
      relCanonicalPrefix: config.relCanonicalPrefix,
      toolVersion: dartdocVersion,
      faviconPath: config.favicon,
      prettyIndexJson: config.prettyIndexJson,
      templatesDir: config.templatesDir,
      useBaseHref: config.useBaseHref);

  return [
    await HtmlGenerator.create(
      options: options,
      headers: config.header,
      footers: config.footer,
      footerTexts: config.footerTextPaths,
    )
  ];
}

/// Dartdoc options related to html generation.
mixin HtmlGeneratorContext on DartdocOptionContextBase {
  String get favicon => optionSet['favicon'].valueAt(context);

  String get relCanonicalPrefix =>
      optionSet['relCanonicalPrefix'].valueAt(context);
}

List<DartdocOption> createHtmlGeneratorOptions() {
  return <DartdocOption>[
    DartdocOptionArgFile<String>('favicon', null,
        isFile: true,
        help: 'A path to a favicon for the generated docs.',
        mustExist: true),
    DartdocOptionArgOnly<String>('relCanonicalPrefix', null,
        help:
            'If provided, add a rel="canonical" prefixed with provided value. '
            'Consider using if\nbuilding many versions of the docs for public '
            'SEO; learn more at https://goo.gl/gktN6F.'),
  ];
}
