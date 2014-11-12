// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:args/args.dart';

import 'package:dartdoc/dartdoc.dart';


/**
 * Analyzes Dart files and generates a representation of included libraries,
 * classes, and members. Uses the current directory to look for libraries.
 */
void main(List<String> arguments) {
  ArgParser parser = _createArgsParser();
  ArgResults results = parser.parse(arguments);

  if (results['help']) {
    _printUsageAndExit(parser);
  }
  List<String> excludeLibraries = results['exclude'] == null ?
         [] : results['exclude'].split(',');

  Directory currentDir = Directory.current;

  new DartDoc(currentDir, excludeLibraries).generate();
}

/**
 * Print help if we are passed the help option or invalid arguments.
 */
void _printUsageAndExit(ArgParser parser) {
  print(parser.usage);
  print('Usage: dartdoc [OPTIONS]');
  exit(0);
}


 ArgParser _createArgsParser() {
   // TODO: more options to be added
    ArgParser parser = new ArgParser();
    parser.addOption(
        'exclude',
        help: 'a comma-separated list of library names to ignore');
    parser.addFlag('help',
        abbr: 'h',
        negatable: false,
        help: 'show command help');
    return parser;
  }
