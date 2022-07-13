// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/generator/generator.dart';
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
    var indexElements =
        packageGraph == null ? <Indexable>[] : _generateDocs(packageGraph);

    await _generatorBackend.generateAdditionalFiles();

    var categories = indexElements
        .whereType<Categorization>()
        .where((e) => e.hasCategorization)
        .toList();
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
      'writtenFunctionFileCount',
      'writtenLibraryFileCount',
      'writtenMethodFileCount',
      'writtenMixinFileCount',
      'writtenPackageFileCount',
      'writtenPropertyFileCount',
      'writtenTopLevelPropertyFileCount',
      'writtenTypedefFileCount'
    });
    _generatorBackend.generatePackage(
        packageGraph, packageGraph.defaultPackage);

    var indexAccumulator = <Indexable>[];
    for (var package in packageGraph.localPackages) {
      for (var category in filterNonDocumented(package.categories)) {
        logInfo('Generating docs for category ${category.name} from '
            '${category.package.fullyQualifiedName}...');
        indexAccumulator.add(category);
        _generatorBackend.generateCategory(packageGraph, category);
      }

      for (var lib in filterNonDocumented(package.libraries)) {
        logInfo('Generating docs for library ${lib.name} from '
            '${lib.element.source.uri}...');
        if (!lib.isAnonymous && !lib.hasDocumentation) {
          packageGraph.warnOnElement(lib, PackageWarning.noLibraryLevelDocs);
        }
        indexAccumulator.add(lib);
        _generatorBackend.generateLibrary(packageGraph, lib);

        for (var clazz in filterNonDocumented(lib.allClasses)) {
          indexAccumulator.add(clazz);
          _generatorBackend.generateClass(packageGraph, lib, clazz);

          for (var constructor in filterNonDocumented(clazz.constructors)) {
            if (!constructor.isCanonical) continue;

            indexAccumulator.add(constructor);
            _generatorBackend.generateConstructor(
                packageGraph, lib, clazz, constructor);
          }

          for (var constant in filterNonDocumented(clazz.constantFields)) {
            if (!constant.isCanonical) continue;

            indexAccumulator.add(constant);
            _generatorBackend.generateConstant(
                packageGraph, lib, clazz, constant);
          }

          for (var property
              in filterNonDocumented(clazz.variableStaticFields)) {
            if (!property.isCanonical) continue;

            indexAccumulator.add(property);
            _generatorBackend.generateProperty(
                packageGraph, lib, clazz, property);
          }

          for (var property in filterNonDocumented(clazz.instanceFields)) {
            if (!property.isCanonical) continue;

            indexAccumulator.add(property);
            _generatorBackend.generateProperty(
                packageGraph, lib, clazz, property);
          }

          for (var method in filterNonDocumented(clazz.instanceMethods)) {
            if (!method.isCanonical) continue;

            indexAccumulator.add(method);
            _generatorBackend.generateMethod(packageGraph, lib, clazz, method);
          }

          for (var operator in filterNonDocumented(clazz.instanceOperators)) {
            if (!operator.isCanonical) continue;

            indexAccumulator.add(operator);
            _generatorBackend.generateMethod(
                packageGraph, lib, clazz, operator);
          }

          for (var method in filterNonDocumented(clazz.staticMethods)) {
            if (!method.isCanonical) continue;

            indexAccumulator.add(method);
            _generatorBackend.generateMethod(packageGraph, lib, clazz, method);
          }
        }

        for (var extension in filterNonDocumented(lib.extensions)) {
          indexAccumulator.add(extension);
          _generatorBackend.generateExtension(packageGraph, lib, extension);

          for (var constant in filterNonDocumented(extension.constantFields)) {
            indexAccumulator.add(constant);
            _generatorBackend.generateConstant(
                packageGraph, lib, extension, constant);
          }

          for (var method
              in filterNonDocumented(extension.publicInstanceMethods)) {
            indexAccumulator.add(method);
            _generatorBackend.generateMethod(
                packageGraph, lib, extension, method);
          }

          for (var operator
              in filterNonDocumented(extension.instanceOperators)) {
            indexAccumulator.add(operator);
            _generatorBackend.generateMethod(
                packageGraph, lib, extension, operator);
          }

          for (var property in filterNonDocumented(extension.instanceFields)) {
            indexAccumulator.add(property);
            _generatorBackend.generateProperty(
                packageGraph, lib, extension, property);
          }

          for (var staticField
              in filterNonDocumented(extension.variableStaticFields)) {
            indexAccumulator.add(staticField);
            _generatorBackend.generateProperty(
                packageGraph, lib, extension, staticField);
          }

          for (var method in filterNonDocumented(extension.staticMethods)) {
            if (!method.isCanonical) continue;

            indexAccumulator.add(method);
            _generatorBackend.generateMethod(
                packageGraph, lib, extension, method);
          }
        }

        for (var mixin in filterNonDocumented(lib.mixins)) {
          indexAccumulator.add(mixin);
          _generatorBackend.generateMixin(packageGraph, lib, mixin);

          for (var constant in filterNonDocumented(mixin.constantFields)) {
            if (!constant.isCanonical) continue;
            indexAccumulator.add(constant);
            _generatorBackend.generateConstant(
                packageGraph, lib, mixin, constant);
          }

          for (var property
              in filterNonDocumented(mixin.variableStaticFields)) {
            if (!property.isCanonical) continue;

            indexAccumulator.add(property);
            _generatorBackend.generateConstant(
                packageGraph, lib, mixin, property);
          }

          for (var property in filterNonDocumented(mixin.instanceFields)) {
            if (!property.isCanonical) continue;

            indexAccumulator.add(property);
            _generatorBackend.generateConstant(
                packageGraph, lib, mixin, property);
          }

          for (var method in filterNonDocumented(mixin.instanceMethods)) {
            if (!method.isCanonical) continue;

            indexAccumulator.add(method);
            _generatorBackend.generateMethod(packageGraph, lib, mixin, method);
          }

          for (var operator in filterNonDocumented(mixin.instanceOperators)) {
            if (!operator.isCanonical) continue;

            indexAccumulator.add(operator);
            _generatorBackend.generateMethod(
                packageGraph, lib, mixin, operator);
          }

          for (var method in filterNonDocumented(mixin.staticMethods)) {
            if (!method.isCanonical) continue;

            indexAccumulator.add(method);
            _generatorBackend.generateMethod(packageGraph, lib, mixin, method);
          }
        }

        for (var enum_ in filterNonDocumented(lib.enums)) {
          indexAccumulator.add(enum_);
          _generatorBackend.generateEnum(packageGraph, lib, enum_);

          for (var constant in filterNonDocumented(enum_.constantFields)) {
            if (constant is EnumField) {
              // Enum values don't get their own page; just any additional
              // constants.
              continue;
            }
            if (!constant.isCanonical) continue;

            indexAccumulator.add(constant);
            _generatorBackend.generateConstant(
                packageGraph, lib, enum_, constant);
          }

          for (var constructor in filterNonDocumented(enum_.constructors)) {
            if (!constructor.isCanonical) continue;

            indexAccumulator.add(constructor);
            _generatorBackend.generateConstructor(
                packageGraph, lib, enum_, constructor);
          }

          for (var property in filterNonDocumented(enum_.instanceFields)) {
            indexAccumulator.add(property);
            _generatorBackend.generateConstant(
                packageGraph, lib, enum_, property);
          }
          for (var operator in filterNonDocumented(enum_.instanceOperators)) {
            indexAccumulator.add(operator);
            _generatorBackend.generateMethod(
                packageGraph, lib, enum_, operator);
          }
          for (var method in filterNonDocumented(enum_.instanceMethods)) {
            indexAccumulator.add(method);
            _generatorBackend.generateMethod(packageGraph, lib, enum_, method);
          }
        }

        for (var constant in filterNonDocumented(lib.constants)) {
          indexAccumulator.add(constant);
          _generatorBackend.generateTopLevelConstant(
              packageGraph, lib, constant);
        }

        for (var property in filterNonDocumented(lib.properties)) {
          indexAccumulator.add(property);
          _generatorBackend.generateTopLevelProperty(
              packageGraph, lib, property);
        }

        for (var function in filterNonDocumented(lib.functions)) {
          indexAccumulator.add(function);
          _generatorBackend.generateFunction(packageGraph, lib, function);
        }

        for (var typeDef in filterNonDocumented(lib.typedefs)) {
          indexAccumulator.add(typeDef);
          _generatorBackend.generateTypeDef(packageGraph, lib, typeDef);
        }
      }
    }
    return indexAccumulator;
  }
}

