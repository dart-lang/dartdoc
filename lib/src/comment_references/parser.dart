// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';

import '../charcode.dart';

const _operatorKeyword = 'operator';
const Map<String, String> operatorNames = {
  '[]': 'get',
  '[]=': 'put',
  '~': 'bitwise_negate',
  '==': 'equals',
  '-': 'minus',
  '+': 'plus',
  '*': 'multiply',
  '/': 'divide',
  '<': 'less',
  '>': 'greater',
  '>=': 'greater_equal',
  '<=': 'less_equal',
  '<<': 'shift_left',
  '>>': 'shift_right',
  '>>>': 'triple_shift',
  '^': 'bitwise_exclusive_or',
  'unary-': 'unary_minus',
  '|': 'bitwise_or',
  '&': 'bitwise_and',
  '~/': 'truncate_divide',
  '%': 'modulo'
};

class StringTrie {
  final Map<int, StringTrie> children = {};

  /// Does [this] node represent a valid entry in the trie?
  bool valid = false;

  /// Greedily match on the string trie starting at the given index.  Returns
  /// the index of the first non-operator character if a match is valid,
  /// otherwise -1.
  int match(String toMatch, [int index = 0, int lastValid = -1]) {
    if (index < 0 || index > toMatch.length) {
      return lastValid;
    }
    if (index == toMatch.length) {
      return valid ? index : lastValid;
    }
    var matchChar = toMatch.codeUnitAt(index);
    var matchedChild = children[matchChar];
    if (matchedChild != null) {
      lastValid = valid ? index : lastValid;
      return matchedChild.match(toMatch, index + 1, lastValid);
    }
    return valid ? index : lastValid;
  }

  void addWord(String toAdd) {
    var currentTrie = this;
    for (var i in toAdd.codeUnits) {
      currentTrie.children.putIfAbsent(i, StringTrie.new);
      currentTrie = currentTrie.children[i]!;
    }
    currentTrie.valid = true;
  }
}

final StringTrie operatorParseTrie = () {
  var operatorParseTrie = StringTrie();
  for (var name in operatorNames.keys) {
    operatorParseTrie.addWord(name);
  }
  return operatorParseTrie;
}();

/// A parser for comment references.
// TODO(jcollins-g): align with [CommentReference] from analyzer AST.
class CommentReferenceParser {
  /// Original, unparsed reference.
  final String codeRef;

  final int _referenceLength;

  CommentReferenceParser(this.codeRef) : _referenceLength = codeRef.length;

  int _index = 0;

  List<CommentReferenceNode> parse() {
    assert(_index == 0);
    var children = _parseRawCommentReference();
    return children;
  }

  ///
  /// Parser for rawCommentReferences.  Does not at present distinguish
  /// between package/library names and identifiers.
  ///
  /// ```text
  ///   <rawCommentReference> ::= <prefix>?<commentReference><suffix>?
  ///
  ///   <commentReference> ::= (<packageName> '.')? (<libraryName> '.')? <dartdocIdentifier> <typeArguments> ('.' <identifier> <typeArguments>)*
  /// ```
  List<CommentReferenceNode> _parseRawCommentReference() {
    var children = <CommentReferenceNode>[];

    // <prefix>?
    var prefixResult = _parsePrefix();
    if (prefixResult.type == _PrefixResultType.endOfFile) {
      return [];
    }
    if (prefixResult.type == _PrefixResultType.parsedConstructorHint) {
      children.add(prefixResult.node!);
    }
    // [_PrefixResultType.junk] and [_PrefixResultType.missing] we can skip.

    // <commentReference>
    while (!_atEnd) {
      var savedIndex = _index;
      var identifierResult = _parseIdentifier();
      if (identifierResult.type == _IdentifierResultType.endOfFile) {
        break;
      } else if (identifierResult.type == _IdentifierResultType.notIdentifier) {
        // Push the '.' back.
        _index = savedIndex;
        break;
      } else if (identifierResult.type ==
          _IdentifierResultType.parsedIdentifier) {
        children.add(identifierResult.node!);
        var typeVariablesResult = _parseTypeVariables();
        if (typeVariablesResult.type == _TypeVariablesResultType.endOfFile) {
          break;
        } else if (typeVariablesResult.type ==
            _TypeVariablesResultType.parsedTypeVariables) {
          children.add(typeVariablesResult.node!);
        } else {
          assert(typeVariablesResult.type ==
              _TypeVariablesResultType.notTypeVariables);
        }
      }
      if (_atEnd || _thisChar != $dot) {
        break;
      }
      _index++;
    }

    // <suffix>?
    var suffixResult = _parseSuffix();
    if (suffixResult.type == _SuffixResultType.notSuffix) {
      // Invalid trailing junk; reject the reference.
      return [];
    } else if (suffixResult.type == _SuffixResultType.parsedCallableHint) {
      children.add(suffixResult.node!);
    }

    // [_SuffixResultType.junk] or [_SuffixResultType.missing] we can skip.
    return children;
  }

