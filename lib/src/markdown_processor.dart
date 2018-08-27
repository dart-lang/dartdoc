// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';
import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart' hide TypeParameter;
import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model.dart';
import 'package:dartdoc/src/model_utils.dart';
import 'package:dartdoc/src/tuple.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

const validHtmlTags = const [
  "a",
  "abbr",
  "address",
  "area",
  "article",
  "aside",
  "audio",
  "b",
  "bdi",
  "bdo",
  "blockquote",
  "br",
  "button",
  "canvas",
  "caption",
  "cite",
  "code",
  "col",
  "colgroup",
  "data",
  "datalist",
  "dd",
  "del",
  "dfn",
  "div",
  "dl",
  "dt",
  "em",
  "fieldset",
  "figcaption",
  "figure",
  "footer",
  "form",
  "h1",
  "h2",
  "h3",
  "h4",
  "h5",
  "h6",
  "header",
  "hr",
  "i",
  "iframe",
  "img",
  "input",
  "ins",
  "kbd",
  "keygen",
  "label",
  "legend",
  "li",
  "link",
  "main",
  "map",
  "mark",
  "meta",
  "meter",
  "nav",
  "noscript",
  "object",
  "ol",
  "optgroup",
  "option",
  "output",
  "p",
  "param",
  "pre",
  "progress",
  "q",
  "s",
  "samp",
  "script",
  "section",
  "select",
  "small",
  "source",
  "span",
  "strong",
  "style",
  "sub",
  "sup",
  "table",
  "tbody",
  "td",
  "template",
  "textarea",
  "tfoot",
  "th",
  "thead",
  "time",
  "title",
  "tr",
  "track",
  "u",
  "ul",
  "var",
  "video",
  "wbr"
];

final RegExp nonHTML =
    new RegExp("</?(?!(${validHtmlTags.join("|")})[> ])\\w+[> ]");

// Type parameters and other things to ignore at the end of doc references.
final RegExp trailingIgnoreStuff = new RegExp(r'(<.*>|\(.*\))$');

// Things to ignore at the beginning of doc references
final RegExp leadingIgnoreStuff =
    new RegExp(r'^(const|final|var)[\s]+', multiLine: true);

// This is explicitly intended as a reference to a constructor.
final RegExp isConstructor = new RegExp(r'^new[\s]+', multiLine: true);

// This is probably not really intended as a doc reference, so don't try or
// warn about them.
// Covers anything with leading digits/symbols, empty string, weird punctuation, spaces.
final RegExp notARealDocReference = new RegExp(r'''(^[^\w]|^[\d]|[,"'/]|^$)''');

final RegExp operatorPrefix = new RegExp(r'^operator[ ]*');

final HtmlEscape htmlEscape = const HtmlEscape(HtmlEscapeMode.element);

final List<md.InlineSyntax> _markdown_syntaxes = [
  new _InlineCodeSyntax(),
  new _AutolinkWithoutScheme()

]..addAll(md.ExtensionSet.gitHubWeb.inlineSyntaxes);

final List<md.BlockSyntax> _markdown_block_syntaxes = []
  ..addAll(md.ExtensionSet.gitHubWeb.blockSyntaxes);

// Remove these schemas from the display text for hyperlinks.
final RegExp _hide_schemes = new RegExp('^(http|https)://');

class MatchingLinkResult {
  final ModelElement element;
  final bool warn;
  MatchingLinkResult(this.element, {this.warn: true});
}

class IterableBlockParser extends md.BlockParser {
  IterableBlockParser(lines, document) : super(lines, document);

  Iterable<md.Node> parseLinesGenerator() sync* {
    while (!isDone) {
      for (var syntax in blockSyntaxes) {
        if (syntax.canParse(this)) {
          md.Node block = syntax.parse(this);
          if (block != null) yield (block);
          break;
        }
      }
    }
  }
}

// Calculate a class hint for findCanonicalModelElementFor.
ModelElement _getPreferredClass(ModelElement modelElement) {
  if (modelElement is EnclosedElement &&
      (modelElement as EnclosedElement).enclosingElement is Class) {
    return (modelElement as EnclosedElement).enclosingElement;
  } else if (modelElement is Class) {
    return modelElement;
  }
  return null;
}

