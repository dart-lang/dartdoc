// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer_testing/utilities/extensions/resource_provider.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:yaml/yaml.dart' as yaml;

export 'package:test_descriptor/test_descriptor.dart';

/// Builds and returns the content of a pubspec file.
String buildPubspecText({
  String sdkConstraint = '>=3.2.0 <4.0.0',
  Map<String, String> dependencies = const {},
}) {
  var buffer = StringBuffer('''
name: test_package
version: 0.0.1
environment:
  sdk: '$sdkConstraint'
''');
  if (dependencies.isNotEmpty) {
    buffer.writeln('dependencies:');
    dependencies.forEach((name, path) {
      buffer.writeln('  $name:');
      buffer.writeln('    path: $path');
    });
  }
  return buffer.toString();
}

/// Creates a pub package in a directory named [name].
///
/// If [resourceProvider] is given, then the pub package is created in the file
/// system provided by [resourceProvider]; otherwise it is created in the
/// physical file system, under [d.sandbox].
Future<String> createPackage(
  String name, {
  String? pubspec,
  String? dartdocOptions,
  String? analysisOptions,
  List<d.Descriptor> libFiles = const [],
  List<d.Descriptor> files = const [],
  MemoryResourceProvider? resourceProvider,
}) async {
  pubspec ??= buildPubspecText();
  final parsedYaml = yaml.loadYaml(pubspec) as Map;
  final packageName = parsedYaml['name'];
  final versionConstraint = (parsedYaml['environment'] as Map)['sdk'] as String;
  final languageVersion = RegExp(r'>=(\S*)\.0(-0)?(-0.0-dev)? ')
      .firstMatch(versionConstraint)!
      .group(1);
  final packagesInfo = StringBuffer('''{
  "name": "$packageName",
  "rootUri": "../",
  "packageUri": "lib/",
  "languageVersion": "$languageVersion"
}''');
  if (parsedYaml.containsKey('dependencies')) {
    final dependencies = parsedYaml['dependencies'] as Map;
    for (var dep in dependencies.keys) {
      // This only accepts 'path' deps.
      final depConfig = dependencies[dep];
      if (depConfig is! Map) {
        throw StateError('dep in pubspec must be a Map, but is: "$depConfig"');
      }
      final pathDep = depConfig['path'];

      packagesInfo.writeln(''',{
  "name": "$dep",
  "rootUri": "../$pathDep",
  "packageUri": "lib/"
}''');
    }
  }

  final packageDir = d.dir(name, [
    d.file('pubspec.yaml', pubspec),
    if (dartdocOptions != null) d.file('dartdoc_options.yaml', dartdocOptions),
    if (analysisOptions != null)
      d.file('analysis_options.yaml', analysisOptions),
    d.dir('lib', [...libFiles]),
    ...files,
    // Write out '.dart_tool/package_config.json' to avoid needing `pub get`.
    d.dir(
      '.dart_tool',
      [
        d.file('package_config.json', '''
{
  "configVersion": 2,
  "packages": [
    $packagesInfo
  ],
  "generated": "2024-02-14T20:36:04.604099Z",
  "generator": "pub",
  "generatorVersion": "3.2.0"
}
''')
      ],
    ),
  ]);
  if (resourceProvider == null) {
    await packageDir.create();
    return packageDir.io.path;
  } else {
    return await packageDir.createInMemory(resourceProvider);
  }
}

extension on d.DirectoryDescriptor {
  Future<String> createInMemory(MemoryResourceProvider resourceProvider,
      [String? parent]) async {
    parent ??= resourceProvider.pathContext.canonicalize(
        ResourceProviderExtension(resourceProvider).convertPath('/temp'));
    resourceProvider.newFolder(parent).create();
    var fullPath = resourceProvider.pathContext.join(parent, name);
    resourceProvider.newFolder(fullPath).create();
    for (var e in contents) {
      await e.createInMemory(resourceProvider, fullPath);
    }
    return fullPath;
  }
}

extension on d.FileDescriptor {
  Future<String> createInMemory(
      MemoryResourceProvider resourceProvider, String parent) async {
    var content = await readAsBytes().transform(utf8.decoder).join('');
    var fullPath = ResourceProviderExtension(resourceProvider)
        .convertPath(resourceProvider.pathContext.join(parent, name));
    resourceProvider.newFile(fullPath, content);
    return fullPath;
  }
}

extension DescriptorExtensions on d.Descriptor {
  /// Creates this [d.Descriptor] in the [MemoryResourceProvider].
  ///
  /// For a [d.DirectoryDescriptor], the subtree will be created. For a
  /// [d.FileDescriptor], the file contents will be written.
  Future<String> createInMemory(MemoryResourceProvider resourceProvider,
      [String? parent]) {
    var self = this;
    return switch (self) {
      d.DirectoryDescriptor() => self.createInMemory(resourceProvider, parent),
      d.FileDescriptor() => self.createInMemory(resourceProvider, parent!),
      _ => throw StateError(
          '$runtimeType is not a DirectoryDescriptor, nor a FileDescriptor!')
    };
  }
}
