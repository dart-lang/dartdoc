// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.
library dartdoc.utils;

final RegExp leadingWhiteSpace = RegExp(r'^([ \t]*)[^ ]');

Iterable<String> stripCommonWhitespace(String str) sync* {
  if (str.isEmpty) return;
  final lines = str.split('\n');
  int /*?*/ minimumSeen;

  for (final line in lines) {
    if (line.isNotEmpty) {
      final match = leadingWhiteSpace.firstMatch(line);
      if (match != null) {
        if (minimumSeen == null || match.group(1).length < minimumSeen) {
          minimumSeen = match.group(1).length;
        }
      }
    }
  }
  minimumSeen ??= 0;
  for (final line in lines) {
    if (line.length >= minimumSeen) {
      yield line.substring(minimumSeen);
    } else {
      yield '';
    }
  }
}

String stripComments(String str) {
  // TODO(parlough): Once we migrate to null safety, prohibit null here
  if (str == null) return null;
  if (str.isEmpty) return '';
  final buf = StringBuffer();

  if (str.startsWith('///')) {
    for (final line in stripCommonWhitespace(str)) {
      if (line.startsWith('/// ')) {
        buf.writeln(line.substring(4));
      } else if (line.startsWith('///')) {
        buf.writeln(line.substring(3));
      } else {
        buf.writeln(line);
      }
    }
  } else {
    var cStyle = false;
    if (str.startsWith('/**')) {
      str = str.substring(3);
      cStyle = true;
    }
    if (str.endsWith('*/')) {
      str = str.substring(0, str.length - 2);
    }
    for (final line in stripCommonWhitespace(str)) {
      if (cStyle && line.startsWith('* ')) {
        buf.writeln(line.substring(2));
      } else if (cStyle && line.startsWith('*')) {
        buf.writeln(line.substring(1));
      } else {
        buf.writeln(line);
      }
    }
  }
  return buf.toString().trim();
}

String truncateString(String str, int length) {
  if (str != null && str.length > length) {
    // Do not call this on unsanitized HTML.
    assert(!str.contains('<'));
    return '${str.substring(0, length)}…';
  }
  return str;
}

String pluralize(String word, int count) => count == 1 ? word : '${word}s';