// TODO: this is in the wrong place
NodeList<CommentReference> _getCommentRefs(Documentable documentable) {
  // Documentable items that aren't related to analyzer elements have no
  // CommentReference list.
  if (documentable is! ModelElement) return null;
  ModelElement modelElement = documentable;

  if (modelElement.element.documentationComment == null &&
      modelElement.canOverride()) {
    var node = modelElement.overriddenElement?.element?.computeNode();
    if (node is AnnotatedNode) {
      if (node.documentationComment != null) {
        return node.documentationComment.references;
      }
    }
  }

  if (modelElement.element.computeNode() is AnnotatedNode) {
    final AnnotatedNode annotatedNode = modelElement.element.computeNode();
    if (annotatedNode.documentationComment != null) {
      return annotatedNode.documentationComment.references;
    }
  } else if (modelElement.element is LibraryElement) {
    // handle anonymous libraries
    if (modelElement.element.computeNode() == null ||
        modelElement.element.computeNode().parent == null) {
      return null;
    }
    var node = modelElement.element.computeNode().parent.parent;
    if (node is AnnotatedNode) {
      if (node.documentationComment != null) {
        return node.documentationComment.references;
      }
    }
  }

  // Our references might come from somewhere up in the inheritance chain.
  // TODO(jcollins-g): rationalize this and all other places where docs are
  //                   inherited to be consistent.
  if (modelElement.element is ClassMemberElement) {
    var node = modelElement.element
        .getAncestor((e) => e is ClassElement)
        .computeNode();
    if (node is AnnotatedNode) {
      if (node.documentationComment != null) {
        return node.documentationComment.references;
      }
    }
  }
  return null;
}

/// Returns null if element is a parameter.
MatchingLinkResult _getMatchingLinkElement(
    String codeRef, Warnable element, List<CommentReference> commentRefs) {
  // By debugging inspection, it seems correct to not warn when we don't have
  // CommentReferences; there's actually nothing that needs resolving in
  // that case.
  if (commentRefs == null) return new MatchingLinkResult(null, warn: false);

  if (!codeRef.contains(isConstructor) &&
      codeRef.contains(notARealDocReference)) {
    // Don't waste our time on things we won't ever find.
    return new MatchingLinkResult(null, warn: false);
  }

  ModelElement refModelElement;

  // Try expensive not-scoped lookup.
  if (refModelElement == null) {
    Class preferredClass = _getPreferredClass(element);
    refModelElement =
        _findRefElementInLibrary(codeRef, element, commentRefs, preferredClass);
  }

  // This is faster but does not know about libraries without imports in the
  // current context; try only as a last resort.
  // TODO(jcollins-g): make analyzer comment references dartdoc-canonicalization-aware?
  if (refModelElement == null) {
    Element refElement = _getRefElementFromCommentRefs(commentRefs, codeRef);
    if (refElement != null) {
      refModelElement = new ModelElement.fromElement(
          _getRefElementFromCommentRefs(commentRefs, codeRef),
          element.packageGraph);
      refModelElement =
          refModelElement.canonicalModelElement ?? refModelElement;
    }
  } else {
    assert(refModelElement is! Accessor);
  }

  // Did not find it anywhere.
  if (refModelElement == null) {
    // TODO(jcollins-g): remove squelching of non-canonical warnings here
    //                   once we no longer process full markdown for
    //                   oneLineDocs (#1417)
    return new MatchingLinkResult(null, warn: element.isCanonical);
  }

  // Ignore all parameters.
  if (refModelElement is Parameter || refModelElement is TypeParameter)
    return new MatchingLinkResult(null, warn: false);

  // There have been places in the code which helpfully cache entities
  // regardless of what package they are associated with.  This assert
  // will protect us from reintroducing that.
  assert(refModelElement == null ||
      refModelElement.packageGraph == element.packageGraph);
  if (refModelElement != null) {
    return new MatchingLinkResult(refModelElement);
  }
  // From this point on, we haven't been able to find a canonical ModelElement.
  if (!refModelElement.isCanonical) {
    if (refModelElement.library.isPublicAndPackageDocumented) {
      refModelElement
          .warn(PackageWarning.noCanonicalFound, referredFrom: [element]);
    }
    // Don't warn about doc references because that's covered by the no
    // canonical library found message.
    return new MatchingLinkResult(null, warn: false);
  }
  // We should never get here unless there's a bug in findCanonicalModelElementFor.
  // findCanonicalModelElementFor(searchElement, preferredClass: preferredClass)
  // should only return null if ModelElement.from(searchElement, refLibrary)
  // would return a non-canonical element.  However, outside of checked mode,
  // at least we have a canonical element, so proceed.
  assert(false);
  return new MatchingLinkResult(refModelElement);
}

