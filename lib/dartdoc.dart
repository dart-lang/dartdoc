// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
///
/// Library interface is still experimental.
@experimental
library dartdoc;

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, exitCode, stderr;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/options.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/generator/empty_generator.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/html_generator.dart';
import 'package:dartdoc/src/generator/markdown_generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:html/parser.dart' show parse;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

export 'package:dartdoc/src/dartdoc_options.dart';
export 'package:dartdoc/src/element_type.dart';
export 'package:dartdoc/src/generator/generator.dart';
export 'package:dartdoc/src/model/model.dart';
export 'package:dartdoc/src/package_config_provider.dart';
export 'package:dartdoc/src/package_meta.dart';

const String programName = 'dartdoc';
// Update when pubspec version changes by running `pub run build_runner build`
const String dartdocVersion = packageVersion;

class DartdocFileWriter implements FileWriter {
  final String _outputDir;
  @override
  final ResourceProvider resourceProvider;
  final Map<String, Warnable> _fileElementMap = {};
  @override
  final Set<String> writtenFiles = {};

  DartdocFileWriter(this._outputDir, this.resourceProvider);

  @override
  void writeBytes(
    String filePath,
    List<int> content, {
    bool allowOverwrite = false,
  }) {
    // Replace '/' separators with proper separators for the platform.
    var outFile = path.joinAll(filePath.split('/'));

    if (!allowOverwrite) {
      _warnAboutOverwrite(outFile, null);
    }
    _fileElementMap[outFile] = null;

    var file = _getFile(outFile);
    file.writeAsBytesSync(content);
    writtenFiles.add(outFile);
    logProgress(outFile);
  }

  @override
  void write(String filePath, String content, {Warnable element}) {
    // Replace '/' separators with proper separators for the platform.
    var outFile = path.joinAll(filePath.split('/'));

    _warnAboutOverwrite(outFile, element);
    _fileElementMap[outFile] = element;

    var file = _getFile(outFile);
    file.writeAsStringSync(content);
    writtenFiles.add(outFile);
    logProgress(outFile);
  }

  void _warnAboutOverwrite(String outFile, Warnable element) {
    if (_fileElementMap.containsKey(outFile)) {
      assert(element != null,
          'Attempted overwrite of $outFile without corresponding element');
      var originalElement = _fileElementMap[outFile];
      var referredFrom = originalElement != null ? [originalElement] : null;
      element?.warn(PackageWarning.duplicateFile,
          message: outFile, referredFrom: referredFrom);
    }
  }

