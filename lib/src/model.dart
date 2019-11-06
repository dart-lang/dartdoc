// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:async';
import 'dart:collection' show UnmodifiableListView;
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/session.dart';
import 'package:analyzer/dart/ast/ast.dart'
    show
        AnnotatedNode,
        AstNode,
        CommentReference,
        CompilationUnit,
        Expression,
        InstanceCreationExpression;
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_system.dart';
import 'package:analyzer/dart/element/visitor.dart';
import 'package:analyzer/file_system/file_system.dart' as file_system;
import 'package:analyzer/file_system/physical_file_system.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/context/builder.dart';
import 'package:analyzer/src/dart/analysis/byte_store.dart';
import 'package:analyzer/src/dart/analysis/driver.dart';
import 'package:analyzer/src/dart/analysis/file_state.dart';
import 'package:analyzer/src/dart/analysis/performance_logger.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/inheritance_manager3.dart';
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, Member, ParameterMember;
import 'package:analyzer/src/dart/element/type.dart' show InterfaceTypeImpl;
import 'package:analyzer/src/dart/sdk/sdk.dart';
import 'package:analyzer/src/generated/engine.dart';
import 'package:analyzer/src/generated/java_io.dart';
import 'package:analyzer/src/generated/sdk.dart';
import 'package:analyzer/src/generated/source.dart';
import 'package:analyzer/src/generated/source_io.dart';
import 'package:analyzer/src/generated/type_system.dart' show Dart2TypeSystem;
import 'package:analyzer/src/source/package_map_resolver.dart';
import 'package:analyzer/src/source/sdk_ext.dart';
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/markdown_processor.dart' show Documentation;
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/package_meta.dart' show PackageMeta, FileContents;
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/special_elements.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:package_config/discovery.dart' as package_config;
import 'package:path/path.dart' as path;
import 'package:pub_semver/pub_semver.dart';
import 'package:quiver/iterables.dart' as quiver;

int byName(Nameable a, Nameable b) =>
    compareAsciiLowerCaseNatural(a.name, b.name);

/// Items mapped less than zero will sort before custom annotations.
/// Items mapped above zero are sorted after custom annotations.
/// Items mapped to zero will sort alphabetically among custom annotations.
/// Custom annotations are assumed to be any annotation or feature not in this
/// map.
const Map<String, int> featureOrder = {
  'read-only': 1,
  'write-only': 1,
  'read / write': 1,
  'covariant': 2,
  'final': 2,
  'inherited': 3,
  'inherited-getter': 3,
  'inherited-setter': 3,
  'override': 3,
  'override-getter': 3,
  'override-setter': 3,
  'extended': 3,
};

int byFeatureOrdering(String a, String b) {
  int scoreA = 0;
  int scoreB = 0;

  if (featureOrder.containsKey(a)) scoreA = featureOrder[a];
  if (featureOrder.containsKey(b)) scoreB = featureOrder[b];

  if (scoreA < scoreB) return -1;
  if (scoreA > scoreB) return 1;
  return compareAsciiLowerCaseNatural(a, b);
}

final RegExp locationSplitter = RegExp(r'(package:|[\\/;.])');
final RegExp substituteNameVersion = RegExp(r'%([bnv])%');

/// This doc may need to be processed in case it has a template or html
/// fragment.
final needsPrecacheRegExp = RegExp(r'{@(template|tool|inject-html)');

final templateRegExp = RegExp(
    r'[ ]*{@template\s+(.+?)}([\s\S]+?){@endtemplate}[ ]*\n?',
    multiLine: true);
final htmlRegExp = RegExp(
    r'[ ]*{@inject-html\s*}([\s\S]+?){@end-inject-html}[ ]*\n?',
    multiLine: true);
final htmlInjectRegExp = RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>');

// Matches all tool directives (even some invalid ones). This is so
// we can give good error messages if the directive is malformed, instead of
// just silently emitting it as-is.
final basicToolRegExp = RegExp(
    r'[ ]*{@tool\s+([^}]+)}\n?([\s\S]+?)\n?{@end-tool}[ ]*\n?',
    multiLine: true);

/// Regexp to take care of splitting arguments, and handling the quotes
/// around arguments, if any.
///
/// Match group 1 is the "foo=" (or "--foo=") part of the option, if any.
/// Match group 2 contains the quote character used (which is discarded).
/// Match group 3 is a quoted arg, if any, without the quotes.
/// Match group 4 is the unquoted arg, if any.
final RegExp argMatcher = RegExp(r'([a-zA-Z\-_0-9]+=)?' // option name
    r'(?:' // Start a new non-capture group for the two possibilities.
    r'''(["'])((?:\\{2})*|(?:.*?[^\\](?:\\{2})*))\2|''' // with quotes.
    r'([^ ]+))'); // without quotes.

final categoryRegexp = RegExp(
    r'[ ]*{@(api|category|subCategory|image|samples) (.+?)}[ ]*\n?',
    multiLine: true);
final macroRegExp = RegExp(r'{@macro\s+([^}]+)}');

/// Mixin for subclasses of [ModelElement] representing Elements that can be
/// extension methods.
mixin Extendable on ContainerMember {
  /// Returns this Extendable from the [Extension] in which it was declared.
  Extendable get definingExtension => throw UnimplementedError;

  @override
  Container get canonicalEnclosingContainer => throw UnimplementedError;
}

/// A [ModelElement] that is a [Container] member.
mixin ContainerMember on ModelElement implements EnclosedElement {
  /// True if this [ContainerMember] is inherited from a different class.
  bool get isInherited;

  /// True if this [ContainerMember] is overriding a superclass.
  bool get isOverride;

  /// True if this [ContainerMember] has a parameter whose type is overridden
  /// by a subtype.
  bool get isCovariant;

  /// True if this [ContainerMember] is from an applicable [Extension].
  /// False otherwise, including if this [ContainerMember]'s [enclosingElement]
  /// is the extension it was declared in.
  // TODO(jcollins-g): This semantic is a little confusing, because a declared
  // extension member element returns false.  The rationale is an
  // extension member is not extending itself.
  // FIXME(jcollins-g): Remove concrete implementation after [Extendable] is
  // implemented.
  bool get isExtended => false;

  Container _definingEnclosingContainer;
  Container get definingEnclosingContainer {
    if (_definingEnclosingContainer == null) {
      _definingEnclosingContainer =
          ModelElement.fromElement(element.enclosingElement, packageGraph);
    }
    return _definingEnclosingContainer;
  }

  @override
  Set<String> get features {
    Set<String> _features = super.features;
    if (isOverride) _features.add('override');
    if (isInherited) _features.add('inherited');
    if (isCovariant) _features.add('covariant');
    if (isExtended) _features.add('extended');
    return _features;
  }

  bool _canonicalEnclosingContainerIsSet = false;
  Container _canonicalEnclosingContainer;
  Container get canonicalEnclosingContainer {
    if (!_canonicalEnclosingContainerIsSet) {
      // TODO(jcollins-g): move Extension specific code to [Extendable]
      if (enclosingElement is! Extension ||
          (enclosingElement is Extension && enclosingElement.isDocumented)) {
        _canonicalEnclosingContainer =
            packageGraph.findCanonicalModelElementFor(enclosingElement.element);
      }
      _canonicalEnclosingContainerIsSet = true;
      assert(_canonicalEnclosingContainer == null ||
          _canonicalEnclosingContainer.isDocumented);
    }
    assert(_canonicalEnclosingContainer == null ||
        (_canonicalEnclosingContainer.isDocumented));
    return _canonicalEnclosingContainer;
  }
}

/// Mixin for subclasses of ModelElement representing Elements that can be
/// inherited from one class to another.
///
/// We can search the inheritance chain between this instance and
/// [definingEnclosingContainer] in [Inheritable.canonicalEnclosingContainer],
/// for the canonical [Class] closest to where this member was defined.  We
/// can then know that when we find [Inheritable.element] inside that [Class]'s
/// namespace, that's the one we should treat as canonical and implementors
/// of this class can use that knowledge to determine canonicalization.
///
/// We pick the class closest to the [definingEnclosingElement] so that all
/// children of that class inheriting the same member will point to the same
/// place in the documentation, and we pick a canonical class because that's
/// the one in the public namespace that will be documented.
mixin Inheritable on ContainerMember {
  @override
  ModelElement _buildCanonicalModelElement() {
    if (canonicalEnclosingContainer is Extension) {
      return this;
    }
    if (canonicalEnclosingContainer is Class) {
      return (canonicalEnclosingContainer as Class)
          ?.allCanonicalModelElements
          ?.firstWhere(
              (m) =>
                  m.name == name && m.isPropertyAccessor == isPropertyAccessor,
              orElse: () => null);
    }
    return null;
  }

  @override
  Container get canonicalEnclosingContainer {
    Element searchElement = element;
    if (!_canonicalEnclosingContainerIsSet) {
      if (isInherited) {
        searchElement = searchElement is Member
            ? PackageGraph.getBasestElement(searchElement)
            : searchElement;
        // TODO(jcollins-g): generate warning if an inherited element's definition
        // is in an intermediate non-canonical class in the inheritance chain?
        Class previous;
        Class previousNonSkippable;
        for (Class c in inheritance.reversed) {
          // Filter out mixins.
          if (c.contains(searchElement)) {
            if ((packageGraph.inheritThrough.contains(previous) &&
                    c != definingEnclosingContainer) ||
                (packageGraph.inheritThrough.contains(c) &&
                    c == definingEnclosingContainer)) {
              return (previousNonSkippable.memberByExample(this) as Inheritable)
                  .canonicalEnclosingContainer;
            }
            Class canonicalC =
                packageGraph.findCanonicalModelElementFor(c.element);
            // TODO(jcollins-g): invert this lookup so traversal is recursive
            // starting from the ModelElement.
            if (canonicalC != null) {
              assert(canonicalC.isCanonical);
              assert(canonicalC.contains(searchElement));
              _canonicalEnclosingContainer = canonicalC;
              break;
            }
          }
          previous = c;
          if (!packageGraph.inheritThrough.contains(c)) {
            previousNonSkippable = c;
          }
        }
        // This is still OK because we're never supposed to cloak public
        // classes.
        if (definingEnclosingContainer.isCanonical &&
            definingEnclosingContainer.isPublic) {
          assert(definingEnclosingContainer == _canonicalEnclosingContainer);
        }
        _canonicalEnclosingContainerIsSet = true;
        assert(_canonicalEnclosingContainer == null ||
            _canonicalEnclosingContainer.isDocumented);
      }
    }
    return super.canonicalEnclosingContainer;
  }

  List<Class> get inheritance {
    List<Class> inheritance = [];
    inheritance.addAll((enclosingElement as Class).inheritanceChain);
    Class object = packageGraph.specialClasses[SpecialClass.object];
    if (!inheritance.contains(definingEnclosingContainer) &&
        definingEnclosingContainer != null) {
      assert(definingEnclosingContainer == object);
    }
    // Unless the code explicitly extends dart-core's Object, we won't get
    // an entry here.  So add it.
    if (inheritance.last != object && object != null) {
      inheritance.add(object);
    }
    assert(inheritance.where((e) => e == object).length == 1);
    return inheritance;
  }

  Inheritable get overriddenElement;

  bool _isOverride;

  @override
  bool get isOverride {
    if (_isOverride == null) {
      // The canonical version of the enclosing element -- not canonicalEnclosingElement,
      // as that is the element enclosing the canonical version of this element,
      // two different things.  Defaults to the enclosing element.
      //
      // We use canonical elements here where possible to deal with reexports
      // as seen in Flutter.
      if (enclosingElement is Extension) {
        _isOverride = false;
        return _isOverride;
      }
      Class enclosingCanonical = enclosingElement.canonicalModelElement;
      // The container in which this element was defined, canonical if available.
      Container definingCanonical =
          definingEnclosingContainer.canonicalModelElement ??
              definingEnclosingContainer;
      // The canonical version of the element we're overriding, if available.
      ModelElement overriddenCanonical =
          overriddenElement?.canonicalModelElement ?? overriddenElement;

      // We have to have an overridden element for it to be possible for this
      // element to be an override.
      _isOverride = overriddenElement != null &&
          // The defining class and the enclosing class for this element
          // must be the same (element is defined here).
          enclosingCanonical == definingCanonical &&
          // If the overridden element isn't public, we shouldn't be an
          // override in most cases.  Approximation until #1623 is fixed.
          overriddenCanonical.isPublic;
      assert(!(_isOverride && isInherited));
    }
    return _isOverride;
  }

  int _overriddenDepth;
  @override
  int get overriddenDepth {
    if (_overriddenDepth == null) {
      _overriddenDepth = 0;
      Inheritable e = this;
      while (e.overriddenElement != null) {
        _overriddenDepth += 1;
        e = e.overriddenElement;
      }
    }
    return _overriddenDepth;
  }
}

/// A getter or setter that is a member of a [Container].
class ContainerAccessor extends Accessor with ContainerMember, Inheritable {
  /// Factory will return an [ContainerAccessor] with isInherited = true
  /// if [element] is in [inheritedAccessors].
  factory ContainerAccessor.from(PropertyAccessorElement element,
      Set<PropertyAccessorElement> inheritedAccessors, Class enclosingClass) {
    ContainerAccessor accessor;
    if (element == null) return null;
    if (inheritedAccessors.contains(element)) {
      accessor = ModelElement.from(
          element, enclosingClass.library, enclosingClass.packageGraph,
          enclosingContainer: enclosingClass);
    } else {
      accessor = ModelElement.from(
          element, enclosingClass.library, enclosingClass.packageGraph);
    }
    return accessor;
  }

  ModelElement _enclosingElement;
  bool _isInherited = false;

  @override
  bool get isCovariant => isSetter && parameters.first.isCovariant;

  ContainerAccessor(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  ContainerAccessor.inherited(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph, this._enclosingElement,
      {Member originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  Container get enclosingElement {
    if (_enclosingElement == null) {
      _enclosingElement = super.enclosingElement;
    }
    return _enclosingElement;
  }

  bool _overriddenElementIsSet = false;
  ModelElement _overriddenElement;

  @override
  ContainerAccessor get overriddenElement {
    assert(packageGraph.allLibrariesAdded);
    if (!_overriddenElementIsSet) {
      _overriddenElementIsSet = true;
      Element parent = element.enclosingElement;
      if (parent is ClassElement) {
        for (InterfaceType t in parent.allSupertypes) {
          Element accessor = this.isGetter
              ? t.getGetter(element.name)
              : t.getSetter(element.name);
          if (accessor != null) {
            if (accessor is Member) {
              accessor = PackageGraph.getBasestElement(accessor);
            }
            Class parentClass =
                ModelElement.fromElement(t.element, packageGraph);
            List<Field> possibleFields = [];
            possibleFields.addAll(parentClass.allInstanceFields);
            possibleFields.addAll(parentClass.staticProperties);
            String fieldName = accessor.name.replaceFirst('=', '');
            Field foundField = possibleFields.firstWhere(
                (f) => f.element.name == fieldName,
                orElse: () => null);
            if (foundField != null) {
              if (this.isGetter) {
                _overriddenElement = foundField.getter;
              } else {
                _overriddenElement = foundField.setter;
              }
              assert(!(_overriddenElement as ContainerAccessor).isInherited);
              break;
            }
          }
        }
      }
    }
    return _overriddenElement;
  }
}

/// Getters and setters.
class Accessor extends ModelElement implements EnclosedElement {
  GetterSetterCombo _enclosingCombo;

  Accessor(PropertyAccessorElement element, Library library,
      PackageGraph packageGraph, Member originalMember)
      : super(element, library, packageGraph, originalMember);

  String get linkedReturnType {
    assert(isGetter);
    return modelType.createLinkedReturnTypeName();
  }

  GetterSetterCombo get enclosingCombo {
    assert(_enclosingCombo != null);
    return _enclosingCombo;
  }

  bool get isSynthetic => element.isSynthetic;

  @override
  String get sourceCode {
    if (_sourceCode == null) {
      if (isSynthetic) {
        _sourceCode = packageGraph
            ._getModelNodeFor((element as PropertyAccessorElement).variable)
            .sourceCode;
      } else {
        _sourceCode = super.sourceCode;
      }
    }
    return _sourceCode;
  }

  @override
  List<ModelElement> get computeDocumentationFrom {
    return super.computeDocumentationFrom;
  }

  @override
  String _computeDocumentationComment() {
    if (isSynthetic) {
      String docComment =
          (element as PropertyAccessorElement).variable.documentationComment;
      // If we're a setter, only display something if we have something different than the getter.
      // TODO(jcollins-g): modify analyzer to do this itself?
      if (isGetter ||
          // TODO(jcollins-g): @nodoc reading from comments is at the wrong abstraction level here.
          (docComment != null &&
              (docComment.contains('<nodoc>') ||
                  docComment.contains('@nodoc'))) ||
          (isSetter &&
              enclosingCombo.hasGetter &&
              enclosingCombo.getter.documentationComment != docComment)) {
        return stripComments(docComment);
      } else {
        return '';
      }
    }
    return stripComments(super._computeDocumentationComment());
  }

  @override
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    enclosingCombo.warn(kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  @override
  ModelElement get enclosingElement {
    if (_accessor.enclosingElement is CompilationUnitElement) {
      return packageGraph.findButDoNotCreateLibraryFor(
          _accessor.enclosingElement.enclosingElement);
    }

    return ModelElement.from(_accessor.enclosingElement, library, packageGraph);
  }

  @override
  bool get isCanonical => enclosingCombo.isCanonical;

  @override
  String get href {
    return enclosingCombo.href;
  }

  bool get isGetter => _accessor.isGetter;

  bool get isSetter => _accessor.isSetter;

  @override
  String get kind => 'accessor';

  @override
  String get namePart {
    if (_namePart == null) {
      _namePart = super.namePart.split('=').first;
    }
    return _namePart;
  }

  PropertyAccessorElement get _accessor => (element as PropertyAccessorElement);
}

/// Implements the Dart 2.1 "mixin" style of mixin declarations.
class Mixin extends Class {
  Mixin(ClassElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  bool get isAbstract => false;

  @override
  List<Class> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain.add(this);

      // Mix-in interfaces come before other interfaces.
      _inheritanceChain.addAll(superclassConstraints
          .expand((ParameterizedElementType i) =>
              (i.element as Class).inheritanceChain)
          .where((Class c) =>
              c != packageGraph.specialClasses[SpecialClass.object]));

      // Interfaces need to come last, because classes in the superChain might
      // implement them even when they aren't mentioned.
      _inheritanceChain.addAll(
          interfaces.expand((e) => (e.element as Class).inheritanceChain));
    }
    return _inheritanceChain.toList(growable: false);
  }

  List<ParameterizedElementType> _superclassConstraints;

  /// Returns a list of superclass constraints for this mixin.
  Iterable<ParameterizedElementType> get superclassConstraints {
    if (_superclassConstraints == null) {
      _superclassConstraints = (element as ClassElement)
          .superclassConstraints
          .map<ParameterizedElementType>(
              (InterfaceType i) => ElementType.from(i, library, packageGraph))
          .toList();
    }
    return _superclassConstraints;
  }

  bool get hasPublicSuperclassConstraints =>
      publicSuperclassConstraints.isNotEmpty;

  Iterable<ParameterizedElementType> get publicSuperclassConstraints =>
      utils.filterNonPublic(superclassConstraints);

  @override
  bool get hasModifiers => super.hasModifiers || hasPublicSuperclassConstraints;

  @override
  String get fileName => "${name}-mixin.html";

  @override
  String get kind => 'mixin';
}

// Can be either a Class or Extension, used in the package graph and template data.
// Aggregates some of the common getters.
abstract class Container extends ModelElement {
  List<Method> _allMethods;
  List<Field> _constants;
  List<Operator> _operators;
  List<Method> _staticMethods;
  List<Method> _instanceMethods;
  List<Field> _fields;
  List<Field> _staticFields;
  List<Field> _instanceFields;
  List<TypeParameter> _typeParameters;

  Container(Element element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  bool get isClass => element is ClassElement;

  bool get isExtension => element is ExtensionElement;

  List<Method> get _methods => _allMethods;

  List<Method> get instanceMethods {
    if (_instanceMethods != null) return _instanceMethods;

    _instanceMethods = _methods
        .where((m) => !m.isStatic && !m.isOperator)
        .toList(growable: false)
          ..sort(byName);
    return _instanceMethods;
  }

  bool get hasPublicMethods =>
      utils.filterNonPublic(instanceMethods).isNotEmpty;

  Iterable<Method> get allPublicInstanceMethods =>
      utils.filterNonPublic(instanceMethods);

  List<Method> get staticMethods {
    if (_staticMethods != null) return _staticMethods;

    _staticMethods = _methods.where((m) => m.isStatic).toList(growable: false)
      ..sort(byName);

    return _staticMethods;
  }

  bool get hasPublicStaticMethods =>
      utils.filterNonPublic(staticMethods).isNotEmpty;

  Iterable<Method> get publicStaticMethods =>
      utils.filterNonPublic(staticMethods);

  List<Operator> get operators {
    if (_operators != null) return _operators;
    _operators = _methods
        .where((m) => m.isOperator)
        .cast<Operator>()
        .toList(growable: false)
          ..sort(byName);
    return _operators;
  }

  Iterable<Operator> get allOperators => operators;

  bool get hasPublicOperators => publicOperators.isNotEmpty;

  Iterable<Operator> get allPublicOperators =>
      utils.filterNonPublic(allOperators);

  Iterable<Operator> get publicOperators => utils.filterNonPublic(operators);

  List<Field> get _allFields => [];

  List<Field> get staticProperties {
    if (_staticFields != null) return _staticFields;
    _staticFields = _allFields
        .where((f) => f.isStatic && !f.isConst)
        .toList(growable: false)
          ..sort(byName);

    return _staticFields;
  }

  Iterable<Field> get publicStaticProperties =>
      utils.filterNonPublic(staticProperties);

  bool get hasPublicStaticProperties => publicStaticProperties.isNotEmpty;

  List<Field> get instanceProperties {
    if (_instanceFields != null) return _instanceFields;
    _instanceFields = _allFields
        .where((f) => !f.isStatic && !f.isInherited && !f.isConst)
        .toList(growable: false)
          ..sort(byName);

    return _instanceFields;
  }

  Iterable<Field> get publicInstanceProperties =>
      utils.filterNonPublic(instanceProperties);

  bool get hasPublicProperties => publicInstanceProperties.isNotEmpty;

  Iterable<Field> get allInstanceFields => instanceProperties;

  Iterable<Field> get allPublicInstanceProperties =>
      utils.filterNonPublic(allInstanceFields);

  bool isInheritingFrom(Container other) => false;

  List<Field> get constants {
    if (_constants != null) return _constants;
    _constants = _allFields.where((f) => f.isConst).toList(growable: false)
      ..sort(byName);

    return _constants;
  }

  Iterable<Field> get publicConstants => utils.filterNonPublic(constants);

  bool get hasPublicConstants => publicConstants.isNotEmpty;

  Iterable<Accessor> get allAccessors => quiver.concat([
        allInstanceFields.expand((f) => f.allAccessors),
        constants.map((c) => c.getter)
      ]);
}

class Class extends Container
    with TypeParameters, Categorization
    implements EnclosedElement {
  List<DefinedElementType> _mixins;
  DefinedElementType supertype;
  List<DefinedElementType> _interfaces;
  List<Constructor> _constructors;
  List<Operator> _inheritedOperators;
  List<Method> _inheritedMethods;
  List<Field> _inheritedProperties;

  Class(ClassElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    packageGraph.specialClasses.addSpecial(this);
    _mixins = _cls.mixins
        .map((f) {
          DefinedElementType t = ElementType.from(f, library, packageGraph);
          return t;
        })
        .where((mixin) => mixin != null)
        .toList(growable: false);

    if (_cls.supertype != null && _cls.supertype.element.supertype != null) {
      supertype = ElementType.from(_cls.supertype, library, packageGraph);
    }

    _interfaces = _cls.interfaces
        .map((f) =>
            ElementType.from(f, library, packageGraph) as DefinedElementType)
        .toList(growable: false);
  }

  Constructor _defaultConstructor;

  Constructor get defaultConstructor {
    if (_defaultConstructor == null) {
      _defaultConstructor = constructors
          .firstWhere((c) => c.isDefaultConstructor, orElse: () => null);
    }
    return _defaultConstructor;
  }

  bool get hasPotentiallyApplicableExtensions =>
      potentiallyApplicableExtensions.isNotEmpty;

  List<Extension> _potentiallyApplicableExtensions;
  Iterable<Extension> get potentiallyApplicableExtensions {
    if (_potentiallyApplicableExtensions == null) {
      _potentiallyApplicableExtensions = utils
          .filterNonDocumented(packageGraph.extensions)
          .where((e) => e.couldApplyTo(this))
          .toList(growable: false);
    }
    return _potentiallyApplicableExtensions;
  }

  Iterable<Method> get allInstanceMethods =>
      quiver.concat([instanceMethods, inheritedMethods]);

  @override
  Iterable<Method> get allPublicInstanceMethods =>
      utils.filterNonPublic(allInstanceMethods);

  bool get allPublicInstanceMethodsInherited =>
      instanceMethods.every((f) => f.isInherited);

  @override
  Iterable<Field> get allInstanceFields =>
      quiver.concat([instanceProperties, inheritedProperties]);

  bool get allPublicInstancePropertiesInherited =>
      allPublicInstanceProperties.every((f) => f.isInherited);

  @override
  Iterable<Operator> get allOperators =>
      quiver.concat([operators, inheritedOperators]);

  bool get allPublicOperatorsInherited =>
      allPublicOperators.every((f) => f.isInherited);

  Map<Element, ModelElement> _allElements;

  Map<Element, ModelElement> get allElements {
    if (_allElements == null) {
      _allElements = Map();
      for (ModelElement me in allModelElements) {
        assert(!_allElements.containsKey(me.element));
        _allElements[me.element] = me;
      }
    }
    return _allElements;
  }

  Map<String, List<ModelElement>> _allModelElementsByNamePart;

  /// Helper for [_MarkdownCommentReference._getResultsForClass].
  Map<String, List<ModelElement>> get allModelElementsByNamePart {
    if (_allModelElementsByNamePart == null) {
      _allModelElementsByNamePart = {};
      for (ModelElement me in allModelElements) {
        _allModelElementsByNamePart.update(
            me.namePart, (List<ModelElement> v) => v..add(me),
            ifAbsent: () => <ModelElement>[me]);
      }
    }
    return _allModelElementsByNamePart;
  }

  /// This class might be canonical for elements it does not contain.
  /// See [Inheritable.canonicalEnclosingContainer].
  bool contains(Element element) => allElements.containsKey(element);

  Map<String, List<ModelElement>> _membersByName;

  /// Given a ModelElement that is a member of some other class, return
  /// a member of this class that has the same name and return type.
  ///
  /// This enables object substitution for canonicalization, such as Interceptor
  /// for Object.
  ModelElement memberByExample(ModelElement example) {
    if (_membersByName == null) {
      _membersByName = Map();
      for (ModelElement me in allModelElements) {
        if (!_membersByName.containsKey(me.name)) {
          _membersByName[me.name] = List();
        }
        _membersByName[me.name].add(me);
      }
    }
    ModelElement member;
    Iterable<ModelElement> possibleMembers = _membersByName[example.name]
        .where((e) => e.runtimeType == example.runtimeType);
    if (example.runtimeType == Accessor) {
      possibleMembers = possibleMembers.where(
          (e) => (example as Accessor).isGetter == (e as Accessor).isGetter);
    }
    member = possibleMembers.first;
    assert(possibleMembers.length == 1);
    return member;
  }

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = List.from(
          quiver.concat([
            allInstanceMethods,
            allInstanceFields,
            allAccessors,
            allOperators,
            constants,
            constructors,
            staticMethods,
            staticProperties,
            typeParameters,
          ]),
          growable: false);
    }
    return _allModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;

  List<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }

  List<Constructor> get constructors {
    if (_constructors != null) return _constructors;

    _constructors = _cls.constructors.map((e) {
      return ModelElement.from(e, library, packageGraph) as Constructor;
    }).toList(growable: true)
      ..sort(byName);

    return _constructors;
  }

  Iterable<Constructor> get publicConstructors =>
      utils.filterNonPublic(constructors);

  /// Returns the library that encloses this element.
  @override
  ModelElement get enclosingElement => library;

  @override
  String get fileName => "${name}-class.html";

  String get fullkind {
    if (isAbstract) return 'abstract $kind';
    return kind;
  }

  bool get hasPublicConstructors => publicConstructors.isNotEmpty;

  bool get hasPublicImplementors => publicImplementors.isNotEmpty;

  bool get hasInstanceProperties => instanceProperties.isNotEmpty;

  bool get hasPublicInterfaces => publicInterfaces.isNotEmpty;

  @override
  bool get hasPublicMethods =>
      publicInstanceMethods.isNotEmpty || publicInheritedMethods.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  bool get hasModifiers =>
      hasPublicMixins ||
      hasAnnotations ||
      hasPublicInterfaces ||
      hasPublicSuperChainReversed ||
      hasPublicImplementors ||
      hasPotentiallyApplicableExtensions;

  @override
  bool get hasPublicOperators =>
      publicOperators.isNotEmpty || publicInheritedOperators.isNotEmpty;

  @override
  bool get hasPublicProperties =>
      publicInheritedProperties.isNotEmpty ||
      publicInstanceProperties.isNotEmpty;

  @override
  bool get hasPublicStaticMethods => publicStaticMethods.isNotEmpty;

  bool get hasPublicSuperChainReversed => publicSuperChainReversed.isNotEmpty;

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${library.dirName}/$fileName';
  }

  /// Returns all the implementors of this class.
  Iterable<Class> get publicImplementors {
    return utils.filterNonPublic(utils.findCanonicalFor(
        packageGraph.implementors[href] != null
            ? packageGraph.implementors[href]
            : []));
  }

  List<Method> get inheritedMethods {
    if (_inheritedMethods == null) {
      _inheritedMethods = <Method>[];
      Set<String> methodNames = _methods.map((m) => m.element.name).toSet();

      Set<ExecutableElement> inheritedMethodElements =
          _inheritedElements.where((e) {
        return (e is MethodElement &&
            !e.isOperator &&
            e is! PropertyAccessorElement &&
            !methodNames.contains(e.name));
      }).toSet();

      for (ExecutableElement e in inheritedMethodElements) {
        Method m = ModelElement.from(e, library, packageGraph,
            enclosingContainer: this);
        _inheritedMethods.add(m);
      }
      _inheritedMethods.sort(byName);
    }
    return _inheritedMethods;
  }

  Iterable get publicInheritedMethods =>
      utils.filterNonPublic(inheritedMethods);

  bool get hasPublicInheritedMethods => publicInheritedMethods.isNotEmpty;

  List<Operator> get inheritedOperators {
    if (_inheritedOperators == null) {
      _inheritedOperators = [];
      Set<String> operatorNames = _operators.map((o) => o.element.name).toSet();

      Set<ExecutableElement> inheritedOperatorElements =
          _inheritedElements.where((e) {
        return (e is MethodElement &&
            e.isOperator &&
            !operatorNames.contains(e.name));
      }).toSet();
      for (ExecutableElement e in inheritedOperatorElements) {
        Operator o = ModelElement.from(e, library, packageGraph,
            enclosingContainer: this);
        _inheritedOperators.add(o);
      }
      _inheritedOperators.sort(byName);
    }
    return _inheritedOperators;
  }

  Iterable<Operator> get publicInheritedOperators =>
      utils.filterNonPublic(inheritedOperators);

  List<Field> get inheritedProperties {
    if (_inheritedProperties == null) {
      _inheritedProperties = _allFields.where((f) => f.isInherited).toList()
        ..sort(byName);
    }
    return _inheritedProperties;
  }

  Iterable<Field> get publicInheritedProperties =>
      utils.filterNonPublic(inheritedProperties);

  Iterable<Method> get publicInstanceMethods => instanceMethods;

  List<DefinedElementType> get interfaces => _interfaces;

  Iterable<DefinedElementType> get publicInterfaces =>
      utils.filterNonPublic(interfaces);

  bool get isAbstract => _cls.isAbstract;

  @override
  bool get isCanonical => super.isCanonical && isPublic;

  bool get isErrorOrException {
    bool _doCheck(ClassElement element) {
      return (element.library.isDartCore &&
          (element.name == 'Exception' || element.name == 'Error'));
    }

    // if this class is itself Error or Exception, return true
    if (_doCheck(_cls)) return true;

    return _cls.allSupertypes.map((t) => t.element).any(_doCheck);
  }

  /// Returns true if [other] is a parent class for this class.
  @override
  bool isInheritingFrom(covariant Class other) =>
      superChain.map((et) => (et.element as Class)).contains(other);

  @override
  String get kind => 'class';

  List<DefinedElementType> get mixins => _mixins;

  Iterable<DefinedElementType> get publicMixins =>
      utils.filterNonPublic(mixins);

  @override
  DefinedElementType get modelType => super.modelType;

  /// Not the same as superChain as it may include mixins.
  /// It's really not even the same as ordinary Dart inheritance, either,
  /// because we pretend that interfaces are part of the inheritance chain
  /// to include them in the set of things we might link to for documentation
  /// purposes in abstract classes.
  List<Class> _inheritanceChain;

  List<Class> get inheritanceChain {
    if (_inheritanceChain == null) {
      _inheritanceChain = [];
      _inheritanceChain.add(this);

      /// Caching should make this recursion a little less painful.
      for (Class c in mixins.reversed.map((e) => (e.element as Class))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      for (Class c in superChain.map((e) => (e.element as Class))) {
        _inheritanceChain.addAll(c.inheritanceChain);
      }

      /// Interfaces need to come last, because classes in the superChain might
      /// implement them even when they aren't mentioned.
      _inheritanceChain.addAll(
          interfaces.expand((e) => (e.element as Class).inheritanceChain));
    }
    return _inheritanceChain.toList(growable: false);
  }

  List<DefinedElementType> get superChain {
    List<DefinedElementType> typeChain = [];
    DefinedElementType parent = supertype;
    while (parent != null) {
      typeChain.add(parent);
      if (parent.type is InterfaceType) {
        // Avoid adding [Object] to the superChain (_supertype already has this
        // check)
        if ((parent.type as InterfaceType)?.superclass?.superclass == null) {
          parent = null;
        } else {
          parent = ElementType.from(
              (parent.type as InterfaceType).superclass, library, packageGraph);
        }
      } else {
        parent = (parent.element as Class).supertype;
      }
    }
    return typeChain;
  }

  Iterable<DefinedElementType> get publicSuperChain =>
      utils.filterNonPublic(superChain);

  Iterable<DefinedElementType> get publicSuperChainReversed =>
      publicSuperChain.toList().reversed;

  List<ExecutableElement> __inheritedElements;

  List<ExecutableElement> get _inheritedElements {
    if (__inheritedElements == null) {
      var classElement = element as ClassElement;
      if (classElement.isDartCoreObject) {
        return __inheritedElements = <ExecutableElement>[];
      }

      var inheritance = definingLibrary.inheritanceManager;
      var classType = classElement.thisType;
      var cmap = inheritance.getInheritedConcreteMap(classType);
      var imap = inheritance.getInheritedMap(classType);

      var combinedMap = <String, ExecutableElement>{};
      for (var nameObj in cmap.keys) {
        combinedMap[nameObj.name] = cmap[nameObj];
      }
      for (var nameObj in imap.keys) {
        combinedMap[nameObj.name] ??= imap[nameObj];
      }

      __inheritedElements = combinedMap.values.toList();
    }
    return __inheritedElements;
  }

  /// Internal only because subclasses are allowed to override how
  /// these are mapped to [allInheritedFields] and so forth.
  @override
  List<Field> get _allFields {
    if (_fields != null) return _fields;
    _fields = [];
    Set<PropertyAccessorElement> inheritedAccessors = Set()
      ..addAll(_inheritedElements.whereType<PropertyAccessorElement>());

    // This structure keeps track of inherited accessors, allowing lookup
    // by field name (stripping the '=' from setters).
    Map<String, List<PropertyAccessorElement>> accessorMap = Map();
    for (PropertyAccessorElement accessorElement in inheritedAccessors) {
      String name = accessorElement.name.replaceFirst('=', '');
      accessorMap.putIfAbsent(name, () => []);
      accessorMap[name].add(accessorElement);
    }

    // For half-inherited fields, the analyzer only links the non-inherited
    // to the [FieldElement].  Compose our [Field] class by hand by looking up
    // inherited accessors that may be related.
    for (FieldElement f in _cls.fields) {
      PropertyAccessorElement getterElement = f.getter;
      if (getterElement == null && accessorMap.containsKey(f.name)) {
        getterElement = accessorMap[f.name]
            .firstWhere((e) => e.isGetter, orElse: () => null);
      }
      PropertyAccessorElement setterElement = f.setter;
      if (setterElement == null && accessorMap.containsKey(f.name)) {
        setterElement = accessorMap[f.name]
            .firstWhere((e) => e.isSetter, orElse: () => null);
      }
      _addSingleField(getterElement, setterElement, inheritedAccessors, f);
      accessorMap.remove(f.name);
    }

    // Now we only have inherited accessors who aren't associated with
    // anything in cls._fields.
    for (String fieldName in accessorMap.keys) {
      List<PropertyAccessorElement> elements = accessorMap[fieldName].toList();
      PropertyAccessorElement getterElement =
          elements.firstWhere((e) => e.isGetter, orElse: () => null);
      PropertyAccessorElement setterElement =
          elements.firstWhere((e) => e.isSetter, orElse: () => null);
      _addSingleField(getterElement, setterElement, inheritedAccessors);
    }

    _fields.sort(byName);
    return _fields;
  }

  /// Add a single Field to _fields.
  ///
  /// If [f] is not specified, pick the FieldElement from the PropertyAccessorElement
  /// whose enclosing class inherits from the other (defaulting to the getter)
  /// and construct a Field using that.
  void _addSingleField(
      PropertyAccessorElement getterElement,
      PropertyAccessorElement setterElement,
      Set<PropertyAccessorElement> inheritedAccessors,
      [FieldElement f]) {
    ContainerAccessor getter =
        ContainerAccessor.from(getterElement, inheritedAccessors, this);
    ContainerAccessor setter =
        ContainerAccessor.from(setterElement, inheritedAccessors, this);
    // Rebind getterElement/setterElement as ModelElement.from can resolve
    // MultiplyInheritedExecutableElements or resolve Members.
    getterElement = getter?.element;
    setterElement = setter?.element;
    assert(!(getter == null && setter == null));
    if (f == null) {
      // Pick an appropriate FieldElement to represent this element.
      // Only hard when dealing with a synthetic Field.
      if (getter != null && setter == null) {
        f = getterElement.variable;
      } else if (getter == null && setter != null) {
        f = setterElement.variable;
      } else
      /* getter != null && setter != null */ {
        // In cases where a Field is composed of two Accessors defined in
        // different places in the inheritance chain, there are two FieldElements
        // for this single Field we're trying to compose.  Pick the one closest
        // to this class on the inheritance chain.
        if ((setter.enclosingElement)
            .isInheritingFrom(getter.enclosingElement)) {
          f = setterElement.variable;
        } else {
          f = getterElement.variable;
        }
      }
    }
    Field field;
    if ((getter == null || getter.isInherited) &&
        (setter == null || setter.isInherited)) {
      // Field is 100% inherited.
      field = ModelElement.from(f, library, packageGraph,
          enclosingContainer: this, getter: getter, setter: setter);
    } else {
      // Field is <100% inherited (could be half-inherited).
      // TODO(jcollins-g): Navigation is probably still confusing for
      // half-inherited fields when traversing the inheritance tree.  Make
      // this better, somehow.
      field = ModelElement.from(f, library, packageGraph,
          getter: getter, setter: setter);
    }
    _fields.add(field);
  }

  ClassElement get _cls => (element as ClassElement);

  @override
  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _cls.methods.map((e) {
      return ModelElement.from(e, library, packageGraph) as Method;
    }).toList(growable: false)
      ..sort(byName);

    return _allMethods;
  }

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    if (_typeParameters == null) {
      _typeParameters = _cls.typeParameters.map((f) {
        var lib = Library(f.enclosingElement.library, packageGraph);
        return ModelElement.from(f, lib, packageGraph) as TypeParameter;
      }).toList();
    }
    return _typeParameters;
  }