/// Given a set of commentRefs, return the one whose name matches the codeRef.
Element _getRefElementFromCommentRefs(
    List<CommentReference> commentRefs, String codeRef) {
  for (CommentReference ref in commentRefs) {
    if (ref.identifier.name == codeRef) {
      bool isConstrElement = ref.identifier.staticElement is ConstructorElement;
      // Constructors are now handled by library search.
      if (!isConstrElement) {
        Element refElement = ref.identifier.staticElement;
        if (refElement is PropertyAccessorElement) {
          // yay we found an accessor that wraps a const, but we really
          // want the top-level field itself
          refElement = (refElement as PropertyAccessorElement).variable;
        }
        if (refElement is PrefixElement) {
          // We found a prefix element, but what we really want is the library element.
          refElement = (refElement as PrefixElement).enclosingElement;
        }
        return refElement;
      }
    }
  }
  return null;
}

/// Returns true if this is a constructor we should consider in
/// _findRefElementInLibrary, or if this isn't a constructor.
bool _ConsiderIfConstructor(String codeRef, ModelElement modelElement) {
  if (modelElement is! Constructor) return true;
  if (codeRef.contains(isConstructor)) return true;
  Constructor aConstructor = modelElement;
  List<String> codeRefParts = codeRef.split('.');
  if (codeRefParts.length > 1) {
    // Pick the last two parts, in case a specific library was part of the
    // codeRef.
    if (codeRefParts[codeRefParts.length - 1] ==
        codeRefParts[codeRefParts.length - 2]) {
      // Foobar.Foobar -- assume they really do mean the constructor for this class.
      return true;
    }
  }
  if (aConstructor.name != aConstructor.enclosingElement.name) {
    // This isn't a default constructor so treat it like any other member.
    return true;
  }
  return false;
}

