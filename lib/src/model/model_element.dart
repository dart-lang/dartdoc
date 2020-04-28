// Copyright (c) 2014, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// The models used to represent Dart code.
library dartdoc.models;

import 'dart:async';
import 'dart:collection' show UnmodifiableListView;
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart'
    show ExecutableMember, Member, ParameterMember;
import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/logging.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/model_utils.dart' as utils;
import 'package:dartdoc/src/render/model_element_renderer.dart';
import 'package:dartdoc/src/render/parameter_renderer.dart';
import 'package:dartdoc/src/source_linker.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/utils.dart';
import 'package:dartdoc/src/warnings.dart';
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

final macroRegExp = RegExp(r'{@macro\s+([^}]+)}');

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
    var lib = p.findButDoNotCreateLibraryFor(e);
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
        e.kind == ElementKind.DYNAMIC ||
        e.kind == ElementKind.NEVER);

    Member originalMember;
    // TODO(jcollins-g): Refactor object model to instantiate 'ModelMembers'
    //                   for members?
    if (e is Member) {
      originalMember = e;
      e = e.declaration;
    }
    var key =
        Tuple3<Element, Library, Container>(e, library, enclosingContainer);
    ModelElement newModelElement;
    if (e.kind != ElementKind.DYNAMIC &&
        e.kind != ElementKind.NEVER &&
        packageGraph.allConstructedModelElements.containsKey(key)) {
      newModelElement = packageGraph.allConstructedModelElements[key];
      assert(newModelElement.element is! MultiplyInheritedExecutableElement);
    } else {
      if (e.kind == ElementKind.DYNAMIC) {
        newModelElement = Dynamic(e, packageGraph);
      }
      if (e.kind == ElementKind.NEVER) {
        newModelElement = NeverType(e, packageGraph);
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
          assert(e.enclosingElement is GenericTypeAliasElement);
          assert(e.enclosingElement.name != '');
          newModelElement = ModelFunctionTypedef(e, library, packageGraph);
        }
        if (e is FunctionTypeAliasElement) {
          newModelElement = Typedef(e, library, packageGraph);
        }
        if (e is FieldElement) {
          if (enclosingContainer == null) {
            if (e.isEnumConstant) {
              var index =
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

    if (newModelElement == null) throw 'Unknown type ${e.runtimeType}';
    if (enclosingContainer != null) assert(newModelElement is Inheritable);
    // TODO(jcollins-g): Reenable Parameter caching when dart-lang/sdk#30146
    //                   is fixed?
    if (library != null && newModelElement is! Parameter) {
      library.packageGraph.allConstructedModelElements[key] = newModelElement;
      if (newModelElement is Inheritable) {
        var iKey = Tuple2<Element, Library>(e, library);
        library.packageGraph.allInheritableElements.putIfAbsent(iKey, () => {});
        library.packageGraph.allInheritableElements[iKey].add(newModelElement);
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
    return library.packageGraph.libraryElementReexportedBy[element.library];
  }

  ModelNode _modelNode;

  @override
  ModelNode get modelNode =>
      _modelNode ??= packageGraph.getModelNodeFor(element);

  List<String> get annotations => annotationsFromMetadata(element.metadata);

  /// Returns linked annotations from a given metadata set, with escaping.
  List<String> annotationsFromMetadata(List<ElementAnnotation> md) {
    var annotationStrings = <String>[];
    if (md == null) return annotationStrings;
    for (var a in md) {
      var annotation = (const HtmlEscape()).convert(a.toSource());
      var annotationElement = a.element;

      ClassElement annotationClassElement;
      if (annotationElement is ExecutableElement) {
        annotationElement =
            (annotationElement as ExecutableElement).returnType.element;
      }
      if (annotationElement is ClassElement) {
        annotationClassElement = annotationElement;
      }
      var annotationModelElement =
          packageGraph.findCanonicalModelElementFor(annotationElement);
      // annotationElement can be null if the element can't be resolved.
      var annotationClass = packageGraph
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
        var docComment = documentationComment;
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
    _config ??=
        DartdocOptionContext.fromContextElement(packageGraph.config, element);
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
    var allFeatures = <String>{};
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
    if (isLate) allFeatures.add('late');
    return allFeatures;
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

  // Returns the canonical ModelElement for this ModelElement, or null
  // if there isn't one.
  ModelElement _canonicalModelElement;

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
    List<ModelElement> docFrom;

    if (documentationComment == null &&
        canOverride() &&
        this is Inheritable &&
        (this as Inheritable).overriddenElement != null) {
      docFrom = (this as Inheritable).overriddenElement.documentationFrom;
    } else if (this is Inheritable && (this as Inheritable).isInherited) {
      var thisInheritable = (this as Inheritable);
      var fromThis = ModelElement.fromElement(
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
      _rawDocs = documentationComment ?? '';
      _rawDocs = stripComments(_rawDocs) ?? '';
      _rawDocs = _injectExamples(_rawDocs);
      _rawDocs = _injectYouTube(_rawDocs);
      _rawDocs = _injectAnimations(_rawDocs);
      _rawDocs = _stripHtmlAndAddToIndex(_rawDocs);
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
      // Since we're looking for a library, find the [Element] immediately
      // contained by a [CompilationUnitElement] in the tree.
      var topLevelElement = element;
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
        var candidateLibraries = definingLibrary.exportedInLibraries
            ?.where((l) =>
                l.isPublic &&
                l.package.documentedWhere != DocumentLocation.missing)
            ?.toList();

        if (candidateLibraries != null) {
          candidateLibraries = candidateLibraries.where((l) {
            var lookup =
                l.element.exportNamespace.definedNames[topLevelElement?.name];
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
          var warnable =
              ModelElement.fromElement(topLevelElement, packageGraph);
          if (candidateLibraries.length > 1) {
            // Heuristic scoring to determine which library a human likely
            // considers this element to be primarily 'from', and therefore,
            // canonical.  Still warn if the heuristic isn't that confident.
            var scoredCandidates =
                warnable.scoreCanonicalCandidates(candidateLibraries);
            candidateLibraries =
                scoredCandidates.map((s) => s.library).toList();
            var secondHighestScore =
                scoredCandidates[scoredCandidates.length - 2].score;
            var highestScore = scoredCandidates.last.score;
            var confidence = highestScore - secondHighestScore;
            var message =
                '${candidateLibraries.map((l) => l.name)} -> ${candidateLibraries.last.name} (confidence ${confidence.toStringAsPrecision(4)})';
            var debugLines = <String>[];
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
    if (!isPublic) return false;
    if (library == canonicalLibrary) {
      if (this is Inheritable) {
        var i = (this as Inheritable);
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
      return '(${path.toUri(sourceFileName)}:${characterLocation.toString()})';
    }
    return '(${path.toUri(sourceFileName)})';
  }

  /// Returns a link to extended documentation, or the empty string if that
  /// does not exist.
  String get extendedDocLink {
    if (hasExtendedDocumentation) {
      return _modelElementRenderer.renderExtendedDocLink(this);
    }
    return '';
  }

  String get fileName => '$name.$fileType';

  String get fileType => package.fileType;

  String get filePath;

  /// Returns the fully qualified name.
  ///
  /// For example: libraryName.className.methodName
  @override
  String get fullyQualifiedName {
    return (_fullyQualifiedName ??= _buildFullyQualifiedName());
  }

  String get fullyQualifiedNameWithoutLibrary {
    // Remember, periods are legal in library names.
    _fullyQualifiedNameWithoutLibrary ??=
        fullyQualifiedName.replaceFirst('${library.fullyQualifiedName}.', '');
    return _fullyQualifiedNameWithoutLibrary;
  }

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

  ModelElementRenderer get _modelElementRenderer =>
      packageGraph.rendererFactory.modelElementRenderer;

  ParameterRenderer get _parameterRenderer =>
      packageGraph.rendererFactory.parameterRenderer;

  ParameterRenderer get _parameterRendererDetailed =>
      packageGraph.rendererFactory.parameterRendererDetailed;

  String get linkedParams => _parameterRenderer.renderLinkedParams(parameters);

  String get linkedParamsLines =>
      _parameterRendererDetailed.renderLinkedParams(parameters).trim();

  String get linkedParamsNoMetadata =>
      _parameterRenderer.renderLinkedParams(parameters, showMetadata: false);

  String get linkedParamsNoMetadataOrNames => _parameterRenderer
      .renderLinkedParams(parameters, showMetadata: false, showNames: false);

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

  void setModelType(ElementType type) {
    _modelType = type;
  }

  @override
  String get name => element.name;

  @override
  String get oneLineDoc => _documentation.asOneLiner;

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
  void warn(PackageWarning kind,
      {String message,
      Iterable<Locatable> referredFrom,
      Iterable<String> extendedDebug}) {
    packageGraph.warnOnElement(this, kind,
        message: message,
        referredFrom: referredFrom,
        extendedDebug: extendedDebug);
  }

  String computeDocumentationComment() => element.documentationComment;

  bool _documentationCommentComputed = false;
  String _documentationComment;

  String get documentationComment {
    if (_documentationCommentComputed == false) {
      _documentationComment = computeDocumentationComment();
      _documentationCommentComputed = true;
    }
    return _documentationComment;
  }

  /// Unconditionally precache local documentation.
  ///
  /// Use only in factory for [PackageGraph].
  Future precacheLocalDocs() async {
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
        element?.kind == ElementKind.DYNAMIC ||
        element?.kind == ElementKind.NEVER ||
        this is ModelFunction);

    if (href == null) {
      if (isPublicAndPackageDocumented) {
        warn(PackageWarning.noCanonicalFound);
      }
      return htmlEscape.convert(name);
    }

    return _modelElementRenderer.renderLinkedName(this);
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
    var exampleRE = RegExp(r'{@example\s+([^}]+)}');
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
        var filePath = element.source.fullName.substring(dirPath.length + 1);

        logWarning(
            'warning: ${filePath}: @example file not found, ${fragmentFile.path}');
      }
      return replacement;
    });
  }

  static Future<String> _replaceAllMappedAsync(String string, Pattern exp,
      Future<String> Function(Match match) replace) async {
    var replaced = StringBuffer();
    var currentIndex = 0;
    for (var match in exp.allMatches(string)) {
      var prefix = match.input.substring(currentIndex, match.start);
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
      var invocationIndex = 0;
      return await _replaceAllMappedAsync(rawDocs, basicToolRegExp,
          (basicMatch) async {
        var args = _splitUpQuotedArgs(basicMatch[1]).toList();
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
    var basicAnimationRegExp = RegExp(r'''{@youtube\s+([^}]+)}''');

    // Matches YouTube IDs from supported YouTube URLs.
    var validYouTubeUrlRegExp =
        RegExp('https://www\.youtube\.com/watch\\?v=([^&]+)\$');

    return rawDocs.replaceAllMapped(basicAnimationRegExp, (basicMatch) {
      var parser = ArgParser();
      var args = _parseArgs(basicMatch[1], parser, 'youtube');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      var positionalArgs = args.rest.sublist(0);
      if (positionalArgs.length != 3) {
        warn(PackageWarning.invalidParameter,
            message: 'Invalid @youtube directive, "${basicMatch[0]}"\n'
                'YouTube directives must be of the form "{@youtube WIDTH '
                'HEIGHT URL}"');
        return '';
      }

      var width = int.tryParse(positionalArgs[0]);
      if (width == null || width <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid width, '
                '"${positionalArgs[0]}". The width must be a positive integer.');
      }

      var height = int.tryParse(positionalArgs[1]);
      if (height == null || height <= 0) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid height, '
                '"${positionalArgs[1]}". The height must be a positive integer.');
      }

      var url = validYouTubeUrlRegExp.firstMatch(positionalArgs[2]);
      if (url == null) {
        warn(PackageWarning.invalidParameter,
            message: 'A @youtube directive has an invalid URL: '
                '"${positionalArgs[2]}". Supported YouTube URLs have the '
                'following format: https://www.youtube.com/watch?v=oHg5SJYRHA0.');
        return '';
      }
      var youTubeId = url.group(url.groupCount);
      var aspectRatio = (height / width * 100).toStringAsFixed(2);

      return _modelElementRenderer.renderYoutubeUrl(youTubeId, aspectRatio);
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
    var basicAnimationRegExp = RegExp(r'''{@animation\s+([^}]+)}''');

    // Matches valid javascript identifiers.
    var validIdRegExp = RegExp(r'^[a-zA-Z_]\w*$');

    // Make sure we have a set to keep track of used IDs for this href.
    package.usedAnimationIdsByHref[href] ??= {};

    String getUniqueId(String base) {
      var animationIdCount = 1;
      var id = '$base$animationIdCount';
      // We check for duplicate IDs so that we make sure not to collide with
      // user-supplied ids on the same page.
      while (package.usedAnimationIdsByHref[href].contains(id)) {
        animationIdCount++;
        id = '$base$animationIdCount';
      }
      return id;
    }

    return rawDocs.replaceAllMapped(basicAnimationRegExp, (basicMatch) {
      var parser = ArgParser();
      parser.addOption('id');
      var args = _parseArgs(basicMatch[1], parser, 'animation');
      if (args == null) {
        // Already warned about an invalid parameter if this happens.
        return '';
      }
      final positionalArgs = args.rest.sublist(0);
      String uniqueId;
      var wasDeprecated = false;
      if (positionalArgs.length == 4) {
        // Supports the original form of the animation tag for backward
        // compatibility.
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
      var overlayId = '${uniqueId}_play_button_';

      // Only warn about deprecation if some other warning didn't occur.
      if (wasDeprecated) {
        warn(PackageWarning.deprecated,
            message:
                'Deprecated form of @animation directive, "${basicMatch[0]}"\n'
                'Animation directives are now of the form "{@animation '
                'WIDTH HEIGHT URL [id=ID]}" (id is an optional '
                'parameter)');
      }

      return _modelElementRenderer.renderAnimation(
          uniqueId, width, height, movieUrl, overlayId);
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
    return rawDocs.replaceAllMapped(macroRegExp, (match) {
      var macro = packageGraph.getMacro(match[1]);
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
      packageGraph.addMacro(match[1].trim(), match[2].trim());
      return '{@macro ${match[1].trim()}}';
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
      var fragment = match[1];
      var digest = sha1.convert(fragment.codeUnits).toString();
      packageGraph.addHtmlFragment(digest, fragment);
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
    var parser = ArgParser();
    parser.addOption('lang');
    parser.addOption('region');
    var results = _parseArgs(argsAsString, parser, 'example');
    if (results == null) {
      return null;
    }

    // Extract PATH and fix the path separators.
    var src = results.rest.isEmpty
        ? ''
        : results.rest.first.replaceAll('/', Platform.pathSeparator);
    var args = <String, String>{
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
