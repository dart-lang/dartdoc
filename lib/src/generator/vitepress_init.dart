// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:path/path.dart' as p;

/// Generates initial VitePress project scaffold files.
///
/// Creates the following files (only if they don't already exist):
/// - `package.json` with VitePress dependency
/// - `.vitepress/config.ts` importing generated sidebar data
/// - `index.md` with a VitePress hero section
class VitePressInitGenerator {
  final FileWriter writer;
  final ResourceProvider resourceProvider;
  final String outputPath;

  VitePressInitGenerator({
    required this.writer,
    required this.resourceProvider,
    required this.outputPath,
  });

  /// Generates scaffold files. Only creates files that don't exist.
  void generate({required String packageName}) {
    _writeIfAbsent(
      'package.json',
      _packageJson(packageName),
    );
    _writeIfAbsent(
      p.join('.vitepress', 'config.ts'),
      _configTs(packageName),
    );
    _writeIfAbsent(
      'index.md',
      _indexMd(packageName),
    );
  }

  void _writeIfAbsent(String relativePath, String content) {
    var fullPath = p.join(outputPath, relativePath);
    var file = resourceProvider.getFile(fullPath);
    if (file.exists) return;
    writer.write(relativePath, content);
  }

  static String _packageJson(String packageName) => '''{
  "name": "${packageName.replaceAll(RegExp(r'[^a-z0-9_-]'), '-')}-docs",
  "private": true,
  "scripts": {
    "dev": "vitepress dev",
    "build": "vitepress build",
    "preview": "vitepress preview"
  },
  "devDependencies": {
    "vitepress": "^1.6.4"
  }
}
''';

  static String _configTs(String packageName) =>
      """import { defineConfig } from 'vitepress'
import { apiSidebar } from './generated/api-sidebar'

export default defineConfig({
  title: '$packageName API',
  description: 'API documentation for $packageName',
  themeConfig: {
    sidebar: {
      '/api/': apiSidebar,
    },
    socialLinks: [
      // { icon: 'github', link: 'https://github.com/your-org/$packageName' },
    ],
  },
})
""";

  static String _indexMd(String packageName) => '''---
layout: home
hero:
  name: $packageName
  text: API Documentation
  tagline: Generated with dartdoc-vitepress
  actions:
    - theme: brand
      text: API Reference
      link: /api/
---
''';
}
