// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.


library dartdoc;

import 'dart:io';

/**
 * Generates Dart documentation for all public Dart libraries in the given
 * directory.
 */
class DartDoc {

  List<String> _excludes;
  Directory _rootDir;


  DartDoc(this._rootDir,this._excludes);

  /**
   * Generate the documentation
   */
  void generate() {
    print("TODO: impelement doc generation");
  }

}

