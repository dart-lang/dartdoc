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
      // Set current to a directory far away from the package root to ensure
      // resolution does not accidentally depend on it.
      pathContext = p.Context(
          style: p.Style.posix, current: '/completely/different/path');
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

    test('path with complex URI encoded characters', () {
      expect(
        resolve('/examples/100%25effective.dart'),
        '/project/examples/100%effective.dart',
      );
      expect(
        resolve('/examples/a%5cb.dart'),
        '/project/examples/a\\b.dart',
      );
      expect(
        resolve('/examples/a%20b.dart'),
        '/project/examples/a b.dart',
      );
    });

    test('path with fragment and query (ignored)', () {
      expect(
        resolve('/examples/hello.dart?q=1#region'),
        '/project/examples/hello.dart',
      );
      expect(
        resolve('/examples/hello.dart?#'),
        '/project/examples/hello.dart',
      );
    });

    test('special characters in package and source paths', () {
      var specialContext = p.Context(style: p.Style.posix, current: '/other');
      var specialPackagePath = '/project %25 space';
      var specialSourcePath = '/project %25 space/lib/a.dart';

      expect(
        DocumentationComment.resolveExamplePath(
          'hello.dart',
          packagePath: specialPackagePath,
          sourceFilePath: specialSourcePath,
          pathContext: specialContext,
          warn: (kind, {message}) {},
        ),
        '/project %25 space/lib/hello.dart',
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

    test('absolute URI (rejected)', () {
      expect(
        resolve('https://example.com/hello.dart'),
        isNull,
      );
    });

    test('path with backslashes', () {
      // Uri.resolve converts backslashes to forward slashes.
      var result = resolve('examples\\hello.dart',
          sourceFileName: '/project/lib/a.dart');
      expect(result, '/project/lib/examples/hello.dart');
    });

    test('Windows-style absolute paths and resolution', () {
      var windowsContext =
          p.Context(style: p.Style.windows, current: r'C:\project');
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

    group('unusual path inputs (no crash)', () {
      var inputs = [
        '\x00',
        ' ',
        '%%',
        '',
        '..',
        '//',
        r'\..\..\',
        'C:\\Windows\\System32',
        'http://[::1]/',
        'a' * 10000,
      ];

      for (var input in inputs) {
        test(': $input', () {
          DocumentationComment.resolveExamplePath(
            input,
            packagePath: packagePath,
            sourceFilePath: '/project/lib/a.dart',
            pathContext: pathContext,
            warn: (kind, {message}) {},
          );
        });
      }
    });

    group('invalid URI inputs (trigger warnings)', () {
      var inputs = [
        ': [', // Invalid URI
        'http://[::1]]', // Invalid IPv6
        '/%ff%fe%fd', // Invalid UTF-8 encoding
      ];

      for (var input in inputs) {
        test(': $input', () {
          var warned = false;
          DocumentationComment.resolveExamplePath(
            input,
            packagePath: packagePath,
            sourceFilePath: '/project/lib/a.dart',
            pathContext: pathContext,
            warn: (kind, {message}) => warned = true,
          );
          expect(warned, isTrue,
              reason: 'Expected a warning for input "$input"');
        });
      }
    });

    group('rejects paths with schemes or authorities (trigger warnings)', () {
      var inputs = [
        'file:///something',
        'file:///etc/passwd',
        'http://example.com/script.dart',
        'https://pub.dev/packages',
      ];

      for (var input in inputs) {
        test('rejects: $input', () {
          var warned = false;
          DocumentationComment.resolveExamplePath(
            input,
            packagePath: packagePath,
            sourceFilePath: '/project/lib/a.dart',
            pathContext: pathContext,
            warn: (kind, {message}) {
              warned = true;
              expect(message,
                  contains('Schemes and authorities are not allowed.'));
            },
          );
          expect(warned, isTrue,
              reason: 'Expected a warning for input "$input"');
        });
      }
    });
  });
}
