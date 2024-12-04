// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// ignore_for_file: non_constant_identifier_names

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:async/async.dart';
import 'package:collection/src/iterable_extensions.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/attribute.dart';
import 'package:dartdoc/src/model/kind.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/package_config_provider.dart';
import 'package:dartdoc/src/package_meta.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';

import '../src/utils.dart'
    show
        ModelElementIterableExtension,
        bootBasicPackage,
        kTestPackagePublicLibraries,
        referenceLookup;

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

  @override
  Package get package => throw UnimplementedError();

  TestLibraryContainer(
      this.name, this.containerOrder, LibraryContainer? enclosingContainer)
      : enclosingName = enclosingContainer?.name ?? '';

  @override
  DartdocOptionContext get config => throw UnimplementedError();

  @override
  String? get documentation => throw UnimplementedError();

  @override
  String get documentationAsHtml => throw UnimplementedError();

  @override
  bool get hasDocumentation => throw UnimplementedError();

  @override
  String? get href => throw UnimplementedError();

  @override
  bool get isDocumented => throw UnimplementedError();

  @override
  Kind get kind => throw UnimplementedError();

  @override
  String get oneLineDoc => throw UnimplementedError();

  @override
  String? get aboveSidebarPath => null;

  @override
  String? get belowSidebarPath => null;
}

class TestLibraryContainerSdk extends TestLibraryContainer {
  TestLibraryContainerSdk(super.name, super.containerOrder,
      LibraryContainer super.enclosingContainer);

  @override
  bool get isSdk => true;
}

