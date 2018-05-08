// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.model_utils;

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:collection/collection.dart';
import 'package:dartdoc/src/model.dart';
import 'package:path/path.dart' as pathLib;
import 'package:quiver/core.dart';

final Map<String, String> _fileContents = <String, String>{};

/// Remove elements that aren't documented.
Iterable<T> filterNonDocumented<T extends Documentable>(
    Iterable<T> maybeDocumentedItems) {
  return maybeDocumentedItems.where((me) => me.isDocumented);
}

/// Returns an iterable containing only public elements from [privacyItems].
Iterable<T> filterNonPublic<T extends Privacy>(Iterable<T> privacyItems) {
  return privacyItems.where((me) => me.isPublic);
}

/// Finds canonical classes for all classes in the iterable, if possible.
/// If a canonical class can not be found, returns the original class.
Iterable<Class> findCanonicalFor(Iterable<Class> classes) {
  return classes.map((c) =>
      c.packageGraph.findCanonicalModelElementFor(c.element) as Class ?? c);
}

String getFileContentsFor(Element e) {
  var location = e.source.fullName;
  if (!_fileContents.containsKey(location)) {
    var contents = new File(location).readAsStringSync();
    _fileContents.putIfAbsent(location, () => contents);
  }
  return _fileContents[location];
}

Iterable<LibraryElement> getRequiredSdkLibraries(
    DartSdk sdk, AnalysisContext context) {
  var requiredLibs = sdk.sdkLibraries
      .where((sdkLib) => sdkLib.shortName == 'dart:_interceptors');
  final Set<LibraryElement> allLibraryElements = new Set();
  for (var sdkLib in requiredLibs) {
    Source source = sdk.mapDartUri(sdkLib.shortName);
    allLibraryElements.add(context.computeLibraryElement(source));
  }
  return allLibraryElements;
}

bool isInExportedLibraries(
    List<LibraryElement> libraries, LibraryElement library) {
  return libraries
      .any((lib) => lib == library || lib.exportedLibraries.contains(library));
}

final RegExp slashes = new RegExp('[\/]');
bool hasPrivateName(Element e) {
  if (e.name == null) return false;

  if (e.name.startsWith('_')) {
    return true;
  }
  // GenericFunctionTypeElements have the name we care about in the enclosing
  // element.
  if (e is GenericFunctionTypeElement) {
    if (e.enclosingElement.name.startsWith('_')) {
      return true;
    }
  }
  if (e is LibraryElement &&
      (e.identifier.startsWith('dart:_') ||
          e.identifier.startsWith('dart:nativewrappers/') ||
          ['dart:nativewrappers'].contains(e.identifier))) {
    return true;
  }
  if (e is LibraryElement) {
    List<String> locationParts = e.location.components[0].split(slashes);
    // TODO(jcollins-g): Implement real cross package detection
    if (locationParts.length >= 2 &&
        locationParts[0].startsWith('package:') &&
        locationParts[1] == 'src') return true;
  }
  return false;
}

bool hasPublicName(Element e) => !hasPrivateName(e);

/// Strip leading dartdoc comments from the given source code.
String stripDartdocCommentsFromSource(String source) {
  String remainer = source.trimLeft();
  HtmlEscape sanitizer = const HtmlEscape();
  bool lineComments = remainer.startsWith('///') ||
      remainer.startsWith(sanitizer.convert('///'));
  bool blockComments = remainer.startsWith('/**') ||
      remainer.startsWith(sanitizer.convert('/**'));

  return source.split('\n').where((String line) {
    if (lineComments) {
      if (line.startsWith('///') || line.startsWith(sanitizer.convert('///'))) {
        return false;
      }
      lineComments = false;
      return true;
    } else if (blockComments) {
      if (line.contains('*/') || line.contains(sanitizer.convert('*/'))) {
        blockComments = false;
        return false;
      }
      if (line.startsWith('/**') || line.startsWith(sanitizer.convert('/**'))) {
        return false;
      }
      return false;
    }

    return true;
  }).join('\n');
}

/// Strip the common indent from the given source fragment.
String stripIndentFromSource(String source) {
  String remainer = source.trimLeft();
  String indent = source.substring(0, source.length - remainer.length);
  return source.split('\n').map((line) {
    line = line.trimRight();
    return line.startsWith(indent) ? line.substring(indent.length) : line;
  }).join('\n');
}

