// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';

import 'model.dart';

/// Bridges the gap between model elements and packages,
/// both of which have documentation.
abstract class Documentable extends Nameable {
  String? get documentation;

  String get documentationAsHtml;

  bool get hasDocumentation;

  String get oneLineDoc;

  PackageGraph get packageGraph;

  bool get isDocumented;

  DartdocOptionContext get config;

  String? get href;

  String get kind;
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

mixin MarkdownFileDocumentation implements Documentable, Canonicalization {
  DocumentLocation get documentedWhere;

  late final Documentation _documentation = Documentation.forElement(this);

  @override
  String get documentationAsHtml => _documentation.asHtml;

  @override
  String get documentation {
    final docFile = documentationFile;
    return docFile == null
        ? ''
        : packageGraph.resourceProvider
            .readAsMalformedAllowedStringSync(docFile);
  }

  @override
  bool get hasDocumentation => documentation.isNotEmpty == true;

  @override
  bool get isDocumented;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

  File? get documentationFile;

  @override
  String get location => '(${documentationFile?.path})';

  @override
  Set<String> get locationPieces => <String>{location};
}
