// Copyright (c) 2025, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/src/dart/analysis/analysis_context_collection.dart'
    show AnalysisContextCollectionImpl;
import 'package:dartdoc/src/mustachio/annotations.dart';
import 'package:path/path.dart' as path;

import 'codegen_aot_compiler.dart';

void main() async {
  await build(path.join('lib', 'src', 'generator', 'templates.dart'));
  await build(
    path.join('test', 'mustachio', 'foo.dart'),
  );
}

Future<void> build(
  String sourcePath, {
  String? root,
}) async {
  root ??= Directory.current.path;
  var contextCollection = AnalysisContextCollectionImpl(
    includedPaths: [root],
    // TODO(jcollins-g): should we pass excluded directories here instead of
    // handling it ourselves?
    resourceProvider: PhysicalResourceProvider.INSTANCE,
    sdkPath: sdkPath,
  );
  var analysisContext = contextCollection.contextFor(root);
  final libraryResult = await analysisContext.currentSession
      .getResolvedLibrary(path.join(root, sourcePath));
  if (libraryResult is! ResolvedLibraryResult) {
    throw StateError(
        'Expected library result to be ResolvedLibraryResult, but is '
        '${libraryResult.runtimeType}');
  }

  var library = libraryResult.element;
  var typeProvider = library.typeProvider;
  var typeSystem = library.typeSystem;
  var rendererSpecs = <RendererSpec>{};
  for (var renderer in library.metadata.annotations
      .where((e) => e.element!.enclosingElement!.name == 'Renderer')) {
    rendererSpecs.add(_buildRendererSpec(renderer));
  }

  var basePath = path.withoutExtension(sourcePath);
  var aotRenderersContents = await compileTemplatesToRenderers(
    rendererSpecs,
    typeProvider,
    typeSystem,
    root: root,
    sourcePath: sourcePath,
  );
  await File(path.join(root, '$basePath.aot_renderers_for_html.dart'))
      .writeAsString(aotRenderersContents);
}

RendererSpec _buildRendererSpec(ElementAnnotation annotation) {
  var constantValue = annotation.computeConstantValue()!;
  var nameField = constantValue.getField('name')!;
  if (nameField.isNull) {
    throw StateError('@Renderer name must not be null');
  }
  var contextField = constantValue.getField('context')!;
  if (contextField.isNull) {
    throw StateError('@Renderer context must not be null');
  }
  var contextFieldType = contextField.type as InterfaceType;
  assert(contextFieldType.typeArguments.length == 1);
  var contextType = contextFieldType.typeArguments.single;

  var visibleTypesField = constantValue.getField('visibleTypes')!;
  if (visibleTypesField.isNull) {
    throw StateError('@Renderer visibleTypes must not be null');
  }
  var visibleTypes = {
    ...visibleTypesField.toSetValue()!.map((object) => object.toTypeValue()!)
  };

  var standardHtmlTemplateField =
      constantValue.getField('standardHtmlTemplate')!;
  return RendererSpec(
    nameField.toSymbolValue()!,
    contextType as InterfaceType,
    visibleTypes,
    standardHtmlTemplateField.toStringValue()!,
  );
}

String get sdkPath => PhysicalResourceProvider.INSTANCE
    .getFile(PhysicalResourceProvider.INSTANCE.pathContext
        .absolute(Platform.resolvedExecutable))
    .parent
    .parent
    .path;
