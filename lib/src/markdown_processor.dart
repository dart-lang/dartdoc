// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';
import 'dart:math';

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/src/dart/element/member.dart' show Member;
import 'package:html/parser.dart' show parse;
import 'package:markdown/markdown.dart' as md;

import 'model.dart';

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

// We don't emit warnings currently: #572.
const List<String> _oneLinerSkipTags = const ["code", "pre"];

final List<md.InlineSyntax> _markdown_syntaxes = [
  new _InlineCodeSyntax(),
  new _AutolinkWithoutScheme()
];

// Remove these schemas from the display text for hyperlinks.
final RegExp _hide_schemes = new RegExp('^(http|https)://');

class MatchingLinkResult {
  final ModelElement element;
  final String label;
  final bool warn;
  MatchingLinkResult(this.element, this.label, {this.warn: true});
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
NodeList<CommentReference> _getCommentRefs(ModelElement modelElement) {
  Class preferredClass = _getPreferredClass(modelElement);
  ModelElement cModelElement = modelElement.package
      .findCanonicalModelElementFor(modelElement.element,
          preferredClass: preferredClass);
  if (cModelElement == null) return null;
  modelElement = cModelElement;

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
    String codeRef, ModelElement element, List<CommentReference> commentRefs) {
  // By debugging inspection, it seems correct to not warn when we don't have
  // CommentReferences; there's actually nothing that needs resolving in
  // that case.
  if (commentRefs == null)
    return new MatchingLinkResult(null, null, warn: false);

  if (!codeRef.contains(isConstructor) &&
      codeRef.contains(notARealDocReference)) {
    // Don't waste our time on things we won't ever find.
    return new MatchingLinkResult(null, null, warn: false);
  }

  Element refElement;

  // Try expensive not-scoped lookup.
  if (refElement == null) {
    refElement = _findRefElementInLibrary(codeRef, element, commentRefs);
  }

  // This is faster but does not take canonicalization into account; try
  // only as a last resort. TODO(jcollins-g): make analyzer comment references
  // dartdoc-canonicalization-aware?
  if (refElement == null) {
    refElement = _getRefElementFromCommentRefs(commentRefs, codeRef);
  }

  // Did not find it anywhere.
  if (refElement == null) {
    return new MatchingLinkResult(null, null);
  }

  if (refElement is PropertyAccessorElement) {
    // yay we found an accessor that wraps a const, but we really
    // want the top-level field itself
    refElement = (refElement as PropertyAccessorElement).variable;
  }

  // Ignore all parameters.
  if (refElement is ParameterElement || refElement is TypeParameterElement)
    return new MatchingLinkResult(null, null, warn: false);

  Library refLibrary = element.package.findOrCreateLibraryFor(refElement);
  Element searchElement =
      refElement is Member ? refElement.baseElement : refElement;

  Class preferredClass = _getPreferredClass(element);
  ModelElement refModelElement = element.package.findCanonicalModelElementFor(
      searchElement,
      preferredClass: preferredClass);
  // There have been places in the code which helpfully cache entities
  // regardless of what package they are associated with.  This assert
  // will protect us from reintroducing that.
  assert(refModelElement == null || refModelElement.package == element.package);
  if (refModelElement != null) {
    return new MatchingLinkResult(refModelElement, null);
  }
  refModelElement = new ModelElement.from(searchElement, refLibrary);
  if (!refModelElement.isCanonical) {
    refModelElement.warn(PackageWarning.noCanonicalFound);
    // Don't warn about doc references because that's covered by the no
    // canonical library found message.
    return new MatchingLinkResult(null, null, warn: false);
  }
  // We should never get here unless there's a bug in findCanonicalModelElementFor.
  // findCanonicalModelElementFor(searchElement, preferredClass: preferredClass)
  // should only return null if ModelElement.from(searchElement, refLibrary)
  // would return a non-canonical element.  However, outside of checked mode,
  // at least we have a canonical element, so proceed.
  assert(false);
  return new MatchingLinkResult(refModelElement, null);
}

Element _getRefElementFromCommentRefs(List<CommentReference> commentRefs, String codeRef) {
  // This is faster but does not take canonicalization into account; try
  // only as a last resort. TODO(jcollins-g): make analyzer comment references
  // dartdoc-canonicalization-aware?
  for (CommentReference ref in commentRefs) {
    if (ref.identifier.name == codeRef) {
      bool isConstrElement =
          ref.identifier.staticElement is ConstructorElement;
      // Constructors are now handled by library search.
      if (!isConstrElement) {
        return ref.identifier.staticElement;
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
Element _findRefElementInLibrary(String codeRef, ModelElement element, List<CommentReference> commentRefs) {
  assert(element.package.allLibrariesAdded);

  String codeRefChomped = codeRef.replaceFirst(isConstructor, '');

  final Library library = element.library;
  final Package package = library.package;
  final Set<ModelElement> results = new Set();

  // This might be an operator.  Strip the operator prefix and try again.
  if (results.isEmpty && codeRef.startsWith('operator')) {
    String newCodeRef = codeRef.replaceFirst('operator', '');
    return _findRefElementInLibrary(newCodeRef, element, commentRefs);
  }

  results.remove(null);
  // Oh, and someone might have some type parameters or other garbage.
  if (results.isEmpty && codeRef.contains(trailingIgnoreStuff)) {
    String newCodeRef = codeRef.replaceFirst(trailingIgnoreStuff, '');
    return _findRefElementInLibrary(newCodeRef, element, commentRefs);
  }

  results.remove(null);
  // Oh, and someone might have thrown on a 'const' or 'final' in front.
  if (results.isEmpty && codeRef.contains(leadingIgnoreStuff)) {
    String newCodeRef = codeRef.replaceFirst(leadingIgnoreStuff, '');
    return _findRefElementInLibrary(newCodeRef, element, commentRefs);
  }

  // Maybe this ModelElement has parameters, and this is one of them.
  // We don't link these, but this keeps us from emitting warnings.  Be sure to
  // get members of parameters too.
  // TODO(jcollins-g): link to classes that are the types of parameters, where known
  results.addAll(element.allParameters.where((p) =>
      p.name == codeRefChomped || codeRefChomped.startsWith("${p.name}.")));

  results.remove(null);
  if (results.isEmpty) {
    // Maybe this is local to a class.
    // TODO(jcollins-g): tryClasses is a strict subset of the superclass chain.  Optimize.
    List<Class> tryClasses = [_getPreferredClass(element)];
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
            tryClass, codeRefChomped, results, codeRef, package);
      }
      if (results.isNotEmpty) break;
    }
    // Sometimes documentation refers to classes that are further up the chain.
    // Get those too.
    if (results.isEmpty && realClass != null) {
      for (Class superClass
          in realClass.superChain.map((et) => et.element as Class)) {
        if (!tryClasses.contains(superClass)) {
          _getResultsForClass(
              superClass, codeRefChomped, results, codeRef, package);
        }
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
    assert(package.allLibrariesAdded);
    _findRefElementCache = new Map();
    for (final modelElement in package.allModelElements) {
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
    for (final modelElement in _findRefElementCache[codeRefChomped]) {
      if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
      results.add(package.findCanonicalModelElementFor(modelElement.element));
    }
  }
  results.remove(null);

  // Only look for partially qualified matches if we didn't find a fully qualified one.
  if (results.isEmpty) {
    for (final modelElement in library.allModelElements) {
      if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
      if (codeRefChomped == modelElement.fullyQualifiedNameWithoutLibrary) {
        results.add(package.findCanonicalModelElementFor(modelElement.element));
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
        results.add(package.findCanonicalModelElementFor(modelElement.element));
      }
    }
  }

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

  Element result;

  results.remove(null);
  if (results.length > 1) {
    // If this name could refer to a class or a constructor, prefer the class.
    if (results.any((r) => r is Class)) {
      results.removeWhere((r) => r is Constructor);
    }
  }

  if (results.length > 1) {
    // Attempt to disambiguate using the library.
    // TODO(jcollins-g): we could have saved ourselves some work by using the analyzer
    //                   to search the namespace, somehow.  Do that instead.
    if (results.any((r) => r.element.isAccessibleIn(element.library.element))) {
      results.removeWhere(
          (r) => !r.element.isAccessibleIn(element.library.element));
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

  // TODO(jcollins-g): further disambiguations based on package information?
  if (results.isEmpty) {
    result = null;
  } else if (results.length == 1) {
    result = results.first.element;
  } else {
    element.warn(PackageWarning.ambiguousDocReference,
        "[$codeRef] => ${results.map((r) => "'${r.fullyQualifiedName}'").join(", ")}");
    result = results.first.element;
  }
  return result;
}

// _getResultsForClass assumes codeRefChomped might be a member of tryClass (inherited or not)
// and will add to [results]
void _getResultsForClass(Class tryClass, String codeRefChomped,
    Set<ModelElement> results, String codeRef, Package package) {
  // This might be part of the type arguments for the class, if so, add them.
  // Otherwise, search the class.
  if ((tryClass.modelType.typeArguments.map((e) => e.name))
      .contains(codeRefChomped)) {
    results.add(tryClass.modelType.typeArguments
        .firstWhere((e) => e.name == codeRefChomped)
        .element);
  } else {
    // People like to use 'this' in docrefs too.
    if (codeRef == 'this') {
      results.add(package.findCanonicalModelElementFor(tryClass.element));
    } else {
      // TODO(jcollins-g): get rid of reimplementation of identifier resolution
      //                   or integrate into ModelElement in a simpler way.
      List<Class> superChain = [];
      superChain.add(tryClass);
      // This seems duplicitous with our caller, but the preferredClass
      // hint matters with findCanonicalModelElementFor.
      // TODO(jcollins-g): This makes our caller ~O(n^2) vs length of superChain.
      //                   Fortunately superChains are short, but optimize this if it matters.
      superChain
          .addAll(tryClass.superChainRaw.map((t) => t.returnElement as Class));
      List<String> codeRefParts = codeRefChomped.split('.');
      for (final c in superChain) {
        // TODO(jcollins-g): add a hash-map-enabled lookup function to Class?
        for (final modelElement in c.allModelElements) {
          if (!_ConsiderIfConstructor(codeRef, modelElement)) continue;
          String namePart = modelElement.fullyQualifiedName.split('.').last;
          // TODO(jcollins-g): fix operators so we can use 'name' here or similar.
          if (codeRefChomped == namePart) {
            results.add(package.findCanonicalModelElementFor(
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
            results.add(package.findCanonicalModelElementFor(
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
                results.add(package.findCanonicalModelElementFor(
                    modelElement.element,
                    preferredClass: tryClass));
                continue;
              }
            }
          }
        }
        if (results.isNotEmpty) break;
        if (c.fullyQualifiedNameWithoutLibrary == codeRefChomped) {
          results.add(c);
          break;
        }
      }
    }
  }
}

String _linkDocReference(String codeRef, ModelElement element,
    NodeList<CommentReference> commentRefs) {
  // TODO(jcollins-g): Refactor so that doc operations work on the
  //                   documented element.
  element = element.overriddenDocumentedElement;

  MatchingLinkResult result;
  result = _getMatchingLinkElement(codeRef, element, commentRefs);
  final ModelElement linkedElement = result.element;
  final String label = result.label ?? codeRef;
  if (linkedElement != null) {
    var classContent = '';
    if (linkedElement.isDeprecated) {
      classContent = 'class="deprecated" ';
    }
    // This would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references.
    if (linkedElement.href == null) {
      return '<code>${HTML_ESCAPE.convert(label)}</code>';
    } else {
      return '<a ${classContent}href="${linkedElement.href}">$label</a>';
    }
  } else {
    if (result.warn) {
      element.warn(PackageWarning.unresolvedDocReference, codeRef);
    }
    return '<code>${HTML_ESCAPE.convert(label)}</code>';
  }
}

String _renderMarkdownToHtml(String text, [ModelElement element]) {
  md.Node _linkResolver(String name) {
    NodeList<CommentReference> commentRefs = _getCommentRefs(element);
    return new md.Text(_linkDocReference(name, element, commentRefs));
  }

  _showWarningsForGenericsOutsideSquareBracketsBlocks(text, element);
  return md.markdownToHtml(text,
      inlineSyntaxes: _markdown_syntaxes, linkResolver: _linkResolver);
}

// Maximum number of characters to display before a suspected generic.
const maxPriorContext = 20;
// Maximum number of characters to display after the beginning of a suspected generic.
const maxPostContext = 30;

// Generics should be wrapped into `[]` blocks, to avoid handling them as HTML tags
// (like, [Apple<int>]). @Hixie asked for a warning when there's something, that looks
// like a non HTML tag (a generic?) outside of a `[]` block.
// https://github.com/dart-lang/dartdoc/issues/1250#issuecomment-269257942
void _showWarningsForGenericsOutsideSquareBracketsBlocks(
    String text, ModelElement element) {
  List<int> tagPositions = findFreeHangingGenericsPositions(text);
  if (tagPositions.isNotEmpty) {
    tagPositions.forEach((int position) {
      String priorContext =
          "${text.substring(max(position - maxPriorContext, 0), position)}";
      String postContext =
          "${text.substring(position, min(position + maxPostContext, text.length))}";
      priorContext =
          priorContext.replaceAll(new RegExp(r'^.*\n', multiLine: true), '');
      postContext =
          postContext.replaceAll(new RegExp(r'\n.*$', multiLine: true), '');
      String errorMessage = "$priorContext$postContext";
      // TODO(jcollins-g):  allow for more specific error location inside comments
      element.warn(PackageWarning.typeAsHtml, errorMessage);
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

class Documentation {
  final String raw;
  final String asHtml;
  final String asOneLiner;

  factory Documentation(String markdown) {
    String tempHtml = _renderMarkdownToHtml(markdown);
    return new Documentation._internal(markdown, tempHtml);
  }

  factory Documentation.forElement(ModelElement element) {
    String tempHtml = _renderMarkdownToHtml(element.documentation, element);
    return new Documentation._internal(element.documentation, tempHtml);
  }

  Documentation._(this.raw, this.asHtml, this.asOneLiner);

  factory Documentation._internal(String markdown, String rawHtml) {
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
      pre.classes.add('prettyprint');
      // Assume the user intended Dart if there are no other classes present.
      if (!specifiesLanguage) pre.classes.add('language-dart');
    }

    // `trim` fixes issue with line ending differences between mac and windows.
    var asHtml = asHtmlDocument.body.innerHtml?.trim();
    var asOneLiner = asHtmlDocument.body.children.isEmpty
        ? ''
        : asHtmlDocument.body.children.first.innerHtml;
    if (!asOneLiner.startsWith('<p>')) {
      asOneLiner = '<p>$asOneLiner</p>';
    }
    return new Documentation._(markdown, asHtml, asOneLiner);
  }
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = new md.Element.text('code', HTML_ESCAPE.convert(match[1]));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1];
    var text = md.escapeHtml(url).replaceFirst(_hide_schemes, '');
    var anchor = new md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
