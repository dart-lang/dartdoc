// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/model/indexable.dart';
import 'package:meta/meta.dart';

enum _MatchPosition {
  isExactly,
  startsWith,
  contains;

  int operator -(_MatchPosition other) => index - other.index;
}

class Index {
  final List<IndexItem> index;

  @visibleForTesting
  Index(this.index);

  factory Index.fromJson(String text) {
    var jsonIndex = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    return Index(jsonIndex.map(IndexItem.fromMap).toList());
  }

  List<IndexItem> find(String rawQuery) {
    if (rawQuery.isEmpty) {
      return [];
    }

    var query = rawQuery.toLowerCase();
    var allMatches = <({IndexItem item, _MatchPosition matchPosition})>[];

    for (var item in index) {
      void score(_MatchPosition matchPosition) {
        allMatches.add((item: item, matchPosition: matchPosition));
      }

      var lowerName = item.name.toLowerCase();
      var lowerQualifiedName = item.qualifiedName.toLowerCase();

      if (lowerName == query ||
          lowerQualifiedName == query ||
          lowerName == 'dart:$query') {
        score(_MatchPosition.isExactly);
      } else if (query.length > 1) {
        if (lowerName.startsWith(query) ||
            lowerQualifiedName.startsWith(query)) {
          score(_MatchPosition.startsWith);
        } else if (lowerName.contains(query) ||
            lowerQualifiedName.contains(query)) {
          score(_MatchPosition.contains);
        }
      }
    }

    allMatches.sort((a, b) {
      // Exact match vs substring is king. If the user has typed the whole term
      // they are searching for, but it isn't at the top, they cannot type any
      // more to try and find it.
      var comparison = a.matchPosition - b.matchPosition;
      if (comparison != 0) {
        return comparison;
      }

      // Prefer packages higher in the package order.
      comparison = a.item.packageRank - b.item.packageRank;
      if (comparison != 0) {
        return comparison;
      }

      // Prefer top-level elements to library members to class (etc.) members.
      comparison = a.item._scope - b.item._scope;
      if (comparison != 0) {
        return comparison;
      }

      // Prefer non-overrides to overrides.
      comparison = a.item.overriddenDepth - b.item.overriddenDepth;
      if (comparison != 0) {
        return comparison;
      }

      // Prefer shorter names to longer ones.
      return a.item.name.length - b.item.name.length;
    });

    return allMatches.map((match) => match.item).toList();
  }
}

class IndexItem {
  final String name;
  final String qualifiedName;
  final int packageRank;
  final Kind kind;
  final String? href;
  final int overriddenDepth;
  final String? desc;
  final EnclosedBy? enclosedBy;

  IndexItem._({
    required this.name,
    required this.qualifiedName,
    required this.packageRank,
    required this.kind,
    required this.desc,
    required this.href,
    required this.overriddenDepth,
    required this.enclosedBy,
  });

  // Example Map structure:
  //
  // ```dart
  // {
  //   "name":"dartdoc",
  //   "qualifiedName":"dartdoc.Dartdoc",
  //   "href":"dartdoc/Dartdoc-class.html",
  //   "kind":1,
  //   "overriddenDepth":0,
  //   "packageRank":0
  //   ["enclosedBy":{"name":"dartdoc","kind":2}]
  // }
  // ```
  factory IndexItem.fromMap(Map<String, dynamic> data) {
    EnclosedBy? enclosedBy;
    if (data['enclosedBy'] != null) {
      final map = data['enclosedBy'] as Map<String, dynamic>;
      assert(
        map['href'] != null,
        "'enclosedBy' element expected to have a non-null 'href', "
        "but was null: '${data['qualifiedName']}', "
        "enclosed by the ${Kind.values[map['kind'] as int]} '${map['name']}' "
        "('${map['qualifiedName']}')",
      );
      enclosedBy = EnclosedBy._(
          name: map['name'] as String,
          kind: Kind.values[map['kind'] as int],
          href: map['href'] as String);
    }

    return IndexItem._(
      name: data['name'],
      qualifiedName: data['qualifiedName'],
      packageRank: (data['packageRank'] as int?) ?? 0,
      href: data['href'],
      kind: Kind.values[data['kind'] as int],
      overriddenDepth: (data['overriddenDepth'] as int?) ?? 0,
      desc: data['desc'],
      enclosedBy: enclosedBy,
    );
  }

  /// The "scope" of a search item which may affect ranking.
  ///
  /// This is not the lexical scope of identifiers in Dart code, but similar in
  /// a very loose sense.
  int get _scope => switch (kind) {
        // Library members.
        Kind.class_ => 0,
        Kind.enum_ => 0,
        Kind.extension => 0,
        Kind.extensionType => 0,
        Kind.mixin => 0,
        Kind.topLevelConstant => 0,
        Kind.topLevelProperty => 0,
        Kind.typedef => 0,

        // Container members.
        Kind.accessor => 1,
        Kind.constant => 1,
        Kind.constructor => 1,
        Kind.function => 1,
        Kind.method => 1,
        Kind.property => 1,

        // Root- and package-level items.
        Kind.library => 2,
        Kind.package => 2,
        Kind.topic => 2,

        // Others.
        Kind.dynamic => 3,
        Kind.never => 3,
        Kind.parameter => 3,
        Kind.prefix => 3,
        Kind.sdk => 3,
        Kind.typeParameter => 3,
      };
}

class EnclosedBy {
  final String name;
  final Kind kind;
  final String href;

  // Built from JSON structure:
  // ["enclosedBy":{"name":"Accessor","kind":"class","href":"link"}]
  EnclosedBy._({required this.name, required this.kind, required this.href});
}
