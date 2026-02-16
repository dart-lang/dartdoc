// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/documentation_comment.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  group('DocumentationComment.resolveExamplePath', () {
    late p.Context pathContext;
    late String packagePath;

    setUp(() {
      pathContext = p.Context(style: p.Style.posix, current: '/project');
      packagePath = '/project';
    });

    String? resolve(String filepath, {String? sourceFileName}) {
      return DocumentationComment.resolveExamplePath(
        filepath,
        packagePath: packagePath,
        sourceFilePath: sourceFileName,
        pathContext: pathContext,
        warn: (kind, {message}) {},
      );
    }

    test('absolute path from root', () {
      expect(resolve('/examples/hello.dart'), '/project/examples/hello.dart');
    });

    test('relative path from root library', () {
      expect(
        resolve('examples/hello.dart', sourceFileName: '/project/lib/a.dart'),
        '/project/lib/examples/hello.dart',
      );
    });

    test('relative path with ..', () {
      expect(
        resolve('../examples/hello.dart',
            sourceFileName: '/project/lib/a.dart'),
        '/project/examples/hello.dart',
      );
    });

    test('relative path from nested library', () {
      expect(
        resolve('util.dart', sourceFileName: '/project/lib/src/a.dart'),
        '/project/lib/src/util.dart',
      );
    });

    test('relative path with null sourceFileName (resolved from root)', () {
      expect(
        resolve('examples/hello.dart', sourceFileName: null),
        '/project/examples/hello.dart',
      );
    });

    test('path with URI encoded characters', () {
      expect(
        resolve('/examples/hello%20world.dart'),
        '/project/examples/hello world.dart',
      );
    });

    test('path with fragment and query (ignored)', () {
      expect(
        resolve('/examples/hello.dart?q=1#region'),
        '/project/examples/hello.dart',
      );
    });

    test('clamping: relative traversal cannot escape root', () {
      expect(
        resolve('../../../examples/hello.dart',
            sourceFileName: '/project/lib/a.dart'),
        '/project/examples/hello.dart',
      );
    });

    test('clamping: absolute traversal cannot escape root', () {
      expect(
        resolve('/../outside.dart'),
        '/project/outside.dart',
      );
    });

    test('absolute URI (resolves its path relative to root)', () {
      expect(
        resolve('https://example.com/hello.dart'),
        '/project/hello.dart',
      );
    });

    test('path with backslashes', () {
      // Uri.resolve converts backslashes to forward slashes.
      var result = resolve('examples\\hello.dart',
          sourceFileName: '/project/lib/a.dart');
      expect(result, '/project/lib/examples/hello.dart');
    });

    test('Windows-style absolute paths and resolution', () {
      var windowsContext = p.Context(style: p.Style.windows, current: r'C:\project');
      var windowsPackagePath = r'C:\project';

      String? resolveWindows(String filepath, {String? sourceFileName}) {
        return DocumentationComment.resolveExamplePath(
          filepath,
          packagePath: windowsPackagePath,
          sourceFilePath: sourceFileName,
          pathContext: windowsContext,
          warn: (kind, {message}) {},
        );
      }

      expect(
        resolveWindows('hello.dart', sourceFileName: r'C:\project\lib\a.dart'),
        r'C:\project\lib\hello.dart',
      );
      expect(
        resolveWindows('../examples/hello.dart',
            sourceFileName: r'C:\project\lib\a.dart'),
        r'C:\project\examples\hello.dart',
      );
      expect(
        resolveWindows('../../../outside.dart',
            sourceFileName: r'C:\project\lib\a.dart'),
        r'C:\project\outside.dart',
      );
    });

    test('unusual path inputs (no crash)', () {
      var inputs = [
        '\x00',
        ' ',
        '%%',
        '',
        '..',
        '//',
        '\\..\\..\\',
        'C:\\Windows\\System32',
        'http://[::1]/',
        'a' * 10000,
      ];

      for (var input in inputs) {
        try {
          DocumentationComment.resolveExamplePath(
            input,
            packagePath: packagePath,
            sourceFilePath: '/project/lib/a.dart',
            pathContext: pathContext,
            warn: (kind, {message}) {},
          );
        } catch (e) {
          fail('resolveExamplePath crashed on input "$input": $e');
        }
      }
    });

    test('invalid URI inputs (trigger warnings)', () {
      var inputs = [
        ': [', // Invalid URI
        'http://[::1]]', // Invalid IPv6
        '/%ff%fe%fd', // Invalid UTF-8 encoding
      ];

      for (var input in inputs) {
        var warned = false;
        DocumentationComment.resolveExamplePath(
          input,
          packagePath: packagePath,
          sourceFilePath: '/project/lib/a.dart',
          pathContext: pathContext,
          warn: (kind, {message}) => warned = true,
        );
        expect(warned, isTrue, reason: 'Expected a warning for input "$input"');
      }
    });
  });
}