// Basic map of reference to ModelElement, for cases where we're searching
// outside of scope.
// TODO(jcollins-g): function caches with maps are very common in dartdoc.
//                   Extract into library.
Map<String, Set<ModelElement>> _findRefElementCache;
// TODO(jcollins-g): Rewrite this to handle constructors in a less hacky way
// TODO(jcollins-g): This function breaks down naturally into many helpers, extract them
// TODO(jcollins-g): Subcomponents of this function shouldn't be adding nulls to results, strip the
//                   removes out that are gratuitous and debug the individual pieces.
// TODO(jcollins-g): A complex package winds up spending a lot of cycles in here.  Optimize.
ModelElement _findRefElementInLibrary(String codeRef, Warnable element,
    List<CommentReference> commentRefs, Class preferredClass) {
  assert(element != null);
  assert(element.packageGraph.allLibrariesAdded);

  String codeRefChomped = codeRef.replaceFirst(isConstructor, '');

  final Library library = element is ModelElement ? element.library : null;
  final PackageGraph packageGraph = library.packageGraph;
  final Set<ModelElement> results = new Set();

  // This might be an operator.  Strip the operator prefix and try again.
  if (results.isEmpty && codeRef.startsWith(operatorPrefix)) {
    String newCodeRef = codeRef.replaceFirst(operatorPrefix, '');
    return _findRefElementInLibrary(
        newCodeRef, element, commentRefs, preferredClass);
  }

  results.remove(null);
  // Oh, and someone might have some type parameters or other garbage.
  if (results.isEmpty && codeRef.contains(trailingIgnoreStuff)) {
    String newCodeRef = codeRef.replaceFirst(trailingIgnoreStuff, '');
    return _findRefElementInLibrary(
        newCodeRef, element, commentRefs, preferredClass);
  }

  results.remove(null);
  // Oh, and someone might have thrown on a 'const' or 'final' in front.
  if (results.isEmpty && codeRef.contains(leadingIgnoreStuff)) {
    String newCodeRef = codeRef.replaceFirst(leadingIgnoreStuff, '');
    return _findRefElementInLibrary(
        newCodeRef, element, commentRefs, preferredClass);
  }

  // Maybe this ModelElement has parameters, and this is one of them.
  // We don't link these, but this keeps us from emitting warnings.  Be sure to
  // get members of parameters too.
  // TODO(jcollins-g): link to classes that are the types of parameters, where known
  if (element is ModelElement) {
    results.addAll(element.allParameters.where((p) =>
        p.name == codeRefChomped || codeRefChomped.startsWith("${p.name}.")));
  }

  results.remove(null);
  // Maybe this ModelElement has type parameters, and this is one of them.
  if (results.isEmpty) {
    if (element is TypeParameters) {
      results.addAll(element.typeParameters.where((p) =>
          p.name == codeRefChomped || codeRefChomped.startsWith("${p.name}.")));
    }
  }

  results.remove(null);
  if (results.isEmpty) {
    // Maybe this is local to a class.
    // TODO(jcollins-g): tryClasses is a strict subset of the superclass chain.  Optimize.
    List<Class> tryClasses = [preferredClass];
    Class realClass = tryClasses.first;
    if (element is Inheritable) {
      ModelElement overriddenElement = element.overriddenElement;
      while (overriddenElement != null) {
        tryClasses.add(
            (element.overriddenElement as EnclosedElement).enclosingElement);
        overriddenElement = overriddenElement.overriddenElement;
      }
    }

    for (Class tryClass in tryClasses) {
      if (tryClass != null) {
        _getResultsForClass(
            tryClass, codeRefChomped, results, codeRef, packageGraph);
      }
      results.remove(null);
      if (results.isNotEmpty) break;
    }

    if (results.isEmpty && realClass != null) {
      for (Class superClass
          in realClass.publicSuperChain.map((et) => et.element as Class)) {
        if (!tryClasses.contains(superClass)) {
          _getResultsForClass(
              superClass, codeRefChomped, results, codeRef, packageGraph);
        }
        results.remove(null);
        if (results.isNotEmpty) break;
      }
    }
  }
  results.remove(null);

  // We now need the ref element cache to keep from repeatedly searching [Package.allModelElements].
  // TODO(jcollins-g): Find somewhere to cache elements outside package.libraries
  //                   so we can give the right warning (no canonical found)
  //                   when referring to objects in libraries outside the
  //                   documented set.
  if (results.isEmpty && _findRefElementCache == null) {
    assert(packageGraph.allLibrariesAdded);
    _findRefElementCache = new Map();
    for (final modelElement
        in filterNonDocumented(packageGraph.allLocalModelElements)) {
      _findRefElementCache.putIfAbsent(
          modelElement.fullyQualifiedNameWithoutLibrary, () => new Set());
      _findRefElementCache.putIfAbsent(
          modelElement.fullyQualifiedName, () => new Set());
      _findRefElementCache[modelElement.fullyQualifiedName].add(modelElement);
      _findRefElementCache[modelElement.fullyQualifiedNameWithoutLibrary]
          .add(modelElement);
    }
  }

  // But if not, look for a fully qualified match.  (That only makes sense
  // if the codeRef might be qualified, and contains periods.)
  if (results.isEmpty &&
      codeRefChomped.contains('.') &&
      _findRefElementCache.containsKey(codeRefChomped)) {
    for (final ModelElement modelElement
        in _findRefElementCache[codeRefChomped]) {
      if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
      // For fully qualified matches, the original preferredClass passed
      // might make no sense.  Instead, use the enclosing class from the
      // element in [_findRefElementCache], because that element's enclosing
      // class will be preferred from [codeRefChomped]'s perspective.
      results.add(packageGraph.findCanonicalModelElementFor(
          modelElement.element,
          preferredClass: modelElement.enclosingElement is Class
              ? modelElement.enclosingElement
              : null));
    }
  }
  results.remove(null);

  // Only look for partially qualified matches if we didn't find a fully qualified one.
  if (results.isEmpty) {
    for (final modelElement in library.allModelElements) {
      if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
      if (codeRefChomped == modelElement.fullyQualifiedNameWithoutLibrary) {
        results.add(packageGraph.findCanonicalModelElementFor(
            modelElement.element,
            preferredClass: preferredClass));
      }
    }
  }
  results.remove(null);

  // And if we still haven't found anything, just search the whole ball-of-wax.
  if (results.isEmpty && _findRefElementCache.containsKey(codeRefChomped)) {
    for (final modelElement in _findRefElementCache[codeRefChomped]) {
      if (codeRefChomped == modelElement.fullyQualifiedNameWithoutLibrary ||
          (modelElement is Library &&
              codeRefChomped == modelElement.fullyQualifiedName)) {
        results.add(
            packageGraph.findCanonicalModelElementFor(modelElement.element));
      }
    }
  }
  results.remove(null);

  // This could conceivably be a reference to an enum member.  They don't show up in allModelElements.
  // TODO(jcollins-g): Put enum members in allModelElements with useful hrefs without blowing up other assumptions about what that means.
  // TODO(jcollins-g): This doesn't provide good warnings if an enum and class have the same name in different libraries in the same package.  Fix that.
  if (results.isEmpty) {
    List<String> codeRefChompedParts = codeRefChomped.split('.');
    if (codeRefChompedParts.length >= 2) {
      String maybeEnumName = codeRefChompedParts
          .sublist(0, codeRefChompedParts.length - 1)
          .join('.');
      String maybeEnumMember = codeRefChompedParts.last;
      if (_findRefElementCache.containsKey(maybeEnumName)) {
        for (final modelElement in _findRefElementCache[maybeEnumName]) {
          if (modelElement is Enum) {
            if (modelElement.constants.any((e) => e.name == maybeEnumMember)) {
              results.add(modelElement);
              break;
            }
          }
        }
      }
    }
  }
  results.remove(null);

  if (results.length > 1) {
    // If this name could refer to a class or a constructor, prefer the class.
    if (results.any((r) => r is Class)) {
      results.removeWhere((r) => r is Constructor);
    }
  }

  if (results.length > 1) {
    if (results.any((r) => r.library?.packageName == library.packageName)) {
      results.removeWhere((r) => r.library?.packageName != library.packageName);
    }
  }

  if (results.length > 1 && element is ModelElement) {
    // Attempt to disambiguate using the library.
    // TODO(jcollins-g): we could have saved ourselves some work by using the analyzer
    //                   to search the namespace, somehow.  Do that instead.
    if (results.any((r) => r.element.isAccessibleIn(element.library.element))) {
      results.removeWhere(
          (r) => !r.element.isAccessibleIn(element.library.element));
    }
  }

  if (results.length > 1) {
    // This may refer to an element with the same name in multiple libraries
    // in an external package, e.g. Matrix4 in vector_math and vector_math_64.
    // Disambiguate by attempting to figure out which of them our package
    // is actually using by checking the import/export graph.
    if (results.any(
        (r) => library.packageImportedExportedLibraries.contains(r.library))) {
      results.removeWhere(
          (r) => !library.packageImportedExportedLibraries.contains(r.library));
    }
  }

  // TODO(jcollins-g): This is only necessary because we had to jettison commentRefs
  // as a way to figure this out.  We could reintroduce commentRefs, or we could
  // compute this via other means.
  if (results.length > 1) {
    String startName = "${element.fullyQualifiedName}.";
    String realName = "${element.fullyQualifiedName}.${codeRefChomped}";
    if (results.any((r) => r.fullyQualifiedName == realName)) {
      results.removeWhere((r) => r.fullyQualifiedName != realName);
    }
    if (results.any((r) => r.fullyQualifiedName.startsWith(startName))) {
      results.removeWhere((r) => !r.fullyQualifiedName.startsWith(startName));
    }
  }

  // TODO(jcollins-g): As a last resort, try disambiguation with commentRefs.
  //                   Maybe one of these is the same as what's resolvable with
  //                   the analyzer, and if so, drop the others.  We can't
  //                   do this in reverse order because commentRefs don't know
  //                   about dartdoc canonicalization.
  if (results.length > 1) {
    Element refElement = _getRefElementFromCommentRefs(commentRefs, codeRef);
    if (results.any((me) => me.element == refElement)) {
      results.removeWhere((me) => me.element != refElement);
    }
  }

  ModelElement result;
  // TODO(jcollins-g): further disambiguations based on package information?
  if (results.isEmpty) {
    result = null;
  } else if (results.length == 1) {
    result = results.first;
  } else {
    // Squelch ambiguous doc reference warnings for parameters, because we
    // don't link those anyway.
    if (!results.every((r) => r is Parameter)) {
      element.warn(PackageWarning.ambiguousDocReference,
          message:
              "[$codeRef] => ${results.map((r) => "'${r.fullyQualifiedName}'").join(", ")}");
    }
    result = results.first;
  }
  return result;
}

