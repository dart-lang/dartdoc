// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.html_utils;

import 'dart:convert';

String htmlEscape(String text) => HTML_ESCAPE.convert(text);

String getHtmlFileNameFor(String name) {
  // dart.dartdoc => dart_dartdoc
  // dart:core => dart_core
  return '${name.replaceAll('.', '_').replaceAll(':', '_')}.html';
}

String escapeBrackets(String text) {
  return text.replaceAll('>', '_').replaceAll('<', '_');
}

String stringEscape(String text, String quoteType) {
  return text
      .replaceAll('\\', r'\\')
      .replaceAll(quoteType, "\\${quoteType}")
      .replaceAllMapped(_escapeRegExp, (m) {
    return _escapMap[m.input];
  });
}


String stripComments(String str) {
  if (str == null) return null;

  StringBuffer buf = new StringBuffer();

  if (str.startsWith('///')) {
    for (String line in str.split('\n')) {
      if (line.startsWith('/// ')) {
        buf.write('${line.substring(4)}\n');
      } else if (line.startsWith('///')) {
        buf.write('${line.substring(3)}\n');
      } else {
        buf.write('${line}\n');
      }
    }
  } else {
    if (str.startsWith('/**')) {
      str = str.substring(3);
    }
    if (str.endsWith('*/')) {
      str = str.substring(0, str.length - 2);
    }
    str = str.trim();
    for (String line in str.split('\n')) {
      line = ltrim(line);
      if (line.startsWith('* ')) {
        buf.write('${line.substring(2)}\n');
      } else if (line.startsWith('*')) {
        buf.write('${line.substring(1)}\n');
      } else {
        buf.write('$line\n');
      }
    }
  }
  return buf.toString().trim();
}

String ltrim(String str) {
  while (str.length > 0 && (str[0] == ' ' || str[0] == '\t')) {
    str = str.substring(1);
  }
  return str;
}

String replaceAll(String str, List<String> matchChars,
    {String htmlEntity, var replaceFunction}) {
  int lastWritten = 0;
  int index = str.indexOf(matchChars[0]);
  StringBuffer buf = new StringBuffer();

  while (index != -1) {
    int end = str.indexOf(matchChars[1], index + 1);
    if (end != -1) {
      if (index - lastWritten > 0) {
        buf.write(str.substring(lastWritten, index));
      }
      String codeRef = str.substring(index + matchChars[0].length, end);
      if (htmlEntity != null) {
        buf.write('<$htmlEntity>$codeRef</$htmlEntity>');
      } else {
        buf.write(replaceFunction(codeRef));
      }
      lastWritten = end + matchChars[1].length;
    } else {
      break;
    }
    index = str.indexOf(matchChars[0], end + 1);
  }
  if (lastWritten < str.length) {
    buf.write(str.substring(lastWritten, str.length));
  }
  return buf.toString();
}

const _escapMap = const {
  '\n': r'\n',
  '\r': r'\r',
  '\f': r'\f',
  '\b': r'\b',
  '\t': r'\t',
  '\v': r'\v',
};

final _escapeStr = "[" + _escapMap.keys.map(_getHexLiteral).join() + "]";

final _escapeRegExp = new RegExp(_escapeStr);

String _getHexLiteral(String input) {
  int rune = input.runes.single;
  return r'\x' + rune.toRadixString(16).padLeft(2, '0');
}
