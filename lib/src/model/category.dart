// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/warnings.dart';

/// A subcategory of a package, containing elements tagged with `{@category}`.
class Category extends Nameable
    with
        Warnable,
        CommentReferable,
        Locatable,
        Canonicalization,
        MarkdownFileDocumentation,
        LibraryContainer,
        TopLevelContainer,
        Indexable,
        ModelBuilder
    implements Documentable {
  /// All libraries in [libraries] must come from [_package].
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
  Library get canonicalLibrary =>
      throw UnimplementedError('Categories can not have associated libraries.');

  @override
  List<Locatable> get documentationFrom => [this];

  @override
  DocumentLocation get documentedWhere => package.documentedWhere;

  @override
  late final bool isDocumented =
      documentedWhere != DocumentLocation.missing && documentationFile != null;

  @override
  String get fullyQualifiedName => name;

  String get filePath => 'topics/${fileStructure.fileName}';

  @override
  String? get href => isCanonical ? '${package.baseHref}$filePath' : null;

  String get categoryLabel => _categoryRenderer.renderCategoryLabel(this);

  String get linkedName => _categoryRenderer.renderLinkedName(this);

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

  CategoryRenderer get _categoryRenderer =>
      packageGraph.rendererFactory.categoryRenderer;

  @override
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  Iterable<CommentReferable> get referenceParents => const [];
}

extension on String? {
  String get orDefault => this ?? '<default>';
}
