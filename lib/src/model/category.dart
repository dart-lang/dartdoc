// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model/model_object_builder.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/warnings.dart';

/// A category is a subcategory of a package, containing libraries tagged
/// with a @category identifier.
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
  /// All libraries in [libraries] must come from [package].
  final Package _package;

  @override
  Package get package => _package;

  final String _name;

  final DartdocOptionContext _config;

  @override
  DartdocOptionContext get config => _config;

  final Set<Categorization> _allItems = {};

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

  void addItem(Categorization c) {
    if (_allItems.contains(c)) return;
    _allItems.add(c);
    if (c is Library) {
      libraries.add(c);
    } else if (c is Mixin) {
      _mixins.add(c);
    } else if (c is Enum) {
      _enums.add(c);
    } else if (c is Class) {
      if (c.isErrorOrException) {
        _exceptions.add(c);
      } else {
        _classes.add(c);
      }
    } else if (c is TopLevelVariable) {
      if (c.isConst) {
        _constants.add(c);
      } else {
        _properties.add(c);
      }
    } else if (c is ModelFunction) {
      _functions.add(c);
    } else if (c is Typedef) {
      _typedefs.add(c);
    } else if (c is Extension) {
      _extensions.add(c);
    } else {
      throw UnimplementedError('Unrecognized element: $c (${c.runtimeType})');
    }
  }

  @override
  Warnable? get enclosingElement => null;

  @override
  Element? get element => null;

  @override
  String get name => categoryDefinition.displayName;

  @override
  String get sortKey => _name;

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
  String get kind => 'Topic';

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
  Iterable<TopLevelVariable> get constants => _constants;

  @override
  Iterable<Enum> get enums => _enums;

  @override
  Iterable<Class> get exceptions => _exceptions;

  @override
  Iterable<Extension> get extensions => _extensions;

  @override
  Iterable<ModelFunction> get functions => _functions;

  @override
  Iterable<Mixin> get mixins => _mixins;

  @override
  Iterable<TopLevelVariable> get properties => _properties;

  @override
  Iterable<Typedef> get typedefs => _typedefs;

  CategoryRenderer get _categoryRenderer =>
      packageGraph.rendererFactory.categoryRenderer;

  @override
  // TODO: implement referenceChildren
  Map<String, CommentReferable> get referenceChildren => {};

  @override
  // TODO: implement referenceParents
  Iterable<CommentReferable> get referenceParents => [];

  @override
  // Categories are not analyzed by the analyzer, so they can't have
  // comment references.
  Map<String, ModelCommentReference> get commentRefs => {};
}
