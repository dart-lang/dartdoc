// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/quiver.dart';

class MatchingLinkResult {
  final CommentReferable commentReferable;
  final bool warn;

  MatchingLinkResult(this.commentReferable, {this.warn = true});

  @override
  bool operator ==(Object other) {
    return other is MatchingLinkResult &&
        commentReferable == other.commentReferable &&
        warn == other.warn;
  }

  @override
  int get hashCode => hash2(commentReferable, warn);

  bool isEquivalentTo(MatchingLinkResult other) {
    var compareThis = commentReferable;
    var compareOther = other.commentReferable;

    if (compareThis is DefinedElementType) {
      compareThis = (compareThis as DefinedElementType).modelElement;
    }

    if (compareOther is DefinedElementType) {
      compareOther = (compareOther as DefinedElementType).modelElement;
    }

    if (compareThis is Accessor) {
      compareThis = (compareThis as Accessor).enclosingCombo;
    }

    if (compareOther is Accessor) {
      compareOther = (compareOther as Accessor).enclosingCombo;
    }

    if (compareThis is ModelElement &&
        compareThis.canonicalModelElement != null) {
      compareThis = (compareThis as ModelElement).canonicalModelElement;
    }
    if (compareOther is ModelElement &&
        compareOther.canonicalModelElement != null) {
      compareOther = (compareOther as ModelElement).canonicalModelElement;
    }
    if (compareThis == compareOther) return true;
    // The old implementation just throws away Parameter matches to avoid
    // problems with warning unnecessarily at higher levels of the code.
    // I'd like to fix this at a different layer with the new lookup, so treat
    // this as equivalent to a null type.
    if (compareOther is Parameter && compareThis == null) {
      return true;
    }
    if (compareThis is Parameter && compareOther == null) {
      return true;
    }
    // Same with TypeParameter.
    if (compareOther is TypeParameter && compareThis == null) {
      return true;
    }
    if (compareThis is TypeParameter && compareOther == null) {
      return true;
    }

    return false;
  }

  @override
  String toString() {
    return 'element: [${commentReferable is Constructor ? 'new ' : ''}${commentReferable?.fullyQualifiedName}] warn: $warn';
  }
}

class _MarkdownStats {
  int totalReferences = 0;
  int resolvedReferences = 0;
  int resolvedNewLookupReferences = 0;
  int resolvedOldLookupReferences = 0;
  int resolvedEquivalentlyReferences = 0;

  String _valueAndPercent(int references) {
    return '$references (${references.toDouble() / totalReferences.toDouble() * 100}%)';
  }

  String buildReport() {
    var report = StringBuffer();
    report.writeln('Reference Counts:');
    report.writeln('total references: $totalReferences');
    report.writeln(
        'resolved references:  ${_valueAndPercent(resolvedReferences)}');
    if (resolvedNewLookupReferences > 0) {
      report.writeln(
          'resolved references with new lookup:  $resolvedNewLookupReferences (${resolvedNewLookupReferences / totalReferences * 100}%)');
    }
    if (resolvedOldLookupReferences > 0) {
      report.writeln(
          'resolved references with old lookup:  $resolvedOldLookupReferences (${resolvedOldLookupReferences / totalReferences * 100}%)');
    }
    if (resolvedEquivalentlyReferences > 0) {
      report.writeln(
          'resolved references with equivalent links:  $resolvedEquivalentlyReferences (${resolvedEquivalentlyReferences / totalReferences * 100}%)');
    }
    return report.toString();
  }
}

/// TODO(jcollins-g): perhaps a more generic stats gathering apparatus for
/// dartdoc would be useful, and one that isn't process-global.
final markdownStats = _MarkdownStats();
