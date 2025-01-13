// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: analyzer_use_new_elements

import 'package:dartdoc/src/generator/generator.dart';
import 'package:dartdoc/src/generator/generator_backend.dart';
import 'package:dartdoc/src/generator/templates.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/runtime_stats.dart';
import 'package:dartdoc/src/warnings.dart';

/// A [Generator] that delegates rendering to a [GeneratorBackend] and delegates
/// file creation to a [FileWriter].
class GeneratorFrontEnd implements Generator {
  final GeneratorBackend _generatorBackend;

  GeneratorFrontEnd(this._generatorBackend);

  @override
  Future<void> generate(PackageGraph? packageGraph) async {
    if (_generatorBackend.templates is RuntimeTemplates) {
      packageGraph?.defaultPackage.warn(
        PackageWarning.deprecated,
        message: "The '--templates-dir' option is deprecated, and will soon no "
            'longer be supported.',
      );
    }

    await _generatorBackend.generateAdditionalFiles();

    if (packageGraph == null) {
      return;
    }

    var indexElements = _generateDocs(packageGraph);
    var categories = indexElements
        .whereType<Categorization>()
        .where((e) => e.hasCategorization)
        .toList(growable: false);
    _generatorBackend.generateCategoryJson(categories);
    _generatorBackend.generateSearchIndex(indexElements);
  }

  @override
  Set<String> get writtenFiles => _generatorBackend.writer.writtenFiles;

