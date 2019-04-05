// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/model.dart';
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

// If found, this may be intended as a reference to a constructor.
final RegExp isConstructor = new RegExp(r'(^new[\s]+|\(\)$)', multiLine: true);

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
  MatchingLinkResult(this.element, {this.warn = true});
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

/// Returns null if element is a parameter.
MatchingLinkResult _getMatchingLinkElement(
    String codeRef, Warnable element, List<ModelCommentReference> commentRefs) {
  if (!codeRef.contains(isConstructor) &&
      codeRef.contains(notARealDocReference)) {
    // Don't waste our time on things we won't ever find.
    return new MatchingLinkResult(null, warn: false);
  }

  ModelElement refModelElement;

  // Try expensive not-scoped lookup.
  if (refModelElement == null && element is ModelElement) {
    Class preferredClass = _getPreferredClass(element);
    refModelElement = new _MarkdownCommentReference(
            codeRef, element, commentRefs, preferredClass)
        .computeReferredElement();
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
    List<ModelCommentReference> commentRefs, String codeRef) {
  if (commentRefs != null) {
    for (ModelCommentReference ref in commentRefs) {
      if (ref.name == codeRef) {
        bool isConstrElement = ref.staticElement is ConstructorElement;
        // Constructors are now handled by library search.
        if (!isConstrElement) {
          Element refElement = ref.staticElement;
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
  }
  return null;
}

/// Represents a single comment reference.
class _MarkdownCommentReference {
  /// The code reference text.
  final String codeRef;

  /// The element containing the code reference.
  final Warnable element;

  /// A list of [ModelCommentReference]s for this element.
  final List<ModelCommentReference> commentRefs;

  /// Disambiguate inheritance with this class.
  final Class preferredClass;

  /// Current results.  Input/output of all _find and _reduce methods.
  Set<ModelElement> results;

  /// codeRef with any leading constructor string, stripped.
  String codeRefChomped;

  /// Library associated with this element.
  Library library;

  /// PackageGraph associated with this element.
  PackageGraph packageGraph;

  _MarkdownCommentReference(
      this.codeRef, this.element, this.commentRefs, this.preferredClass) {
    assert(element != null);
    assert(element.packageGraph.allLibrariesAdded);

    codeRefChomped = codeRef.replaceAll(isConstructor, '');
    library =
        element is ModelElement ? (element as ModelElement).library : null;
    packageGraph = library.packageGraph;
  }

  String __impliedDefaultConstructor;
  bool __impliedDefaultConstructorIsSet = false;

  /// Returns the name of the implied default constructor if there is one, or
  /// null if not.
  ///
  /// Default constructors are a special case in dartdoc.  If we look up a name
  /// within a class of that class itself, the first thing we find is the
  /// default constructor.  But we determine whether that's what they actually
  /// intended (vs. the enclosing class) by context -- whether they seem
  /// to be calling it with () or have a 'new' in front of it, or
  /// whether the name is repeated.
  ///
  /// Similarly, referencing a class by itself might actually refer to its
  /// constructor based on these same heuristics.
  ///
  /// With the name of the implied default constructor, other methods can
  /// determine whether or not the constructor and/or class we resolved to
  /// is actually matching the user's intent.
  String get _impliedDefaultConstructor {
    if (!__impliedDefaultConstructorIsSet) {
      __impliedDefaultConstructorIsSet = true;
      if (codeRef.contains(isConstructor) ||
          (codeRefChompedParts.length >= 2 &&
              codeRefChompedParts[codeRefChompedParts.length - 1] ==
                  codeRefChompedParts[codeRefChompedParts.length - 2])) {
        // If the last two parts of the code reference are equal, this is probably a default constructor.
        __impliedDefaultConstructor = codeRefChompedParts.last;
      }
    }
    return __impliedDefaultConstructor;
  }

  /// Calculate reference to a ModelElement.
  ///
  /// Uses a series of calls to the _find* methods in this class to get one
  /// or more possible [ModelElement] matches, then uses the _reduce* methods
  /// in this class to try to bring it to a single ModelElement.  Calls
  /// [element.warn] for [PackageWarning.ambiguousDocReference] if there
  /// are more than one, but does not warn otherwise.
  ModelElement computeReferredElement() {
    results = new Set();
    // TODO(jcollins-g): A complex package winds up spending a lot of cycles in here.  Optimize.
    for (void Function() findMethod in [
      // This might be an operator.  Strip the operator prefix and try again.
      _findWithoutOperatorPrefix,
      // Oh, and someone might have thrown on a 'const' or 'final' in front.
      _findWithoutLeadingIgnoreStuff,
      // Maybe this ModelElement has parameters, and this is one of them.
      // We don't link these, but this keeps us from emitting warnings.  Be sure to
      // get members of parameters too.
      _findParameters,
      // Maybe this ModelElement has type parameters, and this is one of them.
      _findTypeParameters,
      // This could be local to the class, look there first.
      _findWithinTryClasses,
      // This could be a reference to a renamed library.
      _findReferenceFromPrefixes,
      // We now need the ref element cache to keep from repeatedly searching [Package.allModelElements].
      // But if not, look for a fully qualified match.  (That only makes sense
      // if the codeRef might be qualified, and contains periods.)
      _findWithinRefElementCache,
      // Only look for partially qualified matches if we didn't find a fully qualified one.
      _findPartiallyQualifiedMatches,
      // Only look for partially qualified matches if we didn't find a fully qualified one.
      _findGlobalWithinRefElementCache,
      // This could conceivably be a reference to an enum member.  They don't show up in allModelElements.
      _findEnumReferences,
      // Oh, and someone might have some type parameters or other garbage.
      // After finding within classes because sometimes parentheses are used
      // to imply constructors.
      _findWithoutTrailingIgnoreStuff,
      // Use the analyzer to resolve a comment reference.
      _findAnalyzerReferences,
    ]) {
      findMethod();
      // Remove any "null" objects after each step of trying to add to results.
      // TODO(jcollins-g): Eliminate all situations where nulls can be added
      // to the results set.
      results.remove(null);
      if (results.isNotEmpty) break;
    }

    if (results.length > 1) {
      // This isn't C++.  References to class methods are slightly expensive
      // in Dart so don't build that list unless you need to.
      for (void Function() reduceMethod in [
        // If a result is actually in this library, prefer that.
        _reducePreferResultsInSameLibrary,
        // If a result is accessible in this library, prefer that.
        _reducePreferResultsAccessibleInSameLibrary,
        // This may refer to an element with the same name in multiple libraries
        // in an external package, e.g. Matrix4 in vector_math and vector_math_64.
        // Disambiguate by attempting to figure out which of them our package
        // is actually using by checking the import/export graph.
        _reducePreferLibrariesInLocalImportExportGraph,
        // If a result's fully qualified name has pieces of the comment reference,
        // prefer that.
        _reducePreferReferencesIncludingFullyQualifiedName,
        // Prefer the Dart analyzer's resolution of comment references.  We can't
        // start from this because of the differences in Dartdoc canonicalization.
        _reducePreferAnalyzerResolution,
      ]) {
        reduceMethod();
        if (results.length <= 1) break;
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

  List<String> _codeRefParts;
  List<String> get codeRefParts => _codeRefParts ??= codeRef.split('.');

  List<String> _codeRefChompedParts;
  List<String> get codeRefChompedParts =>
      _codeRefChompedParts ??= codeRefChomped.split('.');

  void _reducePreferAnalyzerResolution() {
    Element refElement = _getRefElementFromCommentRefs(commentRefs, codeRef);
    if (results.any((me) => me.element == refElement)) {
      results.removeWhere((me) => me.element != refElement);
    }
  }

  void _reducePreferReferencesIncludingFullyQualifiedName() {
    String startName = "${element.fullyQualifiedName}.";
    String realName = "${element.fullyQualifiedName}.${codeRefChomped}";
    if (results.any((r) => r.fullyQualifiedName == realName)) {
      results.removeWhere((r) => r.fullyQualifiedName != realName);
    }
    if (results.any((r) => r.fullyQualifiedName.startsWith(startName))) {
      results.removeWhere((r) => !r.fullyQualifiedName.startsWith(startName));
    }
  }

  void _reducePreferLibrariesInLocalImportExportGraph() {
    if (results.any(
        (r) => library.packageImportedExportedLibraries.contains(r.library))) {
      results.removeWhere(
          (r) => !library.packageImportedExportedLibraries.contains(r.library));
    }
  }

  void _reducePreferResultsAccessibleInSameLibrary() {
    // TODO(jcollins-g): we could have saved ourselves some work by using the analyzer
    //                   to search the namespace, somehow.  Do that instead.
    if (element is ModelElement &&
        results.any((r) => r.element
            .isAccessibleIn((element as ModelElement).library.element))) {
      results.removeWhere((r) =>
          !r.element.isAccessibleIn((element as ModelElement).library.element));
    }
  }

  void _reducePreferResultsInSameLibrary() {
    if (results.any((r) => r.library?.packageName == library.packageName)) {
      results.removeWhere((r) => r.library?.packageName != library.packageName);
    }
  }

  void _findTypeParameters() {
    if (element is TypeParameters) {
      results.addAll((element as TypeParameters).typeParameters.where((p) =>
          p.name == codeRefChomped || codeRefChomped.startsWith("${p.name}.")));
    }
  }

  void _findParameters() {
    if (element is ModelElement) {
      results.addAll((element as ModelElement).allParameters.where((p) =>
          p.name == codeRefChomped || codeRefChomped.startsWith("${p.name}.")));
    }
  }

  void _findWithoutLeadingIgnoreStuff() {
    if (codeRef.contains(leadingIgnoreStuff)) {
      String newCodeRef = codeRef.replaceFirst(leadingIgnoreStuff, '');
      results.add(new _MarkdownCommentReference(
              newCodeRef, element, commentRefs, preferredClass)
          .computeReferredElement());
    }
  }

  void _findWithoutTrailingIgnoreStuff() {
    if (codeRef.contains(trailingIgnoreStuff)) {
      String newCodeRef = codeRef.replaceFirst(trailingIgnoreStuff, '');
      results.add(new _MarkdownCommentReference(
              newCodeRef, element, commentRefs, preferredClass)
          .computeReferredElement());
    }
  }

  void _findWithoutOperatorPrefix() {
    if (codeRef.startsWith(operatorPrefix)) {
      String newCodeRef = codeRef.replaceFirst(operatorPrefix, '');
      results.add(new _MarkdownCommentReference(
              newCodeRef, element, commentRefs, preferredClass)
          .computeReferredElement());
    }
  }

  void _findEnumReferences() {
    // TODO(jcollins-g): Put enum members in allModelElements with useful hrefs without blowing up other assumptions about what that means.
    // TODO(jcollins-g): This doesn't provide good warnings if an enum and class have the same name in different libraries in the same package.  Fix that.
    if (codeRefChompedParts.length >= 2) {
      String maybeEnumName = codeRefChompedParts
          .sublist(0, codeRefChompedParts.length - 1)
          .join('.');
      String maybeEnumMember = codeRefChompedParts.last;
      if (packageGraph.findRefElementCache.containsKey(maybeEnumName)) {
        for (final modelElement
            in packageGraph.findRefElementCache[maybeEnumName]) {
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

  /// Transform members of [toConvert] that are classes to their default constructor,
  /// if a constructor is implied.  If not, do the reverse conversion for default
  /// constructors.
  ModelElement _convertConstructors(ModelElement toConvert) {
    if (_impliedDefaultConstructor != null) {
      if (toConvert is Class && toConvert.name == _impliedDefaultConstructor) {
        return toConvert.defaultConstructor;
      }
      return toConvert;
    } else {
      if (toConvert is Constructor &&
          (toConvert.enclosingElement as Class).defaultConstructor ==
              toConvert) {
        return toConvert.enclosingElement;
      }
      return toConvert;
    }
  }

  void _findReferenceFromPrefixes() {
    if (element is! ModelElement) return;
    Map<String, Set<Library>> prefixToLibrary =
        (element as ModelElement).definingLibrary.prefixToLibrary;
    if (prefixToLibrary.containsKey(codeRefChompedParts.first)) {
      if (codeRefChompedParts.length == 1) {
        results.addAll(prefixToLibrary[codeRefChompedParts.first]);
      } else {
        String lookup = codeRefChompedParts.sublist(1).join('.');
        prefixToLibrary[codeRefChompedParts.first]?.forEach((l) => l
            .modelElementsNameMap[lookup]
            ?.map(_convertConstructors)
            ?.forEach((m) => _addCanonicalResult(m, _getPreferredClass(m))));
      }
    }
  }

  void _findGlobalWithinRefElementCache() {
    if (packageGraph.findRefElementCache.containsKey(codeRefChomped)) {
      for (final modelElement
          in packageGraph.findRefElementCache[codeRefChomped]) {
        if (codeRefChomped == modelElement.fullyQualifiedNameWithoutLibrary ||
            (modelElement is Library &&
                codeRefChomped == modelElement.fullyQualifiedName)) {
          _addCanonicalResult(
              _convertConstructors(modelElement), preferredClass);
        }
      }
    }
  }

  void _findPartiallyQualifiedMatches() {
    // Only look for partially qualified matches if we didn't find a fully qualified one.
    if (library.modelElementsNameMap.containsKey(codeRefChomped)) {
      for (final modelElement in library.modelElementsNameMap[codeRefChomped]) {
        _addCanonicalResult(_convertConstructors(modelElement), preferredClass);
      }
    }
  }

  void _findWithinRefElementCache() {
    // We now need the ref element cache to keep from repeatedly searching [Package.allModelElements].
    // But if not, look for a fully qualified match.  (That only makes sense
    // if the codeRef might be qualified, and contains periods.)
    if (codeRefChomped.contains('.') &&
        packageGraph.findRefElementCache.containsKey(codeRefChomped)) {
      for (final ModelElement modelElement
          in packageGraph.findRefElementCache[codeRefChomped]) {
        // For fully qualified matches, the original preferredClass passed
        // might make no sense.  Instead, use the enclosing class from the
        // element in [packageGraph.findRefElementCache], because that element's
        // enclosing class will be preferred from [codeRefChomped]'s perspective.
        _addCanonicalResult(
            _convertConstructors(modelElement),
            modelElement.enclosingElement is Class
                ? modelElement.enclosingElement
                : null);
      }
    }
  }

  void _findWithinTryClasses() {
    // Maybe this is local to a class.
    // TODO(jcollins-g): tryClasses is a strict subset of the superclass chain.  Optimize.
    List<Class> tryClasses = [preferredClass];
    Class realClass = tryClasses.first;
    if (element is Inheritable) {
      Inheritable overriddenElement =
          (element as Inheritable).overriddenElement;
      while (overriddenElement != null) {
        tryClasses.add(
            ((element as Inheritable).overriddenElement as EnclosedElement)
                .enclosingElement);
        overriddenElement = overriddenElement.overriddenElement;
      }
    }

    for (Class tryClass in tryClasses) {
      if (tryClass != null) {
        _getResultsForClass(tryClass);
      }
      results.remove(null);
      if (results.isNotEmpty) break;
    }

    if (results.isEmpty && realClass != null) {
      for (Class superClass
          in realClass.publicSuperChain.map((et) => et.element as Class)) {
        if (!tryClasses.contains(superClass)) {
          _getResultsForClass(superClass);
        }
        results.remove(null);
        if (results.isNotEmpty) break;
      }
    }
  }

  void _findAnalyzerReferences() {
    Element refElement = _getRefElementFromCommentRefs(commentRefs, codeRef);
    if (refElement != null) {
      ModelElement refModelElement = new ModelElement.fromElement(
          _getRefElementFromCommentRefs(commentRefs, codeRef),
          element.packageGraph);
      if (refModelElement is Accessor) {
        refModelElement = (refModelElement as Accessor).enclosingCombo;
      }
      refModelElement =
          refModelElement.canonicalModelElement ?? refModelElement;
      results.add(refModelElement);
    }
  }

  // Add a result, but make it canonical.
  void _addCanonicalResult(ModelElement modelElement, Class tryClass) {
    results.add(packageGraph.findCanonicalModelElementFor(modelElement.element,
        preferredClass: tryClass));
  }

  /// _getResultsForClass assumes codeRefChomped might be a member of tryClass (inherited or not)
  /// and will add to [results]
  void _getResultsForClass(Class tryClass) {
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
        _addCanonicalResult(tryClass, null);
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
        for (final c in superChain) {
          _getResultsForSuperChainElement(c, tryClass);
          if (results.isNotEmpty) break;
        }
      }
    }
  }

  /// Get any possible results for this class in the superChain.   Returns
  /// true if we found something.
  void _getResultsForSuperChainElement(Class c, Class tryClass) {
    Iterable<ModelElement> membersToCheck =
        (c.allModelElementsByNamePart[codeRefChomped] ?? [])
            .map(_convertConstructors);
    for (final ModelElement modelElement in membersToCheck) {
      // [thing], a member of this class
      _addCanonicalResult(modelElement, tryClass);
    }
    membersToCheck = (c.allModelElementsByNamePart[codeRefChompedParts.last] ??
            <ModelElement>[])
        .map(_convertConstructors);
    membersToCheck.forEach((m) => _addCanonicalResult(m, tryClass));
    results.remove(null);
    if (results.isNotEmpty) return;
    if (c.fullyQualifiedNameWithoutLibrary == codeRefChomped) {
      results.add(c);
    }
  }
}

String _linkDocReference(String codeRef, Warnable warnable,
    List<ModelCommentReference> commentRefs) {
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
  Documentation.forElement(this._element);

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

  List<ModelCommentReference> get commentRefs => _element.commentRefs;

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
