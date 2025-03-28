// Copyright (c) 2022, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';

import 'package:analyzer/file_system/file_system.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/locatable.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as path;

class Validator {
  final PackageGraph _packageGraph;
  final DartdocOptionContext _config;
  final String _origin;
  final Set<String> _writtenFiles;
  final StreamController<String> _onCheckProgress;

  final Map<String, Set<ModelElement>> _hrefs;

  /// The set of files that have already been visited.
  final Set<String> _visited = {};

  /// The set of files that simply redirect to a different file.
  final Set<String> _redirects = {};

  Validator(this._packageGraph, this._config, String origin, this._writtenFiles,
      this._onCheckProgress)
      : _origin = path.normalize(origin),
        _hrefs = _packageGraph.allHrefs;

  /// Don't call this method more than once, and only after you've
  /// generated all docs for the Package.
  void validateLinks() {
    logInfo('Validating links...');
    runtimeStats.resetAccumulators({
      'readCountForLinkValidation',
      'readCountForIndexValidation',
    });
    _collectLinks('index.html');
    _checkForOrphans();
    _checkSearchIndex();
  }

  void _collectLinks(String pathToCheck, [String? source, String? fullPath]) {
    fullPath ??= path.join(_origin, pathToCheck);

    final pageLinks = _getLinksAndBaseHref(fullPath);
    if (pageLinks == null) {
      // The file could not be read.
      _warn(PackageWarning.brokenLink, pathToCheck, _origin,
          referredFrom: source);
      _onCheckProgress.add(pathToCheck);
      // Remove so that we properly count that the file doesn't exist for
      // the orphan check.
      _visited.remove(fullPath);
      return;
    }
    var _PageData(:links, :baseHref, :isRedirect) = pageLinks;
    _visited.add(fullPath);
    if (isRedirect) {
      _redirects.add(fullPath);
    }

    // Prevent extremely large stacks by storing the paths we are using
    // here instead -- occasionally, very large jobs have overflowed
    // the stack without this.
    final toVisit = <(String newPathToCheck, String newFullPath)>{};
    final pathDirectory = baseHref == null
        ? path.dirname(pathToCheck)
        : '${path.dirname(pathToCheck)}/$baseHref';

    for (final href in links) {
      final uri = Uri.tryParse(href);
      if (uri == null || !uri.hasAuthority && !uri.hasFragment) {
        var linkPath = path.normalize(path.url.join(pathDirectory, href));
        var newFullPath = path.join(_origin, linkPath);
        if (!_visited.contains(newFullPath)) {
          toVisit.add((linkPath, newFullPath));
          _visited.add(newFullPath);
        }
      }
    }
    for (final visitPaths in toVisit) {
      var (linkPath, fullPath) = visitPaths;
      _collectLinks(linkPath, pathToCheck, fullPath);
    }
    _onCheckProgress.add(pathToCheck);
  }

  void _checkForOrphans() {
    final staticAssets = path.join(_origin, 'static-assets', '');
    final indexJson = path.join(_origin, 'index.json');
    var foundIndexJson = false;

    void checkDirectory(Folder dir) {
      for (final child in dir.getChildren()) {
        final fullPath = path.normalize(child.path);
        if (_visited.contains(fullPath)) {
          continue;
        }
        if (child is Folder) {
          checkDirectory(child);
          continue;
        }
        if (fullPath.startsWith(staticAssets)) {
          continue;
        }
        if (path.equals(fullPath, indexJson)) {
          foundIndexJson = true;
          _onCheckProgress.add(fullPath);
          continue;
        }
        final relativeFullPath = path.relative(fullPath, from: _origin);
        if (!_writtenFiles.contains(relativeFullPath)) {
          // This isn't a file we wrote (this time); don't claim we did.
          _warn(PackageWarning.unknownFile, fullPath, _origin);
        } else {
          // Error messages are orphaned by design and do not appear in the
          // search index.
          if (const {'__404error.html', 'search.html', 'categories.json'}
              .contains(fullPath)) {
            _warn(PackageWarning.orphanedFile, fullPath, _origin);
          }
        }
        _onCheckProgress.add(fullPath);
      }
    }

    checkDirectory(_config.resourceProvider.getFolder(_origin));

    if (!foundIndexJson) {
      _warn(PackageWarning.brokenLink, indexJson, _origin);
      _onCheckProgress.add(indexJson);
    }
  }

