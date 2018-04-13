// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/analyzer.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:html/dom.dart' show Element, Document;
import 'package:html/parser.dart' show parse;
import 'package:path/path.dart' as pathLib;

import 'package:tuple/tuple.dart';
import 'src/config.dart';
import 'src/generator.dart';
import 'src/html/html_generator.dart';
import 'src/logging.dart';
import 'src/model.dart';
import 'src/package_meta.dart';
import 'src/warnings.dart';

export 'src/config.dart';
export 'src/element_type.dart';
export 'src/generator.dart';
export 'src/model.dart';
export 'src/package_meta.dart';

const String name = 'dartdoc';
// Update when pubspec version changes.
const String version = '0.18.1';

final String defaultOutDir = pathLib.join('doc', 'api');

/// Initialize and setup the generators.
Future<List<Generator>> _initGenerators(String url, String relCanonicalPrefix,
    {List<String> headerFilePaths,
    List<String> footerFilePaths,
    List<String> footerTextFilePaths,
    String faviconPath,
    bool prettyIndexJson: false}) async {
  var options = new HtmlGeneratorOptions(
      url: url,
      relCanonicalPrefix: relCanonicalPrefix,
      toolVersion: version,
      faviconPath: faviconPath,
      prettyIndexJson: prettyIndexJson);

  return [
    await HtmlGenerator.create(
      options: options,
      headers: headerFilePaths,
      footers: footerFilePaths,
      footerTexts: footerTextFilePaths,
    )
  ];
}

/// Instantiate dartdoc's configuration object and options parser with the
/// given command line arguments.
DartdocOptionSet createDartdocOptions(List<String> argv) {
  return new DartdocOptionSet('dartdoc')..addAll([
    new DartdocOptionArgOnly<bool>('addCrossdart', false,
        help: 'Add Crossdart links to the source code pieces.',
        negatable: false),
    new DartdocOptionBoth<double>('ambiguousReexportScorerMinConfidence', 0.1,
        help: 'Minimum scorer confidence to suppress warning on ambiguous reexport.'),
    new DartdocOptionArgOnly<bool>('autoIncludeDependencies', false,
        help: 'Include all the used libraries into the docs, even the ones not in the current package or "include-external"',
        negatable: false),
    new DartdocOptionBoth<List<String>>('categoryOrder', [],
        help: "A list of categories (not package names) to place first when grouping symbols on dartdoc's sidebar. "
              'Unmentioned categories are sorted after these.'),
    new DartdocOptionBoth<String>('examplePathPrefix', null,
        isDir: true,
        help: 'Prefix for @example paths.\n(defaults to the project root)',
        mustExist: true),
    new DartdocOptionBoth<List<String>>('exclude', [],
        help: 'Library names to ignore.',
        splitCommas: true),
    new DartdocOptionBoth<List<String>>('excludePackages', [],
        help: 'Package names to ignore.',
        splitCommas: true),
    new DartdocOptionBoth<String>('favicon', null,
        isFile: true,
        help: 'A path to a favicon for the generated docs.',
        mustExist: true),
    new DartdocOptionBoth<List<String>>('footer', [],
        isFile: true,
        help: 'paths to footer files containing HTML text.',
        mustExist: true,
        splitCommas: true),
    new DartdocOptionBoth<List<String>>('footerText', [],
        isFile: true,
        help: 'paths to footer-text files (optional text next to the package name '
              'and version).',
        mustExist: true,
        splitCommas: true),
    new DartdocOptionBoth<List<String>>('header', [],
        isFile: true,
        help: 'paths to header files containing HTML text.',
        splitCommas: true),
    new DartdocOptionArgOnly<bool>('help', false,
        abbr: 'h',
        help: 'Show command help.',
        negatable: false),
    new DartdocOptionArgOnly<bool>('hideSdkText', false,
        help: 'Drop all text for SDK components.  Helpful for integration tests for dartdoc, probably not useful for anything else.',
        negatable: true),
    new DartdocOptionArgOnly<String>('hostedUrl', null,
        help: 'URL where the docs will be hosted (used to generate the sitemap).'),
    new DartdocOptionBoth<List<String>>('include', null,
        help: 'Library names to generate docs for.',
        splitCommas: true),
    new DartdocOptionBoth<List<String>>('includeExternal', null,
        isFile: true,
        help: 'Additional (external) dart files to include; use "dir/fileName", '
            'as in lib/material.dart.',
        mustExist: true,
        splitCommas: true),
    new DartdocOptionBoth<bool>('includeSource', true,
        help: 'Show source code blocks.',
        negatable: true),
    new DartdocOptionArgOnly<String>('input', Directory.current.path,
        isDir: true,
        help: 'Path to source directory',
        mustExist: true),
    new DartdocOptionArgOnly<bool>('json', false,
        help: 'Prints out progress JSON maps. One entry per line.',
        negatable: true),
    new DartdocOptionArgOnly<String>('output', defaultOutDir,
        isDir: true,
        help: 'Path to output directory.'),
    new DartdocOptionBoth<List<String>>('packageOrder', [],
        help: 'A list of package names to place first when grouping libraries in packages. '
              'Unmentioned categories are sorted after these.'),
    new DartdocOptionArgOnly<bool>('prettyIndexJson', false,
        help: "Generates `index.json` with indentation and newlines. The file is larger, but it's also easier to diff.",
        negatable: false),
    new DartdocOptionArgOnly<String>('relCanonicalPrefix', null,
        help: 'If provided, add a rel="canonical" prefixed with provided value. '
              'Consider using if\nbuilding many versions of the docs for public '
              'SEO; learn more at https://goo.gl/gktN6F.'),


  ]);
}