  @override
  bool operator ==(o) =>
      o is Class &&
      name == o.name &&
      o.library.name == library.name &&
      o.library.package.name == library.package.name;
}

/// Extension methods
class Extension extends Container
    with TypeParameters, Categorization
    implements EnclosedElement {
  DefinedElementType extendedType;

  Extension(
      ExtensionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph) {
    extendedType =
        ElementType.from(_extension.extendedType, library, packageGraph);
  }

  /// Returns [true] if there is an instantiation of [c] to which this extension
  /// could be applied.
  bool couldApplyTo(Class c) =>
      _couldApplyTo(extendedType.type, c.element, packageGraph.typeSystem);

  static bool _couldApplyTo(
      DartType extendedType, ClassElement element, Dart2TypeSystem typeSystem) {
    InterfaceTypeImpl classInstantiated =
        typeSystem.instantiateToBounds(element.thisType);
    classInstantiated = element.instantiate(
        typeArguments: classInstantiated.typeArguments.map((a) {
          if (a.isDynamic) {
            return typeSystem.typeProvider.neverType;
          }
          return a;
        }).toList(),
        nullabilitySuffix: classInstantiated.nullabilitySuffix);

    return (classInstantiated.element == extendedType.element) ||
        typeSystem.isSubtypeOf(classInstantiated, extendedType);
  }

  @override
  ModelElement get enclosingElement => library;

  ExtensionElement get _extension => (element as ExtensionElement);

  @override
  String get kind => 'extension';

  @override
  List<Method> get _methods {
    if (_allMethods != null) return _allMethods;

    _allMethods = _extension.methods.map((e) {
      return ModelElement.from(e, library, packageGraph) as Method;
    }).toList(growable: false)
      ..sort(byName);

    return _allMethods;
  }

  @override
  List<Field> get _allFields {
    if (_fields != null) return _fields;
    _fields = _extension.fields.map((f) {
      Accessor getter, setter;
      if (f.getter != null) {
        getter = ContainerAccessor(f.getter, library, packageGraph);
      }
      if (f.setter != null) {
        setter = ContainerAccessor(f.setter, library, packageGraph);
      }
      return ModelElement.from(f, library, packageGraph,
          getter: getter, setter: setter) as Field;
    }).toList(growable: false)
      ..sort(byName);

    return _fields;
  }

  // a stronger hash?
  @override
  List<TypeParameter> get typeParameters {
    if (_typeParameters == null) {
      _typeParameters = _extension.typeParameters.map((f) {
        var lib = Library(f.enclosingElement.library, packageGraph);
        return ModelElement.from(f, lib, packageGraph) as TypeParameter;
      }).toList();
    }
    return _typeParameters;
  }

  @override
  DefinedElementType get modelType => super.modelType;

  List<ModelElement> _allModelElements;

  List<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = List.from(
          quiver.concat([
            instanceMethods,
            allInstanceFields,
            allAccessors,
            allOperators,
            constants,
            staticMethods,
            staticProperties,
            typeParameters,
          ]),
          growable: false);
    }
    return _allModelElements;
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${library.dirName}/$fileName';
  }
}

class Constructor extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  Constructor(
      ConstructorElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  CharacterLocation get characterLocation {
    if (element.isSynthetic) {
      // Make warnings for a synthetic constructor refer to somewhere reasonable
      // since a synthetic constructor has no definition independent of the
      // parent class.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  // TODO(jcollins-g): Revisit this when dart-lang/sdk#31517 is implemented.
  List<TypeParameter> get typeParameters =>
      (enclosingElement as Class).typeParameters;

  @override
  ModelElement get enclosingElement =>
      ModelElement.from(_constructor.enclosingElement, library, packageGraph);

  String get fullKind {
    if (isConst) return 'const $kind';
    if (isFactory) return 'factory $kind';
    return kind;
  }

  @override
  String get fullyQualifiedName {
    if (isDefaultConstructor) return super.fullyQualifiedName;
    return '${library.name}.$name';
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.name}/$name.html';
  }

  @override
  bool get isConst => _constructor.isConst;

  bool get isDefaultConstructor => name == enclosingElement.name;

  bool get isFactory => _constructor.isFactory;

  @override
  String get kind => 'constructor';

  @override
  DefinedElementType get modelType => super.modelType;

  String _name;

  @override
  String get name {
    if (_name == null) {
      String constructorName = element.name;
      if (constructorName.isEmpty) {
        _name = enclosingElement.name;
      } else {
        _name = '${enclosingElement.name}.$constructorName';
      }
    }
    return _name;
  }

  String _nameWithGenerics;

  @override
  String get nameWithGenerics {
    if (_nameWithGenerics == null) {
      String constructorName = element.name;
      if (constructorName.isEmpty) {
        _nameWithGenerics = '${enclosingElement.name}${genericParameters}';
      } else {
        _nameWithGenerics =
            '${enclosingElement.name}${genericParameters}.$constructorName';
      }
    }
    return _nameWithGenerics;
  }

  String get shortName {
    if (name.contains('.')) {
      return name.substring(_constructor.enclosingElement.name.length + 1);
    } else {
      return name;
    }
  }

  ConstructorElement get _constructor => (element as ConstructorElement);
}

/// Bridges the gap between model elements and packages,
/// both of which have documentation.
abstract class Documentable extends Nameable {
  String get documentation;

  String get documentationAsHtml;

  bool get hasDocumentation;

  bool get hasExtendedDocumentation;

  String get oneLineDoc;

  PackageGraph get packageGraph;

  bool get isDocumented;

  DartdocOptionContext get config;
}

/// Mixin implementing dartdoc categorization for ModelElements.
abstract class Categorization implements ModelElement {
  @override
  String _buildDocumentationAddition(String rawDocs) =>
      _stripAndSetDartdocCategories(rawDocs ??= '');

  /// Parse {@category ...} and related information in API comments, stripping
  /// out that information from the given comments and returning the stripped
  /// version.
  String _stripAndSetDartdocCategories(String rawDocs) {
    Set<String> _categorySet = Set();
    Set<String> _subCategorySet = Set();
    _hasCategorization = false;

    rawDocs = rawDocs.replaceAllMapped(categoryRegexp, (match) {
      _hasCategorization = true;
      switch (match[1]) {
        case 'category':
        case 'api':
          _categorySet.add(match[2].trim());
          break;
        case 'subCategory':
          _subCategorySet.add(match[2].trim());
          break;
        case 'image':
          _image = match[2].trim();
          break;
        case 'samples':
          _samples = match[2].trim();
          break;
      }
      return '';
    });

    if (_categorySet.isEmpty) {
      // All objects are in the default category if not specified.
      _categorySet.add(null);
    }
    if (_subCategorySet.isEmpty) {
      // All objects are in the default subcategory if not specified.
      _subCategorySet.add(null);
    }
    _categoryNames = _categorySet.toList()..sort();
    _subCategoryNames = _subCategorySet.toList()..sort();
    _image ??= '';
    _samples ??= '';
    return rawDocs;
  }

  bool get hasSubCategoryNames =>
      subCategoryNames.length > 1 || subCategoryNames.first != null;
  List<String> _subCategoryNames;

  /// Either a set of strings containing all declared subcategories for this symbol,
  /// or a set containing Null if none were declared.
  List<String> get subCategoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_subCategoryNames == null) documentationLocal;
    return _subCategoryNames;
  }

  @override
  bool get hasCategoryNames =>
      categoryNames.length > 1 || categoryNames.first != null;
  List<String> _categoryNames;

  /// Either a set of strings containing all declared categories for this symbol,
  /// or a set containing Null if none were declared.
  List<String> get categoryNames {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_categoryNames == null) documentationLocal;
    return _categoryNames;
  }

  bool get hasImage => image.isNotEmpty;
  String _image;

  /// Either a URI to a defined image, or the empty string if none
  /// was declared.
  String get image {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_image == null) documentationLocal;
    return _image;
  }

  bool get hasSamples => samples.isNotEmpty;
  String _samples;

  /// Either a URI to documentation with samples, or the empty string if none
  /// was declared.
  String get samples {
    // TODO(jcollins-g): avoid side-effect dependency
    if (_samples == null) documentationLocal;
    return _samples;
  }

  bool _hasCategorization;

  Iterable<Category> _categories;

  Iterable<Category> get categories {
    if (_categories == null) {
      _categories = categoryNames
          .map((n) => package.nameToCategory[n])
          .where((c) => c != null)
          .toList()
            ..sort();
    }
    return _categories;
  }

  Iterable<Category> get displayedCategories {
    if (config.showUndocumentedCategories) return categories;
    return categories.where((c) => c.isDocumented);
  }

  /// True if categories, subcategories, a documentation icon, or samples were
  /// declared.
  bool get hasCategorization {
    if (_hasCategorization == null) documentationLocal;
    return _hasCategorization;
  }
}

/// A stripped down [CommentReference] containing only that information needed
/// for Dartdoc.  Drops link to the [CommentReference] after construction.
class ModelCommentReference {
  final String name;
  final Element staticElement;

  ModelCommentReference(CommentReference ref)
      : name = ref.identifier.name,
        staticElement = ref.identifier.staticElement;
}

/// Stripped down information derived from [AstNode] containing only information
/// needed for Dartdoc.  Drops link to the [AstNode] after construction.
class ModelNode {
  final List<ModelCommentReference> commentRefs;
  final Element element;

  final int _sourceOffset;
  final int _sourceEnd;

  ModelNode(AstNode sourceNode, this.element)
      : _sourceOffset = sourceNode?.offset,
        _sourceEnd = sourceNode?.end,
        commentRefs = _commentRefsFor(sourceNode);

  static List<ModelCommentReference> _commentRefsFor(AstNode node) {
    if (node is AnnotatedNode &&
        node?.documentationComment?.references != null) {
      return node.documentationComment.references
          .map((c) => ModelCommentReference(c))
          .toList(growable: false);
    }
    return null;
  }

  String get sourceCode {
    String contents = utils.getFileContentsFor(element);
    if (_sourceOffset != null) {
      // Find the start of the line, so that we can line up all the indents.
      int i = _sourceOffset;
      while (i > 0) {
        i -= 1;
        if (contents[i] == '\n' || contents[i] == '\r') {
          i += 1;
          break;
        }
      }

      // Trim the common indent from the source snippet.
      var start = _sourceOffset - (_sourceOffset - i);
      String source = contents.substring(start, _sourceEnd);

      source = const HtmlEscape().convert(source);
      source = utils.stripIndentFromSource(source);
      source = utils.stripDartdocCommentsFromSource(source);

      return source.trim();
    } else {
      return '';
    }
  }
}

/// Classes extending this class have canonicalization support in Dartdoc.
abstract class Canonicalization implements Locatable, Documentable {
  bool get isCanonical;

  Library get canonicalLibrary;

  List<ModelCommentReference> _commentRefs;

  List<ModelCommentReference> get commentRefs => _commentRefs;

  /// Pieces of the location split by [locationSplitter] (removing package: and
  /// slashes).
  Set<String> get locationPieces;

  List<ScoredCandidate> scoreCanonicalCandidates(List<Library> libraries) {
    return libraries.map((l) => scoreElementWithLibrary(l)).toList()..sort();
  }

  ScoredCandidate scoreElementWithLibrary(Library lib) {
    ScoredCandidate scoredCandidate = ScoredCandidate(this, lib);
    Iterable<String> resplit(Set<String> items) sync* {
      for (String item in items) {
        for (String subItem in item.split('_')) {
          yield subItem;
        }
      }
    }

    // Large boost for @canonicalFor, essentially overriding all other concerns.
    if (lib.canonicalFor.contains(fullyQualifiedName)) {
      scoredCandidate.alterScore(5.0, 'marked @canonicalFor');
    }
    // Penalty for deprecated libraries.
    if (lib.isDeprecated) scoredCandidate.alterScore(-1.0, 'is deprecated');
    // Give a big boost if the library has the package name embedded in it.
    if (lib.package.namePieces.intersection(lib.namePieces).isEmpty) {
      scoredCandidate.alterScore(1.0, 'embeds package name');
    }
    // Give a tiny boost for libraries with long names, assuming they're
    // more specific (and therefore more likely to be the owner of this symbol).
    scoredCandidate.alterScore(.01 * lib.namePieces.length, 'name is long');
    // If we don't know the location of this element, return our best guess.
    // TODO(jcollins-g): is that even possible?
    assert(locationPieces.isNotEmpty);
    if (locationPieces.isEmpty) return scoredCandidate;
    // The more pieces we have of the location in our library name, the more we should boost our score.
    scoredCandidate.alterScore(
        lib.namePieces.intersection(locationPieces).length.toDouble() /
            locationPieces.length.toDouble(),
        'element location shares parts with name');
    // If pieces of location at least start with elements of our library name, boost the score a little bit.
    double scoreBoost = 0.0;
    for (String piece in resplit(locationPieces)) {
      for (String namePiece in lib.namePieces) {
        if (piece.startsWith(namePiece)) {
          scoreBoost += 0.001;
        }
      }
    }
    scoredCandidate.alterScore(
        scoreBoost, 'element location parts start with parts of name');
    return scoredCandidate;
  }
}

class Dynamic extends ModelElement {
  Dynamic(Element element, PackageGraph packageGraph)
      : super(element, null, packageGraph, null);

  /// [dynamic] is not a real object, and so we can't document it, so there
  /// can be nothing canonical for it.
  @override
  ModelElement get canonicalModelElement => null;

  @override
  ModelElement get enclosingElement => throw UnsupportedError('');

  /// And similiarly, even if someone references it directly it can have
  /// no hyperlink.
  @override
  String get href => null;

  @override
  String get kind => 'dynamic';

  @override
  String get linkedName => 'dynamic';
}

/// An element that is enclosed by some other element.
///
/// Libraries are not enclosed.
abstract class EnclosedElement {
  ModelElement get enclosingElement;
}

// TODO(jcollins-g): Consider Enum as subclass of Container?
class Enum extends Class {
  Enum(ClassElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  List<EnumField> _instanceProperties;

  @override
  List<EnumField> get instanceProperties {
    if (_instanceProperties == null) {
      _instanceProperties = super
          .instanceProperties
          .map((Field p) => ModelElement.from(
              p.element, p.library, p.packageGraph,
              getter: p.getter, setter: p.setter) as EnumField)
          .toList(growable: false);
    }
    return _instanceProperties;
  }

  @override
  String get kind => 'enum';
}

/// Enum's fields are virtual, so we do a little work to create
/// usable values for the docs.
class EnumField extends Field {
  int _index;