// _getResultsForClass assumes codeRefChomped might be a member of tryClass (inherited or not)
// and will add to [results]
void _getResultsForClass(Class tryClass, String codeRefChomped,
    Set<ModelElement> results, String codeRef, PackageGraph packageGraph) {
  // This might be part of the type arguments for the class, if so, add them.
  // Otherwise, search the class.
  if ((tryClass.modelType.typeArguments.map((e) => e.name))
      .contains(codeRefChomped)) {
    results.add((tryClass.modelType.typeArguments.firstWhere(
                (e) => e.name == codeRefChomped && e is DefinedElementType)
            as DefinedElementType)
        .element);
  } else {
    // People like to use 'this' in docrefs too.
    if (codeRef == 'this') {
      results.add(packageGraph.findCanonicalModelElementFor(tryClass.element));
    } else {
      // TODO(jcollins-g): get rid of reimplementation of identifier resolution
      //                   or integrate into ModelElement in a simpler way.
      List<Class> superChain = [tryClass];
      superChain.addAll(tryClass.interfaces.map((t) => t.element as Class));
      // This seems duplicitous with our caller, but the preferredClass
      // hint matters with findCanonicalModelElementFor.
      // TODO(jcollins-g): This makes our caller ~O(n^2) vs length of superChain.
      //                   Fortunately superChains are short, but optimize this if it matters.
      superChain.addAll(tryClass.superChain.map((t) => t.element as Class));
      List<String> codeRefParts = codeRefChomped.split('.');
      for (final c in superChain) {
        // TODO(jcollins-g): add a hash-map-enabled lookup function to Class?
        for (final modelElement in c.allModelElements) {
          if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
          String namePart = modelElement.fullyQualifiedName.split('.').last;
          if (modelElement is Accessor) {
            // TODO(jcollins-g): Individual classes should be responsible for
            // this name comparison munging.
            namePart = namePart.split('=').first;
          }
          // TODO(jcollins-g): fix operators so we can use 'name' here or similar.
          if (codeRefChomped == namePart) {
            results.add(packageGraph.findCanonicalModelElementFor(
                modelElement.element,
                preferredClass: tryClass));
            continue;
          }
          // Handle non-documented class documentation being imported into a
          // documented class when it refers to itself (with help from caller's
          // iteration on tryClasses).
          // TODO(jcollins-g): Fix partial qualifications in _findRefElementInLibrary so it can tell
          // when it is referenced from a non-documented element?
          // TODO(jcollins-g): We could probably check this early.
          if (codeRefParts.first == c.name && codeRefParts.last == namePart) {
            results.add(packageGraph.findCanonicalModelElementFor(
                modelElement.element,
                preferredClass: tryClass));
            continue;
          }
          if (modelElement is Constructor) {
            // Constructor names don't include the class, so we might miss them in the above search.
            List<String> codeRefParts = codeRefChomped.split('.');
            if (codeRefParts.length > 1) {
              String codeRefClass = codeRefParts[codeRefParts.length - 2];
              String codeRefConstructor = codeRefParts.last;
              if (codeRefClass == c.name &&
                  codeRefConstructor ==
                      modelElement.fullyQualifiedName.split('.').last) {
                results.add(packageGraph.findCanonicalModelElementFor(
                    modelElement.element,
                    preferredClass: tryClass));
                continue;
              }
            }
          }
        }
        results.remove(null);
        if (results.isNotEmpty) break;
        if (c.fullyQualifiedNameWithoutLibrary == codeRefChomped) {
          results.add(c);
          break;
        }
      }
    }
  }
}