  static const _constructorHintPrefix = 'new';
  static const _ignorePrefixes = ['const', 'final', 'var'];

  /// Implement parsing a prefix to a comment reference.
  ///
  /// ```text
  /// <prefix> ::= <constructorPrefixHint>
  ///    | <leadingJunk>
  ///
  /// <constructorPrefixHint> ::= 'new '
  ///
  /// <leadingJunk> ::= ('const' | 'final' | 'var')(' '+)
  /// ```
  _PrefixParseResult _parsePrefix() {
    if (_atEnd) {
      return _PrefixParseResult.endOfFile;
    }
    _walkPastWhitespace();
    if (_tryMatchLiteral(_constructorHintPrefix,
        requireTrailingNonidentifier: true)) {
      return _PrefixParseResult.ok(
          ConstructorHintStartNode(_constructorHintPrefix));
    }
    if (_ignorePrefixes
        .any((p) => _tryMatchLiteral(p, requireTrailingNonidentifier: true))) {
      return _PrefixParseResult.junk;
    }

    /// There is something else here that doesn't look like a prefix.
    return _PrefixParseResult.missing;
  }

  static const _whitespace = {$space, $tab, $lf, $cr};
  static const _nonIdentifierChars = {
    $dot,
    $gt,
    $lparen,
    $lt,
    $rparen,
    $backslash,
    $question,
    $exclamation,
    ..._whitespace,
  };

  /// Advances the index forward to the end of the operator if one is
  /// present and returns the operator's name.  Otherwise, leaves _index
  /// unchanged and returns null.
  String? _tryParseOperator() {
    var tryIndex = _index;
    if (tryIndex + _operatorKeyword.length < codeRef.length &&
        codeRef.substring(tryIndex, tryIndex + _operatorKeyword.length) ==
            _operatorKeyword) {
      tryIndex = tryIndex + _operatorKeyword.length;
      while (_whitespace.contains(codeRef.codeUnitAt(tryIndex))) {
        tryIndex++;
      }
    }

    var result = operatorParseTrie.match(codeRef, tryIndex);
    if (result == -1) {
      return null;
    }
    _index = result;
    return codeRef.substring(tryIndex, result);
  }

  /// Parse a dartdoc identifier.
  ///
  /// Dartdoc identifiers can include some operators.
  _IdentifierParseResult _parseIdentifier() {
    if (_atEnd) {
      return _IdentifierParseResult.endOfFile;
    }
    var startIndex = _index;

    var foundOperator = _tryParseOperator();
    if (foundOperator != null) {
      return _IdentifierParseResult.ok(IdentifierNode(foundOperator));
    }

    while (!_atEnd) {
      if (_nonIdentifierChars.contains(_thisChar)) {
        if (startIndex == _index) {
          return _IdentifierParseResult.notIdentifier;
        } else {
          break;
        }
      }
      _index++;
    }
    return _IdentifierParseResult.ok(
        IdentifierNode(codeRef.substring(startIndex, _index)));
  }

  /// Parse a list of type variables (arguments or parameters).
  ///
  /// Dartdoc isolates these where present and potentially valid, but we don't
  /// break them down.
  _TypeVariablesParseResult _parseTypeVariables() {
    if (_atEnd) {
      return _TypeVariablesParseResult.endOfFile;
    }
    var startIndex = _index;
    if (_matchBraces($lt, $gt)) {
      return _TypeVariablesParseResult.ok(
          TypeVariablesNode(codeRef.substring(startIndex + 1, _index - 1)));
    }
    return _TypeVariablesParseResult.notIdentifier;
  }