  EnumField(FieldElement element, Library library, PackageGraph packageGraph,
      Accessor getter, Accessor setter)
      : super(element, library, packageGraph, getter, setter);

  EnumField.forConstant(this._index, FieldElement element, Library library,
      PackageGraph packageGraph, Accessor getter)
      : super(element, library, packageGraph, getter, null);

  @override
  String get constantValueBase {
    if (name == 'values') {
      return 'const List&lt;<wbr><span class="type-parameter">${_field.enclosingElement.name}</span>&gt;';
    } else {
      return 'const ${_field.enclosingElement.name}($_index)';
    }
  }

  @override
  List<ModelElement> get documentationFrom {
    if (name == 'values' || name == 'index') return [this];
    return super.documentationFrom;
  }

  @override
  String get documentation {
    if (name == 'values') {
      return 'A constant List of the values in this enum, in order of their declaration.';
    } else if (name == 'index') {
      return 'The integer index of this enum.';
    } else {
      return super.documentation;
    }
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(!(canonicalLibrary == null || canonicalEnclosingContainer == null));
    assert(canonicalLibrary == library);
    assert(canonicalEnclosingContainer == enclosingElement);
    return '${package.baseHref}${enclosingElement.library.dirName}/${(enclosingElement as Class).fileName}';
  }

  @override
  String get linkedName => name;

  @override
  bool get isCanonical {
    if (name == 'index') return false;
    // If this is something inherited from Object, e.g. hashCode, let the
    // normal rules apply.
    if (_index == null) {
      return super.isCanonical;
    }
    // TODO(jcollins-g): We don't actually document this as a separate entity;
    //                   do that or change this to false and deal with the
    //                   consequences.
    return true;
  }

  @override
  String get oneLineDoc => documentationAsHtml;

  @override
  Inheritable get overriddenElement => null;
}

class Field extends ModelElement
    with GetterSetterCombo, ContainerMember, Inheritable
    implements EnclosedElement {
  bool _isInherited = false;
  Container _enclosingClass;
  @override
  final ContainerAccessor getter;
  @override
  final ContainerAccessor setter;

  Field(FieldElement element, Library library, PackageGraph packageGraph,
      this.getter, this.setter)
      : super(element, library, packageGraph, null) {
    assert(getter != null || setter != null);
    if (getter != null) getter._enclosingCombo = this;
    if (setter != null) setter._enclosingCombo = this;
    _setModelType();
  }

  factory Field.inherited(
      FieldElement element,
      Class enclosingClass,
      Library library,
      PackageGraph packageGraph,
      Accessor getter,
      Accessor setter) {
    Field newField = Field(element, library, packageGraph, getter, setter);
    newField._isInherited = true;
    newField._enclosingClass = enclosingClass;
    // Can't set _isInherited to true if this is the defining element, because
    // that would mean it isn't inherited.
    assert(newField.enclosingElement != newField.definingEnclosingContainer);
    return newField;
  }

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    if (isPublic) {
      Set<bool> assertCheck = Set()
        ..addAll([hasPublicSetter, hasPublicGetterNoSetter]);
      assert(assertCheck.containsAll([true, false]));
    }
    documentationFrom;
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement {
    if (_enclosingClass == null) {
      _enclosingClass =
          ModelElement.from(_field.enclosingElement, library, packageGraph);
    }
    return _enclosingClass;
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalEnclosingContainer == enclosingElement);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.name}/$fileName';
  }

  @override
  bool get isConst => _field.isConst;

  /// Returns true if the FieldElement is covariant, or if the first parameter
  /// for the setter is covariant.
  @override
  bool get isCovariant =>
      setter?.isCovariant == true || (_field as FieldElementImpl).isCovariant;

  @override
  bool get isFinal {
    /// isFinal returns true for the field even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return _field.isFinal;
  }

  @override
  bool get isInherited => _isInherited;

  @override
  String get kind => isConst ? 'constant' : 'property';

  @override
  List<String> get annotations {
    List<String> all_annotations = List<String>();
    all_annotations.addAll(super.annotations);

    if (element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;
      all_annotations.addAll(annotationsFromMetadata(pie.getter?.metadata));
      all_annotations.addAll(annotationsFromMetadata(pie.setter?.metadata));
    }
    return all_annotations.toList(growable: false);
  }

  @override
  Set<String> get features {
    Set<String> allFeatures = super.features..addAll(comboFeatures);
    // Combo features can indicate 'inherited' and 'override' if
    // either the getter or setter has one of those properties, but that's not
    // really specific enough for [Field]s that have public getter/setters.
    if (hasPublicGetter && hasPublicSetter) {
      if (getter.isInherited && setter.isInherited) {
        allFeatures.add('inherited');
      } else {
        allFeatures.remove('inherited');
        if (getter.isInherited) allFeatures.add('inherited-getter');
        if (setter.isInherited) allFeatures.add('inherited-setter');
      }
      if (getter.isOverride && setter.isOverride) {
        allFeatures.add('override');
      } else {
        allFeatures.remove('override');
        if (getter.isOverride) allFeatures.add('override-getter');
        if (setter.isOverride) allFeatures.add('override-setter');
      }
    } else {
      if (isInherited) allFeatures.add('inherited');
      if (isOverride) allFeatures.add('override');
    }
    return allFeatures;
  }

  @override
  String _computeDocumentationComment() {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _field.documentationComment;
    return docs;
  }

  FieldElement get _field => (element as FieldElement);

  @override
  String get fileName => isConst ? '$name-constant.html' : '$name.html';

  @override
  String get sourceCode {
    if (_sourceCode == null) {
      // We could use a set to figure the dupes out, but that would lose ordering.
      String fieldSourceCode = modelNode.sourceCode ?? '';
      String getterSourceCode = getter?.sourceCode ?? '';
      String setterSourceCode = setter?.sourceCode ?? '';
      StringBuffer buffer = StringBuffer();
      if (fieldSourceCode.isNotEmpty) {
        buffer.write(fieldSourceCode);
      }
      if (buffer.isNotEmpty) buffer.write('\n\n');
      if (fieldSourceCode != getterSourceCode) {
        if (getterSourceCode != setterSourceCode) {
          buffer.write(getterSourceCode);
          if (buffer.isNotEmpty) buffer.write('\n\n');
        }
      }
      if (fieldSourceCode != setterSourceCode) {
        buffer.write(setterSourceCode);
      }
      _sourceCode = buffer.toString();
    }
    return _sourceCode;
  }

  void _setModelType() {
    if (hasGetter) {
      _modelType = getter.modelType;
    }
  }

  @override
  Inheritable get overriddenElement => null;
}

/// Mixin for top-level variables and fields (aka properties)
mixin GetterSetterCombo on ModelElement {
  Accessor get getter;

  Iterable<Accessor> get allAccessors sync* {
    for (Accessor a in [getter, setter]) {
      if (a != null) yield a;
    }
  }

  Set<String> get comboFeatures {
    Set<String> allFeatures = Set();
    if (hasExplicitGetter && hasPublicGetter) {
      allFeatures.addAll(getter.features);
    }
    if (hasExplicitSetter && hasPublicSetter) {
      allFeatures.addAll(setter.features);
    }
    if (readOnly && !isFinal && !isConst) allFeatures.add('read-only');
    if (writeOnly) allFeatures.add('write-only');
    if (readWrite) allFeatures.add('read / write');
    return allFeatures;
  }

  @override
  ModelElement enclosingElement;

  bool get isInherited;

  Expression get constantInitializer =>
      (element as ConstVariableElement).constantInitializer;

  String linkifyConstantValue(String original) {
    if (constantInitializer is! InstanceCreationExpression) return original;
    String constructorName = (constantInitializer as InstanceCreationExpression)
        .constructorName
        .toString();
    Element staticElement =
        (constantInitializer as InstanceCreationExpression).staticElement;
    Constructor target = ModelElement.fromElement(staticElement, packageGraph);
    Class targetClass = target.enclosingElement;
    // TODO(jcollins-g): this logic really should be integrated into Constructor,
    // but that's not trivial because of linkedName's usage.
    if (targetClass.name == target.name) {
      return original.replaceAll(constructorName, "${target.linkedName}");
    }
    return original.replaceAll("${targetClass.name}.${target.name}",
        "${targetClass.linkedName}.${target.linkedName}");
  }

  String _buildConstantValueBase() {
    String result = constantInitializer?.toString() ?? '';
    return const HtmlEscape(HtmlEscapeMode.unknown).convert(result);
  }

  @override
  CharacterLocation get characterLocation {
    // Handle all synthetic possibilities.  Ordinarily, warnings for
    // explicit setters/getters will be handled by those objects, but
    // if a warning comes up for an enclosing synthetic field we have to
    // put it somewhere.  So pick an accessor.
    if (element.isSynthetic) {
      if (hasExplicitGetter) return getter.characterLocation;
      if (hasExplicitSetter) return setter.characterLocation;
      assert(false, 'Field and accessors can not all be synthetic');
    }
    return super.characterLocation;
  }

  String get constantValue => linkifyConstantValue(constantValueBase);

  String get constantValueTruncated =>
      linkifyConstantValue(truncateString(constantValueBase, 200));
  String _constantValueBase;

  String get constantValueBase =>
      _constantValueBase ??= _buildConstantValueBase();

  bool get hasPublicGetter => hasGetter && getter.isPublic;

  bool get hasPublicSetter => hasSetter && setter.isPublic;

  @override
  bool get isPublic => hasPublicGetter || hasPublicSetter;

  @override
  List<ModelElement> get documentationFrom {
    if (_documentationFrom == null) {
      _documentationFrom = [];
      if (hasPublicGetter) {
        _documentationFrom.addAll(getter.documentationFrom);
      } else if (hasPublicSetter) {
        _documentationFrom.addAll(setter.documentationFrom);
      }
      if (_documentationFrom.isEmpty ||
          _documentationFrom.every((e) => e.documentationComment == '')) {
        _documentationFrom = computeDocumentationFrom;
      }
    }
    return _documentationFrom;
  }

  bool get hasAccessorsWithDocs => (hasPublicGetter &&
          !getter.isSynthetic &&
          getter.documentation.isNotEmpty ||
      hasPublicSetter &&
          !setter.isSynthetic &&
          setter.documentation.isNotEmpty);

  bool get getterSetterBothAvailable => (hasPublicGetter &&
      getter.documentation.isNotEmpty &&
      hasPublicSetter &&
      setter.documentation.isNotEmpty);

  @override
  String get oneLineDoc {
    if (_oneLineDoc == null) {
      if (!hasAccessorsWithDocs) {
        _oneLineDoc = computeOneLineDoc();
      } else {
        StringBuffer buffer = StringBuffer();
        if (hasPublicGetter && getter.oneLineDoc.isNotEmpty) {
          buffer.write('${getter.oneLineDoc}');
        }
        if (hasPublicSetter && setter.oneLineDoc.isNotEmpty) {
          buffer.write('${getterSetterBothAvailable ? "" : setter.oneLineDoc}');
        }
        _oneLineDoc = buffer.toString();
      }
    }
    return _oneLineDoc;
  }

  String get getterSetterDocumentationComment {
    var buffer = StringBuffer();

    if (hasPublicGetter && !getter.isSynthetic) {
      assert(getter.documentationFrom.length == 1);
      // We have to check against dropTextFrom here since documentationFrom
      // doesn't yield the real elements for GetterSetterCombos.
      if (!config.dropTextFrom
          .contains(getter.documentationFrom.first.element.library.name)) {
        String docs = getter.documentationFrom.first.documentationComment;
        if (docs != null) buffer.write(docs);
      }
    }

    if (hasPublicSetter && !setter.isSynthetic) {
      assert(setter.documentationFrom.length == 1);
      if (!config.dropTextFrom
          .contains(setter.documentationFrom.first.element.library.name)) {
        String docs = setter.documentationFrom.first.documentationComment;
        if (docs != null) {
          if (buffer.isNotEmpty) buffer.write('\n\n');
          buffer.write(docs);
        }
      }
    }
    return buffer.toString();
  }

  String get linkedReturnType {
    if (hasGetter) {
      return getter.linkedReturnType;
    } else {
      return setter.linkedParamsNoMetadataOrNames;
    }
  }

  @override
  bool get canHaveParameters => hasSetter;

  @override
  List<Parameter> get parameters => setter.parameters;

  @override
  String get linkedParamsNoMetadata {
    if (hasSetter) return setter.linkedParamsNoMetadata;
    return null;
  }

  bool get hasExplicitGetter => hasPublicGetter && !getter.isSynthetic;

  bool get hasExplicitSetter => hasPublicSetter && !setter.isSynthetic;

  bool get hasGetter => getter != null;

  bool get hasNoGetterSetter => !hasGetterOrSetter;

  bool get hasGetterOrSetter => hasExplicitGetter || hasExplicitSetter;

  bool get hasSetter => setter != null;

  bool get hasPublicGetterNoSetter => (hasPublicGetter && !hasPublicSetter);

  String get arrow {
    // →
    if (readOnly) return r'&#8594;';
    // ←
    if (writeOnly) return r'&#8592;';
    // ↔
    if (readWrite) return r'&#8596;';
    throw UnsupportedError(
        'GetterSetterCombo must be one of readOnly, writeOnly, or readWrite');
  }

  bool get readOnly => hasPublicGetter && !hasPublicSetter;

  bool get readWrite => hasPublicGetter && hasPublicSetter;

  bool get writeOnly => hasPublicSetter && !hasPublicGetter;

  Accessor get setter;
}

/// Find all hashable children of a given element that are defined in the
/// [LibraryElement] given at initialization.
class _HashableChildLibraryElementVisitor
    extends GeneralizingElementVisitor<void> {
  final void Function(Element) libraryProcessor;

  _HashableChildLibraryElementVisitor(this.libraryProcessor);

  @override
  void visitElement(Element element) {
    libraryProcessor(element);
    super.visitElement(element);
    return null;
  }

  @override
  void visitExportElement(ExportElement element) {
    // [ExportElement]s are not always hashable; skip them.
    return null;
  }

  @override
  void visitImportElement(ImportElement element) {
    // [ImportElement]s are not always hashable; skip them.
    return null;
  }

  @override
  void visitParameterElement(ParameterElement element) {
    // [ParameterElement]s without names do not provide sufficiently distinct
    // hashes / comparison, so just skip them all. (dart-lang/sdk#30146)
    return null;
  }
}

class Library extends ModelElement with Categorization, TopLevelContainer {
  List<TopLevelVariable> _variables;
  List<Element> _exportedAndLocalElements;
  String _name;

  factory Library(LibraryElement element, PackageGraph packageGraph) {
    return packageGraph.findButDoNotCreateLibraryFor(element);
  }

  Library._(ResolvedLibraryResult libraryResult, PackageGraph packageGraph,
      this._package)
      : super(libraryResult.element, null, packageGraph, null) {
    if (element == null) throw ArgumentError.notNull('element');

    // Initialize [packageGraph]'s cache of ModelNodes for relevant
    // elements in this library.
    Map<String, CompilationUnit> _compilationUnitMap = Map();
    _compilationUnitMap.addEntries(libraryResult.units
        .map((ResolvedUnitResult u) => MapEntry(u.path, u.unit)));
    _HashableChildLibraryElementVisitor((Element e) =>
            packageGraph._populateModelNodeFor(e, _compilationUnitMap))
        .visitElement(element);

    // Initialize the list of elements defined in this library and
    // exported via its export directives.
    Set<Element> exportedAndLocalElements =
        _libraryElement.exportNamespace.definedNames.values.toSet();
    // TODO(jcollins-g): Consider switch to [_libraryElement.topLevelElements].
    exportedAndLocalElements
        .addAll(getDefinedElements(_libraryElement.definingCompilationUnit));
    for (CompilationUnitElement cu in _libraryElement.parts) {
      exportedAndLocalElements.addAll(getDefinedElements(cu));
    }
    _exportedAndLocalElements = exportedAndLocalElements.toList();

    _package._allLibraries.add(this);
  }

  static Iterable<Element> getDefinedElements(
      CompilationUnitElement compilationUnit) {
    return quiver.concat([
      compilationUnit.accessors,
      compilationUnit.enums,
      compilationUnit.extensions,
      compilationUnit.functions,
      compilationUnit.functionTypeAliases,
      compilationUnit.mixins,
      compilationUnit.topLevelVariables,
      compilationUnit.types,
    ]);
  }

  List<String> _allOriginalModelElementNames;

  bool get isInSdk => _libraryElement.isInSdk;

  final Package _package;

  @override
  Package get package {
    // Everything must be in a package.  TODO(jcollins-g): Support other things
    // that look like packages.
    assert(_package != null);
    return _package;
  }

  /// [allModelElements] resolved to their original names.
  ///
  /// A collection of [ModelElement.fullyQualifiedName]s for [ModelElement]s
  /// documented with this library, but these ModelElements and names correspond
  /// to the defining library where each originally came from with respect
  /// to inheritance and reexporting.  Most useful for error reporting.
  Iterable<String> get allOriginalModelElementNames {
    if (_allOriginalModelElementNames == null) {
      _allOriginalModelElementNames = allModelElements.map((e) {
        Accessor getter;
        Accessor setter;
        if (e is GetterSetterCombo) {
          if (e.hasGetter) {
            getter = ModelElement.fromElement(e.getter.element, packageGraph);
          }
          if (e.hasSetter) {
            setter = ModelElement.fromElement(e.setter.element, packageGraph);
          }
        }
        return ModelElement.from(
                e.element,
                packageGraph.findButDoNotCreateLibraryFor(e.element),
                packageGraph,
                getter: getter,
                setter: setter)
            .fullyQualifiedName;
      }).toList();
    }
    return _allOriginalModelElementNames;
  }

  @override
  CharacterLocation get characterLocation {
    if (element.nameOffset == -1) {
      assert(isAnonymous,
          'Only anonymous libraries are allowed to have no declared location');
      return CharacterLocation(1, 1);
    }
    return super.characterLocation;
  }

  @override
  CompilationUnitElement get compilationUnitElement =>
      (element as LibraryElement).definingCompilationUnit;

  @override
  Iterable<Class> get classes => allClasses.where((c) => !c.isErrorOrException);

  @override
  Iterable<Extension> get extensions {
    if (_extensions == null) {
      _extensions = _exportedAndLocalElements
          .whereType<ExtensionElement>()
          .map((e) => ModelElement.from(e, this, packageGraph) as Extension)
          .toList(growable: false)
            ..sort(byName);
    }
    return _extensions;
  }

  SdkLibrary get sdkLib {
    if (packageGraph.sdkLibrarySources.containsKey(element.librarySource)) {
      return packageGraph.sdkLibrarySources[element.librarySource];
    }
    return null;
  }

  @override
  bool get isPublic {
    if (!super.isPublic) return false;
    if (sdkLib != null && (sdkLib.isInternal || !sdkLib.isDocumented)) {
      return false;
    }
    if (config.isLibraryExcluded(name) ||
        config.isLibraryExcluded(element.librarySource.uri.toString())) {
      return false;
    }
    return true;
  }

  @override
  Iterable<TopLevelVariable> get constants {
    if (_constants == null) {
      // _getVariables() is already sorted.
      _constants =
          _getVariables().where((v) => v.isConst).toList(growable: false);
    }
    return _constants;
  }

  Set<Library> _packageImportedExportedLibraries;

  /// Returns all libraries either imported by or exported by any public library
  /// this library's package.  (Not [PackageGraph], but sharing a package name).
  ///
  /// Note: will still contain non-public libraries because those can be
  /// imported or exported.
  // TODO(jcollins-g): move this to [Package] once it really knows about
  // more than one package.
  Set<Library> get packageImportedExportedLibraries {
    if (_packageImportedExportedLibraries == null) {
      _packageImportedExportedLibraries = Set();
      packageGraph.publicLibraries
          .where((l) => l.packageName == packageName)
          .forEach((l) {
        _packageImportedExportedLibraries.addAll(l.importedExportedLibraries);
      });
    }
    return _packageImportedExportedLibraries;
  }

  Set<Library> _importedExportedLibraries;

  /// Returns all libraries either imported by or exported by this library,
  /// recursively.
  Set<Library> get importedExportedLibraries {
    if (_importedExportedLibraries == null) {
      _importedExportedLibraries = Set();
      Set<LibraryElement> importedExportedLibraryElements = Set();
      importedExportedLibraryElements
          .addAll((element as LibraryElement).importedLibraries);
      importedExportedLibraryElements
          .addAll((element as LibraryElement).exportedLibraries);
      for (LibraryElement l in importedExportedLibraryElements) {
        Library lib = ModelElement.from(l, library, packageGraph);
        _importedExportedLibraries.add(lib);
        _importedExportedLibraries.addAll(lib.importedExportedLibraries);
      }
    }
    return _importedExportedLibraries;
  }

  Map<String, Set<Library>> _prefixToLibrary;

  /// Map of import prefixes ('import "foo" as prefix;') to [Library].
  Map<String, Set<Library>> get prefixToLibrary {
    if (_prefixToLibrary == null) {
      _prefixToLibrary = {};
      // It is possible to have overlapping prefixes.
      for (ImportElement i in (element as LibraryElement).imports) {
        // Ignore invalid imports.
        if (i.prefix?.name != null && i.importedLibrary != null) {
          _prefixToLibrary.putIfAbsent(i.prefix?.name, () => Set());
          _prefixToLibrary[i.prefix?.name]
              .add(ModelElement.from(i.importedLibrary, library, packageGraph));
        }
      }
    }
    return _prefixToLibrary;
  }

  String _dirName;

  String get dirName {
    if (_dirName == null) {
      _dirName = name;
      if (isAnonymous) {
        _dirName = nameFromPath;
      }
      _dirName = _dirName.replaceAll(':', '-').replaceAll('/', '_');
    }
    return _dirName;
  }

  Set<String> _canonicalFor;

  Set<String> get canonicalFor {
    if (_canonicalFor == null) {
      // TODO(jcollins-g): restructure to avoid using side effects.
      _buildDocumentationAddition(documentationComment);
    }
    return _canonicalFor;
  }

  /// Hide canonicalFor from doc while leaving a note to ourselves to
  /// help with ambiguous canonicalization determination.
  ///
  /// Example:
  ///   {@canonicalFor libname.ClassName}
  @override
  String _buildDocumentationAddition(String rawDocs) {
    rawDocs = super._buildDocumentationAddition(rawDocs);
    Set<String> newCanonicalFor = Set();
    Set<String> notFoundInAllModelElements = Set();
    final canonicalRegExp = RegExp(r'{@canonicalFor\s([^}]+)}');
    rawDocs = rawDocs.replaceAllMapped(canonicalRegExp, (Match match) {
      newCanonicalFor.add(match.group(1));
      notFoundInAllModelElements.add(match.group(1));
      return '';
    });
    if (notFoundInAllModelElements.isNotEmpty) {
      notFoundInAllModelElements.removeAll(allOriginalModelElementNames);
    }
    for (String notFound in notFoundInAllModelElements) {
      warn(PackageWarning.ignoredCanonicalFor, message: notFound);
    }
    // TODO(jcollins-g): warn if a macro/tool _does_ generate an unexpected
    // canonicalFor?
    if (_canonicalFor == null) {
      _canonicalFor = newCanonicalFor;
    }
    return rawDocs;
  }

  /// Libraries are not enclosed by anything.
  @override
  ModelElement get enclosingElement => null;

  @override
  List<Enum> get enums {
    if (_enums == null) {
      _enums = _exportedAndLocalElements
          .whereType<ClassElement>()
          .where((element) => element.isEnum)
          .map((e) => ModelElement.from(e, this, packageGraph) as Enum)
          .toList(growable: false)
            ..sort(byName);
    }
    return _enums;
  }

  @override
  List<Mixin> get mixins {
    if (_mixins == null) {
      /// Can not be [MixinElementImpl] because [ClassHandle]s are sometimes
      /// returned from _exportedElements.
      _mixins = _exportedAndLocalElements
          .whereType<ClassElement>()
          .where((ClassElement c) => c.isMixin)
          .map((e) => ModelElement.from(e, this, packageGraph) as Mixin)
          .toList(growable: false)
            ..sort(byName);
    }
    return _mixins;
  }

  @override
  List<Class> get exceptions {
    if (_exceptions == null) {
      _exceptions =
          allClasses.where((c) => c.isErrorOrException).toList(growable: false);
    }
    return _exceptions;
  }

  @override
  String get fileName => '$dirName-library.html';

  @override
  List<ModelFunction> get functions {
    if (_functions == null) {
      _functions =
          _exportedAndLocalElements.whereType<FunctionElement>().map((e) {
        return ModelElement.from(e, this, packageGraph) as ModelFunction;
      }).toList(growable: false)
            ..sort(byName);
    }
    return _functions;
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    return '${package.baseHref}${library.dirName}/$fileName';
  }

  InheritanceManager3 _inheritanceManager;

  InheritanceManager3 get inheritanceManager {
    if (_inheritanceManager == null) {
      var typeSystem = element.context.typeSystem;
      _inheritanceManager = InheritanceManager3(typeSystem);
    }
    return _inheritanceManager;
  }

  bool get isAnonymous => element.name == null || element.name.isEmpty;

  @override
  String get kind => 'library';

  @override
  Library get library => this;

  @override
  String get name {
    if (_name == null) {
      _name = getLibraryName(element);
    }
    return _name;
  }

  String _nameFromPath;

  /// Generate a name for this library based on its location.
  ///
  /// nameFromPath provides filename collision-proofing for anonymous libraries
  /// by incorporating more from the location of the anonymous library into
  /// the name calculation.  Simple cases (such as an anonymous library in
  /// 'lib') are the same, but this will include slashes and possibly colons
  /// for anonymous libraries in subdirectories or other packages.
  String get nameFromPath {
    if (_nameFromPath == null) {
      _nameFromPath = getNameFromPath(element, packageGraph.driver, package);
    }
    return _nameFromPath;
  }

  /// The real package, as opposed to the package we are documenting it with,
  /// [PackageGraph.name]
  String get packageName => packageMeta?.name ?? '';

  /// The real packageMeta, as opposed to the package we are documenting with.
  PackageMeta _packageMeta;

  PackageMeta get packageMeta {
    if (_packageMeta == null) {
      _packageMeta = PackageMeta.fromElement(element, config);
    }
    return _packageMeta;
  }

  /// All variables ("properties") except constants.
  @override
  Iterable<TopLevelVariable> get properties {
    if (_properties == null) {
      _properties =
          _getVariables().where((v) => !v.isConst).toList(growable: false);
    }
    return _properties;
  }

  @override
  List<Typedef> get typedefs {
    if (_typedefs == null) {
      _typedefs = _exportedAndLocalElements
          .whereType<FunctionTypeAliasElement>()
          .map((e) => ModelElement.from(e, this, packageGraph) as Typedef)
          .toList(growable: false)
            ..sort(byName);
    }
    return _typedefs;
  }

  List<Class> get allClasses {
    if (_classes == null) {
      _classes = _exportedAndLocalElements
          .whereType<ClassElement>()
          .where((e) => !e.isMixin && !e.isEnum)
          .map((e) => ModelElement.from(e, this, packageGraph) as Class)
          .toList(growable: false)
            ..sort(byName);
    }
    return _classes;
  }

