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

d.DirectoryDescriptor package(
  String name, {
  String pubspec = _defaultPubspec,
  String? dartdocOptions,
  String? analysisOptions,
  List<d.FileDescriptor> libFiles = const [],
}) {
  return d.dir(name, [
    d.file('pubspec.yaml', pubspec),
    if (dartdocOptions != null) d.file('dartdoc_options.yaml', dartdocOptions),
    if (analysisOptions != null)
      d.file('analysis_options.yaml', analysisOptions),
    d.dir('lib', [...libFiles]),
  ]);
}
