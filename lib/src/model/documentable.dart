// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:path/path.dart' as path;

import 'model.dart';

/// Bridges the gap between model elements and packages,
/// both of which have documentation.
abstract class Documentable extends Nameable {
  String get documentation;

  String get documentationAsHtml;

  bool get hasDocumentation;

  bool get hasExtendedDocumentation;

  String get oneLineDoc;

  PackageGraph get packageGraph;

  bool get isDocumented;

  DartdocOptionContext get config;
}

/// For a given package, indicate with this enum whether it should be documented
/// [local]ly, whether we should treat the package as [missing] and any references
/// to it made canonical to this package, or [remote], indicating that
/// we can build hrefs to an external source.
enum DocumentLocation {
  local,
  missing,
  remote,
}

abstract class MarkdownFileDocumentation
    implements Documentable, Canonicalization {
  DocumentLocation get documentedWhere;

  @override
  String get documentation => documentationFile?.contents;

  Documentation __documentation;

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = Documentation.forElement(this);
    return __documentation;
  }

  @override
  String get documentationAsHtml => _documentation.asHtml;

  @override
  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  @override
  bool get hasExtendedDocumentation =>
      documentation != null && documentation.isNotEmpty;

  @override
  bool get isDocumented;

  @override
  String get oneLineDoc => __documentation.asOneLiner;

  FileContents get documentationFile;

  @override
  String get location => path.toUri(documentationFile.file.path).toString();

  @override
  Set<String> get locationPieces => <String>{location};
}
