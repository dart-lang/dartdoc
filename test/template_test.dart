library dartdoc.template_test;

import 'dart:io';

import 'package:mustache4dart/mustache4dart.dart';
import 'package:unittest/unittest.dart';


tests() {
  group('template', () {
    var script = new File(Platform.script.toFilePath());
    File tmplFile = new File('${script.parent.parent.path}/templates/sitemap.xml');
    
    test('sitemap template exists', () {
      tmplFile.exists().then((t) => expect(t, true));
    });
     
    var siteMapTmpl = tmplFile.readAsStringSync();
    var sitemap = compile(siteMapTmpl);
    
    test('render', () {
      expect(sitemap({'links' : [{'name': 'somefile.html'}]}), 
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
        expect(sitemap({'links' : [{'name': 'somefile.html'}, {'name': 'asecondfile.html'}]}),
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
    
    });
}
