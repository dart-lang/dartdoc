// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.template_test;

import 'dart:io';

import 'package:dartdoc/src/third_party/pkg/mustache4dart/lib/mustache4dart.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

void main() {
  group('template', () {
    group('with sitemap', () {
      var sitemap;

      setUp(() {
        if (sitemap == null) {
          var templatePath =
              pathLib.join(pathLib.current, 'lib/templates/sitemap.xml');
          File tmplFile = new File(templatePath);
          var siteMapTmpl = tmplFile.readAsStringSync();
          sitemap = compile(siteMapTmpl);
        }
      });

      test('render', () {
        expect(
            _normalize(sitemap({
              'links': [
                {'name': 'somefile.html'}
              ]
            })),
            '''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>/somefile.html</loc>
  </url>
</urlset>
''');
      });

      test('substitute multiple links', () {
        expect(
            _normalize(sitemap({
              'links': [
                {'name': 'somefile.html'},
                {'name': 'asecondfile.html'}
              ]
            })),
            '''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>/somefile.html</loc>
  </url>
  <url>
    <loc>/asecondfile.html</loc>
  </url>
</urlset>
''');
      });

      test('url and file name', () {
        expect(
            _normalize(sitemap({
              'url': 'http://mydoc.com',
              'links': [
                {'name': 'somefile.html'}
              ]
            })),
            '''
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
  <url>
    <loc>http://mydoc.com/somefile.html</loc>
  </url>
</urlset>
''');
      });
    });
  });
}

String _normalize(String str) => str.replaceAll('\r\n', '\n');
