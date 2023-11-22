// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io' as io;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/progress_bar.dart';
import 'package:logging/logging.dart';

final _logger = Logger('dartdoc');

/// A custom [Level] for tracking file writes and verification.
///
/// Has a value of `501` – one more than [Level.FINE].
const Level _progressLevel = Level('PROGRESS', 501);

/// A custom [Level] for errant print statements.
///
/// Has a value of `1201` – one more than [Level.SHOUT].
const Level printLevel = Level('PRINT', 1201);

void logWarning(String message) {
  _logger.log(Level.WARNING, message);
}

void logInfo(String message) {
  _logger.log(Level.INFO, message);
}

void logDebug(String message) {
  _logger.log(Level.FINE, message);
}

void logProgress(String message) {
  _logger.log(_progressLevel, message);
}

void logPrint(String message) {
  _logger.log(printLevel, message);
}

/// Creates a new deterministic progress bar, and displays it (with zero
/// progress).
void progressBarStart(int totalTickCount) {
  _DartdocLogger.instance.progressBarStart(totalTickCount);
}

/// Increments the progress of the current progress bar.
void progressBarTick() {
  _DartdocLogger.instance.progressBarTick();
}

/// Updates the total length of the current progress bar.
void progressBarUpdateTickCount(int totalTickCount) {
  _DartdocLogger.instance.progressBarUpdateTickCount(totalTickCount);
}

/// Completes the current progress bar.
///
/// It is important to call this after progress is complete, in case rounding
/// errors leave the displayed progress bar at something less than 100%.
void progressBarComplete() {
  _DartdocLogger.instance.progressBarComplete();
}

abstract class Jsonable {
  /// The `String` to print when in human-readable mode
  String get text;

  /// The JSON content to print when in JSON-output mode.
  Object toJson();

  @override
  String toString() => text;
}

class _DartdocLogger {
  /// By default, we use a quiet logger.
  ///
  /// This field can be re-set, with [startLogging].
  static _DartdocLogger instance =
      _DartdocLogger._(isJson: false, isQuiet: true, showProgress: false);

  final StringSink _outSink;
  final StringSink _errSink;

  final bool _showProgressBar;

  ProgressBar? _progressBar;

  _DartdocLogger._({
    required bool isJson,
    required bool isQuiet,
    required bool showProgress,
    StringSink? outSink,
    StringSink? errSink,
  })  : _outSink = outSink ?? io.stdout,
        _errSink = errSink ?? io.stderr,
        _showProgressBar = showProgress && !isJson && !isQuiet {
    // By default, get all log output at `progressLevel` or greater.
    // This allows us to capture progress events and print `...`.
    // Change this to `Level.FINE` for debug logging.
    Logger.root.level = _progressLevel;
    if (isJson) {
      Logger.root.onRecord.listen(_onJsonRecord);
      return;
    }

    _initialize(isQuiet: isQuiet, showProgress: showProgress);
  }

  /// Initializes this as a non-JSON logger.
  ///
  /// This method mostly sets up callback behavior for each logged message.
  void _initialize({required bool isQuiet, required bool showProgress}) {
    final stopwatch = Stopwatch()..start();

    // Used to track if we're printing `...` to show progress.
    // Allows unified new-line tracking
    var writingProgress = false;
    var spinnerIndex = 0;
    const spinner = ['-', r'\', '|', '/'];

    Logger.root.onRecord.listen((record) {
      if (record.level == progressBarUpdate) {
        _outSink.write(record.message);
        return;
      }

      if (record.level == _progressLevel) {
        if (!isQuiet &&
            showProgress &&
            stopwatch.elapsed.inMilliseconds > 125) {
          if (writingProgress = false) {
            _outSink.write(' ');
          }
          writingProgress = true;
          _outSink.write('$_backspace${spinner[spinnerIndex]}');
          spinnerIndex = (spinnerIndex + 1) % spinner.length;
          stopwatch.reset();
        }
        return;
      }

      stopwatch.reset();
      if (writingProgress) {
        _outSink.write('$_backspace $_backspace');
      }
      var message = record.message;
      assert(message.isNotEmpty);

      if (record.level < Level.WARNING) {
        if (!isQuiet) {
          _outSink.writeln(message);
        }
      } else {
        if (writingProgress) {
          // Some console implementations, like IntelliJ, apparently need
          // the backspace to occur for stderr as well.
          _errSink.write('$_backspace $_backspace');
        }
        _errSink.writeln(message);
      }
      writingProgress = false;
    });
  }

  void progressBarStart(int totalTickCount) {
    if (!_showProgressBar) {
      return;
    }
    _progressBar = ProgressBar(_logger, totalTickCount);
  }

  void progressBarTick() {
    if (!_showProgressBar) {
      return;
    }
    _progressBar?.tick();
  }

  void progressBarUpdateTickCount(int totalTickCount) {
    if (!_showProgressBar) {
      return;
    }
    _progressBar?.totalTickCount = totalTickCount;
  }

  void progressBarComplete() {
    if (!_showProgressBar) {
      return;
    }
    _progressBar?.complete();
    _progressBar = null;
  }

  void _onJsonRecord(LogRecord record) {
    if (record.level == _progressLevel) {
      return;
    }

    var output = <String, dynamic>{'level': record.level.name};

    if (record.object is Jsonable) {
      output['data'] = record.object;
    } else {
      output['message'] = record.message;
    }

    _outSink.writeln(json.encode(output));
  }
}

void startLogging({
  required bool isJson,
  required bool isQuiet,
  required bool showProgress,
  StringSink? outSink,
  StringSink? errSink,
}) {
  _DartdocLogger.instance = _DartdocLogger._(
    isJson: isJson,
    isQuiet: isQuiet,
    showProgress: showProgress,
    outSink: outSink ?? io.stdout,
    errSink: errSink ?? io.stderr,
  );
}

mixin LoggingContext on DartdocOptionContextBase {
  bool get json => optionSet['json'].valueAt(context);

  bool get showProgress => optionSet['showProgress'].valueAt(context);

  bool get quiet => optionSet['quiet'].valueAt(context);
}

List<DartdocOption<Object>> createLoggingOptions(
    PackageMetaProvider packageMetaProvider) {
  var resourceProvider = packageMetaProvider.resourceProvider;
  return [
    DartdocOptionArgOnly<bool>(
      'json',
      false,
      resourceProvider,
      help: 'Prints out progress JSON maps. One entry per line.',
      negatable: true,
    ),
    DartdocOptionArgOnly<bool>(
      'showProgress',
      _terminalSupportsAnsi,
      resourceProvider,
      help: 'Display progress indications to console stdout.',
      negatable: true,
    ),
    DartdocOptionArgSynth<bool>(
      'quiet',
      (DartdocSyntheticOption<Object> option, Folder dir) =>
          option.parent['generateDocs'].valueAt(dir) == false,
      resourceProvider,
      abbr: 'q',
      negatable: true,
      help: 'Only show warnings and errors; silence all other output.',
    ),
  ];
}

const String _backspace = '\b';

bool get _terminalSupportsAnsi =>
    io.stdout.supportsAnsiEscapes &&
    io.stdioType(io.stdout) == io.StdioType.terminal;
