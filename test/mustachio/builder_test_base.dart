// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';

/// The build package Asset for a copy of the Renderer annotation for tests.
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

extension LibraryExtensions on LibraryElement {
  /// Returns the top-level function in [this] library, named [name].
  FunctionElement getTopLevelFunction(String name) => topLevelElements
      .whereType<FunctionElement>()
      .firstWhere((element) => element.name == name, orElse: () => null);
}
