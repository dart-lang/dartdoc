library dartdoc.cache;

import 'dart:io';
import 'dart:collection';

class Cache {
  Map<String, String> __fileContents = {};
  Map<String, SplayTreeMap<int, int>> _lineNumbers = {};

  int lineNumber(String file, int offset) {
    if (offset == 0) {
      return 0;
    } else {
      if (_lineNumbers[file] == null) {
        _lineNumbers[file] = _createLineNumbersMap(_fileContents(file));
      }
      var lastKey = _lineNumbers[file].lastKeyBefore(offset);
      return _lineNumbers[file][lastKey];
    }
  }

  String _fileContents(String file) {
    if (__fileContents[file] == null) {
      __fileContents[file] = new File(file).readAsStringSync();
    }
    return __fileContents[file];
  }

  SplayTreeMap<int, int> _createLineNumbersMap(String contents) {
    var newlineChar = _getNewlineChar(contents);
    var offset = 0;
    var lineNumber = 0;
    var result = new SplayTreeMap();

    do {
      result[offset] = lineNumber;
      offset = contents.indexOf(newlineChar, offset + 1);
      lineNumber += 1;
    } while (offset != -1);

    return result;
  }

  String _getNewlineChar(String contents) {
    if (contents.contains("\r\n")) {
      return "\r\n";
    } else if (contents.contains("\r")) {
      return "\r";
    } else {
      return "\n";
    }
  }
}

Cache cache = new Cache();
