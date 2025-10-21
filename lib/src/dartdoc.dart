// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, exitCode, stderr;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/validator.dart';
import 'package:dartdoc/src/version.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

const String programName = 'dartdoc';
// Update when pubspec version changes by running `pub run build_runner build`
const String dartdocVersion = packageVersion;

/// Used for the generateDocs:false option.
///
/// Writes nothing.
class NoFileWriter implements FileWriter {
  @override
  void write(String filePath, String content, {Warnable? element}) {
    // Do nothing
  }

  @override
  void writeBytes(String filePath, List<int> content,
      {bool allowOverwrite = false}) {
    // Do nothing
  }

  @override
  Set<String> get writtenFiles => {};
}

class DartdocFileWriter implements FileWriter {
  final String _outputDir;
  final ResourceProvider _resourceProvider;
  final Map<String, Warnable?> _fileElementMap = {};
  @override
  final Set<String> writtenFiles = {};

  final int _maxFileCount;
  final int _maxTotalSize;

  int _fileCount = 0;
  int _totalSize = 0;

  DartdocFileWriter(
    this._outputDir,
    this._resourceProvider, {
    int maxFileCount = 0,
    int maxTotalSize = 0,
  })  : _maxFileCount = maxFileCount,
        _maxTotalSize = maxTotalSize;

  void _validateMaxWriteStats(String filePath, int size) {
    _fileCount++;
    _totalSize += size;
    if (_maxFileCount > 0 && _maxFileCount < _fileCount) {
      throw DartdocFailure(
          'Maximum file count reached: $_maxFileCount ($filePath)');
    }
    if (_maxTotalSize > 0 && _maxTotalSize < _totalSize) {
      throw DartdocFailure(
          'Maximum total size reached: $_maxTotalSize bytes ($filePath)');
    }
  }

  @override
  void writeBytes(
    String filePath,
    List<int> content, {
    bool allowOverwrite = false,
  }) {
    _validateMaxWriteStats(filePath, content.length);
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
  void write(String filePath, String content, {Warnable? element}) {
    final bytes = utf8.encode(content);
    _validateMaxWriteStats(filePath, bytes.length);

    // Replace '/' separators with proper separators for the platform.
    var outFile = path.joinAll(filePath.split('/'));

    _warnAboutOverwrite(outFile, element);
    _fileElementMap[outFile] = element;

    var file = _getFile(outFile);
    file.writeAsBytesSync(bytes);
    writtenFiles.add(outFile);
    logProgress(outFile);
  }

  void _warnAboutOverwrite(String outFile, Warnable? element) {
    if (_fileElementMap.containsKey(outFile)) {
      assert(element != null,
          'Attempted overwrite of $outFile without corresponding element');
      var originalElement = _fileElementMap[outFile];
      var referredFrom =
          originalElement == null ? const <Warnable>[] : [originalElement];
      element?.warn(PackageWarning.duplicateFile,
          message: outFile, referredFrom: referredFrom);
    }
  }

  /// Returns the file at [outFile] relative to [_outputDir], creating the
  /// parent directory if necessary.
  File _getFile(String outFile) {
    var file = _resourceProvider
        .getFile(_resourceProvider.pathContext.join(_outputDir, outFile));
    var parent = file.parent;
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
  final Folder _outputDir;

  // Fires when the self checks make progress.
  final StreamController<String> _onCheckProgress =
      StreamController(sync: true);

  Dartdoc._(this.config, this._outputDir, this._generator, this.packageBuilder);

  Generator get generator => _generator;

  @visibleForTesting
  set generator(Generator newGenerator) => _generator = newGenerator;

  /// Builds Dartdoc with a generator determined by [context].
  factory Dartdoc.fromContext(
    DartdocGeneratorOptionContext context,
    PackageBuilder packageBuilder,
  ) {
    var resourceProvider = context.resourceProvider;
    var outputPath = resourceProvider.pathContext.absolute(context.output);
    var outputDir = resourceProvider.getFolder(outputPath)..create();
    var writer = context.generateDocs
        ? DartdocFileWriter(
            outputPath,
            resourceProvider,
            maxFileCount: context.maxFileCount,
            maxTotalSize: context.maxTotalSize,
          )
        : NoFileWriter();
    return Dartdoc._(
      context,
      outputDir,
      initHtmlGenerator(context, writer: writer),
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

    runtimeStats.startPerfTask('generator.generate');
    await generator.generate(packageGraph);
    runtimeStats.endPerfTask();

    var writtenFiles = generator.writtenFiles;
    if (config.validateLinks && writtenFiles.isNotEmpty) {
      runtimeStats.startPerfTask('validateLinks');
      Validator(packageGraph, config, _outputDir.path, writtenFiles,
              _onCheckProgress)
          .validateLinks();
      runtimeStats.endPerfTask();
    }

    var warnings = packageGraph.packageWarningCounter.warningCount;
    var errors = packageGraph.packageWarningCounter.errorCount;
    logWarning("Found $warnings ${pluralize('warning', warnings)} "
        "and $errors ${pluralize('error', errors)}.");

    var seconds = stopwatch.elapsedMilliseconds / 1000.0;
    libs = packageGraph.localPublicLibraries.length;
    logInfo("Documented $libs public librar${libs == 1 ? 'y' : 'ies'} "
        'in ${seconds.toStringAsFixed(1)} seconds');

    if (config.showStats) {
      logInfo(runtimeStats.buildReport());
    }
    return DartdocResults(config.topLevelPackageMeta, packageGraph, _outputDir);
  }

  /// Generates Dartdoc documentation.
  ///
  /// [DartdocResults] is returned if dartdoc succeeds. [DartdocFailure] is
  /// thrown if dartdoc fails in an expected way, for example if there is an
  /// analysis error in the code.
  Future<DartdocResults> generateDocs() async {
    DartdocResults? dartdocResults;
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
      dartdocResults?.packageGraph.dispose();
    }
  }

  /// Runs [generateDocs] function and properly handles the errors.
  void executeGuarded() {
    onCheckProgress.listen(logProgress);
    // This function should *never* `await runZonedGuarded` because the errors
    // thrown in [generateDocs] are uncaught. We want this because uncaught
    // errors cause IDE debugger to automatically stop at the exception.
    //
    // If you await the zone, the code that comes after the await is not
    // executed if the zone dies due to an uncaught error. To avoid this,
    // confusion, never `await runZonedGuarded`.
    runZonedGuarded(
      () async {
        runtimeStats.startPerfTask('generateDocs');
        await generateDocs();
        runtimeStats.endPerfTask();
      },
      (e, stackTrace) {
        stderr.writeln('\n$_dartdocFailedMessage: $e\n$stackTrace');
        exitCode = e is DartdocFailure ? 1 : 255;
      },
      zoneSpecification: ZoneSpecification(
        print: (_, __, ___, String line) => logInfo(line),
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
