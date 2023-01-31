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
  final Package _package;

  @override
  Package get package => _package;

  final String? _name;

  final DartdocOptionContext _config;

  @override
  DartdocOptionContext get config => _config;

  final List<Class> _classes = [];
  final List<Extension> _extensions = [];
  final List<Enum> _enums = [];
  final List<Mixin> _mixins = [];
  final List<Class> _exceptions = [];
  final List<TopLevelVariable> _constants = [];
  final List<TopLevelVariable> _properties = [];
  final List<ModelFunction> _functions = [];
  final List<Typedef> _typedefs = [];

  Category(this._name, this._package, this._config);

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
  String get name => categoryDefinition.displayName;

  @override
  String get sortKey => _name ?? '<default>';

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

  String get _fileType => package.fileType;

  String get filePath => 'topics/$name-topic.$_fileType';

  @override
  String? get href => isCanonical ? '${package.baseHref}$filePath' : null;

  String get categoryLabel => _categoryRenderer.renderCategoryLabel(this);

  String get linkedName => _categoryRenderer.renderLinkedName(this);

  /// The position in the container order for this category.
  late final int categoryIndex = package.categories.indexOf(this);

  late final CategoryDefinition categoryDefinition =
      config.categories.categoryDefinitions[sortKey] ??
          CategoryDefinition(_name, null, null);

  @override
  bool get isCanonical =>
      config.categories.categoryDefinitions.containsKey(sortKey);

  @override
  String get kind => 'topic';

  @override
  late final File? documentationFile = () {
    var documentationMarkdown = categoryDefinition.documentationMarkdown;
    if (documentationMarkdown != null) {
      return _config.resourceProvider.getFile(documentationMarkdown);
    }
    return null;
  }();

  @override
  Iterable<Class> get classes => _classes;

  @override
  List<TopLevelVariable> get constants => _constants;

  @override
  List<Enum> get enums => _enums;

  @override
  Iterable<Class> get exceptions => _exceptions;

  @override
  List<Extension> get extensions => _extensions;

  @override
  List<ModelFunction> get functions => _functions;

  @override
  List<Mixin> get mixins => _mixins;

  @override
  List<TopLevelVariable> get properties => _properties;

  @override
  List<Typedef> get typedefs => _typedefs;

  CategoryRenderer get _categoryRenderer =>
      packageGraph.rendererFactory.categoryRenderer;

  @override
  // TODO: implement referenceChildren
  Map<String, CommentReferable> get referenceChildren => const {};

  @override
  // TODO: implement referenceParents
  Iterable<CommentReferable> get referenceParents => const [];
}