/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc extends PackageBuilder {
  final List<Generator> generators;
  final Directory outputDir;
  final Set<String> writtenFiles = new Set();

  // Fires when the self checks make progress.
  final StreamController<String> _onCheckProgress =
      new StreamController(sync: true);

  DartDoc._(DartDocConfig config, this.generators, this.outputDir,
      PackageMeta packageMeta)
      : super(config, packageMeta);

  /// An asynchronous factory method that builds Dartdoc's file writers
  /// and returns a DartDoc object with them.
  static withDefaultGenerators(DartDocConfig config, Directory outputDir,
      PackageMeta packageMeta) async {
    var generators = await _initGenerators(
        config.hostedUrl, config.relCanonicalPrefix,
        headerFilePaths: config.headerFilePaths,
        footerFilePaths: config.footerFilePaths,
        footerTextFilePaths: config.footerTextFilePaths,
        faviconPath: config.faviconPath,
        prettyIndexJson: config.prettyIndexJson);
    for (var generator in generators) {
      generator.onFileCreated.listen(logProgress);
    }
    return new DartDoc._(config, generators, outputDir, packageMeta);
  }

  factory DartDoc.withoutGenerators(
      DartDocConfig config, Directory outputDir, PackageMeta packageMeta) {
    return new DartDoc._(config, [], outputDir, packageMeta);
  }

  Stream<String> get onCheckProgress => _onCheckProgress.stream;

  @override
  logAnalysisErrors(Set<Source> sources) async {
    List<AnalysisErrorInfo> errorInfos = [];
    // TODO(jcollins-g): figure out why sources can't contain includeExternals
    // or embedded SDK components without having spurious(?) analysis errors.
    // That seems wrong. dart-lang/dartdoc#1547
    for (Source source in sources) {
      ErrorsResult errorsResult = await driver.getErrors(source.fullName);
      AnalysisErrorInfo info =
          new AnalysisErrorInfoImpl(errorsResult.errors, errorsResult.lineInfo);
      List<_Error> errors = [info]
          .expand((AnalysisErrorInfo info) {
            return info.errors.map((error) =>
                new _Error(error, info.lineInfo, packageMeta.dir.path));
          })
          .where((_Error error) => error.isError)
          .toList()
            ..sort();
      // TODO(jcollins-g): Why does the SDK have analysis errors?  Annotations
      // seem correctly formed.  dart-lang/dartdoc#1547
      if (errors.isNotEmpty && !source.uri.toString().startsWith('dart:')) {
        errorInfos.add(info);
        logWarning(
            'analysis errors from source: ${source.uri.toString()} (${source.toString()}');
        errors.forEach(logWarning);
      }
    }

    List<_Error> errors = errorInfos
        .expand((AnalysisErrorInfo info) {
          return info.errors.map((error) =>
              new _Error(error, info.lineInfo, packageMeta.dir.path));
        })
        .where((_Error error) => error.isError)
        // TODO(jcollins-g): remove after conversion to analysis driver
        .where((_Error error) =>
            error.error.errorCode !=
            CompileTimeErrorCode.URI_HAS_NOT_BEEN_GENERATED)
        .toList()
          ..sort();

    if (errors.isNotEmpty) {
      int len = errors.length;
      throw new DartDocFailure(
          "encountered ${len} analysis error${len == 1 ? '' : 's'}");
    }
  }

  PackageGraph packageGraph;

  /// Generate DartDoc documentation.
  ///
  /// [DartDocResults] is returned if dartdoc succeeds. [DartDocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// analysis error in the code.
  Future<DartDocResults> generateDocs() async {
    Stopwatch _stopwatch = new Stopwatch()..start();
    double seconds;
    packageGraph = await buildPackageGraph();
    seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    logInfo(
        "Initialized dartdoc with ${packageGraph.libraries.length} librar${packageGraph.libraries.length == 1 ? 'y' : 'ies'} "
        "in ${seconds.toStringAsFixed(1)} seconds");
    _stopwatch.reset();

    if (generators.isNotEmpty) {
      // Create the out directory.
      if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

      for (var generator in generators) {
        await generator.generate(packageGraph, outputDir.path);
        writtenFiles.addAll(generator.writtenFiles.map(pathLib.normalize));
      }
      if (config.validateLinks) validateLinks(packageGraph, outputDir.path);
    }

    int warnings = packageGraph.packageWarningCounter.warningCount;
    int errors = packageGraph.packageWarningCounter.errorCount;
    if (warnings == 0 && errors == 0) {
      logInfo("no issues found");
    } else {
      logWarning("found ${warnings} ${pluralize('warning', warnings)} "
          "and ${errors} ${pluralize('error', errors)}");
    }

    seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    logInfo(
        "Documented ${packageGraph.publicLibraries.length} public librar${packageGraph.publicLibraries.length == 1 ? 'y' : 'ies'} "
        "in ${seconds.toStringAsFixed(1)} seconds");

    if (packageGraph.publicLibraries.isEmpty) {
      throw new DartDocFailure(
          "dartdoc could not find any libraries to document. Run `pub get` and try again.");
    }

    if (packageGraph.packageWarningCounter.errorCount > 0) {
      throw new DartDocFailure("dartdoc encountered errors while processing");
    }

    return new DartDocResults(packageMeta, packageGraph, outputDir);
  }

  /// Warn on file paths.
  void _warn(PackageGraph packageGraph, PackageWarning kind, String warnOn,
      String origin,
      {String referredFrom}) {
    // Ordinarily this would go in [Package.warn], but we don't actually know what
    // ModelElement to warn on yet.
    Warnable warnOnElement;
    Set<Warnable> referredFromElements = new Set();
    Set<Warnable> warnOnElements;

    // Make all paths relative to origin.
    if (pathLib.isWithin(origin, warnOn)) {
      warnOn = pathLib.relative(warnOn, from: origin);
    }
    if (referredFrom != null) {
      if (pathLib.isWithin(origin, referredFrom)) {
        referredFrom = pathLib.relative(referredFrom, from: origin);
      }
      // Source paths are always relative.
      if (_hrefs[referredFrom] != null) {
        referredFromElements.addAll(_hrefs[referredFrom]);
      }
    }
    warnOnElements = _hrefs[warnOn];

    if (referredFromElements.any((e) => e.isCanonical)) {
      referredFromElements.removeWhere((e) => !e.isCanonical);
    }
    if (warnOnElements != null) {
      if (warnOnElements.any((e) => e.isCanonical)) {
        warnOnElement = warnOnElements.firstWhere((e) => e.isCanonical);
      } else {
        // If we don't have a canonical element, just pick one.
        warnOnElement = warnOnElements.isEmpty ? null : warnOnElements.first;
      }
    }

    if (referredFromElements.isEmpty && referredFrom == 'index.html')
      referredFromElements.add(packageGraph);
    String message = warnOn;
    if (referredFrom == 'index.json') message = '$warnOn (from index.json)';
    packageGraph.warnOnElement(warnOnElement, kind,
        message: message, referredFrom: referredFromElements);
  }

  void _doOrphanCheck(
      PackageGraph packageGraph, String origin, Set<String> visited) {
    String normalOrigin = pathLib.normalize(origin);
    String staticAssets = pathLib.joinAll([normalOrigin, 'static-assets', '']);
    String indexJson = pathLib.joinAll([normalOrigin, 'index.json']);
    bool foundIndexJson = false;
    for (FileSystemEntity f
        in new Directory(normalOrigin).listSync(recursive: true)) {
      var fullPath = pathLib.normalize(f.path);
      if (f is Directory) {
        continue;
      }
      if (fullPath.startsWith(staticAssets)) {
        continue;
      }
      if (fullPath == indexJson) {
        foundIndexJson = true;
        _onCheckProgress.add(fullPath);
        continue;
      }
      if (visited.contains(fullPath)) continue;
      if (!writtenFiles.contains(fullPath)) {
        // This isn't a file we wrote (this time); don't claim we did.
        _warn(packageGraph, PackageWarning.unknownFile, fullPath, normalOrigin);
      } else {
        _warn(
            packageGraph, PackageWarning.orphanedFile, fullPath, normalOrigin);
      }
      _onCheckProgress.add(fullPath);
    }

    if (!foundIndexJson) {
      _warn(packageGraph, PackageWarning.brokenLink, indexJson, normalOrigin);
      _onCheckProgress.add(indexJson);
    }
  }

  // This is extracted to save memory during the check; be careful not to hang
  // on to anything referencing the full file and doc tree.
  Tuple2<Iterable<String>, String> _getStringLinksAndHref(String fullPath) {
    File file = new File("$fullPath");
    if (!file.existsSync()) {
      return null;
    }
    Document doc = parse(file.readAsBytesSync());
    Element base = doc.querySelector('base');
    String baseHref;
    if (base != null) {
      baseHref = base.attributes['href'];
    }
    List<Element> links = doc.querySelectorAll('a');
    List<String> stringLinks = links
        .map((link) => link.attributes['href'])
        .where((href) => href != null)
        .toList();

    return new Tuple2(stringLinks, baseHref);
  }

  void _doSearchIndexCheck(
      PackageGraph packageGraph, String origin, Set<String> visited) {
    String fullPath = pathLib.joinAll([origin, 'index.json']);
    String indexPath = pathLib.joinAll([origin, 'index.html']);
    File file = new File("$fullPath");
    if (!file.existsSync()) {
      return null;
    }
    JsonDecoder decoder = new JsonDecoder();
    List jsonData = decoder.convert(file.readAsStringSync());

    Set<String> found = new Set();
    found.add(fullPath);
    // The package index isn't supposed to be in the search, so suppress the
    // warning.
    found.add(indexPath);
    for (Map<String, String> entry in jsonData) {
      if (entry.containsKey('href')) {
        String entryPath = pathLib.joinAll([origin, entry['href']]);
        if (!visited.contains(entryPath)) {
          _warn(packageGraph, PackageWarning.brokenLink, entryPath,
              pathLib.normalize(origin),
              referredFrom: fullPath);
        }
        found.add(entryPath);
      }
    }
    // Missing from search index
    Set<String> missing_from_search = visited.difference(found);
    for (String s in missing_from_search) {
      _warn(packageGraph, PackageWarning.missingFromSearchIndex, s,
          pathLib.normalize(origin),
          referredFrom: fullPath);
    }
  }

  void _doCheck(PackageGraph packageGraph, String origin, Set<String> visited,
      String pathToCheck,
      [String source, String fullPath]) {
    if (fullPath == null) {
      fullPath = pathLib.joinAll([origin, pathToCheck]);
      fullPath = pathLib.normalize(fullPath);
    }

    Tuple2 stringLinksAndHref = _getStringLinksAndHref(fullPath);
    if (stringLinksAndHref == null) {
      _warn(packageGraph, PackageWarning.brokenLink, pathToCheck,
          pathLib.normalize(origin),
          referredFrom: source);
      _onCheckProgress.add(pathToCheck);
      // Remove so that we properly count that the file doesn't exist for
      // the orphan check.
      visited.remove(fullPath);
      return null;
    }
    visited.add(fullPath);
    Iterable<String> stringLinks = stringLinksAndHref.item1;
    String baseHref = stringLinksAndHref.item2;

    // Prevent extremely large stacks by storing the paths we are using
    // here instead -- occasionally, very large jobs have overflowed
    // the stack without this.
    // (newPathToCheck, newFullPath)
    Set<Tuple2<String, String>> toVisit = new Set();

    for (String href in stringLinks) {
      Uri uri;
      try {
        uri = Uri.parse(href);
      } catch (FormatError) {}

      if (uri == null || !uri.hasAuthority && !uri.hasFragment) {
        var full;
        if (baseHref != null) {
          full = '${pathLib.dirname(pathToCheck)}/$baseHref/$href';
        } else {
          full = '${pathLib.dirname(pathToCheck)}/$href';
        }
        var newPathToCheck = pathLib.normalize(full);
        String newFullPath = pathLib.joinAll([origin, newPathToCheck]);
        newFullPath = pathLib.normalize(newFullPath);
        if (!visited.contains(newFullPath)) {
          toVisit.add(new Tuple2(newPathToCheck, newFullPath));
          visited.add(newFullPath);
        }
      }
    }
    for (Tuple2 visitPaths in toVisit) {
      _doCheck(packageGraph, origin, visited, visitPaths.item1, pathToCheck,
          visitPaths.item2);
    }
    _onCheckProgress.add(pathToCheck);
  }

  Map<String, Set<ModelElement>> _hrefs;

  /// Don't call this method more than once, and only after you've
  /// generated all docs for the Package.
  void validateLinks(PackageGraph packageGraph, String origin) {
    assert(_hrefs == null);
    _hrefs = packageGraph.allHrefs;

    final Set<String> visited = new Set();
    final String start = 'index.html';
    logInfo('Validating docs...');
    _doCheck(packageGraph, origin, visited, start);
    _doOrphanCheck(packageGraph, origin, visited);
    _doSearchIndexCheck(packageGraph, origin, visited);
  }
}

