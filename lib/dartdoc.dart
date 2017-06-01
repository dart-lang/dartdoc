// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A documentation generator for Dart.
library dartdoc;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart' show LibraryElement;
import 'package:analyzer/error/error.dart';
import 'package:analyzer/file_system/file_system.dart' as fileSystem;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/package_map_resolver.dart';
import 'package:analyzer/source/sdk_ext.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:html/dom.dart' show Element, Document;
import 'package:html/parser.dart' show parse;
import 'package:package_config/discovery.dart' as package_config;
import 'package:path/path.dart' as path;

import 'package:tuple/tuple.dart';
import 'src/config.dart';
import 'src/generator.dart';
import 'src/html/html_generator.dart';
import 'src/io_utils.dart';
import 'src/model.dart';
import 'src/model_utils.dart';
import 'src/package_meta.dart';

export 'src/config.dart';
export 'src/element_type.dart';
export 'src/generator.dart';
export 'src/model.dart';
export 'src/package_meta.dart';
export 'src/sdk.dart';

const String name = 'dartdoc';
// Update when pubspec version changes.
const String version = '0.12.0';

final String defaultOutDir = path.join('doc', 'api');

/// Initialize and setup the generators.
Future<List<Generator>> initGenerators(String url, String relCanonicalPrefix,
    {List<String> headerFilePaths,
    List<String> footerFilePaths,
    List<String> footerTextFilePaths,
    String faviconPath,
    bool useCategories: false,
    bool prettyIndexJson: false}) async {
  var options = new HtmlGeneratorOptions(
      url: url,
      relCanonicalPrefix: relCanonicalPrefix,
      toolVersion: version,
      faviconPath: faviconPath,
      useCategories: useCategories,
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

Map<String, List<fileSystem.Folder>> _calculatePackageMap(
    fileSystem.Folder dir) {
  Map<String, List<fileSystem.Folder>> map = new Map();
  var info = package_config.findPackagesFromFile(dir.toUri());

  for (String name in info.packages) {
    Uri uri = info.asMap()[name];
    fileSystem.Resource resource =
        PhysicalResourceProvider.INSTANCE.getResource(uri.toFilePath());
    if (resource is fileSystem.Folder) {
      map[name] = [resource];
    }
  }

  return map;
}

/// Generates Dart documentation for all public Dart libraries in the given
/// directory.
class DartDoc {
  final Directory rootDir;
  final Directory sdkDir;
  final List<Generator> generators;
  final Directory outputDir;
  final PackageMeta packageMeta;
  final List<String> includes;
  final List<String> includeExternals;
  final List<String> excludes;
  final Set<String> writtenFiles = new Set();

  // Fires when the self checks make progress.
  StreamController<String> _onCheckProgress;

  Stopwatch _stopwatch;

  DartDoc(this.rootDir, this.excludes, this.sdkDir, this.generators,
      this.outputDir, this.packageMeta, this.includes,
      {this.includeExternals: const []}) {
    _onCheckProgress = new StreamController(sync: true);
  }

  Stream<String> get onCheckProgress => _onCheckProgress.stream;

  /// Generate DartDoc documentation.
  ///
  /// [DartDocResults] is returned if dartdoc succeeds. [DartDocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// analysis error in the code. Any other exception can be throw if there is an
  /// unexpected failure.
  Future<DartDocResults> generateDocs() async {
    _stopwatch = new Stopwatch()..start();

    List<String> files = packageMeta.isSdk
        ? const []
        : findFilesToDocumentInPackage(rootDir.path).toList();

    // TODO(jcollins-g): seems like most of this belongs in the Package constructor
    List<LibraryElement> libraries = _parseLibraries(files, includeExternals);

    if (includes != null && includes.isNotEmpty) {
      Iterable knownLibraryNames = libraries.map((l) => l.name);
      Set notFound =
          new Set.from(includes).difference(new Set.from(knownLibraryNames));
      if (notFound.isNotEmpty) {
        throw 'Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]';
      }
      libraries.removeWhere((lib) => !includes.contains(lib.name));
    } else {
      // remove excluded libraries
      excludes.forEach((pattern) {
        libraries.removeWhere((lib) {
          return lib.name.startsWith(pattern) || lib.name == pattern;
        });
      });
    }

    PackageWarningOptions warningOptions = new PackageWarningOptions();
    // TODO(jcollins-g): explode this into detailed command line options.
    if (config != null && config.showWarnings) {
      for (PackageWarning kind in PackageWarning.values) {
        warningOptions.warn(kind);
      }
    }
    Package package;
    if (config != null && config.autoIncludeDependencies) {
      package = Package.withAutoIncludedDependencies(
          libraries, packageMeta, warningOptions);
      libraries = package.libraries.map((l) => l.element).toList();
      // remove excluded libraries again, in case they are picked up through
      // dependencies.
      excludes.forEach((pattern) {
        libraries.removeWhere((lib) {
          return lib.name.startsWith(pattern) || lib.name == pattern;
        });
      });
    }
    package = new Package(libraries, packageMeta, warningOptions);

    // Go through docs of every model element in package to prebuild the macros index
    // TODO(jcollins-g): move index building into a cached-on-demand generation
    // like most other bits in [Package].
    package.allCanonicalModelElements.forEach((m) => m.documentation);

    // Create the out directory.
    if (!outputDir.existsSync()) outputDir.createSync(recursive: true);

    for (var generator in generators) {
      await generator.generate(package, outputDir);
      writtenFiles.addAll(generator.writtenFiles.map(path.normalize));
    }

    verifyLinks(package, outputDir.path);
    int warnings = package.packageWarningCounter.warningCount;
    int errors = package.packageWarningCounter.errorCount;
    if (warnings == 0 && errors == 0) {
      print("\nno issues found");
    } else {
      print("\nfound ${warnings} ${pluralize('warning', warnings)} "
          "and ${errors} ${pluralize('error', errors)}");
    }

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print(
        "\ndocumented ${package.libraries.length} librar${package.libraries.length == 1 ? 'y' : 'ies'} "
        "in ${seconds.toStringAsFixed(1)} seconds");

    if (package.libraries.isEmpty) {
      throw new DartDocFailure(
          "dartdoc could not find any libraries to document. Run `pub get` and try again.");
    }

    if (package.packageWarningCounter.errorCount > 0) {
      throw new DartDocFailure("dartdoc encountered errors while processing");
    }

    return new DartDocResults(packageMeta, package, outputDir);
  }

  /// Warn on file paths.
  void _warn(Package package, PackageWarning kind, String warnOn, String origin,
      {String referredFrom}) {
    // Ordinarily this would go in [Package.warn], but we don't actually know what
    // ModelElement to warn on yet.
    Locatable referredFromElement;
    Locatable warnOnElement;
    Set<Locatable> referredFromElements;
    Set<Locatable> warnOnElements;

    // Make all paths relative to origin.
    if (path.isWithin(origin, warnOn)) {
      warnOn = path.relative(warnOn, from: origin);
    }
    if (referredFrom != null) {
      if (path.isWithin(origin, referredFrom)) {
        referredFrom = path.relative(referredFrom, from: origin);
      }
      // Source paths are always relative.
      referredFromElements = _hrefs[referredFrom];
    }
    warnOnElements = _hrefs[warnOn];

    if (referredFromElements != null) {
      if (referredFromElements.any((e) => e.isCanonical)) {
        referredFromElement =
            referredFromElements.firstWhere((e) => e.isCanonical);
      } else {
        // If we don't have a canonical element, just pick one.
        referredFromElement =
            referredFromElements.isEmpty ? null : referredFromElements.first;
      }
    }
    if (warnOnElements != null) {
      if (warnOnElements.any((e) => e.isCanonical)) {
        warnOnElement = warnOnElements.firstWhere((e) => e.isCanonical);
      } else {
        // If we don't have a canonical element, just pick one.
        warnOnElement = warnOnElements.isEmpty ? null : warnOnElements.first;
      }
    }

    if (referredFromElement == null && referredFrom == 'index.html')
      referredFromElement = package;
    String message = warnOn;
    if (referredFrom == 'index.json') message = '$warnOn (from index.json)';
    package.warnOnElement(warnOnElement, kind,
        message: message, referredFrom: referredFromElement);
  }

  void _doOrphanCheck(Package package, String origin, Set<String> visited) {
    String normalOrigin = path.normalize(origin);
    String staticAssets = path.joinAll([normalOrigin, 'static-assets', '']);
    String indexJson = path.joinAll([normalOrigin, 'index.json']);
    bool foundIndexJson = false;
    for (FileSystemEntity f
        in new Directory(normalOrigin).listSync(recursive: true)) {
      var fullPath = path.normalize(f.path);
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
        _warn(package, PackageWarning.unknownFile, fullPath, normalOrigin);
      } else {
        _warn(package, PackageWarning.orphanedFile, fullPath, normalOrigin);
      }
      _onCheckProgress.add(fullPath);
    }

    if (!foundIndexJson) {
      _warn(package, PackageWarning.brokenLink, indexJson, normalOrigin);
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
      Package package, String origin, Set<String> visited) {
    String fullPath = path.joinAll([origin, 'index.json']);
    String indexPath = path.joinAll([origin, 'index.html']);
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
        String entryPath = path.joinAll([origin, entry['href']]);
        if (!visited.contains(entryPath)) {
          _warn(package, PackageWarning.brokenLink, entryPath,
              path.normalize(origin),
              referredFrom: fullPath);
        }
        found.add(entryPath);
      }
    }
    // Missing from search index
    Set<String> missing_from_search = visited.difference(found);
    for (String s in missing_from_search) {
      _warn(package, PackageWarning.missingFromSearchIndex, s,
          path.normalize(origin),
          referredFrom: fullPath);
    }
  }

  void _doCheck(
      Package package, String origin, Set<String> visited, String pathToCheck,
      [String source, String fullPath]) {
    if (fullPath == null) {
      fullPath = path.joinAll([origin, pathToCheck]);
      fullPath = path.normalize(fullPath);
    }

    Tuple2 stringLinksAndHref = _getStringLinksAndHref(fullPath);
    if (stringLinksAndHref == null) {
      _warn(package, PackageWarning.brokenLink, pathToCheck,
          path.normalize(origin),
          referredFrom: source);
      _onCheckProgress.add(pathToCheck);
      return null;
    }
    visited.add(fullPath);
    Iterable<String> stringLinks = stringLinksAndHref.item1;
    String baseHref = stringLinksAndHref.item2;

    for (String href in stringLinks) {
      if (!href.startsWith('http') && !href.contains('#')) {
        var full;
        if (baseHref != null) {
          full = '${path.dirname(pathToCheck)}/$baseHref/$href';
        } else {
          full = '${path.dirname(pathToCheck)}/$href';
        }
        var newPathToCheck = path.normalize(full);
        String newFullPath = path.joinAll([origin, newPathToCheck]);
        newFullPath = path.normalize(newFullPath);
        if (!visited.contains(newFullPath)) {
          _doCheck(package, origin, visited, newPathToCheck, pathToCheck,
              newFullPath);
        }
      }
    }
    _onCheckProgress.add(pathToCheck);
  }

  Map<String, Set<ModelElement>> _hrefs;

  /// Don't call this method more than once, and only after you've
  /// generated all docs for the Package.
  void verifyLinks(Package package, String origin) {
    assert(_hrefs == null);
    _hrefs = package.allHrefs;

    final Set<String> visited = new Set();
    final String start = 'index.html';
    stdout.write('\nvalidating docs...');
    _doCheck(package, origin, visited, start);
    _doOrphanCheck(package, origin, visited);
    _doSearchIndexCheck(package, origin, visited);
  }

  List<LibraryElement> _parseLibraries(
      List<String> files, List<String> includeExternals) {
    Set<LibraryElement> libraries = new Set();
    DartSdk sdk = new FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
        PhysicalResourceProvider.INSTANCE.getFolder(sdkDir.path));
    List<UriResolver> resolvers = [];

    fileSystem.Folder cwd =
        PhysicalResourceProvider.INSTANCE.getResource(rootDir.path);
    Map<String, List<fileSystem.Folder>> packageMap = _calculatePackageMap(cwd);

    EmbedderSdk embedderSdk;
    DartUriResolver embedderResolver;
    if (packageMap != null) {
      resolvers.add(new SdkExtUriResolver(packageMap));
      resolvers.add(new PackageMapUriResolver(
          PhysicalResourceProvider.INSTANCE, packageMap));
      var embedderYamls = new EmbedderYamlLocator(packageMap).embedderYamls;
      embedderSdk =
          new EmbedderSdk(PhysicalResourceProvider.INSTANCE, embedderYamls);
      embedderResolver = new DartUriResolver(embedderSdk);
      if (embedderSdk.urlMappings.length == 0) {
        // The embedder uri resolver has no mappings. Use the default Dart SDK
        // uri resolver.
        resolvers.add(new DartUriResolver(sdk));
      } else {
        // The embedder uri resolver has mappings, use it instead of the default
        // Dart SDK uri resolver.
        resolvers.add(embedderResolver);
      }
    } else {
      resolvers.add(new DartUriResolver(sdk));
    }
    resolvers.add(
        new fileSystem.ResourceUriResolver(PhysicalResourceProvider.INSTANCE));

    SourceFactory sourceFactory = new SourceFactory(resolvers);

    // TODO(jcollins-g): fix this so it actually obeys analyzer options files.
    var options = new AnalysisOptionsImpl()..enableAssertInitializer = true;

    AnalysisEngine.instance.processRequiredPlugins();

    AnalysisContext context = AnalysisEngine.instance.createAnalysisContext()
      ..analysisOptions = options
      ..sourceFactory = sourceFactory;

    if (packageMeta.isSdk) {
      libraries
          .addAll(new Set()..addAll(getSdkLibrariesToDocument(sdk, context)));
    }

    List<Source> sources = [];

    void processLibrary(String filePath) {
      String name = filePath;
      if (name.startsWith(Directory.current.path)) {
        name = name.substring(Directory.current.path.length);
        if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
      }
      print('parsing ${name}...');
      JavaFile javaFile = new JavaFile(filePath).getAbsoluteFile();
      Source source = new FileBasedSource(javaFile);

      // TODO(jcollins-g): remove the manual reversal using embedderSdk when we
      // upgrade to analyzer-0.30 (where DartUriResolver implements
      // restoreAbsolute)
      Uri uri = embedderSdk?.fromFileUri(source.uri)?.uri;
      if (uri != null) {
        source = new FileBasedSource(javaFile, uri);
      } else {
        uri = context.sourceFactory.restoreUri(source);
        if (uri != null) {
          source = new FileBasedSource(javaFile, uri);
        }
      }
      sources.add(source);
      if (context.computeKindOf(source) == SourceKind.LIBRARY) {
        LibraryElement library = context.computeLibraryElement(source);
        if (!isPrivate(library)) libraries.add(library);
      }
    }

    files.forEach(processLibrary);

    if ((embedderSdk != null) && (embedderSdk.urlMappings.length > 0)) {
      embedderSdk.urlMappings.keys.forEach((String dartUri) {
        Source source = embedderSdk.mapDartUri(dartUri);
        processLibrary(source.fullName);
      });
    }

    // Ensure that the analysis engine performs all remaining work.
    AnalysisResult result = context.performAnalysisTask();
    while (result.hasMoreWork) {
      result = context.performAnalysisTask();
    }

    // Use the includeExternals.
    for (Source source in context.librarySources) {
      LibraryElement library = context.computeLibraryElement(source);
      String libraryName = Library.getLibraryName(library);
      var fullPath = source.fullName;

      if (includeExternals.any((string) => fullPath.endsWith(string))) {
        if (libraries.map(Library.getLibraryName).contains(libraryName)) {
          continue;
        }
        libraries.add(library);
      } else if (config != null &&
          config.autoIncludeDependencies &&
          libraryName != '') {
        File searchFile = new File(fullPath);
        searchFile =
            new File(path.join(searchFile.parent.path, 'pubspec.yaml'));
        bool foundLibSrc = false;
        while (!foundLibSrc && searchFile.parent != null) {
          if (searchFile.existsSync()) break;
          List<String> pathParts = path.split(searchFile.parent.path);
          // This is a pretty intensely hardcoded convention, but there seems to
          // to be no other way to identify what might be a "top level" library
          // here.  If lib/src is in the path between the file and the pubspec,
          // assume that this is supposed to be private.
          if (pathParts.length < 2) break;
          pathParts = pathParts.sublist(pathParts.length - 2, pathParts.length);
          foundLibSrc =
              path.join(pathParts[0], pathParts[1]) == path.join('lib', 'src');
          searchFile = new File(
              path.join(searchFile.parent.parent.path, 'pubspec.yaml'));
        }
        if (foundLibSrc) continue;
        libraries.add(library);
      }
    }

    List<AnalysisErrorInfo> errorInfos = [];

    for (Source source in sources) {
      context.computeErrors(source);
      errorInfos.add(context.getErrors(source));
    }

    List<_Error> errors = errorInfos
        .expand((AnalysisErrorInfo info) {
          return info.errors.map((error) =>
              new _Error(error, info.lineInfo, packageMeta.dir.path));
        })
        .where((_Error error) => error.isError)
        .toList()
          ..sort();

    double seconds = _stopwatch.elapsedMilliseconds / 1000.0;
    print("parsed ${libraries.length} ${pluralize('file', libraries.length)} "
        "in ${seconds.toStringAsFixed(1)} seconds");
    _stopwatch.reset();

    if (errors.isNotEmpty) {
      errors.forEach(print);
      int len = errors.length;
      throw new DartDocFailure(
          "encountered ${len} analysis error${len == 1 ? '' : 's'}");
    }

    return libraries.toList();
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
  final Package package;
  final Directory outDir;

  DartDocResults(this.packageMeta, this.package, this.outDir);
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
