// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

final RegExp leadingWhiteSpace = RegExp(r'^([ \t]*)[^ ]');

/// Escapes text for a double-quoted HTML attribute value, such as `href="..."`.
///
/// Unlike [htmlEscape], this leaves `/` alone, keeping URLs readable.
const HtmlEscape htmlAttributeEscape = HtmlEscape(HtmlEscapeMode.attribute);

/// Characters which must never appear in a URL written into HTML: quotes,
/// angle brackets and backticks can terminate an attribute or a tag, and
/// whitespace and control characters are not valid in a URL.
final RegExp _unsafeUrlCharacters = RegExp(r'''["'<>`\s\x00-\x1f\x7f]''');

/// Whether [url] is an `http(s)` URL which can be written into an `href`
/// attribute as is.
///
/// Requiring an `http(s)` scheme with a host rules out relative URLs and
/// non-web schemes such as `javascript:`; rejecting [_unsafeUrlCharacters]
/// rules out values which would break out of the attribute, which
/// `Uri.tryParse` does not catch.
bool isSafeHttpUrl(String url) {
  final uri = Uri.tryParse(url);
  if (uri == null) return false;
  if (uri.scheme != 'http' && uri.scheme != 'https') return false;
  if (uri.host.isEmpty) return false;
  return !_unsafeUrlCharacters.hasMatch(url);
}

Iterable<String> stripCommonWhitespace(String str) sync* {
  if (str.isEmpty) return;
  final lines = str.split('\n');
  int? minimumSeen;

  for (final line in lines) {
    if (line.isNotEmpty) {
      final match = leadingWhiteSpace.firstMatch(line);
      if (match != null) {
        var groupLength = match.group(1)!.length;
        if (minimumSeen == null || groupLength < minimumSeen) {
          minimumSeen = groupLength;
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

/// Strips [str] of all comment delimiters.
String stripCommentDelimiters(String str) {
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
  if (str.length > length) {
    // Do not call this on unsanitized HTML.
    assert(!str.contains('<'));
    return '${str.substring(0, length)}…';
  }
  return str;
}

String pluralize(String word, int count) => count == 1 ? word : '${word}s';