  /// Traverses the [packageGraph] and generates documentation for all contained
  /// elements.
  List<Documentable> _generateDocs(PackageGraph packageGraph) {
    runtimeStats.resetAccumulators({
      'writtenCategoryFileCount',
      'writtenClassFileCount',
      'writtenConstructorFileCount',
      'writtenEnumFileCount',
      'writtenExtensionFileCount',
      'writtenExtensionTypeFileCount',
      'writtenFunctionFileCount',
      'writtenLibraryFileCount',
      'writtenMethodFileCount',
      'writtenMixinFileCount',
      'writtenPackageFileCount',
      'writtenPropertyFileCount',
      'writtenSidebarFileCount',
      'writtenTopLevelPropertyFileCount',
      'writtenTypedefFileCount'
    });
    _generatorBackend.generatePackage(
        packageGraph, packageGraph.defaultPackage);

    var indexAccumulator = <Documentable>[];
    var multiplePackages = packageGraph.localPackages.length > 1;

    void generateConstants(Container container, Library library) {
      for (var constant in container.constantFields.whereDocumented) {
        if (!constant.isCanonical) continue;
        indexAccumulator.add(constant);
        _generatorBackend.generateProperty(
            packageGraph, library, container, constant);
      }
    }

    void generateConstructors(Constructable constructable, Library library) {
      for (var constructor in constructable.constructors.whereDocumented) {
        if (!constructor.isCanonical) continue;
        indexAccumulator.add(constructor);
        _generatorBackend.generateConstructor(
            packageGraph, library, constructable, constructor);
      }
    }

    void generateInstanceMethods(Container container, Library library) {
      for (var method in container.instanceMethods.whereDocumented) {
        if (!method.isCanonical) continue;
        indexAccumulator.add(method);
        _generatorBackend.generateMethod(
            packageGraph, library, container, method);
      }
    }

    void generateInstanceOperators(Container container, Library library) {
      for (var operator in container.instanceOperators.whereDocumented) {
        if (!operator.isCanonical) continue;
        indexAccumulator.add(operator);
        _generatorBackend.generateMethod(
            packageGraph, library, container, operator);
      }
    }

    void generateInstanceProperties(Container container, Library library) {
      for (var property in container.instanceFields.whereDocumented) {
        if (!property.isCanonical) continue;
        indexAccumulator.add(property);
        _generatorBackend.generateProperty(
            packageGraph, library, container, property);
      }
    }

    void generateStaticMethods(Container container, Library library) {
      for (var method in container.staticMethods.whereDocumented) {
        if (!method.isCanonical) continue;
        indexAccumulator.add(method);
        _generatorBackend.generateMethod(
            packageGraph, library, container, method);
      }
    }

    void generateStaticProperties(Container container, Library library) {
      for (var property in container.variableStaticFields.whereDocumented) {
        if (!property.isCanonical) continue;
        indexAccumulator.add(property);
        _generatorBackend.generateProperty(
            packageGraph, library, container, property);
      }
    }

    for (var package in packageGraph.localPackages) {
      if (multiplePackages) {
        logInfo('Generating docs for package ${package.name}...');
      }
      for (var category in package.categories.whereDocumented) {
        logInfo('Generating docs for category ${category.name} from '
            '${category.package.fullyQualifiedName}...');
        indexAccumulator.add(category);
        _generatorBackend.generateCategory(packageGraph, category);
      }

      for (var lib in package.libraries.whereDocumented) {
        if (!multiplePackages) {
          logInfo('Generating docs for library ${lib.breadcrumbName} from '
              '${lib.element.source.uri}...');
        }
        if (!lib.isAnonymous && !lib.hasDocumentation) {
          packageGraph.warnOnElement(lib, PackageWarning.noLibraryLevelDocs);
        }
        indexAccumulator.add(lib);
        _generatorBackend.generateLibrary(packageGraph, lib);

        for (var class_ in lib.classesAndExceptions.whereDocumentedIn(lib)) {
          indexAccumulator.add(class_);
          _generatorBackend.generateClass(packageGraph, lib, class_);

          var canonicalLibrary = class_.canonicalLibraryOrThrow;
          generateConstants(class_, canonicalLibrary);
          generateConstructors(class_, canonicalLibrary);
          generateInstanceMethods(class_, canonicalLibrary);
          generateInstanceOperators(class_, canonicalLibrary);
          generateInstanceProperties(class_, canonicalLibrary);
          generateStaticMethods(class_, canonicalLibrary);
          generateStaticProperties(class_, canonicalLibrary);
        }

        for (var extension in lib.extensions.whereDocumentedIn(lib)) {
          indexAccumulator.add(extension);
          _generatorBackend.generateExtension(packageGraph, lib, extension);

          var canonicalLibrary = extension.canonicalLibraryOrThrow;
          generateConstants(extension, canonicalLibrary);
          generateInstanceMethods(extension, canonicalLibrary);
          generateInstanceOperators(extension, canonicalLibrary);
          generateInstanceProperties(extension, canonicalLibrary);
          generateStaticMethods(extension, canonicalLibrary);
          generateStaticProperties(extension, canonicalLibrary);
        }

        for (var extensionType in lib.extensionTypes.whereDocumentedIn(lib)) {
          indexAccumulator.add(extensionType);
          _generatorBackend.generateExtensionType(
              packageGraph, lib, extensionType);

          var canonicalLibrary = extensionType.canonicalLibraryOrThrow;
          generateConstants(extensionType, canonicalLibrary);
          generateConstructors(extensionType, canonicalLibrary);
          generateInstanceMethods(extensionType, canonicalLibrary);
          generateInstanceOperators(extensionType, canonicalLibrary);
          generateInstanceProperties(extensionType, canonicalLibrary);
          generateStaticMethods(extensionType, canonicalLibrary);
          generateStaticProperties(extensionType, canonicalLibrary);
        }

        for (var mixin in lib.mixins.whereDocumentedIn(lib)) {
          indexAccumulator.add(mixin);
          _generatorBackend.generateMixin(packageGraph, lib, mixin);

          var canonicalLibrary = mixin.canonicalLibraryOrThrow;
          generateConstants(mixin, canonicalLibrary);
          generateInstanceMethods(mixin, canonicalLibrary);
          generateInstanceOperators(mixin, canonicalLibrary);
          generateInstanceProperties(mixin, canonicalLibrary);
          generateStaticMethods(mixin, canonicalLibrary);
          generateStaticProperties(mixin, canonicalLibrary);
        }

        for (var enum_ in lib.enums.whereDocumentedIn(lib)) {
          indexAccumulator.add(enum_);
          _generatorBackend.generateEnum(packageGraph, lib, enum_);

          var canonicalLibrary = enum_.canonicalLibraryOrThrow;
          generateConstants(enum_, canonicalLibrary);
          generateConstructors(enum_, canonicalLibrary);
          generateInstanceMethods(enum_, canonicalLibrary);
          generateInstanceOperators(enum_, canonicalLibrary);
          generateInstanceProperties(enum_, canonicalLibrary);
          generateStaticMethods(enum_, canonicalLibrary);
          generateStaticProperties(enum_, canonicalLibrary);
        }

        for (var constant in lib.constants.whereDocumentedIn(lib)) {
          indexAccumulator.add(constant);
          _generatorBackend.generateTopLevelProperty(
              packageGraph, lib, constant);
        }

        for (var property in lib.properties.whereDocumentedIn(lib)) {
          indexAccumulator.add(property);
          _generatorBackend.generateTopLevelProperty(
              packageGraph, lib, property);
        }

        for (var function in lib.functions.whereDocumentedIn(lib)) {
          indexAccumulator.add(function);
          _generatorBackend.generateFunction(packageGraph, lib, function);
        }

        for (var typeDef in lib.typedefs.whereDocumentedIn(lib)) {
          indexAccumulator.add(typeDef);
          _generatorBackend.generateTypeDef(packageGraph, lib, typeDef);
        }
      }
    }
    return indexAccumulator;
  }
}
