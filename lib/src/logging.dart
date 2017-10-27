// Copyright (c) 2017, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:logging/logging.dart';

final _logger = new Logger('dartdoc');

/// A custom [Level] for tracking file writes and verification.
///
/// Has a value of `501` – one more than [Level.FINE].
final Level progressLevel = new Level('progress', 501);

void logWarning(Object message) {
  _logger.log(Level.WARNING, message);
}

void logInfo(Object message) {
  _logger.log(Level.INFO, message);
}

void logProgress(Object message) {
  _logger.log(progressLevel, message);
}