void main() async {
  final packageGraph = await testPackageGraph;
  late final Library exLibrary;
  late final Library fakeLibrary;
  late final Library twoExportsLib;
  late final Library baseClassLib;
  late final Library dartAsync;

  setUpAll(() async {
    // Use model_special_cases_test.dart for tests that require
    // a different package graph.
    exLibrary = packageGraph.libraries.named('ex');
    fakeLibrary = packageGraph.libraries.named('fake');
    dartAsync = packageGraph.libraries.named('dart:async');
    twoExportsLib = packageGraph.libraries.named('two_exports');
    baseClassLib = packageGraph.libraries.named('base_class');
  });

  group('triple-shift', () {
    Library tripleShift;
    late final Class C, E, F;
    Extension ShiftIt;
    late final Operator classShift, extensionShift;
    late final Field constantTripleShifted;

    setUpAll(() async {
      tripleShift = (await testPackageGraph).libraries.named('triple_shift');
      C = tripleShift.classes.named('C');
      E = tripleShift.classes.named('E');
      F = tripleShift.classes.named('F');
      ShiftIt = tripleShift.extensions.named('ShiftIt');
      classShift =
          C.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
      extensionShift =
          ShiftIt.instanceOperators.firstWhere((o) => o.name.contains('>>>'));
      constantTripleShifted = C.constantFields.named('constantTripleShifted');
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
      genericMetadata =
          (await testPackageGraph).libraries.named('generic_metadata');
      F = genericMetadata.typedefs.named('F');
      f = genericMetadata.properties.named('f');
      C = genericMetadata.classes.named('C');
      mp = C.instanceMethods.named('mp');
      mn = C.instanceMethods.named('mn');
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
      generalizedTypedefs =
          packageGraph.libraries.named('generalized_typedefs');
      T0 = generalizedTypedefs.typedefs.named('T0');
      T1 = generalizedTypedefs.typedefs.named('T1');
      T2 = generalizedTypedefs.typedefs.named('T2');
      T3 = generalizedTypedefs.typedefs.named('T3');
      T4 = generalizedTypedefs.typedefs.named('T4');
      T5 = generalizedTypedefs.typedefs.named('T5');
      T6 = generalizedTypedefs.typedefs.named('T6');
      T7 = generalizedTypedefs.typedefs.named('T7');
      C = generalizedTypedefs.classes.named('C');
      C2 = generalizedTypedefs.classes.named('C2');
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
      var g = C.instanceMethods.named('g');

      var c = C2.allFields.named('c');
      var d = C2.instanceMethods.named('d');

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
      var a = generalizedTypedefs.properties.named('a');
      var b = C2.allFields.named('b');
      var f = C.allFields.named('f');
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
      lateFinalWithoutInitializer =
          packageGraph.libraries.named('late_final_without_initializer');
      nullSafetyClassMemberDeclarations =
          packageGraph.libraries.named('nnbd_class_member_declarations');
      nullableElements = packageGraph.libraries.named('nullable_elements');
      b = nullSafetyClassMemberDeclarations.classes.named('B');
      c = nullSafetyClassMemberDeclarations.classes.named('C');
      oddAsyncFunction =
          nullableElements.functions.wherePublic.named('oddAsyncFunction');
      anotherOddFunction =
          nullableElements.functions.wherePublic.named('oddAsyncFunction');
      neverReturns =
          nullableElements.functions.wherePublic.named('neverReturns');
      almostNeverReturns =
          nullableElements.functions.wherePublic.named('almostNeverReturns');
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
      var m1 = b.instanceMethods.named('m1');
      var p1 = m1.parameters.named('p1');
      var p2 = m1.parameters.named('p2');
      expect(p1.isRequiredNamed, isTrue);
      expect(p2.isRequiredNamed, isFalse);
      expect(p2.isNamed, isTrue);

      expect(
          m1.linkedParamsLines,
          equals(
              '<ol class="parameter-list"> <li><span class="parameter" id="m1-param-some"><span class="type-annotation">int</span> <span class="parameter-name">some</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-regular"><span class="type-annotation">dynamic</span> <span class="parameter-name">regular</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-parameters"><span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">parameters</span>, {</span></li>\n'
              '<li><span class="parameter" id="m1-param-p1"><span>required</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p1</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p2"><span class="type-annotation">int</span> <span class="parameter-name">p2</span> = <span class="default-value">3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p3"><span>required</span> <span>covariant</span> <span class="type-annotation">dynamic</span> <span class="parameter-name">p3</span>, </span></li>\n'
              '<li><span class="parameter" id="m1-param-p4"><span>required</span> <span>covariant</span> <span class="type-annotation">int</span> <span class="parameter-name">p4</span>, </span></li>\n'
              '</ol>}'));
    });

    test('verify no regression on ordinary optionals', () {
      var m2 = b.instanceMethods.named('m2');
      var sometimes = m2.parameters.named('sometimes');
      var optionals = m2.parameters.named('optionals');
      expect(sometimes.isRequiredNamed, isFalse);
      expect(sometimes.isRequiredPositional, isTrue);
      expect(sometimes.isOptionalPositional, isFalse);
      expect(optionals.isRequiredNamed, isFalse);
      expect(optionals.isRequiredPositional, isFalse);
      expect(optionals.isOptionalPositional, isTrue);

      expect(
          m2.linkedParamsLines,
          equals(
              '<ol class="parameter-list"> <li><span class="parameter" id="m2-param-sometimes"><span class="type-annotation">int</span> <span class="parameter-name">sometimes</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-we"><span class="type-annotation">dynamic</span> <span class="parameter-name">we</span>, [</span></li>\n'
              '<li><span class="parameter" id="m2-param-have"><span class="type-annotation">String</span> <span class="parameter-name">have</span>, </span></li>\n'
              '<li><span class="parameter" id="m2-param-optionals"><span class="type-annotation">double</span> <span class="parameter-name">optionals</span>, </span></li>\n'
              '</ol>]'));
    });

    test('anonymous callback parameters are correctly marked as nullable', () {
      var m3 = c.instanceMethods.named('m3');
      var listen = m3.parameters.named('listen');
      var onDone = m3.parameters.named('onDone');
      expect(listen.isRequiredPositional, isTrue);
      expect(onDone.isNamed, isTrue);

      expect(m3.linkedParamsLines, contains('</ol>)?, '));
      expect(m3.linkedParamsLines, contains('</ol>}'));
    });

    test('Late final class member test', () {
      var c = lateFinalWithoutInitializer.classes.named('C');
      var a = c.instanceFields.named('a');
      var b = c.instanceFields.named('b');
      var cField = c.instanceFields.named('cField');
      var dField = c.instanceFields.named('dField');

      // If Null safety isn't enabled, fields named 'late' come back from the
      // analyzer instead of setting up 'isLate'.
      expect(c.instanceFields.any((f) => f.name == 'late'), isFalse);

      expect(a.modelType.name, equals('dynamic'));
      expect(a.isLate, isTrue);
      expect(a.attributes, contains(Attribute.late_));
      expect(a.attributes, isNot(contains(Attribute.getterSetterPair)));

      expect(b.modelType.name, equals('int'));
      expect(b.isLate, isTrue);
      expect(b.attributes, contains(Attribute.late_));
      expect(b.attributes, isNot(contains(Attribute.getterSetterPair)));

      expect(cField.modelType.name, equals('dynamic'));
      expect(cField.isLate, isTrue);
      expect(cField.attributes, contains(Attribute.late_));
      expect(cField.attributes, isNot(contains(Attribute.getterSetterPair)));

      expect(dField.modelType.name, equals('double'));
      expect(dField.isLate, isTrue);
      expect(dField.attributes, contains(Attribute.late_));
      expect(dField.attributes, isNot(contains(Attribute.getterSetterPair)));
    });

    test('Late final top level variables', () {
      var initializeMe = lateFinalWithoutInitializer.properties.wherePublic
          .named('initializeMe');
      expect(initializeMe.modelType.name, equals('String'));
      expect(initializeMe.isLate, isTrue);
      expect(initializeMe.attributes, contains(Attribute.late_));
      expect(
          initializeMe.attributes, isNot(contains(Attribute.getterSetterPair)));
    });

    test('complex nullable elements are detected and rendered correctly', () {
      var complexNullableMembers =
          nullableElements.classes.named('ComplexNullableMembers');
      expect(
          complexNullableMembers.nameWithGenerics,
          equals(
              'ComplexNullableMembers&lt;<wbr><span class="type-parameter">T extends String?</span>&gt;'));
    });

    test('simple nullable elements are detected and rendered correctly', () {
      var nullableMembers = nullableElements.classes.named('NullableMembers');
      var methodWithNullables = nullableMembers.instanceMethods.wherePublic
          .named('methodWithNullables');
      var operatorStar =
          nullableMembers.instanceOperators.wherePublic.named('operator *');
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
      set_literals = packageGraph.libraries.named('set_literals');
      aComplexSet = set_literals.constants.named('aComplexSet');
      inferredTypeSet = set_literals.constants.named('inferredTypeSet');
      specifiedSet = set_literals.constants.named('specifiedSet');
      untypedMap = set_literals.constants.named('untypedMap');
      untypedMapWithoutConst =
          set_literals.constants.named('untypedMapWithoutConst');
      typedSet = set_literals.constants.named('typedSet');
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
    late final Class ImplementingClassForTool,
        CanonicalPrivateInheritedToolUser;
    late final Method invokeTool;
    late final Method invokeToolNoInput;
    late final Method invokeToolMultipleSections;
    late final Method invokeToolParentDoc, invokeToolParentDocOriginal;
    // ignore: omit_local_variable_types
    final RegExp packageInvocationIndexRegexp =
        RegExp(r'PACKAGE_INVOCATION_INDEX: (\d+)');

    setUpAll(() {
      ImplementingClassForTool =
          fakeLibrary.classes.named('ImplementingClassForTool');
      CanonicalPrivateInheritedToolUser =
          fakeLibrary.classes.named('CanonicalPrivateInheritedToolUser');
      toolUser = exLibrary.classes.named('ToolUser');
      invokeTool = toolUser.instanceMethods.named('invokeTool');
      invokeToolNoInput = toolUser.instanceMethods.named('invokeToolNoInput');
      invokeToolMultipleSections =
          toolUser.instanceMethods.named('invokeToolMultipleSections');
      invokeToolParentDoc = CanonicalPrivateInheritedToolUser.instanceMethods
          .named('invokeToolParentDoc');
      invokeToolParentDocOriginal =
          ImplementingClassForTool.instanceMethods.named('invokeToolParentDoc');
      for (var modelElement in packageGraph.localPublicLibraries
          .expand((l) => l.allModelElements)) {
        // Accessing this getter triggers documentation-processing.
        modelElement.documentation;
      }
    });

    test(
        'invokes tool when inherited documentation is the only means for it to be seen',
        () {
      // Verify setup of the test is correct.
      expect(invokeToolParentDoc.isCanonical, isTrue);
      expect(invokeToolParentDoc.hasDocumentationComment, isFalse);
      // Error message here might look strange due to `toString()` on Methods,
      // but if this fails that means we don't have the correct
      // invokeToolParentDoc instance.
      expect(invokeToolParentDoc.documentationFrom,
          contains(invokeToolParentDocOriginal));
      // Tool should be substituted out here.
      expect(invokeToolParentDoc.documentation, isNot(contains('{@tool')));
    });

    group('does _not_ invoke a tool multiple times unnecessarily', () {
      test('for documentation inherited from the implementer', () {
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
              .localPackages.first.defaultCategory.libraries.wherePublic.length,
          // Only 5 libraries have categories, the rest belong in default.
          equals(kTestPackagePublicLibraries - 5));
    });

    // TODO consider moving these to a separate suite
    test('CategoryRendererHtml renders category label', () {
      var category = packageGraph.publicPackages.first.categories.first;
      expect(
          category.categoryLabel,
          '<span class="category superb cp-0 linked" title="This is part of the Superb topic.">'
          '<a href="${htmlBasePlaceholder}topics/Superb-topic.html">Superb</a></span>');
    });

    test('CategoryRendererHtml renders linkedName', () {
      var category = packageGraph.publicPackages.first.categories.first;
      expect(category.linkedName,
          '<a href="${htmlBasePlaceholder}topics/Superb-topic.html">Superb</a>');
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
      anonLib = packageGraph.libraries.named('anonymous_library');
      someLib = packageGraph.libraries.named('reexport.somelib');
      reexportOneLib = packageGraph.libraries.named('reexport_one');
      reexportTwoLib = packageGraph.libraries.named('reexport_two');
      reexportThreeLib = packageGraph.libraries.named('reexport_three');
      SomeClass = someLib.getClassByName('SomeClass');
      SomeOtherClass = someLib.getClassByName('SomeOtherClass');
      YetAnotherClass = someLib.getClassByName('YetAnotherClass');
      AUnicornClass = someLib.getClassByName('AUnicornClass');
      ADuplicateClass = reexportThreeLib.getClassByName('ADuplicateClass');

      isDeprecated = packageGraph.libraries.named('is_deprecated');
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
      expect(fakeLibrary.classes.map((c) => c.name),
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
      // Unicorn class has a warning because two `@canonicalFor`s cancel each
      // other out.
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              AUnicornClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // This class is ambiguous without a `@canonicalFor`.
      expect(
          packageGraph.packageWarningCounter.hasWarning(
              YetAnotherClass, PackageWarning.ambiguousReexport, warningMsg),
          isTrue);
      // These two classes have a `@canonicalFor`.
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
          ...fakeLibrary.element.definingCompilationUnit.libraryImports
              .map((import) => import.uri)
              .whereType<DirectiveUriWithLibrary>()
              .map((uri) => uri.library),
          ...fakeLibrary.element.definingCompilationUnit.libraryExports
              .map((import) => import.uri)
              .whereType<DirectiveUriWithLibrary>()
              .map((uri) => uri.library)
        })
          packageGraph.getModelForElement(l) as Library
      };
      expect(fakeLibraryImportedExported.any((l) => l.name == 'import_unusual'),
          isTrue);
    });

    test('@canonicalFor directive works', () {
      expect(SomeOtherClass.canonicalLibrary, reexportOneLib);
      expect(SomeClass.canonicalLibrary, reexportTwoLib);
    });

    test('with correct show/hide behavior', () {
      expect(ADuplicateClass.library.name, equals('shadowing_lib'));
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
      dog = exLibrary.classes.named('Dog');
      withMacro = dog.instanceMethods.named('withMacro');
      withMacro2 = dog.instanceMethods.named('withMacro2');
      withPrivateMacro = dog.instanceMethods.named('withPrivateMacro');
      withUndefinedMacro = dog.instanceMethods.named('withUndefinedMacro');
      MacrosFromAccessors = fakeLibrary.enums.named('MacrosFromAccessors');
      macroReferencedHere = MacrosFromAccessors.publicEnumValues
          .named('macroReferencedHere') as EnumField;
      ClassTemplateOneLiner = exLibrary.classes.named('ClassTemplateOneLiner');
    });

    test('via reexport does not leave behind template crumbs', () {
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
      dog = exLibrary.classes.named('Dog');
      withYouTubeWatchUrl = dog.instanceMethods.named('withYouTubeWatchUrl');
      withYouTubeInOneLineDoc =
          dog.instanceMethods.named('withYouTubeInOneLineDoc');
      withYouTubeInline = dog.instanceMethods.named('withYouTubeInline');
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
      var dog = exLibrary.classes.named('Dog');
      withAnimationInOneLineDoc =
          dog.instanceMethods.named('withAnimationInOneLineDoc');
      withAnimationInline = dog.instanceMethods.named('withAnimationInline');
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
      incorrectDocReferenceFromEx =
          exLibrary.constants.named('incorrectDocReferenceFromEx');
      B = exLibrary.classes.named('B');
      Apple = exLibrary.classes.named('Apple');
      specialList = fakeLibrary.classes.named('SpecialList');
      topLevelFunction = fakeLibrary.functions.named('topLevelFunction');
      thisIsAsync = fakeLibrary.functions.named('thisIsAsync');
      testingCodeSyntaxInOneLiners =
          fakeLibrary.constants.named('testingCodeSyntaxInOneLiners');
      superAwesomeClass = fakeLibrary.classes.named('SuperAwesomeClass');
      foo2 = fakeLibrary.classes.named('Foo2');
      extendedClass = twoExportsLib.classes.named('ExtendingClass');

      subForDocComments = fakeLibrary.classes.named('SubForDocComments');

      baseForDocComments = fakeLibrary.classes.named('BaseForDocComments');
      doAwesomeStuff =
          baseForDocComments.instanceMethods.named('doAwesomeStuff');

      short = fakeLibrary.functions.named('short');
    });

    group('markdown extensions', () {
      late final Class DocumentWithATable;
      late final String docsAsHtml;

      setUpAll(() {
        DocumentWithATable = fakeLibrary.classes.named('DocumentWithATable');
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
              '<th><a href="${htmlBasePlaceholder}fake/Annotation-class.html">Annotation</a></th>'),
        );
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
        var tpvar = fakeLibrary.constants.named('hasMarkdownInDoc');
        var tpvarDocsAsHtml = tpvar.documentationAsHtml;
        expect(tpvarDocsAsHtml, contains('3ffe:2a00:100:7031::1'));
      });
    });

    group('Comment processing', () {
      test('can virtually add nodoc via options file', () {
        var NodocMeLibrary =
            packageGraph.defaultPackage.allLibraries.named('nodocme');
        expect(NodocMeLibrary.hasNodoc, isTrue);
        var NodocMeImplementation =
            fakeLibrary.classes.named('NodocMeImplementation');
        expect(NodocMeImplementation.hasNodoc, isTrue);
        expect(NodocMeImplementation.isPublic, isFalse);
        var MeNeitherEvenWithoutADocComment =
            fakeLibrary.classes.named('MeNeitherEvenWithoutADocComment');
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
        var aFunctionUsingRenamedLib =
            fakeLibrary.functions.named('aFunctionUsingRenamedLib');
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
            'Link to library: '
            '<a href="${htmlBasePlaceholder}mylibpub/">renamedLib</a>',
          ),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
            'Link to constructor (implied, no new): '
            '<a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/YetAnotherHelper.html">'
            'renamedLib.YetAnotherHelper()</a>',
          ),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
            'Link to class: '
            '<a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper-class.html">'
            'renamedLib.YetAnotherHelper</a>',
          ),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
            'Link to constructor (direct): '
            '<a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/YetAnotherHelper.html">'
            'renamedLib.YetAnotherHelper.new</a>',
          ),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
              'Link to class member: <a href="${htmlBasePlaceholder}mylibpub/YetAnotherHelper/getMoreContents.html">renamedLib.YetAnotherHelper.getMoreContents</a>'),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
              'Link to function: <a href="${htmlBasePlaceholder}mylibpub/helperFunction.html">renamedLib.helperFunction</a>'),
        );
        expect(
          aFunctionUsingRenamedLib.documentationAsHtml,
          contains(
              'Link to overlapping prefix: <a href="${htmlBasePlaceholder}csspub/theOnlyThingInTheLibrary.html">renamedLib2.theOnlyThingInTheLibrary</a>'),
        );
      });

      test('operator [] reference within a class works', () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/BaseForDocComments/operator_get.html">operator []</a> '),
        );
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
              '<a href="${htmlBasePlaceholder}fake/BaseForDocComments-class.html">BaseForDocComments</a>'),
        );
      });

      test(
          'link to a name in another library in this package, but is not imported into this library, should still be linked',
          () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}anonymous_library/doesStuff.html">doesStuff</a>'),
        );
      });

      test(
          'link to unresolved name in the library in this package still should be linked',
          () {
        var helperClass = exLibrary.classes.named('Helper');
        expect(
          helperClass.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'),
        );
        expect(
          helperClass.documentationAsHtml,
          contains('<a href="${htmlBasePlaceholder}ex/B-class.html">ex.B</a>'),
        );
      });

      test('link to override method in implementer from base class', () {
        var helperClass = baseClassLib.classes.named('Constraints');
        expect(
          helperClass.documentationAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}override_class/BoxConstraints/debugAssertIsValid.html">BoxConstraints.debugAssertIsValid</a>'),
        );
      });

      test(
          'link to a name of a class from an imported library that exports the name',
          () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}two_exports/BaseClass-class.html">BaseClass</a>'),
        );
      });

      test(
          'links to a reference to a top-level const with multiple underscores',
          () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/NAME_WITH_TWO_UNDERSCORES-constant.html">NAME_WITH_TWO_UNDERSCORES</a>'),
        );
      });

      test('links to a method in this class', () {
        expect(
          docsAsHtml,
          contains(
              '<a href="${htmlBasePlaceholder}fake/BaseForDocComments/anotherMethod.html">anotherMethod</a>'),
        );
      });

      test('links to a top-level function in this library', () {
        expect(
          docsAsHtml,
          contains(
              '<a class="deprecated" href="${htmlBasePlaceholder}fake/topLevelFunction.html">topLevelFunction</a>'),
        );
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
      var add = specialList.instanceMethods.named('add');
      expect(
          add.oneLineDoc,
          equals(
              'Adds <code>value</code> to the end of this list,\nextending the length by one.'));
    });

    test(
        'full documentation references from inherited methods should not have brackets',
        () {
      var add = specialList.instanceMethods.named('add');
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
            'use <a href="${htmlBasePlaceholder}ex/Apple/Apple.html">Apple.new</a>'),
      );
      expect(
        comment,
        contains(
            '<a href="${htmlBasePlaceholder}ex/Apple/Apple.fromString.html">Apple.fromString</a>'),
      );
    });

    test('references to nullable type and null-checked variable', () {
      var RefsWithQsAndBangs = exLibrary.classes.named('RefsWithQsAndBangs');
      var comment = RefsWithQsAndBangs.documentationAsHtml;
      expect(
        comment,
        contains(
            'nullable type: <a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple?</a>'),
      );
      expect(
        comment,
        contains(
            'null-checked variable <a href="${htmlBasePlaceholder}ex/myNumber.html">myNumber!</a>'),
      );
    });

    test('reference to constructor named the same as a field', () {
      var FieldAndCtorWithSameName =
          exLibrary.classes.named('FieldAndCtorWithSameName');
      var comment = FieldAndCtorWithSameName.documentationAsHtml;
      expect(
        comment,
        contains('Reference to '
            '<a href="${htmlBasePlaceholder}ex/FieldAndCtorWithSameName/FieldAndCtorWithSameName.named.html">'
            'FieldAndCtorWithSameName.named()</a>'),
      );
    });

    test('reference to class from another library', () {
      var comment = superAwesomeClass.documentationAsHtml;
      expect(
        comment,
        contains(
            '<a href="${htmlBasePlaceholder}ex/Apple-class.html">Apple</a>'),
      );
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
      var notAMethodFromPrivateClass = fakeLibrary.classes
          .named('ReferringClass')
          .instanceMethods
          .wherePublic
          .named('notAMethodFromPrivateClass');
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
      var localMethod = subForDocComments.instanceMethods.named('localMethod');
      expect(localMethod.documentationAsHtml, contains('<code>foo</code>'));
      expect(localMethod.documentationAsHtml, contains('<code>bar</code>'));
    });

    test('doc comment inherited from getter', () {
      var getterWithDocs =
          subForDocComments.instanceFields.named('getterWithDocs');
      expect(getterWithDocs.documentationAsHtml,
          contains('Some really great topics.'));
    });

    test(
        'a property with no explicit getters and setters does not duplicate docs',
        () {
      var powers = superAwesomeClass.instanceFields.named('powers');
      var matches =
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
      var implementorsLibrary =
          packageGraph.publicLibraries.named('implementors');
      var ImplementerOfDeclaredPrivateClasses = implementorsLibrary.classes
          .named('ImplementerOfDeclaredPrivateClasses');
      var ImplementerOfThings =
          implementorsLibrary.classes.named('ImplementerOfThings');
      var ImplementBase = implementorsLibrary.classes.named('ImplementBase');

      expect(
        ImplementerOfThings.publicInterfaceElements.first,
        equals(ImplementBase),
      );
      expect(
        ImplementerOfDeclaredPrivateClasses.publicInterfaceElements.first,
        equals(ImplementBase),
      );

      expect(
        ImplementBase.publicImplementersSorted,
        contains(ImplementerOfDeclaredPrivateClasses),
      );
      expect(
        ImplementBase.publicImplementersSorted,
        contains(ImplementerOfThings),
      );
    });

    test('Overrides from intermediate abstract classes are picked up correctly',
        () {
      var IntermediateAbstractSubclass =
          fakeLibrary.classes.named('IntermediateAbstractSubclass');
      var operatorEquals =
          IntermediateAbstractSubclass.inheritedOperators.named('operator ==');
      expect(operatorEquals.definingEnclosingContainer.name,
          equals('IntermediateAbstract'));
    });

    test(
        'Overrides from intermediate abstract classes that have external implementations via the SDK are picked up correctly',
        () {
      var dartCore = packageGraph.libraries.named('dart:core');
      var intClass = dartCore.classes.named('int');
      var operatorEqualsInt = intClass.inheritedOperators.named('operator ==');
      expect(operatorEqualsInt.definingEnclosingContainer.name, equals('num'));
    });

    test('Factories from unrelated classes are linked correctly', () {
      var A = packageGraph.localPublicLibraries
          .named('unrelated_factories')
          .classes
          .named('A');
      var fromMap = A.constructors.named('A.fromMap');
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
          .named('gadget_extender')
          .classes
          .named('GadgetExtender');
      var gadgetGetter = GadgetExtender.instanceFields.named('gadgetGetter');
      expect(gadgetGetter.isCanonical, isTrue);
    });

    test(
        'ExecutableElements from private classes and from public interfaces (#1561)',
        () {
      var MIEEMixinWithOverride =
          fakeLibrary.classes.wherePublic.named('MIEEMixinWithOverride');
      var problematicOperator =
          MIEEMixinWithOverride.inheritedOperators.named('operator []=');
      expect(problematicOperator.element.enclosingElement3.name,
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
      var classes = fakeLibrary.classes.wherePublic;
      GenericClass = classes.named('GenericClass');
      ModifierClass = classes.named('ModifierClass');
      GenericMixin = fakeLibrary.mixins.wherePublic.named('GenericMixin');
      TypeInferenceMixedIn = classes.named('TypeInferenceMixedIn');
      overrideByEverything =
          TypeInferenceMixedIn.instanceFields.named('overrideByEverything');
      overrideByGenericMixin =
          TypeInferenceMixedIn.instanceFields.named('overrideByGenericMixin');
      overrideByBoth =
          TypeInferenceMixedIn.instanceFields.named('overrideByBoth');
      overrideByModifierClass =
          TypeInferenceMixedIn.instanceFields.named('overrideByModifierClass');
    });

    test('computes interfaces and implementors correctly', () {
      var ThingToImplementInMixin =
          fakeLibrary.classes.wherePublic.named('ThingToImplementInMixin');
      var MixedInImplementation =
          fakeLibrary.classes.wherePublic.named('MixedInImplementation');
      var MixInImplementation = fakeLibrary.mixins.named('MixInImplementation');
      var mixinGetter = MixInImplementation.allFields.named('mixinGetter');

      expect(ThingToImplementInMixin.hasModifiers, isTrue);
      expect(MixInImplementation.hasModifiers, isTrue);
      expect(MixedInImplementation.hasModifiers, isTrue);
      expect(
        ThingToImplementInMixin.publicImplementersSorted,
        orderedEquals([MixInImplementation]),
      );
      expect(
        MixInImplementation.publicImplementersSorted,
        orderedEquals([MixedInImplementation]),
      );
      expect(
        MixedInImplementation.allFields
            .named('mixinGetter')
            .canonicalModelElement,
        equals(mixinGetter),
      );
    });

    test('does have a line number and column', () {
      expect(GenericMixin.characterLocation, isNotNull);
    });

    test('Verify inheritance/mixin structure and type inference', () {
      expect(
          TypeInferenceMixedIn.mixedInTypes
              .map<String>((element) => element.name),
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
      var member = TypeInferenceMixedIn.instanceFields.named('member');
      var modifierMember =
          TypeInferenceMixedIn.instanceFields.named('modifierMember');
      var mixinMember =
          TypeInferenceMixedIn.instanceFields.named('mixinMember');
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
        equals(
            GenericClass.instanceFields.named('overrideByEverything').getter),
      );
      expect(
        overrideByGenericMixin.documentationFrom.first,
        equals(
            GenericClass.instanceFields.named('overrideByGenericMixin').getter),
      );
      expect(
        overrideByBoth.documentationFrom.first,
        equals(GenericClass.instanceFields.named('overrideByBoth').getter),
      );
      expect(
        overrideByModifierClass.documentationFrom.first,
        equals(GenericClass.instanceFields
            .named('overrideByModifierClass')
            .getter),
      );
    });

    test('Verify that documentation for mixin applications contains links', () {
      expect(
        overrideByModifierClass.oneLineDoc,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'),
      );
      expect(
        overrideByModifierClass.canonicalModelElement!.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'),
      );
      expect(
        overrideByGenericMixin.oneLineDoc,
        contains(
            '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'),
      );
      expect(
        overrideByGenericMixin.canonicalModelElement!.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'),
      );
      expect(
        overrideByBoth.oneLineDoc,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'),
      );
      expect(
        overrideByBoth.oneLineDoc,
        contains(
            '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'),
      );
      expect(
        overrideByBoth.canonicalModelElement!.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ModifierClass-class.html">ModifierClass</a>'),
      );
      expect(
        overrideByBoth.canonicalModelElement!.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/GenericMixin-mixin.html">GenericMixin</a>'),
      );
    });
  });

  group('Class', () {
    late final List<Class> classes;
    late final Class Apple, B, Cat, Dog, F, Dep, SpecialList;
    late final Class ExtendingClass, CatString;

    setUpAll(() {
      classes = exLibrary.classes.wherePublic.toList();
      Apple = classes.named('Apple');
      B = classes.named('B');
      Cat = classes.named('Cat');
      Dog = classes.named('Dog');
      F = classes.named('F');
      Dep = classes.named('Deprecated');
      SpecialList = fakeLibrary.classes.named('SpecialList');
      ExtendingClass = twoExportsLib.classes.named('ExtendingClass');
      CatString = exLibrary.classes.named('CatString');
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
            'F&lt;<wbr><span class="type-parameter">T extends String</span>&gt;'),
      );
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
      var interfaces = Dog.interfaceElements;
      expect(interfaces, hasLength(2));
      expect(interfaces[0].name, 'Cat');
      expect(interfaces[1].name, 'E');
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
      expect(Apple.constantFields.wherePublic, hasLength(1));
      expect(
        Apple.constantFields.wherePublic.first.kind,
        equals(Kind.constant),
      );
    });

    test('get instance fields', () {
      expect(
        Apple.instanceFields.wherePublic.where((f) => !f.isInherited),
        hasLength(3),
      );
      expect(
        Apple.instanceFields.wherePublic.first.kind,
        equals(Kind.property),
      );
    });

    test('get inherited properties, including properties of Object', () {
      expect(B.inheritedFields.wherePublic, hasLength(4));
    });

    test('get methods', () {
      expect(Dog.instanceMethods.wherePublic.where((m) => !m.isInherited),
          hasLength(16));
    });

    test('get operators', () {
      expect(Dog.instanceOperators.wherePublic, hasLength(2));
      expect(Dog.instanceOperators.wherePublic.first.name, 'operator ==');
      expect(Dog.instanceOperators.wherePublic.last.name, 'operator +');
    });

    test('has non-inherited instance operators', () {
      expect(Dog.publicInheritedInstanceOperators, isFalse);
    });

    test('has only inherited instance operators', () {
      expect(Cat.publicInheritedInstanceOperators, isTrue);
    });

    test('inherited methods, including from Object ', () {
      expect(B.inheritedMethods.wherePublic, hasLength(7));
      expect(B.hasPublicInheritedMethods, isTrue);
    });

    test('all instance methods', () {
      var methods = B.instanceMethods.wherePublic.where((m) => !m.isInherited);
      expect(methods, isNotEmpty);
      expect(B.instanceMethods.wherePublic,
          hasLength(methods.length + B.inheritedMethods.wherePublic.length));
    });

    test('inherited methods exist', () {
      expect(B.inheritedMethods.named('printMsg'), isNotNull);
      expect(B.inheritedMethods.named('isGreaterThan'), isNotNull);
    });

    test('exported class should have hrefs from the current library', () {
      expect(
          Dep.href, equals('${htmlBasePlaceholder}ex/Deprecated-class.html'));
      expect(Dep.instanceMethods.named('toString').href,
          equals('${htmlBasePlaceholder}ex/Deprecated/toString.html'));
    });

    test('F has a single instance method', () {
      expect(
        F.instanceMethods.wherePublic.where((m) => !m.isInherited),
        hasLength(1),
      );
      expect(
        F.instanceMethods.wherePublic.first.name,
        equals('methodWithGenericParam'),
      );
    });

    test('F has many inherited methods', () {
      expect(
          F.inheritedMethods.wherePublic.map((im) => im.name),
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
      expect(
        F.instanceFields.wherePublic.where((f) => !f.isInherited),
        hasLength(0),
      );
    });

    test('F has a few inherited properties', () {
      expect(F.inheritedFields.wherePublic, hasLength(10));
      expect(
          F.inheritedFields.wherePublic.map((ip) => ip.name),
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
      expect(
          SpecialList.instanceMethods.wherePublic.where((m) => !m.isInherited),
          hasLength(0));
    });

    test('SpecialList has many inherited methods', () {
      expect(SpecialList.inheritedMethods.wherePublic, hasLength(49));
      var methods = SpecialList.availableInstanceMethodsSorted
          .where((m) => m.isInherited)
          .toList();
      expect(methods.first.name, equals('add'));
      expect(methods[1].name, equals('addAll'));
    });

    test('ExtendingClass is in the right canonical library', () {
      expect(ExtendingClass.canonicalLibrary!.name, equals('two_exports'));
    });

    // because both the sub and super classes, though from different libraries,
    // are exported out through one library
    test('ExtendingClass has a super class that is also in the same library',
        () {
      // The real implementation of BaseClass is private, but it is exported.
      expect(ExtendingClass.superChain.first.name, equals('BaseClass'));
      expect(ExtendingClass.superChain.first.modelElement.isCanonical, isTrue);
      expect(ExtendingClass.superChain.first.modelElement.isPublic, isTrue);
      // And it should still show up in the publicSuperChain, because it is
      // exported.
      expect(
        ExtendingClass.superChain.wherePublic.first.name,
        equals('BaseClass'),
      );
      expect(
        ExtendingClass
            .superChain.wherePublic.first.modelElement.canonicalLibrary!.name,
        equals('two_exports'),
      );
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
        generalizedTypedefs =
            packageGraph.libraries.named('generalized_typedefs');
        T0 = generalizedTypedefs.typedefs.named('T0');
        T2 = generalizedTypedefs.typedefs.named('T2');
        T5 = generalizedTypedefs.typedefs.named('T5');
        T8 = generalizedTypedefs.typedefs.named('T8');
        C1 = generalizedTypedefs.classes.named('C1');
        C2 = generalizedTypedefs.classes.named('C2');
        C1a = C1.allFields.named('a');
      });

      test('Verify basic ability to link anything', () {
        expect(referenceLookup(T0, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T2, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T5, 'C2'), equals(MatchingLinkResult(C2)));
        expect(referenceLookup(T8, 'C2'), equals(MatchingLinkResult(C2)));
      });

      test('Verify ability to link to type parameters', () {
        var T2X = T2.typeParameters.named('X');
        expect(referenceLookup(T2, 'X'), equals(MatchingLinkResult(T2X)));
        var T5X = T5.typeParameters.named('X');
        expect(referenceLookup(T5, 'X'), equals(MatchingLinkResult(T5X)));
      });

      test('Verify ability to link to parameters', () {
        var T5name = T5.parameters.named('name');
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
        base = packageGraph.libraries.named('two_exports.src.base');
        extending = packageGraph.libraries.named('two_exports.src.extending');
        local_scope =
            packageGraph.libraries.named('two_exports.src.local_scope');
        two_exports = packageGraph.libraries.named('two_exports');

        BaseWithMembers = base.classes.named('BaseWithMembers');
        aStaticField = BaseWithMembers.staticFields.named('aStaticField');
        aStaticMethod = BaseWithMembers.staticMethods.named('aStaticMethod');
        aConstructor =
            BaseWithMembers.constructors.named('BaseWithMembers.aConstructor');

        someConflictingNameSymbol =
            extending.properties.named('someConflictingNameSymbol');

        // This group tests lookups from the perspective of the reexported
        // elements, to verify that various fallbacks work correctly.
        ExtendingAgain = two_exports.classes.named('ExtendingAgain');
        aField = ExtendingAgain.allFields.named('aField');
        anotherField = ExtendingAgain.allFields.named('anotherField');

        aNotReexportedVariable =
            local_scope.properties.named('aNotReexportedVariable');
        anotherNotReexportedVariable =
            local_scope.properties.named('anotherNotReexportedVariable');
        aSymbolOnlyAvailableInExportContext =
            two_exports.properties.named('aSymbolOnlyAvailableInExportContext');
        someConflictingNameSymbolTwoExports =
            two_exports.properties.named('someConflictingNameSymbol');
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
      late final Field aName, aThing;
      late final TypeParameter ATypeParam,
          BTypeParam,
          CTypeParam,
          DTypeParam,
          QTypeParam;
      late final Method aMethod, aMethodExtended, aMethodExtendedQ;
      late final Parameter aParam, anotherParam, typedParam;
      late final ModelFunction aTopLevelTypeParameterFunction;

      setUpAll(() {
        aTopLevelTypeParameterFunction =
            fakeLibrary.functions.named('aTopLevelTypeParameterFunction');
        // TODO(jcollins-g): dart-lang/dartdoc#2704, HTML and type parameters
        // on the extended type should not be present here.
        DTypeParam = aTopLevelTypeParameterFunction.typeParameters.firstWhere(
            (t) => t.name.startsWith('DTypeParam extends TypeParameterThings'));
        typedParam =
            aTopLevelTypeParameterFunction.parameters.named('typedParam');

        TypeParameterThings = fakeLibrary.classes.named('TypeParameterThings');
        aName = TypeParameterThings.instanceFields.named('aName');
        aThing = TypeParameterThings.instanceFields.named('aThing');
        aMethod = TypeParameterThings.instanceMethods.named('aMethod');

        CTypeParam = aMethod.typeParameters.named('CTypeParam');
        aParam = aMethod.parameters.named('aParam');
        anotherParam = aMethod.parameters.named('anotherParam');

        ATypeParam = TypeParameterThings.typeParameters.named('ATypeParam');
        BTypeParam = TypeParameterThings.typeParameters
            .named('BTypeParam extends FactoryConstructorThings');

        TypeParameterThingsExtended =
            fakeLibrary.classes.named('TypeParameterThingsExtended');
        aMethodExtended =
            TypeParameterThingsExtended.instanceMethods.named('aMethod');

        TypeParameterThingsExtendedQ =
            fakeLibrary.classes.named('TypeParameterThingsExtendedQ');
        aMethodExtendedQ =
            TypeParameterThingsExtendedQ.instanceMethods.named('aMethod');
        QTypeParam = aMethodExtendedQ.typeParameters.named('QTypeParam');
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
        mylibpub = packageGraph.libraries.named('mylibpub');
        aFunctionUsingRenamedLib =
            fakeLibrary.functions.named('aFunctionUsingRenamedLib');
        Dart = packageGraph.libraries.named('Dart');
        DartPackage = packageGraph.packages.firstWhere((p) => p.name == 'Dart');
        nameWithTwoUnderscores =
            fakeLibrary.constants.named('NAME_WITH_TWO_UNDERSCORES');
        nameWithSingleUnderscore =
            fakeLibrary.constants.named('NAME_SINGLEUNDERSCORE');
        string =
            packageGraph.libraries.named('dart:core').classes.named('String');
        metaUseResult =
            packageGraph.libraries.named('meta').classes.named('UseResult');
        baseForDocComments = fakeLibrary.classes.named('BaseForDocComments');
        aNonDefaultConstructor = baseForDocComments.constructors
            .named('BaseForDocComments.aNonDefaultConstructor');
        defaultConstructor =
            baseForDocComments.constructors.named('BaseForDocComments');
        somethingShadowyParameter =
            defaultConstructor.parameters.named('somethingShadowy');
        initializeMe = baseForDocComments.allFields.named('initializeMe');
        somethingShadowy =
            baseForDocComments.allFields.named('somethingShadowy');
        doAwesomeStuff =
            baseForDocComments.instanceMethods.named('doAwesomeStuff');
        anotherMethod =
            baseForDocComments.instanceMethods.named('anotherMethod');
        doAwesomeStuffParam = doAwesomeStuff.parameters.first;
        topLevelFunction = fakeLibrary.functions.named('topLevelFunction');
        function1 = exLibrary.functions.named('function1');
        Apple = exLibrary.classes.named('Apple');
        incorrectDocReference =
            fakeLibrary.constants.named('incorrectDocReference');
        incorrectDocReferenceFromEx =
            exLibrary.constants.named('incorrectDocReferenceFromEx');
        theOnlyThingInTheLibrary = packageGraph.libraries
            .named('csspub')
            .properties
            .named('theOnlyThingInTheLibrary');
        doesStuff = packageGraph.libraries
            .named('anonymous_library')
            .functions
            .named('doesStuff');
        BaseClass = packageGraph.libraries
            .named('two_exports.src.base')
            .classes
            .named('BaseClass');
        bracketOperator =
            baseForDocComments.instanceOperators.named('operator []');
        bracketOperatorOtherClass = fakeLibrary.classes
            .named('SpecialList')
            .instanceOperators
            .named('operator []');
        ExtraSpecialList = fakeLibrary.classes.named('ExtraSpecialList');
        forInheriting = fakeLibrary.classes
            .named('ImplicitProperties')
            .allFields
            .named('forInheriting');
        action = packageGraph.libraries
            .named('reexport.somelib')
            .classes
            .named('BaseReexported')
            .allFields
            .named('action');
        aConstructorShadowed = baseForDocComments.constructors
            .named('BaseForDocComments.aConstructorShadowed');
        aConstructorShadowedField =
            baseForDocComments.allFields.named('aConstructorShadowed');

        FactoryConstructorThings =
            fakeLibrary.classes.named('FactoryConstructorThings');
        anotherName = FactoryConstructorThings.constructors
            .named('FactoryConstructorThings.anotherName');
        anotherConstructor = FactoryConstructorThings.constructors
            .named('FactoryConstructorThings.anotherConstructor');
        factoryConstructorThingsDefault = FactoryConstructorThings.constructors
            .named('FactoryConstructorThings');

        aName = anotherName.parameters.named('aName');
        anotherNameParameter = anotherName.parameters.named('anotherName');
        anotherDifferentName =
            anotherName.parameters.named('anotherDifferentName');
        differentName = anotherName.parameters.named('differentName');
        redHerring = anotherConstructor.parameters.named('redHerring');

        aNameField = FactoryConstructorThings.allFields.named('aName');
        yetAnotherNameField =
            FactoryConstructorThings.allFields.named('yetAnotherName');
        initViaFieldFormal =
            FactoryConstructorThings.allFields.named('initViaFieldFormal');

        aMethod = FactoryConstructorThings.instanceMethods.named('aMethod');
        yetAnotherName = aMethod.parameters.named('yetAnotherName');
      });

      group('Parameter references work properly', () {
        test('via a setter with a function parameter', () {
          var aSetterWithFunctionParameter =
              fakeLibrary.properties.named('aSetterWithFunctionParameter');
          var fParam = aSetterWithFunctionParameter.parameters.named('fParam');
          var fParamA =
              (fParam.modelType as Callable).parameters.named('fParamA');
          var fParamB =
              (fParam.modelType as Callable).parameters.named('fParamB');
          var fParamC =
              (fParam.modelType as Callable).parameters.named('fParamC');

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
          var anotherNameField =
              FactoryConstructorThings.allFields.named('anotherName');
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
                'FactoryConstructorThings.anotherName()'),
            equals(MatchingLinkResult(anotherName)),
          );
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
                anotherName, 'FactoryConstructorThings.anotherName()'),
            equals(MatchingLinkResult(anotherName)),
          );
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
          'Verify that constructors do not override member fields unless '
          'explicitly specified', () {
        expect(
          referenceLookup(baseForDocComments, 'aConstructorShadowed'),
          equals(MatchingLinkResult(aConstructorShadowedField)),
        );
        expect(
          referenceLookup(
              baseForDocComments, 'BaseForDocComments.aConstructorShadowed'),
          equals(MatchingLinkResult(aConstructorShadowedField)),
        );
        expect(
          referenceLookup(
              baseForDocComments, 'BaseForDocComments.aConstructorShadowed()'),
          equals(MatchingLinkResult(aConstructorShadowed)),
        );
      });

      test('Deprecated lookup styles still function', () {
        expect(referenceLookup(baseForDocComments, 'aPrefix.UseResult'),
            equals(MatchingLinkResult(metaUseResult)));
      });

      test('Verify basic linking inside class', () {
        expect(
          referenceLookup(baseForDocComments, 'BaseForDocComments.new'),
          equals(MatchingLinkResult(defaultConstructor)),
        );

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

  group('Extensions', () {
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
      reexportOneLib = packageGraph.libraries.named('reexport_one');
      reexportTwoLib = packageGraph.libraries.named('reexport_two');
      documentOnceReexportOne =
          reexportOneLib.extensions.named('DocumentThisExtensionOnce');
      documentOnceReexportTwo =
          reexportTwoLib.extensions.named('DocumentThisExtensionOnce');
      string =
          packageGraph.libraries.named('dart:core').classes.named('String');
      apple = exLibrary.classes.named('Apple');
      ext = exLibrary.extensions.named('AppleExtension');
      extensionReferencer = exLibrary.classes.named('ExtensionReferencer');
      fancyList = exLibrary.extensions.named('FancyList');
      doSomeStuff = exLibrary.classes
          .named('ExtensionUser')
          .instanceMethods
          .named('doSomeStuff');
      doStuff = exLibrary.extensions
          .named('SimpleStringExtension')
          .instanceMethods
          .named('doStuff');
      staticFieldExtension = exLibrary.extensions.named('StaticFieldExtension');
      extensions = exLibrary.extensions.wherePublic.toList();
      baseTest = fakeLibrary.classes.named('BaseTest');
      bigAnotherExtended = fakeLibrary.classes.named('BigAnotherExtended');
      anotherExtended = fakeLibrary.classes.named('AnotherExtended');
      arm = fakeLibrary.extensions.named('Arm');
      leg = fakeLibrary.extensions.named('Leg');
      uphill = fakeLibrary.extensions.named('Uphill');
      megaTron = fakeLibrary.classes.named('Megatron');
      superMegaTron = fakeLibrary.classes.named('SuperMegaTron');
    });

    test('static fields inside extensions do not crash', () {
      expect(staticFieldExtension.staticFields, hasLength(1));
      expect(staticFieldExtension.staticFields.first.name, equals('aStatic'));
    });

    test('basic canonicalization for extensions', () {
      expect(
          documentOnceReexportOne.href, equals(documentOnceReexportTwo.href));
      expect(documentOnceReexportTwo.isCanonical, isTrue);
    });

    test('classes know about applicableExtensions', () {
      expect(apple.potentiallyApplicableExtensionsSorted, orderedEquals([ext]));
      expect(string.potentiallyApplicableExtensionsSorted,
          contains(documentOnceReexportTwo));
      expect(baseTest.potentiallyApplicableExtensionsSorted, isEmpty);
      expect(anotherExtended.potentiallyApplicableExtensionsSorted,
          orderedEquals([uphill]));
      expect(bigAnotherExtended.potentiallyApplicableExtensionsSorted,
          orderedEquals([uphill]));
    });

    test('applicableExtensions include those from implements & mixins', () {
      Extension extensionCheckLeft,
          extensionCheckRight,
          extensionCheckCenter,
          extensionCheckImplementor2,
          onNewSchool,
          onOldSchool;
      Class implementor, implementor2, school;
      Extension getExtension(String name) => fakeLibrary.extensions.named(name);
      Class getClass(String name) => fakeLibrary.classes.named(name);
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

    test('does have a line number and column', () {
      expect(ext.characterLocation, isNotNull);
    });

    test('has enclosing element', () {
      expect(ext.enclosingElement.name, equals(exLibrary.name));
    });

    test('member method has href', () {
      s = ext.instanceMethods.named('s');
      expect(s.href, '${htmlBasePlaceholder}ex/AppleExtension/s.html');
    });

    test('has extended type', () {
      expect(ext.extendedElement.name, equals('Apple'));
    });

    test('extension name with generics', () {
      expect(
          fancyList.nameWithGenerics,
          equals(
              'FancyList&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('extended type has generics', () {
      expect(fancyList.extendedElement.nameWithGenerics,
          equals('List&lt;<wbr><span class="type-parameter">Z</span>&gt;'));
    });

    test('get methods', () {
      expect(fancyList.instanceMethods.wherePublic, hasLength(1));
    });

    test('get operators', () {
      expect(fancyList.instanceOperators.wherePublic, hasLength(1));
    });

    test('get static methods', () {
      expect(fancyList.publicStaticMethodsSorted, hasLength(1));
    });

    test('get properties', () {
      expect(fancyList.instanceFields.wherePublic, hasLength(1));
    });

    test('get constants', () {
      expect(fancyList.constantFields.wherePublic, hasLength(0));
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
      genericFunction = exLibrary.functions.named('genericFunction');
      paramOfFutureOrNull = fakeLibrary.functions.named('paramOfFutureOrNull');
      thisIsAsync = fakeLibrary.functions.named('thisIsAsync');
      thisIsFutureOr = fakeLibrary.functions.named('thisIsFutureOr');
      thisIsFutureOrNull = fakeLibrary.functions.named('thisIsFutureOrNull');
      topLevelFunction = fakeLibrary.functions.named('topLevelFunction');
      typeParamOfFutureOr = fakeLibrary.functions.named('typeParamOfFutureOr');
      doAComplicatedThing = fakeLibrary.functions.named('doAComplicatedThing');
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
      var topLevelFunction2 = fakeLibrary.functions.named('topLevelFunction2');

      expect(
          topLevelFunction2.linkedParamsLines,
          contains('<span class="parameter-name">p3</span> = '
              '<span class="default-value">const &lt;String, int&gt;{}</span>'
              '</span>'));
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
      var function = fakeLibrary.functions.named('addCallback');
      var params =
          ParameterRendererHtml().renderLinkedParams(function.parameters);
      expect(
          params,
          '<span class="parameter" id="addCallback-param-callback">'
          '<span class="type-annotation"><a href="${htmlBasePlaceholder}fake/VoidCallback.html">VoidCallback</a></span> '
          '<span class="parameter-name">callback</span></span>');

      function = fakeLibrary.functions.named('addCallback2');
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
          '<span class="parameter" id="doAComplicatedThing-param-x"><span class="type-annotation">int</span> <span class="parameter-name">x</span>, {</span>'
          '<span class="parameter" id="doAComplicatedThing-param-doSomething"><span class="type-annotation">void</span> <span class="parameter-name">doSomething</span>(<span class="parameter" id="doSomething-param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span>'
          '<span class="parameter" id="doSomething-param-anotherThing"><span class="type-annotation">String</span> <span class="parameter-name">anotherThing</span></span>)?, </span>'
          '<span class="parameter" id="doAComplicatedThing-param-doSomethingElse"><span class="type-annotation">void</span> <span class="parameter-name">doSomethingElse</span>(<span class="parameter" id="doSomethingElse-param-aThingParameter"><span class="type-annotation">int</span> <span class="parameter-name">aThingParameter</span>, </span>'
          '<span class="parameter" id="doSomethingElse-param-somethingElse"><span class="type-annotation">double</span> <span class="parameter-name">somethingElse</span></span>)?</span>}');
    });
  });

  group('Type expansion', () {
    late final Class TemplatedInterface, ClassWithUnusualProperties;

    setUpAll(() {
      TemplatedInterface = exLibrary.classes.named('TemplatedInterface');
      ClassWithUnusualProperties =
          fakeLibrary.classes.named('ClassWithUnusualProperties');
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
      klass = exLibrary.classes.named('Klass');
      classB = exLibrary.classes.named('B');
      HasGenerics = fakeLibrary.classes.named('HasGenerics');
      CatString = exLibrary.classes.named('CatString');
      Cat = exLibrary.classes.named('Cat');
      inheritedClear =
          CatString.inheritedMethods.singleWhere((m) => m.name == 'clear');
      m1 = classB.instanceMethods.singleWhere((m) => m.name == 'm1');
      isGreaterThan = exLibrary.classes
          .named('Apple')
          .instanceMethods
          .singleWhere((m) => m.name == 'isGreaterThan');
      m4 = classB.instanceMethods.singleWhere((m) => m.name == 'writeMsg');
      m5 = klass.instanceMethods.singleWhere((m) => m.name == 'another');
      m6 = klass.instanceMethods.singleWhere((m) => m.name == 'toString');
      m7 = classB.instanceMethods.singleWhere((m) => m.name == 'doNothing');
      abstractMethod =
          Cat.instanceMethods.singleWhere((m) => m.name == 'abstractMethod');
      testGeneric = exLibrary.classes
          .named('Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGeneric');
      testGenericMethod = exLibrary.classes
          .named('Dog')
          .instanceMethods
          .singleWhere((m) => m.name == 'testGenericMethod');
      convertToMap = HasGenerics.instanceMethods
          .singleWhere((m) => m.name == 'convertToMap');
      TypedFunctionsWithoutTypedefs =
          exLibrary.classes.named('TypedFunctionsWithoutTypedefs');
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

    test('has abstract kind', () {
      expect(abstractMethod.fullkind, 'abstract method');
    });

    test('returns correct overriddenDepth', () {
      final bAbstractMethod = classB.instanceMethods.named('abstractMethod');
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
      expect(m1.attributes, contains(Attribute.override_));
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
      specializedDuration = exLibrary.classes.named('SpecializedDuration');
      plus = specializedDuration.instanceOperators.named('operator +');
      equalsOverride =
          exLibrary.classes.named('Dog').instanceOperators.named('operator ==');
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
      c = exLibrary.classes.named('Apple');
      f1 = c.publicVariableStaticFieldsSorted.first; // n
      f2 = c.instanceFields.wherePublic.first;
      constField = c.constantFields.first; // string
      LongFirstLine = fakeLibrary.classes.named('LongFirstLine');
      CatString = exLibrary.classes.named('CatString');

      UnusualProperties =
          fakeLibrary.classes.named('ClassWithUnusualProperties');
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

      isEmpty = CatString.instanceFields.named('isEmpty');
      dynamicGetter = LongFirstLine.instanceFields.named('dynamicGetter');
      onlySetter = LongFirstLine.instanceFields.named('onlySetter');

      lengthX = fakeLibrary.classes
          .named('WithGetterAndSetter')
          .instanceFields
          .named('lengthX');

      var appleClass = exLibrary.classes.named('Apple');

      sFromApple = appleClass.instanceFields.named('s');
      mFromApple = appleClass.instanceFields.singleWhere((p) => p.name == 'm');

      mInB = exLibrary.classes.named('B').instanceFields.named('m');
      autoCompress =
          exLibrary.classes.named('B').instanceFields.named('autoCompress');
      ExtraSpecialListLength = fakeLibrary.classes
          .named('SpecialList')
          .instanceFields
          .named('length');
      aProperty = fakeLibrary.classes
          .named('AClassWithFancyProperties')
          .instanceFields
          .named('aProperty');
      covariantField = fakeLibrary.classes
          .named('CovariantMemberParams')
          .instanceFields
          .named('covariantField');
      covariantSetter = fakeLibrary.classes
          .named('CovariantMemberParams')
          .instanceFields
          .named('covariantSetter');
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
      expect(covariantField.attributesAsString, contains('covariant'));
      expect(covariantSetter.isCovariant, isTrue);
      expect(covariantSetter.setter!.isCovariant, isTrue);
      expect(covariantSetter.attributesAsString, contains('covariant'));
    });

    test('indentation is not lost inside indented code samples', () {
      expect(
        aProperty.documentation,
        equals(
            'This property is quite fancy, and requires sample code to understand.\n'
            '\n'
            '```dart\n'
            'AClassWithFancyProperties x = AClassWithFancyProperties();\n'
            '\n'
            'if (x.aProperty.contains(\'Hello\')) {\n'
            '  print("I am indented!");\n'
            '  if (x.aProperty.contains(\'World\')) {\n'
            '    print ("I am indented even more!!!");\n'
            '  }\n'
            '}\n'
            '```'),
      );
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
          isNot(contains(Attribute.inheritedSetter)));
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
      expect(implicitGetterExplicitSetter.attributes,
          isNot(contains(Attribute.inherited)));
      expect(implicitGetterExplicitSetter.attributes,
          contains(Attribute.inheritedGetter));
      expect(implicitGetterExplicitSetter.attributes,
          isNot(contains(Attribute.override_)));
      expect(implicitGetterExplicitSetter.attributes,
          contains(Attribute.overrideSetter));
      expect(implicitGetterExplicitSetter.attributes,
          contains(Attribute.getterSetterPair));
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
      expect(explicitGetterImplicitSetter.attributes,
          isNot(contains(Attribute.inherited)));
      expect(explicitGetterImplicitSetter.attributes,
          contains(Attribute.inheritedSetter));
      expect(explicitGetterImplicitSetter.attributes,
          isNot(contains(Attribute.override_)));
      expect(explicitGetterImplicitSetter.attributes,
          contains(Attribute.overrideGetter));
      expect(explicitGetterImplicitSetter.attributes,
          contains(Attribute.getterSetterPair));
      expect(explicitGetterImplicitSetter.oneLineDoc,
          equals('Getter doc for explicitGetterImplicitSetter'));
      // Even though we have some new setter docs, getter still takes priority.
      expect(explicitGetterImplicitSetter.documentation,
          equals('Getter doc for explicitGetterImplicitSetter'));
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
      expect(finalProperty.attributes, contains(Attribute.final_));
      expect(finalProperty.attributes, isNot(contains(Attribute.late_)));
      expect(onlySetter.isFinal, isFalse);
      expect(onlySetter.attributes, isNot(contains(Attribute.final_)));
      expect(onlySetter.attributes, isNot(contains(Attribute.late_)));
      expect(dynamicGetter.isFinal, isFalse);
      expect(dynamicGetter.attributes, isNot(contains(Attribute.final_)));
      expect(dynamicGetter.attributes, isNot(contains(Attribute.late_)));
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
      var withGenericSub = exLibrary.classes.named('WithGenericSub');
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
      var justGetter = fakeLibrary.properties.named('justGetter');
      onlyGetterGetter = justGetter.getter;
      onlyGetterSetter = justGetter.setter;
      var justSetter = fakeLibrary.properties.named('justSetter');
      onlySetterSetter = justSetter.setter;
      onlySetterGetter = justSetter.getter;

      classB = exLibrary.classes.named('B');
    });

    test('always has a valid location', () {
      void expectValidLocation(CharacterLocation location) {
        expect(location.lineNumber, greaterThanOrEqualTo(0));
        expect(location.columnNumber, greaterThanOrEqualTo(0));
      }

      var simpleProperty = fakeLibrary.properties.named('simpleProperty');
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
      var macrosFromAccessors = fakeLibrary.enums.named('MacrosFromAccessors');
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
      final doc = classB.instanceFields.named('s').getter!.documentation;
      expect(doc, equals('The getter for `s`'));
    });

    test(
        'has correct linked return type if the return type is a parameterized typedef',
        () {
      var apple = exLibrary.classes.named('Apple');
      final fieldWithTypedef = apple.instanceFields.named('fieldWithTypedef');
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
      v = exLibrary.properties.named('number');
      v3 = exLibrary.properties.named('y');
      meaningOfLife = fakeLibrary.properties.named('meaningOfLife');
      importantComputations =
          fakeLibrary.properties.named('importantComputations');
      complicatedReturn = fakeLibrary.properties.named('complicatedReturn');
      nodocGetter = fakeLibrary.properties.named('getterSetterNodocGetter');
      nodocSetter = fakeLibrary.properties.named('getterSetterNodocSetter');
      justGetter = fakeLibrary.properties.named('justGetter');
      justSetter = fakeLibrary.properties.named('justSetter');
      setAndGet = fakeLibrary.properties.named('setAndGet');
      mapWithDynamicKeys = fakeLibrary.properties.named('mapWithDynamicKeys');
      genericTypedefCombo = fakeLibrary.properties.named('genericTypedefCombo');
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
      expect(meaningOfLife.attributes, contains(Attribute.final_));
      expect(meaningOfLife.attributes, isNot(contains(Attribute.late_)));
      expect(justGetter.isFinal, isFalse);
      expect(justGetter.attributes, isNot(contains(Attribute.final_)));
      expect(justGetter.attributes, isNot(contains(Attribute.late_)));
      expect(justSetter.isFinal, isFalse);
      expect(justSetter.attributes, isNot(contains(Attribute.final_)));
      expect(justSetter.attributes, isNot(contains(Attribute.late_)));
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
      var nodocSimple = fakeLibrary.properties.wherePublic
          .firstWhereOrNull((p) => p.name == 'simplePropertyHidden');
      expect(nodocSimple, isNull);
    });

    test('@nodoc on both hides both', () {
      var nodocBoth = fakeLibrary.properties.wherePublic
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
      expect(exLibrary.properties.wherePublic, hasLength(7));
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
      greenConstant = exLibrary.constants.named('COLOR_GREEN');
      orangeConstant = exLibrary.constants.named('COLOR_ORANGE');
      prettyColorsConstant = exLibrary.constants.named('PRETTY_COLORS');
      cat = exLibrary.constants.named('MY_CAT');
      deprecated = exLibrary.constants.named('deprecated');
      var Dog = exLibrary.classes.named('Dog');
      customClassPrivate = fakeLibrary.constants.named('CUSTOM_CLASS_PRIVATE');
      aStaticConstField = Dog.constantFields.named('aStaticConstField');
      aName = Dog.constantFields.named('aName');
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

    test('has the correct kind', () {
      expect(greenConstant.kind, equals(Kind.topLevelConstant));
    });

    test('has enclosing element', () {
      expect(greenConstant.enclosingElement.name, equals(exLibrary.name));
    });

    test('found all the constants', () {
      expect(exLibrary.constants.wherePublic, hasLength(9));
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
      apple = exLibrary.classes.named('Apple');
      constCat = exLibrary.classes.named('ConstantCat');
      constructorTester = fakeLibrary.classes.named('ConstructorTester');
      constCatConstructor = constCat.constructors.first;
      appleDefaultConstructor = apple.constructors.named('Apple');
      appleConstructorFromString = apple.constructors.named('Apple.fromString');
      constructorTesterDefault =
          constructorTester.constructors.named('ConstructorTester');
      constructorTesterFromSomething = constructorTester.constructors
          .named('ConstructorTester.fromSomething');
      referToADefaultConstructor =
          fakeLibrary.classes.named('ReferToADefaultConstructor');
      withSyntheticConstructor =
          exLibrary.classes.named('WithSyntheticConstructor');
      syntheticConstructor = withSyntheticConstructor.constructors
          .firstWhere((c) => c.isUnnamedConstructor);
    });

    test('calculates comment references to classes vs. constructors correctly',
        () {
      expect(
        referToADefaultConstructor.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ReferToADefaultConstructor-class.html">'
            'ReferToADefaultConstructor</a>'),
      );
      expect(
        referToADefaultConstructor.documentationAsHtml,
        contains(
            '<a href="${htmlBasePlaceholder}fake/ReferToADefaultConstructor/ReferToADefaultConstructor.html">'
            'ReferToADefaultConstructor.new</a>'),
      );
    });

    test('displays generic parameters correctly', () {
      expect(constructorTesterDefault.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;');
      expect(constructorTesterFromSomething.nameWithGenerics,
          'ConstructorTester&lt;<wbr><span class="type-parameter">A</span>, <span class="type-parameter">B</span>&gt;.fromSomething');
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
      returningFutureVoid = fakeLibrary.functions.named('returningFutureVoid');
      aVoidParameter = fakeLibrary.functions.named('aVoidParameter');
      ExtendsFutureVoid = fakeLibrary.classes.named('ExtendsFutureVoid');
      ImplementsFutureVoid = fakeLibrary.classes.named('ImplementsFutureVoid');
      ATypeTakingClassMixedIn =
          fakeLibrary.classes.named('ATypeTakingClassMixedIn');
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
              showMetadata: true),
          equals(
              '<span class="parameter" id="aVoidParameter-param-p1"><span class="type-annotation">Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span></span> <span class="parameter-name">p1</span></span>'));
    });

    test('a class that extends Future<void>', () {
      expect(
          ExtendsFutureVoid.linkedName,
          equals(
              '<a href="${htmlBasePlaceholder}fake/ExtendsFutureVoid-class.html">ExtendsFutureVoid</a>'));
      var FutureVoid = ExtendsFutureVoid.superChain.wherePublic
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
          '<a href="${htmlBasePlaceholder}fake/ImplementsFutureVoid-class.html">ImplementsFutureVoid</a>',
        ),
      );
      var FutureVoid = ImplementsFutureVoid.directInterfaces
          .firstWhere((e) => e.name == 'Future');
      expect(
        FutureVoid.linkedName,
        equals(
          'Future<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>',
        ),
      );
    });

    test('Verify that a mixin with a void type parameter works', () {
      expect(
        ATypeTakingClassMixedIn.linkedName,
        equals(
          '<a href="${htmlBasePlaceholder}fake/ATypeTakingClassMixedIn-class.html">ATypeTakingClassMixedIn</a>',
        ),
      );
      var ATypeTakingClassVoid = ATypeTakingClassMixedIn.mixedInTypes
          .firstWhere((e) => e.name == 'ATypeTakingClass');
      expect(
        ATypeTakingClassVoid.linkedName,
        equals(
          '<a href="${htmlBasePlaceholder}fake/ATypeTakingClass-class.html">ATypeTakingClass</a>'
          '<span class="signature">&lt;<wbr><span class="type-parameter">void</span>&gt;</span>',
        ),
      );
    });
  });

  group('ModelType', () {
    late final Field fList;

    setUpAll(() {
      fList = exLibrary.classes
          .named('B')
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
      processMessage =
          exLibrary.typedefs.named('processMessage') as FunctionTypedef;
      oldgeneric =
          fakeLibrary.typedefs.named('GenericTypedef') as FunctionTypedef;
      generic =
          fakeLibrary.typedefs.named('NewGenericTypedef') as FunctionTypedef;

      aComplexTypedef =
          exLibrary.typedefs.named('aComplexTypedef') as FunctionTypedef;
      TypedefUsingClass = fakeLibrary.classes.named('TypedefUsingClass');
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
        '<ol class="parameter-list single-line"> '
        '<li><span class="parameter" id="param-"><span class="type-annotation">A3</span>, </span></li>\n'
        '<li><span class="parameter" id="param-"><span class="type-annotation">String</span></span></li>\n'
        '</ol>',
      );
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

    test('TypedefRenderer renders genericParameters', () {
      expect(processMessage.genericParameters,
          equals('&lt;<wbr><span class="type-parameter">T</span>&gt;'));
      expect(generic.genericParameters,
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
      c = exLibrary.classes.named('Apple');
      CovariantMemberParams =
          fakeLibrary.classes.named('CovariantMemberParams');
      applyCovariantParams =
          CovariantMemberParams.instanceMethods.named('applyCovariantParams');
      paramFromExportLib =
          c.instanceMethods.singleWhere((m) => m.name == 'paramFromExportLib');
      isGreaterThan =
          c.instanceMethods.singleWhere((m) => m.name == 'isGreaterThan');
      asyncM = exLibrary.classes.named('Dog').instanceMethods.named('foo');
      intNumber = isGreaterThan.parameters.first;
      intCheckOptional = isGreaterThan.parameters.last;
      fClass = exLibrary.classes.named('F');
      methodWithGenericParam = fClass.instanceMethods
          .singleWhere((m) => m.name == 'methodWithGenericParam');
      methodWithTypedefParam = c.instanceMethods
          .singleWhere((m) => m.name == 'methodWithTypedefParam');
      doAComplicatedThing =
          fakeLibrary.functions.wherePublic.named('doAComplicatedThing');
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
      var method = fakeLibrary.functions.named('paintImage1');
      var params =
          ParameterRendererHtml().renderLinkedParams(method.parameters);
      expect(params, contains(', </span>'));
    });

    test('param with annotations', () {
      var method = fakeLibrary.functions.named('paintImage2');
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
    test(
        'private classes in internal libraries do not break the implementor chain',
        () {
      var GenericSuperProperty =
          fakeLibrary.classes.named('GenericSuperProperty');
      var publicImplementors =
          GenericSuperProperty.publicImplementersSorted.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      // A direct implementor.
      expect(publicImplementors, contains('GenericSuperValue'));

      var GenericSuperValue = fakeLibrary.classes.named('GenericSuperValue');
      publicImplementors =
          GenericSuperValue.publicImplementersSorted.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      // A direct implementor.
      expect(publicImplementors, contains('GenericSuperNum'));

      var GenericSuperNum = fakeLibrary.classes.named('GenericSuperNum');
      publicImplementors =
          GenericSuperNum.publicImplementersSorted.map((i) => i.name);
      expect(publicImplementors, hasLength(1));
      expect(publicImplementors, contains('GenericSuperInt'));
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
      EscapableProperties =
          fakeLibrary.classes.named('HtmlEscapableProperties');
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
      var a = StringName(names[i - 1], packageGraph);
      var b = StringName(names[i], packageGraph);
      test('"$a" < "$b"', () {
        expect(byName(a, a), 0);
        expect(byName(b, b), 0);
        expect(byName(a, b), -1);
        expect(byName(b, a), 1);
      });
    }

    test('sort order is stable when necessary', () {
      var a = StringNameHashCode('a', 12, packageGraph);
      var b = StringNameHashCode('b', 12, packageGraph);
      var aa = StringNameHashCode('a', 14, packageGraph);
      expect(byName(a, aa), -1);
      expect(byName(a, b), -1);
      expect(byName(b, a), 1);
      expect(byName(aa, b), -1);
    });
  });
}

class StringName with Nameable {
  @override
  final String name;

  @override
  PackageGraph packageGraph;

  StringName(this.name, this.packageGraph);

  @override
  String toString() => name;
}

class StringNameHashCode with Nameable {
  @override
  final String name;

  @override
  final int hashCode;

  @override
  PackageGraph packageGraph;

  StringNameHashCode(this.name, this.hashCode, this.packageGraph);

  @override
  String toString() => name;

  @override
  // ignore: unnecessary_overrides
  bool operator ==(Object other) => super == other;
}

extension on Library {
  Class getClassByName(String name) => classes.named(name);
}
