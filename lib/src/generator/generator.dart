// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library containing an abstract documentation generator.
library dartdoc.generator;

import 'dart:async' show Future;
import 'dart:io' show Directory;

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart' show PackageGraph;
import 'package:dartdoc/src/warnings.dart';

abstract class FileWriter {
  /// All filenames written by this generator.
  Set<String> get writtenFiles;

  /// Write [content] to a file at [filePath].
  void write(String filePath, Object content,
      {bool allowOverwrite, Warnable element});
}

/// An abstract class that defines a generator that generates documentation for
/// a given package.
///
/// Generators can generate documentation in different formats: html, json etc.
abstract class Generator {
  /// Generate the documentation for the given package using the specified
  /// writer. Completes the returned future when done.
  Future generate(PackageGraph packageGraph, FileWriter writer);
}

/// Dartdoc options related to generators generally.
mixin GeneratorContext on DartdocOptionContextBase {
  List<String> get footer => optionSet['footer'].valueAt(context);

  List<String> get footerText => optionSet['footerText'].valueAt(context);

  // Synthetic. TODO(jcollins-g): Eliminate special case for SDK and use config file.
  bool get addSdkFooter => optionSet['addSdkFooter'].valueAt(context);

  List<String> get header => optionSet['header'].valueAt(context);

  bool get prettyIndexJson => optionSet['prettyIndexJson'].valueAt(context);

  String get favicon => optionSet['favicon'].valueAt(context);

  String get relCanonicalPrefix =>
      optionSet['relCanonicalPrefix'].valueAt(context);

  String get templatesDir => optionSet['templatesDir'].valueAt(context);

  // TODO(jdkoren): duplicated temporarily so that GeneratorContext is enough for configuration.
  bool get useBaseHref => optionSet['useBaseHref'].valueAt(context);
}

Future<List<DartdocOption>> createGeneratorOptions() async {
  return <DartdocOption>[
    DartdocOptionArgFile<List<String>>('footer', [],
        isFile: true,
        help:
            'Paths to files with content to add to page footers, but possibly '
            'outside of dedicated footer elements for the generator (e.g. '
            'outside of <footer> for an HTML generator). To add text content '
            'to dedicated footer elements, use --footer-text instead.',
        mustExist: true,
        splitCommas: true),
    DartdocOptionArgFile<List<String>>('footerText', [],
        isFile: true,
        help: 'Paths to files with content to add to page footers (next to the '
            'package name and version).',
        mustExist: true,
        splitCommas: true),
    DartdocOptionSyntheticOnly<bool>(
      'addSdkFooter',
      (DartdocSyntheticOption<bool> option, Directory dir) {
        return option.root['topLevelPackageMeta'].valueAt(dir).isSdk;
      },
      help: 'Whether the SDK footer text should be added (synthetic)',
    ),
    DartdocOptionArgFile<List<String>>('header', [],
        isFile: true,
        help: 'Paths to files with content to add to page headers.',
        splitCommas: true),
    DartdocOptionArgOnly<bool>('prettyIndexJson', false,
        help:
            'Generates `index.json` with indentation and newlines. The file is '
            'larger, but it\'s also easier to diff.',
        negatable: false),
    DartdocOptionArgFile<String>('favicon', null,
        isFile: true,
        help: 'A path to a favicon for the generated docs.',
        mustExist: true),
    DartdocOptionArgOnly<String>('relCanonicalPrefix', null,
        help:
            'If provided, add a rel="canonical" prefixed with provided value. '
            'Consider using if building many versions of the docs for public '
            'SEO; learn more at https://goo.gl/gktN6F.'),
    DartdocOptionArgOnly<String>('templatesDir', null,
        isDir: true,
        mustExist: true,
        hide: true,
        help:
            'Path to a directory with templates to use instead of the default '
            'ones. Directory must contain a file for each of the following: '
            '404error, category, class, constant, constructor, enum, function, '
            'index, library, method, mixin, property, top_level_constant, '
            'top_level_property, typedef. Partial templates are supported; '
            'they must begin with an underscore, and references to them must '
            'omit the leading underscore (e.g. use {{>foo}} to reference the '
            'partial template named _foo).'),
  ];
}