  LibraryElement get _libraryElement => (element as LibraryElement);

  Class getClassByName(String name) {
    return allClasses.firstWhere((it) => it.name == name, orElse: () => null);
  }

  List<TopLevelVariable> _getVariables() {
    if (_variables == null) {
      Set<TopLevelVariableElement> elements = _exportedAndLocalElements
          .whereType<TopLevelVariableElement>()
          .toSet();
      elements.addAll(_exportedAndLocalElements
          .whereType<PropertyAccessorElement>()
          .map((a) => a.variable));
      _variables = [];
      for (TopLevelVariableElement element in elements) {
        Accessor getter;
        if (element.getter != null) {
          getter = ModelElement.from(element.getter, this, packageGraph);
        }
        Accessor setter;
        if (element.setter != null) {
          setter = ModelElement.from(element.setter, this, packageGraph);
        }
        ModelElement me = ModelElement.from(element, this, packageGraph,
            getter: getter, setter: setter);
        _variables.add(me);
      }
      _variables.sort(byName);
    }
    return _variables;
  }

  /// Reverses URIs if needed to get a package URI.
  /// Not the same as [PackageGraph.name] because there we always strip all
  /// path components; this function only strips the package prefix if the
  /// library is part of the default package or if it is being documented
  /// remotely.
  static String getNameFromPath(
      LibraryElement element, AnalysisDriver driver, Package package) {
    String name;
    if (element.source.uri.toString().startsWith('dart:')) {
      name = element.source.uri.toString();
    } else {
      name = driver.sourceFactory.restoreUri(element.source).toString();
    }
    PackageMeta hidePackage;
    if (package.documentedWhere == DocumentLocation.remote) {
      hidePackage = package.packageMeta;
    } else {
      hidePackage = package.packageGraph.packageMeta;
    }
    // restoreUri must not result in another file URI.
    assert(!name.startsWith('file:'));

    String defaultPackagePrefix = 'package:$hidePackage/';
    if (name.startsWith(defaultPackagePrefix)) {
      name = name.substring(defaultPackagePrefix.length, name.length);
    }
    if (name.endsWith('.dart')) {
      name = name.substring(0, name.length - '.dart'.length);
    }
    assert(!name.startsWith('file:'));
    return name;
  }

  static String getLibraryName(LibraryElement element) {
    var source = element.source;

    if (source.uri.isScheme('dart')) {
      return '${source.uri}';
    }

    var name = element.name;
    if (name != null && name.isNotEmpty) {
      return name;
    }

    name = path.basename(source.fullName);
    if (name.endsWith('.dart')) {
      name = name.substring(0, name.length - '.dart'.length);
    }
    return name;
  }

  Map<String, Set<ModelElement>> _modelElementsNameMap;

  /// Map of [fullyQualifiedNameWithoutLibrary] to all matching [ModelElement]s
  /// in this library.  Used for code reference lookups.
  Map<String, Set<ModelElement>> get modelElementsNameMap {
    if (_modelElementsNameMap == null) {
      _modelElementsNameMap = Map<String, Set<ModelElement>>();
      allModelElements.forEach((ModelElement modelElement) {
        _modelElementsNameMap.putIfAbsent(
            modelElement.fullyQualifiedNameWithoutLibrary, () => Set());
        _modelElementsNameMap[modelElement.fullyQualifiedNameWithoutLibrary]
            .add(modelElement);
      });
    }
    return _modelElementsNameMap;
  }

  Map<Element, Set<ModelElement>> _modelElementsMap;

  Map<Element, Set<ModelElement>> get modelElementsMap {
    if (_modelElementsMap == null) {
      Iterable<ModelElement> results = quiver.concat([
        library.constants,
        library.functions,
        library.properties,
        library.typedefs,
        library.extensions.expand((e) {
          return quiver.concat([
            [e],
            e.allModelElements
          ]);
        }),
        library.allClasses.expand((c) {
          return quiver.concat([
            [c],
            c.allModelElements
          ]);
        }),
        library.enums.expand((e) {
          return quiver.concat([
            [e],
            e.allModelElements
          ]);
        }),
        library.mixins.expand((m) {
          return quiver.concat([
            [m],
            m.allModelElements
          ]);
        }),
      ]);
      _modelElementsMap = Map<Element, Set<ModelElement>>();
      results.forEach((modelElement) {
        _modelElementsMap.putIfAbsent(modelElement.element, () => Set());
        _modelElementsMap[modelElement.element].add(modelElement);
      });
      _modelElementsMap.putIfAbsent(element, () => Set());
      _modelElementsMap[element].add(this);
    }
    return _modelElementsMap;
  }

  List<ModelElement> _allModelElements;

  Iterable<ModelElement> get allModelElements {
    if (_allModelElements == null) {
      _allModelElements = [];
      for (Set<ModelElement> modelElements in modelElementsMap.values) {
        _allModelElements.addAll(modelElements);
      }
    }
    return _allModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;

  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allModelElements.where((e) => e.isCanonical).toList());
  }
}

class Method extends ModelElement
    with ContainerMember, Inheritable, TypeParameters
    implements EnclosedElement {
  bool _isInherited = false;
  Container _enclosingContainer;
  @override
  List<TypeParameter> typeParameters = [];

  Method(MethodElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null) {
    _calcTypeParameters();
  }

  Method.inherited(MethodElement element, this._enclosingContainer,
      Library library, PackageGraph packageGraph,
      {Member originalMember})
      : super(element, library, packageGraph, originalMember) {
    _isInherited = true;
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = _method.typeParameters.map((f) {
      return ModelElement.from(f, library, packageGraph) as TypeParameter;
    }).toList();
  }

  @override
  CharacterLocation get characterLocation {
    if (enclosingElement is Enum && name == 'toString') {
      // The toString() method on Enums is special, treated as not having
      // a definition location by the analyzer yet not being inherited, either.
      // Just directly override our location with the Enum definition --
      // this is OK because Enums can not inherit from each other nor
      // have their definitions split between files.
      return enclosingElement.characterLocation;
    }
    return super.characterLocation;
  }

  @override
  ModelElement get enclosingElement {
    if (_enclosingContainer == null) {
      _enclosingContainer =
          ModelElement.from(_method.enclosingElement, library, packageGraph);
    }
    return _enclosingContainer;
  }

  String get fullkind {
    if (_method.isAbstract) return 'abstract $kind';
    return kind;
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(!(canonicalLibrary == null || canonicalEnclosingContainer == null));
    assert(canonicalLibrary == library);
    assert(canonicalEnclosingContainer == enclosingElement);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.name}/${fileName}';
  }

  @override
  bool get isInherited => _isInherited;

  bool get isOperator => false;

  @override
  Set<String> get features {
    Set<String> allFeatures = super.features;
    if (isInherited) allFeatures.add('inherited');
    return allFeatures;
  }

  @override
  bool get isStatic => _method.isStatic;

  @override
  String get kind => 'method';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  DefinedElementType get modelType => super.modelType;

  @override
  Method get overriddenElement {
    if (_enclosingContainer is Extension) {
      return null;
    }
    ClassElement parent = element.enclosingElement;
    for (InterfaceType t in parent.allSupertypes) {
      Element e = t.getMethod(element.name);
      if (e != null) {
        assert(e.enclosingElement is ClassElement);
        return ModelElement.fromElement(e, packageGraph);
      }
    }
    return null;
  }

  MethodElement get _method => (element as MethodElement);

  /// Methods can not be covariant; always returns false.
  @override
  bool get isCovariant => false;
}

/// This class represents the score for a particular element; how likely
/// it is that this is the canonical element.
class ScoredCandidate implements Comparable<ScoredCandidate> {
  final List<String> reasons = [];

  /// The canonicalization element being scored.
  final Canonicalization element;
  final Library library;

  /// The score accumulated so far.  Higher means it is more likely that this
  /// is the intended canonical Library.
  double score = 0.0;

  ScoredCandidate(this.element, this.library);

  void alterScore(double scoreDelta, String reason) {
    score += scoreDelta;
    if (scoreDelta != 0) {
      reasons.add(
          "${reason} (${scoreDelta >= 0 ? '+' : ''}${scoreDelta.toStringAsPrecision(4)})");
    }
  }

  @override
  int compareTo(ScoredCandidate other) {
    //assert(element == other.element);
    return score.compareTo(other.score);
  }

  @override
  String toString() =>
      "${library.name}: ${score.toStringAsPrecision(4)} - ${reasons.join(', ')}";
}

// TODO(jcollins-g): Implement resolution per ECMA-408 4th edition, page 39 #22.
/// Resolves this very rare case incorrectly by picking the closest element in
/// the inheritance and interface chains from the analyzer.
ModelElement resolveMultiplyInheritedElement(
    MultiplyInheritedExecutableElement e,
    Library library,
    PackageGraph packageGraph,
    Class enclosingClass) {
  Iterable<Inheritable> inheritables = e.inheritedElements
      .map((ee) => ModelElement.fromElement(ee, packageGraph) as Inheritable);
  Inheritable foundInheritable;
  int lowIndex = enclosingClass.inheritanceChain.length;
  for (var inheritable in inheritables) {
    int index =
        enclosingClass.inheritanceChain.indexOf(inheritable.enclosingElement);
    if (index < lowIndex) {
      foundInheritable = inheritable;
      lowIndex = index;
    }
  }
  return ModelElement.from(foundInheritable.element, library, packageGraph,
      enclosingContainer: enclosingClass);
}

/// Classes implementing this have a public/private distinction.
abstract class Privacy {
  bool get isPublic;
}

