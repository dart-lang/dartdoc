// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:io' hide ProcessException;

import 'package:grinder/grinder.dart';
import 'package:path/path.dart' as p;

import 'src/subprocess_launcher.dart';
import 'task.dart' as task;

void main(List<String> args) => grind(args);

/// Creates a clean version of dartdoc (based on the current directory, assumed
/// to be a git repository), configured to use packages from the Dart SDK.
///
/// This copy of dartdoc depends on the HEAD versions of various packages
/// developed within the SDK, such as 'analyzer', '_fe_analyzer_shared',
/// and 'meta'.
Future<String> createSdkDartdoc() async {
  var launcher = SubprocessLauncher('create-sdk-dartdoc');
  var dartdocSdk = Directory.systemTemp.createTempSync('dartdoc-sdk');
  await launcher
      .runStreamed('git', ['clone', Directory.current.path, dartdocSdk.path]);
  await launcher.runStreamed('git', ['checkout'],
      workingDirectory: dartdocSdk.path);

  var sdkClone = Directory.systemTemp.createTempSync('sdk-checkout');
  await launcher.runStreamed('git', [
    'clone',
    '--branch',
    'main',
    '--depth',
    '1',
    'https://dart.googlesource.com/sdk.git',
    sdkClone.path
  ]);
  var dartdocPubspec = File(p.join(dartdocSdk.path, 'pubspec.yaml'));
  var pubspecLines = await dartdocPubspec.readAsLines();
  var pubspecLinesFiltered = <String>[];
  for (var line in pubspecLines) {
    if (line.startsWith('dependency_overrides:')) {
      pubspecLinesFiltered.add('#dependency_overrides:');
    } else {
      pubspecLinesFiltered.add(line);
    }
  }

  await dartdocPubspec.writeAsString(pubspecLinesFiltered.join('\n'));
  dartdocPubspec.writeAsStringSync('''

dependency_overrides:
  analyzer:
    path: '${sdkClone.path}/pkg/analyzer'
  _fe_analyzer_shared:
    path: '${sdkClone.path}/pkg/_fe_analyzer_shared'
  meta:
    path: '${sdkClone.path}/pkg/meta'
''', mode: FileMode.append);
  await launcher.runStreamed(Platform.resolvedExecutable, ['pub', 'get'],
      workingDirectory: dartdocSdk.path);
  return dartdocSdk.path;
}

@Task('Run grind tasks with the analyzer SDK.')
Future<void> testWithAnalyzerSdk() async {
  var launcher = SubprocessLauncher('test-with-analyzer-sdk');
  // Do not override meta on branches outside of stable.
  var sdkDartdoc = await createSdkDartdoc();
  var defaultGrindParameter =
      Platform.environment['DARTDOC_GRIND_STEP'] ?? 'test';
  // TODO(srawlins): Re-enable sdk-analyzer when dart_style is published using
  // analyzer 3.0.0.
  try {
    await launcher.runStreamed(
        Platform.resolvedExecutable, ['run', 'grinder', defaultGrindParameter],
        workingDirectory: sdkDartdoc);
  } catch (e, st) {
    print('Warning: SDK analyzer job threw "$e":\n$st');
  }
}

@Task(
    'Build an arbitrary pub package based on PACKAGE_NAME and PACKAGE_VERSION '
    'environment variables')
Future<String> buildPubPackage() async => await task.docPackage(
      name: Platform.environment['PACKAGE_NAME']!,
      version: Platform.environment['PACKAGE_VERSION'],
    );
