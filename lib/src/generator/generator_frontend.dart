// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

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
    if (_generatorBackend.options.resourcesDir != null) {
      packageGraph?.defaultPackage.warn(
        PackageWarning.deprecated,
        message: "The '--resources-dir' option is deprecated, and will soon be "
            'removed.',
      );
    }

    var indexElements = packageGraph == null
        ? const <Indexable>[]
        : _generateDocs(packageGraph);

    await _generatorBackend.generateAdditionalFiles();

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
  List<Indexable> _generateDocs(PackageGraph packageGraph) {
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

    var indexAccumulator = <Indexable>[];
    var multiplePackages = packageGraph.localPackages.length > 1;

    void generateConstants(Container container) {
      for (var constant in container.constantFields.whereDocumented) {
        if (!constant.isCanonical) continue;
        indexAccumulator.add(constant);
        _generatorBackend.generateProperty(
            packageGraph, container.library, container, constant);
      }
    }

    void generateConstructors(Constructable constructable) {
      for (var constructor in constructable.constructors.whereDocumented) {
        if (!constructor.isCanonical) continue;
        indexAccumulator.add(constructor);
        _generatorBackend.generateConstructor(
            packageGraph, constructable.library, constructable, constructor);
      }
    }

    void generateInstanceMethods(Container container) {
      for (var method in container.instanceMethods.whereDocumented) {
        if (!method.isCanonical) continue;
        indexAccumulator.add(method);
        _generatorBackend.generateMethod(
            packageGraph, container.library, container, method);
      }
    }

    void generateInstanceOperators(Container container) {
      for (var operator in container.instanceOperators.whereDocumented) {
        if (!operator.isCanonical) continue;
        indexAccumulator.add(operator);
        _generatorBackend.generateMethod(
            packageGraph, container.library, container, operator);
      }
    }

    void generateInstanceProperty(Container container) {
      for (var property in container.instanceFields.whereDocumented) {
        if (!property.isCanonical) continue;
        indexAccumulator.add(property);
        _generatorBackend.generateProperty(
            packageGraph, container.library, container, property);
      }
    }

    void generateStaticMethods(Container container) {
      for (var method in container.staticMethods.whereDocumented) {
        if (!method.isCanonical) continue;
        indexAccumulator.add(method);
        _generatorBackend.generateMethod(
            packageGraph, container.library, container, method);
      }
    }

    void generateStaticProperty(Container container) {
      for (var property in container.variableStaticFields.whereDocumented) {
        if (!property.isCanonical) continue;
        indexAccumulator.add(property);
        _generatorBackend.generateProperty(
            packageGraph, container.library, container, property);
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

        for (var class_ in lib.allClasses.whereDocumented) {
          indexAccumulator.add(class_);
          _generatorBackend.generateClass(packageGraph, lib, class_);

          generateConstants(class_);
          generateConstructors(class_);
          generateInstanceMethods(class_);
          generateInstanceOperators(class_);
          generateInstanceProperty(class_);
          generateStaticMethods(class_);
          generateStaticProperty(class_);
        }

        for (var extension in lib.extensions.whereDocumented) {
          indexAccumulator.add(extension);
          _generatorBackend.generateExtension(packageGraph, lib, extension);

          generateConstants(extension);
          generateInstanceMethods(extension);
          generateInstanceOperators(extension);
          generateInstanceProperty(extension);
          generateStaticMethods(extension);
          generateStaticProperty(extension);
        }

        for (var extensionType in lib.extensionTypes.whereDocumented) {
          indexAccumulator.add(extensionType);
          _generatorBackend.generateExtensionType(
              packageGraph, lib, extensionType);

          generateConstants(extensionType);
          generateConstructors(extensionType);
          generateInstanceMethods(extensionType);
          generateInstanceOperators(extensionType);
          generateInstanceProperty(extensionType);
          generateStaticMethods(extensionType);
          generateStaticProperty(extensionType);
        }

        for (var mixin in lib.mixins.whereDocumented) {
          indexAccumulator.add(mixin);
          _generatorBackend.generateMixin(packageGraph, lib, mixin);

          generateConstants(mixin);
          generateInstanceProperty(mixin);
          generateInstanceMethods(mixin);
          generateInstanceOperators(mixin);
          generateStaticMethods(mixin);
          generateStaticProperty(mixin);
        }

        for (var enum_ in lib.enums.whereDocumented) {
          indexAccumulator.add(enum_);
          _generatorBackend.generateEnum(packageGraph, lib, enum_);

          generateConstants(enum_);
          generateConstructors(enum_);
          generateInstanceMethods(enum_);
          generateInstanceOperators(enum_);
          generateInstanceProperty(enum_);
          generateStaticMethods(enum_);
          generateStaticProperty(enum_);
        }

        for (var constant in lib.constants.whereDocumented) {
          indexAccumulator.add(constant);
          _generatorBackend.generateTopLevelProperty(
              packageGraph, lib, constant);
        }

        for (var property in lib.properties.whereDocumented) {
          indexAccumulator.add(property);
          _generatorBackend.generateTopLevelProperty(
              packageGraph, lib, property);
        }

        for (var function in lib.functions.whereDocumented) {
          indexAccumulator.add(function);
          _generatorBackend.generateFunction(packageGraph, lib, function);
        }

        for (var typeDef in lib.typedefs.whereDocumented) {
          indexAccumulator.add(typeDef);
          _generatorBackend.generateTypeDef(packageGraph, lib, typeDef);
        }
      }
    }
    return indexAccumulator;
  }
}
