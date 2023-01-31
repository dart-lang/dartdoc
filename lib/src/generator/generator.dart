// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library containing an abstract documentation generator.
library dartdoc.generator;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';

abstract class FileWriter {
  ResourceProvider get resourceProvider;

  /// All filenames written by this generator.
  Set<String> get writtenFiles;

  /// Writes [content] to a file at [filePath].
  ///
  /// If a file is to be overwritten, a warning will be reported on [element].
  void write(String filePath, String content, {Warnable? element});

  /// Writes [content] to a file at [filePath].
  ///
  /// If a file is to be overwritten, a warning will be reported, unless
  /// [allowOverwrite] is `true`.
  void writeBytes(
    String filePath,
    List<int> content, {
    bool allowOverwrite = false,
  });
}

/// A generator generates documentation for a given package.
///
/// Generators can generate documentation in different formats: HTML, JSON, etc.
abstract class Generator {
  /// Generates the documentation for the given package using the specified
  /// writer. Completes the returned future when done.
  Future<void> generate(PackageGraph packageGraph);

  /// The set of of files written by the generator backend.
  Set<String> get writtenFiles;
}

List<DartdocOption> createGeneratorOptions(
    PackageMetaProvider packageMetaProvider) {
  var resourceProvider = packageMetaProvider.resourceProvider;
  return [
    DartdocOptionArgFile<List<String>>('footer', [], resourceProvider,
        optionIs: OptionKind.file,
        help:
            'Paths to files with content to add to page footers, but possibly '
            'outside of dedicated footer elements for the generator (e.g. '
            'outside of <footer> for an HTML generator). To add text content '
            'to dedicated footer elements, use --footer-text instead.',
        mustExist: true,
        splitCommas: true),
    DartdocOptionArgFile<List<String>>('footerText', [], resourceProvider,
        optionIs: OptionKind.file,
        help: 'Paths to files with content to add to page footers (next to the '
            'package name and version).',
        mustExist: true,
        splitCommas: true),
    DartdocOptionArgFile<List<String>>('header', [], resourceProvider,
        optionIs: OptionKind.file,
        help: 'Paths to files with content to add to page headers.',
        splitCommas: true),
    DartdocOptionArgOnly<bool>('prettyIndexJson', false, resourceProvider,
        help:
            'Generates `index.json` with indentation and newlines. The file is '
            'larger, but it\'s also easier to diff.',
        negatable: false),
    DartdocOptionArgFile<String?>('favicon', null, resourceProvider,
        optionIs: OptionKind.file,
        help: 'A path to a favicon for the generated docs.',
        mustExist: true),
    DartdocOptionArgOnly<String?>('relCanonicalPrefix', null, resourceProvider,
        help:
            'If provided, add a rel="canonical" prefixed with provided value. '
            'Consider using if building many versions of the docs for public '
            'SEO; learn more at https://goo.gl/gktN6F.'),
    DartdocOptionArgOnly<String?>('templatesDir', null, resourceProvider,
        optionIs: OptionKind.dir,
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
