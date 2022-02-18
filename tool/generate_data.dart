// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';
import 'dart:math';
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
  final argParser = ArgParser()
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
      'parameter-count',
      defaultsTo: '1',
      help: 'the number of parameters per method',
    )
    ..addOption(
      'reference-count',
      defaultsTo: '1',
      help: 'the number of references per class doc comment',
    );
  final argResults = argParser.parse(args);
  // TODO(srawlins): Support generating multiple packages.
  final libraryCount = int.parse(argResults['library-count']);
  final classCount = int.parse(argResults['class-count']);
  final methodCount = int.parse(argResults['method-count']);
  final parameterCount = int.parse(argResults['parameter-count']);
  final referenceCount = int.parse(argResults['reference-count']);
  final testDataDir = Directory('test_data')..createSync();
  final libFiles = <d.Descriptor>[];
  var classCounter = 1;
  var methodCounter = 1;
  final rng = Random();
  for (var lIndex = 1; lIndex <= libraryCount; lIndex++) {
    final content = StringBuffer();
    for (var cIndex = 1; cIndex <= classCount; cIndex++) {
      content.writeln('/// Doc comment.');
      final references =
          List.generate(referenceCount, (_) => '[C${rng.nextInt(classCount)}]')
              .join(' ');
      content.writeln('/// References: $references');
      content.writeln('class C$classCounter {');
      for (var mIndex = 1; mIndex <= methodCount; mIndex++) {
        content.write('  void m$methodCounter(');
        content.write(
            List.generate(parameterCount, (var pIndex) => 'int p$pIndex')
                .join(', '));
        content.writeln(') {}');
        methodCounter++;
      }
      content.writeln('}');
      classCounter++;
    }
    libFiles.add(d.file('lib$lIndex.dart', content.toString()));
  }
  final testPackageDir = d.dir('test_package', [
    d.file('pubspec.yaml', _defaultPubspec),
    d.dir('lib', libFiles),
  ]);
  await testPackageDir.create(testDataDir.path);
}
