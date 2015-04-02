// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.package_utils;

import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

String getPackageName(String directoryName) =>
    _getPubspec(directoryName)['name'];

Map _getPubspec(String directoryName) {
  var pubspecName = path.join(directoryName, 'pubspec.yaml');
  File pubspec = new File(pubspecName);
  if (!pubspec.existsSync()) return {'name': ''};
  var contents = pubspec.readAsStringSync();
  return loadYaml(contents);
}

String getPackageDescription(String directoryName) {
  var dir = new Directory(directoryName);
  var readmeFile = dir.listSync().firstWhere((FileSystemEntity file) =>
      path.basename(file.path).toLowerCase().startsWith("readme"), orElse: () => null);
  if (readmeFile != null && readmeFile.existsSync()) {
    // TODO(keertip): cleanup the contents
    return readmeFile.readAsStringSync();
  }
  return '';
}

String getPackageVersion(String directoryName) =>
    _getPubspec(directoryName)['version'];

const String SDK_INTRO = """
Welcome to the Dart API reference documentation,
covering the official Dart API libraries.
Some of the most fundamental Dart libraries include:

* [dart:core]:
  Core functionality such as strings, numbers, collections, errors,
  dates, and URIs.
* [dart:html]:
  DOM manipulation for web apps.
* [dart:io]:
  I/O for command-line apps.

Except for dart:core, you must import a library before you can use it.
Here's an example of importing dart:html, dart:math, and a
third popular library called
[polymer.dart](http://www.dartlang.org/polymer-dart/):

    import 'dart:html';
    import 'dart:math';
    import 'package:polymer/polymer.dart';

Polymer.dart is an example of a library that isn't
included in the Dart download,
but is easy to get and update using the _pub package manager_.
For information on finding, using, and publishing libraries (and more)
with pub, see
[pub.dartlang.org](http://pub.dartlang.org).

The main site for learning and using Dart is
[www.dartlang.org](http://www.dartlang.org).
Check out these pages:

  * [Dart homepage](http://www.dartlang.org)
  * [Tutorials](http://www.dartlang.org/docs/tutorials/)
  * [Programmer's Guide](http://www.dartlang.org/docs/)
  * [Samples](http://www.dartlang.org/samples/)
  * [A Tour of the Dart Libraries](http://www.dartlang.org/docs/dart-up-and-running/contents/ch03.html)

This API reference is automatically generated from the source code in the
[Dart project](https://code.google.com/p/dart/).
If you'd like to contribute to this documentation, see
[Contributing](https://code.google.com/p/dart/wiki/Contributing)
and
[Writing API Documentation](https://code.google.com/p/dart/wiki/WritingApiDocumentation).
""";
