// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'dart:io';

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/package_builder.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:pub_semver/pub_semver.dart';

/// The number of public libraries in testing/test_package, minus 2 for
/// the excluded libraries listed in the initializers for _testPackageGraphMemo
/// and minus 1 for the <nodoc> tag in the 'excluded' library.
const int kTestPackagePublicLibraries = 27;

final _resourceProvider = pubPackageMetaProvider.resourceProvider;
final _pathContext = _resourceProvider.pathContext;

final String platformVersionString = Platform.version.split(' ').first;
final Version platformVersion = Version.parse(platformVersionString);

final Folder testPackageToolError = _resourceProvider.getFolder(_pathContext
    .absolute(_pathContext.normalize('testing/test_package_tool_error')));

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(
    List<String> argv, PackageMetaProvider packageMetaProvider) async {
  var optionSet = await DartdocOptionRoot.fromOptionGenerators(
      'dartdoc', [createDartdocOptions], packageMetaProvider);
  optionSet.parseArguments(argv);
  return DartdocOptionContext.fromDefaultContextLocation(
      optionSet, pubPackageMetaProvider.resourceProvider);
}

Future<PackageGraph> bootBasicPackage(
    String dirPath,
    PackageMetaProvider packageMetaProvider,
    PackageConfigProvider packageConfigProvider,
    {List<String> excludeLibraries = const [],
    List<String> additionalArguments = const []}) async {
  // TODO(devoncarew): Should this test method run 'pub get'?
  var resourceProvider = packageMetaProvider.resourceProvider;
  var dir = resourceProvider.getFolder(resourceProvider.pathContext
      .absolute(resourceProvider.pathContext.normalize(dirPath)));
  return PubPackageBuilder(
          await contextFromArgv([
            '--input',
            dir.path,
            '--sdk-dir',
            packageMetaProvider.defaultSdkDir.path,
            '--exclude',
            excludeLibraries.join(','),
            '--allow-tools',
            ...additionalArguments,
          ], packageMetaProvider),
          packageMetaProvider,
          packageConfigProvider)
      .buildPackageGraph();
}

/// Returns a [FakePackageConfigProvider] with an entry for the SDK directory.
PackageConfigProvider getTestPackageConfigProvider(String sdkPath) {
  var packageConfigProvider = FakePackageConfigProvider();
  // To build the package graph, we always ask package_config for a
  // [PackageConfig] for the SDK directory. Put a dummy entry in.
  packageConfigProvider.addPackageToConfigFor(
      sdkPath, 'analyzer', Uri.file('/sdk/pkg/analyzer/'));
  return packageConfigProvider;
}

/// Returns a [PackageMetaProvider] using a [MemoryResourceProvider].
PackageMetaProvider get testPackageMetaProvider {
  var resourceProvider = MemoryResourceProvider();
  final sdkRoot = resourceProvider.getFolder(
    resourceProvider.convertPath('/sdk'),
  );
  createMockSdk(
    resourceProvider: resourceProvider,
    root: sdkRoot,
  );
  writeMockSdkFiles(sdkRoot);

  return PackageMetaProvider(
    PubPackageMeta.fromElement,
    PubPackageMeta.fromFilename,
    PubPackageMeta.fromDir,
    resourceProvider,
    sdkRoot,
    defaultSdk: FolderBasedDartSdk(resourceProvider, sdkRoot),
    messageForMissingPackageMeta: PubPackageMeta.messageForMissingPackageMeta,
  );
}

/// Writes additional files for a mock SDK.
///
/// Included is a "version" file and an "api_readme.md" file.
void writeMockSdkFiles(Folder sdkFolder) {
  sdkFolder.getChildAssumingFile('version').writeAsStringSync('2.9.0');
  sdkFolder.getChildAssumingFile('api_readme.md').writeAsStringSync(
      'Welcome to the [Dart](https://dart.dev/) API reference documentation');

  _writeMockSdkBinFiles(sdkFolder);
}

/// Dartdoc has a few indicator files it uses to verify that a directory
/// represents a Dart SDK. These include "bin/dart" and "bin/pub".
void _writeMockSdkBinFiles(Folder root) {
  var sdkBinFolder = root.getChildAssumingFolder('bin');
  sdkBinFolder.getChildAssumingFile('dart').writeAsStringSync('');
  var sdkIncludeFolder = root.getChildAssumingFolder('include');
  sdkIncludeFolder.getChildAssumingFile('dart_version.h').writeAsStringSync('');
}

/// Writes a package named [packageName], with [resourceProvider], to the
/// "/projects" directory.
///
/// The package is added to [packageConfigProvider]. A standard pubspec is
/// written if one is not provided via [pubspecContent].
Folder writePackage(String packageName, MemoryResourceProvider resourceProvider,
    FakePackageConfigProvider packageConfigProvider,
    {String? pubspecContent}) {
  pubspecContent ??= '''
name: $packageName
version: 0.0.1
homepage: https://github.com/dart-lang
''';
  var pathContext = resourceProvider.pathContext;
  var projectsFolder = resourceProvider.getFolder(
      pathContext.canonicalize(resourceProvider.convertPath('/projects')));
  var projectFolder = projectsFolder.getChildAssumingFolder(packageName)
    ..create;
  var projectRoot = projectFolder.path;
  projectFolder
      .getChildAssumingFile('pubspec.yaml')
      .writeAsStringSync(pubspecContent);
  projectFolder.getChildAssumingFile('.packages').writeAsStringSync('''
# Generated by pub on 2020-07-07 08:25:30.557406.
one:../one/lib/
two:lib/
''');
  projectFolder
      .getChildAssumingFolder('.dart_tool')
      .getChildAssumingFile('package_config.json')
      .writeAsStringSync('''
{
  "configVersion": 2,
  "packages": [
    {
      "name": "one",
      "rootUri": "../../one",
      "packageUri": "lib/",
      "languageVersion": "2.0"
    },
    {
      "name": "two",
      "rootUri": "../",
      "packageUri": "lib/",
      "languageVersion": "2.0"
    }
  ],
  "generated": "2020-07-07T15:25:30.566271Z",
  "generator": "pub",
  "generatorVersion": "2.8.4"
}
''');
  projectFolder.getChildAssumingFolder('lib').create();
  packageConfigProvider.addPackageToConfigFor(projectRoot, packageName,
      Uri.file('$projectRoot${resourceProvider.pathContext.separator}'));

  return projectFolder;
}

/// For comparison purposes, return an equivalent [MatchingLinkResult]
/// for the defining element returned.  May return [originalResult].
/// We do this to eliminate canonicalization effects from comparison,
/// as the original lookup code returns canonicalized results and the
/// new lookup code is only guaranteed to return equivalent results.
MatchingLinkResult definingLinkResult(MatchingLinkResult originalResult) {
  var definingReferable =
      originalResult.commentReferable?.definingCommentReferable;

  if (definingReferable != null &&
      definingReferable != originalResult.commentReferable) {
    return MatchingLinkResult(definingReferable, warn: originalResult.warn);
  }
  return originalResult;
}

MatchingLinkResult referenceLookup(Warnable element, String codeRef) =>
    definingLinkResult(getMatchingLinkElement(element, codeRef));
