import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

final _logger = new Logger('dartdoc');

/// A custom [Level] for tracking file writes and verification.
///
/// Has a value of `501` – one more than [Level.FINE].
final Level progressLevel = new Level('PROGRESS', 501);

/// A custom [Level] for errant print statements.
///
/// Has a value of `1201` – one more than [Level.SHOUT].
final Level printLevel = new Level('PRINT', 1201);

void logWarning(Object message) {
  _logger.log(Level.WARNING, message);
}

void logInfo(Object message) {
  _logger.log(Level.INFO, message);
}

void logProgress(Object message) {
  _logger.log(progressLevel, message);
}

void logPrint(Object message) {
  _logger.log(printLevel, message);
}

abstract class Jsonable {
  /// The `String` to print when in human-readable mode
  String get text;

  /// The JSON content to print when in JSON-output mode.
  Object toJson();

  @override
  String toString() => text;
}

void startLogging(LoggingContext config) {
  // By default, get all log output at `progressLevel` or greater.
  // This allows us to capture progress events and print `...`.
  Logger.root.level = progressLevel;
  if (config.json) {
    Logger.root.onRecord.listen((record) {
      if (record.level == progressLevel) {
        return;
      }

      var output = <String, dynamic>{'level': record.level.name};

      if (record.object is Jsonable) {
        output['data'] = record.object;
      } else {
        output['message'] = record.message;
      }

      print(json.encode(output));
    });
  } else {
    final stopwatch = new Stopwatch()..start();

    // Used to track if we're printing `...` to show progress.
    // Allows unified new-line tracking
    var writingProgress = false;

    Logger.root.onRecord.listen((record) {
      if (record.level == progressLevel) {
        if (config.showProgress && stopwatch.elapsed.inMilliseconds > 250) {
          writingProgress = true;
          stdout.write('.');
          stopwatch.reset();
        }
        return;
      }

      stopwatch.reset();
      if (writingProgress) {
        // print a new line after progress dots...
        print('');
        writingProgress = false;
      }
      var message = record.message;
      assert(message == message.trimRight());
      assert(message.isNotEmpty);

      if (record.level < Level.WARNING) {
        if (config.showProgress && message.endsWith('...')) {
          // Assume there may be more progress to print, so omit the trailing
          // newline
          writingProgress = true;
          stdout.write(message);
        } else {
          print(message);
        }
      } else {
        stderr.writeln(message);
      }
    });
  }
}

abstract class LoggingContext implements DartdocOptionContext {
  bool get json => optionSet['json'].valueAt(context);
  bool get showProgress => optionSet['showProgress'].valueAt(context);
}

Future<List<DartdocOption>> createLoggingOptions() async {
  return <DartdocOption>[
    new DartdocOptionArgOnly<bool>('json', false,
        help: 'Prints out progress JSON maps. One entry per line.',
        negatable: true),
    new DartdocOptionArgOnly<bool>('showProgress', false,
        help: 'Display progress indications to console stdout',
        negatable: false),
  ];
}
