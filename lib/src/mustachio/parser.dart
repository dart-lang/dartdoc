// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';

/// A [Mustache](https://mustache.github.io/mustache.5.html) parser for use by a
/// generated Mustachio renderer.
class MustachioParser {
  /// The full content of a Mustache template (or Mustache partial).
  final String template;

  /// The length of the template, in code units.
  final int _templateLength;

  /// The index of the character currently being parsed.
  int _index = 0;

  MustachioParser(this.template) : _templateLength = template.length;

  /// Parses [template] into a sequence of [MustachioNode]s.
  ///
  /// In the returned nodes, no keys or partials have been resolved. There is
  /// no guarantee that any key will resolve to a value during rendering. There
  /// is no guarantee that any partial will resolve without errors during
  /// rendering. The type of any [Section] node is not known until rendering.
  List<MustachioNode> parse() {
    assert(_index == 0);
    var children = _parseBlock();
    return children;
  }

  /// Parses a block of Mustache template content starting at [_index].
  ///
  /// When an end tag is encountered:
  /// * if [sectionKey] is non-null, and the end tag matches [sectionKey], the
  ///   block is complete.
  /// * if [sectionKey] is non-null, and the end tag does not match
  ///   [sectionKey], the end tag is treated as plain text, not a tag.
  /// * if [sectionKey] is null, the end tag is treated as plain text, not a
  ///   tag.
  List<MustachioNode> _parseBlock({String /*?*/ sectionKey}) {
    var children = <MustachioNode>[];
    var textStartIndex = _index;

    void addTextNode(int startIndex, int endIndex) {
      if (endIndex > startIndex) {
        children.add(Text(template.substring(startIndex, endIndex)));
      }
    }

    while (true) {
      if (_nextAtEnd) {
        addTextNode(textStartIndex, _templateLength);
        break;
      }
      if (_thisChar == $lbrace && _nextChar == $lbrace) {
        var textEndIndex = _index;
        _index += 2;
        var result = _parseTag();
        if (result == _TagParseResult.endOfFile) {
          _index = textEndIndex + 1;
          continue;
        } else if (result == _TagParseResult.notTag) {
          _index = textEndIndex + 1;
          continue;
        } else if (result == _TagParseResult.commentTag) {
          addTextNode(textStartIndex, textEndIndex);
          textStartIndex = _index;
          continue;
        } else if (result.type == _TagParseResultType.parsedEndTag) {
          if (sectionKey != null && sectionKey == result.endTagKey) {
            addTextNode(textStartIndex, textEndIndex);
            break;
          } else {
            addTextNode(textStartIndex, _index);
            textStartIndex = _index;
            continue;
          }
        } else {
          addTextNode(textStartIndex, textEndIndex);
          children.add(result.node);
          textStartIndex = _index;
          continue;
        }
      }
      _index++;
    }

    return children;
  }

  /// Tries to parse a tag at [_index].
  ///
  /// [_index] should be at the character immediately following the open
  /// delimiter `{{`.
  _TagParseResult _parseTag() {
    _walkPastWhitespace();
    if (_atEnd) {
      return _TagParseResult.endOfFile;
    }
    var char = _thisChar;
    if (char == $hash) {
      _index++;
      return _parseSection(invert: false);
    } else if (char == $caret) {
      _index++;
      return _parseSection(invert: true);
    } else if (char == $slash) {
      _index++;
      return _parseEndSection();
    } else if (char == $gt) {
      _index++;
      return _parsePartial();
    } else if (char == $exclamation) {
      _index++;
      return _parseComment();
    } else {
      return _parseVariable();
    }
  }

  /// Tries to parse a comment tag at [_index].
  ///
  /// [_index] should be at the character immediately following the `!`
  /// character which opens a possible comment tag.
  _TagParseResult _parseComment() {
    while (true) {
      if (_nextAtEnd) {
        return _TagParseResult.endOfFile;
      }
      if (_thisChar == $rbrace && _nextChar == $rbrace) {
        break;
      }
      _index++;
    }

    _index += 2;
    return _TagParseResult.commentTag;
  }

