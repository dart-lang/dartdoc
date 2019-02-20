// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.cache;

import 'dart:collection';
import 'dart:io';

import 'package:dartdoc/src/tuple.dart';
import 'package:path/path.dart' as pathLib;

String _getNewlineChar(String contents) {
  if (contents.contains("\r\n")) {
    return "\r\n";
  } else if (contents.contains("\r")) {
    return "\r";
  } else {
    return "\n";
  }
}

SplayTreeMap<int, int> _createLineNumbersMap(String contents) {
  var newlineChar = _getNewlineChar(contents);
  var offset = 0;
  var lineNumber = 1;
  var result = new SplayTreeMap<int, int>();

  do {
    result[offset] = lineNumber;
    offset = (offset + 1 <= contents.length) ? contents.indexOf(newlineChar, offset + 1) : -1;
    lineNumber += 1;
  } while (offset != -1);

  return result;
}

final LineNumberCache lineNumberCache = new LineNumberCache();

class LineNumberCache {
  final Map<String, SplayTreeMap<int, int>> _lineNumbers =
      <String, SplayTreeMap<int, int>>{};

  Tuple2<int, int> lineAndColumn(String file, int offset) {
    file = pathLib.canonicalize(file);
    var lineMap = _lineNumbers.putIfAbsent(
        file, () => _createLineNumbersMap(new File(file).readAsStringSync()));
    var lastKey = lineMap.lastKeyBefore(offset);
    if (lastKey != null) {
      return new Tuple2(lineMap[lastKey], offset - lastKey);
    } else {
      return new Tuple2(lineMap[0], offset - 0);
    }
  }
}