/// This class is the foundation of Dartdoc's model for source code.
/// All ModelElements are contained within a [PackageGraph], and laid out in a
/// structure that mirrors the availability of identifiers in the various
/// namespaces within that package.  For example, multiple [Class] objects
/// for a particular identifier ([ModelElement.element]) may show up in
/// different [Library]s as the identifier is reexported.
///
/// However, ModelElements have an additional concept vital to generating
/// documentation: canonicalization.
///
/// A ModelElement is canonical if it is the element in the namespace where that
/// element 'comes from' in the public interface to this [PackageGraph].  That often
/// means the [ModelElement.library] is contained in [PackageGraph.libraries], but
/// there are many exceptions and ambiguities the code tries to address here.
///
/// Non-canonical elements should refer to their canonical counterparts, making
/// it easy to calculate links via [ModelElement.href] without having to
/// know in a particular namespace which elements are canonical or not.
/// A number of [PackageGraph] methods, such as [PackageGraph.findCanonicalModelElementFor]
/// can help with this.
///
/// When documenting, Dartdoc should only write out files corresponding to
/// canonical instances of ModelElement ([ModelElement.isCanonical]).  This
/// helps prevent subtle bugs as generated output for a non-canonical
/// ModelElement will reference itself as part of the "wrong" [Library]
/// from the public interface perspective.
abstract class ModelElement extends Canonicalization
    with Privacy, Warnable, Locatable, Nameable, SourceCodeMixin, Indexable
    implements Comparable, Documentable {
  final Element _element;

  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Member _originalMember;
  final Library _library;

  ElementType _modelType;
  String _rawDocs;
  Documentation __documentation;
  UnmodifiableListView<Parameter> _parameters;
  String _linkedName;

  String _fullyQualifiedName;
  String _fullyQualifiedNameWithoutLibrary;

  // TODO(jcollins-g): make _originalMember optional after dart-lang/sdk#15101
  // is fixed.
  ModelElement(
      this._element, this._library, this._packageGraph, this._originalMember);

  factory ModelElement.fromElement(Element e, PackageGraph p) {
    Library lib = p.findButDoNotCreateLibraryFor(e);
    Accessor getter;
    Accessor setter;
    if (e is PropertyInducingElement) {
      getter = e.getter != null ? ModelElement.from(e.getter, lib, p) : null;
      setter = e.setter != null ? ModelElement.from(e.setter, lib, p) : null;
    }
    return ModelElement.from(e, lib, p, getter: getter, setter: setter);
  }

  // TODO(jcollins-g): this way of using the optional parameter is messy,
  // clean that up.
  // TODO(jcollins-g): Refactor this into class-specific factories that
  // call this one.
  // TODO(jcollins-g): Enforce construction restraint.
  // TODO(jcollins-g): Allow e to be null and drop extraneous null checks.
  // TODO(jcollins-g): Auto-vivify element's defining library for library
  // parameter when given a null.
  /// Do not construct any ModelElements unless they are from this constructor.
  /// Specify enclosingContainer if and only if this is to be an inherited or
  /// extended object.
  factory ModelElement.from(
      Element e, Library library, PackageGraph packageGraph,
      {Container enclosingContainer, Accessor getter, Accessor setter}) {
    assert(packageGraph != null && e != null);
    assert(library != null ||
        e is ParameterElement ||
        e is TypeParameterElement ||
        e is GenericFunctionTypeElementImpl ||
        e.kind == ElementKind.DYNAMIC);

    Member originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      var basest = PackageGraph.getBasestElement(e);
      originalMember = e;
      e = basest;
    }
    Tuple3<Element, Library, Container> key =
        Tuple3(e, library, enclosingContainer);
    ModelElement newModelElement;
    if (e.kind != ElementKind.DYNAMIC &&
        packageGraph._allConstructedModelElements.containsKey(key)) {
      newModelElement = packageGraph._allConstructedModelElements[key];
      assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    } else {
      if (e.kind == ElementKind.DYNAMIC) {
        newModelElement = Dynamic(e, packageGraph);
      }
      if (e is MultiplyInheritedExecutableElement) {
        newModelElement = resolveMultiplyInheritedElement(
            e, library, packageGraph, enclosingContainer);
      } else {
        if (e is LibraryElement) {
          newModelElement = Library(e, packageGraph);
        }
        // Also handles enums
        if (e is ClassElement) {
          if (e.isMixin) {
            newModelElement = Mixin(e, library, packageGraph);
          } else if (e.isEnum) {
            newModelElement = Enum(e, library, packageGraph);
          } else {
            newModelElement = Class(e, library, packageGraph);
          }
        }
        if (e is ExtensionElement) {
          newModelElement = Extension(e, library, packageGraph);
        }
        if (e is FunctionElement) {
          newModelElement = ModelFunction(e, library, packageGraph);
        } else if (e is GenericFunctionTypeElement) {
          // TODO(scheglov) "e" cannot be both GenericFunctionTypeElement,
          // and FunctionTypeAliasElement or GenericTypeAliasElement.
          if (e is FunctionTypeAliasElement) {
            assert(e.name != '');
            newModelElement = ModelFunctionTypedef(e, library, packageGraph);
          } else {
            if (e.enclosingElement is GenericTypeAliasElement) {
              assert(e.enclosingElement.name != '');
              newModelElement = ModelFunctionTypedef(e, library, packageGraph);
            } else {
              // Allowing null here is allowed as a workaround for
              // dart-lang/sdk#32005.
              assert(e.name == '' || e.name == null);
              newModelElement = ModelFunctionAnonymous(e, packageGraph);
            }
          }
        }
        if (e is FunctionTypeAliasElement) {
          newModelElement = Typedef(e, library, packageGraph);
        }
        if (e is FieldElement) {
          if (enclosingContainer == null) {
            if (e.isEnumConstant) {
              int index =
                  e.computeConstantValue().getField(e.name).toIntValue();
              newModelElement = EnumField.forConstant(
                  index, e, library, packageGraph, getter);
              // ignore: unnecessary_cast
            } else if (e.enclosingElement is ExtensionElement) {
              newModelElement = Field(e, library, packageGraph, getter, setter);
            } else if (e.enclosingElement is ClassElement &&
                (e.enclosingElement as ClassElement).isEnum) {
              newModelElement =
                  EnumField(e, library, packageGraph, getter, setter);
            } else {
              newModelElement = Field(e, library, packageGraph, getter, setter);
            }
          } else {
            // EnumFields can't be inherited, so this case is simpler.
            newModelElement = Field.inherited(
                e, enclosingContainer, library, packageGraph, getter, setter);
          }
        }
        if (e is ConstructorElement) {
          newModelElement = Constructor(e, library, packageGraph);
        }
        if (e is MethodElement && e.isOperator) {
          if (enclosingContainer == null) {
            newModelElement = Operator(e, library, packageGraph);
          } else {
            newModelElement = Operator.inherited(
                e, enclosingContainer, library, packageGraph,
                originalMember: originalMember);
          }
        }
        if (e is MethodElement && !e.isOperator) {
          if (enclosingContainer == null) {
            newModelElement = Method(e, library, packageGraph);
          } else {
            newModelElement = Method.inherited(
                e, enclosingContainer, library, packageGraph,
                originalMember: originalMember);
          }
        }
        if (e is TopLevelVariableElement) {
          assert(getter != null || setter != null);
          newModelElement =
              TopLevelVariable(e, library, packageGraph, getter, setter);
        }
        if (e is PropertyAccessorElement) {
          // TODO(jcollins-g): why test for ClassElement in enclosingElement?
          if (e.enclosingElement is ClassElement ||
              e is MultiplyInheritedExecutableElement) {
            if (enclosingContainer == null) {
              newModelElement = ContainerAccessor(e, library, packageGraph);
            } else {
              newModelElement = ContainerAccessor.inherited(
                  e, library, packageGraph, enclosingContainer,
                  originalMember: originalMember);
            }
          } else {
            newModelElement = Accessor(e, library, packageGraph, null);
          }
        }
        if (e is TypeParameterElement) {
          newModelElement = TypeParameter(e, library, packageGraph);
        }
        if (e is ParameterElement) {
          newModelElement = Parameter(e, library, packageGraph,
              originalMember: originalMember);
        }
      }
    }

    if (newModelElement == null) throw "Unknown type ${e.runtimeType}";
    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    if (library != null && newModelElement is! Parameter) {
      library.packageGraph._allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        Tuple2<Element, Library> iKey = Tuple2(e, library);
        library.packageGraph._allInheritableElements
            .putIfAbsent(iKey, () => Set());
        library.packageGraph._allInheritableElements[iKey].add(newModelElement);
      }
    }
    if (newModelElement is GetterSetterCombo) {
      assert(getter == null || newModelElement?.getter?.enclosingCombo != null);
      assert(setter == null || newModelElement?.setter?.enclosingCombo != null);
    }

    assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    return newModelElement;
  }

  /// Stub for mustache4dart, or it will search enclosing elements to find
  /// names for members.
  bool get hasCategoryNames => false;

  Set<Library> get exportedInLibraries {
    return library
        .packageGraph.libraryElementReexportedBy[this.element.library];
  }

  ModelNode _modelNode;

  @override
  ModelNode get modelNode =>
      _modelNode ??= packageGraph._getModelNodeFor(element);

  List<String> get annotations => annotationsFromMetadata(element.metadata);

  /// Returns linked annotations from a given metadata set, with escaping.
  List<String> annotationsFromMetadata(List<ElementAnnotation> md) {
    List<String> annotationStrings = [];
    if (md == null) return annotationStrings;
    for (ElementAnnotation a in md) {
      String annotation = (const HtmlEscape()).convert(a.toSource());
      Element annotationElement = a.element;

      ClassElement annotationClassElement;
      if (annotationElement is ExecutableElement) {
        annotationElement =
            (annotationElement as ExecutableElement).returnType.element;
      }
      if (annotationElement is ClassElement) {
        annotationClassElement = annotationElement;
      }
      ModelElement annotationModelElement =
          packageGraph.findCanonicalModelElementFor(annotationElement);
      // annotationElement can be null if the element can't be resolved.
      Class annotationClass = packageGraph
          .findCanonicalModelElementFor(annotationClassElement) as Class;
      if (annotationClass == null &&
          annotationElement != null &&
          annotationClassElement != null) {
        annotationClass =
            ModelElement.fromElement(annotationClassElement, packageGraph)
                as Class;
      }
      // Some annotations are intended to be invisible (@pragma)
      if (annotationClass == null ||
          !packageGraph.invisibleAnnotations.contains(annotationClass)) {
        if (annotationModelElement != null) {
          annotation = annotation.replaceFirst(
              annotationModelElement.name, annotationModelElement.linkedName);
        }
        annotationStrings.add(annotation);
      }
    }
    return annotationStrings;
  }

  bool _isPublic;

  @override
  bool get isPublic {
    if (_isPublic == null) {
      if (name == '') {
        _isPublic = false;
      } else if (this is! Library && (library == null || !library.isPublic)) {
        _isPublic = false;
      } else if (enclosingElement is Class &&
          !(enclosingElement as Class).isPublic) {
        _isPublic = false;
      } else if (enclosingElement is Extension &&
          !(enclosingElement as Extension).isPublic) {
        _isPublic = false;
      } else {
        String docComment = documentationComment;
        if (docComment == null) {
          _isPublic = utils.hasPublicName(element);
        } else {
          _isPublic = utils.hasPublicName(element) &&
              !(docComment.contains('@nodoc') ||
                  docComment.contains('<nodoc>'));
        }
      }
    }
    return _isPublic;
  }

  @override
  List<ModelCommentReference> get commentRefs {
    if (_commentRefs == null) {
      _commentRefs = [];
      for (ModelElement from in documentationFrom) {
        List<ModelElement> checkReferences = [from];
        if (from is Accessor) {
          checkReferences.add(from.enclosingCombo);
        }
        for (ModelElement e in checkReferences) {
          _commentRefs.addAll(e.modelNode.commentRefs ?? []);
        }
      }
    }
    return _commentRefs;
  }

  DartdocOptionContext _config;

  @override
  DartdocOptionContext get config {
    if (_config == null) {
      _config =
          DartdocOptionContext.fromContextElement(packageGraph.config, element);
    }
    return _config;
  }

  @override
  Set<String> get locationPieces {
    return Set.from(element.location
        .toString()
        .split(locationSplitter)
        .where((s) => s.isNotEmpty));
  }

  Set<String> get features {
    Set<String> allFeatures = Set<String>();
    allFeatures.addAll(annotations);

    // Replace the @override annotation with a feature that explicitly
    // indicates whether an override has occurred.
    allFeatures.remove('@override');

    // Drop the plain "deprecated" annotation, that's indicated via
    // strikethroughs. Custom @Deprecated() will still appear.
    allFeatures.remove('@deprecated');
    // const and static are not needed here because const/static elements get
    // their own sections in the doc.
    if (isFinal) allFeatures.add('final');
    return allFeatures;
  }

  String get featuresAsString {
    List<String> allFeatures = features.toList()..sort(byFeatureOrdering);
    return allFeatures.join(', ');
  }

  bool get canHaveParameters =>
      element is ExecutableElement ||
      element is FunctionTypedElement ||
      element is FunctionTypeAliasElement;

  ModelElement _buildCanonicalModelElement() {
    Container preferredClass;
    if (enclosingElement is Class || enclosingElement is Extension) {
      preferredClass = enclosingElement;
    }
    return packageGraph.findCanonicalModelElementFor(element,
        preferredClass: preferredClass);
  }

  // Returns the canonical ModelElement for this ModelElement, or null
  // if there isn't one.
  ModelElement _canonicalModelElement;

  ModelElement get canonicalModelElement =>
      _canonicalModelElement ??= _buildCanonicalModelElement();

  List<ModelElement> _documentationFrom;

  // TODO(jcollins-g): untangle when mixins can call super
  @override
  List<ModelElement> get documentationFrom {
    if (_documentationFrom == null) {
      _documentationFrom = computeDocumentationFrom;
    }
    return _documentationFrom;
  }

  bool get hasSourceHref => sourceHref.isNotEmpty;
  String _sourceHref;

  String get sourceHref {
    _sourceHref ??= SourceLinker.fromElement(this).href();
    return _sourceHref;
  }

  /// Returns the ModelElement(s) from which we will get documentation.
  /// Can be more than one if this is a Field composing documentation from
  /// multiple Accessors.
  ///
  /// This getter will walk up the inheritance hierarchy
  /// to find docs, if the current class doesn't have docs
  /// for this element.
  List<ModelElement> get computeDocumentationFrom {
    List<ModelElement> docFrom;

    if (documentationComment == null &&
        canOverride() &&
        this is Inheritable &&
        (this as Inheritable).overriddenElement != null) {
      docFrom = (this as Inheritable).overriddenElement.documentationFrom;
    } else if (this is Inheritable && (this as Inheritable).isInherited) {
      Inheritable thisInheritable = (this as Inheritable);
      ModelElement fromThis = ModelElement.fromElement(
          element, thisInheritable.definingEnclosingContainer.packageGraph);
      docFrom = fromThis.documentationFrom;
    } else {
      docFrom = [this];
    }
    return docFrom;
  }

  String _buildDocumentationLocal() => _buildDocumentationBaseSync();

  /// Override this to add more features to the documentation builder in a
  /// subclass.
  String _buildDocumentationAddition(String docs) => docs ??= '';

  /// Separate from _buildDocumentationLocal for overriding.
  String _buildDocumentationBaseSync() {
    assert(_rawDocs == null,
        'reentrant calls to _buildDocumentation* not allowed');
    // Do not use the sync method if we need to evaluate tools or templates.
    assert(!isCanonical ||
        !needsPrecacheRegExp.hasMatch(documentationComment ?? ''));
    if (config.dropTextFrom.contains(element.library.name)) {
      _rawDocs = '';
    } else {
      _rawDocs = documentationComment ?? '';
      _rawDocs = stripComments(_rawDocs) ?? '';
      _rawDocs = _injectExamples(_rawDocs);
      _rawDocs = _injectYouTube(_rawDocs);
      _rawDocs = _injectAnimations(_rawDocs);
      _rawDocs = _stripHtmlAndAddToIndex(_rawDocs);
    }
    _rawDocs = _buildDocumentationAddition(_rawDocs);
    return _rawDocs;
  }

  /// Separate from _buildDocumentationLocal for overriding.  Can only be
  /// used as part of [PackageGraph.setUpPackageGraph].
  Future<String> _buildDocumentationBase() async {
    assert(_rawDocs == null,
        'reentrant calls to _buildDocumentation* not allowed');
    // Do not use the sync method if we need to evaluate tools or templates.
    if (config.dropTextFrom.contains(element.library.name)) {
      _rawDocs = '';
    } else {
      _rawDocs = documentationComment ?? '';
      _rawDocs = stripComments(_rawDocs) ?? '';
      // Must evaluate tools first, in case they insert any other directives.
      _rawDocs = await _evaluateTools(_rawDocs);
      _rawDocs = _injectExamples(_rawDocs);
      _rawDocs = _injectYouTube(_rawDocs);
      _rawDocs = _injectAnimations(_rawDocs);
      _rawDocs = _stripMacroTemplatesAndAddToIndex(_rawDocs);
      _rawDocs = _stripHtmlAndAddToIndex(_rawDocs);
    }
    _rawDocs = _buildDocumentationAddition(_rawDocs);
    return _rawDocs;
  }

  /// Returns the documentation for this literal element unless
  /// [config.dropTextFrom] indicates it should not be returned.  Macro
  /// definitions are stripped, but macros themselves are not injected.  This
  /// is a two stage process to avoid ordering problems.
  String _documentationLocal;

  String get documentationLocal =>
      _documentationLocal ??= _buildDocumentationLocal();

  /// Returns the docs, stripped of their leading comments syntax.
  @override
  String get documentation {
    return _injectMacros(
        documentationFrom.map((e) => e.documentationLocal).join('<p>'));
  }

  Library get definingLibrary =>
      packageGraph.findButDoNotCreateLibraryFor(element);

  Library _canonicalLibrary;

  // _canonicalLibrary can be null so we can't check against null to see whether
  // we tried to compute it before.
  bool _canonicalLibraryIsSet = false;

  @override
  Library get canonicalLibrary {
    if (!_canonicalLibraryIsSet) {
      // This is not accurate if we are constructing the Package.
      assert(packageGraph.allLibrariesAdded);
      // Since we're may be looking for a library, find the [Element] immediately
      // contained by a [CompilationUnitElement] in the tree.
      Element topLevelElement = element;
      while (topLevelElement != null &&
          topLevelElement.enclosingElement is! LibraryElement &&
          topLevelElement.enclosingElement is! CompilationUnitElement &&
          topLevelElement.enclosingElement != null) {
        topLevelElement = topLevelElement.enclosingElement;
      }

      // Privately named elements can never have a canonical library, so
      // just shortcut them out.
      if (!utils.hasPublicName(element)) {
        _canonicalLibrary = null;
      } else if (!packageGraph.localPublicLibraries.contains(definingLibrary)) {
        List<Library> candidateLibraries = definingLibrary.exportedInLibraries
            ?.where((l) =>
                l.isPublic &&
                l.package.documentedWhere != DocumentLocation.missing)
            ?.toList();

        if (candidateLibraries != null) {
          candidateLibraries = candidateLibraries.where((l) {
            Element lookup = (l.element as LibraryElement)
                .exportNamespace
                .definedNames[topLevelElement?.name];
            if (lookup is PropertyAccessorElement) {
              lookup = (lookup as PropertyAccessorElement).variable;
            }
            if (topLevelElement == lookup) return true;
            return false;
          }).toList();

          // Avoid claiming canonicalization for elements outside of this element's
          // defining package.
          // TODO(jcollins-g): Make the else block unconditional.
          if (candidateLibraries.isNotEmpty &&
              !candidateLibraries
                  .any((l) => l.package == definingLibrary.package)) {
            warn(PackageWarning.reexportedPrivateApiAcrossPackages,
                message: definingLibrary.package.fullyQualifiedName,
                referredFrom: candidateLibraries);
          } else {
            candidateLibraries
                .removeWhere((l) => l.package != definingLibrary.package);
          }

          // Start with our top-level element.
          ModelElement warnable =
              ModelElement.fromElement(topLevelElement, packageGraph);
          if (candidateLibraries.length > 1) {
            // Heuristic scoring to determine which library a human likely
            // considers this element to be primarily 'from', and therefore,
            // canonical.  Still warn if the heuristic isn't that confident.
            List<ScoredCandidate> scoredCandidates =
                warnable.scoreCanonicalCandidates(candidateLibraries);
            candidateLibraries =
                scoredCandidates.map((s) => s.library).toList();
            double secondHighestScore =
                scoredCandidates[scoredCandidates.length - 2].score;
            double highestScore = scoredCandidates.last.score;
            double confidence = highestScore - secondHighestScore;
            String message =
                "${candidateLibraries.map((l) => l.name)} -> ${candidateLibraries.last.name} (confidence ${confidence.toStringAsPrecision(4)})";
            List<String> debugLines = [];
            debugLines.addAll(scoredCandidates.map((s) => '${s.toString()}'));

            if (confidence < config.ambiguousReexportScorerMinConfidence) {
              warnable.warn(PackageWarning.ambiguousReexport,
                  message: message, extendedDebug: debugLines);
            }
          }
          if (candidateLibraries.isNotEmpty) {
            _canonicalLibrary = candidateLibraries.last;
          }
        }
      } else {
        _canonicalLibrary = definingLibrary;
      }
      // Only pretend when not linking to remote packages.
      if (this is Inheritable && !config.linkToRemote) {
        if ((this as Inheritable).isInherited &&
            _canonicalLibrary == null &&
            packageGraph.publicLibraries.contains(library)) {
          // In the event we've inherited a field from an object that isn't directly reexported,
          // we may need to pretend we are canonical for this.
          _canonicalLibrary = library;
        }
      }
      _canonicalLibraryIsSet = true;
    }
    assert(_canonicalLibrary == null ||
        packageGraph.publicLibraries.contains(_canonicalLibrary));
    return _canonicalLibrary;
  }

  @override
  bool get isCanonical {
    if (library == canonicalLibrary) {
      if (this is Inheritable) {
        Inheritable i = (this as Inheritable);
        // If we're the defining element, or if the defining element is not
        // in the set of libraries being documented, then this element
        // should be treated as canonical (given library == canonicalLibrary).
        if (i.enclosingElement == i.canonicalEnclosingContainer) {
          return true;
        } else {
          return false;
        }
      }
      // If there's no inheritance to deal with, we're done.
      return true;
    }
    return false;
  }

  String _htmlDocumentation;

  @override
  String get documentationAsHtml {
    if (_htmlDocumentation != null) return _htmlDocumentation;
    _htmlDocumentation = _injectHtmlFragments(_documentation.asHtml);
    return _htmlDocumentation;
  }

  @override
  Element get element => _element;

  @override
  String get location {
    // Call nothing from here that can emit warnings or you'll cause stack overflows.
    if (characterLocation != null) {
      return "(${path.toUri(sourceFileName)}:${characterLocation.toString()})";
    }
    return "(${path.toUri(sourceFileName)})";
  }

  /// Returns a link to extended documentation, or the empty string if that
  /// does not exist.
  String get extendedDocLink {
    if (hasExtendedDocumentation) {
      return '<a href="${href}">[...]</a>';
    }
    return '';
  }

  String get fileName => "${name}.html";

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  @override
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  String get fullyQualifiedNameWithoutLibrary {
    // Remember, periods are legal in library names.
    if (_fullyQualifiedNameWithoutLibrary == null) {
      _fullyQualifiedNameWithoutLibrary =
          fullyQualifiedName.replaceFirst("${library.fullyQualifiedName}.", '');
    }
    return _fullyQualifiedNameWithoutLibrary;
  }

  String get sourceFileName => element.source.fullName;

  CharacterLocation _characterLocation;
  bool _characterLocationIsSet = false;

  @override
  CharacterLocation get characterLocation {
    if (!_characterLocationIsSet) {
      LineInfo lineInfo = compilationUnitElement.lineInfo;
      _characterLocationIsSet = true;
      assert(element.nameOffset >= 0,
          'Invalid location data for element: $fullyQualifiedName');
      assert(lineInfo != null,
          'No lineInfo data available for element: $fullyQualifiedName');
      if (element.nameOffset >= 0) {
        _characterLocation = lineInfo?.getLocation(element.nameOffset);
      }
    }
    return _characterLocation;
  }

  CompilationUnitElement get compilationUnitElement =>
      element.getAncestor((e) => e is CompilationUnitElement);

  bool get hasAnnotations => annotations.isNotEmpty;

  @override
  bool get hasDocumentation =>
      documentation != null && documentation.isNotEmpty;

  @override
  bool get hasExtendedDocumentation =>
      href != null && _documentation.hasExtendedDocs;

  bool get hasParameters => parameters.isNotEmpty;

  /// If canonicalLibrary (or canonicalEnclosingElement, for Inheritable
  /// subclasses) is null, href should be null.
  @override
  String get href;

  String get htmlId => name;

  bool get isAsynchronous =>
      isExecutable && (element as ExecutableElement).isAsynchronous;

  bool get isConst => false;

  bool get isDeprecated {
    // If element.metadata is empty, it might be because this is a property
    // where the metadata belongs to the individual getter/setter
    if (element.metadata.isEmpty && element is PropertyInducingElement) {
      var pie = element as PropertyInducingElement;

      // The getter or the setter might be null – so the stored value may be
      // `true`, `false`, or `null`
      var getterDeprecated = pie.getter?.metadata?.any((a) => a.isDeprecated);
      var setterDeprecated = pie.setter?.metadata?.any((a) => a.isDeprecated);

      var deprecatedValues =
          [getterDeprecated, setterDeprecated].where((a) => a != null).toList();

      // At least one of these should be non-null. Otherwise things are weird
      assert(deprecatedValues.isNotEmpty);

      // If there are both a setter and getter, only show the property as
      // deprecated if both are deprecated.
      return deprecatedValues.every((d) => d);
    }
    return element.metadata.any((a) => a.isDeprecated);
  }

  @override
  bool get isDocumented => isCanonical && isPublic;

  bool get isExecutable => element is ExecutableElement;

  bool get isFinal => false;

  bool get isLocalElement => element is LocalElement;

  bool get isPropertyAccessor => element is PropertyAccessorElement;

  bool get isPropertyInducer => element is PropertyInducingElement;

  bool get isStatic {
    if (isPropertyInducer) {
      return (element as PropertyInducingElement).isStatic;
    }
    return false;
  }

  /// A human-friendly name for the kind of element this is.
  @override
  String get kind;

  @override
  Library get library => _library;

  String get linkedName {
    if (_linkedName == null) {
      _linkedName = _calculateLinkedName();
    }
    return _linkedName;
  }

  String get linkedParams => utils.linkedParams(parameters);

  String get linkedParamsLines => utils.linkedParams(parameters).trim();

  String get linkedParamsNoMetadata =>
      utils.linkedParams(parameters, showMetadata: false);

  String get linkedParamsNoMetadataOrNames {
    return utils.linkedParams(parameters,
        showMetadata: false, showNames: false);
  }

  ElementType get modelType {
    if (_modelType == null) {
      // TODO(jcollins-g): Need an interface for a "member with a type" (or changed object model).
      if (_originalMember != null &&
          (_originalMember is ExecutableMember ||
              _originalMember is ParameterMember)) {
        if (_originalMember is ExecutableMember) {
          _modelType = ElementType.from(
              (_originalMember as ExecutableMember).type,
              library,
              packageGraph);
        } else {
          // ParameterMember
          _modelType = ElementType.from(
              (_originalMember as ParameterMember).type, library, packageGraph);
        }
      } else if (element is ExecutableElement ||
          element is FunctionTypedElement ||
          element is ParameterElement ||
          element is TypeDefiningElement ||
          element is PropertyInducingElement) {
        _modelType =
            ElementType.from((element as dynamic).type, library, packageGraph);
      }
    }
    return _modelType;
  }

  @override
  String get name => element.name;

  // TODO(jcollins-g): refactor once dartdoc will only run in a VM where mixins
  // calling super is allowed (SDK constraint >= 2.1.0).
  String computeOneLineDoc() =>
      '${_documentation.asOneLiner}${extendedDocLink.isEmpty ? "" : " $extendedDocLink"}';
  String _oneLineDoc;

  @override
  String get oneLineDoc {
    if (_oneLineDoc == null) {
      _oneLineDoc = computeOneLineDoc();
    }
    return _oneLineDoc;
  }

  Member get originalMember => _originalMember;

  final PackageGraph _packageGraph;

  @override
  PackageGraph get packageGraph => _packageGraph;

  @override
  Package get package => library.package;

  bool get isPublicAndPackageDocumented =>
      isPublic && library.packageGraph.packageDocumentedFor(this);

  List<Parameter> _allParameters;

  // TODO(jcollins-g): This is in the wrong place.  Move parts to GetterSetterCombo,
  // elsewhere as appropriate?
  List<Parameter> get allParameters {
    if (_allParameters == null) {
      final Set<Parameter> recursedParameters = Set();
      final Set<Parameter> newParameters = Set();
      if (this is GetterSetterCombo &&
          (this as GetterSetterCombo).setter != null) {
        newParameters.addAll((this as GetterSetterCombo).setter.parameters);
      } else {
        if (canHaveParameters) newParameters.addAll(parameters);
      }
      while (newParameters.isNotEmpty) {
        recursedParameters.addAll(newParameters);
        newParameters.clear();
        for (Parameter p in recursedParameters) {
          var l = p.modelType.parameters
              .where((pm) => !recursedParameters.contains(pm));
          newParameters.addAll(l);
        }
      }
      _allParameters = recursedParameters.toList();
    }
    return _allParameters;
  }

  List<Parameter> get parameters {
    if (!canHaveParameters) {
      throw StateError("$element cannot have parameters");
    }

    if (_parameters == null) {
      List<ParameterElement> params;

      if (element is ExecutableElement) {
        if (_originalMember != null) {
          assert(_originalMember is ExecutableMember);
          params = (_originalMember as ExecutableMember).parameters;
        } else {
          params = (element as ExecutableElement).parameters;
        }
      }
      if (params == null && element is FunctionTypedElement) {
        if (_originalMember != null) {
          params = (_originalMember as dynamic).parameters;
        } else {
          params = (element as FunctionTypedElement).parameters;
        }
      }
      if (params == null && element is FunctionTypeAliasElement) {
        params = (element as FunctionTypeAliasElement).function.parameters;
      }

      _parameters = UnmodifiableListView<Parameter>(params
          .map((p) => ModelElement.from(p, library, packageGraph) as Parameter)
          .toList());
    }
    return _parameters;
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

  String _computeDocumentationComment() => element.documentationComment;

  bool _documentationCommentComputed = false;
  String _documentationComment;

  String get documentationComment {
    if (_documentationCommentComputed == false) {
      _documentationComment = _computeDocumentationComment();
      _documentationCommentComputed = true;
    }
    return _documentationComment;
  }

  /// Unconditionally precache local documentation.
  ///
  /// Use only in factory for [PackageGraph].
  Future _precacheLocalDocs() async {
    _documentationLocal = await _buildDocumentationBase();
  }

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = Documentation.forElement(this);
    return __documentation;
  }

  bool canOverride() =>
      element is ClassMemberElement || element is PropertyAccessorElement;

  @override
  int compareTo(dynamic other) {
    if (other is ModelElement) {
      return name.toLowerCase().compareTo(other.name.toLowerCase());
    } else {
      return 0;
    }
  }

  @override
  String toString() => '$runtimeType $name';

  String _buildFullyQualifiedName([ModelElement e, String fqName]) {
    e ??= this;
    fqName ??= e.name;

    if (e is! EnclosedElement || e.enclosingElement == null) {
      return fqName;
    }

    return _buildFullyQualifiedName(
        e.enclosingElement, '${e.enclosingElement.name}.$fqName');
  }

  String _calculateLinkedName() {
    // If we're calling this with an empty name, we probably have the wrong
    // element associated with a ModelElement or there's an analysis bug.
    assert(name.isNotEmpty ||
        this.element?.kind == ElementKind.DYNAMIC ||
        this is ModelFunction);

    if (href == null) {
      if (isPublicAndPackageDocumented) {
        warn(PackageWarning.noCanonicalFound);
      }
      return htmlEscape.convert(name);
    }

    var classContent = isDeprecated ? ' class="deprecated"' : '';
    return '<a${classContent} href="${href}">$name</a>';
  }

  /// Replace &#123;@example ...&#125; in API comments with the content of named file.
  ///
  /// Syntax:
  ///
  ///     &#123;@example PATH [region=NAME] [lang=NAME]&#125;
  ///
  /// If PATH is `dir/file.ext` and region is `r` then we'll look for the file
  /// named `dir/file-r.ext.md`, relative to the project root directory of the
  /// project for which the docs are being generated.
  ///
  /// Examples: (escaped in this comment to show literal values in dartdoc's
  ///            dartdoc)
  ///
  ///     &#123;@example examples/angular/quickstart/web/main.dart&#125;
  ///     &#123;@example abc/def/xyz_component.dart region=template lang=html&#125;
  ///
  String _injectExamples(String rawdocs) {
    final dirPath = package.packageMeta.dir.path;
    RegExp exampleRE = RegExp(r'{@example\s+([^}]+)}');
    return rawdocs.replaceAllMapped(exampleRE, (match) {
      var args = _getExampleArgs(match[1]);
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      var lang =
          args['lang'] ?? path.extension(args['src']).replaceFirst('.', '');

      var replacement = match[0]; // default to fully matched string.

      var fragmentFile = File(path.join(dirPath, args['file']));
      if (fragmentFile.existsSync()) {
        replacement = fragmentFile.readAsStringSync();
        if (lang.isNotEmpty) {
          replacement = replacement.replaceFirst('```', '```$lang');
        }
      } else {
        // TODO(jcollins-g): move this to Package.warn system
        var filePath =
            this.element.source.fullName.substring(dirPath.length + 1);

        logWarning(
            'warning: ${filePath}: @example file not found, ${fragmentFile.path}');
      }
      return replacement;
    });
  }

  static Future<String> _replaceAllMappedAsync(
      String string, Pattern exp, Future<String> replace(Match match)) async {
    StringBuffer replaced = StringBuffer();
    int currentIndex = 0;
    for (Match match in exp.allMatches(string)) {
      String prefix = match.input.substring(currentIndex, match.start);
      currentIndex = match.end;
      replaced..write(prefix)..write(await replace(match));
    }
    replaced.write(string.substring(currentIndex));
    return replaced.toString();
  }

  /// Replace &#123;@tool ...&#125&#123;@end-tool&#125; in API comments with the
  /// output of an external tool.
  ///
  /// Looks for tools invocations, looks up their bound executables in the
  /// options, and executes them with the source comment material as input,
  /// returning the output of the tool. If a named tool isn't configured in the
  /// options file, then it will not be executed, and dartdoc will quit with an
  /// error.
  ///
  /// Tool command line arguments are passed to the tool, with the token
  /// `$INPUT` replaced with the absolute path to a temporary file containing
  /// the content for the tool to read and produce output from. If the tool
  /// doesn't need any input, then no `$INPUT` is needed.
  ///
  /// Nested tool directives will not be evaluated, but tools may generate other
  /// directives in their output and those will be evaluated.
  ///
  /// Syntax:
  ///
  ///     &#123;@tool TOOL [Tool arguments]&#125;
  ///     Content to send to tool.
  ///     &#123;@end-tool&#125;
  ///
  /// Examples:
  ///
  /// In `dart_options.yaml`:
  ///
  /// ```yaml
  /// dartdoc:
  ///   tools:
  ///     # Prefixes the given input with "## "
  ///     # Path is relative to project root.
  ///     prefix: "bin/prefix.dart"
  ///     # Prints the date
  ///     date: "/bin/date"
  /// ```
  ///
  /// In code:
  ///
  /// _This:_
  ///
  ///     &#123;@tool prefix $INPUT&#125;
  ///     Content to send to tool.
  ///     &#123;@end-tool&#125;
  ///     &#123;@tool date --iso-8601=minutes --utc&#125;
  ///     &#123;@end-tool&#125;
  ///
  /// _Produces:_
  ///
  /// ## Content to send to tool.
  /// 2018-09-18T21:15+00:00
  Future<String> _evaluateTools(String rawDocs) async {
    if (config.allowTools) {
      int invocationIndex = 0;
      return await _replaceAllMappedAsync(rawDocs, basicToolRegExp,
          (basicMatch) async {
        List<String> args = _splitUpQuotedArgs(basicMatch[1]).toList();
        // Tool name must come first.
        if (args.isEmpty) {
          warn(PackageWarning.toolError,
              message:
                  'Must specify a tool to execute for the @tool directive.');
          return Future.value('');
        }
        // Count the number of invocations of tools in this dartdoc block,
        // so that tools can differentiate different blocks from each other.
        invocationIndex++;
        return await config.tools.runner.run(
            args,
            (String message) async =>
                warn(PackageWarning.toolError, message: message),
            content: basicMatch[2],
            environment: {
              'SOURCE_LINE': characterLocation?.lineNumber.toString(),
              'SOURCE_COLUMN': characterLocation?.columnNumber.toString(),
              'SOURCE_PATH': (sourceFileName == null ||
                      package?.packagePath == null)
                  ? null
                  : path.relative(sourceFileName, from: package.packagePath),
              'PACKAGE_PATH': package?.packagePath,
              'PACKAGE_NAME': package?.name,
              'LIBRARY_NAME': library?.fullyQualifiedName,
              'ELEMENT_NAME': fullyQualifiedNameWithoutLibrary,
              'INVOCATION_INDEX': invocationIndex.toString(),
              'PACKAGE_INVOCATION_INDEX':
                  (package.toolInvocationIndex++).toString(),
            }..removeWhere((key, value) => value == null));
      });
    } else {
      return rawDocs;
    }
  }

  /// Replace &#123;@youtube ...&#125; in API comments with some HTML to embed
  /// a YouTube video.
  ///
  /// Syntax:
  ///
  ///     &#123;@youtube WIDTH HEIGHT URL&#125;
  ///
  /// Example:
  ///
  ///     &#123;@youtube 560 315 https://www.youtube.com/watch?v=oHg5SJYRHA0&#125;
  ///
  /// Which will embed a YouTube player into the page that plays the specified
  /// video.
  ///
  /// The width and height must be positive integers specifying the dimensions
  /// of the video in pixels. The height and width are used to calculate the
  /// aspect ratio of the video; the video is always rendered to take up all
  /// available horizontal space to accommodate different screen sizes on
  /// desktop and mobile.
  ///
  /// The video URL must have the following format:
  /// https://www.youtube.com/watch?v=oHg5SJYRHA0. This format can usually be
  /// found in the address bar of the browser when viewing a YouTube video.
  String _injectYouTube(String rawDocs) {
    // Matches all youtube directives (even some invalid ones). This is so
    // we can give good error messages if the directive is malformed, instead of
    // just silently emitting it as-is.
    final RegExp basicAnimationRegExp = RegExp(r'''{@youtube\s+([^}]+)}''');

    // Matches YouTube IDs from supported YouTube URLs.
    final RegExp validYouTubeUrlRegExp =
        RegExp('https://www\.youtube\.com/watch\\?v=([^&]+)\$');

    return rawDocs.replaceAllMapped(basicAnimationRegExp, (basicMatch) {
      final ArgParser parser = ArgParser();
      final ArgResults args = _parseArgs(basicMatch[1], parser, 'youtube');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      final List<String> positionalArgs = args.rest.sublist(0);
      if (positionalArgs.length != 3) {
        warn(PackageWarning.invalidParameter,
            message: 'Invalid @youtube directive, "${basicMatch[0]}"\n'
                'YouTube directives must be of the form "{@youtube WIDTH '
                'HEIGHT URL}"');
        return '';
      }

      final int width = int.tryParse(positionalArgs[0]);
      if (width == null || width <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid width, '
                '"${positionalArgs[0]}". The width must be a positive integer.');
      }

      final int height = int.tryParse(positionalArgs[1]);
      if (height == null || height <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid height, '
                '"${positionalArgs[1]}". The height must be a positive integer.');
      }

      final Match url = validYouTubeUrlRegExp.firstMatch(positionalArgs[2]);
      if (url == null) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid URL: '
                '"${positionalArgs[2]}". Supported YouTube URLs have the '
                'follwing format: https://www.youtube.com/watch?v=oHg5SJYRHA0.');
        return '';
      }
      final String youTubeId = url.group(url.groupCount);
      final String aspectRatio = (height / width * 100).toStringAsFixed(2);

      // Blank lines before and after, and no indenting at the beginning and end
      // is needed so that Markdown doesn't confuse this with code, so be
      // careful of whitespace here.
      return '''

<p style="position: relative;
          padding-top: $aspectRatio%;">
  <iframe src="https://www.youtube.com/embed/$youTubeId?rel=0"
          frameborder="0"
          allow="accelerometer;
                 autoplay;
                 encrypted-media;
                 gyroscope;
                 picture-in-picture"
          allowfullscreen
          style="position: absolute;
                 top: 0;
                 left: 0;
                 width: 100%;
                 height: 100%;">
  </iframe>
</p>

'''; // String must end at beginning of line, or following inline text will be
      // indented.
    });
  }

  /// Replace &#123;@animation ...&#125; in API comments with some HTML to manage an
  /// MPEG 4 video as an animation.
  ///
  /// Syntax:
  ///
  ///     &#123;@animation WIDTH HEIGHT URL [id=ID]&#125;
  ///
  /// Example:
  ///
  ///     &#123;@animation 300 300 https://example.com/path/to/video.mp4 id="my_video"&#125;
  ///
  /// Which will render the HTML necessary for embedding a simple click-to-play
  /// HTML5 video player with no controls that has an HTML id of "my_video".
  ///
  /// The optional ID should be a unique id that is a valid JavaScript
  /// identifier, and will be used as the id for the video tag. If no ID is
  /// supplied, then a unique identifier (starting with "animation_") will be
  /// generated.
  ///
  /// The width and height must be integers specifying the dimensions of the
  /// video file in pixels.
  String _injectAnimations(String rawDocs) {
    // Matches all animation directives (even some invalid ones). This is so
    // we can give good error messages if the directive is malformed, instead of
    // just silently emitting it as-is.
    final RegExp basicAnimationRegExp = RegExp(r'''{@animation\s+([^}]+)}''');

    // Matches valid javascript identifiers.
    final RegExp validIdRegExp = RegExp(r'^[a-zA-Z_]\w*$');

    // Make sure we have a set to keep track of used IDs for this href.
    package.usedAnimationIdsByHref[href] ??= {};

    String getUniqueId(String base) {
      int animationIdCount = 1;
      String id = '$base$animationIdCount';
      // We check for duplicate IDs so that we make sure not to collide with
      // user-supplied ids on the same page.
      while (package.usedAnimationIdsByHref[href].contains(id)) {
        animationIdCount++;
        id = '$base$animationIdCount';
      }
      return id;
    }

    return rawDocs.replaceAllMapped(basicAnimationRegExp, (basicMatch) {
      final ArgParser parser = ArgParser();
      parser.addOption('id');
      final ArgResults args = _parseArgs(basicMatch[1], parser, 'animation');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      final List<String> positionalArgs = args.rest.sublist(0);
      String uniqueId;
      bool wasDeprecated = false;
      if (positionalArgs.length == 4) {
        // Supports the original form of the animation tag for backward
        // compatibility.`
        uniqueId = positionalArgs.removeAt(0);
        wasDeprecated = true;
      } else if (positionalArgs.length == 3) {
        uniqueId = args['id'] ?? getUniqueId('animation_');
      } else {
        warn(PackageWarning.invalidParameter,
            message: 'Invalid @animation directive, "${basicMatch[0]}"\n'
                'Animation directives must be of the form "{@animation WIDTH '
                'HEIGHT URL [id=ID]}"');
        return '';
      }

      if (!validIdRegExp.hasMatch(uniqueId)) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid identifier, "$uniqueId". The '
                'identifier can only contain letters, numbers and underscores, '
                'and must not begin with a number.');
        return '';
      }
      if (package.usedAnimationIdsByHref[href].contains(uniqueId)) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has a non-unique identifier, "$uniqueId". '
                'Animation identifiers must be unique.');
        return '';
      }
      package.usedAnimationIdsByHref[href].add(uniqueId);

      int width;
      try {
        width = int.parse(positionalArgs[0]);
      } on FormatException {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid width ($uniqueId), '
                '"${positionalArgs[0]}". The width must be an integer.');
        return '';
      }

      int height;
      try {
        height = int.parse(positionalArgs[1]);
      } on FormatException {
        warn(PackageWarning.invalidParameter,
            message: 'An animation has an invalid height ($uniqueId), '
                '"${positionalArgs[1]}". The height must be an integer.');
        return '';
      }

      Uri movieUrl;
      try {
        movieUrl = Uri.parse(positionalArgs[2]);
      } on FormatException catch (e) {
        warn(PackageWarning.invalidParameter,
            message: 'An animation URL could not be parsed ($uniqueId): '
                '${positionalArgs[2]}\n$e');
        return '';
      }
      final String overlayId = '${uniqueId}_play_button_';

      // Only warn about deprecation if some other warning didn't occur.
      if (wasDeprecated) {
        warn(PackageWarning.deprecated,
            message:
                'Deprecated form of @animation directive, "${basicMatch[0]}"\n'
                'Animation directives are now of the form "{@animation '
                'WIDTH HEIGHT URL [id=ID]}" (id is an optional '
                'parameter)');
      }

      // Blank lines before and after, and no indenting at the beginning and end
      // is needed so that Markdown doesn't confuse this with code, so be
      // careful of whitespace here.
      return '''

<div style="position: relative;">
  <div id="${overlayId}"
       onclick="var $uniqueId = document.getElementById('$uniqueId');
                if ($uniqueId.paused) {
                  $uniqueId.play();
                  this.style.display = 'none';
                } else {
                  $uniqueId.pause();
                  this.style.display = 'block';
                }"
       style="position:absolute;
              width:${width}px;
              height:${height}px;
              z-index:100000;
              background-position: center;
              background-repeat: no-repeat;
              background-image: url(static-assets/play_button.svg);">
  </div>
  <video id="$uniqueId"
         style="width:${width}px; height:${height}px;"
         onclick="var $overlayId = document.getElementById('$overlayId');
                  if (this.paused) {
                    this.play();
                    $overlayId.style.display = 'none';
                  } else {
                    this.pause();
                    $overlayId.style.display = 'block';
                  }" loop>
    <source src="$movieUrl" type="video/mp4"/>
  </video>
</div>

'''; // String must end at beginning of line, or following inline text will be
      // indented.
    });
  }

  /// Replace &lt;<dartdoc-html>[digest]</dartdoc-html>&gt; in API comments with
  /// the contents of the HTML fragment earlier defined by the
  /// &#123;@inject-html&#125; directive. The [digest] is a SHA1 of the contents
  /// of the HTML fragment, automatically generated upon parsing the
  /// &#123;@inject-html&#125; directive.
  ///
  /// This markup is generated and inserted by [_stripHtmlAndAddToIndex] when it
  /// removes the HTML fragment in preparation for markdown processing. It isn't
  /// meant to be used at a user level.
  ///
  /// Example:
  ///
  /// You place the fragment in a dartdoc comment:
  ///
  ///     Some comments
  ///     &#123;@inject-html&#125;
  ///     &lt;p&gt;[HTML contents!]&lt;/p&gt;
  ///     &#123;@endtemplate&#125;
  ///     More comments
  ///
  /// and [_stripHtmlAndAddToIndex] will replace your HTML fragment with this:
  ///
  ///     Some comments
  ///     &lt;dartdoc-html&gt;4cc02f877240bf69855b4c7291aba8a16e5acce0&lt;/dartdoc-html&gt;
  ///     More comments
  ///
  /// Which will render in the final HTML output as:
  ///
  ///     Some comments
  ///     &lt;p&gt;[HTML contents!]&lt;/p&gt;
  ///     More comments
  ///
  /// And the HTML fragment will not have been processed or changed by Markdown,
  /// but just injected verbatim.
  String _injectHtmlFragments(String rawDocs) {
    if (!config.injectHtml) return rawDocs;

    return rawDocs.replaceAllMapped(htmlInjectRegExp, (match) {
      String fragment = packageGraph.getHtmlFragment(match[1]);
      if (fragment == null) {
        warn(PackageWarning.unknownHtmlFragment, message: match[1]);
      }
      return fragment;
    });
  }

  /// Replace &#123;@macro ...&#125; in API comments with the contents of the macro
  ///
  /// Syntax:
  ///
  ///     &#123;@macro NAME&#125;
  ///
  /// Example:
  ///
  /// You define the template in any comment for a documentable entity like:
  ///
  ///     &#123;@template foo&#125;
  ///     Foo contents!
  ///     &#123;@endtemplate&#125;
  ///
  /// and them somewhere use it like this:
  ///
  ///     Some comments
  ///     &#123;@macro foo&#125;
  ///     More comments
  ///
  /// Which will render
  ///
  ///     Some comments
  ///     Foo contents!
  ///     More comments
  ///
  String _injectMacros(String rawDocs) {
    return rawDocs.replaceAllMapped(macroRegExp, (match) {
      String macro = packageGraph.getMacro(match[1]);
      if (macro == null) {
        warn(PackageWarning.unknownMacro, message: match[1]);
      }
      return macro;
    });
  }

  /// Parse and remove &#123;@template ...&#125; in API comments and store them
  /// in the index on the package.
  ///
  /// Syntax:
  ///
  ///     &#123;@template NAME&#125;
  ///     The contents of the macro
  ///     &#123;@endtemplate&#125;
  ///
  String _stripMacroTemplatesAndAddToIndex(String rawDocs) {
    return rawDocs.replaceAllMapped(templateRegExp, (match) {
      packageGraph._addMacro(match[1].trim(), match[2].trim());
      return "{@macro ${match[1].trim()}}";
    });
  }

  /// Parse and remove &#123;@inject-html ...&#125; in API comments and store
  /// them in the index on the package, replacing them with a SHA1 hash of the
  /// contents, where the HTML will be re-injected after Markdown processing of
  /// the rest of the text is complete.
  ///
  /// Syntax:
  ///
  ///     &#123;@inject-html&#125;
  ///     <p>The HTML to inject.</p>
  ///     &#123;@end-inject-html&#125;
  ///
  String _stripHtmlAndAddToIndex(String rawDocs) {
    if (!config.injectHtml) return rawDocs;
    return rawDocs.replaceAllMapped(htmlRegExp, (match) {
      String fragment = match[1];
      String digest = sha1.convert(fragment.codeUnits).toString();
      packageGraph._addHtmlFragment(digest, fragment);
      // The newlines are so that Markdown will pass this through without
      // touching it.
      return '\n<dartdoc-html>$digest</dartdoc-html>\n';
    });
  }

  /// Helper to process arguments given as a (possibly quoted) string.
  ///
  /// First, this will split the given [argsAsString] into separate arguments,
  /// taking any quoting (either ' or " are accepted) into account, including
  /// handling backslash-escaped quotes.
  ///
  /// Then, it will prepend "--" to any args that start with an identifier
  /// followed by an equals sign, allowing the argument parser to treat any
  /// "foo=bar" argument as "--foo=bar". It does handle quoted args like
  /// "foo='bar baz'" too, returning just bar (without quotes) for the foo
  /// value.
  Iterable<String> _splitUpQuotedArgs(String argsAsString,
      {bool convertToArgs = false}) {
    final Iterable<Match> matches = argMatcher.allMatches(argsAsString);
    // Remove quotes around args, and if convertToArgs is true, then for any
    // args that look like assignments (start with valid option names followed
    // by an equals sign), add a "--" in front so that they parse as options.
    return matches.map<String>((Match match) {
      var option = '';
      if (convertToArgs && match[1] != null && !match[1].startsWith('-')) {
        option = '--';
      }
      if (match[2] != null) {
        // This arg has quotes, so strip them.
        return '$option${match[1] ?? ''}${match[3] ?? ''}${match[4] ?? ''}';
      }
      return '$option${match[0]}';
    });
  }

  /// Helper to process arguments given as a (possibly quoted) string.
  ///
  /// First, this will split the given [argsAsString] into separate arguments
  /// with [_splitUpQuotedArgs] it then parses the resulting argument list
  /// normally with [argParser] and returns the result.
  ArgResults _parseArgs(
      String argsAsString, ArgParser argParser, String directiveName) {
    var args = _splitUpQuotedArgs(argsAsString, convertToArgs: true);
    try {
      return argParser.parse(args);
    } on ArgParserException catch (e) {
      warn(PackageWarning.invalidParameter,
          message: 'The {@$directiveName ...} directive was called with '
              'invalid parameters. $e');
      return null;
    }
  }

  /// Helper for _injectExamples used to process @example arguments.
  /// Returns a map of arguments. The first unnamed argument will have key 'src'.
  /// The computed file path, constructed from 'src' and 'region' will have key
  /// 'file'.
  Map<String, String> _getExampleArgs(String argsAsString) {
    ArgParser parser = ArgParser();
    parser.addOption('lang');
    parser.addOption('region');
    ArgResults results = _parseArgs(argsAsString, parser, 'example');
    if (results == null) {
      return null;
    }

    // Extract PATH and fix the path separators.
    final String src = results.rest.isEmpty
        ? ''
        : results.rest.first.replaceAll('/', Platform.pathSeparator);
    final Map<String, String> args = <String, String>{
      'src': src,
      'lang': results['lang'],
      'region': results['region'] ?? '',
    };

    // Compute 'file' from region and src.
    final fragExtension = '.md';
    var file = src + fragExtension;
    var region = args['region'] ?? '';
    if (region.isNotEmpty) {
      var dir = path.dirname(src);
      var basename = path.basenameWithoutExtension(src);
      var ext = path.extension(src);
      file = path.join(dir, '$basename-$region$ext$fragExtension');
    }
    args['file'] = config.examplePathPrefix == null
        ? file
        : path.join(config.examplePathPrefix, file);
    return args;
  }
}