  /// Returns the file at [outFile] relative to [_outputDir], creating the
  /// parent directory if necessary.
  File _getFile(String outFile) {
    var file = resourceProvider
        .getFile(resourceProvider.pathContext.join(_outputDir, outFile));
    var parent = file.parent2;
    if (!parent.exists) {
      parent.create();
    }
    return file;
  }
}

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class Dartdoc {
  Generator _generator;
  final PackageBuilder packageBuilder;
  final DartdocOptionContext config;
  final Set<String> _writtenFiles = {};
  Folder _outputDir;

  // Fires when the self checks make progress.
  final StreamController<String> _onCheckProgress =
      StreamController(sync: true);

  Dartdoc._(this.config, this._generator, this.packageBuilder) {
    _outputDir = config.resourceProvider
        .getFolder(config.resourceProvider.pathContext.absolute(config.output))
      ..create();
  }

  // TODO(srawlins): Remove when https://github.com/dart-lang/linter/issues/2706
  // is fixed.
  // ignore: unnecessary_getters_setters
  Generator get generator => _generator;

  @visibleForTesting
  // TODO(srawlins): Remove when https://github.com/dart-lang/linter/issues/2706
  // is fixed.
  // ignore: unnecessary_getters_setters
  set generator(Generator newGenerator) => _generator = newGenerator;

  /// Asynchronous factory method that builds Dartdoc with an empty generator.
  static Future<Dartdoc> withEmptyGenerator(
    DartdocOptionContext config,
    PackageBuilder packageBuilder,
  ) async {
    return Dartdoc._(
      config,
      await initEmptyGenerator(config),
      packageBuilder,
    );
  }

  /// Asynchronous factory method that builds Dartdoc with a generator
  /// determined by the given context.
  static Future<Dartdoc> fromContext(
    DartdocGeneratorOptionContext context,
    PackageBuilder packageBuilder,
  ) async {
    Generator generator;
    switch (context.format) {
      case 'html':
        generator = await initHtmlGenerator(context);
        break;
      case 'md':
        generator = await initMarkdownGenerator(context);
        break;
      default:
        throw DartdocFailure('Unsupported output format: ${context.format}');
    }
    return Dartdoc._(
      context,
      generator,
      packageBuilder,
    );
  }

  Stream<String> get onCheckProgress => _onCheckProgress.stream;

  @visibleForTesting
  Future<DartdocResults> generateDocsBase() async {
    var stopwatch = Stopwatch()..start();
    var packageGraph = await packageBuilder.buildPackageGraph();
    var seconds = stopwatch.elapsedMilliseconds / 1000.0;
    var libs = packageGraph.libraries.length;
    logInfo("Initialized dartdoc with $libs librar${libs == 1 ? 'y' : 'ies'} "
        'in ${seconds.toStringAsFixed(1)} seconds');
    stopwatch.reset();

    // Create the out directory.
    if (!_outputDir.exists) _outputDir.create();

    var writer = DartdocFileWriter(_outputDir.path, config.resourceProvider);
    await generator.generate(packageGraph, writer);

    _writtenFiles.addAll(writer.writtenFiles);
    if (config.validateLinks && _writtenFiles.isNotEmpty) {
      _validateLinks(packageGraph, _outputDir.path);
    }

    var warnings = packageGraph.packageWarningCounter.warningCount;
    var errors = packageGraph.packageWarningCounter.errorCount;
    if (warnings == 0 && errors == 0) {
      logInfo('no issues found');
    } else {
      logWarning("Found $warnings ${pluralize('warning', warnings)} "
          "and $errors ${pluralize('error', errors)}.");
    }

    seconds = stopwatch.elapsedMilliseconds / 1000.0;
    libs = packageGraph.localPublicLibraries.length;
    logInfo("Documented $libs public librar${libs == 1 ? 'y' : 'ies'} "
        'in ${seconds.toStringAsFixed(1)} seconds');

    if (config.showStats) {
      logInfo(markdownStats.buildReport());
    }
    return DartdocResults(config.topLevelPackageMeta, packageGraph, _outputDir);
  }

  /// Generate Dartdoc documentation.
  ///
  /// [DartdocResults] is returned if dartdoc succeeds. [DartdocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// analysis error in the code.
  Future<DartdocResults> generateDocs() async {
    DartdocResults dartdocResults;
    try {
      logInfo('Documenting ${config.topLevelPackageMeta}...');

      dartdocResults = await generateDocsBase();
      if (dartdocResults.packageGraph.localPublicLibraries.isEmpty) {
        logWarning('dartdoc could not find any libraries to document');
      }

      final errorCount =
          dartdocResults.packageGraph.packageWarningCounter.errorCount;
      if (errorCount > 0) {
        throw DartdocFailure('encountered $errorCount errors');
      }
      var outDirPath = config.resourceProvider.pathContext
          .absolute(dartdocResults.outDir.path);
      logInfo('Success! Docs generated into $outDirPath');
      return dartdocResults;
    } finally {
      dartdocResults?.packageGraph?.dispose();
    }
  }

  /// Warn on file paths.
  void _warn(PackageGraph packageGraph, PackageWarning kind, String warnOn,
      String origin,
      {String referredFrom}) {
    // Ordinarily this would go in [Package.warn], but we don't actually know what
    // ModelElement to warn on yet.
    Warnable warnOnElement;
    var referredFromElements = <Warnable>{};
    Set<Warnable> warnOnElements;

    // Make all paths relative to origin.
    if (path.isWithin(origin, warnOn)) {
      warnOn = path.relative(warnOn, from: origin);
    }
    if (referredFrom != null) {
      if (path.isWithin(origin, referredFrom)) {
        referredFrom = path.relative(referredFrom, from: origin);
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
      warnOnElement = warnOnElements.firstWhere((e) => e.isCanonical,
          orElse: () => warnOnElements.isEmpty ? null : warnOnElements.first);
    }

    if (referredFromElements.isEmpty && referredFrom == 'index.html') {
      referredFromElements.add(packageGraph.defaultPackage);
    }
    var message = warnOn;
    if (referredFrom == 'index.json') message = '$warnOn (from index.json)';
    packageGraph.warnOnElement(warnOnElement, kind,
        message: message, referredFrom: referredFromElements);
  }

  void _doOrphanCheck(
      PackageGraph packageGraph, String origin, Set<String> visited) {
    var normalOrigin = path.normalize(origin);
    var staticAssets = path.joinAll([normalOrigin, 'static-assets', '']);
    var indexJson = path.joinAll([normalOrigin, 'index.json']);
    var foundIndexJson = false;

    void checkDirectory(Folder dir) {
      for (var f in dir.getChildren()) {
        if (f is Folder) {
          checkDirectory(f);
          continue;
        }
        var fullPath = path.normalize(f.path);
        if (fullPath.startsWith(staticAssets)) {
          continue;
        }
        if (path.equals(fullPath, indexJson)) {
          foundIndexJson = true;
          _onCheckProgress.add(fullPath);
          continue;
        }
        if (visited.contains(fullPath)) continue;
        var relativeFullPath = path.relative(fullPath, from: normalOrigin);
        if (!_writtenFiles.contains(relativeFullPath)) {
          // This isn't a file we wrote (this time); don't claim we did.
          _warn(
              packageGraph, PackageWarning.unknownFile, fullPath, normalOrigin);
        } else {
          // Error messages are orphaned by design and do not appear in the search
          // index.
          if (const {'__404error.html', 'categories.json'}.contains(fullPath)) {
            _warn(packageGraph, PackageWarning.orphanedFile, fullPath,
                normalOrigin);
          }
        }
        _onCheckProgress.add(fullPath);
      }
    }

    checkDirectory(config.resourceProvider.getFolder(normalOrigin));

    if (!foundIndexJson) {
      _warn(packageGraph, PackageWarning.brokenLink, indexJson, normalOrigin);
      _onCheckProgress.add(indexJson);
    }
  }

  // This is extracted to save memory during the check; be careful not to hang
  // on to anything referencing the full file and doc tree.
  Tuple2<Iterable<String>, String> _getStringLinksAndHref(String fullPath) {
    var file = config.resourceProvider.getFile(fullPath);
    if (!file.exists) {
      return null;
    }
    // TODO(srawlins): It is possible that instantiating an HtmlParser using
    // `lowercaseElementName: false` and `lowercaseAttrName: false` may save
    // time or memory.
    var doc = parse(file.readAsBytesSync());
    var base = doc.querySelector('base');
    String baseHref;
    if (base != null) {
      baseHref = base.attributes['href'];
    }
    var links = doc.querySelectorAll('a');
    var stringLinks = links
        .map((link) => link.attributes['href'])
        .where((href) => href != null && href != '')
        .toList();

    return Tuple2(stringLinks, baseHref);
  }

  void _doSearchIndexCheck(
      PackageGraph packageGraph, String origin, Set<String> visited) {
    var fullPath = path.joinAll([origin, 'index.json']);
    var indexPath = path.joinAll([origin, 'index.html']);
    var file = config.resourceProvider.getFile(fullPath);
    if (!file.exists) {
      return;
    }
    var decoder = JsonDecoder();
    List<Object> jsonData = decoder.convert(file.readAsStringSync());

    var found = <String>{};
    found.add(fullPath);
    // The package index isn't supposed to be in the search, so suppress the
    // warning.
    found.add(indexPath);
    for (Map<String, dynamic> entry in jsonData) {
      if (entry.containsKey('href')) {
        var entryPath =
            path.joinAll([origin, ...path.posix.split(entry['href'])]);
        if (!visited.contains(entryPath)) {
          _warn(packageGraph, PackageWarning.brokenLink, entryPath,
              path.normalize(origin),
              referredFrom: fullPath);
        }
        found.add(entryPath);
      }
    }
    // Missing from search index
    var missingFromSearch = visited.difference(found);
    for (var s in missingFromSearch) {
      _warn(packageGraph, PackageWarning.missingFromSearchIndex, s,
          path.normalize(origin),
          referredFrom: fullPath);
    }
  }

  void _doCheck(PackageGraph packageGraph, String origin, Set<String> visited,
      String pathToCheck,
      [String source, String fullPath]) {
    fullPath ??= path.normalize(path.joinAll([origin, pathToCheck]));

    var stringLinksAndHref = _getStringLinksAndHref(fullPath);
    if (stringLinksAndHref == null) {
      _warn(packageGraph, PackageWarning.brokenLink, pathToCheck,
          path.normalize(origin),
          referredFrom: source);
      _onCheckProgress.add(pathToCheck);
      // Remove so that we properly count that the file doesn't exist for
      // the orphan check.
      visited.remove(fullPath);
      return;
    }
    visited.add(fullPath);
    var stringLinks = stringLinksAndHref.item1;
    var baseHref = stringLinksAndHref.item2;

    // Prevent extremely large stacks by storing the paths we are using
    // here instead -- occasionally, very large jobs have overflowed
    // the stack without this.
    // (newPathToCheck, newFullPath)
    var toVisit = <Tuple2<String, String>>{};

    final ignoreHyperlinks = RegExp(r'^(https:|http:|mailto:|ftp:)');
    for (final href in stringLinks) {
      if (!href.startsWith(ignoreHyperlinks)) {
        final uri = Uri.tryParse(href);

        if (uri == null || !uri.hasAuthority && !uri.hasFragment) {
          String full;
          if (baseHref != null) {
            full = '${path.dirname(pathToCheck)}/$baseHref/$href';
          } else {
            full = '${path.dirname(pathToCheck)}/$href';
          }

          final newPathToCheck = path.normalize(full);
          final newFullPath =
              path.normalize(path.joinAll([origin, newPathToCheck]));
          if (!visited.contains(newFullPath)) {
            toVisit.add(Tuple2(newPathToCheck, newFullPath));
            visited.add(newFullPath);
          }
        }
      }
    }
    for (var visitPaths in toVisit) {
      _doCheck(packageGraph, origin, visited, visitPaths.item1, pathToCheck,
          visitPaths.item2);
    }
    _onCheckProgress.add(pathToCheck);
  }

  Map<String, Set<ModelElement>> _hrefs;

  /// Don't call this method more than once, and only after you've
  /// generated all docs for the Package.
  void _validateLinks(PackageGraph packageGraph, String origin) {
    assert(_hrefs == null);
    _hrefs = packageGraph.allHrefs;

    final visited = <String>{};
    logInfo('Validating docs...');
    _doCheck(packageGraph, origin, visited, 'index.html');
    _doOrphanCheck(packageGraph, origin, visited);
    _doSearchIndexCheck(packageGraph, origin, visited);
  }

  /// Runs [generateDocs] function and properly handles the errors.
  ///
  /// Passing in a [postProcessCallback] to do additional processing after
  /// the documentation is generated.
  void executeGuarded([
    Future<void> Function(DartdocOptionContext) postProcessCallback,
  ]) {
    onCheckProgress.listen(logProgress);
    // This function should *never* await `runZonedGuarded` because the errors
    // thrown in generateDocs are uncaught. We want this because uncaught errors
    // cause IDE debugger to automatically stop at the exception.
    //
    // If you await the zone, the code that comes after the await is not
    // executed if the zone dies due to uncaught error. To avoid this confusion,
    // never await `runZonedGuarded` and never change the return value of
    // [executeGuarded].
    runZonedGuarded(
      () async {
        await generateDocs();
        await postProcessCallback?.call(config);
      },
      (e, chain) {
        if (e is DartdocFailure) {
          stderr.writeln('\n$_dartdocFailedMessage: $e.');
          exitCode = 1;
        } else {
          stderr.writeln('\n$_dartdocFailedMessage: $e\n$chain');
          exitCode = 255;
        }
      },
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, String line) => logPrint(line),
      ),
    );
  }
}

/// The results of a [Dartdoc.generateDocs] call.
class DartdocResults {
  final PackageMeta packageMeta;
  final PackageGraph packageGraph;
  final Folder outDir;

  DartdocResults(this.packageMeta, this.packageGraph, this.outDir);
}

String get _dartdocFailedMessage =>
    'dartdoc $packageVersion (${Platform.script.path}) failed';
