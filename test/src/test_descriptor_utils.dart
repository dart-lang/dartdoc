// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:test_descriptor/test_descriptor.dart' as d;
export 'package:test_descriptor/test_descriptor.dart';

const _defaultPubspec = '''
name: test_package
version: 0.0.1
environment:
  sdk: '>=2.12.0 <3.0.0'
''';

/// Creates a pub package in a directory named [name].
Future<d.DirectoryDescriptor> createPackage(
  String name, {
  String pubspec = _defaultPubspec,
  String? dartdocOptions,
  String? analysisOptions,
  List<d.Descriptor> libFiles = const [],
  List<d.Descriptor> files = const [],
}) async {
  final packageDir = d.dir(name, [
    d.file('pubspec.yaml', pubspec),
    if (dartdocOptions != null) d.file('dartdoc_options.yaml', dartdocOptions),
    if (analysisOptions != null)
      d.file('analysis_options.yaml', analysisOptions),
    d.dir('lib', [...libFiles]),
    ...files,
    // Write out '.dart_tool/package_config.json' to avoid needing `pub get`.
    // TODO(srawlins): intelligently write out this file, even in the presense
    // of dependencies.
    if (!pubspec.contains('dependencies:'))
      d.dir(
        '.dart_tool',
        [
          d.file('package_config.json', '''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "test_package",
      "rootUri": "../",
      "packageUri": "lib/",
      "languageVersion": "2.0"
    }
  ],
  "generated": "2021-09-14T20:36:04.604099Z",
  "generator": "pub",
  "generatorVersion": "2.14.1"
}
''')
        ],
      ),
  ]);
  await packageDir.create();
  return packageDir;
}
