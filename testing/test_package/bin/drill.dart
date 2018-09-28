// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// Used by tests as an "external tool". Has no other useful purpose.

// This is a sample "tool" used to test external tool integration into dartdoc.
// It has no practical purpose other than that.

import 'dart:io';
import 'package:args/args.dart';

void main(List<String> argList) {
  final ArgParser argParser = ArgParser();
  argParser.addOption('file');
  argParser.addOption('special');
  final ArgResults args = argParser.parse(argList);

  // Normalize the filename, since it includes random
  // and system-specific components, but make sure it
  // matches the pattern we expect.
  RegExp filenameRegExp = new RegExp(
      r'(--file=)(.*)([/\\]dartdoc_tools_)([^/\\]+)([/\\]input_)(\d+)');
  List<String> normalized = argList.map((String arg) {
    if (filenameRegExp.hasMatch(arg)) {
      return '--file=<INPUT_FILE>';
    } else {
      return arg;
    }
  }).toList();
  print('Args: $normalized');
  if (args['file'] != null) {
    File file = new File(args['file']);
    if (file.existsSync()) {
      List<String> lines = file.readAsLinesSync();
      for (String line in lines) {
        print('## `${line}`');
        print('\n$line Is not a [ToolUser].\n');
      }
    } else {
      exit(1);
    }
  }
  exit(0);
}
