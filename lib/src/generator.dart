// Copyright (c) 2015, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A library containing an abstract documentation generator.
library dartdoc.generator;

import 'dart:async' show Stream, Future;
import 'dart:io' show Directory;
import 'dart:isolate';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart' show PackageGraph;
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:path/path.dart' as path;

/// An abstract class that defines a generator that generates documentation for
/// a given package.
///
/// Generators can generate documentation in different formats: html, json etc.
abstract class Generator {
  /// Generate the documentation for the given package in the specified
  /// directory. Completes the returned future when done.
  Future generate(PackageGraph packageGraph, String outputDirectoryPath);

  /// Fires when a file is created.
  Stream<void> get onFileCreated;

  final Map<String, Warnable> writtenFiles = {};
}

/// Dartdoc options related to generators generally.
mixin GeneratorContext on DartdocOptionContextBase {
  List<String> get footer => optionSet['footer'].valueAt(context);

  /// _footerText is only used to construct synthetic options.
  // ignore: unused_element
  List<String> get _footerText => optionSet['footerText'].valueAt(context);

  List<String> get footerTextPaths =>
      optionSet['footerTextPaths'].valueAt(context);

  List<String> get header => optionSet['header'].valueAt(context);

  bool get prettyIndexJson => optionSet['prettyIndexJson'].valueAt(context);

  String get favicon => optionSet['favicon'].valueAt(context);

  String get relCanonicalPrefix =>
      optionSet['relCanonicalPrefix'].valueAt(context);

  String get templatesDir => optionSet['templatesDir'].valueAt(context);

  // TODO(jdkoren): duplicated temporarily so that GeneratorContext is enough for configuration.
  bool get useBaseHref => optionSet['useBaseHref'].valueAt(context);
}

Uri _sdkFooterCopyrightUri;

Future<void> _setSdkFooterCopyrightUri() async {
  if (_sdkFooterCopyrightUri == null) {
    // TODO(jdkoren): find a way to make this not specific to HTML, or have
    // alternatives for other supported formats.
    _sdkFooterCopyrightUri = await Isolate.resolvePackageUri(
        Uri.parse('package:dartdoc/resources/sdk_footer_text.html'));
  }
}

Future<List<DartdocOption>> createGeneratorOptions() async {
  await _setSdkFooterCopyrightUri();
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
    DartdocOptionSyntheticOnly<List<String>>(
      'footerTextPaths',
      (DartdocSyntheticOption<List<String>> option, Directory dir) {
        final List<String> footerTextPaths = <String>[];
        final PackageMeta topLevelPackageMeta =
            option.root['topLevelPackageMeta'].valueAt(dir);
        // TODO(jcollins-g): Eliminate special casing for SDK and use config file.
        if (topLevelPackageMeta.isSdk == true) {
          footerTextPaths
              .add(path.canonicalize(_sdkFooterCopyrightUri.toFilePath()));
        }
        footerTextPaths.addAll(option.parent['footerText'].valueAt(dir));
        return footerTextPaths;
      },
      isFile: true,
      help: 'paths to footer-text-files (adding special case for SDK)',
      mustExist: true,
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
    DartdocOptionArgOnly<String>("templatesDir", null,
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
            'partial template _foo.html).'),
  ];
}
