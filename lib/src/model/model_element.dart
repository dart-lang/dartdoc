// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:collection' show UnmodifiableListView;
import 'dart:convert';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, Member, ParameterMember;
import 'package:collection/collection.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model/documentation_comment.dart';
import 'package:dartdoc/src/model/feature_set.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/render/source_code_renderer.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

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
  'late': 2,
  'inherited': 3,
  'inherited-getter': 3,
  'inherited-setter': 3,
  'override': 3,
  'override-getter': 3,
  'override-setter': 3,
  'extended': 3,
};

int byFeatureOrdering(String a, String b) {
  var scoreA = 0;
  var scoreB = 0;

  if (featureOrder.containsKey(a)) scoreA = featureOrder[a];
  if (featureOrder.containsKey(b)) scoreB = featureOrder[b];

  if (scoreA < scoreB) return -1;
  if (scoreA > scoreB) return 1;
  return compareAsciiLowerCaseNatural(a, b);
}

/// This doc may need to be processed in case it has a template or html
/// fragment.
final RegExp needsPrecacheRegExp = RegExp(r'{@(template|tool|inject-html)');

final _htmlInjectRegExp = RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>');
@Deprecated('Public variable intended to be private; will be removed as early '
    'as Dartdoc 1.0.0')
RegExp get htmlInjectRegExp => _htmlInjectRegExp;

final _macroRegExp = RegExp(r'{@macro\s+([^}]+)}');
@Deprecated('Public variable intended to be private; will be removed as early '
    'as Dartdoc 1.0.0')
RegExp get macroRegExp => _macroRegExp;