/// Add links to crossdart.info to the given source fragment
String crossdartifySource(
    String inputPath,
    Map<String, Map<String, dynamic>> json,
    String source,
    Element element,
    int start) {
  inputPath = pathLib.canonicalize(inputPath);
  var sanitizer = const HtmlEscape();
  String newSource;
  if (json.isNotEmpty) {
    var node = element.computeNode();
    var file = pathLib.canonicalize(element.source.fullName);
    var filesData = json[file];
    if (filesData != null) {
      var data = filesData["references"]
          .where((r) => r["offset"] >= start && r["end"] <= node.end);
      if (data.isNotEmpty) {
        var previousStop = 0;
        var stringBuffer = new StringBuffer();
        for (var item in data) {
          stringBuffer.write(sanitizer
              .convert(source.substring(previousStop, item["offset"] - start)));
          stringBuffer
              .write("<a class='crossdart-link' href='${item["remotePath"]}'>");
          stringBuffer.write(sanitizer.convert(
              source.substring(item["offset"] - start, item["end"] - start)));
          stringBuffer.write("</a>");
          previousStop = item["end"] - start;
        }
        stringBuffer.write(
            sanitizer.convert(source.substring(previousStop, source.length)));

        newSource = stringBuffer.toString();
      }
    }
  }
  if (newSource == null) {
    newSource = sanitizer.convert(source);
  }
  return newSource;
}

/// An UnmodifiableListView that computes equality and hashCode based on the
/// equality and hashCode of its contained objects.
class _HashableList {
  final List _source;
  int _hashCache;
  _HashableList(this._source);

  @override
  bool operator ==(other) {
    if (other is _HashableList) {
      if (_source.length == other._source.length) {
        for (var index = 0; index < _source.length; ++index) {
          if (_source[index] != other._source[index]) return false;
        }
        return true;
      }
    }
    return false;
  }

  @override
  get hashCode => _hashCache ??= hashObjects(_source);
}

/// Like [Memoizer], except in checked mode will validate that the value of the
/// memoized function is unchanging using [DeepCollectionEquality].  Still
/// returns the cached value assuming the assertion passes.
class ValidatingMemoizer extends Memoizer {
  bool _assert_on_difference = false;

  ValidatingMemoizer() : super() {
    // Assignment within assert to take advantage of the expression only
    // being executed in checked mode.
    assert(_assert_on_difference = true);
    invalidateMemos();
  }

  /// In checked mode and when constructed with assert_on_difference == true,
  /// validate that the return value from f() equals the memoized value.
  /// Otherwise, a wrapper around putIfAbsent.
  @override
  R _cacheIfAbsent<R>(_HashableList key, R Function() f) {
    if (_assert_on_difference) {
      if (_memoizationTable.containsKey(key)) {
        R value = f();
        if (!new DeepCollectionEquality()
            .equals(value, _memoizationTable[key])) {
          throw new AssertionError('${value} != $_memoizationTable[key]');
        }
      }
    }
    return super._cacheIfAbsent(key, f);
  }
}

/// A basic Memoizer class.  Instantiate as a member variable, extend, or use
/// as a mixin to track object-specific cached values, or instantiate directly
/// to track other values.
///
/// For all methods in this class, the parameter [f] must be a tear-off method
/// or top level function (not an inline closure) for memoization to work.
/// [Memoizer] depends on the equality operator on the given function to detect
/// when we are calling the same function.
///
/// Use:
///
/// ```dart
/// String aTestFunction(String greeting, String name) => "${greeting}, ${name}";
/// int aSlowFunction() { doSome(); return expensiveCalculations(); }
///
/// myMemoizer.memoized2(aTestFunction, "Hello, "world");
/// myMemoizer.memoized(aSlowFunction);
/// ```
///
/// *Not*:
///
/// ```dart
/// String aTestFunction(String greeting, String name) => "${greeting}, ${name}";
///
/// myMemoizer.memoized2((a, b) => aTestFunction(a, b), "Hello", "world");
/// myMemoizer.memoized(() => aSlowFunction());;
/// ```
class Memoizer {
  /// Map of a function and its positional parameters (if any), to a value.
  final Map<_HashableList, dynamic> _memoizationTable = new HashMap();

  /// Reset the memoization table, forcing calls of the underlying functions.
  void invalidateMemos() {
    _memoizationTable.clear();
  }

