// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names

library dartdoc.model_test;

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:async/async.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/feature.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/category_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/typedef_renderer.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import '../src/utils.dart'
    show bootBasicPackage, referenceLookup, kTestPackagePublicLibraries;

final _testPackageGraphMemo = AsyncMemoizer<PackageGraph>();
Future<PackageGraph> get testPackageGraph async =>
    _testPackageGraphMemo.runOnce(() => bootBasicPackage('testing/test_package',
        pubPackageMetaProvider, PhysicalPackageConfigProvider(),
        excludeLibraries: ['css', 'code_in_comments'],
        additionalArguments: ['--no-link-to-remote']));

/// For testing sort behavior.
class TestLibraryContainer extends LibraryContainer with Nameable {
  @override
  final List<String> containerOrder;
  @override
  String enclosingName;
  @override
  final String name;

  @override
  bool get isSdk => false;
  @override
  PackageGraph get packageGraph => throw UnimplementedError();

  TestLibraryContainer(
      this.name, this.containerOrder, LibraryContainer? enclosingContainer)
      : enclosingName = enclosingContainer?.name ?? '';
}

class TestLibraryContainerSdk extends TestLibraryContainer {
  TestLibraryContainerSdk(super.name, super.containerOrder,
      LibraryContainer super.enclosingContainer);

  @override
  bool get isSdk => true;
}