// TODO(jcollins-g): Implement resolution per ECMA-408 4th edition, page 39 #22.
/// Resolves this very rare case incorrectly by picking the closest element in
/// the inheritance and interface chains from the analyzer.
ModelElement resolveMultiplyInheritedElement(
    MultiplyInheritedExecutableElement e,
    Library library,
    PackageGraph packageGraph,
    Class enclosingClass) {
  var inheritables = e.inheritedElements
      .map((ee) => ModelElement.fromElement(ee, packageGraph) as Inheritable);
  Inheritable foundInheritable;
  var lowIndex = enclosingClass.inheritanceChain.length;
  for (var inheritable in inheritables) {
    var index =
        enclosingClass.inheritanceChain.indexOf(inheritable.enclosingElement);
    if (index < lowIndex) {
      foundInheritable = inheritable;
      lowIndex = index;
    }
  }
  return ModelElement.from(foundInheritable.element, library, packageGraph,
      enclosingContainer: enclosingClass);
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
    with
        Privacy,
        Warnable,
        Locatable,
        Nameable,
        SourceCodeMixin,
        Indexable,
        FeatureSet,
        DocumentationComment
    implements Comparable<ModelElement>, Documentable {
  final Element _element;

  // TODO(jcollins-g): This really wants a "member that has a type" class.
  final Member _originalMember;
  final Library _library;

  ElementType _modelType;
  String _rawDocs;
  Documentation __documentation;
  UnmodifiableListView<Parameter> _parameters;
  String _linkedName;

  // TODO(jcollins-g): make _originalMember optional after dart-lang/sdk#15101
  // is fixed.
  ModelElement(
      this._element, this._library, this._packageGraph, this._originalMember);

  /// Creates a [ModelElement] from [e].
  factory ModelElement.fromElement(Element e, PackageGraph p) {
    var lib = p.findButDoNotCreateLibraryFor(e);
    if (e is PropertyInducingElement) {
      var getter =
          e.getter != null ? ModelElement.from(e.getter, lib, p) : null;
      var setter =
          e.setter != null ? ModelElement.from(e.setter, lib, p) : null;
      return ModelElement.fromPropertyInducingElement(e, lib, p,
          getter: getter, setter: setter);
    }
    return ModelElement.from(e, lib, p);
  }

  /// Creates a  [ModelElement] from [PropertyInducingElement] [e].
  ///
  /// Do not construct any ModelElements except from this constructor or
  /// [ModelElement.from]. Specify [enclosingContainer]
  /// if and only if this is to be an inherited or extended object.
  factory ModelElement.fromPropertyInducingElement(
      PropertyInducingElement e, Library library, PackageGraph packageGraph,
      {Container enclosingContainer,
      @required Accessor getter,
      @required Accessor setter}) {
    assert(packageGraph != null);
    assert(e != null);
    assert(library != null);

    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      e = e.declaration;
    }

    // Return the cached ModelElement if it exists.
    var key =
        Tuple3<Element, Library, Container>(e, library, enclosingContainer);
    if (packageGraph.allConstructedModelElements.containsKey(key)) {
      return packageGraph.allConstructedModelElements[key];
    }

    ModelElement newModelElement;
    if (e is FieldElement) {
      if (enclosingContainer == null) {
        if (e.isEnumConstant) {
          var index = e.computeConstantValue().getField(e.name).toIntValue();
          newModelElement =
              EnumField.forConstant(index, e, library, packageGraph, getter);
        } else if (e.enclosingElement is ExtensionElement) {
          newModelElement = Field(e, library, packageGraph, getter, setter);
        } else if (e.enclosingElement is ClassElement &&
            (e.enclosingElement as ClassElement).isEnum) {
          newModelElement = EnumField(e, library, packageGraph, getter, setter);
        } else {
          newModelElement = Field(e, library, packageGraph, getter, setter);
        }
      } else {
        // EnumFields can't be inherited, so this case is simpler.
        newModelElement = Field.inherited(
            e, enclosingContainer, library, packageGraph, getter, setter);
      }
    }
    if (e is TopLevelVariableElement) {
      assert(getter != null || setter != null);
      newModelElement =
          TopLevelVariable(e, library, packageGraph, getter, setter);
    }

    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

    assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    return newModelElement;
  }

  /// Creates a [ModelElement] from a non-property-inducing [e].
  ///
  /// Do not construct any ModelElements except from this constructor or
  /// [ModelElement.fromPropertyInducingElement]. Specify [enclosingContainer]
  /// if and only if this is to be an inherited or extended object.
  // TODO(jcollins-g): this way of using the optional parameter is messy,
  // clean that up.
  // TODO(jcollins-g): Enforce construction restraint.
  // TODO(jcollins-g): Allow e to be null and drop extraneous null checks.
  // TODO(jcollins-g): Auto-vivify element's defining library for library
  // parameter when given a null.
  factory ModelElement.from(
      Element e, Library library, PackageGraph packageGraph,
      {Container enclosingContainer}) {
    assert(packageGraph != null);
    assert(e != null);
    assert(library != null ||
        e is ParameterElement ||
        e is TypeParameterElement ||
        e is GenericFunctionTypeElementImpl ||
        e.kind == ElementKind.DYNAMIC ||
        e.kind == ElementKind.NEVER);

    if (e.kind == ElementKind.DYNAMIC) {
      return Dynamic(e, packageGraph);
    }
    if (e.kind == ElementKind.NEVER) {
      return NeverType(e, packageGraph);
    }

    Member originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      originalMember = e;
      e = e.declaration;
    }

    // Return the cached ModelElement if it exists.
    var key =
        Tuple3<Element, Library, Container>(e, library, enclosingContainer);
    if (packageGraph.allConstructedModelElements.containsKey(key)) {
      return packageGraph.allConstructedModelElements[key];
    }

    var newModelElement = ModelElement._from(e, library, packageGraph,
        enclosingContainer: enclosingContainer, originalMember: originalMember);

    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    _cacheNewModelElement(e, newModelElement, library,
        enclosingContainer: enclosingContainer);

    assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    return newModelElement;
  }

  /// Caches a newly-created [ModelElement] from [ModelElement.from] or
  /// [ModelElement.fromPropertyInducingElement].
  static void _cacheNewModelElement(
      Element e, ModelElement newModelElement, Library library,
      {Container enclosingContainer}) {
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    if (library != null && newModelElement is! Parameter) {
      var key =
          Tuple3<Element, Library, Container>(e, library, enclosingContainer);
      library.packageGraph.allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        var iKey = Tuple2<Element, Library>(e, library);
        library.packageGraph.allInheritableElements
            .putIfAbsent(iKey, () => {})
            .add(newModelElement);
      }
    }
  }

  static ModelElement _from(
      Element e, Library library, PackageGraph packageGraph,
      {Container enclosingContainer, Member originalMember}) {
    if (e is MultiplyInheritedExecutableElement) {
      return resolveMultiplyInheritedElement(
          e, library, packageGraph, enclosingContainer);
    }
    assert(e is! MultiplyDefinedElement);
    if (e is LibraryElement) {
      return Library(e, packageGraph);
    }
    if (e is ClassElement) {
      if (e.isMixin) {
        return Mixin(e, library, packageGraph);
      } else if (e.isEnum) {
        return Enum(e, library, packageGraph);
      } else {
        return Class(e, library, packageGraph);
      }
    }
    if (e is ExtensionElement) {
      return Extension(e, library, packageGraph);
    }
    if (e is FunctionElement) {
      return ModelFunction(e, library, packageGraph);
    } else if (e is GenericFunctionTypeElement) {
      assert(e.enclosingElement is FunctionTypeAliasElement);
      assert(e.enclosingElement.name != '');
      return ModelFunctionTypedef(e, library, packageGraph);
    }
    if (e is FunctionTypeAliasElement) {
      return Typedef(e, library, packageGraph);
    }
    if (e is ConstructorElement) {
      return Constructor(e, library, packageGraph);
    }
    if (e is MethodElement && e.isOperator) {
      if (enclosingContainer == null) {
        return Operator(e, library, packageGraph);
      } else {
        return Operator.inherited(e, enclosingContainer, library, packageGraph,
            originalMember: originalMember);
      }
    }
    if (e is MethodElement && !e.isOperator) {
      if (enclosingContainer == null) {
        return Method(e, library, packageGraph);
      } else {
        return Method.inherited(e, enclosingContainer, library, packageGraph,
            originalMember: originalMember);
      }
    }
    if (e is PropertyAccessorElement) {
      // Accessors can be part of a [Container], or a part of a [Library].
      if (e.enclosingElement is ClassElement ||
          e.enclosingElement is ExtensionElement ||
          e is MultiplyInheritedExecutableElement) {
        if (enclosingContainer == null) {
          return ContainerAccessor(e, library, packageGraph);
        } else {
          assert(e.enclosingElement is! ExtensionElement);
          return ContainerAccessor.inherited(
              e, library, packageGraph, enclosingContainer,
              originalMember: originalMember);
        }
      } else {
        return Accessor(e, library, packageGraph, null);
      }
    }
    if (e is TypeParameterElement) {
      return TypeParameter(e, library, packageGraph);
    }
    if (e is ParameterElement) {
      return Parameter(e, library, packageGraph,
          originalMember: originalMember);
    }
    throw 'Unknown type ${e.runtimeType}';
  }

  // Stub for mustache, which would otherwise search enclosing elements to find
  // names for members.
  bool get hasCategoryNames => false;

  // Stub for mustache.
  Iterable<Category> get displayedCategories => [];

  Set<Library> get exportedInLibraries {
    return library.packageGraph.libraryElementReexportedBy[element.library];
  }

  ModelNode _modelNode;

  @override
  ModelNode get modelNode =>
      _modelNode ??= packageGraph.getModelNodeFor(element);

  List<String> get annotations => annotationsFromMetadata(element.metadata);

  /// Returns linked annotations from a given metadata set, with escaping.
  // TODO(srawlins): Attempt to revive constructor arguments in an annotation,
  // akin to source_gen's Reviver, in order to link to inner components. For
  // example, in `@Foo(const Bar(), baz: <Baz>[Baz.one, Baz.two])`, link to
  // `Foo`, `Bar`, `Baz`, `Baz.one`, and `Baz.two`.
  List<String> annotationsFromMetadata(Iterable<ElementAnnotation> md) {
    var annotationStrings = <String>[];
    if (md == null) return annotationStrings;
    for (var a in md) {
      var annotation = (const HtmlEscape()).convert(a.toSource());
      var annotationElement = a.element;

      if (annotationElement is ConstructorElement) {
        // TODO(srawlins): I think we should actually link to the constructor,
        // which may have details about parameters. For example, given the
        // annotation `@Immutable('text')`, the constructor documents what the
        // parameter is, and the class only references `immutable`. It's a
        // lose-lose cycle of mis-direction.
        annotationElement =
            (annotationElement as ConstructorElement).returnType.element;
      } else if (annotationElement is PropertyAccessorElement) {
        annotationElement =
            (annotationElement as PropertyAccessorElement).variable;
      }
      if (annotationElement is Member) {
        annotationElement = (annotationElement as Member).declaration;
      }

      // Some annotations are intended to be invisible (such as `@pragma`).
      if (!_shouldDisplayAnnotation(annotationElement)) continue;

      var annotationModelElement =
          packageGraph.findCanonicalModelElementFor(annotationElement);
      if (annotationModelElement != null) {
        annotation = annotation.replaceFirst(
            annotationModelElement.name, annotationModelElement.linkedName);
      }
      annotationStrings.add(annotation);
    }
    return annotationStrings;
  }

  bool _shouldDisplayAnnotation(Element annotationElement) {
    if (annotationElement is ClassElement) {
      var annotationClass =
          packageGraph.findCanonicalModelElementFor(annotationElement) as Class;
      if (annotationClass == null && annotationElement != null) {
        annotationClass =
            ModelElement.fromElement(annotationElement, packageGraph) as Class;
      }

      return annotationClass == null ||
          packageGraph.isAnnotationVisible(annotationClass);
    }
    // We cannot resolve it, which does not prevent it from being displayed.
    return true;
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
        _isPublic = utils.hasPublicName(element) && !hasNodoc;
      }
    }
    return _isPublic;
  }

  List<ModelCommentReference> _commentRefs;

  @override
  List<ModelCommentReference> get commentRefs {
    if (_commentRefs == null) {
      _commentRefs = [];
      for (var from in documentationFrom) {
        var checkReferences = <ModelElement>[from];
        if (from is Accessor) {
          checkReferences.add(from.enclosingCombo);
        }
        for (var e in checkReferences) {
          _commentRefs.addAll(e.modelNode.commentRefs ?? []);
        }
      }
    }
    return _commentRefs;
  }

  DartdocOptionContext _config;

  @override
  DartdocOptionContext get config {
    _config ??= DartdocOptionContext.fromContextElement(
        packageGraph.config, library.element, packageGraph.resourceProvider);
    return _config;
  }

  Set<String> _locationPieces;

  @override
  Set<String> get locationPieces =>
      _locationPieces ??= Set.from(element.location
          .toString()
          .split(locationSplitter)
          .where((s) => s.isNotEmpty));

  static final Set<String> _specialFeatures = {
    // Replace the @override annotation with a feature that explicitly
    // indicates whether an override has occurred.
    'override',
    // Drop the plain "deprecated" annotation; that's indicated via
    // strikethroughs. Custom @Deprecated() will still appear.
    'deprecated'
  };

  Set<String> get features {
    return {
      ...annotationsFromMetadata(element.metadata
          .where((e) => !_specialFeatures.contains(e.element?.name))),
      // 'const' and 'static' are not needed here because 'const' and 'static'
      // elements get their own sections in the doc.
      if (isFinal) 'final',
      if (isLate) 'late',
    };
  }

  String get featuresAsString {
    var allFeatures = features.toList()..sort(byFeatureOrdering);
    return allFeatures.join(', ');
  }

  bool get canHaveParameters =>
      element is ExecutableElement ||
      element is FunctionTypedElement ||
      element is FunctionTypeAliasElement;

  ModelElement buildCanonicalModelElement() {
    Container preferredClass;
    if (enclosingElement is Class || enclosingElement is Extension) {
      preferredClass = enclosingElement;
    }
    return packageGraph.findCanonicalModelElementFor(element,
        preferredClass: preferredClass);
  }

  ModelElement _canonicalModelElement;
  // Returns the canonical ModelElement for this ModelElement, or null
  // if there isn't one.
  ModelElement get canonicalModelElement =>
      _canonicalModelElement ??= buildCanonicalModelElement();

  List<ModelElement> _documentationFrom;

  // TODO(jcollins-g): untangle when mixins can call super
  @override
  List<ModelElement> get documentationFrom {
    _documentationFrom ??= computeDocumentationFrom;
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
    if (documentationComment == null &&
        _canOverride &&
        this is Inheritable &&
        (this as Inheritable).overriddenElement != null) {
      return (this as Inheritable).overriddenElement.documentationFrom;
    } else if (this is Inheritable && (this as Inheritable).isInherited) {
      var thisInheritable = (this as Inheritable);
      var fromThis = ModelElement.fromElement(
          element, thisInheritable.definingEnclosingContainer.packageGraph);
      return fromThis.documentationFrom;
    } else {
      return [this];
    }
  }

  String _buildDocumentationLocal() => _buildDocumentationBaseSync();

  /// Override this to add more features to the documentation builder in a
  /// subclass.
  String buildDocumentationAddition(String docs) => docs ??= '';

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
      _rawDocs = processCommentWithoutTools(documentationComment ?? '');
    }
    _rawDocs = buildDocumentationAddition(_rawDocs);
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
      _rawDocs = await processComment(documentationComment ?? '');
    }
    _rawDocs = buildDocumentationAddition(_rawDocs);
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

  Library get definingLibrary {
    var library = packageGraph.findButDoNotCreateLibraryFor(element);
    if (library == null) {
      warn(PackageWarning.noDefiningLibraryFound);
    }
    return library;
  }

  Library _canonicalLibrary;

  // [_canonicalLibrary] can be null so we can't check against null to see
  // whether we tried to compute it before.
  bool _canonicalLibraryIsSet = false;

  @override
  Library get canonicalLibrary {
    if (!_canonicalLibraryIsSet) {
      // This is not accurate if we are constructing the Package.
      assert(packageGraph.allLibrariesAdded);

      // Privately named elements can never have a canonical library, so
      // just shortcut them out.
      if (!utils.hasPublicName(element)) {
        _canonicalLibrary = null;
      } else if (!packageGraph.localPublicLibraries.contains(definingLibrary)) {
        _canonicalLibrary = _searchForCanonicalLibrary();
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

  Library _searchForCanonicalLibrary() {
    if (definingLibrary == null) {
      return null;
    }
    var thisAndExported = definingLibrary.exportedInLibraries;

    if (thisAndExported == null) {
      return null;
    }

    // Since we're looking for a library, find the [Element] immediately
    // contained by a [CompilationUnitElement] in the tree.
    var topLevelElement = element;
    while (topLevelElement != null &&
        topLevelElement.enclosingElement is! LibraryElement &&
        topLevelElement.enclosingElement is! CompilationUnitElement &&
        topLevelElement.enclosingElement != null) {
      topLevelElement = topLevelElement.enclosingElement;
    }

    var candidateLibraries = thisAndExported
        .where((l) =>
            l.isPublic && l.package.documentedWhere != DocumentLocation.missing)
        .where((l) {
      var lookup =
          l.element.exportNamespace.definedNames[topLevelElement?.name];
      if (lookup is PropertyAccessorElement) {
        lookup = (lookup as PropertyAccessorElement).variable;
      }
      return topLevelElement == lookup;
    }).toList();

    // Avoid claiming canonicalization for elements outside of this element's
    // defining package.
    // TODO(jcollins-g): Make the else block unconditional.
    if (candidateLibraries.isNotEmpty &&
        !candidateLibraries.any((l) => l.package == definingLibrary.package)) {
      warn(PackageWarning.reexportedPrivateApiAcrossPackages,
          message: definingLibrary.package.fullyQualifiedName,
          referredFrom: candidateLibraries);
    } else {
      candidateLibraries
          .removeWhere((l) => l.package != definingLibrary.package);
    }

    if (candidateLibraries.isEmpty) {
      return null;
    }
    if (candidateLibraries.length == 1) {
      return candidateLibraries.single;
    }

    // Start with our top-level element.
    var warnable = ModelElement.fromElement(topLevelElement, packageGraph);
    // Heuristic scoring to determine which library a human likely
    // considers this element to be primarily 'from', and therefore,
    // canonical.  Still warn if the heuristic isn't that confident.
    var scoredCandidates =
        warnable.scoreCanonicalCandidates(candidateLibraries);
    candidateLibraries = scoredCandidates.map((s) => s.library).toList();
    var secondHighestScore =
        scoredCandidates[scoredCandidates.length - 2].score;
    var highestScore = scoredCandidates.last.score;
    var confidence = highestScore - secondHighestScore;

    if (confidence < config.ambiguousReexportScorerMinConfidence) {
      var libraryNames = candidateLibraries.map((l) => l.name);
      var message = '$libraryNames -> ${candidateLibraries.last.name} '
          '(confidence ${confidence.toStringAsPrecision(4)})';
      warnable.warn(PackageWarning.ambiguousReexport,
          message: message, extendedDebug: scoredCandidates.map((s) => '$s'));
    }

    return candidateLibraries.last;
  }

  @override
  bool get isCanonical {
    if (!isPublic) return false;
    if (library != canonicalLibrary) return false;
    // If there's no inheritance to deal with, we're done.
    if (this is! Inheritable) return true;
    var i = this as Inheritable;
    // If we're the defining element, or if the defining element is not in the
    // set of libraries being documented, then this element should be treated as
    // canonical (given library == canonicalLibrary).
    return i.enclosingElement == i.canonicalEnclosingContainer;
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
      return '(${path.toUri(sourceFileName)}:${characterLocation.toString()})';
    }
    return '(${path.toUri(sourceFileName)})';
  }

  /// Returns a link to extended documentation, or the empty string if that
  /// does not exist.
  String get extendedDocLink {
    if (hasExtendedDocumentation) {
      return modelElementRenderer.renderExtendedDocLink(this);
    }
    return '';
  }

  String get fileName => '$name.$fileType';

  String get fileType => package.fileType;

  String get filePath;

  String _fullyQualifiedName;

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  @override
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  String _fullyQualifiedNameWithoutLibrary;
  @override
  String get fullyQualifiedNameWithoutLibrary {
    // Remember, periods are legal in library names.
    _fullyQualifiedNameWithoutLibrary ??=
        fullyQualifiedName.replaceFirst('${library.fullyQualifiedName}.', '');
    return _fullyQualifiedNameWithoutLibrary;
  }

  @override
  String get sourceFileName => element.source.fullName;

  CharacterLocation _characterLocation;
  bool _characterLocationIsSet = false;

  @override
  CharacterLocation get characterLocation {
    if (!_characterLocationIsSet) {
      var lineInfo = compilationUnitElement.lineInfo;
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
      element.thisOrAncestorOfType<CompilationUnitElement>();

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

  bool get isLate => false;

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
    _linkedName ??= _calculateLinkedName();
    return _linkedName;
  }

  @visibleForTesting
  @override
  ModelElementRenderer get modelElementRenderer =>
      packageGraph.rendererFactory.modelElementRenderer;

  ParameterRenderer get _parameterRenderer =>
      packageGraph.rendererFactory.parameterRenderer;

  ParameterRenderer get _parameterRendererDetailed =>
      packageGraph.rendererFactory.parameterRendererDetailed;

  SourceCodeRenderer get _sourceCodeRenderer =>
      packageGraph.rendererFactory.sourceCodeRenderer;

  String get linkedParams => _parameterRenderer.renderLinkedParams(parameters);

  String get linkedParamsLines =>
      _parameterRendererDetailed.renderLinkedParams(parameters).trim();

  String get linkedParamsNoMetadata =>
      _parameterRenderer.renderLinkedParams(parameters, showMetadata: false);

  String get linkedParamsNoMetadataOrNames => _parameterRenderer
      .renderLinkedParams(parameters, showMetadata: false, showNames: false);

  ElementType get modelType {
    var element = this.element;
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
      } else if (element is ClassElement) {
        _modelType = ElementType.from(element.thisType, library, packageGraph);
      } else if (element is FunctionTypeAliasElement) {
        _modelType =
            ElementType.from(element.function.type, library, packageGraph);
      } else if (element is FunctionTypedElement) {
        _modelType = ElementType.from(element.type, library, packageGraph);
      } else if (element is ParameterElement) {
        _modelType = ElementType.from(element.type, library, packageGraph);
      } else if (element is PropertyInducingElement) {
        _modelType = ElementType.from(element.type, library, packageGraph);
      } else {
        throw UnimplementedError('(${element.runtimeType}) $element');
      }
    }
    return _modelType;
  }

  void setModelType(ElementType type) {
    _modelType = type;
  }

  String _name;

  @override
  String get name => _name ??= element.name;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

  Member get originalMember => _originalMember;

  final PackageGraph _packageGraph;

  @override
  PackageGraph get packageGraph => _packageGraph;

  @override
  Package get package => library?.package;

  bool get isPublicAndPackageDocumented => isPublic && package.isDocumented;

  List<Parameter> _allParameters;

  // TODO(jcollins-g): This is in the wrong place.  Move parts to GetterSetterCombo,
  // elsewhere as appropriate?
  List<Parameter> get allParameters {
    if (_allParameters == null) {
      var recursedParameters = <Parameter>{};
      var newParameters = <Parameter>{};
      if (this is GetterSetterCombo &&
          (this as GetterSetterCombo).setter != null) {
        newParameters.addAll((this as GetterSetterCombo).setter.parameters);
      } else {
        if (canHaveParameters) newParameters.addAll(parameters);
      }
      while (newParameters.isNotEmpty) {
        recursedParameters.addAll(newParameters);
        newParameters.clear();
        for (var p in recursedParameters) {
          var l = p.modelType.parameters
              .where((pm) => !recursedParameters.contains(pm));
          newParameters.addAll(l);
        }
      }
      _allParameters = recursedParameters.toList();
    }
    return _allParameters;
  }

  @override
  path.Context get pathContext => packageGraph.resourceProvider.pathContext;

  List<Parameter> get parameters {
    if (!canHaveParameters) {
      throw StateError('$element cannot have parameters');
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
  String computeDocumentationComment() => element.documentationComment;

  /// Unconditionally precache local documentation.
  ///
  /// Use only in factory for [PackageGraph].
  Future<void> precacheLocalDocs() async {
    _documentationLocal = await _buildDocumentationBase();
  }

  Documentation get _documentation {
    if (__documentation != null) return __documentation;
    __documentation = Documentation.forElement(this);
    return __documentation;
  }

  String _sourceCode;

  @override
  String get sourceCode {
    return _sourceCode ??=
        _sourceCodeRenderer.renderSourceCode(super.sourceCode);
  }

  bool get _canOverride =>
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
        element?.kind == ElementKind.DYNAMIC ||
        element?.kind == ElementKind.NEVER ||
        this is ModelFunction);

    if (href == null) {
      if (isPublicAndPackageDocumented) {
        warn(PackageWarning.noCanonicalFound);
      }
      return htmlEscape.convert(name);
    }

    return modelElementRenderer.renderLinkedName(this);
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

    return rawDocs.replaceAllMapped(_htmlInjectRegExp, (match) {
      var fragment = packageGraph.getHtmlFragment(match[1]);
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
    return rawDocs.replaceAllMapped(_macroRegExp, (match) {
      var macro = packageGraph.getMacro(match[1]);
      if (macro == null) {
        warn(PackageWarning.unknownMacro, message: match[1]);
      }
      macro = processCommentDirectives(macro ?? '');
      return macro;
    });
  }
}
