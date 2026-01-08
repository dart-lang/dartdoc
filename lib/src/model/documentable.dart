// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/warnings.dart';

import 'model.dart';

/// An interface that bridges the gap between [ModelElement]s, [Category]s, and
/// [Package]s, all of which have documentation, but in different forms.
abstract interface class Documentable with Nameable {
  String? get documentation;

  String get documentationAsHtml;

  bool get hasDocumentation;

  String get oneLineDoc;

  @override
  PackageGraph get packageGraph;

  Package get package;

  bool get isDocumented;

  DartdocOptionContext get config;

  /// A human-friendly name for the kind of element this is.
  Kind get kind;

  String? get href;

  /// The full path of the sidebar for elements "above" this element.
  ///
  /// A `null` value indicates no content is displayed in the "above" sidebar.
  String? get aboveSidebarPath;

  /// The full path of the sidebar for elements "below" this element.
  ///
  /// A `null` value indicates no content is displayed in the "below" sidebar.
  String? get belowSidebarPath;
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

mixin MarkdownFileDocumentation implements Documentable, Warnable {
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
  bool get hasDocumentation => documentation.isNotEmpty;

  @override
  bool get isDocumented;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

  File? get documentationFile;

  @override
  String get location => '(${documentationFile?.path})';
}
