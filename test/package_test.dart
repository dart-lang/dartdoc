// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/renderer_factory.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

import 'src/utils.dart' as utils;

void main() {
  MemoryResourceProvider resourceProvider;
  Folder projectRoot;
  PackageGraph packageGraph;
  //_Processor processor;

  setUp(() async {
    resourceProvider = MemoryResourceProvider();
    var pathContext = resourceProvider.pathContext;
    projectRoot =
        resourceProvider.getFolder(resourceProvider.convertPath('/project'));
    projectRoot.create();
    resourceProvider
        .getFile(pathContext.join(projectRoot.path, 'pubspec.yaml'))
        .writeAsStringSync('''
name: foo
''');
    resourceProvider
        .getFile(pathContext.join(
            projectRoot.path, '.dart_tool', 'package_config.json'))
        .writeAsStringSync('');
    var mockSdk = MockSdk(resourceProvider: resourceProvider);
    var sdkFolder = resourceProvider.getFolder(sdkRoot);
    var packageMetaProvider = PackageMetaProvider(
      PubPackageMeta.fromElement,
      PubPackageMeta.fromFilename,
      PubPackageMeta.fromDir,
      resourceProvider,
      sdkFolder,
      defaultSdk: mockSdk,
    );
    resourceProvider.getFolder(sdkFolder.path).create();
    resourceProvider
        .getFile(pathContext.join(sdkFolder.path, 'bin/dart'))
        .writeAsStringSync('');
    resourceProvider
        .getFile(pathContext.join(sdkFolder.path, 'bin/pub'))
        .writeAsStringSync('');
    resourceProvider
        .getFile(pathContext.join(sdkFolder.path, 'lib/core/core.dart'))
        .writeAsStringSync('');
    var optionSet = await DartdocOptionSet.fromOptionGenerators(
        'dartdoc', [createDartdocOptions], packageMetaProvider);
    optionSet.parseArguments([]);
    /*processor = _Processor(
        DartdocOptionContext(optionSet, projectRoot, resourceProvider),
        projectRoot,
        resourceProvider);
    when(processor.packageGraph.resourceProvider).thenReturn(resourceProvider);

    libFooPath =
        resourceProvider.pathContext.join(projectRoot.path, 'foo.dart');
    processor.href = libFooPath;*/
    var packageConfigProvider = FakePackageConfigProvider();
    packageConfigProvider.addPackageToConfigFor(
        Uri.file(projectRoot.path), 'foo', Uri.file('${projectRoot.path}/'));
    packageGraph = await utils.bootBasicPackage(
        projectRoot.path, [], packageMetaProvider, packageConfigProvider,
        additionalArguments: [
          '--auto-include-dependencies',
          '--no-link-to-remote'
        ]);
  });

  test('something has multiple local packages', () {
    expect(packageGraph.localPackages, hasLength(3));
  });
}

/// In order to mix in [CommentProcessable], we must first implement
/// the super-class constraints.
abstract class __Processor extends Fake
    implements Documentable, Warnable, Locatable, SourceCodeMixin {}

/// A simple comment processor for testing [CommentProcessable].
class _Processor extends __Processor with CommentProcessable {
  @override
  final DartdocOptionContext config;

  @override
  final _FakePackage package;

  @override
  final _MockPackageGraph packageGraph;

  @override
  final ModelElementRenderer modelElementRenderer;

  @override
  String href;

  @override
  Element element;

  _Processor(this.config, Folder dir, ResourceProvider resourceProvider)
      : package = _FakePackage(PubPackageMeta.fromDir(dir, resourceProvider)),
        packageGraph = _MockPackageGraph(),
        modelElementRenderer =
            RendererFactory.forFormat('html').modelElementRenderer {
    throwOnMissingStub(packageGraph);
    when(packageGraph.addMacro(any, any)).thenReturn(null);
    when(packageGraph.warnOnElement(this, any, message: anyNamed('message')))
        .thenReturn(null);
  }

  @override
  void warn(PackageWarning warning,
          {String message, Iterable<Locatable> referredFrom}) =>
      packageGraph.warnOnElement(this, warning,
          message: message, referredFrom: referredFrom);
}

class _FakePackage extends Fake implements Package {
  @override
  final PackageMeta packageMeta;

  @override
  final Map<String, Set<String>> usedAnimationIdsByHref = {};

  _FakePackage(this.packageMeta);
}

class _FakeElement extends Fake implements Element {
  @override
  final Source source;

  _FakeElement({this.source});
}

class _FakeSource extends Fake implements Source {
  @override
  final String fullName;

  _FakeSource({this.fullName});
}

class _MockPackageGraph extends Mock implements PackageGraph {}