/// This class is returned if dartdoc fails in an expected way (for instance, if
/// there is an analysis error in the library).
class DartDocFailure {
  final String message;

  DartDocFailure(this.message);

  @override
  String toString() => message;
}

/// The results of a [DartDoc.generateDocs] call.
class DartDocResults {
  final PackageMeta packageMeta;
  final PackageGraph packageGraph;
  final Directory outDir;

  DartDocResults(this.packageMeta, this.packageGraph, this.outDir);
}

class _Error implements Comparable<_Error> {
  final AnalysisError error;
  final LineInfo lineInfo;
  final String projectPath;

  _Error(this.error, this.lineInfo, this.projectPath);

  String get description => '${error.message} at ${location}, line ${line}.';
  bool get isError => error.errorCode.errorSeverity == ErrorSeverity.ERROR;
  int get line => lineInfo.getLocation(error.offset).lineNumber;
  String get location {
    String path = error.source.fullName;
    if (path.startsWith(projectPath)) {
      path = path.substring(projectPath.length + 1);
    }
    return path;
  }

  int get severity => error.errorCode.errorSeverity.ordinal;

  String get severityName => error.errorCode.errorSeverity.displayName;

  @override
  int compareTo(_Error other) {
    if (severity == other.severity) {
      int cmp = error.source.fullName.compareTo(other.error.source.fullName);
      return cmp == 0 ? line - other.line : cmp;
    } else {
      return other.severity - severity;
    }
  }

  @override
  String toString() => '[${severityName}] ${description}';
}
