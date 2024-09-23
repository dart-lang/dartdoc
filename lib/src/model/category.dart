// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';

/// A subcategory of a package, containing elements tagged with `{@category}`.
class Category
    with
        Nameable,
        Warnable,
        CommentReferable,
        Locatable,
        MarkdownFileDocumentation,
        LibraryContainer,
        TopLevelContainer
    implements Documentable {
  /// The package in which this category is contained.
  ///
  /// All libraries in [libraries] must come from [package].
  @override
  final Package package;

  final String? _name;

  @override
  final DartdocOptionContext config;

  final List<Class> _classes = [];

  final List<Class> _exceptions = [];

  @override
  final List<TopLevelVariable> constants = [];

  @override
  final List<Extension> extensions = [];

  @override
  final List<ExtensionType> extensionTypes = [];

  @override
  final List<Enum> enums = [];

  @override
  final List<ModelFunction> functions = [];

  @override
  final List<Mixin> mixins = [];

  @override
  final List<TopLevelVariable> properties = [];

  @override
  final List<Typedef> typedefs = [];

  final CategoryDefinition _categoryDefinition;

  Category(this._name, this.package, this.config)
      : _categoryDefinition =
            config.categories.categoryDefinitions[_name.orDefault] ??
                CategoryDefinition(_name, null, null);

  Iterable<ExternalItem> get externalItems => _categoryDefinition.externalItems;

  void addClass(Class class_) {
    if (class_.isErrorOrException) {
      _exceptions.add(class_);
    } else {
      _classes.add(class_);
    }
  }

  @override
  Element? get element => null;

  @override
  String get name => _categoryDefinition.displayName;

  @override
  String get sortKey => _name.orDefault;

  @override
  List<String> get containerOrder => config.categoryOrder;

  @override
  String get enclosingName => package.name;

  @override
  PackageGraph get packageGraph => package.packageGraph;

  @override
  List<Locatable> get documentationFrom => [this];

  @override
  DocumentLocation get documentedWhere => package.documentedWhere;

  @override
  late final bool isDocumented =
      documentedWhere != DocumentLocation.missing && documentationFile != null;

  String get filePath => 'topics/$name-topic.html';

  @override
  String? get href => isCanonical ? '${package.baseHref}$filePath' : null;

  @override
  String? get aboveSidebarPath => null;

  @override
  String? get belowSidebarPath => null;

  String get categoryLabel {
    final buffer = StringBuffer('<span class="category ');
    buffer.writeAll(name.toLowerCase().split(' '), '-');
    buffer.write(' cp-');
    buffer.write(categoryIndex);

    if (isDocumented) {
      buffer.write(' linked');
    }

    buffer.write('"'); // Wrap up the class list and begin title
    buffer.write(' title="This is part of the ');
    buffer.write(name);
    buffer.write(' ');
    buffer.write(kind);
    buffer.write('.">'); // Wrap up the title

    buffer.write(linkedName);
    buffer.write('</span>');

    return buffer.toString();
  }

  String get linkedName {
    final unbrokenName = name.replaceAll(' ', '&nbsp;');
    if (isDocumented) {
      final href = this.href;
      if (href == null) {
        throw StateError("Requesting the 'linkedName' of a non-canonical "
            "category: '$name'");
      }
      return '<a href="$href">$unbrokenName</a>';
    } else {
      return unbrokenName;
    }
  }

  /// The position in the container order for this category.
  int get categoryIndex => package.categories.indexOf(this);

  @override
  bool get isCanonical =>
      config.categories.categoryDefinitions.containsKey(sortKey);

  @override
  Kind get kind => Kind.topic;

  @override
  File? get documentationFile {
    var documentationMarkdown = _categoryDefinition.documentationMarkdown;
    if (documentationMarkdown != null) {
      return config.resourceProvider.getFile(documentationMarkdown);
    }
    return null;
  }

  @override
  Iterable<Class> get classes => _classes;

  @override
  Iterable<Class> get exceptions => _exceptions;

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];
}

extension on String? {
  String get orDefault => this ?? '<default>';
}

/// A external link for an item in a dartdoc category.
///
/// This is a name, url, and optional documentation text.
class ExternalItem {
  final String name;
  final String url;
  final String docs;

  ExternalItem({
    required this.name,
    required this.url,
    required String? docs,
  }) : docs = docs ?? '';

  @override
  String toString() => '$name $url';
}
