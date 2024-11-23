// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

class WarningsCollection {
  final String dir;
  final Map<String, int> warningKeyCounts = {};
  final String branch;
  final String? pubCachePath;

  WarningsCollection(this.dir, this.pubCachePath, this.branch);

  static const String kPubCachePathReplacement = '_xxxPubDirectoryxxx_';
  static const String kTempDirReplacement = '_xxxTempDirectoryxxx_';

  String _toKey(String text) {
    var key = text.replaceAll(dir, kTempDirReplacement);
    var pubCachePath = this.pubCachePath;
    if (pubCachePath != null) {
      key = key.replaceAll(pubCachePath, kPubCachePathReplacement);
    }
    return key;
  }

  String _fromKey(String text) {
    var key = text.replaceAll(kTempDirReplacement, dir);
    if (pubCachePath != null) {
      key = key.replaceAll(kPubCachePathReplacement, pubCachePath!);
    }
    return key;
  }

  void add(String text) {
    var key = _toKey(text);
    warningKeyCounts.update(key, (e) => e + 1, ifAbsent: () => 1);
  }

  /// Outputs formatted for comparing warnings between this (the "original"
  /// code) and the "current" code.
  String warningDeltaText(String title, WarningsCollection current) {
    var buffer = StringBuffer();
    var quantityChangedOuts = <String>{};
    var onlyOriginal = <String>{};
    var onlyCurrent = <String>{};
    var identical = <String>{};
    var allKeys = <String>{
      ...warningKeyCounts.keys,
      ...current.warningKeyCounts.keys,
    };

    for (var key in allKeys) {
      if (warningKeyCounts.containsKey(key) &&
          !current.warningKeyCounts.containsKey(key)) {
        onlyOriginal.add(key);
      } else if (!warningKeyCounts.containsKey(key) &&
          current.warningKeyCounts.containsKey(key)) {
        onlyCurrent.add(key);
      } else if (warningKeyCounts.containsKey(key) &&
          current.warningKeyCounts.containsKey(key) &&
          warningKeyCounts[key] != current.warningKeyCounts[key]) {
        quantityChangedOuts.add(key);
      } else {
        identical.add(key);
      }
    }

    if (onlyOriginal.isNotEmpty) {
      buffer
          .writeln('*** $title: ${onlyOriginal.length} warnings from $branch, '
              'missing in ${current.branch}:');
      for (var key in onlyOriginal) {
        buffer.writeln(_fromKey(key));
      }
    }
    if (onlyCurrent.isNotEmpty) {
      buffer.writeln(
          '*** $title: ${onlyCurrent.length} new warnings in ${current.branch}, '
          'missing in $branch');
      for (var key in onlyCurrent) {
        buffer.writeln(current._fromKey(key));
      }
    }
    if (quantityChangedOuts.isNotEmpty) {
      buffer.writeln('*** $title : Identical warning quantity changed');
      for (var key in quantityChangedOuts) {
        buffer.writeln('* Appeared ${warningKeyCounts[key]} times in $branch, '
            '${current.warningKeyCounts[key]} in ${current.branch}:');
        buffer.writeln(current._fromKey(key));
      }
    }
    if (onlyOriginal.isEmpty &&
        onlyCurrent.isEmpty &&
        quantityChangedOuts.isEmpty) {
      buffer.writeln('*** $title: No difference in warning output from '
          '$branch to ${current.branch}');
      if (allKeys.isNotEmpty) {
        buffer.write(' (${allKeys.length} warnings found)');
      }
    } else if (identical.isNotEmpty) {
      buffer.writeln('*** $title: Difference in warning output found for '
          '${allKeys.length - identical.length} warnings '
          '(${allKeys.length} warnings found)"');
    }
    return buffer.toString();
  }
}