/// A [ModelElement] for a [FunctionElement] that isn't part of a type definition.
class ModelFunction extends ModelFunctionTyped with Categorization {
  ModelFunction(
      FunctionElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  bool get isStatic {
    return _func.isStatic;
  }

  @override
  String get name => element.name ?? '';

  @override
  FunctionElement get _func => (element as FunctionElement);
}

/// A [ModelElement] for a [FunctionTypedElement] that is an
/// explicit typedef.
///
/// Distinct from ModelFunctionTypedef in that it doesn't
/// have a name, but we document it as "Function" to match how these are
/// written in declarations.
class ModelFunctionAnonymous extends ModelFunctionTyped {
  ModelFunctionAnonymous(
      FunctionTypedElement element, PackageGraph packageGraph)
      : super(element, null, packageGraph);

  @override
  ModelElement get enclosingElement {
    // These are not considered to be a part of libraries, so we can simply
    // blindly instantiate a ModelElement for their enclosing element.
    return ModelElement.fromElement(element.enclosingElement, packageGraph);
  }

  @override
  String get name => 'Function';

  @override
  String get linkedName => 'Function';

  @override
  bool get isPublic => false;
}

/// A [ModelElement] for a [FunctionTypedElement] that is part of an
/// explicit typedef.
class ModelFunctionTypedef extends ModelFunctionTyped {
  ModelFunctionTypedef(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  @override
  String get name {
    Element e = element;
    while (e != null) {
      if (e is FunctionTypeAliasElement || e is GenericTypeAliasElement) {
        return e.name;
      }
      e = e.enclosingElement;
    }
    assert(false);
    return super.name;
  }
}

class ModelFunctionTyped extends ModelElement
    with TypeParameters
    implements EnclosedElement {
  @override
  List<TypeParameter> typeParameters = [];

  ModelFunctionTyped(
      FunctionTypedElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null) {
    _calcTypeParameters();
  }

  void _calcTypeParameters() {
    typeParameters = _func.typeParameters.map((f) {
      return ModelElement.from(f, library, packageGraph) as TypeParameter;
    }).toList();
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${library.dirName}/$fileName';
  }

  @override
  String get kind => 'function';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  // Food for mustache. TODO(jcollins-g): what about enclosing elements?
  bool get isInherited => false;

  @override
  DefinedElementType get modelType => super.modelType;

  FunctionTypedElement get _func => (element as FunctionTypedElement);
}

/// Something that has a name.
abstract class Nameable {
  String get name;

  String get fullyQualifiedName => name;

  Set<String> _namePieces;

  Set<String> get namePieces {
    if (_namePieces == null) {
      _namePieces = Set()
        ..addAll(name.split(locationSplitter).where((s) => s.isNotEmpty));
    }
    return _namePieces;
  }

  String _namePart;

  /// Utility getter/cache for [_MarkdownCommentReference._getResultsForClass].
  String get namePart {
    // TODO(jcollins-g): This should really be the same as 'name', but isn't
    // because of accessors and operators.
    if (_namePart == null) {
      _namePart = fullyQualifiedName.split('.').last;
    }
    return _namePart;
  }

  @override
  String toString() => name;
}

/// Something able to be indexed.
abstract class Indexable implements Nameable {
  String get href;

  String get kind;

  int get overriddenDepth => 0;
}

class Operator extends Method {
  static const Map<String, String> friendlyNames = {
    "[]": "get",
    "[]=": "put",
    "~": "bitwise_negate",
    "==": "equals",
    "-": "minus",
    "+": "plus",
    "*": "multiply",
    "/": "divide",
    "<": "less",
    ">": "greater",
    ">=": "greater_equal",
    "<=": "less_equal",
    "<<": "shift_left",
    ">>": "shift_right",
    "^": "bitwise_exclusive_or",
    "unary-": "unary_minus",
    "|": "bitwise_or",
    "&": "bitwise_and",
    "~/": "truncate_divide",
    "%": "modulo"
  };

  Operator(MethodElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph);

  Operator.inherited(MethodElement element, Class enclosingClass,
      Library library, PackageGraph packageGraph, {Member originalMember})
      : super.inherited(element, enclosingClass, library, packageGraph,
            originalMember: originalMember) {
    _isInherited = true;
  }

  @override
  String get fileName {
    var actualName = super.name;
    if (friendlyNames.containsKey(actualName)) {
      return "operator_${friendlyNames[actualName]}.html";
    } else {
      return '$actualName.html';
    }
  }

  @override
  String get fullyQualifiedName =>
      '${library.name}.${enclosingElement.name}.${super.name}';

  @override
  bool get isOperator => true;

  @override
  String get name {
    return 'operator ${super.name}';
  }
}

class PackageGraph {
  PackageGraph.UninitializedPackageGraph(
      this.config, this.driver, this.typeSystem, this.sdk, this.hasEmbedderSdk)
      : packageMeta = config.topLevelPackageMeta,
        session = driver.currentSession {
    _packageWarningCounter = PackageWarningCounter(this);
    // Make sure the default package exists, even if it has no libraries.
    // This can happen for packages that only contain embedder SDKs.
    Package.fromPackageMeta(packageMeta, this);
  }

  /// Call during initialization to add a library to this [PackageGraph].
  ///
  /// Libraries added in this manner are assumed to be part of documented
  /// packages, even if includes or embedder.yaml files cause these to
  /// span packages.
  void addLibraryToGraph(ResolvedLibraryResult result) {
    assert(!allLibrariesAdded);
    LibraryElement element = result.element;
    var packageMeta = PackageMeta.fromElement(element, config);
    var lib =
        Library._(result, this, Package.fromPackageMeta(packageMeta, this));
    packageMap[packageMeta.name]._libraries.add(lib);
    allLibraries[element] = lib;
  }

  /// Call during initialization to add a library possibly containing
  /// special/non-documented elements to this [PackageGraph].  Must be called
  /// after any normal libraries.
  void addSpecialLibraryToGraph(ResolvedLibraryResult result) {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    findOrCreateLibraryFor(result);
  }

  /// Call after all libraries are added.
  Future<void> initializePackageGraph() async {
    allLibrariesAdded = true;
    assert(!_localDocumentationBuilt);
    // From here on in, we might find special objects.  Initialize the
    // specialClasses handler so when we find them, they get added.
    specialClasses = SpecialClasses();
    // Go through docs of every ModelElement in package to pre-build the macros
    // index.  Uses toList() in order to get all the precaching on the stack.
    List<Future> precacheFutures = precacheLocalDocs().toList();
    for (Future f in precacheFutures) {
      await f;
    }
    _localDocumentationBuilt = true;

    // Scan all model elements to insure that interceptor and other special
    // objects are found.
    // After the allModelElements traversal to be sure that all packages
    // are picked up.
    documentedPackages.toList().forEach((package) {
      package._libraries.sort((a, b) => compareNatural(a.name, b.name));
      package._libraries.forEach((library) {
        library.allClasses.forEach(_addToImplementors);
        // TODO(jcollins-g): Use a better data structure.
        _extensions.addAll(library.extensions);
      });
    });
    _implementors.values.forEach((l) => l.sort());
    allImplementorsAdded = true;
    _extensions.sort(byName);
    allExtensionsAdded = true;

    // We should have found all special classes by now.
    specialClasses.assertSpecials();
  }

  /// Generate a list of futures for any docs that actually require precaching.
  Iterable<Future> precacheLocalDocs() sync* {
    // Prevent reentrancy.
    Set<ModelElement> precachedElements = Set();

    Iterable<Future> precacheOneElement(ModelElement m) sync* {
      for (ModelElement d
          in m.documentationFrom.where((d) => d.documentationComment != null)) {
        if (needsPrecacheRegExp.hasMatch(d.documentationComment) &&
            !precachedElements.contains(d)) {
          precachedElements.add(d);
          yield d._precacheLocalDocs();
          // TopLevelVariables get their documentation from getters and setters,
          // so should be precached if either has a template.
          if (m is TopLevelVariable) {
            precachedElements.add(m);
            yield m._precacheLocalDocs();
          }
        }
      }
    }

    for (ModelElement m in allModelElements) {
      // Skip if there is a canonicalModelElement somewhere else we can run this
      // for.  Not the same as allCanonicalModelElements since we need to run
      // for any ModelElement that might not have a canonical ModelElement,
      // too.
      if (m.canonicalModelElement != null && !m.isCanonical) continue;
      yield* precacheOneElement(m);
    }
  }

  // Many ModelElements have the same ModelNode; don't build/cache this data more
  // than once for them.
  final Map<Element, ModelNode> _modelNodes = Map();

  void _populateModelNodeFor(
      Element element, Map<String, CompilationUnit> compilationUnitMap) {
    _modelNodes.putIfAbsent(
        element,
        () =>
            ModelNode(utils.getAstNode(element, compilationUnitMap), element));
  }

  ModelNode _getModelNodeFor(Element element) => _modelNodes[element];

  SpecialClasses specialClasses;

  /// It is safe to cache values derived from the [_implementors] table if this
  /// is true.
  bool allImplementorsAdded = false;

  /// It is safe to cache values derived from the [_extensions] table if this
  /// is true.
  bool allExtensionsAdded = false;

  Map<String, List<Class>> get implementors {
    assert(allImplementorsAdded);
    return _implementors;
  }

  Iterable<Extension> get extensions {
    assert(allExtensionsAdded);
    return _extensions;
  }

  Map<String, Set<ModelElement>> _findRefElementCache;

  Map<String, Set<ModelElement>> get findRefElementCache {
    if (_findRefElementCache == null) {
      assert(packageGraph.allLibrariesAdded);
      _findRefElementCache = Map();
      for (final modelElement
          in utils.filterNonDocumented(packageGraph.allLocalModelElements)) {
        _findRefElementCache.putIfAbsent(
            modelElement.fullyQualifiedNameWithoutLibrary, () => Set());
        _findRefElementCache.putIfAbsent(
            modelElement.fullyQualifiedName, () => Set());
        _findRefElementCache[modelElement.fullyQualifiedName].add(modelElement);
        _findRefElementCache[modelElement.fullyQualifiedNameWithoutLibrary]
            .add(modelElement);
      }
    }
    return _findRefElementCache;
  }

  // All library objects related to this package; a superset of _libraries.
  final Map<LibraryElement, Library> allLibraries = Map();

  /// Keep track of warnings
  PackageWarningCounter _packageWarningCounter;

  /// All ModelElements constructed for this package; a superset of [allModelElements].
  final Map<Tuple3<Element, Library, Container>, ModelElement>
      _allConstructedModelElements = Map();

  /// Anything that might be inheritable, place here for later lookup.
  final Map<Tuple2<Element, Library>, Set<ModelElement>>
      _allInheritableElements = Map();

  /// Map of Class.href to a list of classes implementing that class
  final Map<String, List<Class>> _implementors = Map();

  /// A list of extensions that exist in the package graph.
  // TODO(jcollins-g): Consider implementing a smarter structure for this.
  final List<Extension> _extensions = List();

  /// PackageMeta for the default package.
  final PackageMeta packageMeta;

  /// Name of the default package.
  String get defaultPackageName => packageMeta.name;

  /// Dartdoc's configuration flags.
  final DartdocOptionContext config;

  Package _defaultPackage;

  Package get defaultPackage {
    if (_defaultPackage == null) {
      _defaultPackage = Package.fromPackageMeta(packageMeta, this);
    }
    return _defaultPackage;
  }

  final bool hasEmbedderSdk;

  bool get hasFooterVersion => !config.excludeFooterVersion;

  PackageGraph get packageGraph => this;

  /// Map of package name to Package.
  final Map<String, Package> packageMap = {};

  /// TODO(brianwilkerson) Replace the driver with the session.
  final AnalysisDriver driver;
  final AnalysisSession session;
  final TypeSystem typeSystem;
  final DartSdk sdk;

  Map<Source, SdkLibrary> _sdkLibrarySources;

  Map<Source, SdkLibrary> get sdkLibrarySources {
    if (_sdkLibrarySources == null) {
      _sdkLibrarySources = Map();
      for (SdkLibrary lib in sdk?.sdkLibraries) {
        _sdkLibrarySources[sdk.mapDartUri(lib.shortName)] = lib;
      }
    }
    return _sdkLibrarySources;
  }

  final Map<String, String> _macros = {};
  final Map<String, String> _htmlFragments = {};
  bool allLibrariesAdded = false;
  bool _localDocumentationBuilt = false;

  /// Returns true if there's at least one library documented in the package
  /// that has the same package path as the library for the given element.
  /// Usable as a cross-check for dartdoc's canonicalization to generate
  /// warnings for ModelElement.isPublicAndPackageDocumented.
  Set<String> _allRootDirs;

  bool packageDocumentedFor(ModelElement element) {
    if (_allRootDirs == null) {
      _allRootDirs = Set()
        ..addAll(publicLibraries.map((l) => l.packageMeta?.resolvedDir));
    }
    return (_allRootDirs.contains(element.library.packageMeta?.resolvedDir));
  }

  PackageWarningCounter get packageWarningCounter => _packageWarningCounter;

  final Set<Tuple3<Element, PackageWarning, String>> _warnAlreadySeen = Set();

