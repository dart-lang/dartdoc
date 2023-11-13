import 'dart:io' as io;
import 'dart:math' as math;

import 'package:logging/logging.dart';

const Level progressBarUpdate = Level('PROGRESS_BAR', 502);

/// A facility for drawing a progress bar in the terminal.
///
/// The bar is instantiated with the total number of "ticks" to be completed,
/// and progress is made by calling [tick]. The bar is drawn across one entire
/// line, like so:
///
///     [----------                                                   ]
///
/// The hyphens represent completed progress, and the whitespace represents
/// remaining progress.
///
/// If there is no terminal, the progress bar will not be drawn.
class ProgressBar {
  final Logger _logger;

  /// Whether the progress bar should be drawn.
  late bool _shouldDrawProgress;

  /// The width of the terminal, in terms of characters.
  late int _width;

  /// The inner width of the terminal, in terms of characters.
  ///
  /// This represents the number of characters available for drawing progress.
  late int _innerWidth;

  int totalTickCount;

  int _tickCount = 0;

  ProgressBar(this._logger, this.totalTickCount) {
    if (!io.stdout.hasTerminal) {
      _shouldDrawProgress = false;
    } else {
      _shouldDrawProgress = true;
      _width = io.stdout.terminalColumns;
      // Inclusion of the percent indicator assumes a terminal width of at least
      // 12 (2 brackets + 1 space + 2 parenthesis characters + 3 digits +
      // 1 period + 2 digits + 1 '%' character).
      _innerWidth = io.stdout.terminalColumns - 12;
      _logger.log(progressBarUpdate, '[${' ' * _innerWidth}]');
    }
  }

  /// Clears the progress bar from the terminal, allowing other logging to be
  /// printed.
  void clear() {
    if (!_shouldDrawProgress) {
      return;
    }
    io.stdout.write('\r${' ' * _width}\r');
  }

  /// Draws the progress bar as complete, and print two newlines.
  void complete() {
    if (!_shouldDrawProgress) {
      return;
    }
    _logger.log(progressBarUpdate, '\r[${'-' * _innerWidth}] (100.00%)\n\n');
  }

  /// Progresses the bar by one tick.
  void tick() {
    if (!_shouldDrawProgress) {
      return;
    }
    _tickCount++;
    final fractionComplete =
        math.max(0, _tickCount * _innerWidth ~/ totalTickCount - 1);
    // The inner space consists of hyphens, one spinner character, spaces, and a
    // percentage (8 characters).
    final hyphens = '-' * fractionComplete;
    final trailingSpace = ' ' * (_innerWidth - fractionComplete - 1);
    final spinner = _animationItems[_tickCount % 4];
    final pctComplete = (_tickCount * 100 / totalTickCount).toStringAsFixed(2);
    _logger.log(progressBarUpdate,
        '\r[$hyphens$spinner$trailingSpace] ($pctComplete%)');
  }
}

const List<String> _animationItems = ['/', '-', r'\', '|'];