  /// A wrapper around putIfAbsent, exposed to allow overrides.
  R _cacheIfAbsent<R>(_HashableList key, R Function() f) {
    return _memoizationTable.putIfAbsent(key, f);
  }

  /// Calls and caches the return value of [f]() if not in the cache, then
  /// returns the cached value of [f]().
  R memoized<R>(Function f, {String altKey}) {
    Object obj = altKey ?? f;
    _HashableList key = new _HashableList([obj]);
    return _cacheIfAbsent(key, f);
  }

  /// Calls and caches the return value of [f]([param1]) if not in the cache, then
  /// returns the cached value of [f]([param1]).
  R memoized1<R, A>(R Function(A) f, A param1) {
    _HashableList key = new _HashableList([f, param1]);
    return _cacheIfAbsent(key, () => f(param1));
  }

  /// Calls and caches the return value of [f]([param1], [param2]) if not in the
  /// cache, then returns the cached value of [f]([param1], [param2]).
  R memoized2<R, A, B>(R Function(A, B) f, A param1, B param2) {
    _HashableList key = new _HashableList([f, param1, param2]);
    return _cacheIfAbsent(key, () => f(param1, param2));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3]) if
  /// not in the cache, then returns the cached value of [f]([param1],
  /// [param2], [param3]).
  R memoized3<R, A, B, C>(R Function(A, B, C) f, A param1, B param2, C param3) {
    _HashableList key = new _HashableList([f, param1, param2, param3]);
    return _cacheIfAbsent(key, () => f(param1, param2, param3));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3],
  /// [param4]) if not in the cache, then returns the cached value of
  /// [f]([param1], [param2], [param3], [param4]).
  R memoized4<R, A, B, C, D>(
      R Function(A, B, C, D) f, A param1, B param2, C param3, D param4) {
    _HashableList key = new _HashableList([f, param1, param2, param3, param4]);
    return _cacheIfAbsent(key, () => f(param1, param2, param3, param4));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3],
  /// [param4], [param5]) if not in the cache, then returns the cached value of [f](
  /// [param1], [param2], [param3], [param4], [param5]).
  R memoized5<R, A, B, C, D, E>(R Function(A, B, C, D, E) f, A param1, B param2,
      C param3, D param4, E param5) {
    _HashableList key =
        new _HashableList([f, param1, param2, param3, param4, param5]);
    return _cacheIfAbsent(key, () => f(param1, param2, param3, param4, param5));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3],
  /// [param4], [param5], [param6]) if not in the cache, then returns the cached
  /// value of [f]([param1], [param2], [param3], [param4], [param5], [param6]).
  R memoized6<R, A, B, C, D, E, F>(R Function(A, B, C, D, E, F) f, A param1,
      B param2, C param3, D param4, E param5, F param6) {
    _HashableList key =
        new _HashableList([f, param1, param2, param3, param4, param5, param6]);
    return _cacheIfAbsent(
        key, () => f(param1, param2, param3, param4, param5, param6));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3],
  /// [param4], [param5], [param6], [param7]) if not in the cache, then returns
  /// the cached value of [f]([param1], [param2], [param3], [param4], [param5],
  /// [param6], [param7]).
  R memoized7<R, A, B, C, D, E, F, G>(R Function(A, B, C, D, E, F, G) f,
      A param1, B param2, C param3, D param4, E param5, F param6, G param7) {
    _HashableList key = new _HashableList(
        [f, param1, param2, param3, param4, param5, param6, param7]);
    return _cacheIfAbsent(
        key, () => f(param1, param2, param3, param4, param5, param6, param7));
  }

  /// Calls and caches the return value of [f]([param1], [param2], [param3],
  /// [param4], [param5], [param6], [param7], [param8]) if not in the cache,
  /// then returns the cached value of [f]([param1], [param2], [param3],
  /// [param4], [param5], [param6], [param7], [param8]).
  R memoized8<R, A, B, C, D, E, F, G, H>(
      R Function(A, B, C, D, E, F, G, H) f,
      A param1,
      B param2,
      C param3,
      D param4,
      E param5,
      F param6,
      G param7,
      H param8) {
    _HashableList key = new _HashableList(
        [f, param1, param2, param3, param4, param5, param6, param7, param8]);
    return _cacheIfAbsent(
        key,
        () =>
            f(param1, param2, param3, param4, param5, param6, param7, param8));
  }
}