void main() {
  late final PackageGraph packageGraph;
  late final Library exLibrary;
  late final Library fakeLibrary;
  late final Library twoExportsLib;
  late final Library baseClassLib;
  late final Library dartAsync;

  setUpAll(() async {
    // Use model_special_cases_test.dart for tests that require
    // a different package graph.
    packageGraph = await testPackageGraph;
    exLibrary = packageGraph.libraries.firstWhere((lib) => lib.name == 'ex');
    fakeLibrary =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'fake');
    dartAsync =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'dart:async');
    twoExportsLib =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'two_exports');
    baseClassLib =
        packageGraph.libraries.firstWhere((lib) => lib.name == 'base_class');
  });

  group('PackageMeta and PackageGraph integration', () {
    test('PackageMeta error messages generate correctly', () {
      var message = packageGraph.packageMetaProvider
          .getMessageForMissingPackageMeta(
              fakeLibrary.element, packageGraph.config);
      expect(message, contains('fake.dart'));
      expect(message, contains('pub global activate dartdoc'));
    });
  });

  group('triple-shift', () {
    Library tripleShift;
    late final Class C, E, F;
    Extension ShiftIt;
    late final Operator classShift, extensionShift;
    late final Field constantTripleShifted;

    setUpAll(() async {
      tripleShift = (await testPackageGraph)
          .libraries
          .firstWhere((l) => l.name == 'triple_shift');
      C = tripleShift.classes.firstWhere((c) => c.name == 'C');
      E = tripleShift.classes.firstWhere((c) => c.name == 'E');
      F = tripleShift.classes.firstWhere((c) => c.name == 'F');
      ShiftIt = tripleShift.extensions.firstWhere((e) => e.name == 'ShiftIt');
      classShift =
          C.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
      extensionShift =
          ShiftIt.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
      constantTripleShifted =
          C.constantFields.firstWhere((f) => f.name == 'constantTripleShifted');
    });

    test('constants with triple shift render correctly', () {
      expect(constantTripleShifted.constantValue, equals('3 &gt;&gt;&gt; 5'));
    });

    test('operators exist and are named correctly', () {
      expect(classShift.name, equals('operator >>>'));
      expect(extensionShift.name, equals('operator >>>'));
    });

    test('inheritance and overriding of triple shift operators works correctly',
        () {
      var tripleShiftE =
          E.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
      var tripleShiftF =
          F.instanceOperators.firstWhere((o) => o.name.contains('>>>'));

      expect(tripleShiftE.isInherited, isTrue);
      expect(tripleShiftE.canonicalModelElement, equals(classShift));
      expect(tripleShiftE.modelType.returnType.name, equals('C'));
      expect(tripleShiftF.isInherited, isFalse);
      expect(tripleShiftF.modelType.returnType.name, equals('F'));
    });
  });

  group('generic metadata', () {
    late final Library genericMetadata;
    late final TopLevelVariable f;
    late final Typedef F;
    late final Class C;
    late final Method mp, mn;

    setUpAll(() async {
      genericMetadata = (await testPackageGraph)
          .libraries
          .firstWhere((l) => l.name == 'generic_metadata');
      F = genericMetadata.typedefs.firstWhere((t) => t.name == 'F');
      f = genericMetadata.properties.firstWhere((p) => p.name == 'f');
      C = genericMetadata.classes.firstWhere((c) => c.name == 'C');
      mp = C.instanceMethods.firstWhere((m) => m.name == 'mp');
      mn = C.instanceMethods.firstWhere((m) => m.name == 'mn');
    });

    test(
        'Verify annotations and their type arguments render on type parameters '
        'for typedefs',
        skip: 'dart-lang/sdk#46064', () {
      expect((F.aliasedType as FunctionType).typeFormals.first.metadata,
          isNotEmpty);
      expect((F.aliasedType as FunctionType).parameters.first.metadata,
          isNotEmpty);
      // TODO(jcollins-g): add rendering verification once we have data from
      // analyzer.
    });

    test('Verify type arguments on annotations renders, including parameters',
        () {
      var ab0 =
          '@<a href="%%__HTMLBASE_dartdoc_internal__%%generic_metadata/A-class.html">A</a><span class="signature">&lt;<wbr><span class="type-parameter"><a href="%%__HTMLBASE_dartdoc_internal__%%generic_metadata/B.html">B</a></span>&gt;</span>(0)';

      expect(genericMetadata.annotations.first.linkedNameWithParameters,
          equals(ab0));
      expect(f.annotations.first.linkedNameWithParameters, equals(ab0));
      expect(C.annotations.first.linkedNameWithParameters, equals(ab0));
      expect(C.typeParameters.first.annotations.first.linkedNameWithParameters,
          equals(ab0));
      expect(
          mp.parameters
              .map((p) => p.annotations.first.linkedNameWithParameters),
          everyElement(equals(ab0)));
      expect(
          mn.parameters
              .map((p) => p.annotations.first.linkedNameWithParameters),
          everyElement(equals(ab0)));
    });
  });

  group('generalized typedefs', () {
    late final Library generalizedTypedefs;
    late final Typedef T0, T1, T2, T3, T4, T5, T6, T7;
    late final Class C, C2;

    setUpAll(() {
      generalizedTypedefs = packageGraph.libraries
          .firstWhere((l) => l.name == 'generalized_typedefs');
      T0 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T0');
      T1 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T1');
      T2 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T2');
      T3 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T3');
      T4 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T4');
      T5 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T5');
      T6 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T6');
      T7 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T7');
      C = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C');
      C2 = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C2');
    });

    void expectTypedefs(Typedef t, String modelTypeToString,
        Iterable<String> genericParameters) {
      expect(t.modelType.toString(), equals(modelTypeToString));
      expect(t.element.typeParameters.map((p) => p.toString()),
          orderedEquals(genericParameters));
    }

    void expectAliasedTypeName(Aliased n, Matcher expected) {
      expect(n.aliasElement.name, expected);
    }

    test('typedef references display aliases', () {
      var g = C.instanceMethods.firstWhere((m) => m.name == 'g');

      var c = C2.allFields.firstWhere((f) => f.name == 'c');
      var d = C2.instanceMethods.firstWhere((f) => f.name == 'd');

      expectAliasedTypeName(c.modelType as Aliased, equals('T1'));
      expectAliasedTypeName(d.modelType.returnType as Aliased, equals('T2'));
      expectAliasedTypeName(
          d.parameters.first.modelType as Aliased, equals('T3'));
      expectAliasedTypeName(
          d.parameters.last.modelType as Aliased, equals('T4'));

      expectAliasedTypeName(g.modelType.returnType as Aliased, equals('T1'));
      expectAliasedTypeName(
          g.modelType.parameters.first.modelType as Aliased, equals('T2'));
      expectAliasedTypeName(
          g.modelType.parameters.last.modelType as Aliased, equals('T3'));
    });

    test('typedef references to special types work',
        skip: 'dart-lang/sdk#45291', () {
      var a = generalizedTypedefs.properties.firstWhere((p) => p.name == 'a');
      var b = C2.allFields.firstWhere((f) => f.name == 'b');
      var f = C.allFields.firstWhere((f) => f.name == 'f');
      expectAliasedTypeName(a.modelType as Aliased, equals('T0'));
      expectAliasedTypeName(b.modelType as Aliased, equals('T0'));
      expectAliasedTypeName(f.modelType as Aliased, equals('T0'));
    });

    test('basic non-function typedefs work', () {
      expectTypedefs(T0, 'void', []);
      expectTypedefs(T1, 'Function', []);
      expectTypedefs(T2, 'List<X>', ['out X']);
      expectTypedefs(T3, 'Map<X, Y>', ['out X', 'out Y']);
      expectTypedefs(T4, 'void Function()', []);
      expectTypedefs(T5, 'X Function(X, {X name})', ['inout X']);
      expectTypedefs(T6, 'X Function(Y, [Map<Y, Y>])', ['out X', 'in Y']);
      expectTypedefs(T7, 'X Function(Y, [Map<Y, Y>])',
          ['out X extends String', 'in Y extends List<X>']);
    });
  });

  group('NNBD cases', () {
    late final Library lateFinalWithoutInitializer,
        nullSafetyClassMemberDeclarations,
        nullableElements;
    late final Class b;
    late final Class c;
    late final ModelFunction oddAsyncFunction, anotherOddFunction;
    late final ModelFunction neverReturns, almostNeverReturns;

    setUpAll(() async {
      lateFinalWithoutInitializer = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'late_final_without_initializer');
      nullSafetyClassMemberDeclarations = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'nnbd_class_member_declarations');
      nullableElements = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'nullable_elements');
      b = nullSafetyClassMemberDeclarations.allClasses
          .firstWhere((c) => c.name == 'B');
      c = nullSafetyClassMemberDeclarations.allClasses
          .firstWhere((c) => c.name == 'C');
      oddAsyncFunction = nullableElements.publicFunctions
          .firstWhere((f) => f.name == 'oddAsyncFunction') as ModelFunction;
      anotherOddFunction = nullableElements.publicFunctions
          .firstWhere((f) => f.name == 'oddAsyncFunction') as ModelFunction;
      neverReturns = nullableElements.publicFunctions
          .firstWhere((f) => f.name == 'neverReturns') as ModelFunction;
      almostNeverReturns = nullableElements.publicFunctions
          .firstWhere((f) => f.name == 'almostNeverReturns') as ModelFunction;
    });

    test('Never types are allowed to have nullability markers', () {
      expect(neverReturns.modelType.returnType.name, equals('Never'));
      expect(neverReturns.modelType.returnType.nullabilitySuffix, equals(''));
      expect(almostNeverReturns.modelType.returnType.name, equals('Never'));
      expect(almostNeverReturns.modelType.returnType.nullabilitySuffix,
          equals('?'));
    });

    test('old implied Future types have correct nullability', () {
      expect(oddAsyncFunction.modelType.returnType.name, equals('dynamic'));
      expect(
          oddAsyncFunction.modelType.returnType.nullabilitySuffix, equals(''));
      expect(anotherOddFunction.modelType.returnType.name, equals('dynamic'));
      expect(anotherOddFunction.modelType.returnType.nullabilitySuffix,
          equals(''));
    });

    test('method parameters with required', () {
      var m1 = b.instanceMethods.firstWhere((m) => m.name == 'm1');
      var p1 = m1.parameters.firstWhere((p) => p.name == 'p1');
      var p2 = m1.parameters.firstWhere((p) => p.name == 'p2');
      expect(p1.isRequiredNamed, isTrue);
      expect(p2.isRequiredNamed, isFalse);
      expect(p2.isNamed, isTrue);

      expect(
          m1.linkedParamsLines,
          equals(
              '<ol class="parameter-list"><li><span class="parameter" id="m1-param-some"><span class="type-annotation">int</span> <span class="parameter-name">some</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-regular"><span class="type-annotation">dynamic</span> <span class="parameter-name">regular</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-parameters"><span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">parameters</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p1">{<span>required</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p1</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p2"><span class="type-annotation">int</span> <span class="parameter-name">p2</span> = <span class="default-value">3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p3"><span>required</span> <span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p4"><span>required</span> <span>covariant</span> <span class="type-annotation">int</span> <span class="parameter-name">p4</span>}</span></li>\n'
              '</ol>'));
    });

    test('verify no regression on ordinary optionals', () {
      var m2 = b.instanceMethods.firstWhere((m) => m.name == 'm2');
      var sometimes = m2.parameters.firstWhere((p) => p.name == 'sometimes');
      var optionals = m2.parameters.firstWhere((p) => p.name == 'optionals');
      expect(sometimes.isRequiredNamed, isFalse);
      expect(sometimes.isRequiredPositional, isTrue);
      expect(sometimes.isOptionalPositional, isFalse);
      expect(optionals.isRequiredNamed, isFalse);
      expect(optionals.isRequiredPositional, isFalse);
      expect(optionals.isOptionalPositional, isTrue);

      expect(
          m2.linkedParamsLines,
          equals(
              '<ol class="parameter-list"><li><span class="parameter" id="m2-param-sometimes"><span class="type-annotation">int</span> <span class="parameter-name">sometimes</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-we"><span class="type-annotation">dynamic</span> <span class="parameter-name">we</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-have">[<span class="type-annotation">String</span> <span class="parameter-name">have</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-optionals"><span class="type-annotation">double</span> <span class="parameter-name">optionals</span>]</span></li>\n'
              '</ol>'));
    });

    test('anonymous callback parameters are correctly marked as nullable', () {
      var m3 = c.instanceMethods.firstWhere((m) => m.name == 'm3');
      var listen = m3.parameters.firstWhere((p) => p.name == 'listen');
      var onDone = m3.parameters.firstWhere((p) => p.name == 'onDone');
      expect(listen.isRequiredPositional, isTrue);
      expect(onDone.isNamed, isTrue);

      expect(m3.linkedParamsLines, contains('</ol>\n)?, '));
      expect(m3.linkedParamsLines, contains('</ol>\n)?}</span>'));
    });

    test('Late final class member test', () {
      var c = lateFinalWithoutInitializer.allClasses
          .firstWhere((c) => c.name == 'C');
      var a = c.instanceFields.firstWhere((f) => f.name == 'a');
      var b = c.instanceFields.firstWhere((f) => f.name == 'b');
      var cField = c.instanceFields.firstWhere((f) => f.name == 'cField');
      var dField = c.instanceFields.firstWhere((f) => f.name == 'dField');

      // If Null safety isn't enabled, fields named 'late' come back from the
      // analyzer instead of setting up 'isLate'.
      expect(c.instanceFields.any((f) => f.name == 'late'), isFalse);

      expect(a.modelType.name, equals('dynamic'));
      expect(a.isLate, isTrue);
      expect(a.features, contains(Feature.lateFeature));
      expect(a.features, isNot(contains(Feature.readWrite)));

      expect(b.modelType.name, equals('int'));
      expect(b.isLate, isTrue);
      expect(b.features, contains(Feature.lateFeature));
      expect(b.features, isNot(contains(Feature.readWrite)));

      expect(cField.modelType.name, equals('dynamic'));
      expect(cField.isLate, isTrue);
      expect(cField.features, contains(Feature.lateFeature));
      expect(cField.features, isNot(contains(Feature.readWrite)));

      expect(dField.modelType.name, equals('double'));
      expect(dField.isLate, isTrue);
      expect(dField.features, contains(Feature.lateFeature));
      expect(dField.features, isNot(contains(Feature.readWrite)));
    });

    test('Late final top level variables', () {
      var initializeMe = lateFinalWithoutInitializer.publicProperties
          .firstWhere((v) => v.name == 'initializeMe');
      expect(initializeMe.modelType.name, equals('String'));
      expect(initializeMe.isLate, isTrue);
      expect(initializeMe.features, contains(Feature.lateFeature));
      expect(initializeMe.features, isNot(contains(Feature.readWrite)));
    });

    test('complex nullable elements are detected and rendered correctly', () {
      var complexNullableMembers = nullableElements.allClasses
          .firstWhere((c) => c.name == 'ComplexNullableMembers');
      expect(
          complexNullableMembers.nameWithGenerics,
          equals(
              'ComplexNullableMembers&lt;<wbr><span class="type-parameter">T extends String?</span>&gt;'));
    });

    test('simple nullable elements are detected and rendered correctly', () {
      var nullableMembers = nullableElements.allClasses
          .firstWhere((c) => c.name == 'NullableMembers');
      var methodWithNullables = nullableMembers.publicInstanceMethods
          .firstWhere((f) => f.name == 'methodWithNullables');
      var operatorStar = nullableMembers.publicInstanceOperators
          .firstWhere((f) => f.name == 'operator *');
      expect(
          methodWithNullables.linkedParams,
          equals(
              '<span class="parameter" id="methodWithNullables-param-foo"><span class="type-annotation">String?</span> <span class="parameter-name">foo</span></span>'));
      expect(
          operatorStar.linkedParams,
          equals(
              '<span class="parameter" id="*-param-nullableOther"><span class="type-annotation"><a href="%%__HTMLBASE_dartdoc_internal__%%nullable_elements/NullableMembers-class.html">NullableMembers</a>?</span> <span class="parameter-name">nullableOther</span></span>'));
    });
  });

  group('Set Literals', () {
    late final Library set_literals;
    late final TopLevelVariable aComplexSet,
        inferredTypeSet,
        specifiedSet,
        untypedMap,
        untypedMapWithoutConst,
        typedSet;

    setUpAll(() async {
      set_literals = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'set_literals');
      aComplexSet =
          set_literals.constants.firstWhere((v) => v.name == 'aComplexSet');
      inferredTypeSet =
          set_literals.constants.firstWhere((v) => v.name == 'inferredTypeSet');
      specifiedSet =
          set_literals.constants.firstWhere((v) => v.name == 'specifiedSet');
      untypedMap =
          set_literals.constants.firstWhere((v) => v.name == 'untypedMap');
      untypedMapWithoutConst = set_literals.constants
          .firstWhere((v) => v.name == 'untypedMapWithoutConst');
      typedSet = set_literals.constants.firstWhere((v) => v.name == 'typedSet');
    });

    test('Set literals test', () {
      expect(aComplexSet.modelType.name, equals('Set'));
      expect(
          (aComplexSet.modelType as ParameterizedElementType)
              .typeArguments
              .map((a) => a.name)
              .toList(),
          equals(['AClassContainingLiterals']));
      expect(aComplexSet.constantValue,
          equals('const {const AClassContainingLiterals(3, 5)}'));
      expect(inferredTypeSet.modelType.name, equals('Set'));
      expect(
          (inferredTypeSet.modelType as ParameterizedElementType)
              .typeArguments
              .map((a) => a.name)
              .toList(),
          equals(['int']));
      expect(inferredTypeSet.constantValue, equals('const {1, 3, 5}'));
      expect(specifiedSet.modelType.name, equals('Set'));
      expect(
          (specifiedSet.modelType as ParameterizedElementType)
              .typeArguments
              .map((a) => a.name)
              .toList(),
          equals(['int']));
      expect(specifiedSet.constantValue, equals('const {}'));
      // The analyzer is allowed to return a string with or without leading
      // `const` here.
      expect(
          untypedMapWithoutConst.constantValue, matches(RegExp('(const )?{}')));
      expect(untypedMap.modelType.name, equals('Map'));
      expect(
          (untypedMap.modelType as ParameterizedElementType)
              .typeArguments
              .map((a) => a.name)
              .toList(),
          equals(['dynamic', 'dynamic']));
      expect(untypedMap.constantValue, equals('const {}'));
      expect(typedSet.modelType.name, equals('Set'));
      expect(
          (typedSet.modelType as ParameterizedElementType)
              .typeArguments
              .map((a) => a.name)
              .toList(),
          equals(['String']));
      expect(typedSet.constantValue,
          matches(RegExp(r'const &lt;String&gt;\s?{}')));
    });
  });

  group('Tools', () {
    late final Class toolUser;
    late final Class NonCanonicalToolUser,
        CanonicalToolUser,
        PrivateLibraryToolUser;
    late final Class ImplementingClassForTool,
        CanonicalPrivateInheritedToolUser;
    late final Method invokeTool;
    late final Method invokeToolNoInput;
    late final Method invokeToolMultipleSections;
    late final Method invokeToolNonCanonical, invokeToolNonCanonicalSubclass;
    late final Method invokeToolPrivateLibrary,
        invokeToolPrivateLibraryOriginal;
    late final Method invokeToolParentDoc, invokeToolParentDocOriginal;
    // ignore: omit_local_variable_types
    final RegExp packageInvocationIndexRegexp =
        RegExp(r'PACKAGE_INVOCATION_INDEX: (\d+)');

    setUpAll(() {
      NonCanonicalToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == '_NonCanonicalToolUser');
      CanonicalToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'CanonicalToolUser');
      PrivateLibraryToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'PrivateLibraryToolUser');
      ImplementingClassForTool = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'ImplementingClassForTool');
      CanonicalPrivateInheritedToolUser = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'CanonicalPrivateInheritedToolUser');
      toolUser = exLibrary.classes.firstWhere((c) => c.name == 'ToolUser');
      invokeTool =
          toolUser.instanceMethods.firstWhere((m) => m.name == 'invokeTool');
      invokeToolNonCanonical = NonCanonicalToolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolNonCanonical');
      invokeToolNonCanonicalSubclass = CanonicalToolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolNonCanonical');
      invokeToolNoInput = toolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolNoInput');
      invokeToolMultipleSections = toolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolMultipleSections');
      invokeToolPrivateLibrary = PrivateLibraryToolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolPrivateLibrary');
      invokeToolPrivateLibraryOriginal =
          (invokeToolPrivateLibrary.definingEnclosingContainer as Class)
              .instanceMethods
              .firstWhere((m) => m.name == 'invokeToolPrivateLibrary');
      invokeToolParentDoc = CanonicalPrivateInheritedToolUser.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolParentDoc');
      invokeToolParentDocOriginal = ImplementingClassForTool.instanceMethods
          .firstWhere((m) => m.name == 'invokeToolParentDoc');
      for (var modelElement in packageGraph.allLocalModelElements) {
        modelElement.documentation;
      }
    });

    test(
        'invokes tool when inherited documentation is the only means for it to be seen',
        () {
      // Verify setup of the test is correct.
      expect(invokeToolParentDoc.isCanonical, isTrue);
      expect(invokeToolParentDoc.hasDocumentationComment, isFalse);
      // Error message here might look strange due to toString() on Methods, but if this
      // fails that means we don't have the correct invokeToolParentDoc instance.
      expect(invokeToolParentDoc.documentationFrom,
          contains(invokeToolParentDocOriginal));
      // Tool should be substituted out here.
      expect(invokeToolParentDoc.documentation, isNot(contains('{@tool')));
    });

    group('does _not_ invoke a tool multiple times unnecessarily', () {
      test('non-canonical subclass case', () {
        expect(invokeToolNonCanonical.isCanonical, isFalse);
        expect(invokeToolNonCanonicalSubclass.isCanonical, isTrue);
        expect(
            packageInvocationIndexRegexp
                .firstMatch(invokeToolNonCanonical.documentation)!
                .group(1),
            equals(packageInvocationIndexRegexp
                .firstMatch(invokeToolNonCanonicalSubclass.documentation)!
                .group(1)));
        expect(
            invokeToolPrivateLibrary.documentation, isNot(contains('{@tool')));
        expect(
            invokeToolPrivateLibraryOriginal.documentation, contains('{@tool'));
      });

      test('Documentation borrowed from implementer case', () {
        expect(
            packageInvocationIndexRegexp
                .firstMatch(invokeToolParentDoc.documentation)!
                .group(1),
            equals(packageInvocationIndexRegexp
                .firstMatch(invokeToolParentDocOriginal.documentation)!
                .group(1)));
      });
    });

    test('can invoke a tool and pass args and environment', () {
      expect(invokeTool.documentation, contains('--file=<INPUT_FILE>'));
      expect(invokeTool.documentation,
          contains(RegExp(r'--source=lib[/\\]example\.dart_[0-9]+_[0-9]+, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'--package-path=<PACKAGE_PATH>, ')));
      expect(
          invokeTool.documentation, contains('--package-name=test_package, '));
      expect(invokeTool.documentation, contains('--library-name=ex, '));
      expect(invokeTool.documentation,
          contains('--element-name=ToolUser.invokeTool, '));
      expect(invokeTool.documentation,
          contains(r'''--special= |\[]!@#\"'$%^&*()_+]'''));
      expect(invokeTool.documentation, contains('INPUT: <INPUT_FILE>'));
      expect(invokeTool.documentation,
          contains(RegExp('SOURCE_COLUMN: [0-9]+, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'SOURCE_PATH: lib[/\\]example\.dart, ')));
      expect(invokeTool.documentation,
          contains(RegExp(r'PACKAGE_PATH: <PACKAGE_PATH>, ')));
      expect(
          invokeTool.documentation, contains('PACKAGE_NAME: test_package, '));
      expect(invokeTool.documentation, contains('LIBRARY_NAME: ex, '));
      expect(invokeTool.documentation,
          contains('ELEMENT_NAME: ToolUser.invokeTool, '));
      expect(invokeTool.documentation,
          contains(RegExp('INVOCATION_INDEX: [0-9]+}')));
      expect(invokeTool.documentation, contains('## `Yes it is a [Dog]!`'));
    });
    test('can invoke a tool and add a reference link', () {
      expect(invokeTool.documentation,
          contains('Yes it is a [Dog]! Is not a [ToolUser].'));
      expect(
          invokeTool.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}ex/ToolUser-class.html">ToolUser</a>'));
      expect(
          invokeTool.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}ex/Dog-class.html">Dog</a>'));
    });
    test(r'can invoke a tool with no $INPUT or args', () {
      expect(invokeToolNoInput.documentation, contains('Args: []'));
      expect(invokeToolNoInput.documentation,
          isNot(contains('This text should not appear in the output')));
      expect(invokeToolNoInput.documentation, isNot(contains('[Dog]')));
      expect(
          invokeToolNoInput.documentationAsHtml,
          isNot(contains(
              '<a href="${htmlBasePlaceholder}ex/Dog-class.html">Dog</a>')));
    });
    test('can invoke a tool multiple times in one comment block', () {
      var envLine = RegExp(r'^Env: \{', multiLine: true);
      expect(envLine.allMatches(invokeToolMultipleSections.documentation),
          hasLength(2));
      var argLine = RegExp(r'^Args: \[', multiLine: true);
      expect(argLine.allMatches(invokeToolMultipleSections.documentation),
          hasLength(2));
      expect(invokeToolMultipleSections.documentation,
          contains('Invokes more than one tool in the same comment block.'));
      expect(invokeToolMultipleSections.documentation,
          contains('This text should appear in the output.'));
      expect(invokeToolMultipleSections.documentation,
          contains('## `This text should appear in the output.`'));
      expect(invokeToolMultipleSections.documentation,
          contains('This text should also appear in the output.'));
      expect(invokeToolMultipleSections.documentation,
          contains('## `This text should also appear in the output.`'));
    });
  });

  group('Missing and Remote', () {
    test(
        'Verify that SDK libraries are not canonical when documenting a package',
        () {
      expect(
          dartAsync.package.documentedWhere, equals(DocumentLocation.missing));
      expect(dartAsync.isCanonical, isFalse);
    });

    test('Verify that packageGraph has an SDK but will not document it locally',
        () {
      expect(packageGraph.packages.firstWhere((p) => p.isSdk).documentedWhere,
          isNot(equals(DocumentLocation.local)));
    });
  });

  group('Category', () {
    test('Verify categories for test_package', () {
      expect(packageGraph.localPackages, hasLength(1));
      expect(packageGraph.localPackages.first.hasCategories, isTrue);
      var packageCategories = packageGraph.localPackages.first.categories;
      expect(packageCategories, hasLength(6));
      expect(packageGraph.localPackages.first.categoriesWithPublicLibraries,
          hasLength(3));
      expect(
          packageCategories.map((c) => c.name).toList(),
          orderedEquals([
            'Superb',
            'Unreal',
            'Real Libraries',
            'Misc',
            'More Excellence',
            'NotSoExcellent'
          ]));
      expect(
          packageCategories.map((c) => c.libraries).toList(),
          orderedEquals([
            hasLength(0),
            hasLength(2),
            hasLength(3),
            hasLength(1),
            hasLength(0),
            hasLength(0)
          ]));
    });

    test('Verify libraries with multiple categories show up in multiple places',
        () {
      var packageCategories = packageGraph.publicPackages.first.categories;
      var realLibraries =
          packageCategories.firstWhere((c) => c.name == 'Real Libraries');
      var misc = packageCategories.firstWhere((c) => c.name == 'Misc');
      expect(
          realLibraries.libraries.map((l) => l.name), contains('two_exports'));
      expect(misc.libraries.map((l) => l.name), contains('two_exports'));
    });

    test('Verify that libraries without categories get handled', () {
      expect(
          packageGraph
              .localPackages.first.defaultCategory.publicLibraries.length,
          // Only 5 libraries have categories, the rest belong in default.
          equals(kTestPackagePublicLibraries - 5));
    });

    // TODO consider moving these to a separate suite
    test('CategoryRendererHtml renders category label', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererHtml();
      expect(
          renderer.renderCategoryLabel(category),
          '<span class="category superb cp-0 linked" title="This is part of the Superb topic.">'
          '<a href="${htmlBasePlaceholder}topics/Superb-topic.html">Superb</a></span>');
    });

    test('CategoryRendererHtml renders linkedName', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererHtml();
      expect(renderer.renderLinkedName(category),
          '<a href="${htmlBasePlaceholder}topics/Superb-topic.html">Superb</a>');
    });

    test('CategoryRendererMd renders category label', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererMd();
      expect(renderer.renderCategoryLabel(category),
          '[Superb](${htmlBasePlaceholder}topics/Superb-topic.html)');
    });

    test('CategoryRendererMd renders linkedName', () {
      var category = packageGraph.publicPackages.first.categories.first;
      var renderer = CategoryRendererMd();
      expect(renderer.renderLinkedName(category),
          '[Superb](${htmlBasePlaceholder}topics/Superb-topic.html)');
    });
  });

  group('LibraryContainer', () {
    late final TestLibraryContainer topLevel;
    var sortOrderBasic = ['theFirst', 'second', 'fruit'];
    var containerNames = [
      'moo',
      'woot',
      'theFirst',
      'topLevel Things',
      'toplevel',
      'fruit'
    ];

    setUpAll(() {
      topLevel = TestLibraryContainer('topLevel', [], null);
    });

    test('multiple containers with specified sort order', () {
      var containers = <LibraryContainer>[];
      for (var i = 0; i < containerNames.length; i++) {
        var name = containerNames[i];
        containers.add(TestLibraryContainer(name, sortOrderBasic, topLevel));
      }
      containers.add(TestLibraryContainerSdk('SDK', sortOrderBasic, topLevel));
      containers.sort();
      expect(
          containers.map((c) => c.name),
          orderedEquals([
            'theFirst',
            'fruit',
            'toplevel',
            'SDK',
            'topLevel Things',
            'moo',
            'woot'
          ]));
    });

    test('multiple containers, no specified sort order', () {
      var containers = <LibraryContainer>[];
      for (var name in containerNames) {
        containers.add(TestLibraryContainer(name, [], topLevel));
      }
      containers.add(TestLibraryContainerSdk('SDK', [], topLevel));
      containers.sort();
      expect(
          containers.map((c) => c.name),
          orderedEquals([
            'toplevel',
            'SDK',
            'topLevel Things',
            'fruit',
            'moo',
            'theFirst',
            'woot'
          ]));
    });
  });

  group('Library', () {
    late final Library anonLib,
        isDeprecated,
        someLib,
        reexportOneLib,
        reexportTwoLib,
        reexportThreeLib;
    late final Class SomeClass,
        SomeOtherClass,
        YetAnotherClass,
        AUnicornClass,
        ADuplicateClass;

    setUpAll(() {
      anonLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'anonymous_library');

      someLib = packageGraph.allLibraries.values
          .firstWhere((lib) => lib.name == 'reexport.somelib');
      reexportOneLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_one');
      reexportTwoLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_two');
      reexportThreeLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_three');
      SomeClass = someLib.getClassByName('SomeClass');
      SomeOtherClass = someLib.getClassByName('SomeOtherClass');
      YetAnotherClass = someLib.getClassByName('YetAnotherClass');
      AUnicornClass = someLib.getClassByName('AUnicornClass');
      ADuplicateClass = reexportThreeLib.getClassByName('ADuplicateClass');

      isDeprecated = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'is_deprecated');
    });

    test('has a name', () {
      expect(exLibrary.name, 'ex');
    });

    test('has a line number and column', () {
      expect(exLibrary.characterLocation, isNotNull);
    });

    test('can be deprecated', () {
      expect(isDeprecated.isDeprecated, isTrue);
      expect(anonLib.isDeprecated, isFalse);
    });

    test('can be reexported even if the file suffix is not .dart', () {
      expect(fakeLibrary.allClasses.map((c) => c.name),
          contains('MyClassFromADartFile'));
    });

    test('that is deprecated has a deprecated css class in linkedName', () {
      expect(isDeprecated.linkedName, contains('class="deprecated"'));
    });

    test('has properties', () {
      expect(exLibrary.hasPublicProperties, isTrue);
    });

    test('has constants', () {
      expect(exLibrary.hasPublicConstants, isTrue);
    });

    test('has exceptions', () {
      expect(exLibrary.hasPublicExceptions, isTrue);
    });

    test('has mixins', () {
      expect(fakeLibrary.hasPublicMixins, isTrue);
      expect(reexportTwoLib.hasPublicMixins, isTrue);
    });

    test('has functions', () {
      expect(exLibrary.hasPublicFunctions, isTrue);
    });

    test('has typedefs', () {
      expect(exLibrary.hasPublicTypedefs, isTrue);
    });

    test('exported class', () {
      expect(exLibrary.classes.any((c) => c.name == 'Helper'), isTrue);
    });

    test('exported function', () {
      expect(
          exLibrary.functions.any((f) => f.name == 'helperFunction'), isFalse);
    });

    test('anonymous lib', () {
      expect(anonLib.isAnonymous, isTrue);
    });

    test('with ambiguous reexport warnings', () {
      final warningMsg =
          '(reexport_one, reexport_two) -> reexport_two (confidence 0.000)';
      // Unicorn class has a warning because two @canonicalFors cancel each other out.
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              AUnicornClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // This class is ambiguous without a @canonicalFor
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              YetAnotherClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // These two classes have a @canonicalFor
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              SomeClass, PackageWarning.ambiguousReexport, warningMsg),
          isFalse);
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              SomeOtherClass, PackageWarning.ambiguousReexport, warningMsg),
          isFalse);
      // This library has a canonicalFor with no corresponding item
      expect(
          packageGraph.packageWarningCounter.hasWarning(reexportTwoLib,
              PackageWarning.ignoredCanonicalFor, 'something.ThatDoesntExist'),
          isTrue);
    });

    test('can import other libraries with unusual URIs', () {
      final fakeLibraryImportedExported = <Library>{
        for (final l in <LibraryElement>{
          ...fakeLibrary.element.importedLibraries,
          ...fakeLibrary.element.exportedLibraries
        })
          packageGraph.modelBuilder.fromElement(l) as Library
      };
      expect(fakeLibraryImportedExported.any((l) => l.name == 'import_unusual'),
          isTrue);
    });

    test('@canonicalFor directive works', () {
      expect(SomeOtherClass.canonicalLibrary, reexportOneLib);
      expect(SomeClass.canonicalLibrary, reexportTwoLib);
    });

    test('with correct show/hide behavior', () {
      expect(ADuplicateClass.definingLibrary.name, equals('shadowing_lib'));
    });
  });

  group('Macros', () {
    late final Class dog, ClassTemplateOneLiner;
    late final Enum MacrosFromAccessors;
    late final Method withMacro,
        withMacro2,
        withPrivateMacro,
        withUndefinedMacro;
    late final EnumField macroReferencedHere;

    setUpAll(() {
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withMacro = dog.instanceMethods.firstWhere((m) => m.name == 'withMacro');
      withMacro2 =
          dog.instanceMethods.firstWhere((m) => m.name == 'withMacro2');
      withPrivateMacro =
          dog.instanceMethods.firstWhere((m) => m.name == 'withPrivateMacro');
      withUndefinedMacro =
          dog.instanceMethods.firstWhere((m) => m.name == 'withUndefinedMacro');
      MacrosFromAccessors =
          fakeLibrary.enums.firstWhere((e) => e.name == 'MacrosFromAccessors');
      macroReferencedHere = MacrosFromAccessors.publicEnumValues
          .firstWhere((e) => e.name == 'macroReferencedHere') as EnumField;
      ClassTemplateOneLiner = exLibrary.allClasses
          .firstWhere((c) => c.name == 'ClassTemplateOneLiner');
    });

    test('via reexport does not leave behind template crumbs', () {
      expect(ClassTemplateOneLiner.isCanonical, isFalse);
      expect(
          ClassTemplateOneLiner.oneLineDoc,
          equals(
              'I had better not have a template directive in my one liner.'));
    });

    test('renders a macro defined within a enum', () {
      expect(macroReferencedHere.documentationAsHtml,
          contains('This is a macro defined in an Enum accessor.'));
    });

    test("renders a macro within the same comment where it's defined", () {
      expect(withMacro.documentation,
          equals('Macro method\n\nFoo macro content\n\nMore docs'));
    });

    test("renders a macro in another method, not the same where it's defined",
        () {
      expect(withMacro2.documentation, equals('Foo macro content'));
    });

    test('renders a macro defined in a private symbol', () {
      expect(withPrivateMacro.documentation, contains('Private macro content'));
    });

    test('a warning is generated for unknown macros', () {
      // Retrieve documentation first to generate the warning.
      withUndefinedMacro.documentation;
      expect(
          packageGraph.packageWarningCounter.hasWarning(withUndefinedMacro,
              PackageWarning.unknownMacro, 'ThatDoesNotExist'),
          isTrue);
    });
  });

  group('YouTube', () {
    Class dog;
    late final Method withYouTubeWatchUrl;
    late final Method withYouTubeInOneLineDoc;
    late final Method withYouTubeInline;

    setUpAll(() {
      dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withYouTubeWatchUrl = dog.instanceMethods
          .firstWhere((m) => m.name == 'withYouTubeWatchUrl');
      withYouTubeInOneLineDoc = dog.instanceMethods
          .firstWhere((m) => m.name == 'withYouTubeInOneLineDoc');
      withYouTubeInline =
          dog.instanceMethods.firstWhere((m) => m.name == 'withYouTubeInline');
    });

    test(
        'renders a YouTube video within the method documentation with correct max height/width',
        () {
      expect(
        withYouTubeWatchUrl.documentation,
        contains(
          '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"',
        ),
      );
      expect(
        withYouTubeWatchUrl.documentation,
        contains('max-width: 560px;'),
      );
      expect(
        withYouTubeWatchUrl.documentation,
        contains('max-height: 315px;'),
      );
    });
    test("Doesn't place YouTube video in one line doc", () {
      expect(
        withYouTubeInOneLineDoc.oneLineDoc,
        isNot(
          contains(
            '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"',
          ),
        ),
      );
      expect(
        withYouTubeInOneLineDoc.documentation,
        contains(
          '<iframe src="https://www.youtube.com/embed/oHg5SJYRHA0?rel=0"',
        ),
      );
    });
    test('Handles YouTube video inline properly', () {
      // Make sure it doesn't have a double-space before the continued line,
      // which would indicate to Markdown to indent the line.
      expect(withYouTubeInline.documentation, isNot(contains('  works')));
    });
  });

  group('Animation', () {
    late final Method withAnimationInOneLineDoc;
    late final Method withAnimationInline;

    setUpAll(() {
      var dog = exLibrary.classes.firstWhere((c) => c.name == 'Dog');
      withAnimationInOneLineDoc = dog.instanceMethods
          .firstWhere((m) => m.name == 'withAnimationInOneLineDoc');
      withAnimationInline = dog.instanceMethods
          .firstWhere((m) => m.name == 'withAnimationInline');
    });

    test("Doesn't place animations in one line doc", () {
      expect(withAnimationInOneLineDoc.oneLineDoc, isNot(contains('<video')));
      expect(withAnimationInOneLineDoc.documentation, contains('<video'));
    });
    test('Handles animations inline properly', () {
      // Make sure it doesn't have a double-space before the continued line,
      // which would indicate to Markdown to indent the line.
      expect(withAnimationInline.documentation, isNot(contains('  works')));
    });
  });

  group('MultiplyInheritedExecutableElement handling', () {
    late final Class BaseThingy, BaseThingy2, ImplementingThingy2;
    late final Method aImplementingThingyMethod;
    late final Field aImplementingThingyField;
    late final Field aImplementingThingy;
    late final Accessor aImplementingThingyAccessor;

    setUpAll(() {
      BaseThingy =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseThingy');
      BaseThingy2 =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseThingy2');
      ImplementingThingy2 = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ImplementingThingy2');

      aImplementingThingy = ImplementingThingy2.instanceFields
          .firstWhere((m) => m.name == 'aImplementingThingy');
      aImplementingThingyMethod = ImplementingThingy2.instanceMethods
          .firstWhere((m) => m.name == 'aImplementingThingyMethod');
      aImplementingThingyField = ImplementingThingy2.instanceFields
          .firstWhere((m) => m.name == 'aImplementingThingyField');
      aImplementingThingyAccessor = aImplementingThingyField.getter!;
    });

    test('Verify behavior of imperfect resolver', () {
      expect(aImplementingThingy.element.enclosingElement,
          equals(BaseThingy2.element));
      expect(aImplementingThingyMethod.element.enclosingElement,
          equals(BaseThingy.element));
      expect(aImplementingThingyField.element.enclosingElement,
          equals(BaseThingy.element));
      expect(aImplementingThingyAccessor.element.enclosingElement,
          equals(BaseThingy.element));
    });
  });

  group('Docs as HTML', () {
    late final Class Apple, B, superAwesomeClass, foo2;
    late final TopLevelVariable incorrectDocReferenceFromEx;
    late final ModelFunction thisIsAsync;
    late final ModelFunction topLevelFunction;

    late final Class extendedClass;
    late final TopLevelVariable testingCodeSyntaxInOneLiners;

    late final Class specialList;
    Class baseForDocComments;
    late final Method doAwesomeStuff;
    late final Class subForDocComments;

    late final ModelFunction short;

    setUpAll(() {
      incorrectDocReferenceFromEx = exLibrary.constants
          .firstWhere((c) => c.name == 'incorrectDocReferenceFromEx');
      B = exLibrary.classes.firstWhere((c) => c.name == 'B');
      Apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      specialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');
      topLevelFunction =
          fakeLibrary.functions.firstWhere((f) => f.name == 'topLevelFunction');
      thisIsAsync =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsAsync');
      testingCodeSyntaxInOneLiners = fakeLibrary.constants
          .firstWhere((c) => c.name == 'testingCodeSyntaxInOneLiners');
      superAwesomeClass = fakeLibrary.classes
          .firstWhere((cls) => cls.name == 'SuperAwesomeClass');
      foo2 = fakeLibrary.classes.firstWhere((cls) => cls.name == 'Foo2');
      extendedClass = twoExportsLib.allClasses
          .firstWhere((clazz) => clazz.name == 'ExtendingClass');

      subForDocComments =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SubForDocComments');

      baseForDocComments =
          fakeLibrary.classes.firstWhere((c) => c.name == 'BaseForDocComments');
      doAwesomeStuff = baseForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'doAwesomeStuff');

      short = fakeLibrary.functions.firstWhere((f) => f.name == 'short');
    });

    group('markdown extensions', () {
      late final Class DocumentWithATable;
      late final String docsAsHtml;

      setUpAll(() {
        DocumentWithATable = fakeLibrary.classes
            .firstWhere((cls) => cls.name == 'DocumentWithATable');
        docsAsHtml = DocumentWithATable.documentationAsHtml;
      });

      test('Verify table appearance', () {
        expect(
          docsAsHtml,
          contains('<table>\n<thead>\n<tr>\n<th>Component</th>'),
        );
      });

      test('Verify links inside of table headers', () {
        expect(
            docsAsHtml,
            contains(
                '<th><a href="${htmlBasePlaceholder}fake/Annotation-class.html">Annotation</a></th>'));
      });

      test('Verify links inside of table body', () {
        expect(
          docsAsHtml,
          contains('<tbody>\n'
              '<tr>\n'
              '<td><a href="${htmlBasePlaceholder}fake/DocumentWithATable/foo-constant.html">foo</a></td>'),
        );
      });

      test('Verify there is no emoji support', () {
        var tpvar = fakeLibrary.constants
            .firstWhere((t) => t.name == 'hasMarkdownInDoc');
        var tpvarDocsAsHtml = tpvar.documentationAsHtml;
        expect(tpvarDocsAsHtml, contains('3ffe:2a00:100:7031::1'));
      });
    });

    group('Comment processing', () {
      test('can virtually add nodoc via options file', () {
        var NodocMeLibrary = packageGraph.defaultPackage.allLibraries
            .firstWhere((l) => l.name == 'nodocme');
        expect(NodocMeLibrary.hasNodoc, isTrue);
        var NodocMeImplementation = fakeLibrary.allClasses
            .firstWhere((c) => c.name == 'NodocMeImplementation');
        expect(NodocMeImplementation.hasNodoc, isTrue);
        expect(NodocMeImplementation.isPublic, isFalse);
        var MeNeitherEvenWithoutADocComment = fakeLibrary.allClasses
            .firstWhere((c) => c.name == 'MeNeitherEvenWithoutADocComment');
        expect(MeNeitherEvenWithoutADocComment.hasNodoc, isTrue);
        expect(MeNeitherEvenWithoutADocComment.isPublic, isFalse);
      });
    });

    group('doc references', () {
      late final String docsAsHtml;

      setUpAll(() {
        docsAsHtml = doAwesomeStuff.documentationAsHtml;
      });

      test('Verify links to inherited members inside class', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/ImplicitProperties/forInheriting.html">ClassWithUnusualProperties.forInheriting</a>'));
        expect(
            docsAsHtml,
            contains(
                '<a href="%%__HTMLBASE_dartdoc_internal__%%reexport_two/BaseReexported/action.html">ExtendedBaseReexported.action</a></p>'));
        var doAwesomeStuffWarnings = packageGraph.packageWarningCounter
                .countedWarnings[doAwesomeStuff.element] ??
            {};
        expect(
            doAwesomeStuffWarnings,
            isNot(doAwesomeStuffWarnings
                .containsKey(PackageWarning.ambiguousDocReference)));
      });

      test('can handle renamed imports', () {
        var aFunctionUsingRenamedLib = fakeLibrary.functions
            .firstWhere((f) => f.name == 'aFunctionUsingRenamedLib');
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to library: <a href="${htmlBasePlaceholder}mylibpub/mylibpub-library.html">renamedLib</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (implied): <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/YetAnotherHelper.html">new renamedLib.YetAnotherHelper()</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (implied, no new): <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/YetAnotherHelper.html">renamedLib.YetAnotherHelper()</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to class: <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper-class.html">renamedLib.YetAnotherHelper</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to constructor (direct): <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/YetAnotherHelper.html">renamedLib.YetAnotherHelper.YetAnotherHelper</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to class member: <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/getMoreContents.html">renamedLib.YetAnotherHelper.getMoreContents</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to function: <a href="${htmlBasePlaceholder}mylibpub/helperFunction.html">renamedLib.helperFunction</a>'));
        expect(
            aFunctionUsingRenamedLib.documentationAsHtml,
            contains(
                'Link to overlapping prefix: <a href="${htmlBasePlaceholder}csspub/theOnlyThingInTheLibrary.html">renamedLib2.theOnlyThingInTheLibrary</a>'));
      });

      test('operator [] reference within a class works', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/BaseForDocComments/operator_get.html">operator []</a> '));
      });

      test('operator [] reference outside of a class works',
          skip: 'https://github.com/dart-lang/dartdoc/issues/1285', () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/SpecialList/operator_get.html">'
              'SpecialList.operator []</a> '),
        );
      });

      test('adds <code> tag to a class from the SDK', () {
        expect(docsAsHtml, contains('<code>String</code>'));
      });

      test('adds <code> tag to a reference to its parameter', () {
        expect(docsAsHtml, contains('<code>value</code>'));
      });

      test('links to a reference to its class', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/BaseForDocComments-class.html">BaseForDocComments</a>'));
      });

      test(
          'link to a name in another library in this package, but is not imported into this library, should still be linked',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}anonymous_library/doesStuff.html">doesStuff</a>'));
      });

      test(
          'link to unresolved name in the library in this package still should be linked',
          () {
        var helperClass =
            exLibrary.classes.firstWhere((c) => c.name == 'Helper');
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'));
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}ex/B-class.html">ex.B</a>'));
      });

      test('link to override method in implementer from base class', () {
        var helperClass =
            baseClassLib.classes.firstWhere((c) => c.name == 'Constraints');
        expect(
            helperClass.documentationAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}override_class/BoxConstraints/debugAssertIsValid.html">BoxConstraints.debugAssertIsValid</a>'));
      });

      test(
          'link to a name of a class from an imported library that exports the name',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}two_exports/BaseClass-class.html">BaseClass</a>'));
      });

      test(
          'links to a reference to a top-level const with multiple underscores',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/NAME_WITH_TWO_UNDERSCORES-constant.html">NAME_WITH_TWO_UNDERSCORES</a>'));
      });

      test('links to a method in this class', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/BaseForDocComments/anotherMethod.html">anotherMethod</a>'));
      });

      test('links to a top-level function in this library', () {
        expect(
            docsAsHtml,
            contains(
                '<a class="deprecated" href="${htmlBasePlaceholder}fake/topLevelFunction.html">topLevelFunction</a>'));
      });

      test('links to top-level function from an imported library', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}ex/function1.html">function1</a>'));
      });

      test('links to a class from an imported lib', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'));
      });

      test(
          'links to a top-level const from same lib (which also has the same name as a const from an imported lib)',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/incorrectDocReference-constant.html">incorrectDocReference</a>'));
      });

      test('links to a top-level const from an imported lib', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}ex/incorrectDocReferenceFromEx-constant.html">incorrectDocReferenceFromEx</a>'));
      });

      test('links to a top-level variable with a prefix from an imported lib',
          () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}csspub/theOnlyThingInTheLibrary.html">css.theOnlyThingInTheLibrary</a>'));
      });

      test('links to a name with a single underscore', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/NAME_SINGLEUNDERSCORE-constant.html">NAME_SINGLEUNDERSCORE</a>'));
      });

      test('correctly escapes type parameters in links', () {
        expect(
            docsAsHtml,
            contains(
                '<a href="${htmlBasePlaceholder}fake/ExtraSpecialList-class.html">ExtraSpecialList&lt;Object&gt;</a>'));
      });

      test('correctly escapes type parameters in broken links', () {
        expect(docsAsHtml,
            contains('<code>ThisIsNotHereNoWay&lt;MyType&gt;</code>'));
      });

      test('leaves relative href resulting in a working link', () {
        // Ideally doc comments should not make assumptions about Dartdoc output
        // files, but unfortunately some do...
        expect(
            docsAsHtml,
            contains(
                '<a href="../SubForDocComments/localMethod.html">link</a>'));
      });
    });

    test('multi-underscore names in brackets do not become italicized', () {
      expect(short.documentation, contains('[NAME_WITH_TWO_UNDERSCORES]'));
      expect(
          short.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/NAME_WITH_TWO_UNDERSCORES-constant.html">NAME_WITH_TWO_UNDERSCORES</a>'));
    });

    test('still has brackets inside code blocks', () {
      expect(topLevelFunction.documentationAsHtml,
          contains("['hello from dart']"));
    });

    test('oneLine doc references in inherited methods should not have brackets',
        () {
      var add = specialList.instanceMethods.firstWhere((m) => m.name == 'add');
      expect(
          add.oneLineDoc,
          equals(
              'Adds <code>value</code> to the end of this list,\nextending the length by one.'));
    });

    test(
        'full documentation references from inherited methods should not have brackets',
        () {
      var add = specialList.instanceMethods.firstWhere((m) => m.name == 'add');
      expect(
          add.documentationAsHtml,
          startsWith(
              '<p>Adds <code>value</code> to the end of this list,\nextending the length by one.'));
    });

    test('incorrect doc references are still wrapped in code blocks', () {
      expect(incorrectDocReferenceFromEx.documentationAsHtml,
          '<p>This should <code>not work</code>.</p>');
    });

    test('no references', () {
      expect(
          Apple.documentationAsHtml,
          '<p>Sample class <code>String</code></p>\n'
          '<pre class="language-dart">  A\n'
          '   B\n'
          '</pre>');
    });

    test('single ref to class', () {
      expect(
          B.documentationAsHtml,
          contains(
              '<p>Extends class <a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>, use <a href="${htmlBasePlaceholder}ex/Apple/Apple.html">Apple.new</a> or <a href="${htmlBasePlaceholder}ex/Apple/Apple.fromString.html">Apple.fromString</a></p>'));
    });

    test('doc ref to class in SDK does not render as link', () {
      expect(
          thisIsAsync.documentationAsHtml,
          equals(
              '<p>An async function. It should look like I return a <code>Future</code>.</p>'));
    });

    test('references are correct in exported libraries', () {
      expect(twoExportsLib, isNotNull);
      expect(extendedClass, isNotNull);
      var resolved = extendedClass.documentationAsHtml;
      expect(resolved, isNotNull);
      expect(
          resolved,
          contains(
              '<a href="${htmlBasePlaceholder}two_exports/BaseClass-class.html">BaseClass</a>'));
      expect(
          resolved,
          contains(
              'Linking over to <a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'));
    });

    test('references to class and constructors', () {
      var comment = B.documentationAsHtml;
      expect(
          comment,
          contains(
              'Extends class <a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'));
      expect(
          comment,
          contains(
              'use <a href="${htmlBasePlaceholder}ex/Apple/Apple.html">Apple.new</a>'));
      expect(
          comment,
          contains(
              '<a href="${htmlBasePlaceholder}ex/Apple/Apple.fromString.html">Apple.fromString</a>'));
    });

    test('references to nullable type and null-checked variable', () {
      var RefsWithQsAndBangs =
          exLibrary.classes.firstWhere((c) => c.name == 'RefsWithQsAndBangs');
      var comment = RefsWithQsAndBangs.documentationAsHtml;
      expect(
          comment,
          contains(
              'nullable type: <a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple?</a>'));
      expect(
          comment,
          contains(
              'null-checked variable <a href="${htmlBasePlaceholder}ex/myNumber.html">myNumber!</a>'));
    });

    test('reference to constructor named the same as a field', () {
      var FieldAndCtorWithSameName = exLibrary.classes
          .firstWhere((c) => c.name == 'FieldAndCtorWithSameName');
      var comment = FieldAndCtorWithSameName.documentationAsHtml;
      expect(
          comment,
          contains('Reference to '
              '<a href="${htmlBasePlaceholder}ex/FieldAndCtorWithSameName/FieldAndCtorWithSameName.named.html">'
              'FieldAndCtorWithSameName.named()</a>'));
    });

    test('reference to class from another library', () {
      var comment = superAwesomeClass.documentationAsHtml;
      expect(
          comment,
          contains(
              '<a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'));
    });

    test('reference to method', () {
      var comment = foo2.documentationAsHtml;
      expect(
          comment,
          equals(
              '<p>link to method from class <a href="${htmlBasePlaceholder}ex/Apple/m.html">Apple.m</a></p>'));
    });

    test(
        'code references to privately defined elements in public classes work properly',
        () {
      var notAMethodFromPrivateClass = fakeLibrary.allClasses
          .firstWhere((Class c) => c.name == 'ReferringClass')
          .publicInstanceMethods
          .firstWhere((Method m) => m.name == 'notAMethodFromPrivateClass');
      expect(
          notAMethodFromPrivateClass.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/InheritingClassOne/aMethod.html">fake.InheritingClassOne.aMethod</a>'));
      expect(
          notAMethodFromPrivateClass.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/InheritingClassTwo/aMethod.html">fake.InheritingClassTwo.aMethod</a>'));
    });

    test('legacy code blocks render correctly', () {
      expect(
          testingCodeSyntaxInOneLiners.oneLineDoc,
          equals(
              'These are code syntaxes: <code>true</code> and <code>false</code>'));
    });

    test('doc comments to parameters are marked as code', () {
      var localMethod = subForDocComments.instanceMethods
          .firstWhere((m) => m.name == 'localMethod');
      expect(localMethod.documentationAsHtml, contains('<code>foo</code>'));
      expect(localMethod.documentationAsHtml, contains('<code>bar</code>'));
    });

    test('doc comment inherited from getter', () {
      var getterWithDocs = subForDocComments.instanceFields
          .firstWhere((m) => m.name == 'getterWithDocs');
      expect(getterWithDocs.documentationAsHtml,
          contains('Some really great topics.'));
    });

    test(
        'a property with no explicit getters and setters does not duplicate docs',
        () {
      var powers = superAwesomeClass.instanceFields
          .firstWhere((p) => p.name == 'powers');
      Iterable<Match> matches =
          RegExp('In the super class').allMatches(powers.documentationAsHtml);
      expect(matches, hasLength(1));
    });
  });

  group('Class edge cases', () {
    // This is distinct from inheritance in the language and the analyzer
    // implementation.
    test(
        'Implementor chain is correctly rewritten through intermediate private classes',
        () {
      var implementorsLibrary = packageGraph.publicLibraries
          .firstWhere((l) => l.name == 'implementors');
      var ImplementerOfDeclaredPrivateClasses = implementorsLibrary.classes
          .firstWhere((c) => c.name == 'ImplementerOfDeclaredPrivateClasses');
      var ImplementerOfThings = implementorsLibrary.classes
          .firstWhere((c) => c.name == 'ImplementerOfThings');
      var ImplementBase = implementorsLibrary.classes
          .firstWhere((c) => c.name == 'ImplementBase');

      expect(ImplementerOfThings.publicInterfaces.first.modelElement,
          equals(ImplementBase));
      expect(
          ImplementerOfDeclaredPrivateClasses
              .publicInterfaces.first.modelElement,
          equals(ImplementBase));

      expect(ImplementBase.publicImplementors,
          contains(ImplementerOfDeclaredPrivateClasses));
      expect(ImplementBase.publicImplementors, contains(ImplementerOfThings));
    });

    test('Overrides from intermediate abstract classes are picked up correctly',
        () {
      var IntermediateAbstractSubclass = fakeLibrary.allClasses
          .firstWhere((c) => c.name == 'IntermediateAbstractSubclass');
      var operatorEquals = IntermediateAbstractSubclass.inheritedOperators
          .firstWhere((o) => o.name == 'operator ==');
      expect(operatorEquals.definingEnclosingContainer.name,
          equals('IntermediateAbstract'));
    });

    test(
        'Overrides from intermediate abstract classes that have external implementations via the SDK are picked up correctly',
        () {
      var dartCore =
          packageGraph.libraries.firstWhere((l) => l.name == 'dart:core');
      var intClass = dartCore.allClasses.firstWhere((c) => c.name == 'int');
      var operatorEqualsInt = intClass.inheritedOperators
          .firstWhere((o) => o.name == 'operator ==');
      expect(operatorEqualsInt.definingEnclosingContainer.name, equals('num'));
    });

    test('Factories from unrelated classes are linked correctly', () {
      var A = packageGraph.localPublicLibraries
          .firstWhere((l) => l.name == 'unrelated_factories')
          .allClasses
          .firstWhere((c) => c.name == 'A');
      var fromMap = A.constructors.firstWhere((c) => c.name == 'A.fromMap');
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/AB/AB.fromMap.html">AB.fromMap</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'A/A.fromMap.html">fromMap</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/AB-class.html">AB</a>'));
      expect(fromMap.documentationAsHtml,
          contains(r'unrelated_factories/A-class.html">A</a>'));
    });

    test('Inherit from private class across private library to public library',
        () {
      var GadgetExtender = packageGraph.localPublicLibraries
          .firstWhere((l) => l.name == 'gadget_extender')
          .allClasses
          .firstWhere((c) => c.name == 'GadgetExtender');
      var gadgetGetter = GadgetExtender.instanceFields
          .firstWhere((f) => f.name == 'gadgetGetter');
      expect(gadgetGetter.isCanonical, isTrue);
    });

    test(
        'ExecutableElements from private classes and from public interfaces (#1561)',
        () {
      var MIEEMixinWithOverride = fakeLibrary.publicClasses
          .firstWhere((c) => c.name == 'MIEEMixinWithOverride');
      var problematicOperator = MIEEMixinWithOverride.inheritedOperators
          .firstWhere((o) => o.name == 'operator []=');
      expect(problematicOperator.element.enclosingElement.name,
          equals('_MIEEPrivateOverride'));
      expect(problematicOperator.canonicalModelElement!.enclosingElement!.name,
          equals('MIEEMixinWithOverride'));
    });
  });

  group('Mixin', () {
    late final Mixin GenericMixin;
    late final Class GenericClass, ModifierClass, TypeInferenceMixedIn;
    late final Field overrideByEverything,
        overrideByGenericMixin,
        overrideByBoth,
        overrideByModifierClass;

    setUpAll(() {
      var classes = fakeLibrary.publicClasses;
      GenericClass = classes.firstWhere((c) => c.name == 'GenericClass');
      ModifierClass = classes.firstWhere((c) => c.name == 'ModifierClass');
      GenericMixin =
          fakeLibrary.publicMixins.firstWhere((m) => m.name == 'GenericMixin');
      TypeInferenceMixedIn =
          classes.firstWhere((c) => c.name == 'TypeInferenceMixedIn');
      overrideByEverything = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'overrideByEverything');
      overrideByGenericMixin = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'overrideByGenericMixin');
      overrideByBoth = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'overrideByBoth');
      overrideByModifierClass = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'overrideByModifierClass');
    });

    test('computes interfaces and implementors correctly', () {
      var ThingToImplementInMixin = fakeLibrary.publicClasses
          .firstWhere((c) => c.name == 'ThingToImplementInMixin');
      var MixedInImplementation = fakeLibrary.publicClasses
          .firstWhere((c) => c.name == 'MixedInImplementation');
      var MixInImplementation =
          fakeLibrary.mixins.firstWhere((m) => m.name == 'MixInImplementation');
      var mixinGetter = MixInImplementation.allFields
          .firstWhere((f) => f.name == 'mixinGetter');

      expect(ThingToImplementInMixin.hasModifiers, isTrue);
      expect(MixInImplementation.hasModifiers, isTrue);
      expect(MixedInImplementation.hasModifiers, isTrue);
      expect(ThingToImplementInMixin.publicImplementors,
          orderedEquals([MixInImplementation]));
      expect(MixInImplementation.publicImplementors,
          orderedEquals([MixedInImplementation]));
      expect(
          MixedInImplementation.allFields
              .firstWhere((f) => f.name == 'mixinGetter')
              .canonicalModelElement,
          equals(mixinGetter));
    });

    test('does have a line number and column', () {
      expect(GenericMixin.characterLocation, isNotNull);
    });

    test('Verify inheritance/mixin structure and type inference', () {
      expect(
          TypeInferenceMixedIn.mixedInTypes
              .map<String>((DefinedElementType t) => t.modelElement.name),
          orderedEquals(['GenericMixin']));
      expect(
          TypeInferenceMixedIn.mixedInTypes.first.typeArguments
              .map<String>((ElementType t) => t.name),
          orderedEquals(['int']));

      expect(TypeInferenceMixedIn.superChain, hasLength(2));
      final firstType =
          TypeInferenceMixedIn.superChain.first as ParameterizedElementType;
      final lastType =
          TypeInferenceMixedIn.superChain.last as ParameterizedElementType;
      expect(firstType.name, equals('ModifierClass'));
      expect(firstType.typeArguments.map<String>((ElementType t) => t.name),
          orderedEquals(['int']));
      expect(lastType.name, equals('GenericClass'));
      expect(lastType.typeArguments.map<String>((ElementType t) => t.name),
          orderedEquals(['int']));
    });

    test('Verify non-overridden members have right canonical classes', () {
      var member = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'member');
      var modifierMember = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'modifierMember');
      var mixinMember = TypeInferenceMixedIn.instanceFields
          .firstWhere((f) => f.name == 'mixinMember');
      expect(member.canonicalEnclosingContainer, equals(GenericClass));
      expect(modifierMember.canonicalEnclosingContainer, equals(ModifierClass));
      expect(mixinMember.canonicalEnclosingContainer, equals(GenericMixin));
    });

    test('Verify overrides & documentation inheritance work as intended', () {
      expect(overrideByEverything.canonicalEnclosingContainer,
          equals(TypeInferenceMixedIn));
      expect(overrideByGenericMixin.canonicalEnclosingContainer,
          equals(GenericMixin));
      expect(overrideByBoth.canonicalEnclosingContainer, equals(GenericMixin));
      expect(overrideByModifierClass.canonicalEnclosingContainer,
          equals(ModifierClass));
      expect(
          overrideByEverything.documentationFrom.first,
          equals(GenericClass.instanceFields
              .firstWhere((f) => f.name == 'overrideByEverything')
              .getter));
      expect(
          overrideByGenericMixin.documentationFrom.first,
          equals(GenericClass.instanceFields
              .firstWhere((f) => f.name == 'overrideByGenericMixin')
              .getter));
      expect(
          overrideByBoth.documentationFrom.first,
          equals(GenericClass.instanceFields
              .firstWhere((f) => f.name == 'overrideByBoth')
              .getter));
      expect(
          overrideByModifierClass.documentationFrom.first,
          equals(GenericClass.instanceFields
              .firstWhere((f) => f.name == 'overrideByModifierClass')
              .getter));
    });

    test('Verify that documentation for mixin applications contains links', () {
      expect(
          overrideByModifierClass.oneLineDoc,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByModifierClass.canonicalModelElement!.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByGenericMixin.oneLineDoc,
          contains(
              '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByGenericMixin.canonicalModelElement!.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByBoth.oneLineDoc,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByBoth.oneLineDoc,
          contains(
              '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'));
      expect(
          overrideByBoth.canonicalModelElement!.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'));
      expect(
          overrideByBoth.canonicalModelElement!.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'));
    });
  });

  group('Class', () {
    late final List<Class> classes;
    late final Class Apple, B, Cat, Dog, F, Dep, SpecialList;
    late final Class ExtendingClass, CatString;

    setUpAll(() {
      classes = exLibrary.publicClasses.toList();
      Apple = classes.firstWhere((c) => c.name == 'Apple');
      B = classes.firstWhere((c) => c.name == 'B');
      Cat = classes.firstWhere((c) => c.name == 'Cat');
      Dog = classes.firstWhere((c) => c.name == 'Dog');
      F = classes.firstWhere((c) => c.name == 'F');
      Dep = classes.firstWhere((c) => c.name == 'Deprecated');
      SpecialList =
          fakeLibrary.classes.firstWhere((c) => c.name == 'SpecialList');
      ExtendingClass =
          twoExportsLib.classes.firstWhere((c) => c.name == 'ExtendingClass');
      CatString = exLibrary.classes.firstWhere((c) => c.name == 'CatString');
    });

    test('has a fully qualified name', () {
      expect(Apple.fullyQualifiedName, 'ex.Apple');
    });

    test('does have a line number and column', () {
      expect(Apple.characterLocation, isNotNull);
    });

    test('we got the classes we expect', () {
      expect(Apple.name, equals('Apple'));
      expect(B.name, equals('B'));
      expect(Cat.name, equals('Cat'));
      expect(Dog.name, equals('Dog'));
    });

    test('a class with only inherited properties has some properties', () {
      expect(CatString.hasInstanceFields, isTrue);
      expect(CatString.instanceFields, isNotEmpty);
    });

    test('has enclosing element', () {
      expect(Apple.enclosingElement.name, equals(exLibrary.name));
    });

    test('class name with generics', () {
      expect(
          F.nameWithGenerics,
          equals(
              'F&lt;<wbr><span class="type-parameter">T extends String</span>&gt;'));
    });

    test('correctly finds all the classes', () {
      expect(classes, hasLength(37));
    });

    test('abstract', () {
      expect(Cat.isAbstract, isTrue);
    });

    test('supertype', () {
      expect(B.hasPublicSuperChainReversed, isTrue);
    });

    test('mixins', () {
      expect(Apple.mixedInTypes, hasLength(0));
    });

    test('mixins private', () {
      expect(F.mixedInTypes, hasLength(1));
    });

    test('interfaces', () {
      var interfaces = Dog.interfaces;
      expect(interfaces, hasLength(2));
      expect(interfaces[0].name, 'Cat');
      expect(interfaces[1].name, 'E');
    });

    test('class title has abstract keyword', () {
      expect(Cat.fullkind, 'abstract class');
    });

    test('class title has no abstract keyword', () {
      expect(Dog.fullkind, 'class');
    });

    test('get constructors', () {
      expect(Apple.publicConstructorsSorted, hasLength(2));
    });

    test('get static fields', () {
      expect(Apple.publicVariableStaticFieldsSorted, hasLength(1));
    });

    test('constructors have source', () {
      var ctor = Dog.constructors.first;
      expect(ctor.sourceCode, isNotEmpty);
    });

    test('get constants', () {
      expect(Apple.publicConstantFields, hasLength(1));
      expect(Apple.publicConstantFields.first.kind, equals('constant'));
    });

    test('get instance fields', () {
      expect(Apple.publicInstanceFields.where((f) => !f.isInherited),
          hasLength(3));
      expect(Apple.publicInstanceFields.first.kind, equals('property'));
    });

    test('get inherited properties, including properties of Object', () {
      expect(B.publicInheritedFields, hasLength(4));
    });

    test('get methods', () {
      expect(Dog.publicInstanceMethods.where((m) => !m.isInherited),
          hasLength(16));
    });

    test('get operators', () {
      expect(Dog.publicInstanceOperators, hasLength(2));
      expect(Dog.publicInstanceOperators.first.name, 'operator ==');
      expect(Dog.publicInstanceOperators.last.name, 'operator +');
    });

    test('has non-inherited instance operators', () {
      expect(Dog.publicInheritedInstanceOperators, isFalse);
    });

    test('has only inherited instance operators', () {
      expect(Cat.publicInheritedInstanceOperators, isTrue);
    });

    test('inherited methods, including from Object ', () {
      expect(B.publicInheritedMethods, hasLength(7));
      expect(B.hasPublicInheritedMethods, isTrue);
    });

    test('all instance methods', () {
      var methods = B.publicInstanceMethods.where((m) => !m.isInherited);
      expect(methods, isNotEmpty);
      expect(B.publicInstanceMethods,
          hasLength(methods.length + B.publicInheritedMethods.length));
    });

    test('inherited methods exist', () {
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'printMsg'),
          isNotNull);
      expect(B.inheritedMethods.firstWhere((x) => x.name == 'isGreaterThan'),
          isNotNull);
    });

    test('exported class should have hrefs from the current library', () {
      expect(
          Dep.href, equals('${htmlBasePlaceholder}ex/Deprecated-class.html'));
      expect(Dep.instanceMethods.firstWhere((m) => m.name == 'toString').href,
          equals('${htmlBasePlaceholder}ex/Deprecated/toString.html'));
    });

    test('F has a single instance method', () {
      expect(
          F.publicInstanceMethods.where((m) => !m.isInherited), hasLength(1));
      expect(
          F.publicInstanceMethods.first.name, equals('methodWithGenericParam'));
    });

    test('F has many inherited methods', () {
      expect(
          F.publicInheritedMethods.map((im) => im.name),
          containsAll([
            'abstractMethod',
            'foo',
            'getAnotherClassD',
            'getClassA',
            'noSuchMethod',
            'test',
            'testGeneric',
            'testGenericMethod',
            'testMethod',
            'toString',
            'withAnimationInline',
            'withAnimationInOneLineDoc',
            'withMacro',
            'withMacro2',
            'withPrivateMacro',
            'withUndefinedMacro',
            'withYouTubeInline',
            'withYouTubeInOneLineDoc',
            'withYouTubeWatchUrl',
          ]));
    });

    test('F has zero declared instance properties', () {
      expect(F.publicInstanceFields.where((f) => !f.isInherited), hasLength(0));
    });

    test('F has a few inherited properties', () {
      expect(F.publicInheritedFields, hasLength(10));
      expect(
          F.publicInheritedFields.map((ip) => ip.name),
          containsAll([
            'aFinalField',
            'aGetterReturningRandomThings',
            'aProtectedFinalField',
            'deprecatedField',
            'deprecatedGetter',
            'deprecatedSetter',
            'hashCode',
            'isImplemented',
            'name',
            'runtimeType'
          ]));
    });

    test('SpecialList has zero instance methods', () {
      expect(SpecialList.publicInstanceMethods.where((m) => !m.isInherited),
          hasLength(0));
    });

    test('SpecialList has many inherited methods', () {
      expect(SpecialList.publicInheritedMethods, hasLength(49));
      var methods = SpecialList.publicInstanceMethodsSorted
          .where((m) => m.isInherited)
          .toList();
      expect(methods.first.name, equals('add'));
      expect(methods[1].name, equals('addAll'));
    });

    test('ExtendingClass is in the right library', () {
      expect(ExtendingClass.library.name, equals('two_exports'));
    });

    // because both the sub and super classes, though from different libraries,
    // are exported out through one library
    test('ExtendingClass has a super class that is also in the same library',
        () {
      // The real implementation of BaseClass is private, but it is exported.
      expect(ExtendingClass.superChain.first.name, equals('BaseClass'));
      expect(ExtendingClass.superChain.first.modelElement.isCanonical,
          equals(false));
      expect(
          ExtendingClass.superChain.first.modelElement.isPublic, equals(false));
      // And it should still show up in the publicSuperChain, because it is
      // exported.
      expect(ExtendingClass.publicSuperChain.first.name, equals('BaseClass'));
      expect(
          ExtendingClass
              .publicSuperChain.first.modelElement.canonicalLibrary!.name,
          equals('two_exports'));
    });

    test(
        "ExtendingClass's super class has a library that is not in two_exports",
        () {
      expect(
          ExtendingClass.superChain.last.name, equals('WithGetterAndSetter'));
      expect(ExtendingClass.superChain.last.modelElement.library.name,
          equals('fake'));
    });
  });

  // Put linkage tests here; rendering tests should go to the appropriate
  // [Class], [Extension], etc groups.
  group('Comment References link tests', () {
    group('Linking for generalized typedef cases works', () {
      late final Library generalizedTypedefs;
      late final Typedef T0, T2, T5, T8;
      late final Class C1, C2;
      late final Field C1a;

      setUpAll(() {
        generalizedTypedefs = packageGraph.libraries
            .firstWhere((l) => l.name == 'generalized_typedefs');
        T0 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T0');
        T2 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T2');
        T5 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T5');
        T8 = generalizedTypedefs.typedefs.firstWhere((a) => a.name == 'T8');
        C1 = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C1');
        C2 = generalizedTypedefs.classes.firstWhere((c) => c.name == 'C2');
        C1a = C1.allFields.firstWhere((f) => f.name == 'a');
      });

      test('Verify basic ability to link anything', () {
        expect(referenceLookup(T0, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T2, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T5, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T8, 'C2'), equals(MatchingLinkResult(C2)));
      });

      test('Verify ability to link to type parameters', () {
        var T2X = T2.typeParameters.firstWhere((t) => t.name == 'X');
        expect(referenceLookup(T2, 'X'), equals(MatchingLinkResult(T2X)));
        var T5X = T5.typeParameters.firstWhere((t) => t.name == 'X');
        expect(referenceLookup(T5, 'X'), equals(MatchingLinkResult(T5X)));
      });

      test('Verify ability to link to parameters', () {
        var T5name = T5.parameters.firstWhere((t) => t.name == 'name');
        expect(referenceLookup(T5, 'name'), equals(MatchingLinkResult(T5name)));
      });

      test('Verify ability to link to class members of aliased classes', () {
        expect(referenceLookup(generalizedTypedefs, 'T8.a'),
            equals(MatchingLinkResult(C1a)));
        expect(referenceLookup(T8, 'a'), equals(MatchingLinkResult(C1a)));
      });
    });

    group('Linking for complex inheritance and reexport cases', () {
      late Library base, extending, local_scope, two_exports;
      late Class BaseWithMembers, ExtendingAgain;
      late Field aField, anotherField, aStaticField;
      late TopLevelVariable aNotReexportedVariable,
          anotherNotReexportedVariable,
          aSymbolOnlyAvailableInExportContext,
          someConflictingNameSymbolTwoExports,
          someConflictingNameSymbol;
      late Method aStaticMethod;
      late Constructor aConstructor;

      setUp(() {
        base = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'two_exports.src.base');
        extending = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'two_exports.src.extending');
        local_scope = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'two_exports.src.local_scope');
        two_exports = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'two_exports');

        BaseWithMembers =
            base.classes.firstWhere((c) => c.name == 'BaseWithMembers');
        aStaticField = BaseWithMembers.staticFields
            .firstWhere((f) => f.name == 'aStaticField');
        aStaticMethod = BaseWithMembers.staticMethods
            .firstWhere((m) => m.name == 'aStaticMethod');
        aConstructor = BaseWithMembers.constructors
            .firstWhere((c) => c.name == 'BaseWithMembers.aConstructor');

        someConflictingNameSymbol = extending.properties
            .firstWhere((p) => p.name == 'someConflictingNameSymbol');

        // This group tests lookups from the perspective of the reexported
        // elements, to verify that various fallbacks work correctly.
        ExtendingAgain =
            two_exports.classes.firstWhere((c) => c.name == 'ExtendingAgain');
        aField = ExtendingAgain.allFields.firstWhere((f) => f.name == 'aField');
        anotherField = ExtendingAgain.allFields
            .firstWhere((f) => f.name == 'anotherField');

        aNotReexportedVariable = local_scope.properties
            .firstWhere((p) => p.name == 'aNotReexportedVariable');
        anotherNotReexportedVariable = local_scope.properties
            .firstWhere((p) => p.name == 'anotherNotReexportedVariable');
        aSymbolOnlyAvailableInExportContext = two_exports.properties
            .firstWhere((p) => p.name == 'aSymbolOnlyAvailableInExportContext');
        someConflictingNameSymbolTwoExports = two_exports.properties
            .firstWhere((p) => p.name == 'someConflictingNameSymbol');
      });

      test('Grandparent override in container members', () {
        expect(referenceLookup(aField, 'aNotReexportedVariable'),
            equals(MatchingLinkResult(aNotReexportedVariable)));

        // Verify that documentationFrom cases work.  Just having the doc
        // in the base class is enough to trigger [documentationFrom] and this
        // feature.
        expect(referenceLookup(anotherField, 'aNotReexportedVariable'),
            equals(MatchingLinkResult(aNotReexportedVariable)));
      });

      // TODO(jcollins-g): dart-lang/dartdoc#2698
      test('Linking for static/constructor inheritance across libraries', () {
        expect(referenceLookup(ExtendingAgain, 'aStaticField'),
            equals(MatchingLinkResult(aStaticField)));
        expect(referenceLookup(ExtendingAgain, 'aStaticMethod'),
            equals(MatchingLinkResult(aStaticMethod)));
        expect(referenceLookup(ExtendingAgain, 'aConstructor'),
            equals(MatchingLinkResult(aConstructor)));
      });

      test('Linking for inherited field from reexport context', () {
        expect(referenceLookup(aField, 'anotherNotReexportedVariable'),
            equals(MatchingLinkResult(anotherNotReexportedVariable)));
      });

      // TODO(jcollins-g): dart-lang/dartdoc#2696
      test('Allow non-explicit export namespace linking', () {
        expect(
            referenceLookup(
                BaseWithMembers, 'aSymbolOnlyAvailableInExportContext'),
            equals(MatchingLinkResult(aSymbolOnlyAvailableInExportContext)));
      });

      test('Link to definingLibrary for class rather than its export context',
          () {
        expect(referenceLookup(ExtendingAgain, 'someConflictingNameSymbol'),
            equals(MatchingLinkResult(someConflictingNameSymbol)));
        expect(referenceLookup(two_exports, 'someConflictingNameSymbol'),
            equals(MatchingLinkResult(someConflictingNameSymbolTwoExports)));
      });
    });

    group('Type parameter lookups work', () {
      late final Class TypeParameterThings,
          TypeParameterThingsExtended,
          TypeParameterThingsExtendedQ;
      late final Extension UnboundTypeTargetExtension;
      late final Field aName, aThing, doesNotCrash;
      late final TypeParameter ATypeParam,
          BTypeParam,
          CTypeParam,
          DTypeParam,
          QTypeParam;
      late final Method aMethod, aMethodExtended, aMethodExtendedQ;
      late final Parameter aParam, anotherParam, typedParam;
      late final ModelFunction aTopLevelTypeParameterFunction;

      setUpAll(() {
        UnboundTypeTargetExtension = fakeLibrary.extensions
            .firstWhere((f) => f.name == 'UnboundTypeTargetExtension');
        doesNotCrash = UnboundTypeTargetExtension.instanceFields
            .firstWhere((f) => f.name == 'doesNotCrash');

        aTopLevelTypeParameterFunction = fakeLibrary.functions
            .firstWhere((f) => f.name == 'aTopLevelTypeParameterFunction');
        // TODO(jcollins-g): dart-lang/dartdoc#2704, HTML and type parameters
        // on the extended type should not be present here.
        DTypeParam = aTopLevelTypeParameterFunction.typeParameters.firstWhere(
            (t) => t.name.startsWith('DTypeParam extends TypeParameterThings'));
        typedParam = aTopLevelTypeParameterFunction.parameters
            .firstWhere((t) => t.name == 'typedParam');

        TypeParameterThings = fakeLibrary.allClasses
            .firstWhere((c) => c.name == 'TypeParameterThings');
        aName = TypeParameterThings.instanceFields
            .firstWhere((f) => f.name == 'aName');
        aThing = TypeParameterThings.instanceFields
            .firstWhere((f) => f.name == 'aThing');
        aMethod = TypeParameterThings.instanceMethods
            .firstWhere((m) => m.name == 'aMethod');

        CTypeParam =
            aMethod.typeParameters.firstWhere((t) => t.name == 'CTypeParam');
        aParam = aMethod.parameters.firstWhere((p) => p.name == 'aParam');
        anotherParam =
            aMethod.parameters.firstWhere((p) => p.name == 'anotherParam');

        ATypeParam = TypeParameterThings.typeParameters
            .firstWhere((t) => t.name == 'ATypeParam');
        BTypeParam = TypeParameterThings.typeParameters.firstWhere(
            (t) => t.name == 'BTypeParam extends FactoryConstructorThings');

        TypeParameterThingsExtended = fakeLibrary.allClasses
            .firstWhere((c) => c.name == 'TypeParameterThingsExtended');
        aMethodExtended = TypeParameterThingsExtended.instanceMethods
            .firstWhere((m) => m.name == 'aMethod');

        TypeParameterThingsExtendedQ = fakeLibrary.allClasses
            .firstWhere((c) => c.name == 'TypeParameterThingsExtendedQ');
        aMethodExtendedQ = TypeParameterThingsExtendedQ.instanceMethods
            .firstWhere((m) => m.name == 'aMethod');
        QTypeParam = aMethodExtendedQ.typeParameters
            .firstWhere((p) => p.name == 'QTypeParam');
      });

      test('on extension targeting an unbound type', () {
        expect(referenceLookup(UnboundTypeTargetExtension, 'doesNotCrash'),
            equals(MatchingLinkResult(doesNotCrash)));
      });

      test('on inherited documentation', () {
        expect(referenceLookup(aMethodExtended, 'ATypeParam'),
            equals(MatchingLinkResult(ATypeParam)));
        expect(referenceLookup(aMethodExtended, 'BTypeParam'),
            equals(MatchingLinkResult(BTypeParam)));
        expect(referenceLookup(aMethodExtended, 'CTypeParam'),
            equals(MatchingLinkResult(CTypeParam)));
        // Disallowed, because Q does not exist where the docs originated from.
        // The old code forgave this most of the time.
        expect(referenceLookup(aMethodExtended, 'QTypeParam'),
            equals(MatchingLinkResult(null)));

        // We get an inverse situation on the extendedQ class.
        expect(referenceLookup(aMethodExtendedQ, 'ATypeParam'),
            equals(MatchingLinkResult(null)));
        expect(referenceLookup(aMethodExtendedQ, 'BTypeParam'),
            equals(MatchingLinkResult(null)));
        expect(referenceLookup(aMethodExtendedQ, 'CTypeParam'),
            equals(MatchingLinkResult(null)));
        expect(referenceLookup(aMethodExtendedQ, 'QTypeParam'),
            equals(MatchingLinkResult(QTypeParam)));
      });

      test('on classes', () {
        expect(referenceLookup(TypeParameterThings, 'ATypeParam'),
            equals(MatchingLinkResult(ATypeParam)));
        expect(referenceLookup(TypeParameterThings, 'BTypeParam'),
            equals(MatchingLinkResult(BTypeParam)));
        expect(referenceLookup(aName, 'ATypeParam'),
            equals(MatchingLinkResult(ATypeParam)));
        expect(referenceLookup(aThing, 'BTypeParam'),
            equals(MatchingLinkResult(BTypeParam)));
        expect(referenceLookup(aMethod, 'CTypeParam'),
            equals(MatchingLinkResult(CTypeParam)));
        expect(referenceLookup(aParam, 'ATypeParam'),
            equals(MatchingLinkResult(ATypeParam)));
        expect(referenceLookup(anotherParam, 'CTypeParam'),
            equals(MatchingLinkResult(CTypeParam)));
      });

      test('on top level methods', () {
        expect(referenceLookup(aTopLevelTypeParameterFunction, 'DTypeParam'),
            equals(MatchingLinkResult(DTypeParam)));
        expect(referenceLookup(typedParam, 'DTypeParam'),
            equals(MatchingLinkResult(DTypeParam)));
      });
    });

    group('Ordinary namespace cases', () {
      late final Package DartPackage;
      late final Library Dart, mylibpub;
      late final ModelFunction doesStuff,
          function1,
          topLevelFunction,
          aFunctionUsingRenamedLib;
      late final TopLevelVariable incorrectDocReference,
          incorrectDocReferenceFromEx,
          nameWithTwoUnderscores,
          nameWithSingleUnderscore,
          theOnlyThingInTheLibrary;
      late final Constructor aNonDefaultConstructor,
          defaultConstructor,
          aConstructorShadowed,
          anotherName,
          anotherConstructor,
          factoryConstructorThingsDefault;
      late final Class Apple,
          BaseClass,
          baseForDocComments,
          ExtraSpecialList,
          FactoryConstructorThings,
          string,
          metaUseResult;
      late final Method doAwesomeStuff, anotherMethod, aMethod;
      // ignore: unused_local_variable
      late final Operator bracketOperator, bracketOperatorOtherClass;
      late final Parameter doAwesomeStuffParam,
          aName,
          anotherNameParameter,
          anotherDifferentName,
          differentName,
          redHerring,
          yetAnotherName,
          somethingShadowyParameter;
      late final Field forInheriting,
          action,
          initializeMe,
          somethingShadowy,
          aConstructorShadowedField,
          aNameField,
          yetAnotherNameField,
          initViaFieldFormal;

      setUpAll(() async {
        mylibpub = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'mylibpub');
        aFunctionUsingRenamedLib = fakeLibrary.functions
            .firstWhere((f) => f.name == 'aFunctionUsingRenamedLib');
        Dart = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'Dart');
        DartPackage = packageGraph.packages.firstWhere((p) => p.name == 'Dart');
        nameWithTwoUnderscores = fakeLibrary.constants
            .firstWhere((v) => v.name == 'NAME_WITH_TWO_UNDERSCORES');
        nameWithSingleUnderscore = fakeLibrary.constants
            .firstWhere((v) => v.name == 'NAME_SINGLEUNDERSCORE');
        string = packageGraph.allLibraries.values
            .firstWhere((e) => e.name == 'dart:core')
            .allClasses
            .firstWhere((c) => c.name == 'String');
        metaUseResult = packageGraph.allLibraries.values
            .firstWhere((e) => e.name == 'meta')
            .allClasses
            .firstWhere((c) => c.name == 'UseResult');
        baseForDocComments = fakeLibrary.classes
            .firstWhere((c) => c.name == 'BaseForDocComments');
        aNonDefaultConstructor = baseForDocComments.constructors.firstWhere(
            (c) => c.name == 'BaseForDocComments.aNonDefaultConstructor');
        defaultConstructor = baseForDocComments.constructors
            .firstWhere((c) => c.name == 'BaseForDocComments');
        somethingShadowyParameter = defaultConstructor.parameters
            .firstWhere((p) => p.name == 'somethingShadowy');
        initializeMe = baseForDocComments.allFields
            .firstWhere((f) => f.name == 'initializeMe');
        somethingShadowy = baseForDocComments.allFields
            .firstWhere((f) => f.name == 'somethingShadowy');
        doAwesomeStuff = baseForDocComments.instanceMethods
            .firstWhere((m) => m.name == 'doAwesomeStuff');
        anotherMethod = baseForDocComments.instanceMethods
            .firstWhere((m) => m.name == 'anotherMethod');
        doAwesomeStuffParam = doAwesomeStuff.parameters.first;
        topLevelFunction = fakeLibrary.functions
            .firstWhere((f) => f.name == 'topLevelFunction');
        function1 =
            exLibrary.functions.firstWhere((f) => f.name == 'function1');
        Apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
        incorrectDocReference = fakeLibrary.constants
            .firstWhere((v) => v.name == 'incorrectDocReference');
        incorrectDocReferenceFromEx = exLibrary.constants
            .firstWhere((v) => v.name == 'incorrectDocReferenceFromEx');
        theOnlyThingInTheLibrary = packageGraph.libraries
            .firstWhere((l) => l.name == 'csspub')
            .properties
            .firstWhere((v) => v.name == 'theOnlyThingInTheLibrary');
        doesStuff = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'anonymous_library')
            .functions
            .firstWhere((f) => f.name == 'doesStuff');
        BaseClass = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'two_exports.src.base')
            .classes
            .firstWhere((c) => c.name == 'BaseClass');
        bracketOperator = baseForDocComments.instanceOperators
            .firstWhere((o) => o.name == 'operator []');
        bracketOperatorOtherClass = fakeLibrary.classes
            .firstWhere((c) => c.name == 'SpecialList')
            .instanceOperators
            .firstWhere((o) => o.name == 'operator []');
        ExtraSpecialList =
            fakeLibrary.classes.firstWhere((c) => c.name == 'ExtraSpecialList');
        forInheriting = fakeLibrary.classes
            .firstWhere((c) => c.name == 'ImplicitProperties')
            .allFields
            .firstWhere((n) => n.name == 'forInheriting');
        action = packageGraph.allLibraries.values
            .firstWhere((l) => l.name == 'reexport.somelib')
            .classes
            .firstWhere((c) => c.name == 'BaseReexported')
            .allFields
            .firstWhere((f) => f.name == 'action');
        aConstructorShadowed = baseForDocComments.constructors.firstWhere(
            (c) => c.name == 'BaseForDocComments.aConstructorShadowed');
        aConstructorShadowedField = baseForDocComments.allFields
            .firstWhere((f) => f.name == 'aConstructorShadowed');

        FactoryConstructorThings = fakeLibrary.classes
            .firstWhere((c) => c.name == 'FactoryConstructorThings');
        anotherName = FactoryConstructorThings.constructors.firstWhere(
            (c) => c.name == 'FactoryConstructorThings.anotherName');
        anotherConstructor = FactoryConstructorThings.constructors.firstWhere(
            (c) => c.name == 'FactoryConstructorThings.anotherConstructor');
        factoryConstructorThingsDefault = FactoryConstructorThings.constructors
            .firstWhere((c) => c.name == 'FactoryConstructorThings');

        aName = anotherName.parameters.firstWhere((p) => p.name == 'aName');
        anotherNameParameter =
            anotherName.parameters.firstWhere((p) => p.name == 'anotherName');
        anotherDifferentName = anotherName.parameters
            .firstWhere((p) => p.name == 'anotherDifferentName');
        differentName =
            anotherName.parameters.firstWhere((p) => p.name == 'differentName');
        redHerring = anotherConstructor.parameters
            .firstWhere((p) => p.name == 'redHerring');

        aNameField = FactoryConstructorThings.allFields
            .firstWhere((f) => f.name == 'aName');
        yetAnotherNameField = FactoryConstructorThings.allFields
            .firstWhere((f) => f.name == 'yetAnotherName');
        initViaFieldFormal = FactoryConstructorThings.allFields
            .firstWhere((f) => f.name == 'initViaFieldFormal');

        aMethod = FactoryConstructorThings.instanceMethods
            .firstWhere((m) => m.name == 'aMethod');
        yetAnotherName =
            aMethod.parameters.firstWhere((p) => p.name == 'yetAnotherName');
      });

      group('Parameter references work properly', () {
        test('via a setter with a function parameter', () {
          var aSetterWithFunctionParameter = fakeLibrary.properties
              .firstWhere((p) => p.name == 'aSetterWithFunctionParameter');
          var fParam = aSetterWithFunctionParameter.parameters
              .firstWhere((p) => p.name == 'fParam');
          var fParamA = (fParam.modelType as Callable)
              .parameters
              .firstWhere((p) => p.name == 'fParamA');
          var fParamB = (fParam.modelType as Callable)
              .parameters
              .firstWhere((p) => p.name == 'fParamB');
          var fParamC = (fParam.modelType as Callable)
              .parameters
              .firstWhere((p) => p.name == 'fParamC');

          expect(
              referenceLookup(aSetterWithFunctionParameter, 'fParam.fParamA'),
              equals(MatchingLinkResult(fParamA)));
          expect(
              referenceLookup(aSetterWithFunctionParameter, 'fParam.fParamB'),
              equals(MatchingLinkResult(fParamB)));
          expect(
              referenceLookup(aSetterWithFunctionParameter, 'fParam.fParamC'),
              equals(MatchingLinkResult(fParamC)));
        });

        test('in class scope overridden by fields', () {
          expect(referenceLookup(FactoryConstructorThings, 'aName'),
              equals(MatchingLinkResult(aNameField)));
          var anotherNameField = FactoryConstructorThings.allFields
              .firstWhere((f) => f.name == 'anotherName');
          expect(referenceLookup(FactoryConstructorThings, 'anotherName'),
              equals(MatchingLinkResult(anotherNameField)));
          expect(referenceLookup(FactoryConstructorThings, 'yetAnotherName'),
              equals(MatchingLinkResult(yetAnotherNameField)));
          expect(
              referenceLookup(FactoryConstructorThings, 'initViaFieldFormal'),
              equals(MatchingLinkResult(initViaFieldFormal)));
          expect(referenceLookup(FactoryConstructorThings, 'redHerring'),
              equals(MatchingLinkResult(redHerring)));
        });

        test('in class scope overridden by constructors when specified', () {
          expect(
              referenceLookup(FactoryConstructorThings,
                  'new FactoryConstructorThings.anotherName'),
              equals(MatchingLinkResult(anotherName)));
        });

        test(
            'in default constructor scope referring to a field formal parameter',
            () {
          expect(
              referenceLookup(
                  factoryConstructorThingsDefault, 'initViaFieldFormal'),
              equals(MatchingLinkResult(initViaFieldFormal)));
        });

        test('in factory constructor scope referring to parameters', () {
          expect(referenceLookup(anotherName, 'aName'),
              equals(MatchingLinkResult(aName)));
          expect(referenceLookup(anotherName, 'anotherName'),
              equals(MatchingLinkResult(anotherNameParameter)));
          expect(referenceLookup(anotherName, 'anotherDifferentName'),
              equals(MatchingLinkResult(anotherDifferentName)));
          expect(referenceLookup(anotherName, 'differentName'),
              equals(MatchingLinkResult(differentName)));
          expect(referenceLookup(anotherName, 'redHerring'),
              equals(MatchingLinkResult(redHerring)));
        });

        test('in factory constructor scope referring to constructors', () {
          // A bare constructor reference is OK because there is no conflict.
          expect(referenceLookup(anotherName, 'anotherConstructor'),
              equals(MatchingLinkResult(anotherConstructor)));
          // A conflicting constructor has to be explicit.
          expect(
              referenceLookup(
                  anotherName, 'new FactoryConstructorThings.anotherName'),
              equals(MatchingLinkResult(anotherName)));
        });

        test('in method scope referring to parameters and variables', () {
          expect(referenceLookup(aMethod, 'yetAnotherName'),
              equals(MatchingLinkResult(yetAnotherName)));
          expect(
              referenceLookup(
                  aMethod, 'FactoryConstructorThings.yetAnotherName'),
              equals(MatchingLinkResult(yetAnotherNameField)));
          expect(
              referenceLookup(
                  aMethod, 'FactoryConstructorThings.anotherName.anotherName'),
              equals(MatchingLinkResult(anotherNameParameter)));
          expect(referenceLookup(aMethod, 'aName'),
              equals(MatchingLinkResult(aNameField)));
        });
      });

      test('Referring to a renamed library directly works', () {
        expect(
            (referenceLookup(aFunctionUsingRenamedLib, 'renamedLib')
                    .commentReferable as ModelElement)
                .canonicalModelElement,
            equals(mylibpub));
      });

      test('Referring to libraries and packages with the same name is fine',
          () {
        expect(
            referenceLookup(Apple, 'Dart'), equals(MatchingLinkResult(Dart)));
        expect(referenceLookup(Apple, 'package:Dart'),
            equals(MatchingLinkResult(DartPackage)));
      });

      test('Verify basic linking inside a constructor', () {
        expect(referenceLookup(aNonDefaultConstructor, 'initializeMe'),
            equals(MatchingLinkResult(initializeMe)));
        expect(
            referenceLookup(aNonDefaultConstructor, 'aNonDefaultConstructor'),
            equals(MatchingLinkResult(aNonDefaultConstructor)));
        expect(
            referenceLookup(aNonDefaultConstructor,
                'BaseForDocComments.aNonDefaultConstructor'),
            equals(MatchingLinkResult(aNonDefaultConstructor)));
      });

      test(
          'Verify that constructors do not override member fields unless explicitly specified',
          () {
        expect(referenceLookup(baseForDocComments, 'aConstructorShadowed'),
            equals(MatchingLinkResult(aConstructorShadowedField)));
        expect(
            referenceLookup(
                baseForDocComments, 'BaseForDocComments.aConstructorShadowed'),
            equals(MatchingLinkResult(aConstructorShadowedField)));
        expect(
            referenceLookup(baseForDocComments,
                'new BaseForDocComments.aConstructorShadowed'),
            equals(MatchingLinkResult(aConstructorShadowed)));
      });

      test('Deprecated lookup styles still function', () {
        expect(referenceLookup(baseForDocComments, 'aPrefix.UseResult'),
            equals(MatchingLinkResult(metaUseResult)));
      });

      test('Verify basic linking inside class', () {
        expect(
            referenceLookup(
                baseForDocComments, 'BaseForDocComments.BaseForDocComments'),
            equals(MatchingLinkResult(defaultConstructor)));

        // We don't want the parameter on the default constructor, here.
        expect(
            referenceLookup(fakeLibrary, 'BaseForDocComments.somethingShadowy'),
            equals(MatchingLinkResult(somethingShadowy)));
        expect(referenceLookup(baseForDocComments, 'somethingShadowy'),
            equals(MatchingLinkResult(somethingShadowy)));

        // Allow specific reference if necessary
        expect(
            referenceLookup(baseForDocComments,
                'BaseForDocComments.BaseForDocComments.somethingShadowy'),
            equals(MatchingLinkResult(somethingShadowyParameter)));

        expect(referenceLookup(doAwesomeStuff, 'aNonDefaultConstructor'),
            equals(MatchingLinkResult(aNonDefaultConstructor)));

        expect(
            referenceLookup(
                doAwesomeStuff, 'BaseForDocComments.aNonDefaultConstructor'),
            equals(MatchingLinkResult(aNonDefaultConstructor)));

        expect(referenceLookup(doAwesomeStuff, 'this'),
            equals(MatchingLinkResult(baseForDocComments)));

        expect(referenceLookup(doAwesomeStuff, 'value'),
            equals(MatchingLinkResult(doAwesomeStuffParam)));

        // Parent class of [doAwesomeStuff].
        expect(referenceLookup(doAwesomeStuff, 'BaseForDocComments'),
            equals(MatchingLinkResult(baseForDocComments)));

        // Top level constants in the same library as [doAwesomeStuff].
        expect(referenceLookup(doAwesomeStuff, 'NAME_WITH_TWO_UNDERSCORES'),
            equals(MatchingLinkResult(nameWithTwoUnderscores)));
        expect(referenceLookup(doAwesomeStuff, 'NAME_SINGLEUNDERSCORE'),
            equals(MatchingLinkResult(nameWithSingleUnderscore)));

        // Top level class from [dart:core].
        expect(referenceLookup(doAwesomeStuff, 'String'),
            equals(MatchingLinkResult(string)));

        // Another method in the same class.
        expect(referenceLookup(doAwesomeStuff, 'anotherMethod'),
            equals(MatchingLinkResult(anotherMethod)));

        // A top level function in this library.
        expect(referenceLookup(doAwesomeStuff, 'topLevelFunction'),
            equals(MatchingLinkResult(topLevelFunction)));

        // A top level function in another library imported into this library.
        expect(referenceLookup(doAwesomeStuff, 'function1'),
            equals(MatchingLinkResult(function1)));

        // A class in another library imported into this library.
        expect(referenceLookup(doAwesomeStuff, 'Apple'),
            equals(MatchingLinkResult(Apple)));

        // A top level constant in this library sharing the same name as a name in another library.
        expect(referenceLookup(doAwesomeStuff, 'incorrectDocReference'),
            equals(MatchingLinkResult(incorrectDocReference)));

        // A top level constant in another library.
        expect(referenceLookup(doAwesomeStuff, 'incorrectDocReferenceFromEx'),
            equals(MatchingLinkResult(incorrectDocReferenceFromEx)));

        // A prefixed constant in another library.
        expect(referenceLookup(doAwesomeStuff, 'css.theOnlyThingInTheLibrary'),
            equals(MatchingLinkResult(theOnlyThingInTheLibrary)));

        // A name that exists in this package but is not imported.
        expect(referenceLookup(doAwesomeStuff, 'doesStuff'),
            equals(MatchingLinkResult(doesStuff)));

        // A name of a class from an import of a library that exported that name.
        expect(referenceLookup(doAwesomeStuff, 'BaseClass'),
            equals(MatchingLinkResult(BaseClass)));

        // A bracket operator within this class.
        expect(referenceLookup(doAwesomeStuff, 'operator []'),
            equals(MatchingLinkResult(bracketOperator)));

        // A bracket operator in another class.
        expect(referenceLookup(doAwesomeStuff, 'SpecialList.operator []'),
            equals(MatchingLinkResult(bracketOperatorOtherClass)));

        // Reference containing a type parameter.
        expect(referenceLookup(doAwesomeStuff, 'ExtraSpecialList<Object>'),
            equals(MatchingLinkResult(ExtraSpecialList)));

        // Reference to an inherited member.
        expect(
            referenceLookup(
                doAwesomeStuff, 'ClassWithUnusualProperties.forInheriting'),
            equals(MatchingLinkResult(forInheriting)));

        // Reference to an inherited member in another library via class name.
        expect(referenceLookup(doAwesomeStuff, 'ExtendedBaseReexported.action'),
            equals(MatchingLinkResult(action)));
      });
    });
  });

  group('Extension', () {
    late final Extension arm, leg, ext, fancyList, uphill;
    late final Extension documentOnceReexportOne, documentOnceReexportTwo;
    late final Extension staticFieldExtension;
    late final Library reexportOneLib, reexportTwoLib;
    late final Class apple,
        anotherExtended,
        baseTest,
        bigAnotherExtended,
        extensionReferencer,
        megaTron,
        superMegaTron,
        string;
    late final Method doSomeStuff, doStuff, s;
    late final List<Extension> extensions;

    setUpAll(() {
      reexportOneLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_one');
      reexportTwoLib = packageGraph.libraries
          .firstWhere((lib) => lib.name == 'reexport_two');
      documentOnceReexportOne = reexportOneLib.extensions
          .firstWhere((e) => e.name == 'DocumentThisExtensionOnce');
      documentOnceReexportTwo = reexportTwoLib.extensions
          .firstWhere((e) => e.name == 'DocumentThisExtensionOnce');
      string = packageGraph.allLibraries.values
          .firstWhere((e) => e.name == 'dart:core')
          .allClasses
          .firstWhere((c) => c.name == 'String');
      apple = exLibrary.classes.firstWhere((e) => e.name == 'Apple');
      ext = exLibrary.extensions.firstWhere((e) => e.name == 'AppleExtension');
      extensionReferencer =
          exLibrary.classes.firstWhere((c) => c.name == 'ExtensionReferencer');
      fancyList = exLibrary.extensions.firstWhere((e) => e.name == 'FancyList');
      doSomeStuff = exLibrary.classes
          .firstWhere((c) => c.name == 'ExtensionUser')
          .instanceMethods
          .firstWhere((m) => m.name == 'doSomeStuff');
      doStuff = exLibrary.extensions
          .firstWhere((e) => e.name == 'SimpleStringExtension')
          .instanceMethods
          .firstWhere((m) => m.name == 'doStuff');
      staticFieldExtension = exLibrary.extensions
          .firstWhere((e) => e.name == 'StaticFieldExtension');
      extensions = exLibrary.publicExtensions.toList();
      baseTest = fakeLibrary.classes.firstWhere((e) => e.name == 'BaseTest');
      bigAnotherExtended =
          fakeLibrary.classes.firstWhere((e) => e.name == 'BigAnotherExtended');
      anotherExtended =
          fakeLibrary.classes.firstWhere((e) => e.name == 'AnotherExtended');
      arm = fakeLibrary.extensions.firstWhere((e) => e.name == 'Arm');
      leg = fakeLibrary.extensions.firstWhere((e) => e.name == 'Leg');
      uphill = fakeLibrary.extensions.firstWhere((e) => e.name == 'Uphill');
      megaTron = fakeLibrary.classes.firstWhere((e) => e.name == 'Megatron');
      superMegaTron =
          fakeLibrary.classes.firstWhere((e) => e.name == 'SuperMegaTron');
    });

    test('static fields inside extensions do not crash', () {
      expect(staticFieldExtension.staticFields, hasLength(1));
      expect(staticFieldExtension.staticFields.first.name, equals('aStatic'));
    });

    test('basic canonicalization for extensions', () {
      expect(documentOnceReexportOne.isCanonical, isFalse);
      expect(
          documentOnceReexportOne.href, equals(documentOnceReexportTwo.href));
      expect(documentOnceReexportTwo.isCanonical, isTrue);
    });

    test('classes know about applicableExtensions', () {
      expect(apple.potentiallyApplicableExtensionsSorted, orderedEquals([ext]));
      expect(string.potentiallyApplicableExtensionsSorted,
          isNot(contains(documentOnceReexportOne)));
      expect(string.potentiallyApplicableExtensionsSorted,
          contains(documentOnceReexportTwo));
      expect(baseTest.potentiallyApplicableExtensionsSorted, isEmpty);
      expect(anotherExtended.potentiallyApplicableExtensionsSorted,
          orderedEquals([uphill]));
      expect(bigAnotherExtended.potentiallyApplicableExtensionsSorted,
          orderedEquals([uphill]));
    });

    test('extensions on special types work', () {
      Extension extensionOnDynamic,
          extensionOnVoid,
          extensionOnNull,
          extensionOnTypeParameter;
      var object = packageGraph.specialClasses[SpecialClass.object]!;
      Extension getExtension(String name) =>
          fakeLibrary.extensions.firstWhere((e) => e.name == name);

      extensionOnDynamic = getExtension('ExtensionOnDynamic');
      extensionOnNull = getExtension('ExtensionOnNull');
      extensionOnVoid = getExtension('ExtensionOnVoid');
      extensionOnTypeParameter = getExtension('ExtensionOnTypeParameter');

      expect(extensionOnDynamic.couldApplyTo(object), isTrue);
      expect(extensionOnVoid.couldApplyTo(object), isTrue);
      expect(extensionOnNull.couldApplyTo(object), isFalse);
      expect(extensionOnTypeParameter.couldApplyTo(object), isTrue);

      expect(extensionOnDynamic.alwaysApplies, isTrue);
      expect(extensionOnVoid.alwaysApplies, isTrue);
      expect(extensionOnNull.alwaysApplies, isFalse);
      expect(extensionOnTypeParameter.alwaysApplies, isTrue);

      // Even though it does have extensions that could apply to it,
      // extensions that apply to [Object] should always be hidden from
      // documentation.
      expect(object.hasPotentiallyApplicableExtensions, isFalse);
    });

    test('applicableExtensions include those from implements & mixins', () {
      Extension extensionCheckLeft,
          extensionCheckRight,
          extensionCheckCenter,
          extensionCheckImplementor2,
          onNewSchool,
          onOldSchool;
      Class implementor, implementor2, school;
      Extension getExtension(String name) =>
          fakeLibrary.extensions.firstWhere((e) => e.name == name);
      Class getClass(String name) =>
          fakeLibrary.classes.firstWhere((e) => e.name == name);
      extensionCheckLeft = getExtension('ExtensionCheckLeft');
      extensionCheckRight = getExtension('ExtensionCheckRight');
      extensionCheckCenter = getExtension('ExtensionCheckCenter');
      extensionCheckImplementor2 = getExtension('ExtensionCheckImplementor2');
      onNewSchool = getExtension('OnNewSchool');
      onOldSchool = getExtension('OnOldSchool');

      implementor = getClass('Implementor');
      implementor2 = getClass('Implementor2');
      school = getClass('School');

      expect(
          implementor.potentiallyApplicableExtensionsSorted,
          orderedEquals([
            extensionCheckCenter,
            extensionCheckImplementor2,
            extensionCheckLeft,
            extensionCheckRight
          ]));
      expect(implementor2.potentiallyApplicableExtensionsSorted,
          orderedEquals([extensionCheckImplementor2, extensionCheckLeft]));
      expect(school.potentiallyApplicableExtensionsSorted,
          orderedEquals([onNewSchool, onOldSchool]));
    });

    test('type parameters and bounds work with applicableExtensions', () {
      expect(superMegaTron.potentiallyApplicableExtensionsSorted,
          orderedEquals([leg]));
      expect(megaTron.potentiallyApplicableExtensionsSorted,
          orderedEquals([arm, leg]));
    });

    test('documentation links do not crash in base cases', () {
      // Parameters are OK.
      expect(doStuff.documentationAsHtml, contains('<code>another</code>'));
      expect(
          doStuff.documentationAsHtml,
          contains(
              '<a href="%%__HTMLBASE_dartdoc_internal__%%ex/AnExtendableThing/aMember.html">aMember</a>'));
      expect(
          doStuff.documentationAsHtml,
          contains(
              '<a href="%%__HTMLBASE_dartdoc_internal__%%ex/AnExtendableThing-class.html">AnExtendableThing</a>'));
      // TODO(jcollins-g): consider linking via applied extensions?
      expect(doSomeStuff.documentationAsHtml, contains('<code>aMember</code>'));
    });

    test(
        'references from outside an extension refer correctly to the extension',
        () {
      expect(extensionReferencer.documentationAsHtml,
          contains('<code>_Shhh</code>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}ex/FancyList.html">FancyList</a>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}ex/AnExtension/call.html">AnExtension.call</a>'));
      expect(
          extensionReferencer.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}reexport_two/DocumentThisExtensionOnce.html">DocumentThisExtensionOnce</a>'));
    });

    test('has a fully qualified name', () {
      expect(ext.fullyQualifiedName, 'ex.AppleExtension');
    });

    test('does have a line number and column', () {
      expect(ext.characterLocation, isNotNull);
    });

    test('has enclosing element', () {
      expect(ext.enclosingElement.name, equals(exLibrary.name));
    });

    test('member method has href', () {
      s = ext.instanceMethods.firstWhere((m) => m.name == 's');
      expect(s.href, '${htmlBasePlaceholder}ex/AppleExtension/s.html');
    });

    test('has extended type', () {
      expect(ext.extendedType.name, equals('Apple'));
    });

    test('extension name with generics', () {
      expect(
          fancyList.nameWithGenerics,
          equals(
              'FancyList&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('extended type has generics', () {
      expect(fancyList.extendedType.nameWithGenerics,
          equals('List&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('get methods', () {
      expect(fancyList.publicInstanceMethods, hasLength(1));
    });

    test('get operators', () {
      expect(fancyList.publicInstanceOperators, hasLength(1));
    });

    test('get static methods', () {
      expect(fancyList.publicStaticMethodsSorted, hasLength(1));
    });

    test('get properties', () {
      expect(fancyList.publicInstanceFields, hasLength(1));
    });

    test('get constants', () {
      expect(fancyList.publicConstantFields, hasLength(0));
    });

    test('correctly finds all the extensions', () {
      expect(exLibrary.extensions, hasLength(9));
    });

    test('correctly finds all the public extensions', () {
      expect(extensions, hasLength(7));
    });
  });

  group('Function', () {
    late final ModelFunction f1;
    late final ModelFunction genericFunction;
    late final ModelFunction paramOfFutureOrNull;
    late final ModelFunction thisIsAsync;
    late final ModelFunction thisIsFutureOr;
    late final ModelFunction thisIsFutureOrNull;
    late final ModelFunction topLevelFunction;
    late final ModelFunction typeParamOfFutureOr;
    late final ModelFunction doAComplicatedThing;

    setUpAll(() {
      f1 = exLibrary.publicFunctionsSorted.first as ModelFunction;
      genericFunction =
          exLibrary.functions.firstWhere((f) => f.name == 'genericFunction');
      paramOfFutureOrNull = fakeLibrary.functions
          .firstWhere((f) => f.name == 'paramOfFutureOrNull');
      thisIsAsync =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsAsync');
      thisIsFutureOr =
          fakeLibrary.functions.firstWhere((f) => f.name == 'thisIsFutureOr');
      thisIsFutureOrNull = fakeLibrary.functions
          .firstWhere((f) => f.name == 'thisIsFutureOrNull');
      topLevelFunction =
          fakeLibrary.functions.firstWhere((f) => f.name == 'topLevelFunction');
      typeParamOfFutureOr = fakeLibrary.functions
          .firstWhere((f) => f.name == 'typeParamOfFutureOr');
      doAComplicatedThing = fakeLibrary.functions
          .firstWhere((f) => f.name == 'doAComplicatedThing');
    });

    test('has a fully qualified name', () {
      expect(thisIsAsync.fullyQualifiedName, 'fake.thisIsAsync');
    });

    test('does have a line number and column', () {
      expect(thisIsAsync.characterLocation, isNotNull);
    });

    test('has enclosing element', () {
      expect(f1.enclosingElement.name, equals(exLibrary.name));
    });

    test('name is function1', () {
      expect(f1.name, 'function1');
    });

    test('is static', () {
      expect(f1.isStatic, true);
    });

    test('handles dynamic parameters correctly', () {
      expect(ParameterRendererHtml().renderLinkedParams(f1.parameters),
          contains('lastParam'));
    });

    test('async function', () {
      expect(thisIsAsync.isAsynchronous, isTrue);
      expect(
          thisIsAsync.documentation,
          equals(
              'An async function. It should look like I return a [Future].'));
      expect(
          thisIsAsync.documentationAsHtml,
          equals(
              '<p>An async function. It should look like I return a <code>Future</code>.</p>'));
    });

    test('function returning FutureOr', () {
      expect(thisIsFutureOr.isAsynchronous, isFalse);
    });

    test('function returning FutureOr<Null>', () {
      expect(thisIsFutureOrNull.isAsynchronous, isFalse);
    });

    test('function returning FutureOr<T>', () {
      expect(thisIsFutureOrNull.isAsynchronous, isFalse);
    });

    test('function with a parameter having type FutureOr<Null>', () {
      expect(
          ParameterRendererHtml()
              .renderLinkedParams(paramOfFutureOrNull.parameters),
          equals(
              '<span class="parameter" id="paramOfFutureOrNull-param-future"><span class="type-annotation">FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">Null</span>&gt;</span></span> <span class="parameter-name">future</span></span>'));
    });

    test('function with a bound type to FutureOr', () {
      expect(
          typeParamOfFutureOr.linkedGenericParameters,
          equals(
              '<span class="signature">&lt;<wbr><span class="type-parameter">T extends FutureOr<span class="signature">&lt;<wbr><span class="type-parameter">List</span>&gt;</span></span>&gt;</span>'));
    });

    test('docs do not lose brackets in code blocks', () {
      expect(topLevelFunction.documentation, contains("['hello from dart']"));
    });

    test('escapes HTML in default values', () {
      var topLevelFunction2 = fakeLibrary.functions
          .firstWhere((f) => f.name == 'topLevelFunction2');

      expect(
          topLevelFunction2.linkedParamsLines,
          contains('<span class="parameter-name">p3</span> = '
              '<span class="default-value">const &lt;String, int&gt;{}</span>'
              ']</span>'));
    });

    test('has source code', () {
      expect(topLevelFunction.sourceCode, startsWith('@deprecated'));
      expect(topLevelFunction.sourceCode, endsWith('''
String? topLevelFunction(int param1, bool param2, Cool coolBeans,
    [double optionalPositional = 0.0]) {
  return null;
}'''));
    });

    test('typedef params have proper signature', () {
      var function =
          fakeLibrary.functions.firstWhere((f) => f.name == 'addCallback');
      var params =
          ParameterRendererHtml().renderLinkedParams(function.parameters);
      expect(
          params,
          '<span class="parameter" id="addCallback-param-callback">'
          '<span class="type-annotation"><a href="${htmlBasePlaceholder}fake/VoidCallback.html">VoidCallback</a></span> '
          '<span class="parameter-name">callback</span></span>');

      function =
          fakeLibrary.functions.firstWhere((f) => f.name == 'addCallback2');
      params = ParameterRendererHtml().renderLinkedParams(function.parameters);
      expect(
          params,
          '<span class="parameter" id="addCallback2-param-callback">'
          '<span class="type-annotation"><a href="${htmlBasePlaceholder}fake/Callback2.html">Callback2</a></span> '
          '<span class="parameter-name">callback</span></span>');
    });

    test('supports generic methods', () {
      expect(genericFunction.nameWithGenerics,
          'genericFunction&lt;<wbr><span class="type-parameter">T</span>&gt;');
    });

    test('can resolve functions as parameters', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(doAComplicatedThing.parameters);
      expect(
          params,
          '<span class="parameter" id="doAComplicatedThing-param-x"><span class="type-annotation">int</span> <span class="parameter-name">x</span>, </span>'
          '<span class="parameter" id="doAComplicatedThing-param-doSomething">{<span class="type-annotation">void</span> <span class="parameter-name">doSomething</span>(<span class="parameter" id="doSomething-param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span>'
          '<span class="parameter" id="doSomething-param-anotherThing"><span class="type-annotation">String</span> <span class="parameter-name">anotherThing</span></span>)?, </span>'
          '<span class="parameter" id="doAComplicatedThing-param-doSomethingElse"><span class="type-annotation">void</span> <span class="parameter-name">doSomethingElse</span>(<span class="parameter" id="doSomethingElse-param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span>'
          '<span class="parameter" id="doSomethingElse-param-somethingElse"><span class="type-annotation">double</span> <span class="parameter-name">somethingElse</span></span>)?}</span>');
    });
  });

  group('Type expansion', () {
    late final Class TemplatedInterface, ClassWithUnusualProperties;

    setUpAll(() {
      TemplatedInterface =
          exLibrary.classes.singleWhere((c) => c.name == 'TemplatedInterface');
      ClassWithUnusualProperties = fakeLibrary.classes
          .singleWhere((c) => c.name == 'ClassWithUnusualProperties');
    });

    test('setter that takes a function is correctly displayed', () {
      var explicitSetter = ClassWithUnusualProperties.instanceFields
          .singleWhere((f) => f.name == 'explicitSetter');
      // TODO(jcollins-g): really, these shouldn't be called "parameters" in
      // the span class.
      expect(
          explicitSetter.modelType.linkedName,
          matches(RegExp(
              r'dynamic Function<span class="signature">\(<span class="parameter" id="(f-)?param-bar"><span class="type-annotation">int</span> <span class="parameter-name">bar</span>, </span><span class="parameter" id="(f-)?param-baz"><span class="type-annotation"><a href="%%__HTMLBASE_dartdoc_internal__%%fake/Cool-class.html">Cool</a></span> <span class="parameter-name">baz</span>, </span><span class="parameter" id="(f-)?param-macTruck"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span> <span class="parameter-name">macTruck</span></span>\)</span>')));
    });

    test('parameterized type from inherited field is correctly displayed', () {
      var aInheritedField = TemplatedInterface.inheritedFields
          .singleWhere((f) => f.name == 'aInheritedField');
      expect(
          aInheritedField.modelType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a>'
          '<span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>?');
    });

    test(
        'parameterized type for return value from inherited explicit getter is correctly displayed',
        () {
      Accessor aInheritedGetter = TemplatedInterface.inheritedFields
          .singleWhere((f) => f.name == 'aInheritedGetter')
          .getter!;
      expect(aInheritedGetter.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from inherited explicit setter is correctly displayed',
        () {
      Accessor aInheritedSetter = TemplatedInterface.inheritedFields
          .singleWhere((f) => f.name == 'aInheritedSetter')
          .setter!;
      expect(aInheritedSetter.parameters.first.modelType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
      expect(aInheritedSetter.enclosingCombo.modelType.linkedName,
          '<a href="%%__HTMLBASE_dartdoc_internal__%%ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from method is correctly displayed',
        () {
      var aMethodInterface = TemplatedInterface.instanceMethods
          .singleWhere((m) => m.name == 'aMethodInterface');
      expect(aMethodInterface.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value from inherited method is correctly displayed',
        () {
      var aInheritedMethod = TemplatedInterface.instanceMethods
          .singleWhere((m) => m.name == 'aInheritedMethod');
      expect(aInheritedMethod.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/AnotherParameterizedClass-class.html">AnotherParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value containing a parameterized typedef is correctly displayed',
        () {
      var aTypedefReturningMethodInterface = TemplatedInterface.instanceMethods
          .singleWhere((m) => m.name == 'aTypedefReturningMethodInterface');
      expect(aTypedefReturningMethodInterface.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">String</span>&gt;</span></span>&gt;</span>');
    });

    test(
        'parameterized type for return value containing a parameterized typedef from inherited method is correctly displayed',
        () {
      var aInheritedTypedefReturningMethod = TemplatedInterface.instanceMethods
          .singleWhere((m) => m.name == 'aInheritedTypedefReturningMethod');
      expect(aInheritedTypedefReturningMethod.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
    });

    test('parameterized types for inherited operator is correctly displayed',
        () {
      var aInheritedAdditionOperator = TemplatedInterface.inheritedOperators
          .singleWhere((m) => m.name == 'operator +');
      expect(aInheritedAdditionOperator.modelType.returnType.linkedName,
          '<a href="${htmlBasePlaceholder}ex/ParameterizedClass-class.html">ParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span>');
      expect(
          ParameterRendererHtml()
              .renderLinkedParams(aInheritedAdditionOperator.parameters),
          '<span class="parameter" id="+-param-other"><span class="type-annotation"><a href="${htmlBasePlaceholder}ex/ParameterizedClass-class.html">ParameterizedClass</a><span class="signature">&lt;<wbr><span class="type-parameter">List<span class="signature">&lt;<wbr><span class="type-parameter">int</span>&gt;</span></span>&gt;</span></span> <span class="parameter-name">other</span></span>');
    });

    test('', () {});
  });

  group('Method', () {
    late final Class classB,
        klass,
        HasGenerics,
        Cat,
        CatString,
        TypedFunctionsWithoutTypedefs;
    late final Method m1,
        isGreaterThan,
        m4,
        m5,
        m6,
        m7,
        convertToMap,
        abstractMethod;
    late final Method inheritedClear, testGeneric, testGenericMethod;
    late final Method getAFunctionReturningVoid, getAFunctionReturningBool;

    setUpAll(() {
      klass = exLibrary.classes.singleWhere((c) => c.name == 'Klass');
      classB = exLibrary.classes.singleWhere((c) => c.name == 'B');
      HasGenerics =
          fakeLibrary.classes.singleWhere((c) => c.name == 'HasGenerics');
      CatString = exLibrary.classes.singleWhere((c) => c.name == 'CatString');
      Cat = exLibrary.classes.singleWhere((c) => c.name == 'Cat');
      inheritedClear =
          CatString.inheritedMethods.singleWhere((m) => m.name == 'clear');
      m1 = classB.instanceMethods.singleWhere((m) => m.name == 'm1');
      isGreaterThan = exLibrary.classes
          .singleWhere((c) => c.name == 'Apple')
          .instanceMethods
          .singleWhere((m) => m.name == 'isGreaterThan');
      m4 = classB.instanceMethods.singleWhere((m) => m.name == 'writeMsg');
      m5 = klass.instanceMethods.singleWhere((m) => m.name == 'another');
      m6 = klass.instanceMethods.singleWhere((m) => m.name == 'toString');
      m7 = classB.instanceMethods.singleWhere((m) => m.name == 'doNothing');
      abstractMethod =
          Cat.instanceMethods.singleWhere((m) => m.name == 'abstractMethod');
      testGeneric = exLibrary.classes
          .singleWhere((c) => c.name == 'Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGeneric');
      testGenericMethod = exLibrary.classes
          .singleWhere((c) => c.name == 'Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGenericMethod');
      convertToMap = HasGenerics.instanceMethods
          .singleWhere((m) => m.name == 'convertToMap');
      TypedFunctionsWithoutTypedefs = exLibrary.classes
          .singleWhere((c) => c.name == 'TypedFunctionsWithoutTypedefs');
      getAFunctionReturningVoid = TypedFunctionsWithoutTypedefs.instanceMethods
          .singleWhere((m) => m.name == 'getAFunctionReturningVoid');
      getAFunctionReturningBool = TypedFunctionsWithoutTypedefs.instanceMethods
          .singleWhere((m) => m.name == 'getAFunctionReturningBool');
    });

    test('does have a line number and column', () {
      expect(abstractMethod.characterLocation, isNotNull);
    });

    test('verify parameter types are correctly displayed', () {
      expect(
          getAFunctionReturningVoid.modelType.returnType.linkedName,
          equals(
              'void Function<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">T1</span>, </span><span class="parameter" id="param-"><span class="type-annotation">T2</span></span>)</span>'));
    });

    test(
        'verify type parameters to anonymous functions are distinct from normal parameters and instantiated type parameters from method, displayed correctly',
        () {
      expect(
          getAFunctionReturningBool.modelType.returnType.linkedName,
          equals(
              'bool Function&lt;<wbr><span class="type-parameter">T4</span>&gt;<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">String</span>, </span><span class="parameter" id="param-"><span class="type-annotation">T1</span>, </span><span class="parameter" id="param-"><span class="type-annotation">T4</span></span>)</span>'));
    });

    test('has a fully qualified name', () {
      expect(m1.fullyQualifiedName, 'ex.B.m1');
    });

    test('has abstract kind', () {
      expect(abstractMethod.fullkind, 'abstract method');
    });

    test('returns correct overriddenDepth', () {
      final bAbstractMethod =
          classB.instanceMethods.firstWhere((m) => m.name == 'abstractMethod');
      expect(abstractMethod.overriddenDepth, equals(0));
      expect(bAbstractMethod.overriddenDepth, equals(1));
    });

    test(
        'an inherited method has class as the enclosing class, when superclass not in package',
        () {
      expect(inheritedClear.enclosingElement.name, equals('CatString'));
    });

    test(
        'inherited method has the current library, when superclass library not in package',
        () {
      expect(inheritedClear.library.name, equals('ex'));
    });

    test(
        'an inherited method from the core SDK has a href relative to the package class',
        () {
      expect(inheritedClear.href,
          equals('${htmlBasePlaceholder}ex/CatString/clear.html'));
    });

    test(
        'an inherited method has linked to enclosed class name when superclass not in package',
        () {
      expect(
          inheritedClear.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}ex/CatString/clear.html">clear</a>'));
    });

    test('has enclosing element', () {
      expect(m1.enclosingElement.name, equals(classB.name));
    });

    test('overridden method', () {
      expect(m1.overriddenElement.runtimeType.toString(), 'Method');
    });

    test('method documentation', () {
      expect(m1.documentation,
          equals('This is a method.\n\n    new Apple().m1();'));
    });

    test('can have params', () {
      expect(isGreaterThan.isCallable, isTrue);
    });

    test('has parameters', () {
      expect(isGreaterThan.hasParameters, isTrue);
    });

    test('return type', () {
      expect(isGreaterThan.modelType.returnType.linkedName, 'bool');
    });

    test('return type has Future', () {
      expect(m7.modelType.returnType.linkedName, contains('Future'));
    });

    test('parameter has generics in signature', () {
      expect(testGeneric.parameters[0].modelType.linkedName,
          'Map<span class="signature">&lt;<wbr><span class="type-parameter">String</span>, <span class="type-parameter">dynamic</span>&gt;</span>');
    });

    test('parameter is a function', () {
      var functionArgParam = m4.parameters[1];
      expect((functionArgParam.modelType as Callable).returnType.linkedName,
          'String');
    });

    test('method overrides another', () {
      expect(m1.isOverride, isTrue);
      expect(m1.features, contains(Feature.overrideFeature));
    });

    test('generic method type args are rendered', () {
      expect(testGenericMethod.nameWithGenerics,
          'testGenericMethod&lt;<wbr><span class="type-parameter">T</span>&gt;');
    });

    test('doc for method with no return type', () {
      var comment = m5.documentation;
      var comment2 = m6.documentation;
      expect(comment, equals('Another method'));
      expect(comment2, equals('A shadowed method'));
    });

    test('method source code indents correctly', () {
      expect(convertToMap.sourceCode,
          'Map&lt;X, Y&gt;? convertToMap() =&gt; null;');
    });
  });

  group('Operators', () {
    late final Class specializedDuration;
    late final Operator plus, equalsOverride;

    setUpAll(() {
      specializedDuration =
          exLibrary.classes.firstWhere((c) => c.name == 'SpecializedDuration');
      plus = specializedDuration.instanceOperators
          .firstWhere((o) => o.name == 'operator +');
      equalsOverride = exLibrary.classes
          .firstWhere((c) => c.name == 'Dog')
          .instanceOperators
          .firstWhere((o) => o.name == 'operator ==');
    });

    test('can be an override', () {
      expect(equalsOverride.isInherited, isFalse);
      expect(equalsOverride.isOverride, isTrue);
    });

    test('has a fully qualified name', () {
      expect(plus.fullyQualifiedName, 'ex.SpecializedDuration.+');
    });

    test('can be inherited', () {
      expect(plus.isInherited, isTrue);
      expect(plus.isOverride, isFalse);
    });

    test('if inherited, and superclass not in package', () {
      expect(plus.enclosingElement.name, equals('SpecializedDuration'));
    });

    test("if inherited, has the class's library", () {
      expect(plus.library.name, 'ex');
    });

    test('if inherited, has a href relative to enclosed class', () {
      expect(
          plus.href,
          equals(
              '${htmlBasePlaceholder}ex/SpecializedDuration/operator_plus.html'));
    });

    test('if inherited and superclass not in package, link to enclosed class',
        () {
      expect(
          plus.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}ex/SpecializedDuration/operator_plus.html">operator +</a>'));
    });
  });

  group('Field', () {
    late final Class c, LongFirstLine, CatString, UnusualProperties;
    late final Field f1, f2, constField, dynamicGetter, onlySetter;
    late final Field lengthX;
    late final Field sFromApple, mFromApple, mInB, autoCompress;
    late final Field isEmpty;
    late final Field implicitGetterExplicitSetter, explicitGetterImplicitSetter;
    late final Field explicitGetterSetter;
    late final Field explicitNonDocumentedInBaseClassGetter;
    late final Field documentedPartialFieldInSubclassOnly;
    late final Field finalProperty;
    late final Field ExtraSpecialListLength;
    late final Field aProperty;
    late final Field covariantField, covariantSetter;

    setUpAll(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      f1 = c.publicVariableStaticFieldsSorted.first; // n
      f2 = c.publicInstanceFields.first;
      constField = c.constantFields.first; // string
      LongFirstLine =
          fakeLibrary.classes.firstWhere((c) => c.name == 'LongFirstLine');
      CatString = exLibrary.classes.firstWhere((c) => c.name == 'CatString');

      UnusualProperties = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ClassWithUnusualProperties');
      implicitGetterExplicitSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'implicitGetterExplicitSetter') as Field;
      explicitGetterImplicitSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterImplicitSetter') as Field;
      explicitGetterSetter = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterSetter') as Field;
      explicitNonDocumentedInBaseClassGetter =
          UnusualProperties.allModelElements.firstWhere(
                  (e) => e.name == 'explicitNonDocumentedInBaseClassGetter')
              as Field;
      documentedPartialFieldInSubclassOnly = UnusualProperties.allModelElements
          .firstWhere(
              (e) => e.name == 'documentedPartialFieldInSubclassOnly') as Field;
      finalProperty = UnusualProperties.allModelElements
          .firstWhere((e) => e.name == 'finalProperty') as Field;

      isEmpty = CatString.instanceFields.firstWhere((p) => p.name == 'isEmpty');
      dynamicGetter = LongFirstLine.instanceFields
          .firstWhere((p) => p.name == 'dynamicGetter');
      onlySetter = LongFirstLine.instanceFields
          .firstWhere((p) => p.name == 'onlySetter');

      lengthX = fakeLibrary.classes
          .firstWhere((c) => c.name == 'WithGetterAndSetter')
          .instanceFields
          .firstWhere((c) => c.name == 'lengthX');

      var appleClass =
          exLibrary.allClasses.firstWhere((c) => c.name == 'Apple');

      sFromApple = appleClass.instanceFields.firstWhere((p) => p.name == 's');
      mFromApple = appleClass.instanceFields.singleWhere((p) => p.name == 'm');

      mInB = exLibrary.allClasses
          .firstWhere((c) => c.name == 'B')
          .instanceFields
          .firstWhere((p) => p.name == 'm');
      autoCompress = exLibrary.allClasses
          .firstWhere((c) => c.name == 'B')
          .instanceFields
          .firstWhere((p) => p.name == 'autoCompress');
      ExtraSpecialListLength = fakeLibrary.classes
          .firstWhere((c) => c.name == 'SpecialList')
          .instanceFields
          .firstWhere((f) => f.name == 'length');
      aProperty = fakeLibrary.classes
          .firstWhere((c) => c.name == 'AClassWithFancyProperties')
          .instanceFields
          .firstWhere((f) => f.name == 'aProperty');
      covariantField = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams')
          .instanceFields
          .firstWhere((f) => f.name == 'covariantField');
      covariantSetter = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams')
          .instanceFields
          .firstWhere((f) => f.name == 'covariantSetter');
    });

    test('Fields always have line and column information', () {
      expect(implicitGetterExplicitSetter.characterLocation, isNotNull);
      expect(explicitGetterImplicitSetter.characterLocation, isNotNull);
      expect(explicitGetterSetter.characterLocation, isNotNull);
      expect(constField.characterLocation, isNotNull);
      expect(aProperty.characterLocation, isNotNull);
    });

    test('covariant fields are recognized', () {
      expect(covariantField.isCovariant, isTrue);
      expect(covariantField.featuresAsString, contains('covariant'));
      expect(covariantSetter.isCovariant, isTrue);
      expect(covariantSetter.setter!.isCovariant, isTrue);
      expect(covariantSetter.featuresAsString, contains('covariant'));
    });

    test('indentation is not lost inside indented code samples', () {
      expect(
          aProperty.documentation,
          equals(
              'This property is quite fancy, and requires sample code to understand.\n'
              '\n'
              '```dart\n'
              'AClassWithFancyProperties x = new AClassWithFancyProperties();\n'
              '\n'
              'if (x.aProperty.contains(\'Hello\')) {\n'
              '  print("I am indented!");\n'
              '  if (x.aProperty.contains(\'World\')) {\n'
              '    print ("I am indented even more!!!");\n'
              '  }\n'
              '}\n'
              '```'));
    });

    test('Docs from inherited implicit accessors are preserved', () {
      expect(
          explicitGetterImplicitSetter.setter!.documentationComment, isNot(''));
    });

    test('@nodoc on simple property works', () {
      var simpleHidden = UnusualProperties.allModelElements
          .firstWhereOrNull((e) => e.name == 'simpleHidden' && e.isPublic);
      expect(simpleHidden, isNull);
    });

    test('@nodoc on explicit getters/setters hides entire field', () {
      var explicitNodocGetterSetter = UnusualProperties.allModelElements
          .firstWhereOrNull(
              (e) => e.name == 'explicitNodocGetterSetter' && e.isPublic);
      expect(explicitNodocGetterSetter, isNull);
    });

    test(
        '@nodoc overridden in subclass with explicit getter over simple property works',
        () {
      expect(documentedPartialFieldInSubclassOnly.isPublic, isTrue);
      expect(documentedPartialFieldInSubclassOnly.readOnly, isTrue);
      expect(documentedPartialFieldInSubclassOnly.documentationComment,
          contains('This getter is documented'));
      expect(documentedPartialFieldInSubclassOnly.annotations,
          isNot(contains(Feature.inheritedSetter)));
    });

    test('@nodoc overridden in subclass for getter works', () {
      expect(explicitNonDocumentedInBaseClassGetter.isPublic, isTrue);
      expect(explicitNonDocumentedInBaseClassGetter.hasPublicGetter, isTrue);
      expect(explicitNonDocumentedInBaseClassGetter.documentationComment,
          contains('I should be documented'));
      expect(explicitNonDocumentedInBaseClassGetter.readOnly, isTrue);
    });

    test('inheritance of docs from SDK works for getter/setter combos', () {
      expect(
          ExtraSpecialListLength
              .getter!.documentationFrom.first.element.library!.name,
          equals('dart.core'));
      expect(ExtraSpecialListLength.oneLineDoc == '', isFalse);
    });

    test('split inheritance with explicit setter works', () {
      expect(implicitGetterExplicitSetter.getter!.isInherited, isTrue);
      expect(implicitGetterExplicitSetter.setter!.isInherited, isFalse);
      expect(implicitGetterExplicitSetter.isInherited, isFalse);
      expect(implicitGetterExplicitSetter.features,
          isNot(contains(Feature.inherited)));
      expect(implicitGetterExplicitSetter.features,
          contains(Feature.inheritedGetter));
      expect(implicitGetterExplicitSetter.features,
          isNot(contains(Feature.overrideFeature)));
      expect(implicitGetterExplicitSetter.features,
          contains(Feature.overrideSetter));
      expect(
          implicitGetterExplicitSetter.features, contains(Feature.readWrite));
      expect(
          implicitGetterExplicitSetter.oneLineDoc,
          equals(
              'Docs for implicitGetterExplicitSetter from ImplicitProperties.'));
      expect(
          implicitGetterExplicitSetter.documentation,
          equals(
              'Docs for implicitGetterExplicitSetter from ImplicitProperties.'));
    });

    test('split inheritance with explicit getter works', () {
      expect(explicitGetterImplicitSetter.getter!.isInherited, isFalse);
      expect(explicitGetterImplicitSetter.setter!.isInherited, isTrue);
      expect(explicitGetterImplicitSetter.isInherited, isFalse);
      expect(explicitGetterImplicitSetter.features,
          isNot(contains(Feature.inherited)));
      expect(explicitGetterImplicitSetter.features,
          contains(Feature.inheritedSetter));
      expect(explicitGetterImplicitSetter.features,
          isNot(contains(Feature.overrideFeature)));
      expect(explicitGetterImplicitSetter.features,
          contains(Feature.overrideGetter));
      expect(
          explicitGetterImplicitSetter.features, contains(Feature.readWrite));
      expect(explicitGetterImplicitSetter.oneLineDoc,
          equals('Getter doc for explicitGetterImplicitSetter'));
      // Even though we have some new setter docs, getter still takes priority.
      expect(explicitGetterImplicitSetter.documentation,
          equals('Getter doc for explicitGetterImplicitSetter'));
    });

    test('has a fully qualified name', () {
      expect(lengthX.fullyQualifiedName, 'fake.WithGetterAndSetter.lengthX');
    });

    test('has extended documentation', () {
      expect(lengthX.oneLineDoc, equals('Returns a length.'));
      expect(lengthX.documentation, contains('the fourth dimension'));
      expect(lengthX.documentation, isNot(contains('[...]')));
    });

    test('has valid documentation', () {
      expect(mFromApple.hasDocumentation, isTrue);
      expect(mFromApple.documentation, 'The read-write field `m`.');
    });

    test('inherited property has a linked name to superclass in package', () {
      expect(mInB.linkedName,
          equals('<a href="${htmlBasePlaceholder}ex/Apple/m.html">m</a>'));
    });

    test(
        'inherited property has linked name to enclosed class, if superclass is not in package',
        () {
      expect(
          isEmpty.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}ex/CatString/isEmpty.html">isEmpty</a>'));
    });

    test('inherited property has the enclosing class', () {
      expect(isEmpty.enclosingElement.name, equals('CatString'));
    });

    test('inherited property has the enclosing class library', () {
      expect(isEmpty.library.name, equals('ex'));
    });

    test('has enclosing element', () {
      expect(f1.enclosingElement.name, equals(c.name));
    });

    test('is not const', () {
      expect(f1.isConst, isFalse);
    });

    test('is const', () {
      expect(constField.isConst, isTrue);
    });

    test('is final only when appropriate', () {
      expect(f1.isFinal, isFalse);
      expect(finalProperty.isFinal, isTrue);
      expect(finalProperty.isLate, isFalse);
      expect(finalProperty.features, contains(Feature.finalFeature));
      expect(finalProperty.features, isNot(contains(Feature.lateFeature)));
      expect(onlySetter.isFinal, isFalse);
      expect(onlySetter.features, isNot(contains(Feature.finalFeature)));
      expect(onlySetter.features, isNot(contains(Feature.lateFeature)));
      expect(dynamicGetter.isFinal, isFalse);
      expect(dynamicGetter.features, isNot(contains(Feature.finalFeature)));
      expect(dynamicGetter.features, isNot(contains(Feature.lateFeature)));
    });

    test('is not static', () {
      expect(f2.isStatic, isFalse);
    });

    test('getter documentation', () {
      expect(dynamicGetter.documentation,
          equals('Dynamic getter. Readable only.'));
    });

    test('setter documentation', () {
      expect(onlySetter.documentation,
          equals('Only a setter, with a single param, of type double.'));
    });

    test('Field with no explicit getter/setter has documentation', () {
      expect(autoCompress.documentation,
          contains('To enable, set `autoCompress` to `true`'));
    });

    test(
        'property with setter and getter and comments with asterisks do not show asterisks',
        () {
      expect(sFromApple.documentationAsHtml, isNot(contains('/**')));
    });

    test('explicit getter/setter has a getter accessor', () {
      expect(lengthX.getter, isNotNull);
      expect(lengthX.getter!.name, equals('lengthX'));
    });

    test('explicit getter/setter has a setter accessor', () {
      expect(lengthX.setter, isNotNull);
      expect(lengthX.setter!.name, equals('lengthX='));
    });

    test('a stand-alone setter does not have a getter', () {
      expect(onlySetter.getter, isNull);
    });

    test(
        'has one inherited property for getter/setter when inherited from parameterized class',
        () {
      var withGenericSub =
          exLibrary.classes.firstWhere((c) => c.name == 'WithGenericSub');
      expect(withGenericSub.inheritedFields.where((p) => p.name == 'prop'),
          hasLength(1));
    });
  });

  group('Accessor', () {
    late final Accessor? onlyGetterGetter,
        onlyGetterSetter,
        onlySetterGetter,
        onlySetterSetter;

    late final Class classB;

    setUpAll(() {
      var justGetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justGetter');
      onlyGetterGetter = justGetter.getter;
      onlyGetterSetter = justGetter.setter;
      var justSetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justSetter');
      onlySetterSetter = justSetter.setter;
      onlySetterGetter = justSetter.getter;

      classB = exLibrary.classes.singleWhere((c) => c.name == 'B');
    });

    test('always has a valid location', () {
      void expectValidLocation(CharacterLocation location) {
        expect(location.lineNumber, greaterThanOrEqualTo(0));
        expect(location.columnNumber, greaterThanOrEqualTo(0));
      }

      var simpleProperty =
          fakeLibrary.properties.firstWhere((p) => p.name == 'simpleProperty');
      expectValidLocation(simpleProperty.getter!.characterLocation!);
      expectValidLocation(simpleProperty.setter!.characterLocation!);
      expectValidLocation(onlyGetterGetter!.characterLocation!);
      expectValidLocation(onlySetterSetter!.characterLocation!);

      Iterable<Accessor> expandAccessors(Field f) sync* {
        if (f.hasGetter) yield f.getter!;
        if (f.hasSetter) yield f.setter!;
      }

      // classB has a variety of inherited and partially overridden fields.
      // All should have valid locations on their accessors.
      for (var a in classB.allFields.expand(expandAccessors)) {
        expectValidLocation(a.characterLocation!);
      }

      // Enums also have fields and have historically had problems.
      var macrosFromAccessors =
          fakeLibrary.enums.firstWhere((e) => e.name == 'MacrosFromAccessors');
      for (var a in macrosFromAccessors.allFields.expand(expandAccessors)) {
        if (a.name == 'values') {
          continue;
        }
        expectValidLocation(a.characterLocation!);
      }
    });

    test('are available on top-level variables', () {
      expect(onlyGetterGetter?.name, equals('justGetter'));
      expect(onlyGetterSetter, isNull);
      expect(onlySetterGetter, isNull);
      expect(onlySetterSetter?.name, equals('justSetter='));
    });

    test('if overridden, gets documentation from superclasses', () {
      final doc = classB.instanceFields
          .firstWhere((p) => p.name == 's')
          .getter!
          .documentation;
      expect(doc, equals('The getter for `s`'));
    });

    test(
        'has correct linked return type if the return type is a parameterized typedef',
        () {
      var apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      final fieldWithTypedef =
          apple.instanceFields.firstWhere((m) => m.name == 'fieldWithTypedef');
      expect(
          fieldWithTypedef.modelType.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">bool</span>&gt;</span>'));
    });
  });

  group('Top-level Variable', () {
    late final TopLevelVariable v;
    late final TopLevelVariable v3, justGetter, justSetter;
    late final TopLevelVariable setAndGet, mapWithDynamicKeys;
    late final TopLevelVariable nodocGetter, nodocSetter;
    late final TopLevelVariable complicatedReturn;
    late final TopLevelVariable meaningOfLife, importantComputations;
    late final TopLevelVariable genericTypedefCombo;

    setUpAll(() {
      v = exLibrary.properties.firstWhere((p) => p.name == 'number');
      v3 = exLibrary.properties.firstWhere((p) => p.name == 'y');
      meaningOfLife =
          fakeLibrary.properties.firstWhere((v) => v.name == 'meaningOfLife');
      importantComputations = fakeLibrary.properties
          .firstWhere((v) => v.name == 'importantComputations');
      complicatedReturn = fakeLibrary.properties
          .firstWhere((f) => f.name == 'complicatedReturn');
      nodocGetter = fakeLibrary.properties
          .firstWhere((p) => p.name == 'getterSetterNodocGetter');
      nodocSetter = fakeLibrary.properties
          .firstWhere((p) => p.name == 'getterSetterNodocSetter');
      justGetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justGetter');
      justSetter =
          fakeLibrary.properties.firstWhere((p) => p.name == 'justSetter');
      setAndGet =
          fakeLibrary.properties.firstWhere((p) => p.name == 'setAndGet');
      mapWithDynamicKeys = fakeLibrary.properties
          .firstWhere((p) => p.name == 'mapWithDynamicKeys');
      genericTypedefCombo = fakeLibrary.properties
          .firstWhere((p) => p.name == 'genericTypedefCombo');
    });

    test(
        'Verify that combos with a generic typedef modelType can render correctly',
        () {
      expect(genericTypedefCombo.modelType.typeArguments, isEmpty);
      expect(
          genericTypedefCombo.modelType.linkedName,
          equals(
              '<a href="%%__HTMLBASE_dartdoc_internal__%%fake/NewGenericTypedef.html">NewGenericTypedef</a>?'));
    });

    test('Verify that final and late show up (or not) appropriately', () {
      expect(meaningOfLife.isFinal, isTrue);
      expect(meaningOfLife.isLate, isFalse);
      expect(meaningOfLife.features, contains(Feature.finalFeature));
      expect(meaningOfLife.features, isNot(contains(Feature.lateFeature)));
      expect(justGetter.isFinal, isFalse);
      expect(justGetter.features, isNot(contains(Feature.finalFeature)));
      expect(justGetter.features, isNot(contains(Feature.lateFeature)));
      expect(justSetter.isFinal, isFalse);
      expect(justSetter.features, isNot(contains(Feature.finalFeature)));
      expect(justSetter.features, isNot(contains(Feature.lateFeature)));
    });

    test(
        'Verify that a map containing anonymous functions as values works correctly',
        () {
      var typeArguments =
          (importantComputations.modelType as DefinedElementType).typeArguments;
      expect(typeArguments, isNotEmpty);
      expect(
          typeArguments.last.linkedName,
          // TODO(jcollins-g): after analyzer 0.39.5 change to 'num' in first
          // group.
          matches(RegExp(
              r'(dynamic|num) Function<span class="signature">\(<span class="parameter" id="param-a"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">num</span>&gt;</span></span> <span class="parameter-name">a</span></span>\)</span>')));
      expect(
          importantComputations.modelType.linkedName,
          matches(RegExp(
              r'Map<span class="signature">&lt;<wbr><span class="type-parameter">int</span>, <span class="type-parameter">(dynamic|num) Function<span class="signature">\(<span class="parameter" id="param-a"><span class="type-annotation">List<span class="signature">&lt;<wbr><span class="type-parameter">num</span>&gt;</span></span> <span class="parameter-name">a</span></span>\)</span></span>&gt;</span>')));
    });

    test(
        'Verify that a complex type parameter with an anonymous function works correctly',
        () {
      expect(
          complicatedReturn.modelType.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ATypeTakingClass-class.html">ATypeTakingClass</a>'
              '<span class="signature">&lt;<wbr><span class="type-parameter">String Function<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">int</span></span>)</span></span>&gt;</span>?'));
    });

    test('@nodoc on simple property works', () {
      var nodocSimple = fakeLibrary.publicProperties
          .firstWhereOrNull((p) => p.name == 'simplePropertyHidden');
      expect(nodocSimple, isNull);
    });

    test('@nodoc on both hides both', () {
      var nodocBoth = fakeLibrary.publicProperties
          .firstWhereOrNull((p) => p.name == 'getterSetterNodocBoth');
      expect(nodocBoth, isNull);
    });

    test('@nodoc on setter only works', () {
      expect(nodocSetter.isPublic, isTrue);
      expect(nodocSetter.readOnly, isTrue);
      expect(nodocSetter.documentationComment,
          equals('Getter docs should be shown.'));
    });

    test('@nodoc on getter only works', () {
      expect(nodocGetter.isPublic, isTrue);
      expect(nodocGetter.writeOnly, isTrue);
      expect(nodocGetter.documentationComment,
          equals('Setter docs should be shown.'));
    });

    test('has a fully qualified name', () {
      expect(justGetter.fullyQualifiedName, 'fake.justGetter');
    });

    test('type arguments are correct', () {
      var modelType = mapWithDynamicKeys.modelType as ParameterizedElementType;
      expect(modelType.typeArguments, hasLength(2));
      expect(modelType.typeArguments.first.name, equals('dynamic'));
      expect(modelType.typeArguments.last.name, equals('String'));
    });

    test('has enclosing element', () {
      expect(v.enclosingElement.name, equals(exLibrary.name));
    });

    test('found five properties', () {
      expect(exLibrary.publicProperties, hasLength(7));
    });

    test('linked return type is a double', () {
      expect(v.modelType.linkedName, 'double');
    });

    test('linked return type is dynamic', () {
      expect(v3.modelType.linkedName, 'dynamic');
    });

    test('just a getter has documentation', () {
      expect(justGetter.documentation,
          equals('Just a getter. No partner setter.'));
    });

    test('just a setter has documentation', () {
      expect(justSetter.documentation,
          equals('Just a setter. No partner getter.'));
    });

    test('has a getter accessor', () {
      expect(setAndGet.getter, isNotNull);
      expect(setAndGet.getter!.name, equals('setAndGet'));
    });

    test('has a setter accessor', () {
      expect(setAndGet.setter, isNotNull);
      expect(setAndGet.setter!.name, equals('setAndGet='));
    });
  });

  group('Constant', () {
    late final TopLevelVariable greenConstant,
        cat,
        customClassPrivate,
        orangeConstant,
        prettyColorsConstant,
        deprecated;

    late final Field aStaticConstField, aName;

    setUpAll(() {
      greenConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_GREEN');
      orangeConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'COLOR_ORANGE');
      prettyColorsConstant =
          exLibrary.constants.firstWhere((c) => c.name == 'PRETTY_COLORS');
      cat = exLibrary.constants.firstWhere((c) => c.name == 'MY_CAT');
      deprecated =
          exLibrary.constants.firstWhere((c) => c.name == 'deprecated');
      var Dog = exLibrary.allClasses.firstWhere((c) => c.name == 'Dog');
      customClassPrivate = fakeLibrary.constants
          .firstWhere((c) => c.name == 'CUSTOM_CLASS_PRIVATE');
      aStaticConstField =
          Dog.constantFields.firstWhere((f) => f.name == 'aStaticConstField');
      aName = Dog.constantFields.firstWhere((f) => f.name == 'aName');
    });

    test('substrings of the constant values type are not linked (#1535)', () {
      expect(aName.constantValue,
          'const <a href="${htmlBasePlaceholder}ex/ExtendedShortName/ExtendedShortName.html">ExtendedShortName</a>(&quot;hello there&quot;)');
    });

    test('constant field values are escaped', () {
      expect(aStaticConstField.constantValue, '&quot;A Constant Dog&quot;');
    });

    test('privately constructed constants are unlinked', () {
      expect(customClassPrivate.constantValue, 'const _APrivateConstClass()');
    });

    test('has a fully qualified name', () {
      expect(greenConstant.fullyQualifiedName, 'ex.COLOR_GREEN');
    });

    test('has the correct kind', () {
      expect(greenConstant.kind, equals('top-level constant'));
    });

    test('has enclosing element', () {
      expect(greenConstant.enclosingElement.name, equals(exLibrary.name));
    });

    test('found all the constants', () {
      expect(exLibrary.publicConstants, hasLength(9));
    });

    test('COLOR_GREEN is constant', () {
      expect(greenConstant.isConst, isTrue);
    });

    test('COLOR_ORANGE has correct value', () {
      expect(orangeConstant.constantValue, '&#39;orange&#39;');
    });

    test('PRETTY_COLORS', () {
      expect(
          prettyColorsConstant.constantValue,
          matches(RegExp(
              r'const &lt;String&gt;\s?\[COLOR_GREEN, COLOR_ORANGE, &#39;blue&#39;\]')));
    });

    test('MY_CAT is linked', () {
      expect(cat.constantValue,
          'const <a href="${htmlBasePlaceholder}ex/ConstantCat/ConstantCat.html">ConstantCat</a>(&#39;tabby&#39;)');
    });

    test('exported property', () {
      expect(deprecated.library.name, equals('ex'));
    });
  });

  group('Constructor', () {
    late final Constructor appleDefaultConstructor, constCatConstructor;
    late final Constructor appleConstructorFromString;
    late final Constructor constructorTesterDefault,
        constructorTesterFromSomething;
    late final Constructor syntheticConstructor;
    late final Class apple,
        constCat,
        constructorTester,
        referToADefaultConstructor,
        withSyntheticConstructor;

    setUpAll(() {
      apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      constCat = exLibrary.classes.firstWhere((c) => c.name == 'ConstantCat');
      constructorTester =
          fakeLibrary.classes.firstWhere((c) => c.name == 'ConstructorTester');
      constCatConstructor = constCat.constructors.first;
      appleDefaultConstructor =
          apple.constructors.firstWhere((c) => c.name == 'Apple');
      appleConstructorFromString =
          apple.constructors.firstWhere((c) => c.name == 'Apple.fromString');
      constructorTesterDefault = constructorTester.constructors
          .firstWhere((c) => c.name == 'ConstructorTester');
      constructorTesterFromSomething = constructorTester.constructors
          .firstWhere((c) => c.name == 'ConstructorTester.fromSomething');
      referToADefaultConstructor = fakeLibrary.classes
          .firstWhere((c) => c.name == 'ReferToADefaultConstructor');
      withSyntheticConstructor = exLibrary.classes
          .firstWhere((c) => c.name == 'WithSyntheticConstructor');
      syntheticConstructor = withSyntheticConstructor.constructors
          .firstWhere((c) => c.isUnnamedConstructor);
    });

    test('calculates comment references to classes vs. constructors correctly',
        () {
      expect(
          referToADefaultConstructor.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ReferToADefaultConstructor-class.html">ReferToADefaultConstructor</a>'));
      expect(
          referToADefaultConstructor.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/ReferToADefaultConstructor/ReferToADefaultConstructor.html">ReferToADefaultConstructor.ReferToADefaultConstructor</a>'));
    });

    test('displays generic parameters correctly', () {
      expect(constructorTesterDefault.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;');
      expect(constructorTesterFromSomething.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;.fromSomething');
    });

    test('has a fully qualified name', () {
      expect(
          appleConstructorFromString.fullyQualifiedName, 'ex.Apple.fromString');
    });

    test('has a line number and column', () {
      expect(appleDefaultConstructor.characterLocation, isNotNull);
      expect(syntheticConstructor.characterLocation, isNotNull);
      // The default constructor should not reference the class for location
      // because it is not synthetic.
      expect(appleDefaultConstructor.characterLocation.toString(),
          isNot(equals(apple.characterLocation.toString())));
      // A synthetic class should reference its parent.
      expect(syntheticConstructor.characterLocation.toString(),
          equals(withSyntheticConstructor.characterLocation.toString()));
    });

    test('has enclosing element', () {
      expect(appleDefaultConstructor.enclosingElement.name, equals(apple.name));
    });

    test('has constructor', () {
      expect(appleDefaultConstructor, isNotNull);
      expect(appleDefaultConstructor.name, equals('Apple'));
      expect(appleDefaultConstructor.shortName, equals('Apple'));
    });

    test('title has factory qualifier', () {
      expect(appleConstructorFromString.fullKind, 'factory constructor');
    });

    test('title has const qualifier', () {
      expect(constCatConstructor.fullKind, 'const constructor');
    });

    test('title has no qualifiers', () {
      expect(appleDefaultConstructor.fullKind, 'constructor');
    });

    test('shortName', () {
      expect(appleConstructorFromString.shortName, equals('fromString'));
    });
  });

  group('void as type', () {
    late final ModelFunction returningFutureVoid, aVoidParameter;
    late final Class ExtendsFutureVoid,
        ImplementsFutureVoid,
        ATypeTakingClassMixedIn;

    setUpAll(() {
      returningFutureVoid = fakeLibrary.functions
          .firstWhere((f) => f.name == 'returningFutureVoid');
      aVoidParameter =
          fakeLibrary.functions.firstWhere((f) => f.name == 'aVoidParameter');
      ExtendsFutureVoid =
          fakeLibrary.classes.firstWhere((f) => f.name == 'ExtendsFutureVoid');
      ImplementsFutureVoid = fakeLibrary.classes
          .firstWhere((f) => f.name == 'ImplementsFutureVoid');
      ATypeTakingClassMixedIn = fakeLibrary.classes
          .firstWhere((f) => f.name == 'ATypeTakingClassMixedIn');
    });

    test('a function returning a Future<void>', () {
      expect(
          returningFutureVoid.modelType.returnType.linkedName,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('a function requiring a Future<void> parameter', () {
      expect(
          ParameterRendererHtml().renderLinkedParams(aVoidParameter.parameters,
              showMetadata: true, showNames: true),
          equals(
              '<span class="parameter" id="aVoidParameter-param-p1"><span class="type-annotation">Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span></span> <span class="parameter-name">p1</span></span>'));
    });

    test('a class that extends Future<void>', () {
      expect(
          ExtendsFutureVoid.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ExtendsFutureVoid-class.html">ExtendsFutureVoid</a>'));
      var FutureVoid = ExtendsFutureVoid.publicSuperChain
          .firstWhere((c) => c.name == 'Future');
      expect(
          FutureVoid.linkedName,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('a class that implements Future<void>', () {
      expect(
          ImplementsFutureVoid.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ImplementsFutureVoid-class.html">ImplementsFutureVoid</a>'));
      var FutureVoid =
          ImplementsFutureVoid.interfaces.firstWhere((c) => c.name == 'Future');
      expect(
          FutureVoid.linkedName,
          equals(
              'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });

    test('Verify that a mixin with a void type parameter works', () {
      expect(
          ATypeTakingClassMixedIn.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ATypeTakingClassMixedIn-class.html">ATypeTakingClassMixedIn</a>'));
      var ATypeTakingClassVoid = ATypeTakingClassMixedIn.mixedInTypes
          .firstWhere((c) => c.name == 'ATypeTakingClass');
      expect(
          ATypeTakingClassVoid.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ATypeTakingClass-class.html">ATypeTakingClass</a><span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>'));
    });
  });

  group('ModelType', () {
    late final Field fList;

    setUpAll(() {
      fList = exLibrary.classes
          .firstWhere((c) => c.name == 'B')
          .instanceFields
          .singleWhere((p) => p.name == 'list');
    });

    test('parameterized type', () {
      expect(fList.modelType is ParameterizedElementType, isTrue);
    });
  });

  group('Typedef', () {
    late final FunctionTypedef processMessage;
    late final FunctionTypedef oldgeneric;
    late final FunctionTypedef generic;
    late final FunctionTypedef aComplexTypedef;
    late final Class TypedefUsingClass;

    setUpAll(() {
      processMessage = exLibrary.typedefs
          .firstWhere((t) => t.name == 'processMessage') as FunctionTypedef;
      oldgeneric = fakeLibrary.typedefs
          .firstWhere((t) => t.name == 'GenericTypedef') as FunctionTypedef;
      generic = fakeLibrary.typedefs
          .firstWhere((t) => t.name == 'NewGenericTypedef') as FunctionTypedef;

      aComplexTypedef = exLibrary.typedefs
          .firstWhere((t) => t.name == 'aComplexTypedef') as FunctionTypedef;
      TypedefUsingClass =
          fakeLibrary.classes.firstWhere((t) => t.name == 'TypedefUsingClass');
    });

    test(
        'Typedefs with bound type parameters indirectly referred in parameters are displayed',
        () {
      var theConstructor = TypedefUsingClass.constructors.first;
      expect(
          ParameterRendererHtml().renderLinkedParams(theConstructor.parameters),
          equals(
              '<span class="parameter" id="-param-x"><span class="type-annotation"><a href="${htmlBasePlaceholder}ex/ParameterizedTypedef.html">ParameterizedTypedef</a><span class="signature">&lt;<wbr><span class="type-parameter">double</span>&gt;</span></span> <span class="parameter-name">x</span></span>'));
    });

    test('anonymous nested functions inside typedefs are handled', () {
      expect(aComplexTypedef, isNotNull);
      expect(aComplexTypedef.modelType.returnType.linkedName,
          startsWith('void Function'));
      expect(
          aComplexTypedef.nameWithGenerics,
          equals(
              'aComplexTypedef&lt;<wbr><span class="type-parameter">A1</span>, <span class="type-parameter">A2</span>, <span class="type-parameter">A3</span>&gt;'));
    });

    test('anonymous nested functions inside typedefs are handled correctly',
        () {
      expect(
        aComplexTypedef.modelType.returnType.linkedName,
        'void Function<span class="signature">'
        '(<span class="parameter" id="param-"><span class="type-annotation">A1</span>, '
        '</span><span class="parameter" id="param-"><span class="type-annotation">A2</span>, </span>'
        '<span class="parameter" id="param-"><span class="type-annotation">A3</span></span>)</span>',
      );
      expect(
        aComplexTypedef.linkedParamsLines,
        '<ol class="parameter-list">'
        '<li><span class="parameter" id="param-"><span class="type-annotation">A3</span>, </span></li>\n'
        '<li><span class="parameter" id="param-"><span class="type-annotation">String</span></span></li>\n'
        '</ol>',
      );
    });

    test('has a fully qualified name', () {
      expect(processMessage.fullyQualifiedName, 'ex.processMessage');
      expect(generic.fullyQualifiedName, 'fake.NewGenericTypedef');
    });

    test('has enclosing element', () {
      expect(processMessage.enclosingElement.name, equals(exLibrary.name));
      expect(generic.enclosingElement.name, equals(fakeLibrary.name));
    });

    test('docs', () {
      expect(processMessage.documentation, equals(''));
      expect(generic.documentation,
          equals('A typedef with the new style generic function syntax.'));
    });

    test('linked return type', () {
      expect(processMessage.modelType.returnType.linkedName, equals('String'));
      expect(
          generic.modelType.returnType.linkedName,
          equals(
              'List<span class="signature">&lt;<wbr><span class="type-parameter">S</span>&gt;</span>'));
    });

    test('return type', () {
      expect(
          oldgeneric.modelType.linkedName,
          isIn([
            'T Function<span class="signature">(<span class="parameter" id="GenericTypedef-param-input"><span class="type-annotation">T</span> <span class="parameter-name">input</span></span>)</span>',
            // Remove following after analyzer 2.0.0
            'T Function<span class="signature">(<span class="parameter" id="param-input"><span class="type-annotation">T</span> <span class="parameter-name">input</span></span>)</span>',
          ]));
      expect(
          generic.modelType.linkedName,
          equals(
              'List<span class="signature">&lt;<wbr><span class="type-parameter">S</span>&gt;</span> Function&lt;<wbr><span class="type-parameter">S</span>&gt;<span class="signature">(<span class="parameter" id="param-"><span class="type-annotation">T</span>, </span><span class="parameter" id="param-"><span class="type-annotation">int</span>, </span><span class="parameter" id="param-"><span class="type-annotation">bool</span></span>)</span>'));
    });

    test('name with generics', () {
      expect(
          processMessage.nameWithGenerics,
          equals(
              'processMessage&lt;<wbr><span class="type-parameter">T</span>&gt;'));
      expect(
          generic.nameWithGenerics,
          equals(
              'NewGenericTypedef&lt;<wbr><span class="type-parameter">T</span>&gt;'));
    });

    // TODO(jdkoren): Not easy to call TypedefRenderer directly because Typedef
    // inspects its element member. Find a better way when we start to isolate
    // renderer tests.
    test('TypedefRendererHtml renders genericParameters', () {
      expect(TypedefRendererHtml().renderGenericParameters(processMessage),
          equals('&lt;<wbr><span class="type-parameter">T</span>&gt;'));
      expect(TypedefRendererHtml().renderGenericParameters(generic),
          equals('&lt;<wbr><span class="type-parameter">T</span>&gt;'));
    });
  });

  group('Parameter', () {
    Class c, fClass, CovariantMemberParams;
    late final Method isGreaterThan,
        asyncM,
        methodWithGenericParam,
        paramFromExportLib,
        methodWithTypedefParam,
        applyCovariantParams;
    late final ModelFunction doAComplicatedThing;
    late final Parameter intNumber, intCheckOptional;

    setUpAll(() {
      c = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      CovariantMemberParams = fakeLibrary.classes
          .firstWhere((c) => c.name == 'CovariantMemberParams');
      applyCovariantParams = CovariantMemberParams.instanceMethods
          .firstWhere((m) => m.name == 'applyCovariantParams');
      paramFromExportLib =
          c.instanceMethods.singleWhere((m) => m.name == 'paramFromExportLib');
      isGreaterThan =
          c.instanceMethods.singleWhere((m) => m.name == 'isGreaterThan');
      asyncM = exLibrary.classes
          .firstWhere((c) => c.name == 'Dog')
          .instanceMethods
          .firstWhere((m) => m.name == 'foo');
      intNumber = isGreaterThan.parameters.first;
      intCheckOptional = isGreaterThan.parameters.last;
      fClass = exLibrary.classes.firstWhere((c) => c.name == 'F');
      methodWithGenericParam = fClass.instanceMethods
          .singleWhere((m) => m.name == 'methodWithGenericParam');
      methodWithTypedefParam = c.instanceMethods
          .singleWhere((m) => m.name == 'methodWithTypedefParam');
      doAComplicatedThing = fakeLibrary.publicFunctions
          .firstWhere((m) => m.name == 'doAComplicatedThing') as ModelFunction;
    });

    test('covariant parameters render correctly', () {
      expect(applyCovariantParams.parameters, hasLength(2));
      expect(applyCovariantParams.linkedParamsLines,
          contains('<span>covariant</span>'));
    });

    test(
        'ambiguous reference to function parameter parameters resolves to nothing',
        () {
      expect(doAComplicatedThing.documentationAsHtml,
          contains('<code>aThingParameter</code>'));
    });

    test('has parameters', () {
      expect(isGreaterThan.parameters, hasLength(2));
    });

    test('is optional', () {
      expect(intCheckOptional.isNamed, isTrue);
      expect(intCheckOptional.isRequiredNamed, isFalse);
      expect(intNumber.isNamed, isFalse);
      expect(intNumber.isRequiredPositional, isTrue);
    });

    test('default value', () {
      expect(intCheckOptional.defaultValue, '5');
    });

    test('is named', () {
      expect(intCheckOptional.isNamed, isTrue);
    });

    test('uses = instead of : to set default value', () {
      final rendered =
          ParameterRendererHtml().renderLinkedParams([intCheckOptional]);
      expect(rendered, contains('</span> = <span'));
    });

    test('linkedName', () {
      expect(intCheckOptional.modelType.linkedName, 'int');
    });

    test('async return type', () {
      expect(asyncM.modelType.returnType.linkedName, 'dynamic');
    });

    test('param with generics', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(methodWithGenericParam.parameters);
      expect(params, contains('List'));
      expect(params, contains('Apple'));
    });

    test('commas on same param line', () {
      var method =
          fakeLibrary.functions.firstWhere((f) => f.name == 'paintImage1');
      var params =
          ParameterRendererHtml().renderLinkedParams(method.parameters);
      expect(params, contains(', </span>'));
    });

    test('param with annotations', () {
      var method =
          fakeLibrary.functions.firstWhere((f) => f.name == 'paintImage2');
      var params =
          ParameterRendererHtml().renderLinkedParams(method.parameters);
      expect(
          params,
          contains(
              '@<a href="${htmlBasePlaceholder}fake/required-constant.html">required</a>'));
    });

    test('param exported in library', () {
      var param = paramFromExportLib.parameters[0];
      expect(param.name, equals('helper'));
      expect(param.library.name, equals('ex'));
    });

    test('typedef param is linked and does not include types', () {
      var params = ParameterRendererHtml()
          .renderLinkedParams(methodWithTypedefParam.parameters);
      expect(
          params,
          equals('<span class="parameter" id="methodWithTypedefParam-param-p">'
              '<span class="type-annotation"><a href="${htmlBasePlaceholder}ex/processMessage.html">processMessage</a></span> '
              '<span class="parameter-name">p</span></span>'));
    });
  });

  group('Implementors', () {
    late final Class apple;
    late final Class b;
    late final List<InheritingContainer> implA, implC;

    setUpAll(() {
      apple = exLibrary.classes.firstWhere((c) => c.name == 'Apple');
      b = exLibrary.classes.firstWhere((c) => c.name == 'B');
      implA = apple.publicImplementors.toList();
      implC = exLibrary.classes
          .firstWhere((c) => c.name == 'Cat')
          .publicImplementors
          .toList();
    });

    test('private classes do not break the implementor chain', () {
      var Super1 = fakeLibrary.classes.singleWhere((c) => c.name == 'Super1');
      var publicImplementors = Super1.publicImplementors.map((i) => i.name);
      expect(publicImplementors, hasLength(3));
      // A direct implementor.
      expect(publicImplementors, contains('Super4'));
      // An implementor through _Super2.
      expect(publicImplementors, contains('Super3'));
      // An implementor through _Super5 and _Super2.
      expect(publicImplementors, contains('Super6'));
    });

    test(
        'private classes in internal libraries do not break the implementor chain',
        () {
      var GenericSuperProperty = fakeLibrary.classes
          .singleWhere((c) => c.name == 'GenericSuperProperty');
      var publicImplementors =
          GenericSuperProperty.publicImplementors.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      // A direct implementor.
      expect(publicImplementors, contains('GenericSuperValue'));

      var GenericSuperValue =
          fakeLibrary.classes.singleWhere((c) => c.name == 'GenericSuperValue');
      publicImplementors =
          GenericSuperValue.publicImplementors.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      // A direct implementor.
      expect(publicImplementors, contains('GenericSuperNum'));

      var GenericSuperNum =
          fakeLibrary.classes.singleWhere((c) => c.name == 'GenericSuperNum');
      publicImplementors =
          GenericSuperNum.publicImplementors.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      expect(publicImplementors, contains('GenericSuperInt'));
    });

    test('the first class is Apple', () {
      expect(apple.name, equals('Apple'));
    });

    test('apple has some implementors', () {
      expect(apple.hasPublicImplementors, isTrue);
      expect(implA, isNotNull);
      expect(implA, hasLength(1));
      expect(implA[0].name, equals('B'));
    });

    test('Cat has implementors', () {
      expect(implC, hasLength(3));
      var implementors = <String>['B', 'Dog', 'ConstantCat'];
      expect(implementors, contains(implC[0].name));
      expect(implementors, contains(implC[1].name));
      expect(implementors, contains(implC[2].name));
    });

    test('B does not have implementors', () {
      expect(b, isNotNull);
      expect(b.name, equals('B'));
      expect(b.publicImplementors, hasLength(0));
    });
  });

  group('Errors and exceptions', () {
    var expectedNames = <String>[
      'MyError',
      'MyException',
      'MyErrorImplements',
      'MyExceptionImplements'
    ];
    test('library has the exact errors/exceptions we expect', () {
      expect(exLibrary.exceptions.map((e) => e.name),
          unorderedEquals(expectedNames));
    });
  });

  group('Source Code HTML', () {
    Class EscapableProperties;
    late final Field implicitGetterExplicitSetter, explicitGetterImplicitSetter;
    late final Field explicitGetterSetter, explicitGetterSetterForInheriting;
    late final Field finalProperty, simpleProperty, forInheriting;
    late final Field ensureWholeDeclarationIsVisible;

    setUpAll(() {
      EscapableProperties = fakeLibrary.classes
          .firstWhere((c) => c.name == 'HtmlEscapableProperties');
      implicitGetterExplicitSetter = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'implicitGetterExplicitSetter') as Field;
      explicitGetterImplicitSetter = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterImplicitSetter') as Field;
      explicitGetterSetter = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'explicitGetterSetter') as Field;
      finalProperty = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'finalProperty') as Field;
      simpleProperty = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'simpleProperty') as Field;
      forInheriting = EscapableProperties.allModelElements
          .firstWhere((e) => e.name == 'forInheriting') as Field;
      explicitGetterSetterForInheriting = EscapableProperties.allModelElements
              .firstWhere((e) => e.name == 'explicitGetterSetterForInheriting')
          as Field;
      ensureWholeDeclarationIsVisible = EscapableProperties.allModelElements
              .firstWhere((e) => e.name == 'ensureWholeDeclarationIsVisible')
          as Field;
    });

    test('Normal property fields are escaped', () {
      expect(finalProperty.sourceCode, contains('&lt;int&gt;'));
      expect(simpleProperty.sourceCode, contains('&lt;int&gt;'));
      expect(forInheriting.sourceCode, contains('&lt;int&gt;'));
    });

    test('Explicit accessors are escaped', () {
      expect(explicitGetterSetter.getter!.sourceCode, contains('&lt;int&gt;'));
      expect(explicitGetterSetter.setter!.sourceCode, contains('&lt;int&gt;'));
    });

    test('Implicit accessors are escaped', () {
      expect(implicitGetterExplicitSetter.getter!.sourceCode,
          contains('&lt;int&gt;'));
      expect(implicitGetterExplicitSetter.setter!.sourceCode,
          contains('&lt;int&gt;'));
      expect(explicitGetterImplicitSetter.getter!.sourceCode,
          contains('&lt;int&gt;'));
      expect(explicitGetterImplicitSetter.setter!.sourceCode,
          contains('&lt;int&gt;'));
      expect(explicitGetterSetterForInheriting.getter!.sourceCode,
          contains('&lt;int&gt;'));
      expect(explicitGetterSetterForInheriting.setter!.sourceCode,
          contains('&lt;int&gt;'));
    });

    test('Property fields are terminated with semicolon', () {
      expect(finalProperty.sourceCode.trim(),
          endsWith('List&lt;int&gt;.filled(1, 1);'));
      expect(simpleProperty.sourceCode.trim(),
          endsWith('List&lt;int&gt;.filled(1, 1);'));
      expect(forInheriting.sourceCode.trim(), endsWith('forInheriting;'));
    });

    test('Arrow accessors are terminated with semicolon', () {
      expect(explicitGetterImplicitSetter.getter!.sourceCode.trim(),
          endsWith('List&lt;int&gt;.filled(1, 1);'));
      expect(explicitGetterSetter.getter!.sourceCode.trim(),
          endsWith('List&lt;int&gt;.filled(1, 1);'));
    });

    test('Traditional accessors are not terminated with semicolon', () {
      expect(implicitGetterExplicitSetter.setter!.sourceCode.trim(),
          endsWith('{}'));
      expect(explicitGetterSetter.setter!.sourceCode.trim(), endsWith('{}'));
    });

    test('Whole declaration is visible when declaration spans many lines', () {
      expect(ensureWholeDeclarationIsVisible.sourceCode,
          contains('List&lt;int&gt;? '));
    });
  });

  group('Sorting by name', () {
    // Order by uppercase lexical ordering for non-digits,
    // lexicographical ordering of embedded digit sequences.
    var names = [
      r'',
      r'$',
      r'0',
      r'0a',
      r'00',
      r'1',
      r'01',
      r'_',
      r'a',
      r'aaab',
      r'aab',
      r'Ab',
      r'B',
      r'bA',
      r'x0$',
      r'x1$',
      r'x01$',
      r'x001$',
      r'x10$',
      r'x010$',
      r'x100$',
    ];
    for (var i = 1; i < names.length; i++) {
      var a = StringName(names[i - 1]);
      var b = StringName(names[i]);
      test('"$a" < "$b"', () {
        expect(byName(a, a), 0);
        expect(byName(b, b), 0);
        expect(byName(a, b), -1);
        expect(byName(b, a), 1);
      });
    }

    test('sort order is stable when necessary', () {
      var a = StringNameHashCode('a', 12);
      var b = StringNameHashCode('b', 12);
      var aa = StringNameHashCode('a', 14);
      expect(byName(a, aa), -1);
      expect(byName(a, b), -1);
      expect(byName(b, a), 1);
      expect(byName(aa, b), -1);
    });
  });
}

class StringName extends Nameable {
  @override
  final String name;

  StringName(this.name);

  @override
  String toString() => name;
}

class StringNameHashCode extends Nameable {
  @override
  final String name;
  @override
  final int hashCode;

  StringNameHashCode(this.name, this.hashCode);

  @override
  String toString() => name;

  @override
  // ignore: unnecessary_overrides
  bool operator ==(Object other) => super == other;
}

extension on Library {
  Class getClassByName(String name) {
    return allClasses.firstWhere((c) => c.name == name);
  }
}
