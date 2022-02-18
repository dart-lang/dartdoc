// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'package:args/args.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;

const _defaultPubspec = '''
name: test_package
version: 0.0.1
environment:
  sdk: '>=2.12.0 <3.0.0'
''';

/// This script generates a test package with a specified number of libraries,
/// classes, methods, and doc comment references, in order to test dartdoc's
/// performance and scalability characteristics.
///
/// Within the generated package, `dartdoc --show-stats` can be helpful in
/// understanding these characteristics.
void main(List<String> args) async {
  var argParser = ArgParser()
    ..addOption(
      'library-count',
      defaultsTo: '1',
      help: 'the number of libraries',
    )
    ..addOption(
      'class-count',
      defaultsTo: '1',
      help: 'the number of classes per library',
    )
    ..addOption(
      'method-count',
      defaultsTo: '1',
      help: 'the number of methods per class',
    )
    ..addOption(
      'reference-count',
      defaultsTo: '1',
      help: 'the number of references per class doc comment',
    );
  var argResults = argParser.parse(args);
  // TODO(srawlins): Support generating multiple packages.
  var libraryCount = int.parse(argResults['library-count']);
  var classCount = int.parse(argResults['class-count']);
  var methodCount = int.parse(argResults['method-count']);
  var referenceCount = int.parse(argResults['reference-count']);
  var testDataDir = Directory('test_data')..createSync();
  var libFiles = <d.Descriptor>[];
  var classCounter = 1;
  var methodCounter = 1;
  // TODO(srawlins): Swap these out for elements being generated.
  var sdkElements = [
    'int',
    'double',
    'bool',
    'List',
    'String',
    'Set',
    'Iterable',
    'Map',
    'Future',
    'num',
  ];
  for (var i = 1; i <= libraryCount; i++) {
    var libraryContent = StringBuffer();
    for (var j = 1; j <= classCount; j++) {
      libraryContent.writeln('/// Doc comment.');
      var sdkReferences =
          sdkElements.take(referenceCount).map((e) => '[$e]').join(' ');
      libraryContent.writeln('/// $sdkReferences');
      if (classCounter > 1) {
        libraryContent.writeln('/// Another class: [C${classCounter - 1}]');
      }
      libraryContent.writeln('class C$classCounter {');
      for (var k = 1; k < methodCount; k++) {
        libraryContent.writeln('  void m$methodCounter() {}');
        methodCounter++;
      }
      libraryContent.writeln('}');
      classCounter++;
    }
    libFiles.add(d.file('lib$i.dart', libraryContent.toString()));
  }
  var testPackageDir = d.dir('test_package', [
    d.file('pubspec.yaml', _defaultPubspec),
    d.dir('lib', libFiles),
  ]);
  await testPackageDir.create(testDataDir.path);
}