  void _checkSearchIndex() {
    final fullPath = path.join(_origin, 'index.json');
    final indexPath = path.join(_origin, 'index.html');
    final file = _config.resourceProvider.getFile(fullPath);
    if (!file.exists) {
      return;
    }
    final jsonData = json.decode(file.readAsStringSync()) as List;
    runtimeStats.incrementAccumulator('readCountForIndexValidation');

    final found = <String>{};
    found.add(fullPath);
    // The package index isn't supposed to be in the search, so suppress the
    // warning.
    found.add(indexPath);
    for (var entry in jsonData.cast<Map<String, dynamic>>()) {
      if (entry.containsKey('href')) {
        var href =
            path.joinAll([_origin, ...path.url.split(entry['href'] as String)]);
        if (path.extension(href).isEmpty) {
          // An aliased link to an `index.html` file.
          href = path.join(href, 'index.html');
        }
        if (!_visited.contains(href)) {
          _warn(PackageWarning.brokenLink, href, _origin,
              referredFrom: fullPath);
        }
        found.add(href);
      }
    }
    final missingFromSearch = _visited.difference(_redirects).difference(found);
    for (final missingFile in missingFromSearch) {
      _warn(PackageWarning.missingFromSearchIndex, missingFile, _origin,
          referredFrom: fullPath);
    }
  }

  /// Gets all link destinations, and the base link destination, if one is found
  /// on the page.
  ///
  /// This is extracted to save memory during the check; be careful not to hang
  /// on to anything referencing the full file and doc tree.
  _PageData? _getLinksAndBaseHref(String fullPath) {
    final file = _config.resourceProvider.getFile(fullPath);
    if (!file.exists) {
      return null;
    }
    // TODO(srawlins): It is possible that instantiating an HtmlParser using
    // `lowercaseElementName: false` and `lowercaseAttrName: false` may save
    // time or memory.
    final doc = parse(file.readAsBytesSync());
    runtimeStats.incrementAccumulator('readCountForLinkValidation');
    final base = doc.querySelector('base');
    String? baseHref;
    if (base != null) {
      baseHref = base.attributes['href'];
    }
    final links = doc.querySelectorAll('a');
    final stringLinks = links
        .map((link) => link.attributes['href'])
        .nonNulls
        .where((uri) =>
            uri.isNotEmpty &&
            !uri.startsWith('https:') &&
            !uri.startsWith('http:') &&
            !uri.startsWith('mailto:') &&
            !uri.startsWith('ftp:'))
        .map((uri) =>
            // An aliased link to an `index.html` file.
            path.extension(uri).isEmpty
                ? path.url.join(uri, 'index.html')
                : uri)
        .toSet();
    var refreshTag = doc
        .querySelectorAll('meta')
        .firstWhereOrNull((e) => e.attributes['http-equiv'] == 'refresh');
    if (refreshTag != null) {
      var refreshUrl = refreshTag.attributes['url'];
      if (refreshUrl != null) {
        stringLinks.add(refreshUrl);
      }
    }

    return _PageData(stringLinks, baseHref, refreshTag != null);
  }

  /// Warns on erroneous file paths.
  void _warn(
    PackageWarning kind,
    String warnOn,
    String origin, {
    String? referredFrom,
  }) {
    final referredFromElements = <Locatable>{};

    // Make all paths relative to origin.
    if (path.isWithin(origin, warnOn)) {
      warnOn = path.relative(warnOn, from: origin);
    }
    if (referredFrom != null) {
      if (path.isWithin(origin, referredFrom)) {
        referredFrom = path.relative(referredFrom, from: origin);
      }
      final hrefReferredFrom = _hrefs[referredFrom];
      // Source paths are always relative.
      if (hrefReferredFrom != null) {
        referredFromElements.addAll(hrefReferredFrom);
      }
    }
    var warnOnElements = _hrefs[warnOn];

    if (referredFromElements.any((e) => e.isCanonical)) {
      referredFromElements.removeWhere((e) => !e.isCanonical);
    }
    var warnOnElement = warnOnElements?.firstWhereOrNull((e) => e.isCanonical);

    if (referredFromElements.isEmpty && referredFrom == 'index.html') {
      referredFromElements.add(_packageGraph.defaultPackage);
    }
    final message =
        referredFrom == 'index.json' ? '$warnOn (from index.json)' : warnOn;
    _packageGraph.warnOnElement(warnOnElement, kind,
        message: message, referredFrom: referredFromElements);
  }
}

/// Various data found in a given generate page
class _PageData {
  final Set<String> links;
  final String? baseHref;
  final bool isRedirect;

  const _PageData(this.links, this.baseHref, this.isRedirect);
}
