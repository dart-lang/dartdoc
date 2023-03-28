// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/src/dart/element/member.dart';
import 'package:build/build.dart';
import 'package:dartdoc/src/mustachio/annotations.dart';

import 'codegen_aot_compiler.dart';
import 'codegen_runtime_renderer.dart';

const rendererClassesArePublicOption = 'rendererClassesArePublic';

/// A [Builder] which builds runtime Mustachio renderers.
class MustachioBuilder implements Builder {
  final bool _rendererClassesArePublic;

  MustachioBuilder({bool rendererClassesArePublic = false})
      : _rendererClassesArePublic = rendererClassesArePublic;

  @override
  final buildExtensions = const {
    '.dart': [
      '.aot_renderers_for_html.dart',
      '.aot_renderers_for_md.dart',
      '.runtime_renderers.dart',
    ]
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Each `buildStep` has a single input.
    var inputId = buildStep.inputId;

    final entryLib = await buildStep.inputLibrary;

    final rendererGatherer = _RendererGatherer(entryLib);

    // Create a new target `AssetId` based on the old one.
    var runtimeRenderersLibrary =
        inputId.changeExtension('.runtime_renderers.dart');

    var aotLibraries = {
      TemplateFormat.html:
          inputId.changeExtension('.aot_renderers_for_html.dart'),
      TemplateFormat.md: inputId.changeExtension('.aot_renderers_for_md.dart'),
    };

    if (rendererGatherer._rendererSpecs.isEmpty) {
      await buildStep.writeAsString(runtimeRenderersLibrary, '');
      await buildStep.writeAsString(aotLibraries[TemplateFormat.html]!, '');
      await buildStep.writeAsString(aotLibraries[TemplateFormat.md]!, '');

      return;
    }

    var runtimeRenderersContents = buildRuntimeRenderers(
      rendererGatherer._rendererSpecs,
      entryLib.source.uri,
      entryLib.typeProvider,
      entryLib.typeSystem,
      rendererClassesArePublic: _rendererClassesArePublic,
    );
    await buildStep.writeAsString(
        runtimeRenderersLibrary, runtimeRenderersContents);

    for (var format in TemplateFormat.values) {
      String aotRenderersContents;
      var someSpec = rendererGatherer._rendererSpecs.first;
      if (someSpec.standardTemplateUris[format] != null) {
        aotRenderersContents = await compileTemplatesToRenderers(
          rendererGatherer._rendererSpecs,
          entryLib.source.uri,
          buildStep,
          entryLib.typeProvider,
          entryLib.typeSystem,
          format,
        );
      } else {
        aotRenderersContents = '';
      }

      await buildStep.writeAsString(
          aotLibraries[format]!, aotRenderersContents);
    }
  }
}

class _RendererGatherer {
  final Set<RendererSpec> _rendererSpecs;

  _RendererGatherer._(this._rendererSpecs);

  factory _RendererGatherer(LibraryElement entryLib) {
    final rendererSpecs = <RendererSpec>{};

    void addRendererSpecs(List<ElementAnnotation> annotations) {
      for (var annotation in annotations) {
        if (annotation.element is ConstructorElement) {
          if (annotation.element!.enclosingElement!.name == 'Renderer') {
            rendererSpecs.add(_buildRendererSpec(annotation));
          }
        } else if (annotation.element is ConstructorMember) {
          if (annotation.element!.enclosingElement!.name == 'Renderer') {
            rendererSpecs.add(_buildRendererSpec(annotation));
          }
        }
      }
    }

    addRendererSpecs(entryLib.metadata);
    for (final element in entryLib.topLevelElements) {
      addRendererSpecs(element.metadata);
    }
    return _RendererGatherer._(rendererSpecs);
  }

  static RendererSpec _buildRendererSpec(ElementAnnotation annotation) {
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
        constantValue.getField('standardHtmlTemplate');
    var standardMdTemplateField = constantValue.getField('standardMdTemplate');

    return RendererSpec(
      nameField.toSymbolValue()!,
      contextType as InterfaceType,
      visibleTypes,
      standardHtmlTemplateField!.toStringValue()!,
      standardMdTemplateField!.toStringValue()!,
    );
  }
}

Builder mustachioBuilder(BuilderOptions options) => MustachioBuilder(
    rendererClassesArePublic:
        options.config[rendererClassesArePublicOption] as bool? ?? false);
