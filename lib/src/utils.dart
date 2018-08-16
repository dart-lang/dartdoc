// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library dartdoc.utils;

final RegExp leadingWhiteSpace = new RegExp(r'^([ \t]*)[^ ]');

String stripCommonWhitespace(String str) {
  StringBuffer buf = new StringBuffer();
  List<String> lines = str.split('\n');
  int minimumSeen;

  for (String line in lines) {
    if (line.isNotEmpty) {
      Match m = leadingWhiteSpace.firstMatch(line);
      if (m != null) {
        if (minimumSeen == null || m.group(1).length < minimumSeen) {
          minimumSeen = m.group(1).length;
        }
      }
    }
  }
  minimumSeen ??= 0;
  int lineno = 1;
  for (String line in lines) {
    if (line.length >= minimumSeen) {
      buf.write('${line.substring(minimumSeen)}\n');
    } else {
      if (lineno < lines.length) {
        buf.write('\n');
      }
    }
    ++lineno;
  }
  return buf.toString();
}

String stripComments(String str) {
  bool cStyle = false;
  if (str == null) return null;
  StringBuffer buf = new StringBuffer();

  if (str.startsWith('///')) {
    str = stripCommonWhitespace(str);
    for (String line in str.split('\n')) {
      if (line.startsWith('/// ')) {
        buf.write('${line.substring(4)}\n');
      } else if (line.startsWith('///')) {
        buf.write('${line.substring(3)}\n');
      } else {
        buf.write('$line\n');
      }
    }
  } else {
    if (str.startsWith('/**')) {
      str = str.substring(3);
      cStyle = true;
    }
    if (str.endsWith('*/')) {
      str = str.substring(0, str.length - 2);
    }
    str = stripCommonWhitespace(str);
    for (String line in str.split('\n')) {
      if (cStyle && line.startsWith('* ')) {
        buf.write('${line.substring(2)}\n');
      } else if (cStyle && line.startsWith('*')) {
        buf.write('${line.substring(1)}\n');
      } else {
        buf.write('$line\n');
      }
    }
  }
  return buf.toString().trim();
}

String truncateString(String str, int length) {
  if (str != null && str.length > length) {
    // Do not call this on unsanitized HTML.
    assert(!str.contains("<"));
    return '${str.substring(0, length)}…';
  }
  return str;
}

String pluralize(String word, int count) => count == 1 ? word : '${word}s';
