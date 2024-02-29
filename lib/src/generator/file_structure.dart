// Copyright (c) 2023, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/comment_references/parser.dart';
import 'package:meta/meta.dart';

import '../model/model.dart';

/// This class defines an interface to allow [ModelElement]s and [Generator]s
/// to get information about the desired on-disk representation of a single
/// [ModelElement].  None of these getters should be considered valid unless
/// [modelElement.isCanonical] is true.  Implementations of this class can
/// define which elements have their own files and which do not, how
/// to lay them out on disk, and how to link different pages in the structure
/// together.
abstract class FileStructure {
  factory FileStructure.fromDocumentable(Documentable documentable) {
    return switch (documentable) {
      LibraryContainer() =>
        // [LibraryContainer]s are not ModelElements, but have documentation.
        FileStructure._fromLibraryContainer(documentable),
      ModelElement() =>
        // This should be the common case.
        FileStructure._fromModelElement(documentable),
      _ => throw UnimplementedError(
          'Tried to build a FileStructure for an unknown subtype of '
          "Documentable: '${documentable.runtimeType}'")
    };
  }

  factory FileStructure._fromLibraryContainer(
    LibraryContainer libraryContainer,
  ) =>
      switch (libraryContainer) {
        Category() => FileStructureImpl(libraryContainer.name, 'topic'),
        Package() => FileStructureImpl('index', null),
        _ => throw UnimplementedError(
            'Unrecognized LibraryContainer subtype:  ${libraryContainer.runtimeType}')
      };

  factory FileStructure._fromModelElement(ModelElement modelElement) {
    return switch (modelElement) {
      Library() => FileStructureImpl(modelElement.dirName, 'library'),
      Mixin() => FileStructureImpl(modelElement.name, 'mixin'),
      // Probably just an archaic state, but enums do not have a file suffix.
      Enum() => FileStructureImpl(modelElement.name, null),
      Class() => FileStructureImpl(modelElement.name, 'class'),
      ExtensionType() => FileStructureImpl(modelElement.name, 'extension-type'),
      Operator() => FileStructureImpl(
          'operator_${operatorNames[modelElement.referenceName]}', null),
      GetterSetterCombo() => FileStructureImpl(
          modelElement.name, modelElement.isConst ? 'constant' : null),
      _ => FileStructureImpl(modelElement.name, null)
    };
  }

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
  /// the file type and the [modelElement.enclosingElement]'s [dirName].
  String get fileName;

  /// The directory name that should contain any elements enclosed by
  /// [modelElement].
  String get dirName;
}

@visibleForTesting
class FileStructureImpl implements FileStructure {
  /// This is a name for the underlying [Documentable] that is free of
  /// characters that can not appear in a path (URI, Unix, or Windows).
  String pathSafeName;

  /// This is a string to disambiguate the filename of the underlying
  /// [Documentable] from other files with the same [pathSafeName] in the
  /// same directory and is composed with [pathSafeName] to generate [fileName].
  /// It is usually based on [ModelElement.kind], e.g. `'class'`.  If null, no
  /// disambiguating string will be added.
  // TODO(jcollins-g): Legacy layout doesn't always include this; move toward
  // always having a disambiguating string.
  final String? kindAddition;

  FileStructureImpl(this.pathSafeName, this.kindAddition);

  @override

  /// Initial implementation is bug-for-bug compatible with pre-extraction
  /// dartdoc.  This means that some types will have kindAdditions, and
  /// some will not.  See [FileStructure._fromModelElement].
  String get fileName {
    if (kindAddition != null) {
      return '$pathSafeName-$kindAddition.html';
    }
    return '$pathSafeName.html';
  }

  @override
  bool get hasIndependentFile => true;

  @override
  // TODO: implement href
  String get href => throw UnimplementedError();

  @override
  // TODO: implement htmlId
  String get htmlId => throw UnimplementedError();

  @override
  // TODO: implement dirName
  String get dirName => throw UnimplementedError();
}
