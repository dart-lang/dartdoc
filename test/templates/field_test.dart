// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/src/dartdoc.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import '../src/test_descriptor_utils.dart' as d;
import '../src/utils.dart';

void main() async {
  const packageName = 'test_package';

  late List<String> f1Lines;

  group('methods', () {
    setUpAll(() async {
      final packageMetaProvider = testPackageMetaProvider;
      final resourceProvider =
          packageMetaProvider.resourceProvider as MemoryResourceProvider;
      final packagePath = await d.createPackage(
        packageName,
        pubspec: '''
name: fields
version: 0.0.1
environment:
  sdk: '>=2.18.0 <3.0.0'
''',
        libFiles: [
          d.file('lib.dart', '''
class A {
  const A(String m);
}

class B {
  @deprecated
  @A('message')
  int f1 = 1;
}
'''),
        ],
        resourceProvider: resourceProvider,
      );
      await writeDartdocResources(resourceProvider);
      final context = await generatorContextFromArgv([
        '--input',
        packagePath,
        '--output',
        p.join(packagePath, 'doc'),
        '--sdk-dir',
        packageMetaProvider.defaultSdkDir.path,
        '--no-link-to-remote',
      ], packageMetaProvider);

      final packageConfigProvider =
          getTestPackageConfigProvider(packageMetaProvider.defaultSdkDir.path);
      packageConfigProvider.addPackageToConfigFor(
          packagePath, packageName, Uri.file('$packagePath/'));
      final packageBuilder = PubPackageBuilder(
        context,
        packageMetaProvider,
        packageConfigProvider,
        skipUnreachableSdkLibraries: true,
      );
      await (await Dartdoc.fromContext(context, packageBuilder)).generateDocs();
      f1Lines = resourceProvider
          .getFile(p.join(packagePath, 'doc', 'lib', 'B', 'f1.html'))
          .readAsStringSync()
          .split('\n');
    });

    test('method page contains method name', () async {
      f1Lines.expectMainContentContainsAllInOrder(
        [
          matches('<h1><span class="kind-property">f1</span> property'),
        ],
      );
    });

    test('enum page contains annotations', () async {
      f1Lines.expectMainContentContainsAllInOrder(
        [
          matches('<ol class="annotation-list">'),
          matches('<li>@deprecated</li>'),
          matches(
              r'<li>@<a href="../../lib/A-class.html">A</a>\(&#39;message&#39;\)</li>'),
          matches('</ol>'),
        ],
      );
    });

    // TODO(srawlins): Add rendering tests.
    // * how inherited fields look on subclass page ('inherited' feature)
    // * static fields
    // * linked elements in signature
  });
}