  /// Tries to parse a partial tag at [_index].
  ///
  /// [_index] should be at the character immediately following the `>`
  /// character which opens a possible partial tag.
  _TagParseResult _parsePartial() {
    var startIndex = _index;
    int endIndex;
    while (true) {
      if (_nextAtEnd) {
        return _TagParseResult.endOfFile;
      }
      if (_thisChar == $space) {
        endIndex = _index;
        // Whitespace _must_ be at the end of the tag.
        _walkPastWhitespace();
        if (_thisChar == $rbrace && _nextChar == $rbrace) {
          break;
        } else {
          return _TagParseResult.notTag;
        }
      }
      if (_thisChar == $rbrace && _nextChar == $rbrace) {
        endIndex = _index;
        break;
      }
      _index++;
    }
    _index += 2;

    var key = template.substring(startIndex, endIndex);
    return _TagParseResult.ok(Partial(key));
  }

  /// Tries to parse a section tag at [_index].
  ///
  /// [_index] should be at the character immediately following the `#`
  /// character which opens a possible section tag.
  _TagParseResult _parseSection({@required invert}) {
    var result = _parseKey();
    if (result.type == _KeyParseResultType.notKey) {
      return _TagParseResult.notTag;
    } else if (result == _KeyParseResult.endOfFile) {
      return _TagParseResult.endOfFile;
    }

    var children = _parseBlock(sectionKey: result.joinedNames);

    return _TagParseResult.ok(Section(result.names, children, invert: invert));
  }

  /// Tries to parse an end tag at [_index].
  ///
  /// [_index] should be at the character immediately following the `/`
  /// character which opens a possible end tag.
  _TagParseResult _parseEndSection() {
    var result = _parseKey();
    if (result.type == _KeyParseResultType.notKey) {
      return _TagParseResult.notTag;
    } else if (result == _KeyParseResult.endOfFile) {
      return _TagParseResult.endOfFile;
    }

    return _TagParseResult.endTag(result.joinedNames);
  }

  /// Tries to parse a variable tag at [_index].
  ///
  /// [_index] should be at the character immediately following the `{{`
  /// characters which open a possible variable tag.
  _TagParseResult _parseVariable() {
    var escape = true;
    if (_thisChar == $lbrace) {
      escape = false;
      _index++;
      _walkPastWhitespace();
    }
    var result = _parseKey(escape: escape);
    if (result.type == _KeyParseResultType.notKey) {
      return _TagParseResult.notTag;
    } else if (result == _KeyParseResult.endOfFile) {
      return _TagParseResult.endOfFile;
    }

    return _TagParseResult.ok(Variable(result.names, escape: escape));
  }

  /// Tries to parse a key at [_index].
  ///
  /// [_index] should be at the first character which opens a possible key.
  _KeyParseResult _parseKey({bool escape = true}) {
    var startIndex = _index;
    while (true) {
      if (_atEnd) {
        return _KeyParseResult.endOfFile;
      }
      var char = _thisChar;
      if ((char >= $a && char <= $z) ||
          (char >= $A && char <= $Z) ||
          (char >= $0 && char <= $9) ||
          char == $underscore ||
          char == $dot ||
          char == $dollar) {
        _index++;
        continue;
      } else {
        break;
      }
    }

    if (_index == startIndex) {
      return _KeyParseResult.notKey;
    }

    var key = template.substring(startIndex, _index);

    if (key.length > 1 &&
        (key.codeUnitAt(0) == $dot || key.codeUnitAt(key.length - 1) == $dot)) {
      // A key cannot start or end with dot.
      return _KeyParseResult.notKey;
    }

    _walkPastWhitespace();
    if (_nextAtEnd) {
      return _KeyParseResult.endOfFile;
    }

    var char0 = _thisChar;
    var char1 = _nextChar;
    if (escape) {
      if (char0 == $rbrace && char1 == $rbrace) {
        _index += 2;
        return _KeyParseResult(_KeyParseResultType.parsedKey, key);
      } else {
        return _KeyParseResult.notKey;
      }
    } else {
      if (_nextNextAtEnd) {
        return _KeyParseResult.endOfFile;
      }
      // Need one more right brace.
      var char2 = _nextNextChar;
      if (char0 == $rbrace && char1 == $rbrace && char2 == $rbrace) {
        _index += 3;
        return _KeyParseResult(_KeyParseResultType.parsedKey, key);
      } else {
        return _KeyParseResult.notKey;
      }
    }
  }