  static const _callableHintSuffix = '()';

  /// ```text
  /// <suffix> ::= <callableHintSuffix>
  ///   | <trailingJunk>
  ///
  /// <trailingJunk> ::= '<'<CHARACTER>*'>'
  ///   | '('<notClosedParenthesis>*')'
  ///   | '<'<notGreaterThan>*'>'
  ///   | '?'
  ///   | '!'
  ///
  /// <callableHintSuffix> ::= '()'
  /// ```
  _SuffixParseResult _parseSuffix() {
    var startIndex = _index;
    _walkPastWhitespace();
    if (_atEnd) {
      return _SuffixParseResult.missing;
    }
    if (_tryMatchLiteral(_callableHintSuffix)) {
      if (_atEnd) {
        return _SuffixParseResult.ok(
            CallableHintEndNode(codeRef.substring(startIndex, _index)));
      }
      return _SuffixParseResult.notSuffix;
    }

    if ((_thisChar == $exclamation || _thisChar == $question) && _nextAtEnd) {
      return _SuffixParseResult.junk;
    }
    if (_matchBraces($lparen, $rparen)) {
      return _SuffixParseResult.junk;
    }

    return _SuffixParseResult.notSuffix;
  }

  bool get _atEnd => _index >= _referenceLength;
  bool get _nextAtEnd => _index + 1 >= _referenceLength;
  int get _thisChar => codeRef.codeUnitAt(_index);

  /// Advances [_index] on match, preserves on non-match.
  bool _tryMatchLiteral(String characters,
      {bool acceptTrailingWhitespace = true,
      bool requireTrailingNonidentifier = false}) {
    if (characters.length + _index > _referenceLength) return false;
    int startIndex;
    for (startIndex = _index;
        _index - startIndex < characters.length;
        _index++) {
      if (codeRef.codeUnitAt(_index) !=
          characters.codeUnitAt(_index - startIndex)) {
        _index = startIndex;
        return false;
      }
    }
    if (requireTrailingNonidentifier) {
      if (_atEnd || !_nonIdentifierChars.contains(_thisChar)) {
        _index = startIndex;
        return false;
      }
    }
    if (acceptTrailingWhitespace) _walkPastWhitespace();
    return true;
  }

  /// Walks past any whitespace characters.
  ///
  /// [_index] points to a non-whitespace character when this method returns.
  ///
  /// If EOF is reached, then [_index] points past the end of the template
  /// content when this method returns.
  void _walkPastWhitespace() {
    while (!_atEnd) {
      if (_whitespace.contains(_thisChar)) {
        _index++;
      } else {
        return;
      }
    }
    return;
  }

  /// Returns `true` if we started with [startChar] and ended with [endChar]
  /// with a matching number of braces.
  /// Restores [_index] to state when called if returning `false`.
  bool _matchBraces(int startChar, int endChar) {
    var braceCount = 0;
    if (_thisChar != startChar) return false;
    var startIndex = _index;
    while (!_atEnd) {
      if (_thisChar == startChar) braceCount++;
      if (_thisChar == endChar) braceCount--;
      _index++;
      if (braceCount == 0) {
        return true;
      }
    }
    _index = startIndex;
    return false;
  }
}

enum _PrefixResultType {
  endOfFile, // Found end of file instead of a prefix.
  junk, // Found some recognized junk that can be ignored.
  missing, // There is no prefix here.
  parsedConstructorHint, // Parsed a [ConstructorHintStartNode].
}

/// The result of attempting to parse a prefix to a comment reference.
class _PrefixParseResult {
  final _PrefixResultType type;

  final CommentReferenceNode? node;

  const _PrefixParseResult._(this.type, this.node);

  factory _PrefixParseResult.ok(ConstructorHintStartNode node) =>
      _PrefixParseResult._(_PrefixResultType.parsedConstructorHint, node);

  static const _PrefixParseResult endOfFile =
      _PrefixParseResult._(_PrefixResultType.endOfFile, null);

