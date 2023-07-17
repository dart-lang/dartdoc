// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollectionImpl;
import 'package:collection/collection.dart';
import 'package:path/path.dart' as path;
import 'package:test_descriptor/test_descriptor.dart' as d;

import '../../tool/mustachio/builder.dart';
import '../src/test_descriptor_utils.dart';

export '../../tool/mustachio/builder.dart';

/// The build package Asset for a copy of the Renderer annotation for tests.
///
/// In testing builders, the builder cannot access both in-line assets specified
/// in tests, _and_ assets on disk in the package.
// Update this when [Renderer] and [Context] are updated.
const annotationsContent = '''
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
  })  : standardHtmlTemplate = 'lib/templates/html/\${standardTemplateBasename}.html',
        standardMdTemplate = 'lib/templates/md/\${standardTemplateBasename}.md';
}

class Context<T> {
  const Context();
}
''';

/// Front matter for a library which declares a Renderer for `Foo`.
const libraryFrontMatter = '''
@Renderer(#renderFoo, Context<Foo>(), 'foo', visibleTypes: {Bar, Baz})
library foo;
import 'annotations.dart';
''';

/// Tests the Mustachio builder using in-memory Assets.
Future<void> testMustachioBuilder(
  String sourceLibraryContent, {
  String libraryFrontMatter = libraryFrontMatter,
  Iterable<DirectoryDescriptor> Function()? additionalAssets,
}) async {
  sourceLibraryContent = '''
$libraryFrontMatter
$sourceLibraryContent
''';
  additionalAssets ??= () => [];
  await d.dir('foo_package', [
    d.dir('lib', [
      d.file('annotations.dart', annotationsContent),
      d.file('foo.dart', sourceLibraryContent),
      d.dir('templates', [
        d.dir('html', [
          d.file('foo.html', 's1 is {{ s1 }}'),
          d.file('bar.html', 'EMPTY'),
          d.file('baz.html', 'EMPTY'),
        ]),
        d.dir('md', [
          d.file('foo.md', 's1 is {{ s1 }}'),
          d.file('bar.md', 'EMPTY'),
          d.file('baz.md', 'EMPTY'),
        ]),
      ]),
    ]),
  ]).create();
  await d.dir('foo_package', [...additionalAssets()]).create();
  await build(path.join(d.sandbox, 'foo_package', 'lib/foo.dart'),
      root: path.join(d.sandbox, 'foo_package'));
}

Future<LibraryElement> resolveGeneratedLibrary(String libraryPath) async {
  var contextCollection = AnalysisContextCollectionImpl(
    includedPaths: [d.sandbox],
    // TODO(jcollins-g): should we pass excluded directories here instead of
    // handling it ourselves?
    resourceProvider: PhysicalResourceProvider.INSTANCE,
    sdkPath: sdkPath,
  );
  var analysisContext = contextCollection.contextFor(d.sandbox);
  final libraryResult =
      await analysisContext.currentSession.getResolvedLibrary(libraryPath);
  if (libraryResult is! ResolvedLibraryResult) {
    throw StateError(
        'Expected library result to be ResolvedLibraryResult, but is '
        '${libraryResult.runtimeType}');
  }

  return libraryResult.element;
}

extension LibraryExtensions on LibraryElement {
  /// Returns the top-level function in [this] library, named [name], or `null`
  /// if no function is found.
  FunctionElement? getTopLevelFunction(String name) => topLevelElements
      .whereType<FunctionElement>()
      .firstWhereOrNull((element) => element.name == name);
}
