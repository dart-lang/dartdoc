library dartdoc.cache;

import 'dart:io';
import 'dart:collection';

String _getNewlineChar(String contents) {
  if (contents.contains("\r\n")) {
    return "\r\n";
  } else if (contents.contains("\r")) {
    return "\r";
  } else {
    return "\n";
  }
}

SplayTreeMap<int, int> _createLineNumbersMap(String contents) {
  var newlineChar = _getNewlineChar(contents);
  var offset = 0;
  var lineNumber = 0;
  var result = new SplayTreeMap<int, int>();

  do {
    result[offset] = lineNumber;
    offset = contents.indexOf(newlineChar, offset + 1);
    lineNumber += 1;
  } while (offset != -1);

  return result;
}

final LineNumberCache lineNumberCache = new LineNumberCache();

// TODO(kevmoo): this could use some testing
class LineNumberCache {
  final Map<String, String> __fileContents = <String, String>{};
  final Map<String, SplayTreeMap<int, int>> _lineNumbers =
      <String, SplayTreeMap<int, int>>{};

  int lineNumber(String file, int offset) {
    if (offset == 0) {
      return 0;
    } else {
      var lineMap = _lineNumbers.putIfAbsent(
          file, () => _createLineNumbersMap(_fileContents(file)));
      var lastKey = lineMap.lastKeyBefore(offset);
      return lineMap[lastKey];
    }
  }

  String _fileContents(String file) =>
      __fileContents.putIfAbsent(file, () => new File(file).readAsStringSync());
}
