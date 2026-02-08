// Copyright (c) 2024, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/vitepress_init.dart';
import 'package:test/test.dart';

void main() {
  group('VitePressInitGenerator.buildSocialLinks', () {
    test('returns empty array for empty URL', () {
      expect(VitePressInitGenerator.buildSocialLinks(''), equals('[]'));
    });

    test('returns github icon for GitHub URL', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/user/repo',
      );
      expect(result, contains("icon: 'github'"));
      expect(result, contains("link: 'https://github.com/user/repo'"));
    });

    test('returns gitlab icon for GitLab URL', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://gitlab.com/user/repo',
      );
      expect(result, contains("icon: 'gitlab'"));
      expect(result, contains("link: 'https://gitlab.com/user/repo'"));
    });

    test('defaults to github icon for unknown hosts', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://bitbucket.org/user/repo',
      );
      expect(result, contains("icon: 'github'"));
      expect(result, contains("link: 'https://bitbucket.org/user/repo'"));
    });

    test('strips /tree/main suffix from GitHub URL', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/user/repo/tree/main/packages/core',
      );
      expect(result, contains("link: 'https://github.com/user/repo'"));
      expect(result, isNot(contains('/tree/main')));
    });

    test('strips /tree/master suffix from GitHub URL', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/user/repo/tree/master/src',
      );
      expect(result, contains("link: 'https://github.com/user/repo'"));
      expect(result, isNot(contains('/tree/master')));
    });

    test('strips /tree/develop/deep/path suffix', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/org/mono/tree/develop/packages/a/lib',
      );
      expect(result, contains("link: 'https://github.com/org/mono'"));
    });

    test('preserves URL without /tree/ suffix', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/user/repo',
      );
      expect(result, contains("link: 'https://github.com/user/repo'"));
    });

    test('returns valid TypeScript array syntax', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://github.com/user/repo',
      );
      expect(result, startsWith('['));
      expect(result, endsWith(']'));
      expect(result, contains('icon:'));
      expect(result, contains('link:'));
    });

    test('empty URL returns valid TypeScript empty array', () {
      var result = VitePressInitGenerator.buildSocialLinks('');
      expect(result, equals('[]'));
    });

    test('handles GitLab with /tree/ suffix', () {
      var result = VitePressInitGenerator.buildSocialLinks(
        'https://gitlab.com/group/project/tree/main/packages/core',
      );
      expect(result, contains("icon: 'gitlab'"));
      expect(result, contains("link: 'https://gitlab.com/group/project'"));
    });
  });
}