  void warnOnElement(Warnable warnable, PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    var newEntry = Tuple3(warnable?.element, kind, message);
    if (_warnAlreadySeen.contains(newEntry)) {
      return;
    }
    // Warnings can cause other warnings.  Queue them up via the stack but
    // don't allow warnings we're already working on to get in there.
    _warnAlreadySeen.add(newEntry);
    _warnOnElement(warnable, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
    _warnAlreadySeen.remove(newEntry);
  }

  void _warnOnElement(Warnable warnable, PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    if (warnable != null) {
      // This sort of warning is only applicable to top level elements.
      if (kind == PackageWarning.ambiguousReexport) {
        while (warnable.enclosingElement is! Library &&
            warnable.enclosingElement != null) {
          warnable = warnable.enclosingElement;
        }
      }
    } else {
      // If we don't have an element, we need a message to disambiguate.
      assert(message != null);
    }
    if (_packageWarningCounter.hasWarning(warnable, kind, message)) {
      return;
    }
    // Some kinds of warnings it is OK to drop if we're not documenting them.
    // TODO(jcollins-g): drop this and use new flag system instead.
    if (warnable != null &&
        skipWarningIfNotDocumentedFor.contains(kind) &&
        !warnable.isDocumented) {
      return;
    }
    // Elements that are part of the Dart SDK can have colons in their FQNs.
    // This confuses IntelliJ and makes it so it can't link to the location
    // of the error in the console window, so separate out the library from
    // the path.
    // TODO(jcollins-g): What about messages that may include colons?  Substituting
    //                   them out doesn't work as well there since it might confuse
    //                   the user, yet we still want IntelliJ to link properly.
    final warnableName = _safeWarnableName(warnable);

    String warnablePrefix = 'from';
    String referredFromPrefix = 'referred to by';
    String warningMessage;
    switch (kind) {
      case PackageWarning.noCanonicalFound:
        // Fix these warnings by adding libraries with --include, or by using
        // --auto-include-dependencies.
        // TODO(jcollins-g): pipeline references through linkedName for error
        //                   messages and warn for non-public canonicalization
        //                   errors.
        warningMessage =
            "no canonical library found for ${warnableName}, not linking";
        break;
      case PackageWarning.ambiguousReexport:
        // Fix these warnings by adding the original library exporting the
        // symbol with --include, by using --auto-include-dependencies,
        // or by using --exclude to hide one of the libraries involved
        warningMessage =
            "ambiguous reexport of ${warnableName}, canonicalization candidates: ${message}";
        break;
      case PackageWarning.noLibraryLevelDocs:
        warningMessage =
            "${warnable.fullyQualifiedName} has no library level documentation comments";
        break;
      case PackageWarning.ambiguousDocReference:
        warningMessage = "ambiguous doc reference ${message}";
        break;
      case PackageWarning.ignoredCanonicalFor:
        warningMessage =
            "library says it is {@canonicalFor ${message}} but ${message} can't be canonical there";
        break;
      case PackageWarning.packageOrderGivesMissingPackageName:
        warningMessage =
            "--package-order gives invalid package name: '${message}'";
        break;
      case PackageWarning.reexportedPrivateApiAcrossPackages:
        warningMessage =
            "private API of ${message} is reexported by libraries in other packages: ";
        break;
      case PackageWarning.notImplemented:
        warningMessage = message;
        break;
      case PackageWarning.unresolvedDocReference:
        warningMessage = "unresolved doc reference [${message}]";
        referredFromPrefix = 'in documentation inherited from';
        break;
      case PackageWarning.unknownMacro:
        warningMessage = "undefined macro [${message}]";
        break;
      case PackageWarning.unknownHtmlFragment:
        warningMessage = "undefined HTML fragment identifier [${message}]";
        break;
      case PackageWarning.brokenLink:
        warningMessage = 'dartdoc generated a broken link to: ${message}';
        warnablePrefix = 'to element';
        referredFromPrefix = 'linked to from';
        break;
      case PackageWarning.orphanedFile:
        warningMessage = 'dartdoc generated a file orphan: ${message}';
        break;
      case PackageWarning.unknownFile:
        warningMessage =
            'dartdoc detected an unknown file in the doc tree: ${message}';
        break;
      case PackageWarning.missingFromSearchIndex:
        warningMessage =
            'dartdoc generated a file not in the search index: ${message}';
        break;
      case PackageWarning.typeAsHtml:
        // The message for this warning can contain many punctuation and other symbols,
        // so bracket with a triple quote for defense.
        warningMessage = 'generic type handled as HTML: """${message}"""';
        break;
      case PackageWarning.invalidParameter:
        warningMessage = 'invalid parameter to dartdoc directive: ${message}';
        break;
      case PackageWarning.toolError:
        warningMessage = 'tool execution failed: ${message}';
        break;
      case PackageWarning.deprecated:
        warningMessage = 'deprecated dartdoc usage: ${message}';
        break;
      case PackageWarning.unresolvedExport:
        warningMessage = 'unresolved export uri: ${message}';
        break;
    }

    List<String> messageParts = [warningMessage];
    if (warnable != null) {
      messageParts.add("$warnablePrefix $warnableName: ${warnable.location}");
    }
    if (referredFrom != null) {
      for (Locatable referral in referredFrom) {
        if (referral != warnable) {
          var referredFromStrings = _safeWarnableName(referral);
          messageParts.add(
              "$referredFromPrefix $referredFromStrings: ${referral.location}");
        }
      }
    }
    if (config.verboseWarnings && extendedDebug != null) {
      messageParts.addAll(extendedDebug.map((s) => "    $s"));
    }
    String fullMessage;
    if (messageParts.length <= 2) {
      fullMessage = messageParts.join(', ');
    } else {
      fullMessage = messageParts.join('\n    ');
    }

    packageWarningCounter.addWarning(warnable, kind, message, fullMessage);
  }

  String _safeWarnableName(Locatable locatable) {
    if (locatable == null) {
      return '<unknown>';
    }

    return locatable.fullyQualifiedName.replaceFirst(':', '-');
  }

  List<Package> get packages => packageMap.values.toList();

  List<Package> _publicPackages;

  List<Package> get publicPackages {
    if (_publicPackages == null) {
      assert(allLibrariesAdded);
      // Help the user if they pass us a package that doesn't exist.
      for (String packageName in config.packageOrder) {
        if (!packages.map((p) => p.name).contains(packageName)) {
          warnOnElement(
              null, PackageWarning.packageOrderGivesMissingPackageName,
              message:
                  "${packageName}, packages: ${packages.map((p) => p.name).join(',')}");
        }
      }
      _publicPackages = packages.where((p) => p.isPublic).toList()..sort();
    }
    return _publicPackages;
  }

  /// Local packages are to be documented locally vs. remote or not at all.
  List<Package> get localPackages =>
      publicPackages.where((p) => p.isLocal).toList();

  /// Documented packages are documented somewhere (local or remote).
  Iterable<Package> get documentedPackages =>
      packages.where((p) => p.documentedWhere != DocumentLocation.missing);

  Map<LibraryElement, Set<Library>> _libraryElementReexportedBy = Map();

  /// Prevent cycles from breaking our stack.
  Set<Tuple2<Library, LibraryElement>> _reexportsTagged = Set();

  void _tagReexportsFor(
      final Library topLevelLibrary, final LibraryElement libraryElement,
      [ExportElement lastExportedElement]) {
    Tuple2<Library, LibraryElement> key =
        Tuple2(topLevelLibrary, libraryElement);
    if (_reexportsTagged.contains(key)) {
      return;
    }
    _reexportsTagged.add(key);
    if (libraryElement == null) {
      // The first call to _tagReexportFor should not have a null libraryElement.
      assert(lastExportedElement != null);
      warnOnElement(
          findButDoNotCreateLibraryFor(lastExportedElement.enclosingElement),
          PackageWarning.unresolvedExport,
          message: '"${lastExportedElement.uri}"',
          referredFrom: <Locatable>[topLevelLibrary]);
      return;
    }
    _libraryElementReexportedBy.putIfAbsent(libraryElement, () => Set());
    _libraryElementReexportedBy[libraryElement].add(topLevelLibrary);
    for (ExportElement exportedElement in libraryElement.exports) {
      _tagReexportsFor(
          topLevelLibrary, exportedElement.exportedLibrary, exportedElement);
    }
  }

  int _lastSizeOfAllLibraries = 0;

  Map<LibraryElement, Set<Library>> get libraryElementReexportedBy {
    // Table must be reset if we're still in the middle of adding libraries.
    if (allLibraries.keys.length != _lastSizeOfAllLibraries) {
      _lastSizeOfAllLibraries = allLibraries.keys.length;
      _libraryElementReexportedBy = Map<LibraryElement, Set<Library>>();
      _reexportsTagged = Set();
      for (Library library in publicLibraries) {
        _tagReexportsFor(library, library.element);
      }
    }
    return _libraryElementReexportedBy;
  }

  /// A lookup index for hrefs to allow warnings to indicate where a broken
  /// link or orphaned file may have come from.  Not cached because
  /// [ModelElement]s can be created at any time and we're basing this
  /// on more than just [allLocalModelElements] to make the error messages
  /// comprehensive.
  Map<String, Set<ModelElement>> get allHrefs {
    Map<String, Set<ModelElement>> hrefMap = Map();
    // TODO(jcollins-g ): handle calculating hrefs causing new elements better
    //                    than toList().
    for (ModelElement modelElement
        in _allConstructedModelElements.values.toList()) {
      // Technically speaking we should be able to use canonical model elements
      // only here, but since the warnings that depend on this debug
      // canonicalization problems, don't limit ourselves in case an href is
      // generated for something non-canonical.
      if (modelElement is Dynamic) continue;
      // TODO: see [Accessor.enclosingCombo]
      if (modelElement is Accessor) continue;
      if (modelElement.href == null) continue;
      hrefMap.putIfAbsent(modelElement.href, () => Set());
      hrefMap[modelElement.href].add(modelElement);
    }
    for (Package package in packageMap.values) {
      for (Library library in package.libraries) {
        if (library.href == null) continue;
        hrefMap.putIfAbsent(library.href, () => Set());
        hrefMap[library.href].add(library);
      }
    }
    return hrefMap;
  }

  void _addToImplementors(Class c) {
    assert(!allImplementorsAdded);
    _implementors.putIfAbsent(c.href, () => []);
    void _checkAndAddClass(Class key, Class implClass) {
      _implementors.putIfAbsent(key.href, () => []);
      List list = _implementors[key.href];

      if (!list.any((l) => l.element == c.element)) {
        list.add(implClass);
      }
    }

    if (c._mixins.isNotEmpty) {
      c._mixins.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
    if (c.supertype != null) {
      _checkAndAddClass(c.supertype.element, c);
    }
    if (c.interfaces.isNotEmpty) {
      c.interfaces.forEach((t) {
        _checkAndAddClass(t.element, c);
      });
    }
  }

  List<Library> get libraries =>
      packages.expand((p) => p.libraries).toList()..sort();

  List<Library> _publicLibraries;

  Iterable<Library> get publicLibraries {
    if (_publicLibraries == null) {
      assert(allLibrariesAdded);
      _publicLibraries = utils.filterNonPublic(libraries).toList();
    }
    return _publicLibraries;
  }

  List<Library> _localLibraries;

  Iterable<Library> get localLibraries {
    if (_localLibraries == null) {
      assert(allLibrariesAdded);
      _localLibraries = localPackages.expand((p) => p.libraries).toList()
        ..sort();
    }
    return _localLibraries;
  }

  List<Library> _localPublicLibraries;

  Iterable<Library> get localPublicLibraries {
    if (_localPublicLibraries == null) {
      assert(allLibrariesAdded);
      _localPublicLibraries = utils.filterNonPublic(localLibraries).toList();
    }
    return _localPublicLibraries;
  }

  Set<Class> _inheritThrough;

  /// Return the set of [Class]es objects should inherit through if they
  /// show up in the inheritance chain.  Do not call before interceptorElement is
  /// found.  Add classes here if they are similar to Interceptor in that they
  /// are to be ignored even when they are the implementors of [Inheritable]s,
  /// and the class these inherit from should instead claim implementation.
  Set<Class> get inheritThrough {
    if (_inheritThrough == null) {
      _inheritThrough = Set();
      _inheritThrough.add(specialClasses[SpecialClass.interceptor]);
    }
    return _inheritThrough;
  }

  Set<Class> _invisibleAnnotations;

  /// Returns the set of [Class] objects that are similar to pragma
  /// in that we should never count them as documentable annotations.
  Set<Class> get invisibleAnnotations {
    if (_invisibleAnnotations == null) {
      _invisibleAnnotations = Set();
      _invisibleAnnotations.add(specialClasses[SpecialClass.pragma]);
    }
    return _invisibleAnnotations;
  }

  @override
  String toString() => 'PackageGraph built from ${defaultPackage.name}';

  final Map<Element, Library> _canonicalLibraryFor = Map();

  /// Tries to find a top level library that references this element.
  Library findCanonicalLibraryFor(Element e) {
    assert(allLibrariesAdded);
    Element searchElement = e;
    if (e is PropertyAccessorElement) {
      searchElement = e.variable;
    }
    if (e is GenericFunctionTypeElement) {
      searchElement = e.enclosingElement;
    }

    if (_canonicalLibraryFor.containsKey(e)) {
      return _canonicalLibraryFor[e];
    }
    _canonicalLibraryFor[e] = null;
    for (Library library in publicLibraries) {
      if (library.modelElementsMap.containsKey(searchElement)) {
        for (ModelElement modelElement
            in library.modelElementsMap[searchElement]) {
          if (modelElement.isCanonical) {
            _canonicalLibraryFor[e] = library;
            break;
          }
        }
      }
    }
    return _canonicalLibraryFor[e];
  }

  // TODO(jcollins-g): Revise when dart-lang/sdk#29600 is fixed.
  static Element getBasestElement(Element possibleMember) {
    Element element = possibleMember;
    while (element is Member) {
      element = (element as Member).baseElement;
    }
    return element;
  }

  /// Tries to find a canonical ModelElement for this element.  If we know
  /// this element is related to a particular class, pass preferredClass to
  /// disambiguate.
  ///
  /// This doesn't know anything about [PackageGraph.inheritThrough] and probably
  /// shouldn't, so using it with [Inheritable]s without special casing is
  /// not advised.
  ModelElement findCanonicalModelElementFor(Element e,
      {Container preferredClass}) {
    assert(allLibrariesAdded);
    Library lib = findCanonicalLibraryFor(e);
    if (preferredClass != null && preferredClass is Container) {
      Container canonicalClass =
          findCanonicalModelElementFor(preferredClass.element);
      if (canonicalClass != null) preferredClass = canonicalClass;
    }
    if (lib == null && preferredClass != null) {
      lib = findCanonicalLibraryFor(preferredClass.element);
    }
    ModelElement modelElement;
    // For elements defined in extensions, they are canonical.
    if (e?.enclosingElement is ExtensionElement) {
      lib ??= Library(e.enclosingElement.library, packageGraph);
      // (TODO:keertip) Find a better way to exclude members of extensions
      //  when libraries are specified using the "--include" flag
      if (lib?.isDocumented == true) {
        return ModelElement.from(e, lib, packageGraph);
      }
    }
    // TODO(jcollins-g): Special cases are pretty large here.  Refactor to split
    // out into helpers.
    // TODO(jcollins-g): The data structures should be changed to eliminate guesswork
    // with member elements.
    if (e is ClassMemberElement || e is PropertyAccessorElement) {
      if (e is Member) e = getBasestElement(e);
      Set<ModelElement> candidates = Set();
      Tuple2<Element, Library> iKey = Tuple2(e, lib);
      Tuple4<Element, Library, Class, ModelElement> key =
          Tuple4(e, lib, null, null);
      Tuple4<Element, Library, Class, ModelElement> keyWithClass =
          Tuple4(e, lib, preferredClass, null);
      if (_allConstructedModelElements.containsKey(key)) {
        candidates.add(_allConstructedModelElements[key]);
      }
      if (_allConstructedModelElements.containsKey(keyWithClass)) {
        candidates.add(_allConstructedModelElements[keyWithClass]);
      }
      if (candidates.isEmpty && _allInheritableElements.containsKey(iKey)) {
        candidates.addAll(
            _allInheritableElements[iKey].where((me) => me.isCanonical));
      }
      Class canonicalClass = findCanonicalModelElementFor(e.enclosingElement);
      if (canonicalClass != null) {
        candidates.addAll(canonicalClass.allCanonicalModelElements.where((m) {
          if (m.element == e) return true;
          return false;
        }));
      }
      Set<ModelElement> matches = Set()
        ..addAll(candidates.where((me) => me.isCanonical));

      // It's possible to find accessors but no combos.  Be sure that if we
      // have Accessors, we find their combos too.
      if (matches.any((me) => me is Accessor)) {
        List<GetterSetterCombo> combos =
            matches.whereType<Accessor>().map((a) => a.enclosingCombo).toList();
        matches.addAll(combos);
        assert(combos.every((c) => c.isCanonical));
      }

      // This is for situations where multiple classes may actually be canonical
      // for an inherited element whose defining Class is not canonical.
      if (matches.length > 1 &&
          preferredClass != null &&
          preferredClass is Class) {
        // Search for matches inside our superchain.
        List<Class> superChain = preferredClass.superChain
            .map((et) => et.element)
            .cast<Class>()
            .toList();
        superChain.add(preferredClass);
        matches.removeWhere((me) =>
            !superChain.contains((me as EnclosedElement).enclosingElement));
        // Assumed all matches are EnclosedElement because we've been told about a
        // preferredClass.
        Set<Class> enclosingElements = Set()
          ..addAll(matches
              .map((me) => (me as EnclosedElement).enclosingElement as Class));
        for (Class c in superChain.reversed) {
          if (enclosingElements.contains(c)) {
            matches.removeWhere(
                (me) => (me as EnclosedElement).enclosingElement != c);
          }
          if (matches.length <= 1) break;
        }
      }

      // Prefer a GetterSetterCombo to Accessors.
      if (matches.any((me) => me is GetterSetterCombo)) {
        matches.removeWhere((me) => me is Accessor);
      }

      assert(matches.length <= 1);
      if (matches.isNotEmpty) {
        modelElement = matches.first;
      }
    } else {
      if (lib != null) {
        Accessor getter;
        Accessor setter;
        if (e is PropertyInducingElement) {
          if (e.getter != null) {
            getter = ModelElement.from(e.getter, lib, packageGraph);
          }
          if (e.setter != null) {
            setter = ModelElement.from(e.setter, lib, packageGraph);
          }
        }
        modelElement = ModelElement.from(e, lib, packageGraph,
            getter: getter, setter: setter);
      }
      assert(modelElement is! Inheritable);
      if (modelElement != null && !modelElement.isCanonical) {
        modelElement = null;
      }
    }
    // Prefer Fields.
    if (e is PropertyAccessorElement && modelElement is Accessor) {
      modelElement = (modelElement as Accessor).enclosingCombo;
    }
    return modelElement;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findButDoNotCreateLibraryFor(Element e) {
    // This is just a cache to avoid creating lots of libraries over and over.
    if (allLibraries.containsKey(e.library)) {
      return allLibraries[e.library];
    }
    return null;
  }

  /// This is used when we might need a Library object that isn't actually
  /// a documentation entry point (for elements that have no Library within the
  /// set of canonical Libraries).
  Library findOrCreateLibraryFor(ResolvedLibraryResult result) {
    // This is just a cache to avoid creating lots of libraries over and over.
    if (allLibraries.containsKey(result.element.library)) {
      return allLibraries[result.element.library];
    }
    // can be null if e is for dynamic
    if (result.element.library == null) {
      return null;
    }
    Library foundLibrary = Library._(
        result,
        this,
        Package.fromPackageMeta(
            PackageMeta.fromElement(result.element.library, config),
            packageGraph));
    allLibraries[result.element.library] = foundLibrary;
    return foundLibrary;
  }

  List<ModelElement> _allModelElements;

  Iterable<ModelElement> get allModelElements {
    assert(allLibrariesAdded);
    if (_allModelElements == null) {
      _allModelElements = [];
      Set<Package> packagesToDo = packages.toSet();
      Set<Package> completedPackages = Set();
      while (packagesToDo.length > completedPackages.length) {
        packagesToDo.difference(completedPackages).forEach((Package p) {
          Set<Library> librariesToDo = p.allLibraries.toSet();
          Set<Library> completedLibraries = Set();
          while (librariesToDo.length > completedLibraries.length) {
            librariesToDo
                .difference(completedLibraries)
                .forEach((Library library) {
              _allModelElements.addAll(library.allModelElements);
              completedLibraries.add(library);
            });
            librariesToDo.addAll(p.allLibraries);
          }
          completedPackages.add(p);
        });
        packagesToDo.addAll(packages);
      }
    }
    return _allModelElements;
  }

  List<ModelElement> _allLocalModelElements;

  Iterable<ModelElement> get allLocalModelElements {
    assert(allLibrariesAdded);
    if (_allLocalModelElements == null) {
      _allLocalModelElements = [];
      this.localLibraries.forEach((library) {
        _allLocalModelElements.addAll(library.allModelElements);
      });
    }
    return _allLocalModelElements;
  }

  List<ModelElement> _allCanonicalModelElements;

  Iterable<ModelElement> get allCanonicalModelElements {
    return (_allCanonicalModelElements ??=
        allLocalModelElements.where((e) => e.isCanonical).toList());
  }

  String getMacro(String name) {
    assert(_localDocumentationBuilt);
    return _macros[name];
  }

  void _addMacro(String name, String content) {
    assert(!_localDocumentationBuilt);
    _macros[name] = content;
  }

  String getHtmlFragment(String name) {
    assert(_localDocumentationBuilt);
    return _htmlFragments[name];
  }

  void _addHtmlFragment(String name, String content) {
    assert(!_localDocumentationBuilt);
    _htmlFragments[name] = content;
  }
}

/// A set of [Class]es, [Enum]s, [TopLevelVariable]s, [ModelFunction]s,
/// [Property]s, and [Typedef]s, possibly initialized after construction by
/// accessing private member variables.  Do not call any methods or members
/// excepting [name] and the private Lists below before finishing initialization
/// of a [TopLevelContainer].
abstract class TopLevelContainer implements Nameable {
  List<Class> _classes;
  List<Extension> _extensions;
  List<Enum> _enums;
  List<Mixin> _mixins;
  List<Class> _exceptions;
  List<TopLevelVariable> _constants;
  List<TopLevelVariable> _properties;
  List<ModelFunction> _functions;
  List<Typedef> _typedefs;

  Iterable<Class> get classes => _classes;

  Iterable<Extension> get extensions => _extensions;

  Iterable<Enum> get enums => _enums;

  Iterable<Mixin> get mixins => _mixins;

  Iterable<Class> get exceptions => _exceptions;

  Iterable<TopLevelVariable> get constants => _constants;

  Iterable<TopLevelVariable> get properties => _properties;

  Iterable<ModelFunction> get functions => _functions;

  Iterable<Typedef> get typedefs => _typedefs;

  bool get hasPublicClasses => publicClasses.isNotEmpty;

  bool get hasPublicExtensions => publicExtensions.isNotEmpty;

  bool get hasPublicConstants => publicConstants.isNotEmpty;

  bool get hasPublicEnums => publicEnums.isNotEmpty;

  bool get hasPublicExceptions => publicExceptions.isNotEmpty;

  bool get hasPublicFunctions => publicFunctions.isNotEmpty;

  bool get hasPublicMixins => publicMixins.isNotEmpty;

  bool get hasPublicProperties => publicProperties.isNotEmpty;

  bool get hasPublicTypedefs => publicTypedefs.isNotEmpty;

  Iterable<Class> get publicClasses => utils.filterNonPublic(classes);

  Iterable<Extension> get publicExtensions => utils.filterNonPublic(extensions);

  Iterable<TopLevelVariable> get publicConstants =>
      utils.filterNonPublic(constants);

  Iterable<Enum> get publicEnums => utils.filterNonPublic(enums);

  Iterable<Class> get publicExceptions => utils.filterNonPublic(exceptions);

  Iterable<ModelFunction> get publicFunctions =>
      utils.filterNonPublic(functions);

  Iterable<Mixin> get publicMixins => utils.filterNonPublic(mixins);

  Iterable<TopLevelVariable> get publicProperties =>
      utils.filterNonPublic(properties);

  Iterable<Typedef> get publicTypedefs => utils.filterNonPublic(typedefs);
}

/// A set of libraries, initialized after construction by accessing [_libraries].
/// Do not cache return values of any methods or members excepting [_libraries]
/// and [name] before finishing initialization of a [LibraryContainer].
abstract class LibraryContainer
    implements Nameable, Comparable<LibraryContainer> {
  final List<Library> _libraries = [];

  List<Library> get libraries => _libraries;

  PackageGraph get packageGraph;

  Iterable<Library> get publicLibraries => utils.filterNonPublic(libraries);

  bool get hasPublicLibraries => publicLibraries.isNotEmpty;

  /// The name of the container or object that this LibraryContainer is a part
  /// of.  Used for sorting in [containerOrder].
  String get enclosingName;

  /// Order by which this container should be sorted.
  List<String> get containerOrder;

  /// Sorting key.  [containerOrder] should contain these.
  String get sortKey => name;

  /// Does this container represent the SDK?  This can be false for containers
  /// that only represent a part of the SDK.
  bool get isSdk => false;

  /// Returns:
  /// -1 if this container is listed in [containerOrder].
  /// 0 if this container is named the same as the [enclosingName].
  /// 1 if this container represents the SDK.
  /// 2 if this group has a name that contains the name [enclosingName].
  /// 3 otherwise.
  int get _group {
    if (containerOrder.contains(sortKey)) return -1;
    if (equalsIgnoreAsciiCase(sortKey, enclosingName)) return 0;
    if (isSdk) return 1;
    if (sortKey.toLowerCase().contains(enclosingName.toLowerCase())) return 2;
    return 3;
  }

  @override
  int compareTo(LibraryContainer other) {
    if (_group == other._group) {
      if (_group == -1) {
        return Comparable.compare(containerOrder.indexOf(sortKey),
            containerOrder.indexOf(other.sortKey));
      } else {
        return sortKey.toLowerCase().compareTo(other.sortKey.toLowerCase());
      }
    }
    return Comparable.compare(_group, other._group);
  }
}

abstract class MarkdownFileDocumentation
    implements Documentable, Canonicalization {
  DocumentLocation get documentedWhere;

  @override
  String get documentation => documentationFile?.contents;

  Documentation __documentation;

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = Documentation.forElement(this);
    return __documentation;
  }

  @override
  String get documentationAsHtml => _documentation.asHtml;

  @override
  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  @override
  bool get hasExtendedDocumentation =>
      documentation != null && documentation.isNotEmpty;

  @override
  bool get isDocumented;

  @override
  String get oneLineDoc => __documentation.asOneLiner;

  FileContents get documentationFile;

  @override
  String get location => path.toUri(documentationFile.file.path).toString();

  @override
  Set<String> get locationPieces => Set.from(<String>[location]);
}

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
  final Set<Categorization> _allItems = Set();

  Category(this._name, this.package, this.config) {
    _enums = [];
    _exceptions = [];
    _classes = [];
    _constants = [];
    _properties = [];
    _functions = [];
    _mixins = [];
    _typedefs = [];
    _extensions = [];
  }

  void addItem(Categorization c) {
    if (_allItems.contains(c)) return;
    _allItems.add(c);
    if (c is Library) {
      _libraries.add(c);
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
      throw UnimplementedError("Unrecognized element");
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
    if (_isDocumented == null) {
      _isDocumented = documentedWhere != DocumentLocation.missing &&
          documentationFile != null;
    }
    return _isDocumented;
  }

  @override
  String get fullyQualifiedName => name;

  @override
  String get href =>
      isCanonical ? '${package.baseHref}topics/${name}-topic.html' : null;

  String get linkedName {
    String unbrokenCategoryName = name.replaceAll(' ', '&nbsp;');
    if (isDocumented) {
      return '<a href="$href">$unbrokenCategoryName</a>';
    } else {
      return unbrokenCategoryName;
    }
  }

  String _categoryNumberClass;

  /// The position in the container order for this category.
  String get categoryNumberClass {
    if (_categoryNumberClass == null) {
      _categoryNumberClass = "cp-${package.categories.indexOf(this)}";
    }
    return _categoryNumberClass;
  }

  /// Category name used in template as part of the class.
  String get spanClass => name.split(' ').join('-').toLowerCase();

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
}

/// For a given package, indicate with this enum whether it should be documented
/// [local]ly, whether we should treat the package as [missing] and any references
/// to it made canonical to this package, or [remote], indicating that
/// we can build hrefs to an external source.
enum DocumentLocation {
  local,
  missing,
  remote,
}

/// A [LibraryContainer] that contains [Library] objects related to a particular
/// package.
class Package extends LibraryContainer
    with Nameable, Locatable, Canonicalization, Warnable
    implements Privacy, Documentable {
  String _name;
  PackageGraph _packageGraph;

  final Map<String, Category> _nameToCategory = {};

  // Creates a package, if necessary, and adds it to the [packageGraph].
  factory Package.fromPackageMeta(
      PackageMeta packageMeta, PackageGraph packageGraph) {
    String packageName = packageMeta.name;

    bool expectNonLocal = false;

    if (!packageGraph.packageMap.containsKey(packageName) &&
        packageGraph.allLibrariesAdded) expectNonLocal = true;
    packageGraph.packageMap.putIfAbsent(
        packageName, () => Package._(packageName, packageGraph, packageMeta));
    // Verify that we don't somehow decide to document locally a package picked
    // up after all documented libraries are added, because that breaks the
    // assumption that we've picked up all documented libraries and packages
    // before allLibrariesAdded is true.
    assert(
        !(expectNonLocal &&
            packageGraph.packageMap[packageName].documentedWhere ==
                DocumentLocation.local),
        'Found more libraries to document after allLibrariesAdded was set to true');
    return packageGraph.packageMap[packageName];
  }

  Package._(this._name, this._packageGraph, this._packageMeta);

  @override
  bool get isCanonical => true;

  @override
  Library get canonicalLibrary => null;

  /// Number of times we have invoked a tool for this package.
  int toolInvocationIndex = 0;

  // The animation IDs that have already been used, indexed by the [href] of the
  // object that contains them.
  Map<String, Set<String>> usedAnimationIdsByHref = {};

  /// Pieces of the location split by [locationSplitter] (removing package: and
  /// slashes).
  @override
  Set<String> get locationPieces => Set();

  final Set<Library> _allLibraries = Set();

  bool get hasHomepage =>
      packageMeta.homepage != null && packageMeta.homepage.isNotEmpty;

  String get homepage => packageMeta.homepage;

  String get kind => (isSdk) ? 'SDK' : 'package';

  @override
  List<Locatable> get documentationFrom => [this];

  /// Returns all libraries added to this package.  May include non-documented
  /// libraries, but is not guaranteed to include a complete list of
  /// non-documented libraries unless they are all referenced by documented ones.
  /// Not sorted.
  Set<Library> get allLibraries => _allLibraries;

  /// Return true if the code has defined non-default categories for libraries
  /// in this package.
  bool get hasCategories => categories.isNotEmpty;

  LibraryContainer get defaultCategory => nameToCategory[null];

  String _documentationAsHtml;

  @override
  String get documentationAsHtml {
    if (_documentationAsHtml != null) return _documentationAsHtml;
    _documentationAsHtml = Documentation.forElement(this).asHtml;

    return _documentationAsHtml;
  }

  @override
  String get documentation {
    return hasDocumentationFile ? documentationFile.contents : null;
  }

  @override
  bool get hasDocumentation =>
      documentationFile != null && documentationFile.contents.isNotEmpty;

  @override
  bool get hasExtendedDocumentation => documentation.isNotEmpty;

  // TODO: Clients should use [documentationFile] so they can act differently on
  // plain text or markdown.
  bool get hasDocumentationFile => documentationFile != null;

  FileContents get documentationFile => packageMeta.getReadmeContents();

  @override
  String get oneLineDoc => '';

  @override
  bool get isDocumented =>
      isFirstPackage || documentedWhere != DocumentLocation.missing;

  @override
  Warnable get enclosingElement => null;

  bool _isPublic;

  @override
  bool get isPublic {
    if (_isPublic == null) _isPublic = libraries.any((l) => l.isPublic);
    return _isPublic;
  }

  bool _isLocal;

  /// Return true if this is the default package, this is part of an embedder SDK,
  /// or if [config.autoIncludeDependencies] is true -- but only if the package
  /// was not excluded on the command line.
  bool get isLocal {
    if (_isLocal == null) {
      _isLocal = (packageMeta == packageGraph.packageMeta ||
              packageGraph.hasEmbedderSdk && packageMeta.isSdk ||
              packageGraph.config.autoIncludeDependencies) &&
          !packageGraph.config.isPackageExcluded(name);
    }
    return _isLocal;
  }

  DocumentLocation get documentedWhere {
    if (isLocal) {
      if (isPublic) {
        return DocumentLocation.local;
      } else {
        // Possible if excludes result in a "documented" package not having
        // any actual documentation.
        return DocumentLocation.missing;
      }
    } else {
      if (config.linkToRemote && config.linkToUrl.isNotEmpty && isPublic) {
        return DocumentLocation.remote;
      } else {
        return DocumentLocation.missing;
      }
    }
  }

  @override
  String get enclosingName => packageGraph.defaultPackageName;

  @override
  String get fullyQualifiedName => 'package:$name';

  String _baseHref;

  String get baseHref {
    if (_baseHref == null) {
      if (documentedWhere == DocumentLocation.remote) {
        _baseHref =
            config.linkToUrl.replaceAllMapped(substituteNameVersion, (m) {
          switch (m.group(1)) {
            // Return the prerelease tag of the release if a prerelease,
            // or 'stable' otherwise. Mostly coded around
            // the Dart SDK's use of dev/stable, but theoretically applicable
            // elsewhere.
            case 'b':
              {
                Version version = Version.parse(packageMeta.version);
                return version.isPreRelease
                    ? version.preRelease.first
                    : 'stable';
              }
            case 'n':
              return name;
            // The full version string of the package.
            case 'v':
              return packageMeta.version;
            default:
              assert(false, 'Unsupported case: ${m.group(1)}');
              return null;
          }
        });
        if (!_baseHref.endsWith('/')) _baseHref = '${_baseHref}/';
      } else {
        _baseHref = '';
      }
    }
    return _baseHref;
  }

  @override
  String get href => '${baseHref}index.html';

  @override
  String get location => path.toUri(packageMeta.resolvedDir).toString();

  @override
  String get name => _name;

  @override
  Package get package => this;

  @override
  PackageGraph get packageGraph => _packageGraph;

  // Workaround for mustache4dart issue where templates do not recognize
  // inherited properties as being in-context.
  @override
  Iterable<Library> get publicLibraries {
    assert(libraries.every((l) => l.packageMeta == _packageMeta));
    return super.publicLibraries;
  }

  /// A map of category name to the category itself.
  Map<String, Category> get nameToCategory {
    if (_nameToCategory.isEmpty) {
      Category categoryFor(String category) {
        _nameToCategory.putIfAbsent(
            category, () => Category(category, this, config));
        return _nameToCategory[category];
      }

      _nameToCategory[null] = Category(null, this, config);
      for (Categorization c in libraries.expand(
          (l) => l.allCanonicalModelElements.whereType<Categorization>())) {
        for (String category in c.categoryNames) {
          categoryFor(category).addItem(c);
        }
      }
    }
    return _nameToCategory;
  }

  List<Category> _categories;

  List<Category> get categories {
    if (_categories == null) {
      _categories = nameToCategory.values.where((c) => c.name != null).toList()
        ..sort();
    }
    return _categories;
  }

  Iterable<LibraryContainer> get categoriesWithPublicLibraries =>
      categories.where((c) => c.publicLibraries.isNotEmpty);

  Iterable<Category> get documentedCategories =>
      categories.where((c) => c.isDocumented);

  bool get hasDocumentedCategories => documentedCategories.isNotEmpty;

  DartdocOptionContext _config;

  @override
  DartdocOptionContext get config {
    if (_config == null) {
      _config = DartdocOptionContext.fromContext(
          packageGraph.config, Directory(packagePath));
    }
    return _config;
  }

  /// Is this the package at the top of the list?  We display the first
  /// package specially (with "Libraries" rather than the package name).
  bool get isFirstPackage =>
      packageGraph.localPackages.isNotEmpty &&
      identical(packageGraph.localPackages.first, this);

  @override
  bool get isSdk => packageMeta.isSdk;

  String _packagePath;

  String get packagePath {
    if (_packagePath == null) {
      _packagePath = path.canonicalize(packageMeta.dir.path);
    }
    return _packagePath;
  }

  String get version => packageMeta.version ?? '0.0.0-unknown';

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

  final PackageMeta _packageMeta;

  PackageMeta get packageMeta => _packageMeta;

  @override
  Element get element => null;

  @override
  List<String> get containerOrder => config.packageOrder;
}

class Parameter extends ModelElement implements EnclosedElement {
  Parameter(
      ParameterElement element, Library library, PackageGraph packageGraph,
      {Member originalMember})
      : super(element, library, packageGraph, originalMember);

  String get defaultValue {
    if (!hasDefaultValue) return null;
    return _parameter.defaultValueCode;
  }

  @override
  ModelElement get enclosingElement => (_parameter.enclosingElement != null)
      ? ModelElement.from(_parameter.enclosingElement, library, packageGraph)
      : null;

  bool get hasDefaultValue {
    return _parameter.defaultValueCode != null &&
        _parameter.defaultValueCode.isNotEmpty;
  }

  @override
  String get href {
    throw StateError('href not implemented for parameters');
  }

  @override
  String get htmlId {
    if (_parameter.enclosingElement != null) {
      String enclosingName = _parameter.enclosingElement.name;
      if (_parameter.enclosingElement is GenericFunctionTypeElement) {
        // TODO(jcollins-g): Drop when GenericFunctionTypeElement populates name.
        // Also, allowing null here is allowed as a workaround for
        // dart-lang/sdk#32005.
        for (Element e = _parameter.enclosingElement;
            e.enclosingElement != null;
            e = e.enclosingElement) {
          enclosingName = e.name;
          if (enclosingName != null && enclosingName.isNotEmpty) break;
        }
      }
      return '${enclosingName}-param-${name}';
    } else {
      return 'param-${name}';
    }
  }

  @override
  int get hashCode => _element == null ? 0 : _element.hashCode;

  @override
  bool operator ==(Object object) =>
      object is Parameter && (_parameter.type == object._parameter.type);

  bool get isCovariant => _parameter.isCovariant;

  bool get isOptional => _parameter.isOptional;

  bool get isOptionalNamed => _parameter.isNamed;

  bool get isOptionalPositional => _parameter.isOptionalPositional;

  @override
  String get kind => 'parameter';

  ParameterElement get _parameter => element as ParameterElement;
}

abstract class SourceCodeMixin implements Documentable {
  ModelNode get modelNode;

  CharacterLocation get characterLocation;

  Element get element;

  bool get hasSourceCode => config.includeSource && sourceCode.isNotEmpty;

  Library get library;

  String _sourceCode;

  String get sourceCode =>
      _sourceCode ??= modelNode == null ? '' : modelNode.sourceCode;
}

abstract class TypeParameters implements ModelElement {
  String get nameWithGenerics => '$name$genericParameters';

  String get nameWithLinkedGenerics => '$name$linkedGenericParameters';

  bool get hasGenericParameters => typeParameters.isNotEmpty;

  String get genericParameters {
    if (typeParameters.isEmpty) return '';
    return '&lt;<wbr><span class="type-parameter">${typeParameters.map((t) => t.name).join('</span>, <span class="type-parameter">')}</span>&gt;';
  }

  String get linkedGenericParameters {
    if (typeParameters.isEmpty) return '';
    return '<span class="signature">&lt;<wbr><span class="type-parameter">${typeParameters.map((t) => t.linkedName).join('</span>, <span class="type-parameter">')}</span>&gt;</span>';
  }

  @override
  DefinedElementType get modelType;

  List<TypeParameter> get typeParameters;
}

/// Top-level variables. But also picks up getters and setters?
class TopLevelVariable extends ModelElement
    with Canonicalization, GetterSetterCombo, SourceCodeMixin, Categorization
    implements EnclosedElement {
  @override
  final Accessor getter;
  @override
  final Accessor setter;

  TopLevelVariable(TopLevelVariableElement element, Library library,
      PackageGraph packageGraph, this.getter, this.setter)
      : super(element, library, packageGraph, null) {
    if (getter != null) {
      getter._enclosingCombo = this;
    }
    if (setter != null) {
      setter._enclosingCombo = this;
    }
  }

  @override
  bool get isInherited => false;

  @override
  String get documentation {
    // Verify that hasSetter and hasGetterNoSetter are mutually exclusive,
    // to prevent displaying more or less than one summary.
    if (isPublic) {
      Set<bool> assertCheck = Set()
        ..addAll([hasPublicSetter, hasPublicGetterNoSetter]);
      assert(assertCheck.containsAll([true, false]));
    }
    return super.documentation;
  }

  @override
  ModelElement get enclosingElement => library;

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${library.dirName}/$fileName';
  }

  @override
  bool get isConst => _variable.isConst;

  @override
  bool get isFinal {
    /// isFinal returns true for the variable even if it has an explicit getter
    /// (which means we should not document it as "final").
    if (hasExplicitGetter) return false;
    return _variable.isFinal;
  }

  @override
  String get kind => isConst ? 'top-level constant' : 'top-level property';

  @override
  Set<String> get features => super.features..addAll(comboFeatures);

  @override
  String _computeDocumentationComment() {
    String docs = getterSetterDocumentationComment;
    if (docs.isEmpty) return _variable.documentationComment;
    return docs;
  }

  @override
  String get fileName => isConst ? '$name-constant.html' : '$name.html';

  @override
  DefinedElementType get modelType => super.modelType;

  TopLevelVariableElement get _variable => (element as TopLevelVariableElement);
}

class Typedef extends ModelElement
    with SourceCodeMixin, TypeParameters, Categorization
    implements EnclosedElement {
  Typedef(FunctionTypeAliasElement element, Library library,
      PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  ModelElement get enclosingElement => library;

  @override
  String get nameWithGenerics => '$name${super.genericParameters}';

  @override
  String get genericParameters {
    if (element is GenericTypeAliasElement) {
      List<TypeParameterElement> genericTypeParameters =
          (element as GenericTypeAliasElement).function.typeParameters;
      if (genericTypeParameters.isNotEmpty) {
        return '&lt;<wbr><span class="type-parameter">${genericTypeParameters.map((t) => t.name).join('</span>, <span class="type-parameter">')}</span>&gt;';
      }
    } // else, all types are resolved.
    return '';
  }

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${library.dirName}/$fileName';
  }

  // Food for mustache.
  bool get isInherited => false;

  @override
  String get kind => 'typedef';

  String get linkedReturnType => modelType.createLinkedReturnTypeName();

  @override
  DefinedElementType get modelType => super.modelType;

  FunctionTypeAliasElement get _typedef =>
      (element as FunctionTypeAliasElement);

  @override
  List<TypeParameter> get typeParameters => _typedef.typeParameters.map((f) {
        return ModelElement.from(f, library, packageGraph) as TypeParameter;
      }).toList();
}

class TypeParameter extends ModelElement {
  TypeParameter(
      TypeParameterElement element, Library library, PackageGraph packageGraph)
      : super(element, library, packageGraph, null);

