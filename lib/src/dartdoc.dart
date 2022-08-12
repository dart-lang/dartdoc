// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library src.dartdoc;

import 'dart:async';
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
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/validator.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

const String programName = 'dartdoc';
// Update when pubspec version changes by running `pub run build_runner build`
const String dartdocVersion = packageVersion;

class DartdocFileWriter implements FileWriter {
  final String _outputDir;
  @override
  final ResourceProvider resourceProvider;
  final Map<String, Warnable?> _fileElementMap = {};
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
    var outFile = p.joinAll(filePath.split('/'));

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
  void write(String filePath, String content, {Warnable? element}) {
    // Replace '/' separators with proper separators for the platform.
    var outFile = p.joinAll(filePath.split('/'));

    _warnAboutOverwrite(outFile, element);
    _fileElementMap[outFile] = element;

    var file = _getFile(outFile);
    file.writeAsStringSync(content);
    writtenFiles.add(outFile);
    logProgress(outFile);
  }

  void _warnAboutOverwrite(String outFile, Warnable? element) {
    if (_fileElementMap.containsKey(outFile)) {
      assert(element != null,
          'Attempted overwrite of $outFile without corresponding element');
      var originalElement = _fileElementMap[outFile];
      var referredFrom = <Warnable>[];
      if (originalElement != null) referredFrom.add(originalElement);
      element?.warn(PackageWarning.duplicateFile,
          message: outFile, referredFrom: referredFrom);
    }
  }

  /// Returns the file at [outFile] relative to [_outputDir], creating the
  /// parent directory if necessary.
  File _getFile(String outFile) {
    var file = resourceProvider
        .getFile(resourceProvider.pathContext.join(_outputDir, outFile));
    var parent = file.parent;
    if (!parent.exists) {
      parent.create();
    }
    return file;
  }
}

/// Generates Dart documentation for Dart libraries in the given directory.
class Dartdoc {
  Generator _generator;
  final PackageBuilder packageBuilder;
  final DartdocOptionContext config;
  late final Folder _outputDir = config.resourceProvider
      .getFolder(config.resourceProvider.pathContext.absolute(config.output))
    ..create();

  // Fires when the self checks make progress.
  final StreamController<String> _onCheckProgress =
      StreamController(sync: true);

  Dartdoc._(this.config, this._generator, this.packageBuilder);

  Generator get generator => _generator;

  @visibleForTesting
  set generator(Generator newGenerator) => _generator = newGenerator;

  /// Factory method that builds Dartdoc with an empty generator.
  static Dartdoc withEmptyGenerator(
    DartdocOptionContext config,
    PackageBuilder packageBuilder,
  ) {
    return Dartdoc._(
      config,
      initEmptyGenerator(),
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
    runtimeStats.startPerfTask('buildPackageGraph');
    var packageGraph = await packageBuilder.buildPackageGraph();
    runtimeStats.endPerfTask();
    var libs = packageGraph.libraryCount;
    logInfo("Initialized dartdoc with $libs librar${libs == 1 ? 'y' : 'ies'}");

    // Create the out directory.
    if (!_outputDir.exists) _outputDir.create();

    runtimeStats.startPerfTask('generator.generate');
    var writer = DartdocFileWriter(_outputDir.path, config.resourceProvider);
    await generator.generate(packageGraph, writer);
    runtimeStats.endPerfTask();

    var writtenFiles = writer.writtenFiles;
    if (config.validateLinks && writtenFiles.isNotEmpty) {
      runtimeStats.startPerfTask('validateLinks');
      Validator(packageGraph, config, _outputDir.path, writtenFiles,
              _onCheckProgress)
          .validateLinks();
      runtimeStats.endPerfTask();
    }

    var warnings = packageGraph.packageWarningCounter.warningCount;
    var errors = packageGraph.packageWarningCounter.errorCount;
    if (warnings == 0 && errors == 0) {
      logInfo('no issues found');
    } else {
      logWarning("Found $warnings ${pluralize('warning', warnings)} "
          "and $errors ${pluralize('error', errors)}.");
    }

    var seconds = stopwatch.elapsedMilliseconds / 1000.0;
    libs = packageGraph.localDocumentedLibraries.length;
    logInfo("Documented $libs public librar${libs == 1 ? 'y' : 'ies'} "
        'in ${seconds.toStringAsFixed(1)} seconds');

    if (config.showStats) {
      logInfo(runtimeStats.buildReport());
    }
    return DartdocResults(config.topLevelPackageMeta, packageGraph, _outputDir);
  }

  /// Generate Dartdoc documentation.
  ///
  /// [DartdocResults] is returned if dartdoc succeeds. [DartdocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// analysis error in the code.
  Future<DartdocResults> generateDocs() async {
    DartdocResults? dartdocResults;
    try {
      logInfo('Documenting ${config.topLevelPackageMeta}...');

      dartdocResults = await generateDocsBase();
      if (dartdocResults.packageGraph.localDocumentedLibraries.isEmpty) {
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
      dartdocResults?.packageGraph.dispose();
    }
  }

  /// Runs [generateDocs] function and properly handles the errors.
  ///
  /// Passing in a [postProcessCallback] to do additional processing after
  /// the documentation is generated.
  void executeGuarded([
    Future<void> Function(DartdocOptionContext)? postProcessCallback,
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
        runtimeStats.startPerfTask('generateDocs');
        await generateDocs();
        runtimeStats.endPerfTask();
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
