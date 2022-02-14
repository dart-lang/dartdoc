// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:build_test/build_test.dart';
import 'package:collection/collection.dart';

import '../../tool/mustachio/builder.dart';

/// The build package Asset for a copy of the Renderer annotation for tests.
///
/// In testing builders, the builder cannot access both in-line assets specified
/// in tests, _and_ assets on disk in the package.
// Update this when [Renderer] and [Context] are updated.
const annotationsAsset = {
  'mustachio|lib/annotations.dart': '''
class Renderer {
  final Symbol name;

  final Context context;

  final Set<Type> visibleTypes;

  final String standardHtmlTemplate;

  final String standardMdTemplate;

  const Renderer(
    this.name,
    this.context,
    String standardTemplateBasename, {
    this.visibleTypes = const {},
  })  : standardHtmlTemplate =
            'package:foo/templates/html/\$standardTemplateBasename.html',
        standardMdTemplate =
            'package:foo/templates/md/\$standardTemplateBasename.md';
}

class Context<T> {
  const Context();
}
'''
};

/// Front matter for a library which declares a Renderer for `Foo`.
const libraryFrontMatter = '''
@Renderer(#renderFoo, Context<Foo>(), 'foo', visibleTypes: {Bar, Baz})
library foo;
import 'package:mustachio/annotations.dart';
''';

/// Tests the Mustachio builder using in-memory Assets.
Future<void> testMustachioBuilder(
  InMemoryAssetWriter writer,
  String sourceLibraryContent, {
  String libraryFrontMatter = libraryFrontMatter,
  Map<String, String> additionalAssets = const {},
}) async {
  sourceLibraryContent = '''
$libraryFrontMatter
$sourceLibraryContent
''';
  await testBuilder(
    mustachioBuilder(BuilderOptions({})),
    {
      ...annotationsAsset,
      'foo|lib/foo.dart': sourceLibraryContent,
      'foo|lib/templates/html/foo.html': 's1 is {{ s1 }}',
      'foo|lib/templates/md/foo.md': 's1 is {{ s1 }}',
      'foo|lib/templates/html/bar.html': 'EMPTY',
      'foo|lib/templates/md/bar.md': 'EMPTY',
      'foo|lib/templates/html/baz.html': 'EMPTY',
      'foo|lib/templates/md/baz.md': 'EMPTY',
      ...additionalAssets,
    },
    writer: writer,
  );
}

extension LibraryExtensions on LibraryElement {
  /// Returns the top-level function in [this] library, named [name], or `null`
  /// if no function is found.
  FunctionElement? getTopLevelFunction(String name) => topLevelElements
      .whereType<FunctionElement>()
      .firstWhereOrNull((element) => element.name == name);
}
