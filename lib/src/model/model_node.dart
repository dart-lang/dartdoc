// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:analyzer/dart/analysis/analysis_context.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/source_range.dart';
import 'package:meta/meta.dart';

/// Stripped down information derived from [AstNode] containing only information
/// needed to resurrect the source code of [_element].
class ModelNode {
  final Element _element;
  final AnalysisContext _analysisContext;
  final int _sourceEnd;
  final int _sourceOffset;

  /// Data about the doc comment of this node.
  final CommentData? commentData;

  factory ModelNode(
    AstNode sourceNode,
    Element element,
    AnalysisContext analysisContext, {
    Comment? comment,
  }) {
    var commentData = comment?.data;
    // Get a node higher up the syntax tree that includes the semicolon.
    // In this case, it is either a [FieldDeclaration] or
    // [TopLevelVariableDeclaration]. (#2401)
    if (sourceNode is VariableDeclaration) {
      sourceNode = sourceNode.parent!.parent!;
      assert(sourceNode is FieldDeclaration ||
          sourceNode is TopLevelVariableDeclaration);
    }
    return ModelNode._(
      element,
      analysisContext,
      sourceEnd: sourceNode.end,
      sourceOffset: sourceNode.offset,
      commentData: commentData,
    );
  }

  ModelNode._(
    this._element,
    this._analysisContext, {
    required int sourceEnd,
    required int sourceOffset,
    this.commentData,
  })  : _sourceEnd = sourceEnd,
        _sourceOffset = sourceOffset;

  bool get _isSynthetic => _sourceEnd < 0 || _sourceOffset < 0;

  /// The text of the source code of this node, stripped of the leading
  /// indentation, and stripped of the doc comments.
  late final String sourceCode = () {
    if (_isSynthetic) return '';

    var path = _element.firstFragment.libraryFragment?.source.fullName;
    if (path == null) return '';

    var fileResult = _analysisContext.currentSession.getFile(path);
    if (fileResult is! FileResult) return '';

    return fileResult.content
        .substringFromLineStart(_sourceOffset, _sourceEnd)
        .stripIndent
        .stripDocComments
        .trim();
  }();
}

/// Comment data from the syntax tree.
///
/// Various comment data is not available on the analyzer's Element model, so we
/// store it in instances of this class after resolving libraries.
class CommentData {
  /// The source ranges of this comment's tokens.
  final List<SourceRange> sourceRanges;

  /// The source ranges of this comment's doc-imports.
  final List<SourceRange> docImportSourceRanges;

  final Map<String, CommentReferenceData> references;

  CommentData({
    required this.sourceRanges,
    required this.docImportSourceRanges,
    required this.references,
  });
}

/// doc-import data from the syntax tree.
///
/// Comment doc-import data is not available on the analyzer's Element model, so
/// we store it in instances of this class after resolving libraries.
class CommentDocImportData {
  /// The offset of the doc import in the source text.
  final int offset;

  /// The offset of the end of the doc import in the source text.
  final int end;

  CommentDocImportData({required this.offset, required this.end});
}

/// Comment reference data from the syntax tree.
///
/// Comment reference data is not available on the analyzer's Element model, so
/// we store it in instances of this class after resolving libraries.
class CommentReferenceData {
  final Element element;
  final String name;
  final int offset;
  final int length;

  CommentReferenceData(this.element, String? name, this.offset, this.length)
      : name = name ?? '';
}

@visibleForTesting
extension SourceStringExtensions on String {
  String substringFromLineStart(int offset, int endOffset) {
    var lineStartOffset = startOfLineWithOffset(offset);
    return substring(lineStartOffset, endOffset);
  }

  // Finds the start of the line which contains the character at [offset].
  int startOfLineWithOffset(int offset) {
    var i = offset;
    // Walk backwards until we find the previous line's EOL character.
    while (i > 0) {
      i -= 1;
      if (this[i] == '\n' || this[i] == '\r') {
        i += 1;
        break;
      }
    }
    return i;
  }

  /// Strips leading doc comments from the given source code.
  String get stripDocComments {
    var remainder = trimLeft();
    var lineComments = remainder.startsWith(_tripleSlash) ||
        remainder.startsWith(_escapedTripleSlash);
    var blockComments = remainder.startsWith(_slashStarStar) ||
        remainder.startsWith(_escapedSlashStarStar);

    return split('\n').where((String line) {
      if (lineComments) {
        if (line.startsWith(_tripleSlash) ||
            line.startsWith(_escapedTripleSlash)) {
          return false;
        }
        lineComments = false;
        return true;
      } else if (blockComments) {
        if (line.contains(_starSlash) || line.contains(_escapedStarSlash)) {
          blockComments = false;
          return false;
        }
        if (line.startsWith(_slashStarStar) ||
            line.startsWith(_escapedSlashStarStar)) {
          return false;
        }
        return false;
      }

      return true;
    }).join('\n');
  }

