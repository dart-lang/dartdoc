// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/vitepress_guide_generator.dart';
import 'package:test/test.dart';

void main() {
  group('VitePressGuideGenerator.extractTitle', () {
    test('extracts H1 heading from markdown', () {
      var content = '# Getting Started\n\nSome content here.';
      expect(
        VitePressGuideGenerator.extractTitle(content, 'getting-started.md'),
        equals('Getting Started'),
      );
    });

    test('extracts H1 heading with leading whitespace', () {
      var content = '  # Installation Guide  \n\nContent.';
      expect(
        VitePressGuideGenerator.extractTitle(content, 'install.md'),
        equals('Installation Guide'),
      );
    });

    test('ignores H2 and finds first H1', () {
      var content = '## Section\n\n### Subsection\n\n# Real Title';
      expect(
        VitePressGuideGenerator.extractTitle(content, 'doc.md'),
        equals('Real Title'),
      );
    });

    test('falls back to filename for empty content', () {
      expect(
        VitePressGuideGenerator.extractTitle('', 'getting-started.md'),
        equals('Getting Started'),
      );
    });

    test('falls back to filename when no H1 found', () {
      var content = 'No headings in this file.\nJust plain text.';
      expect(
        VitePressGuideGenerator.extractTitle(content, 'my_guide.md'),
        equals('My Guide'),
      );
    });

    test('converts snake_case filename to Title Case', () {
      expect(
        VitePressGuideGenerator.extractTitle('', 'quick_start_guide.md'),
        equals('Quick Start Guide'),
      );
    });

    test('converts kebab-case filename to Title Case', () {
      expect(
        VitePressGuideGenerator.extractTitle('', 'api-reference.md'),
        equals('Api Reference'),
      );
    });

    test('handles nested path for fallback', () {
      expect(
        VitePressGuideGenerator.extractTitle('', 'sub/nested/overview.md'),
        equals('Overview'),
      );
    });

    test('handles content with only H2 heading', () {
      var content = '## Not an H1\n\nSome text.';
      expect(
        VitePressGuideGenerator.extractTitle(content, 'fallback.md'),
        equals('Fallback'),
      );
    });
  });

  group('VitePressGuideGenerator.matchesFilters', () {
    VitePressGuideGenerator makeGenerator({
      List<String> include = const [],
      List<String> exclude = const [],
    }) {
      return VitePressGuideGenerator(
        resourceProvider: _FakeResourceProvider(),
        scanDirs: ['doc', 'docs'],
        include: include,
        exclude: exclude,
      );
    }

    test('empty patterns pass everything', () {
      var gen = makeGenerator();
      expect(gen.matchesFilters('README.md'), isTrue);
      expect(gen.matchesFilters('sub/file.md'), isTrue);
      expect(gen.matchesFilters('CHANGELOG.md'), isTrue);
    });

    test('include-only filters correctly', () {
      var gen = makeGenerator(include: [r'.*\.md$']);
      expect(gen.matchesFilters('guide.md'), isTrue);
      expect(gen.matchesFilters('guide.txt'), isFalse);
    });

    test('exclude-only filters correctly', () {
      var gen = makeGenerator(exclude: [r'CHANGELOG\.md']);
      expect(gen.matchesFilters('README.md'), isTrue);
      expect(gen.matchesFilters('CHANGELOG.md'), isFalse);
    });

    test('include + exclude combined', () {
      var gen = makeGenerator(
        include: [r'.*\.md$'],
        exclude: [r'internal/.*'],
      );
      expect(gen.matchesFilters('guide.md'), isTrue);
      expect(gen.matchesFilters('internal/secret.md'), isFalse);
      expect(gen.matchesFilters('guide.txt'), isFalse);
    });

    test('exclude takes precedence over include', () {
      var gen = makeGenerator(
        include: [r'.*\.md$'],
        exclude: [r'draft.*'],
      );
      expect(gen.matchesFilters('draft-guide.md'), isFalse);
    });

    test('multiple include patterns (OR logic)', () {
      var gen = makeGenerator(include: [r'guide/.*', r'tutorial/.*']);
      expect(gen.matchesFilters('guide/start.md'), isTrue);
      expect(gen.matchesFilters('tutorial/intro.md'), isTrue);
      expect(gen.matchesFilters('other/file.md'), isFalse);
    });

    test('multiple exclude patterns (OR logic)', () {
      var gen = makeGenerator(exclude: [r'CHANGELOG\.md', r'LICENSE\.md']);
      expect(gen.matchesFilters('README.md'), isTrue);
      expect(gen.matchesFilters('CHANGELOG.md'), isFalse);
      expect(gen.matchesFilters('LICENSE.md'), isFalse);
    });

    test('throws FormatException for invalid regex', () {
      expect(
        () => makeGenerator(include: [r'[invalid(regex']),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid exclude regex', () {
      expect(
        () => makeGenerator(exclude: [r'*broken']),
        throwsFormatException,
      );
    });
  });

  group('VitePressGuideGenerator.generateSidebar', () {
    VitePressGuideGenerator makeGenerator() {
      return VitePressGuideGenerator(
        resourceProvider: _FakeResourceProvider(),
        scanDirs: ['doc', 'docs'],
      );
    }

    test('empty entries produce empty sidebar', () {
      var gen = makeGenerator();
      var result = gen.generateSidebar([], isMultiPackage: false);
      expect(result, contains('guideSidebar'));
      expect(result, contains('{}'));
    });

    test('single-package produces flat list', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'my_pkg',
          relativePath: 'guide/getting-started.md',
          title: 'Getting Started',
          content: '',
        ),
        GuideEntry(
          packageName: 'my_pkg',
          relativePath: 'guide/installation.md',
          title: 'Installation',
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: false);
      expect(result, contains("text: 'Getting Started'"));
      expect(result, contains("link: '/guide/getting-started'"));
      expect(result, contains("text: 'Installation'"));
      expect(result, contains("link: '/guide/installation'"));
      expect(result, isNot(contains('collapsed')));
    });

    test('multi-package groups by package name', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'core',
          relativePath: 'guide/core/overview.md',
          title: 'Overview',
          content: '',
        ),
        GuideEntry(
          packageName: 'flutter',
          relativePath: 'guide/flutter/widgets.md',
          title: 'Widgets',
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: true);
      expect(result, contains("text: 'core'"));
      expect(result, contains("text: 'flutter'"));
      expect(result, contains('collapsed: false'));
      expect(result, contains("text: 'Overview'"));
      expect(result, contains("text: 'Widgets'"));
    });

    test('escapes single quotes in titles', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'pkg',
          relativePath: 'guide/its-fine.md',
          title: "It's a guide",
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: false);
      expect(result, contains(r"text: 'It\'s a guide'"));
    });

    test('escapes backslashes and newlines in titles', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'pkg',
          relativePath: 'guide/test.md',
          title: 'Path: C\\Users\nNew',
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: false);
      expect(result, contains(r"text: 'Path: C\\Users\nNew'"));
    });

    test('generates valid TypeScript import', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'pkg',
          relativePath: 'guide/intro.md',
          title: 'Intro',
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: false);
      expect(result, contains("import type { DefaultTheme } from 'vitepress'"));
      expect(result, contains('export const guideSidebar'));
    });

    test('multi-package sorts package groups alphabetically', () {
      var gen = makeGenerator();
      var entries = [
        GuideEntry(
          packageName: 'zebra',
          relativePath: 'guide/zebra/intro.md',
          title: 'Zebra Intro',
          content: '',
        ),
        GuideEntry(
          packageName: 'alpha',
          relativePath: 'guide/alpha/intro.md',
          title: 'Alpha Intro',
          content: '',
        ),
      ];

      var result = gen.generateSidebar(entries, isMultiPackage: true);
      var alphaIdx = result.indexOf("text: 'alpha'");
      var zebraIdx = result.indexOf("text: 'zebra'");
      expect(alphaIdx, lessThan(zebraIdx));
    });
  });
}

/// Minimal fake ResourceProvider for testing.
///
/// Only used to satisfy the constructor — no file system operations
/// are invoked in the methods under test (extractTitle, matchesFilters,
/// generateSidebar).
class _FakeResourceProvider implements ResourceProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}