  @override
  ModelElement get enclosingElement => (element.enclosingElement != null)
      ? ModelElement.from(element.enclosingElement, library, packageGraph)
      : null;

  @override
  String get href {
    if (!identical(canonicalModelElement, this)) {
      return canonicalModelElement?.href;
    }
    assert(canonicalLibrary != null);
    assert(canonicalLibrary == library);
    return '${package.baseHref}${enclosingElement.library.dirName}/${enclosingElement.name}/$name';
  }

  @override
  String get kind => 'type parameter';

  ElementType _boundType;

  ElementType get boundType {
    if (_boundType == null) {
      var bound = _typeParameter.bound;
      if (bound != null) {
        _boundType = ElementType.from(bound, library, packageGraph);
      }
    }
    return _boundType;
  }

  String _name;

  @override
  String get name {
    if (_name == null) {
      _name = _typeParameter.bound != null
          ? '${_typeParameter.name} extends ${boundType.nameWithGenerics}'
          : _typeParameter.name;
    }
    return _name;
  }

  @override
  String get linkedName {
    if (_linkedName == null) {
      _linkedName = _typeParameter.bound != null
          ? '${_typeParameter.name} extends ${boundType.linkedName}'
          : _typeParameter.name;
    }
    return _linkedName;
  }

  TypeParameterElement get _typeParameter => element as TypeParameterElement;
}

/// Everything you need to instantiate a PackageGraph object for documenting.
class PackageBuilder {
  final DartdocOptionContext config;

  PackageBuilder(this.config);

  Future<PackageGraph> buildPackageGraph() async {
    if (config.topLevelPackageMeta.needsPubGet) {
      config.topLevelPackageMeta.runPubGet();
    }

    PackageGraph newGraph = PackageGraph.UninitializedPackageGraph(
        config,
        driver,
        await driver.currentSession.typeSystem,
        sdk,
        hasEmbedderSdkFiles);
    await getLibraries(newGraph);
    await newGraph.initializePackageGraph();
    return newGraph;
  }

  DartSdk _sdk;

  DartSdk get sdk {
    if (_sdk == null) {
      _sdk = FolderBasedDartSdk(PhysicalResourceProvider.INSTANCE,
          PhysicalResourceProvider.INSTANCE.getFolder(config.sdkDir));
    }
    return _sdk;
  }

  EmbedderSdk _embedderSdk;

  EmbedderSdk get embedderSdk {
    if (_embedderSdk == null && !config.topLevelPackageMeta.isSdk) {
      _embedderSdk = EmbedderSdk(PhysicalResourceProvider.INSTANCE,
          EmbedderYamlLocator(packageMap).embedderYamls);
    }
    return _embedderSdk;
  }

  static Map<String, List<file_system.Folder>> _calculatePackageMap(
      file_system.Folder dir) {
    Map<String, List<file_system.Folder>> map = Map();
    var info = package_config.findPackagesFromFile(dir.toUri());

    for (String name in info.packages) {
      Uri uri = info.asMap()[name];
      String packagePath = path.normalize(path.fromUri(uri));
      file_system.Resource resource =
          PhysicalResourceProvider.INSTANCE.getResource(packagePath);
      if (resource is file_system.Folder) {
        map[name] = [resource];
      }
    }

    return map;
  }

  Map<String, List<file_system.Folder>> _packageMap;

  Map<String, List<file_system.Folder>> get packageMap {
    if (_packageMap == null) {
      file_system.Folder cwd =
          PhysicalResourceProvider.INSTANCE.getResource(config.inputDir);
      _packageMap = _calculatePackageMap(cwd);
    }
    return _packageMap;
  }

  DartUriResolver _embedderResolver;

  DartUriResolver get embedderResolver {
    if (_embedderResolver == null) {
      _embedderResolver = DartUriResolver(embedderSdk);
    }
    return _embedderResolver;
  }

  SourceFactory get sourceFactory {
    List<UriResolver> resolvers = [];
    resolvers.add(SdkExtUriResolver(packageMap));
    final UriResolver packageResolver =
        PackageMapUriResolver(PhysicalResourceProvider.INSTANCE, packageMap);
    UriResolver sdkResolver;
    if (embedderSdk == null || embedderSdk.urlMappings.isEmpty) {
      // The embedder uri resolver has no mappings. Use the default Dart SDK
      // uri resolver.
      sdkResolver = DartUriResolver(sdk);
    } else {
      // The embedder uri resolver has mappings, use it instead of the default
      // Dart SDK uri resolver.
      sdkResolver = embedderResolver;
    }

    /// [AnalysisDriver] seems to require package resolvers that
    /// never resolve to embedded SDK files, and the resolvers list must still
    /// contain a DartUriResolver.  This hack won't be necessary once analyzer
    /// has a clean public API.
    resolvers.add(PackageWithoutSdkResolver(packageResolver, sdkResolver));
    resolvers.add(sdkResolver);
    resolvers.add(
        file_system.ResourceUriResolver(PhysicalResourceProvider.INSTANCE));

    assert(
        resolvers.any((UriResolver resolver) => resolver is DartUriResolver));
    SourceFactory sourceFactory = SourceFactory(resolvers);
    return sourceFactory;
  }

  AnalysisDriver _driver;

  AnalysisDriver get driver {
    if (_driver == null) {
      PerformanceLog log = PerformanceLog(null);
      AnalysisDriverScheduler scheduler = AnalysisDriverScheduler(log);
      AnalysisOptionsImpl options = AnalysisOptionsImpl();

      // TODO(jcollins-g): pass in an ExperimentStatus instead?
      options.enabledExperiments = config.enableExperiment
        ..add('extension-methods');

      // TODO(jcollins-g): Make use of currently not existing API for managing
      //                   many AnalysisDrivers
      // TODO(jcollins-g): make use of DartProject isApi()
      _driver = AnalysisDriver(
          scheduler,
          log,
          PhysicalResourceProvider.INSTANCE,
          MemoryByteStore(),
          FileContentOverlay(),
          null,
          sourceFactory,
          options);
      driver.results.listen((_) {});
      driver.exceptions.listen((_) {});
      scheduler.start();
    }
    return _driver;
  }

  /// Return an Iterable with the sdk files we should parse.
  /// Filter can be String or RegExp (technically, anything valid for
  /// [String.contains])
  Iterable<String> getSdkFilesToDocument() sync* {
    for (var sdkLib in sdk.sdkLibraries) {
      Source source = sdk.mapDartUri(sdkLib.shortName);
      yield source.fullName;
    }
  }

  /// Parse a single library at [filePath] using the current analysis driver.
  /// If [filePath] is not a library, returns null.
  Future<ResolvedLibraryResult> processLibrary(String filePath) async {
    String name = filePath;

    if (name.startsWith(directoryCurrentPath)) {
      name = name.substring(directoryCurrentPath.length);
      if (name.startsWith(Platform.pathSeparator)) name = name.substring(1);
    }
    JavaFile javaFile = JavaFile(filePath).getAbsoluteFile();
    Source source = FileBasedSource(javaFile);

    // TODO(jcollins-g): remove the manual reversal using embedderSdk when we
    // upgrade to analyzer-0.30 (where DartUriResolver implements
    // restoreAbsolute)
    Uri uri = embedderSdk?.fromFileUri(source.uri)?.uri;
    if (uri != null) {
      source = FileBasedSource(javaFile, uri);
    } else {
      uri = driver.sourceFactory.restoreUri(source);
      if (uri != null) {
        source = FileBasedSource(javaFile, uri);
      }
    }
    var sourceKind = await driver.getSourceKind(filePath);
    // Allow dart source files with inappropriate suffixes (#1897).  Those
    // do not show up as SourceKind.LIBRARY.
    if (sourceKind != SourceKind.PART) {
      // Loading libraryElements from part files works, but is painfully slow
      // and creates many duplicates.
      return await driver.currentSession.getResolvedLibrary(source.fullName);
    }
    return null;
  }

  Set<PackageMeta> _packageMetasForFiles(Iterable<String> files) {
    Set<PackageMeta> metas = Set();
    for (String filename in files) {
      metas.add(PackageMeta.fromFilename(filename));
    }
    return metas;
  }

  /// Parse libraries with the analyzer and invoke a callback with the
  /// result.
  ///
  /// Uses the [libraries] parameter to prevent calling
  /// the callback more than once with the same [LibraryElement].
  /// Adds [LibraryElement]s found to that parameter.
  Future<void> _parseLibraries(
      void Function(ResolvedLibraryResult) libraryAdder,
      Set<LibraryElement> libraries,
      Set<String> files,
      [bool Function(LibraryElement) isLibraryIncluded]) async {
    isLibraryIncluded ??= (_) => true;
    Set<PackageMeta> lastPass = Set();
    Set<PackageMeta> current;
    do {
      lastPass = _packageMetasForFiles(files);

      // Be careful here not to accidentally stack up multiple
      // ResolvedLibraryResults, as those eat our heap.
      for (String f in files) {
        ResolvedLibraryResult r = await processLibrary(f);
        if (r != null &&
            !libraries.contains(r.element) &&
            isLibraryIncluded(r.element)) {
          logInfo('parsing ${f}...');
          libraryAdder(r);
          libraries.add(r.element);
        }
      }

      // Be sure to give the analyzer enough time to find all the files.
      await driver.discoverAvailableFiles();
      files.addAll(driver.knownFiles);
      files.addAll(_includeExternalsFrom(driver.knownFiles));
      current = _packageMetasForFiles(files);
      // To get canonicalization correct for non-locally documented packages
      // (so we can generate the right hyperlinks), it's vital that we
      // add all libraries in dependent packages.  So if the analyzer
      // discovers some files in a package we haven't seen yet, add files
      // for that package.
      for (PackageMeta meta in current.difference(lastPass)) {
        if (meta.isSdk) {
          files.addAll(getSdkFilesToDocument());
        } else {
          files.addAll(
              findFilesToDocumentInPackage(meta.dir.path, false, false));
        }
      }
    } while (!lastPass.containsAll(current));
  }

  /// Given a package name, explore the directory and pull out all top level
  /// library files in the "lib" directory to document.
  Iterable<String> findFilesToDocumentInPackage(
      String basePackageDir, bool autoIncludeDependencies,
      [bool filterExcludes = true]) sync* {
    final String sep = path.separator;

    Set<String> packageDirs = Set()..add(basePackageDir);

    if (autoIncludeDependencies) {
      Map<String, Uri> info = package_config
          .findPackagesFromFile(
              Uri.file(path.join(basePackageDir, 'pubspec.yaml')))
          .asMap();
      for (String packageName in info.keys) {
        if (!filterExcludes || !config.exclude.contains(packageName)) {
          packageDirs.add(path.dirname(info[packageName].toFilePath()));
        }
      }
    }

    for (String packageDir in packageDirs) {
      var packageLibDir = path.join(packageDir, 'lib');
      var packageLibSrcDir = path.join(packageLibDir, 'src');
      // To avoid analyzing package files twice, only files with paths not
      // containing '/packages' will be added. The only exception is if the file
      // to analyze already has a '/package' in its path.
      for (var lib
          in listDir(packageDir, recursive: true, listDir: _packageDirList)) {
        if (lib.endsWith('.dart') &&
            (!lib.contains('${sep}packages${sep}') ||
                packageDir.contains('${sep}packages${sep}'))) {
          // Only include libraries within the lib dir that are not in lib/src
          if (path.isWithin(packageLibDir, lib) &&
              !path.isWithin(packageLibSrcDir, lib)) {
            // Only add the file if it does not contain 'part of'
            var contents = File(lib).readAsStringSync();

            if (contents.contains(newLinePartOfRegexp) ||
                contents.startsWith(partOfRegexp)) {
              // NOOP: it's a part file
            } else {
              yield lib;
            }
          }
        }
      }
    }
  }

  /// Calculate includeExternals based on a list of files.  Assumes each
  /// file might be part of a [DartdocOptionContext], and loads those
  /// objects to find any [DartdocOptionContext.includeExternal] configurations
  /// therein.
  Iterable<String> _includeExternalsFrom(Iterable<String> files) sync* {
    for (String file in files) {
      DartdocOptionContext fileContext =
          DartdocOptionContext.fromContext(config, File(file));
      if (fileContext.includeExternal != null) {
        yield* fileContext.includeExternal;
      }
    }
  }

  Set<String> getFiles() {
    Iterable<String> files;
    if (config.topLevelPackageMeta.isSdk) {
      files = getSdkFilesToDocument();
    } else {
      files = findFilesToDocumentInPackage(
          config.inputDir, config.autoIncludeDependencies);
    }
    files = quiver.concat([files, _includeExternalsFrom(files)]);
    return Set.from(files.map((s) => File(s).absolute.path));
  }

  Iterable<String> getEmbedderSdkFiles() sync* {
    if (embedderSdk != null &&
        embedderSdk.urlMappings.isNotEmpty &&
        !config.topLevelPackageMeta.isSdk) {
      for (String dartUri in embedderSdk.urlMappings.keys) {
        Source source = embedderSdk.mapDartUri(dartUri);
        yield (File(source.fullName)).absolute.path;
      }
    }
  }

  bool get hasEmbedderSdkFiles =>
      embedderSdk != null && getEmbedderSdkFiles().isNotEmpty;

  Future<void> getLibraries(PackageGraph uninitializedPackageGraph) async {
    DartSdk findSpecialsSdk = sdk;
    if (embedderSdk != null && embedderSdk.urlMappings.isNotEmpty) {
      findSpecialsSdk = embedderSdk;
    }
    Set<String> files = getFiles()..addAll(getEmbedderSdkFiles());
    Set<String> specialFiles = specialLibraryFiles(findSpecialsSdk).toSet();

    /// Returns true if this library element should be included according
    /// to the configuration.
    bool isLibraryIncluded(LibraryElement libraryElement) {
      if (config.include.isNotEmpty &&
          !config.include.contains(libraryElement.name)) {
        return false;
      }
      return true;
    }

    Set<LibraryElement> foundLibraries = Set();
    await _parseLibraries(uninitializedPackageGraph.addLibraryToGraph,
        foundLibraries, files, isLibraryIncluded);
    if (config.include.isNotEmpty) {
      Iterable knownLibraryNames = foundLibraries.map((l) => l.name);
      Set notFound = Set.from(config.include)
          .difference(Set.from(knownLibraryNames))
          .difference(Set.from(config.exclude));
      if (notFound.isNotEmpty) {
        throw 'Did not find: [${notFound.join(', ')}] in '
            'known libraries: [${knownLibraryNames.join(', ')}]';
      }
    }
    // Include directive does not apply to special libraries.
    await _parseLibraries(uninitializedPackageGraph.addSpecialLibraryToGraph,
        foundLibraries, specialFiles.difference(files));
  }

  /// If [dir] contains both a `lib` directory and a `pubspec.yaml` file treat
  /// it like a package and only return the `lib` dir.
  ///
  /// This ensures that packages don't have non-`lib` content documented.
  static Iterable<FileSystemEntity> _packageDirList(Directory dir) sync* {
    var entities = dir.listSync();

    var pubspec = entities.firstWhere(
        (e) => e is File && path.basename(e.path) == 'pubspec.yaml',
        orElse: () => null);

    var libDir = entities.firstWhere(
        (e) => e is Directory && path.basename(e.path) == 'lib',
        orElse: () => null);

    if (pubspec != null && libDir != null) {
      yield libDir;
    } else {
      yield* entities;
    }
  }
}

/// This class resolves package URIs, but only if a given SdkResolver doesn't
/// resolve them.
///
/// TODO(jcollins-g): remove this hackery when a clean public API to analyzer
/// exists, and port dartdoc to it.
class PackageWithoutSdkResolver extends UriResolver {
  final UriResolver _packageResolver;
  final UriResolver _sdkResolver;

  PackageWithoutSdkResolver(this._packageResolver, this._sdkResolver);

  @override
  Source resolveAbsolute(Uri uri, [Uri actualUri]) {
    if (_sdkResolver.resolveAbsolute(uri, actualUri) == null) {
      return _packageResolver.resolveAbsolute(uri, actualUri);
    }
    return null;
  }

  @override
  Uri restoreAbsolute(Source source) {
    Uri resolved;
    try {
      resolved = _sdkResolver.restoreAbsolute(source);
    } catch (ArgumentError) {
      // SDK resolvers really don't like being thrown package paths.
    }
    if (resolved == null) {
      return _packageResolver.restoreAbsolute(source);
    }
    return null;
  }
}
