// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library test_utils;

import 'package:analyzer/file_system/file_system.dart';
import 'package:analyzer/file_system/memory_file_system.dart';
import 'package:analyzer/src/test_utilities/mock_sdk.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';

/// The number of public libraries in testing/test_package, minus 2 for
/// the excluded libraries listed in the initializers for _testPackageGraphMemo
/// and minus 1 for the <nodoc> tag in the 'excluded' library.
const int kTestPackagePublicLibraries = 17;

final _resourceProvider = pubPackageMetaProvider.resourceProvider;
final _pathContext = _resourceProvider.pathContext;

final Folder testPackageToolError = _resourceProvider.getFolder(_pathContext
    .absolute(_pathContext.normalize('testing/test_package_tool_error')));

/// Convenience factory to build a [DartdocOptionContext] and associate it with a
/// [DartdocOptionSet] based on the current working directory.
Future<DartdocOptionContext> contextFromArgv(
    List<String> argv, PackageMetaProvider packageMetaProvider) async {
  var resourceProvider = packageMetaProvider.resourceProvider;
  var optionSet = await DartdocOptionSet.fromOptionGenerators(
      'dartdoc', [createDartdocOptions], packageMetaProvider);
  optionSet.parseArguments(argv);
  return DartdocOptionContext(
      optionSet,
      resourceProvider.getFolder(resourceProvider.pathContext.current),
      pubPackageMetaProvider.resourceProvider);
}

Future<PackageGraph> bootBasicPackage(
    String dirPath,
    PackageMetaProvider packageMetaProvider,
    PackageConfigProvider packageConfigProvider,
    {List<String> excludeLibraries = const [],
    List<String> additionalArguments = const []}) async {
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
  var mockSdk = MockSdk(resourceProvider: resourceProvider);
  var sdkFolder = writeMockSdkFiles(mockSdk);

  return PackageMetaProvider(
    PubPackageMeta.fromElement,
    PubPackageMeta.fromFilename,
    PubPackageMeta.fromDir,
    resourceProvider,
    sdkFolder,
    defaultSdk: mockSdk,
  );
}

/// Writes [mockSdk] to disk at both its original path, and its canonicalized
/// path (they may be different on Windows).
///
/// Included is a "version" file and an "api_readme.md" file.
Folder writeMockSdkFiles(MockSdk mockSdk) {
  var resourceProvider = mockSdk.resourceProvider;
  var pathContext = resourceProvider.pathContext;

  // The [MockSdk] only works in non-canonicalized paths, which include
  // "C:\sdk", on Windows. However, dartdoc works almost exclusively with
  // canonical paths ("c:\sdk"). Copy all MockSdk files to the canonicalized
  // path.
  for (var l in mockSdk.sdkLibraries) {
    var p = l.path;
    resourceProvider
        .getFile(pathContext.canonicalize(p))
        .writeAsStringSync(resourceProvider.getFile(p).readAsStringSync());
  }
  var sdkFolder = resourceProvider.getFolder(
      pathContext.canonicalize(resourceProvider.convertPath(sdkRoot)))
    ..create();
  sdkFolder.getChildAssumingFile('version').writeAsStringSync('2.9.0');
  sdkFolder.getChildAssumingFile('api_readme.md').writeAsStringSync(
      'Welcome to the [Dart](https://dart.dev/) API reference documentation');

  _writeMockSdkBinFiles(sdkFolder);
  _writeMockSdkBinFiles(
      resourceProvider.getFolder(resourceProvider.convertPath(sdkRoot)));

  return sdkFolder;
}

/// Dartdoc has a few indicator files it uses to verify that a directory
/// represents a Dart SDK. These include "bin/dart" and "bin/pub".
void _writeMockSdkBinFiles(Folder root) {
  var sdkBinFolder = root.getChildAssumingFolder('bin');
  sdkBinFolder.getChildAssumingFile('dart').writeAsStringSync('');
  sdkBinFolder.getChildAssumingFile('pub').writeAsStringSync('');
}

/// Writes a package named [packageName], with [resourceProvider], to the
/// "/projects" directory.
///
/// The package is added to [packageConfigProvider]. A standard pubspec is
/// written if one is not provided via [pubspecContent].
Folder writePackage(String packageName, MemoryResourceProvider resourceProvider,
    FakePackageConfigProvider packageConfigProvider,
    {String pubspecContent}) {
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
      Uri.file('${projectRoot}${resourceProvider.pathContext.separator}'));

  return projectFolder;
}
