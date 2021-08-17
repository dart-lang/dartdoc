// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// @dart=2.9

library dartdoc.dartdoc_test;

import 'dart:async';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/generator/html_generator.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:test/test.dart';

/// Convenience factory to build a [DartdocGeneratorOptionContext] and associate
/// it with a [DartdocOptionSet] based on the current working directory and/or
/// the '--input' flag.
Future<DartdocGeneratorOptionContext> _generatorContextFromArgv(
    List<String> argv) async {
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc',
      [
        createDartdocOptions,
        createGeneratorOptions,
      ],
      pubPackageMetaProvider);
  optionSet.parseArguments(argv);
  return DartdocGeneratorOptionContext(
      optionSet, null, pubPackageMetaProvider.resourceProvider);
}

void main() {
  test('source code links are visible', () async {
    var resourceProvider = pubPackageMetaProvider.resourceProvider;
    var pathContext = resourceProvider.pathContext;
    var testPackageDir = resourceProvider.getFolder(
        pathContext.absolute(pathContext.canonicalize('testing/test_package')));

    var context = await _generatorContextFromArgv(
        ['--input', testPackageDir.path, '--output', 'UNUSED']);
    var dartdoc = await Dartdoc.fromContext(
      context,
      PubPackageBuilder(
          context, pubPackageMetaProvider, PhysicalPackageConfigProvider()),
    );

    var packageGraph = await dartdoc.packageBuilder.buildPackageGraph();
    var reourceProviderForWriting = MemoryResourceProvider();

    var tempDirForAot = reourceProviderForWriting.createSystemTemp('aot.');
    if (!tempDirForAot.exists) tempDirForAot.create();
    var writerForAot =
        DartdocFileWriter(tempDirForAot.path, reourceProviderForWriting);
    await dartdoc.generator.generate(packageGraph, writerForAot);

    var tempDirForRuntime =
        reourceProviderForWriting.createSystemTemp('runtime.');
    if (!tempDirForRuntime.exists) tempDirForRuntime.create();
    var writerForRuntime =
        DartdocFileWriter(tempDirForRuntime.path, reourceProviderForWriting);
    dartdoc.generator =
        await initHtmlGenerator(context, forceRuntimeTemplates: true);
    await dartdoc.generator.generate(packageGraph, writerForRuntime);

    var filesInAot = 0;
    var filesInRuntime = 0;
    var charactersInAot = 0;
    var charactersInRuntime = 0;

    void checkDirectories(Folder aotDirectory, Folder runtimeDirectory) {
      expect(aotDirectory.exists, true);
      expect(runtimeDirectory.exists, true);
      for (var aotResource in aotDirectory.getChildren()) {
        var runtimeResource = runtimeDirectory.getChild(aotResource.shortName);
        expect(runtimeResource.exists, true);
        if (aotResource is Folder) {
          if (aotResource.shortName == '.') continue;
          if (aotResource.shortName == '..') continue;
          if (aotResource.shortName == 'static-assets') continue;
          expect(runtimeResource is Folder, true);
          checkDirectories(aotResource, runtimeResource);
        } else if (aotResource is File) {
          expect(runtimeResource is File, true);
          var contentInAot = aotResource.readAsStringSync();
          var contentInRuntime = (runtimeResource as File).readAsStringSync();
          expect(contentInAot, equals(contentInRuntime));
          filesInAot++;
          filesInRuntime++;
          charactersInAot += contentInAot.length;
          charactersInRuntime += contentInRuntime.length;
        }
      }
    }

    checkDirectories(tempDirForAot, tempDirForRuntime);

    print('Checked $filesInAot files in AOT-rendered HTML against '
        '$filesInRuntime files in runtime-rendered HTML');
    print('Checked $charactersInAot characters in AOT-rendered HTML against '
        '$charactersInRuntime characters in runtime-rendered HTML');
  }, timeout: Timeout.factor(2));
}