String _linkDocReference(
    String codeRef, Warnable warnable, NodeList<CommentReference> commentRefs) {
  MatchingLinkResult result;
  result = _getMatchingLinkElement(codeRef, warnable, commentRefs);
  final ModelElement linkedElement = result.element;
  if (linkedElement != null) {
    var classContent = '';
    if (linkedElement.isDeprecated) {
      classContent = 'class="deprecated" ';
    }
    // This would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references.
    if (linkedElement.href == null) {
      return '<code>${htmlEscape.convert(codeRef)}</code>';
    } else {
      return '<a ${classContent}href="${linkedElement.href}">${htmlEscape.convert(codeRef)}</a>';
    }
  } else {
    if (result.warn) {
      warnable.warn(PackageWarning.unresolvedDocReference,
          message: codeRef, referredFrom: warnable.documentationFrom);
    }
    return '<code>${htmlEscape.convert(codeRef)}</code>';
  }
}

// Maximum number of characters to display before a suspected generic.
const maxPriorContext = 20;
// Maximum number of characters to display after the beginning of a suspected generic.
const maxPostContext = 30;

final RegExp allBeforeFirstNewline = new RegExp(r'^.*\n', multiLine: true);
final RegExp allAfterLastNewline = new RegExp(r'\n.*$', multiLine: true);

