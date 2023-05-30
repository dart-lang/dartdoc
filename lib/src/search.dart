// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:dartdoc/src/generator/generator_utils.dart';
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
    var jsonIndex = (jsonDecode(text) as List).cast<Map<String, Object>>();
    var indexList = <IndexItem>[];
    var packageOrder = <String>[];
    for (var entry in jsonIndex) {
      if (entry.containsKey(packageOrderKey)) {
        packageOrder.addAll(entry[packageOrderKey] as List<String>);
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

  // TODO(srawlins): Store the integer of in the package order instead of this
  // String. The Strings bloat the `index.json` file and keeping duplicate
  // parsed Strings in memory is expensive.
  final String packageName;
  final String type;
  final String? href;
  final int overriddenDepth;
  final String? desc;
  final EnclosedBy? enclosedBy;

  IndexItem._({
    required this.name,
    required this.qualifiedName,
    required this.packageName,
    required this.type,
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
  //   "qualifiedName":"dartdoc",
  //   "href":"dartdoc/dartdoc-library.html",
  //   "type":"library",
  //   "overriddenDepth":0,
  //   "packageName":"dartdoc"
  //   ["enclosedBy":{"name":"Accessor","type":"class"}]
  // }
  // ```
  factory IndexItem.fromMap(Map<String, dynamic> data) {
    // Note that this map also contains 'packageName', but we're not currently
    // using that info.

    EnclosedBy? enclosedBy;
    if (data['enclosedBy'] != null) {
      final map = data['enclosedBy'] as Map<String, Object>;
      enclosedBy = EnclosedBy._(
          name: map['name'] as String,
          type: map['type'] as String,
          href: map['href'] as String);
    }

    return IndexItem._(
      name: data['name'],
      qualifiedName: data['qualifiedName'],
      packageName: data['packageName'],
      href: data['href'],
      type: data['type'],
      overriddenDepth: (data['overriddenDepth'] as int?) ?? 0,
      desc: data['desc'],
      enclosedBy: enclosedBy,
    );
  }

  int get _scope =>
      const {
        'topic': 0,
        'library': 0,
        'class': 1,
        'enum': 1,
        'mixin': 1,
        'extension': 1,
        'typedef': 1,
        'function': 2,
        'method': 2,
        'accessor': 2,
        'operator': 2,
        'constant': 2,
        'property': 2,
        'constructor': 2,
      }[type] ??
      3;
}

class EnclosedBy {
  final String name;
  final String type;
  final String href;

  // Built from JSON structure:
  // ["enclosedBy":{"name":"Accessor","type":"class","href":"link"}]
  EnclosedBy._({required this.name, required this.type, required this.href});
}
