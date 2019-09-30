// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// This is a sample "tool" used to test external tool integration into dartdoc.
// It has no practical purpose other than that.

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> argList) {
  final ArgParser argParser = ArgParser();
  argParser.addOption('file');
  argParser.addOption('special');
  argParser.addOption('source');
  argParser.addFlag('html', defaultsTo: false);
  argParser.addOption('package-name');
  argParser.addOption('package-path');
  argParser.addOption('library-name');
  argParser.addOption('element-name');
  final ArgResults args = argParser.parse(argList);
  // Normalize the filenames, since they include random
  // and system-specific components, but make sure they
  // match the patterns we expect.
  RegExp inputFileRegExp =
      RegExp(r'(--file=)?(.*)([/\\]dartdoc_tools_)([^/\\]+)([/\\]input_)(\d+)');
  RegExp packagePathRegExp =
      RegExp(r'(--package-path=)?(.+dartdoc.*[/\\]testing[/\\]test_package)');

  final Set<String> variableNames = Set<String>.from([
    'INPUT',
    'SOURCE_COLUMN',
    'SOURCE_PATH',
    'PACKAGE_NAME',
    'PACKAGE_PATH',
    'LIBRARY_NAME',
    'ELEMENT_NAME',
    'INVOCATION_INDEX',
    'PACKAGE_INVOCATION_INDEX',
  ]);
  Map<String, String> env = <String, String>{}..addAll(Platform.environment);
  env.removeWhere((String key, String value) => !variableNames.contains(key));
  env.updateAll(
      (key, value) => inputFileRegExp.hasMatch(value) ? '<INPUT_FILE>' : value);
  env.updateAll((key, value) =>
      packagePathRegExp.hasMatch(value) ? '<PACKAGE_PATH>' : value);
  print('Env: ${env}');

  List<String> normalized = argList.map((String arg) {
    if (inputFileRegExp.hasMatch(arg)) {
      return '--file=<INPUT_FILE>';
    } else if (packagePathRegExp.hasMatch(arg)) {
      return '--package-path=<PACKAGE_PATH>';
    } else {
      return arg;
    }
  }).toList();
  RegExp snapshotCacheRegExp =
      RegExp(r'.*[/\\]dartdoc_snapshot_cache_[^/\\]+[/\\]snapshot_0');
  RegExp snapshotFirstRegExp =
      RegExp(r'.*[/\\]testing[/\\]test_package[/\\]bin[/\\]drill.dart$');
  if (snapshotCacheRegExp.hasMatch(Platform.script.path)) {
    print('Script location is in snapshot cache.');
  } else if (snapshotFirstRegExp.hasMatch(Platform.script.path)) {
    print('Script location is in dartdoc tree.');
  } else {
    print('Script location is not recognized: ${Platform.script.path}');
  }
  print('Args: $normalized');
  if (args['file'] != null) {
    File file = File(args['file']);
    if (file.existsSync()) {
      List<String> lines = file.readAsLinesSync();
      for (String line in lines) {
        print('## `${line}`');
        if (args['html']) {
          print(
              '{@inject-html}<div class="title">Title</div>{@end-inject-html}');
        }
        print('\n$line Is not a [ToolUser].\n');
      }
    } else {
      exit(1);
    }
  }
  exit(0);
}