// Generics should be wrapped into `[]` blocks, to avoid handling them as HTML tags
// (like, [Apple<int>]). @Hixie asked for a warning when there's something, that looks
// like a non HTML tag (a generic?) outside of a `[]` block.
// https://github.com/dart-lang/dartdoc/issues/1250#issuecomment-269257942
void _showWarningsForGenericsOutsideSquareBracketsBlocks(
    String text, Warnable element) {
  List<int> tagPositions = findFreeHangingGenericsPositions(text);
  if (tagPositions.isNotEmpty) {
    tagPositions.forEach((int position) {
      String priorContext =
          "${text.substring(max(position - maxPriorContext, 0), position)}";
      String postContext =
          "${text.substring(position, min(position + maxPostContext, text.length))}";
      priorContext = priorContext.replaceAll(allBeforeFirstNewline, '');
      postContext = postContext.replaceAll(allAfterLastNewline, '');
      String errorMessage = "$priorContext$postContext";
      // TODO(jcollins-g):  allow for more specific error location inside comments
      element.warn(PackageWarning.typeAsHtml, message: errorMessage);
    });
  }
}

List<int> findFreeHangingGenericsPositions(String string) {
  int currentPosition = 0;
  int squareBracketsDepth = 0;
  List<int> results = [];
  while (true) {
    final int nextOpenBracket = string.indexOf("[", currentPosition);
    final int nextCloseBracket = string.indexOf("]", currentPosition);
    final int nextNonHTMLTag = string.indexOf(nonHTML, currentPosition);
    final Iterable<int> nextPositions = [
      nextOpenBracket,
      nextCloseBracket,
      nextNonHTMLTag
    ].where((p) => p != -1);
    if (nextPositions.isNotEmpty) {
      final minPos = nextPositions.reduce(min);
      if (nextOpenBracket == minPos) {
        squareBracketsDepth += 1;
      } else if (nextCloseBracket == minPos) {
        squareBracketsDepth = max(squareBracketsDepth - 1, 0);
      } else if (nextNonHTMLTag == minPos) {
        if (squareBracketsDepth == 0) {
          results.add(minPos);
        }
      }
      currentPosition = minPos + 1;
    } else {
      break;
    }
  }
  return results;
}

class MarkdownDocument extends md.Document {
  MarkdownDocument(
      {Iterable<md.BlockSyntax> blockSyntaxes,
      Iterable<md.InlineSyntax> inlineSyntaxes,
      md.ExtensionSet extensionSet,
      md.Resolver linkResolver,
      imageLinkResolver})
      : super(
            blockSyntaxes: blockSyntaxes,
            inlineSyntaxes: inlineSyntaxes,
            extensionSet: extensionSet,
            linkResolver: linkResolver,
            imageLinkResolver: imageLinkResolver);

  /// Returns a tuple of longHtml, shortHtml.  longHtml is NULL if [processFullDocs] is true.
  static Tuple2<String, String> _renderNodesToHtml(
      List<md.Node> nodes, bool processFullDocs) {
    var rawHtml = new md.HtmlRenderer().render(nodes);
    var asHtmlDocument = parse(rawHtml);
    for (var s in asHtmlDocument.querySelectorAll('script')) {
      s.remove();
    }
    for (var pre in asHtmlDocument.querySelectorAll('pre')) {
      if (pre.children.isNotEmpty &&
          pre.children.length != 1 &&
          pre.children.first.localName != 'code') {
        continue;
      }

      if (pre.children.isNotEmpty && pre.children.first.localName == 'code') {
        var code = pre.children.first;
        pre.classes
            .addAll(code.classes.where((name) => name.startsWith('language-')));
      }

      bool specifiesLanguage = pre.classes.isNotEmpty;
      // Assume the user intended Dart if there are no other classes present.
      if (!specifiesLanguage) pre.classes.add('language-dart');
    }
    String asHtml;
    String asOneLiner;

    if (processFullDocs) {
      // `trim` fixes issue with line ending differences between mac and windows.
      asHtml = asHtmlDocument.body.innerHtml?.trim();
    }
    asOneLiner = asHtmlDocument.body.children.isEmpty
        ? ''
        : asHtmlDocument.body.children.first.innerHtml;

    return new Tuple2(asHtml, asOneLiner);
  }