/// An interface for classes which are responsible for outputing the generated
/// documentation.
abstract class GeneratorBackend {
  FileWriter get writer;

  /// Emits JSON describing the [categories] defined by the package.
  void generateCategoryJson(List<Categorization> categories);

  /// Emits a JSON catalog of [indexedElements] for use with a search index.
  void generateSearchIndex(List<Indexable> indexedElements);

  /// Emits documentation content for the [package].
  void generatePackage(PackageGraph graph, Package package);

  /// Emits documentation content for the [category].
  void generateCategory(PackageGraph graph, Category category);

  /// Emits documentation content for the [library].
  void generateLibrary(PackageGraph graph, Library library);

  /// Emits documentation content for the [clazz].
  void generateClass(PackageGraph graph, Library library, Class clazz);

  /// Emits documentation content for the [eNum].
  void generateEnum(PackageGraph graph, Library library, Enum eNum);

  /// Emits documentation content for the [mixin].
  void generateMixin(PackageGraph graph, Library library, Mixin mixin);

  /// Emits documentation content for the [constructor].
  void generateConstructor(PackageGraph graph, Library library,
      Constructable constructable, Constructor constructor);

  /// Emits documentation content for the [field].
  void generateConstant(
      PackageGraph graph, Library library, Container clazz, Field field);

  /// Emits documentation content for the [field].
  void generateProperty(
      PackageGraph graph, Library library, Container clazz, Field field);

  /// Emits documentation content for the [method].
  void generateMethod(
      PackageGraph graph, Library library, Container clazz, Method method);

  /// Emits documentation content for the [extension].
  void generateExtension(
      PackageGraph graph, Library library, Extension extension);

  /// Emits documentation content for the [function].
  void generateFunction(
      PackageGraph graph, Library library, ModelFunction function);

  /// Emits documentation content for the [constant].
  void generateTopLevelConstant(
      PackageGraph graph, Library library, TopLevelVariable constant);

  /// Emits documentation content for the [property].
  void generateTopLevelProperty(
      PackageGraph graph, Library library, TopLevelVariable property);

  /// Emits documentation content for the [typedef].
  void generateTypeDef(PackageGraph graph, Library library, Typedef typedef);

  /// Emits files not specific to a Dart language element (like a favicon, etc).
  Future<void> generateAdditionalFiles();
}
