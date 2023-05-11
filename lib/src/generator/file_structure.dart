// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/failure.dart';
import 'package:dartdoc/src/model/model_element.dart';

const _html = 'html';
const _md = 'md';

/// This class defines an interface to allow [ModelElement]s and [Generator]s
/// to get information about the desired on-disk representation of a single
/// [ModelElement].  None of these getters should be considered valid unless
/// [modelElement.isCanonical] is true.  Implementations of this class can
/// define which elements have their own files and which do not, how
/// to lay them out on disk, and how to link different pages in the structure
/// together.
abstract class FileStructure {
  factory FileStructure(String configFormat, ModelElement modelElement) {
    switch(configFormat) {
      case 'html':
        return _FileStructureHtml(modelElement);
      case 'md':
        return _FileStructureMd(modelElement);
      default:
        throw DartdocFailure('Internal error: unrecognized config.format: $configFormat');
    }
  }

  /// Link to the [ModelElement] the information for this [FileStructure]
  /// applies to.
  // TODO(jcollins): consider not carrying a reference to a ModelElement and
  // calculating necessary bits at construction time.  Might be challenging
  // if we want to calculate [hasIndependentFile] based on documentation
  // length or other variables not always available.
  ModelElement get modelElement;

  /// True if an independent file should be created for this `ModelElement`.
  bool get hasIndependentFile;

  /// Returns a string suitable for use as an in-page anchor for this element in
  /// its [ModelElement.enclosingElement] page.
  String get htmlId;

  /// Returns a link fragment relative to the HTML base for this `modelElement`.
  /// Scrubbed of platform-local path separators.  Must include an anchor
  /// if [hasIndependentFile] is false.
  String get href;

  /// The file name for an independent file.  Only valid if [hasIndependentFile]
  /// is `true`.  May contain platform-local path separators.  Includes
  /// the [fileType] and the [modelElement.enclosingElement]'s [dirName].
  String get fileName;

  /// The directory name that should contain any elements enclosed by
  /// [modelElement].
  String get dirName;

  /// A type (generally "html" or "md") to be appended to the file name.
  String get fileType;
}

class _FileStructureHtml implements FileStructure {
  _FileStructureHtml(this.modelElement);

  @override
  // TODO: implement fileName
  String get fileName => throw UnimplementedError();

  @override
  String get fileType => _html;

  @override
  bool get hasIndependentFile => true;

  @override
  // TODO: implement href
  String get href => throw UnimplementedError();

  @override
  // TODO: implement htmlId
  String get htmlId => throw UnimplementedError();

  @override
  final ModelElement modelElement;

  @override
  // TODO: implement dirName
  String get dirName => throw UnimplementedError();
}

class _FileStructureMd implements FileStructure {
  _FileStructureMd(this.modelElement);

  @override
  // TODO: implement fileName
  String get fileName => throw UnimplementedError();

  @override
  // TODO: implement fileType
  String get fileType => _md;

  @override
  bool get hasIndependentFile => true;

  @override
  // TODO: implement href
  String get href => throw UnimplementedError();

  @override
  // TODO: implement htmlId
  String get htmlId => throw UnimplementedError();

  @override
  final ModelElement modelElement;

  @override
  // TODO: implement dirName
  String get dirName => throw UnimplementedError();
}
