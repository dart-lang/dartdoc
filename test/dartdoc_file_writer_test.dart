// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer_testing/utilities/extensions/resource_provider.dart';
import 'package:dartdoc/src/dartdoc.dart' show DartdocFileWriter;
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:test/test.dart';

Matcher refusesToWrite(String fragment) =>
    throwsA(const TypeMatcher<DartdocFailure>()
        .having((e) => e.message, 'message', contains(fragment)));

void main() {
  group('DartdocFileWriter', () {
    late MemoryResourceProvider resourceProvider;
    late String outputDir;
    late DartdocFileWriter writer;

    String p(String posixPath) =>
        ResourceProviderExtension(resourceProvider).convertPath(posixPath);

    bool exists(String posixPath) =>
        resourceProvider.getFile(p(posixPath)).exists;

    setUp(() {
      resourceProvider = MemoryResourceProvider();
      outputDir = p('/pkg/doc/api');
      resourceProvider.newFolder(outputDir);
      writer = DartdocFileWriter(outputDir, resourceProvider);
    });

    test('writes files inside the output directory', () {
      writer.write('index.html', 'index');
      writer.write('topics/Real Libraries-topic.html', 'topic');
      writer.writeBytes('static-assets/x.png', [1, 2, 3]);

      expect(exists('/pkg/doc/api/index.html'), isTrue);
      expect(exists('/pkg/doc/api/topics/Real Libraries-topic.html'), isTrue);
      expect(exists('/pkg/doc/api/static-assets/x.png'), isTrue);
      expect(writer.writtenFiles, hasLength(3));
    });

    test('refuses a path which climbs out of the output directory', () {
      expect(() => writer.write('topics/../../../evil-topic.html', 'evil'),
          refusesToWrite('outside of the output directory'));
      expect(exists('/pkg/evil-topic.html'), isFalse);
      expect(resourceProvider.getFolder(p('/pkg/topics')).exists, isFalse);
    });

    test('never writes an absolute path outside the output directory', () {
      // `write` splits its argument on `/`, which on POSIX turns an absolute
      // path into a relative one; on Windows it stays absolute.
      if (io.Platform.isWindows) {
        expect(() => writer.write(p('/tmp/evil-topic.html'), 'evil'),
            refusesToWrite('outside of the output directory'));
      } else {
        writer.write('/tmp/evil-topic.html', 'evil');
        expect(exists('/pkg/doc/api/tmp/evil-topic.html'), isTrue);
      }
      expect(exists('/tmp/evil-topic.html'), isFalse);
    });

    test('refuses to write through a symbolic link', () {
      resourceProvider.newFile(p('/outside/target.html'), 'target');
      resourceProvider.newLink(
          p('/pkg/doc/api/index.html'), p('/outside/target.html'));

      expect(() => writer.write('index.html', 'evil'),
          refusesToWrite('through a symbolic link'));
    });

    test('refuses a directory which links outside the output directory', () {
      resourceProvider.newFolder(p('/elsewhere'));
      resourceProvider.newLink(p('/pkg/doc/api/topics'), p('/elsewhere'));

      expect(() => writer.write('topics/evil-topic.html', 'evil'),
          refusesToWrite('links to'));
    });

    test('keeps refusing a directory after a first refusal', () {
      resourceProvider.newFolder(p('/elsewhere'));
      resourceProvider.newLink(p('/pkg/doc/api/topics'), p('/elsewhere'));

      expect(() => writer.write('topics/a-topic.html', 'a'),
          refusesToWrite('links to'));
      expect(() => writer.write('topics/b-topic.html', 'b'),
          refusesToWrite('links to'));
    });

    test('allows a directory which links inside the output directory', () {
      resourceProvider.newFolder(p('/pkg/doc/api/real'));
      resourceProvider.newLink(p('/pkg/doc/api/alias'), p('/pkg/doc/api/real'));

      expect(() => writer.write('alias/a.html', 'a'), returnsNormally);
    });
  });

  // The memory file system does not follow links when writing, so the effect
  // of the symbolic link checks is verified on the physical file system.
  group('DartdocFileWriter on the physical file system', () {
    late Folder tempDir;
    late Folder outputDir;
    late Folder elsewhere;
    late DartdocFileWriter writer;

    setUp(() {
      tempDir = PhysicalResourceProvider.INSTANCE
          .createSystemTemp('dartdoc_file_writer_test');
      outputDir = tempDir.getFolder('out')..create();
      elsewhere = tempDir.getFolder('elsewhere')..create();
      writer =
          DartdocFileWriter(outputDir.path, PhysicalResourceProvider.INSTANCE);
    });

    tearDown(() {
      tempDir.delete();
    });

    test('creates no file outside the output directory', () {
      io.Link(outputDir.getFolder('topics').path).createSync(elsewhere.path);

      expect(() => writer.write('topics/evil-topic.html', 'evil'),
          refusesToWrite('links to'));
      expect(elsewhere.getFile('evil-topic.html').exists, isFalse);
    }, onPlatform: {'windows': Skip('Creating links requires privileges')});

    test('overwrites no file outside the output directory', () {
      var target = elsewhere.getFile('target.html')
        ..writeAsStringSync('target');
      io.Link(outputDir.getFile('index.html').path).createSync(target.path);

      expect(() => writer.write('index.html', 'evil'),
          refusesToWrite('through a symbolic link'));
      expect(target.readAsStringSync(), 'target');
    }, onPlatform: {'windows': Skip('Creating links requires privileges')});

    test('writes through a directory which links inside the output directory',
        () {
      var real = outputDir.getFolder('real')..create();
      io.Link(outputDir.getFolder('alias').path).createSync(real.path);

      writer.write('alias/a.html', 'a');
      expect(real.getFile('a.html').readAsStringSync(), 'a');
    }, onPlatform: {'windows': Skip('Creating links requires privileges')});
  });
}