  /// Walks past any whitespace characters.
  ///
  /// [_index] points to a non-whitespace character when this method returns.
  ///
  /// If EOF is reached, then [_index] points past the end of the template
  /// content when this method returns.
  void _walkPastWhitespace() {
    while (true) {
      if (_atEnd) {
        return;
      }
      if (_thisChar == $space ||
          _thisChar == $tab ||
          _thisChar == $lf ||
          _thisChar == $cr) {
        _index++;
        continue;
      } else {
        return;
      }
    }
  }

  bool get _atEnd => _index >= _templateLength;

  bool get _nextAtEnd => _index + 1 >= _templateLength;

  bool get _nextNextAtEnd => _index + 2 >= _templateLength;

  int get _thisChar => template.codeUnitAt(_index);

  int get _nextChar => template.codeUnitAt(_index + 1);

  int get _nextNextChar => template.codeUnitAt(_index + 2);
}

/// An interface for various types of node in a Mustache template.
@sealed
abstract class MustachioNode {}

/// A Text node, representing literal text.
@immutable
class Text implements MustachioNode {
  final String content;

  Text(this.content);

  @override
  String toString() => 'Text["$content"]';
}

/// A Variable node, representing a variable to be resolved.
@immutable
class Variable implements MustachioNode {
  final List<String> key;

  final bool escape;

  Variable(this.key, {@required this.escape});

  @override
  String toString() => 'Variable[$key, escape=$escape]';
}

/// A Section node, representing either a Conditional Section, a Repeated
/// Section, or a Value Section, possibly inverted.
@immutable
class Section implements MustachioNode {
  final List<String> key;

  final bool invert;

  final List<MustachioNode> children;

  Section(this.key, this.children, {@required this.invert});

  @override
  String toString() => 'Section[$key, invert=$invert]';
}

/// A Partial node, representing a partial to be resolved.
@immutable
class Partial implements MustachioNode {
  final String key;

  Partial(this.key);
}

/// An enumeration of types of tag parse results.
enum _TagParseResultType {
  commentTag,
  endOfFile,
  notTag,
  parsedTag,
  parsedEndTag,
}

/// The result of attempting to parse a Mustache tag.
class _TagParseResult {
  final _TagParseResultType type;

  /// The parsed Mustache node, if parsing was successful.
  ///
  /// This field is `null` if EOF was reached, or if a tag was not parsed
  /// (perhaps it started out like a tag, but was malformed, and so is read as
  /// text).
  final MustachioNode /*?*/ node;

  /// The key of an end tag, if an end tag was parsed.
  final String /*?*/ endTagKey;

  _TagParseResult(this.type, this.node, this.endTagKey);

  _TagParseResult.ok(this.node)
      : type = _TagParseResultType.parsedTag,
        endTagKey = null;

  _TagParseResult.endTag(this.endTagKey)
      : type = _TagParseResultType.parsedEndTag,
        node = null;

  /// A [_TagParseResult] representing that EOF was reached, without parsing a
  /// tag.
  static _TagParseResult endOfFile =
      _TagParseResult(_TagParseResultType.endOfFile, null, null);

  /// A [_TagParseResult] representing that a tag was not parsed.
  static _TagParseResult notTag =
      _TagParseResult(_TagParseResultType.notTag, null, null);

  /// A [_TagParseResult] representing that a comment tag was parsed.
  static _TagParseResult commentTag =
      _TagParseResult(_TagParseResultType.commentTag, null, null);
}

/// An enumeration of types of key parse results.
enum _KeyParseResultType {
  parsedKey,
  notKey,
  endOfFile,
}

/// The result of attempting to parse a Mustache key.
class _KeyParseResult {
  final _KeyParseResultType type;

  final List<String> names;

  _KeyParseResult._(this.type, this.names);

  factory _KeyParseResult(_KeyParseResultType type, String key) {
    if (key == '.') {
      return _KeyParseResult._(type, [key]);
    } else {
      return _KeyParseResult._(type, key.split('.'));
    }
  }

  /// A [_KeyParseResult] representing that EOF was reached, without parsing a
  /// key.
  static _KeyParseResult endOfFile =
      _KeyParseResult._(_KeyParseResultType.endOfFile, null);

  /// A [_KeyParseResult] representing that a key was not parsed.
  static _KeyParseResult notKey =
      _KeyParseResult._(_KeyParseResultType.notKey, null);

  /// The reconstituted key, with periods separating names.
  String get joinedNames => names.join('.');

  String get lastName => names.last;
}
