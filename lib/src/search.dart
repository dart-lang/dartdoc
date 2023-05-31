// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/generator/generator_utils.dart';
import 'package:dartdoc/src/model/indexable.dart';
import 'package:meta/meta.dart';

enum _MatchPosition {
  isExactly,
  startsWith,
  contains;

  int operator -(_MatchPosition other) => index - other.index;
}

class Index {
  final List<String> packageOrder;
  final List<IndexItem> index;

  @visibleForTesting
  Index(this.packageOrder, this.index);

  factory Index.fromJson(String text) {
    var jsonIndex = (jsonDecode(text) as List).cast<Map<String, dynamic>>();
    var indexList = <IndexItem>[];
    var packageOrder = <String>[];
    for (var entry in jsonIndex) {
      if (entry.containsKey(packageOrderKey)) {
        packageOrder.addAll((entry[packageOrderKey] as List).cast<String>());
      } else {
        indexList.add(IndexItem.fromMap(entry));
      }
    }
    return Index(packageOrder, indexList);
  }

  int packageOrderPosition(String packageName) {
    if (packageOrder.isEmpty) return 0;
    var index = packageOrder.indexOf(packageName);
    return index == -1 ? packageOrder.length : index;
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
      comparison = packageOrderPosition(a.item.packageName) -
          packageOrderPosition(b.item.packageName);
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

  // TODO(srawlins): Store the index of the package in package order instead of
  // this String. The Strings bloat the `index.json` file and keeping duplicate
  // parsed Strings in memory is expensive.
  final String packageName;
  final Kind kind;
  final String? href;
  final int overriddenDepth;
  final String? desc;
  final EnclosedBy? enclosedBy;

  IndexItem._({
    required this.name,
    required this.qualifiedName,
    required this.packageName,
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
  //   "packageName":"dartdoc"
  //   ["enclosedBy":{"name":"dartdoc","kind":2}]
  // }
  // ```
  factory IndexItem.fromMap(Map<String, dynamic> data) {
    // Note that this map also contains 'packageName', but we're not currently
    // using that info.

    EnclosedBy? enclosedBy;
    if (data['enclosedBy'] != null) {
      final map = data['enclosedBy'] as Map<String, dynamic>;
      enclosedBy = EnclosedBy._(
          name: map['name'] as String,
          kind: Kind.values[map['kind'] as int],
          href: map['href'] as String);
    }

    return IndexItem._(
      name: data['name'],
      qualifiedName: data['qualifiedName'],
      packageName: data['packageName'],
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
        // Root- and package-level items.
        Kind.library => 0,
        Kind.package => 0,
        Kind.topic => 0,

        // Library members.
        Kind.class_ => 1,
        Kind.enum_ => 1,
        Kind.extension => 1,
        Kind.mixin => 1,
        Kind.topLevelConstant => 1,
        Kind.topLevelProperty => 1,
        Kind.typedef => 1,

        // Container members.
        Kind.accessor => 2,
        Kind.constant => 2,
        Kind.constructor => 2,
        Kind.function => 2,
        Kind.method => 2,
        Kind.property => 2,

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