  /// Strips the common indent from the given source fragment.
  String get stripIndent {
    var remainder = trimLeft();
    var indent = substring(0, length - remainder.length);
    return split('\n').map((line) {
      line = line.trimRight();
      return line.startsWith(indent) ? line.substring(indent.length) : line;
    }).join('\n');
  }
}

const HtmlEscape _escape = HtmlEscape();

const String _tripleSlash = '///';

final String _escapedTripleSlash = _escape.convert(_tripleSlash);

const String _slashStarStar = '/**';

final String _escapedSlashStarStar = _escape.convert(_slashStarStar);

const String _starSlash = '*/';

final String _escapedStarSlash = _escape.convert(_starSlash);

extension on Comment {
  /// A mapping of all comment references to their various data.
  CommentData get data {
    var sourceRanges0 = <SourceRange>[
      for (var token in tokens)
        SourceRange(
            token.offset,
            switch (token.next) {
                  var next? => next.offset,
                  null => token.end,
                } -
                token.offset),
    ];
    var docImportsData = <CommentDocImportData>[];
    for (var docImport in docImports) {
      docImportsData.add(
        CommentDocImportData(
            offset: docImport.offset, end: docImport.import.end),
      );
    }

    var (:sourceRanges, :docImportSourceRanges) =
        _normalizeSourceRanges(sourceRanges0, docImportsData);

    var referencesData = <String, CommentReferenceData>{};
    for (var reference in references) {
      var referable = reference.expression;
      String name;
      Element? staticElement;
      if (referable case PropertyAccess(:var propertyName)) {
        var target = referable.target;
        if (target is! PrefixedIdentifier) continue;
        name = '${target.name}.${propertyName.name}';
        staticElement = propertyName.element;
      } else if (referable case PrefixedIdentifier(:var identifier)) {
        name = referable.name;
        staticElement = identifier.element;
      } else if (referable case SimpleIdentifier()) {
        name = referable.name;
        staticElement = referable.element;
      } else {
        continue;
      }

      if (staticElement != null && !referencesData.containsKey(name)) {
        referencesData[name] = CommentReferenceData(
          staticElement,
          name,
          referable.offset,
          referable.length,
        );
      }
    }
    return CommentData(
      sourceRanges: sourceRanges,
      docImportSourceRanges: docImportSourceRanges,
      references: referencesData,
    );
  }

  /// Normalizes the comment's source ranges and the doc-import source ranges,
  /// to be relative to the start of the comment text, and to skip over gaps
  /// produced by interleaved comments.
  ({List<SourceRange> sourceRanges, List<SourceRange> docImportSourceRanges})
      _normalizeSourceRanges(
    List<SourceRange> sourceRanges,
    List<CommentDocImportData> docImportsData,
  ) {
    // All of the `offset` and `end` properties are offsets from the start of
    // the file (rather than from `content`). For the purposes of stripping
    // `@docImport` directives, we need to shift all offsets by this value,
    // the starting offset of the doc comment.
    var commentOffset = sourceRanges.first.offset;

    // Adjust the source ranges in two ways:
    // 1. Change the offsets to be offsets from the start of the comment text,
    //    instead of the file.
    // 2. Collapse the offsets between one token's end and the next one's start,
    //    which accounts for non-comment text between comment tokens.
    var normalizedSourceRanges = <SourceRange>[];
    var docImportSourceRanges = <SourceRange>[];
    var accumulatedGapSize = 0;
    var docImportIndex = 0;
    for (var i = 0; i < sourceRanges.length; i++) {
      var sourceRange = sourceRanges[i];
      var rangeStart = sourceRange.offset - commentOffset;
      var rangeEnd = sourceRange.end - commentOffset;
      var gapSize =
          i == 0 ? 0 : rangeStart - (sourceRanges[i - 1].end - commentOffset);
      accumulatedGapSize += gapSize;
      var rangeStartWithGap = rangeStart - accumulatedGapSize;
      var rangeEndWithGap = rangeEnd - accumulatedGapSize;
      normalizedSourceRanges.add(
          SourceRange(rangeStartWithGap, rangeEndWithGap - rangeStartWithGap));

      while (docImportIndex < docImportsData.length &&
          docImportsData[docImportIndex].end - commentOffset <= rangeEnd) {
        var docImportOffset =
            docImportsData[docImportIndex].offset - commentOffset;
        var docImportEnd = docImportsData[docImportIndex].end - commentOffset;
        docImportSourceRanges.add(SourceRange(
          docImportOffset - accumulatedGapSize,
          docImportEnd - docImportOffset,
        ));
        docImportIndex++;
      }
    }

    return (
      sourceRanges: normalizedSourceRanges,
      docImportSourceRanges: docImportSourceRanges
    );
  }
}