  static const _PrefixParseResult junk =
      _PrefixParseResult._(_PrefixResultType.junk, null);

  static const _PrefixParseResult missing =
      _PrefixParseResult._(_PrefixResultType.missing, null);
}

enum _IdentifierResultType {
  endOfFile, // Found end of file instead of the beginning of an identifier.
  notIdentifier, // This is not an identifier.
  parsedIdentifier, // Found an identifier.
}

/// The result of attempting to parse a single identifier within a
/// comment reference.
class _IdentifierParseResult {
  final _IdentifierResultType type;

  final IdentifierNode? node;

  const _IdentifierParseResult._(this.type, this.node);

  factory _IdentifierParseResult.ok(IdentifierNode node) =>
      _IdentifierParseResult._(_IdentifierResultType.parsedIdentifier, node);

  static const _IdentifierParseResult endOfFile =
      _IdentifierParseResult._(_IdentifierResultType.endOfFile, null);

  static const _IdentifierParseResult notIdentifier =
      _IdentifierParseResult._(_IdentifierResultType.notIdentifier, null);
}

enum _TypeVariablesResultType {
  endOfFile, // Found end of file instead of the beginning of a list of type
  // variables.
  notTypeVariables, // Found something, but it isn't type variables.
  parsedTypeVariables, // Found type variables.
}

class _TypeVariablesParseResult {
  final _TypeVariablesResultType type;

  final TypeVariablesNode? node;

  const _TypeVariablesParseResult._(this.type, this.node);

  factory _TypeVariablesParseResult.ok(TypeVariablesNode node) =>
      _TypeVariablesParseResult._(
          _TypeVariablesResultType.parsedTypeVariables, node);

  static const _TypeVariablesParseResult endOfFile =
      _TypeVariablesParseResult._(_TypeVariablesResultType.endOfFile, null);

  static const _TypeVariablesParseResult notIdentifier =
      _TypeVariablesParseResult._(
          _TypeVariablesResultType.notTypeVariables, null);
}

enum _SuffixResultType {
  junk, // Found known types of junk it is OK to ignore.
  missing, // There is no suffix here.  Same as EOF as this is a suffix.
  notSuffix, // Found something, but not a valid suffix.
  parsedCallableHint, // Parsed a [CallableHintEndNode].
}

/// The result of attempting to parse a suffix to a comment reference.
class _SuffixParseResult {
  final _SuffixResultType type;

  final CommentReferenceNode? node;

  const _SuffixParseResult._(this.type, this.node);

  factory _SuffixParseResult.ok(CommentReferenceNode node) =>
      _SuffixParseResult._(_SuffixResultType.parsedCallableHint, node);

  static const _SuffixParseResult junk =
      _SuffixParseResult._(_SuffixResultType.junk, null);

  static const _SuffixParseResult missing =
      _SuffixParseResult._(_SuffixResultType.missing, null);

  static const _SuffixParseResult notSuffix =
      _SuffixParseResult._(_SuffixResultType.notSuffix, null);
}

@sealed
// TODO(jcollins-g): add SourceSpans?
abstract class CommentReferenceNode {
  String get text;
}

class ConstructorHintStartNode extends CommentReferenceNode {
  @override
  final String text;

  ConstructorHintStartNode(this.text);

  @override
  String toString() => 'ConstructorHintStartNode["$text"]';
}

class CallableHintEndNode extends CommentReferenceNode {
  @override
  final String text;

  CallableHintEndNode(this.text);

  @override
  String toString() => 'CallableHintEndNode["$text"]';
}

/// Represents an identifier.
class IdentifierNode extends CommentReferenceNode {
  @override
  final String text;

  IdentifierNode(this.text);

  @override
  String toString() => 'Identifier["$text"]';
}

/// Represents one or more type variables, may be
/// comma separated.
class TypeVariablesNode extends CommentReferenceNode {
  @override

  /// Note that this will contain commas, spaces, and other text, as
  /// generally type variables are a form of junk that comment references
  /// should ignore.
  final String text;

  TypeVariablesNode(this.text);

  @override
  String toString() => 'TypeVariablesNode["$text"]';
}
