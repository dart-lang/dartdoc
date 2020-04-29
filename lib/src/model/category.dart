// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/warnings.dart';

/// A category is a subcategory of a package, containing libraries tagged
/// with a @category identifier.
class Category extends Nameable
    with
        Warnable,
        Locatable,
        Canonicalization,
        MarkdownFileDocumentation,
        LibraryContainer,
        TopLevelContainer,
        Indexable
    implements Documentable {
  /// All libraries in [libraries] must come from [package].
  @override
  Package package;
  final String _name;
  @override
  DartdocOptionContext config;
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

  Category(this._name, this.package, this.config);

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
      throw UnimplementedError('Unrecognized element');
    }
  }

  @override
  // TODO(jcollins-g): make [Category] a [Warnable]?
  Warnable get enclosingElement => null;

  @override
  Element get element => null;

  @override
  String get name => categoryDefinition?.displayName ?? _name;

  @override
  String get sortKey => _name;

  @override
  List<String> get containerOrder => config.categoryOrder;

  @override
  String get enclosingName => package.name;

  @override
  PackageGraph get packageGraph => package.packageGraph;

  @override
  Library get canonicalLibrary => null;

  @override
  List<Locatable> get documentationFrom => [this];

  @override
  DocumentLocation get documentedWhere => package.documentedWhere;

  bool _isDocumented;

  @override
  bool get isDocumented {
    _isDocumented ??= documentedWhere != DocumentLocation.missing &&
        documentationFile != null;
    return _isDocumented;
  }

  @override
  String get fullyQualifiedName => name;

  String get fileType => package.fileType;

  String get filePath => 'topics/$name-topic.$fileType';

  @override
  String get href => isCanonical ? '${package.baseHref}$filePath' : null;

  String get categoryLabel => _categoryRenderer.renderCategoryLabel(this);

  String get linkedName => _categoryRenderer.renderLinkedName(this);

  int _categoryIndex;

  /// The position in the container order for this category.
  int get categoryIndex {
    _categoryIndex ??= package.categories.indexOf(this);
    return _categoryIndex;
  }

  CategoryDefinition get categoryDefinition =>
      config.categories.categoryDefinitions[sortKey];

  @override
  bool get isCanonical => categoryDefinition != null;

  @override
  String get kind => 'Topic';

  FileContents _documentationFile;

  @override
  FileContents get documentationFile {
    if (_documentationFile == null) {
      if (categoryDefinition?.documentationMarkdown != null) {
        _documentationFile =
            FileContents(File(categoryDefinition.documentationMarkdown));
      }
    }
    return _documentationFile;
  }

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    packageGraph.warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

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
}