  // From package:markdown/src/document.dart
  // TODO(jcollins-g): consider making this a public method in markdown package
  void _parseInlineContent(List<md.Node> nodes) {
    for (int i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node is md.UnparsedContent) {
        List<md.Node> inlineNodes =
            new md.InlineParser(node.textContent, this).parse();
        nodes.removeAt(i);
        nodes.insertAll(i, inlineNodes);
        i += inlineNodes.length - 1;
      } else if (node is md.Element && node.children != null) {
        _parseInlineContent(node.children);
      }
    }
  }

  /// Returns a tuple of longHtml, shortHtml (longHtml is NULL if !processFullDocs)
  Tuple3<String, String, bool> renderLinesToHtml(
      List<String> lines, bool processFullDocs) {
    bool hasExtendedDocs = false;
    md.Node firstNode;
    List<md.Node> nodes = [];
    for (md.Node node
        in new IterableBlockParser(lines, this).parseLinesGenerator()) {
      if (firstNode != null) {
        hasExtendedDocs = true;
        if (!processFullDocs) break;
      }
      firstNode ??= node;
      nodes.add(node);
    }
    _parseInlineContent(nodes);

    String shortHtml;
    String longHtml;
    if (processFullDocs) {
      Tuple2 htmls = _renderNodesToHtml(nodes, processFullDocs);
      longHtml = htmls.item1;
      shortHtml = htmls.item2;
    } else {
      if (firstNode != null) {
        Tuple2 htmls = _renderNodesToHtml([firstNode], processFullDocs);
        shortHtml = htmls.item2;
      } else {
        shortHtml = '';
      }
    }
    return new Tuple3<String, String, bool>(
        longHtml, shortHtml, hasExtendedDocs);
  }
}

class Documentation {
  final Canonicalization _element;
  Documentation.forElement(this._element) {}

  bool _hasExtendedDocs;
  bool get hasExtendedDocs {
    if (_hasExtendedDocs == null) {
      _renderHtmlForDartdoc(_element.isCanonical && _asHtml == null);
    }
    return _hasExtendedDocs;
  }

  String _asHtml;
  String get asHtml {
    if (_asHtml == null) {
      assert(_asOneLiner == null || _element.isCanonical);
      _renderHtmlForDartdoc(true);
    }
    return _asHtml;
  }

  String _asOneLiner;
  String get asOneLiner {
    if (_asOneLiner == null) {
      assert(_asHtml == null);
      _renderHtmlForDartdoc(_element.isCanonical);
    }
    return _asOneLiner;
  }

  NodeList<CommentReference> _commentRefs;
  NodeList<CommentReference> get commentRefs {
    if (_commentRefs == null) _commentRefs = _getCommentRefs(_element);
    return _commentRefs;
  }

  void _renderHtmlForDartdoc(bool processAllDocs) {
    Tuple3<String, String, bool> renderResults =
        _renderMarkdownToHtml(processAllDocs);
    if (processAllDocs) {
      _asHtml = renderResults.item1;
    }
    if (_asOneLiner == null) {
      _asOneLiner = renderResults.item2;
    }
    if (_hasExtendedDocs != null) {
      assert(_hasExtendedDocs == renderResults.item3);
    }
    _hasExtendedDocs = renderResults.item3;
  }

  /// Returns a tuple of longHtml, shortHtml, hasExtendedDocs
  /// (longHtml is NULL if !processFullDocs)
  Tuple3<String, String, bool> _renderMarkdownToHtml(bool processFullDocs) {
    md.Node _linkResolver(String name, [String _]) {
      if (name.isEmpty) {
        return null;
      }
      return new md.Text(_linkDocReference(name, _element, commentRefs));
    }

    String text = _element.documentation;
    _showWarningsForGenericsOutsideSquareBracketsBlocks(text, _element);
    MarkdownDocument document = new MarkdownDocument(
        inlineSyntaxes: _markdown_syntaxes,
        blockSyntaxes: _markdown_block_syntaxes,
        linkResolver: _linkResolver);
    List<String> lines = LineSplitter.split(text).toList();
    return document.renderLinesToHtml(lines, processFullDocs);
  }
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = new md.Element.text('code', htmlEscape.convert(match[1]));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1];
    var text = htmlEscape.convert(url).replaceFirst(_hide_schemes, '');
    var anchor = new md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
