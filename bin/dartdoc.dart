// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.bin;

import 'dart:io';

import 'package:args/args.dart';
import 'package:dartdoc/dartdoc.dart';

const String NAME = 'dartdoc';

// Update when puspec version changes
const String VERSION = '0.0.1';

/// Analyzes Dart files and generates a representation of included libraries,
/// classes, and members. Uses the current directory to look for libraries.
void main(List<String> arguments) {
  var parser = _createArgsParser();
  var results = parser.parse(arguments);

  if (results['help']) {
    _printUsageAndExit(parser);
  }
  if (results['version']) {
    print('$NAME version: $VERSION');
    exit(0);
  }
  List<String> excludeLibraries =
      results['exclude'] == null ? [] : results['exclude'].split(',');
  String sdkLocation = results['dart-sdk'];
  if (sdkLocation == null) {
    _printUsageAndExit(parser);
  }

  String url = results['url'];
  var currentDir = Directory.current;
  new DartDoc(currentDir, sdkLocation, excludeLibraries, url).generateDocs();
}

/// Print help if we are passed the help option or invalid arguments.
void _printUsageAndExit(ArgParser parser) {
  print(parser.usage);
  print('Usage: dartdoc --dartsdk=sdkLocation [OPTIONS]');
  exit(0);
}

ArgParser _createArgsParser() {
  // TODO: more options to be added
  var parser = new ArgParser();
  parser.addOption('dart-sdk',
      help: 'the complete path to the dart sdk.');
  parser.addOption('exclude',
      help: 'a comma-separated list of library names to ignore');
  parser.addOption('url',
      help: 'the url where the docs will be hosted (used to generate the sitemap)');
  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'show command help');
  parser.addFlag('version',
      help: 'Display the version for $NAME', negatable: false);
  return parser;
}
