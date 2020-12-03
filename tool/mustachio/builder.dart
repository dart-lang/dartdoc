import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart';
import 'package:build/build.dart';

import 'codegen_runtime_renderer.dart';

const rendererClassesArePublicOption = 'rendererClassesArePublic';

/// A [Builder] which builds runtime Mustachio renderers.
class MustachioBuilder implements Builder {
  final bool _rendererClassesArePublic;

  MustachioBuilder({bool rendererClassesArePublic = false})
      : _rendererClassesArePublic = rendererClassesArePublic;

  @override
  final buildExtensions = const {
    '.dart': ['.renderers.dart']
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    // Each `buildStep` has a single input.
    var inputId = buildStep.inputId;

    final entryLib = await buildStep.inputLibrary;
    if (entryLib == null) return;

    final rendererGatherer = _RendererGatherer(entryLib);

    // Create a new target `AssetId` based on the old one.
    var renderersLibrary = inputId.changeExtension('.renderers.dart');
    var contents = '';

    if (rendererGatherer._rendererSpecs.isNotEmpty) {
      contents += buildTemplateRenderers(rendererGatherer._rendererSpecs,
          entryLib.source.uri, entryLib.typeProvider, entryLib.typeSystem,
          rendererClassesArePublic: _rendererClassesArePublic);

      await buildStep.writeAsString(renderersLibrary, contents);
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
        if (annotation == null) continue;
        if (annotation.element is ConstructorElement) {
          if (annotation.element.enclosingElement.name == 'Renderer') {
            rendererSpecs.add(_buildRendererSpec(annotation));
          }
        } else if (annotation.element is ConstructorMember) {
          if (annotation.element.enclosingElement.name == 'Renderer') {
            rendererSpecs.add(_buildRendererSpec(annotation));
          }
        }
      }
    }

    if (entryLib.metadata != null) {
      addRendererSpecs(entryLib.metadata);
    }
    for (final element in entryLib.topLevelElements) {
      if (element.metadata != null) {
        addRendererSpecs(element.metadata);
      }
    }
    return _RendererGatherer._(rendererSpecs);
  }

  static RendererSpec _buildRendererSpec(ElementAnnotation annotation) {
    var constantValue = annotation.computeConstantValue();
    var nameField = constantValue.getField('name');
    if (nameField.isNull) {
      throw StateError('@Renderer name must not be null');
    }
    var contextField = constantValue.getField('context');
    if (contextField.isNull) {
      throw StateError('@Renderer context must not be null');
    }
    var contextFieldType = contextField.type;
    assert(contextFieldType.typeArguments.length == 1);
    var contextType = contextFieldType.typeArguments.single;

    return RendererSpec(nameField.toSymbolValue(), contextType);
  }
}

Builder mustachioBuilder(BuilderOptions options) => MustachioBuilder(
    rendererClassesArePublic:
        options.config[rendererClassesArePublicOption] ?? false);
