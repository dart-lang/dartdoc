// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:dartdoc/src/generator/html_resources.g.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../web/icons.dart';

void main() {
  group('Material Symbols subset synchronization', () {
    test(
        'lib/templates/_head.html icon_names matches all template, SCSS, and '
        'web icons', () {
      final repoRoot = _resolvePackageRoot();

      final templateDir = Directory(p.join(repoRoot, 'lib', 'templates'));
      final templateFiles = templateDir
          .listSync()
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.html')
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(templateFiles, isNotEmpty);

      final templateIcons = <String>{};
      for (final file in templateFiles) {
        final relPath = p.relative(file.path, from: repoRoot);
        templateIcons.addAll(
          _extractTemplateIcons(file.readAsStringSync(), sourcePath: relPath),
        );
      }
      expect(templateIcons, isNotEmpty);

      final stylesDir = Directory(p.join(repoRoot, 'web', 'styles'));
      final scssFiles = stylesDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.scss')
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(scssFiles, isNotEmpty);

      final scssIcons = <String>{};
      for (final file in scssFiles) {
        final relPath = p.relative(file.path, from: repoRoot);
        scssIcons.addAll(
          _extractScssIcons(file.readAsStringSync(), sourcePath: relPath),
        );
      }
      expect(scssIcons, isNotEmpty);

      final bundledCss = utf8.decode(
        base64.decode(
          bundledResourcesBase64['styles.css']!.replaceAll('\n', ''),
        ),
      );
      for (final icon in scssIcons) {
        expect(
          bundledCss,
          matches(RegExp('''content\\s*:\\s*['"]$icon['"]''')),
          reason: 'Compiled styles.css is missing "$icon"; run '
              '"dart tool/task.dart build".',
        );
      }

      final webDir = Directory(p.join(repoRoot, 'web'));
      final iconsDartPath = p.normalize(p.join(repoRoot, 'web', 'icons.dart'));
      final webDartFiles = webDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => p.extension(f.path) == '.dart')
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      expect(webDartFiles, isNotEmpty);

      for (final file in webDartFiles) {
        if (p.normalize(file.path) == iconsDartPath) continue;
        final relPath = p.relative(file.path, from: repoRoot);
        final stripped = _stripCStyleComments(file.readAsStringSync());
        expect(
          stripped,
          isNot(contains(materialSymbolsClass)),
          reason: '$relPath references "$materialSymbolsClass" directly; '
              'use materialSymbolsClass and WebMaterialSymbol in '
              'web/icons.dart so icon_names stays in sync.',
        );
        expect(
          stripped.toLowerCase(),
          isNot(contains('material symbols outlined')),
          reason: '$relPath references "Material Symbols Outlined" directly; '
              'register web icons in WebMaterialSymbol (web/icons.dart).',
        );
      }

      final webIcons = <String>{};
      for (final symbol in WebMaterialSymbol.values) {
        _validateLigature(symbol.ligature, sourcePath: 'web/icons.dart');
        final added = webIcons.add(symbol.ligature);
        expect(
          added,
          isTrue,
          reason: 'Duplicate WebMaterialSymbol ligature "${symbol.ligature}".',
        );
      }
      expect(webIcons, isNotEmpty);

      final headHtml = File(
        p.join(repoRoot, 'lib', 'templates', '_head.html'),
      ).readAsStringSync();
      final headDoc = html_parser.parse(headHtml);
      final symbolsHref = headDoc
          .querySelectorAll('link[rel="stylesheet"]')
          .map((link) => link.attributes['href'] ?? '')
          .singleWhere((href) => href.contains('Material+Symbols+Outlined'));
      final symbolsUri = Uri.parse(symbolsHref);
      expect(symbolsUri.queryParameters['display'], 'block');

      final headIconNames =
          symbolsUri.queryParameters['icon_names']!.split(',');
      final expectedIcons = {
        ...templateIcons,
        ...scssIcons,
        ...webIcons,
      }.toList()
        ..sort();

      expect(
        headIconNames,
        orderedEquals(expectedIcons),
        reason: 'lib/templates/_head.html Material Symbols subset drifted. '
            'Expected alphabetically sorted '
            'icon_names=${expectedIcons.join(",")}',
      );
    });

    test(
        'template extractor handles Mustache control tags, ignores Mustache '
        'comments, and rejects dynamic ligatures', () {
      final icons = _extractTemplateIcons(
        '''
{{! <span class="material-symbols-outlined">commented_out</span> }}
{{ #hasSource }}
  <span class="{{#active}}material-symbols-outlined{{/active}}">
    open_in_new
  </span>
{{ /hasSource }}
''',
        sourcePath: 'synthetic.html',
      );
      expect(icons, {'open_in_new'});

      expect(
        () => _extractTemplateIcons(
          '<span class="material-symbols-outlined">{{dynamicIcon}}</span>',
          sourcePath: 'dynamic.html',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('dynamic.html'),
          ),
        ),
      );

      expect(
        () => _extractTemplateIcons(
          '<span class="material-symbols-outlined">   </span>',
          sourcePath: 'empty.html',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test(
        'SCSS extractor collects ligatures from Material Symbols partials and '
        'ignores unrelated or commented rules', () {
      expect(
        _extractScssIcons(
          '.copy-button::after { content: "Copy to clipboard"; }',
          sourcePath: '_code.scss',
        ),
        isEmpty,
      );

      final icons = _extractScssIcons(
        '''
// content: 'line_comment_icon';
/* content: 'block_comment_icon'; */
.alert-title {
  justify-content: center;
  &::before {
    font: 22px / 1 'Material Symbols Outlined';
    content: "";
  }
}
.alert-note .alert-title::before {
  content: 'info';
}
.alert-warning .alert-title::before {
  content: "warning" !important;
}
''',
        sourcePath: '_gfm.scss',
      );
      expect(icons, {'info', 'warning'});

      expect(
        () => _extractScssIcons(
          '''
.icon::before { font-family: 'Material Symbols Outlined'; }
.tooltip::after { content: "Copy to clipboard"; }
''',
          sourcePath: 'mixed.scss',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('mixed.scss'),
          ),
        ),
      );
    });
  });
}

final RegExp _mustacheControlTagPattern = RegExp(r'\{\{\s*[#!/^>][\s\S]*?\}\}');
final RegExp _validLigaturePattern = RegExp(r'^[a-z0-9_]+$');
final RegExp _cStyleCommentPattern = RegExp(
  r'''("(?:\\.|[^"\\])*")|('(?:\\.|[^'\\])*')|(//[^\n]*)|(/\*[\s\S]*?\*/)''',
);
final RegExp _cssContentPropertyPattern = RegExp(
  r'''(?<![-\w])content\s*:\s*(['"])([^'"]*)\1''',
);

String _resolvePackageRoot() {
  final libUri = Isolate.resolvePackageUriSync(
    Uri.parse('package:dartdoc/dartdoc.dart'),
  );
  if (libUri == null) {
    throw StateError('Unable to resolve package:dartdoc/dartdoc.dart');
  }
  return p.dirname(p.dirname(libUri.toFilePath()));
}

Set<String> _extractTemplateIcons(
  String templateHtml, {
  required String sourcePath,
}) {
  final sanitized = templateHtml.replaceAll(_mustacheControlTagPattern, ' ');
  final fragment = html_parser.parseFragment(sanitized);
  final icons = <String>{};
  for (final element in fragment.querySelectorAll('.$materialSymbolsClass')) {
    final ligature = element.text.trim();
    _validateLigature(ligature, sourcePath: sourcePath);
    icons.add(ligature);
  }
  return icons;
}

Set<String> _extractScssIcons(
  String scssSource, {
  required String sourcePath,
}) {
  final stripped = _stripCStyleComments(scssSource);
  if (!stripped.toLowerCase().contains('material symbols outlined')) {
    return const {};
  }
  final icons = <String>{};
  for (final match in _cssContentPropertyPattern.allMatches(stripped)) {
    final value = match.group(2)!;
    if (value.isEmpty) continue;
    _validateLigature(value, sourcePath: sourcePath);
    icons.add(value);
  }
  return icons;
}

String _stripCStyleComments(String source) =>
    source.replaceAllMapped(_cStyleCommentPattern, (match) {
      // Preserve quoted string literals (groups 1 and 2) so `//` or `/*` inside
      // URLs or CSS strings are not treated as comments.
      if (match.group(1) != null || match.group(2) != null) {
        return match.group(0)!;
      }
      return '';
    });

void _validateLigature(String ligature, {required String sourcePath}) {
  if (!_validLigaturePattern.hasMatch(ligature)) {
    throw StateError(
      'Invalid or dynamic Material Symbols ligature "$ligature" in '
      '$sourcePath. Expected a static snake_case identifier matching '
      '${_validLigaturePattern.pattern}.',
    );
  }
}
