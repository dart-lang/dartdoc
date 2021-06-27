// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Utility code to convert markdown comments to html.
library dartdoc.markdown_processor;

import 'dart:convert';
import 'dart:math';

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/comment_references/model_comment_reference.dart';
import 'package:dartdoc/src/element_type.dart';
import 'package:dartdoc/src/matching_link_result.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:meta/meta.dart';

const validHtmlTags = [
  'a',
  'abbr',
  'address',
  'area',
  'article',
  'aside',
  'audio',
  'b',
  'bdi',
  'bdo',
  'blockquote',
  'br',
  'button',
  'canvas',
  'caption',
  'cite',
  'code',
  'col',
  'colgroup',
  'data',
  'datalist',
  'dd',
  'del',
  'dfn',
  'div',
  'dl',
  'dt',
  'em',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'hr',
  'i',
  'iframe',
  'img',
  'input',
  'ins',
  'kbd',
  'keygen',
  'label',
  'legend',
  'li',
  'link',
  'main',
  'map',
  'mark',
  'meta',
  'meter',
  'nav',
  'noscript',
  'object',
  'ol',
  'optgroup',
  'option',
  'output',
  'p',
  'param',
  'pre',
  'progress',
  'q',
  's',
  'samp',
  'script',
  'section',
  'select',
  'small',
  'source',
  'span',
  'strong',
  'style',
  'sub',
  'sup',
  'table',
  'tbody',
  'td',
  'template',
  'textarea',
  'tfoot',
  'th',
  'thead',
  'time',
  'title',
  'tr',
  'track',
  'u',
  'ul',
  'var',
  'video',
  'wbr'
];

final RegExp nonHTML =
    RegExp("</?(?!(${validHtmlTags.join("|")})[> ])\\w+[> ]");

/// Things to ignore at the end of a doc reference.
///
/// This is intended to catch type parameters/arguments, and function call
/// parentheses.
final _trailingIgnorePattern = RegExp(r'(<.*>|\(.*\)|\?|!)$');

/// Things to ignore at the beginning of a doc reference.
///
/// This is intended to catch various keywords that a developer may include in
/// front of a variable name.
// TODO(srawlins): I cannot find any tests asserting we can resolve such
// references.
final _leadingIgnorePattern =
    RegExp(r'^(const|final|var)[\s]+', multiLine: true);

/// If found, this pattern may indicate a reference to a constructor.
final _constructorIndicationPattern =
    RegExp(r'(^new[\s]+|\(\)$)', multiLine: true);

/// A pattern indicating that text which looks like a doc reference is not
/// intended to be.
///
/// This covers anything with leading digits/symbols, empty strings, weird
/// punctuation, spaces.
///
/// The idea is to catch such cases and not produce warnings about the contents.
// TODO(jcollins-g): consider being more strict here.
final RegExp notARealDocReference = RegExp(r'''(^[^\w]|^[\d]|[,"'/]|^$)''');

final RegExp operatorPrefix = RegExp(r'^operator[ ]*');

final HtmlEscape htmlEscape = const HtmlEscape(HtmlEscapeMode.element);

final List<md.InlineSyntax> _markdownSyntaxes = [
  _InlineCodeSyntax(),
  _AutolinkWithoutScheme(),
  md.InlineHtmlSyntax(),
  md.StrikethroughSyntax(),
  md.AutolinkExtensionSyntax(),
];

final List<md.BlockSyntax> _markdownBlockSyntaxes = [
  const md.FencedCodeBlockSyntax(),
  const md.HeaderWithIdSyntax(),
  const md.SetextHeaderWithIdSyntax(),
  const md.TableSyntax(),
];

// Remove these schemas from the display text for hyperlinks.
final RegExp _hideSchemes = RegExp('^(http|https)://');

class IterableBlockParser extends md.BlockParser {
  IterableBlockParser(List<String> lines, md.Document document)
      : super(lines, document);

  Iterable<md.Node> parseLinesGenerator() sync* {
    while (!isDone) {
      for (var syntax in blockSyntaxes) {
        if (syntax.canParse(this)) {
          var block = syntax.parse(this);
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
      (modelElement as EnclosedElement).enclosingElement is Container) {
    return (modelElement as EnclosedElement).enclosingElement;
  } else if (modelElement is Class) {
    return modelElement;
  }
  return null;
}

/// Return false if the passed [referable] is a default [Constructor],
/// or if it is shadowing another type of element, or is a parameter of
/// one of the above.
bool _rejectDefaultAndShadowingConstructors(CommentReferable referable) {
  if (referable is Constructor) {
    if (referable.name == referable.enclosingElement.name) {
      return false;
    }
    if (referable.enclosingElement
        .referenceChildren[referable.name.split('.').last] is! Constructor) {
      return false;
    }
  }
  return true;
}

/// Return false unless the passed [referable] represents a callable object.
/// Allows constructors but does not require them.
bool _requireCallable(CommentReferable referable) =>
    referable is ModelElement && referable.isCallable;

/// Return false unless the passed [referable] represents a constructor.
bool _requireConstructor(CommentReferable referable) =>
    referable is Constructor;

/// Implements _getMatchingLinkElement via [CommentReferable.referenceBy].
MatchingLinkResult _getMatchingLinkElementCommentReferable(
    String codeRef, Warnable warnable) {
  var commentReference =
      warnable.commentRefs[codeRef] ?? ModelCommentReference.synthetic(codeRef);

  bool Function(CommentReferable) filter;
  bool Function(CommentReferable) allowTree;

  // Constructor references are pretty ambiguous by nature since they are
  // declared with the same name as the class they are constructing, and even
  // if they don't use field-formal parameters, sometimes have parameters
  // named the same as members.
  // Maybe clean this up with inspiration from constructor tear-off syntax?
  if (commentReference.allowDefaultConstructor) {
    // Neither reject, nor require, a default constructor in the event
    // the comment reference structure implies one.  (We can not require it
    // in case a library name is the same as a member class name and the class
    // is the intended lookup).   For example, [FooClass.FooClass] structurally
    // "looks like" a default constructor, so we should allow it here.
    filter = commentReference.hasCallableHint ? _requireCallable : null;
  } else if (commentReference.hasConstructorHint &&
      commentReference.hasCallableHint) {
    // This takes precedence over the callable hint if both are present --
    // pick a constructor and only constructor if we see `new`.
    filter = _requireConstructor;
  } else if (commentReference.hasCallableHint) {
    // Trailing parens indicate we are looking for a callable.
    filter = _requireCallable;
  } else {
    // Without hints, reject default constructors and their parameters to force
    // resolution to the class.
    filter = _rejectDefaultAndShadowingConstructors;

    if (!commentReference.allowDefaultConstructorParameter) {
      allowTree = _rejectDefaultAndShadowingConstructors;
    }
  }

  var lookupResult = warnable.referenceBy(commentReference.referenceBy,
      allowTree: allowTree, filter: filter);

  // TODO(jcollins-g): Consider prioritizing analyzer resolution before custom.
  return MatchingLinkResult(lookupResult);
}

/// Returns null if element is a parameter.
MatchingLinkResult _getMatchingLinkElementLegacy(
    String codeRef, Warnable warnable) {
  if (!codeRef.contains(_constructorIndicationPattern) &&
      codeRef.contains(notARealDocReference)) {
    // Don't waste our time on things we won't ever find.
    return MatchingLinkResult(null, warn: false);
  }

  ModelElement refModelElement;

  // Try expensive not-scoped lookup.
  if (refModelElement == null && warnable is ModelElement) {
    Container preferredClass = _getPreferredClass(warnable);
    // We might still get here in comparison mode, don't complain if that's
    // the case.
    if (preferredClass is Extension &&
        warnable.config.enhancedReferenceLookup == false) {
      warnable.warn(PackageWarning.notImplemented,
          message:
              'Comment reference resolution inside extension methods is not yet implemented');
    } else {
      refModelElement =
          _MarkdownCommentReference(codeRef, warnable, preferredClass)
              .computeReferredElement();
    }
  }

  // Did not find it anywhere.
  if (refModelElement == null) {
    // TODO(jcollins-g): remove squelching of non-canonical warnings here
    //                   once we no longer process full markdown for
    //                   oneLineDocs (#1417)
    return MatchingLinkResult(null, warn: warnable.isCanonical);
  }

  // Ignore all parameters.
  if (refModelElement is Parameter || refModelElement is TypeParameter) {
    return MatchingLinkResult(null, warn: false);
  }

  // There have been places in the code which helpfully cache entities
  // regardless of what package they are associated with.  This assert
  // will protect us from reintroducing that.
  assert(refModelElement == null ||
      refModelElement.packageGraph == warnable.packageGraph);
  if (refModelElement != null) {
    return MatchingLinkResult(refModelElement);
  }
  // From this point on, we haven't been able to find a canonical ModelElement.
  if (!refModelElement.isCanonical) {
    if (refModelElement.library.isPublicAndPackageDocumented) {
      refModelElement
          .warn(PackageWarning.noCanonicalFound, referredFrom: [warnable]);
    }
    // Don't warn about doc references because that's covered by the no
    // canonical library found message.
    return MatchingLinkResult(null, warn: false);
  }
  // We should never get here unless there's a bug in findCanonicalModelElementFor.
  // findCanonicalModelElementFor(searchElement, preferredClass: preferredClass)
  // should only return null if ModelElement.from(searchElement, refLibrary)
  // would return a non-canonical element.  However, outside of checked mode,
  // at least we have a canonical element, so proceed.
  assert(false);
  return MatchingLinkResult(refModelElement);
}

/// Get the element referred by the [codeRef] in analyzer.
/// Deletes constructors and otherwise messes with the output for the rest
/// of the heuristics.
Element _getRefElementFromCommentRefs(Warnable element, String codeRef) {
  if (element.commentRefs != null) {
    var ref = element.commentRefs[codeRef];
    // ref can be null here if the analyzer failed to recognize this as a
    // comment reference (e.g. [Foo.operator []]).
    if (ref != null) {
      // Constructors are now handled by library search.
      if (ref.staticElement is! ConstructorElement) {
        var refElement = ref.staticElement;
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

/// Represents a single comment reference.
class _MarkdownCommentReference {
  /// The code reference text.
  final String codeRef;

  /// The element containing the code reference.
  final Warnable element;

  /// Disambiguate inheritance with this class.
  final Class preferredClass;

  /// Current results.  Input/output of all _find and _reduce methods.
  Set<CommentReferable> results;

  /// codeRef with any leading constructor string, stripped.
  String codeRefChomped;

  /// Library associated with this element.
  Library library;

  /// PackageGraph associated with this element.
  PackageGraph packageGraph;

  _MarkdownCommentReference(this.codeRef, this.element, this.preferredClass) {
    assert(element != null);
    assert(element.packageGraph.allLibrariesAdded);

    codeRefChomped = codeRef.replaceAll(_constructorIndicationPattern, '');
    library =
        element is ModelElement ? (element as ModelElement).library : null;
    packageGraph = library.packageGraph;
  }

  String __impliedUnnamedConstructor;

  /// [_impliedUnnamedConstructor] is memoized in [__impliedUnnamedConstructor],
  /// but even after it is initialized, it may be null. This bool represents the
  /// initialization state.
  bool __impliedUnnamedConstructorIsSet = false;

  /// Returns the name of the implied unnamed constructor if there is one, or
  /// null if not.
  ///
  /// Unnamed constructors are a special case in dartdoc.  If we look up a name
  /// within a class of that class itself, the first thing we find is the
  /// unnamed constructor.  But we determine whether that's what they actually
  /// intended (vs. the enclosing class) by context -- whether they seem
  /// to be calling it with () or have a 'new' in front of it, or
  /// whether the name is repeated.
  ///
  /// Similarly, referencing a class by itself might actually refer to its
  /// unnamed constructor based on these same heuristics.
  ///
  /// With the name of the implied unnamed constructor, other methods can
  /// determine whether or not the constructor and/or class we resolved to
  /// is actually matching the user's intent.
  String get _impliedUnnamedConstructor {
    if (!__impliedUnnamedConstructorIsSet) {
      __impliedUnnamedConstructorIsSet = true;
      if (codeRef.contains(_constructorIndicationPattern) ||
          (codeRefChompedParts.length >= 2 &&
              codeRefChompedParts[codeRefChompedParts.length - 1] ==
                  codeRefChompedParts[codeRefChompedParts.length - 2])) {
        // If the last two parts of the code reference are equal, this is probably a default constructor.
        __impliedUnnamedConstructor = codeRefChompedParts.last;
      }
    }
    return __impliedUnnamedConstructor;
  }

  /// Calculate reference to a ModelElement.
  ///
  /// Uses a series of calls to the _find* methods in this class to get one
  /// or more possible [ModelElement] matches, then uses the _reduce* methods
  /// in this class to try to bring it to a single ModelElement.  Calls
  /// [element.warn] for [PackageWarning.ambiguousDocReference] if there
  /// are more than one, but does not warn otherwise.
  ModelElement computeReferredElement() {
    results = {};
    // TODO(jcollins-g): A complex package winds up spending a lot of cycles in
    // here.  Optimize.
    for (var findMethod in [
      // This might be an operator.  Strip the operator prefix and try again.
      _findWithoutOperatorPrefix,
      // Oh, and someone might have thrown on a 'const' or 'final' in front.
      _findWithoutLeadingIgnoreStuff,
      // Maybe this ModelElement has parameters, and this is one of them.
      // We don't link these, but this keeps us from emitting warnings.  Be sure
      // to get members of parameters too.
      _findParameters,
      // Maybe this ModelElement has type parameters, and this is one of them.
      _findTypeParameters,
      // This could be local to the class, look there first.
      _findWithinTryClasses,
      // This could be a reference to a renamed library.
      _findReferenceFromPrefixes,
      // We now need the ref element cache to keep from repeatedly searching
      // [Package.allModelElements].  But if not, look for a fully qualified
      // match.  (That only makes sense if the code reference might be
      // qualified, and contains periods.)
      _findWithinRefElementCache,
      // Only look for partially qualified matches if we didn't find a fully
      // qualified one.
      _findPartiallyQualifiedMatches,
      // Only look for partially qualified matches if we didn't find a fully
      // qualified one.
      _findGlobalWithinRefElementCache,
      // This could conceivably be a reference to an enum member.  They don't
      // show up in [allModelElements].
      _findEnumReferences,
      // Oh, and someone might have some type parameters or other garbage.
      // After finding within classes because sometimes parentheses are used to
      // imply constructors.
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
      for (var reduceMethod in [
        // If a result is actually in this library, prefer that.
        _reducePreferResultsInSameLibrary,
        // If a result is accessible in this library, prefer that.
        _reducePreferResultsAccessibleInSameLibrary,
        // This may refer to an element with the same name in multiple libraries
        // in an external package, e.g. Matrix4 in vector_math and
        // vector_math_64.  Disambiguate by attempting to figure out which of
        // them our package is actually using by checking the import/export
        // graph.
        _reducePreferLibrariesInLocalImportExportGraph,
        // If a result's fully qualified name has pieces of the comment
        // reference, prefer that.
        _reducePreferReferencesIncludingFullyQualifiedName,
        // If the reference is indicated to be a constructor, prefer
        // constructors.  This is not as generic as it sounds; very few naming
        // conflicts are allowed, but an instance field is allowed to have the
        // same name as a named constructor.
        _reducePreferConstructorViaIndicators,
        // Prefer Fields/TopLevelVariables to accessors.
        // TODO(jcollins-g): Remove after fixing dart-lang/dartdoc#2396 or
        // exclude Accessors from all lookup tables.
        _reducePreferCombos,
        // Prefer the Dart analyzer's resolution of comment references.  We
        // can't start from this because of the differences in Dartdoc
        // canonicalization.
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
        var elementNames = results.map((r) => "'${r.fullyQualifiedName}'");
        element.warn(PackageWarning.ambiguousDocReference,
            message: '[$codeRef] => ${elementNames.join(', ')}');
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
    var refElement = _getRefElementFromCommentRefs(element, codeRef);
    if (results.any((me) => me.element == refElement)) {
      results.removeWhere((me) => me.element != refElement);
    }
  }

  void _reducePreferConstructorViaIndicators() {
    if (codeRef.contains(_constructorIndicationPattern) &&
        codeRefChompedParts.length >= 2) {
      results.removeWhere((r) => r is! Constructor);
    }
  }

  void _reducePreferReferencesIncludingFullyQualifiedName() {
    var startName = '${element.fullyQualifiedName}.';
    var realName = '${element.fullyQualifiedName}.$codeRefChomped';
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

  void _reducePreferCombos() {
    var accessors = results.whereType<Accessor>().toList();
    accessors.forEach((a) {
      results.remove(a);
      results.add(a.enclosingCombo);
    });
  }

  void _findTypeParameters() {
    if (element is TypeParameters) {
      results.addAll((element as TypeParameters).typeParameters.where((p) =>
          p.name == codeRefChomped || codeRefChomped.startsWith('${p.name}.')));
    }
  }

  void _findParameters() {
    if (element is ModelElement) {
      results.addAll((element as ModelElement).allParameters.where((p) =>
          p.name == codeRefChomped || codeRefChomped.startsWith('${p.name}.')));
    }
  }

  void _findWithoutLeadingIgnoreStuff() {
    if (codeRef.contains(_leadingIgnorePattern)) {
      var newCodeRef = codeRef.replaceFirst(_leadingIgnorePattern, '');
      results.add(_MarkdownCommentReference(newCodeRef, element, preferredClass)
          .computeReferredElement());
    }
  }

  void _findWithoutTrailingIgnoreStuff() {
    if (codeRef.contains(_trailingIgnorePattern)) {
      var newCodeRef = codeRef.replaceFirst(_trailingIgnorePattern, '');
      results.add(_MarkdownCommentReference(newCodeRef, element, preferredClass)
          .computeReferredElement());
    }
  }

  void _findWithoutOperatorPrefix() {
    if (codeRef.startsWith(operatorPrefix)) {
      var newCodeRef = codeRef.replaceFirst(operatorPrefix, '');
      results.add(_MarkdownCommentReference(newCodeRef, element, preferredClass)
          .computeReferredElement());
    }
  }

  void _findEnumReferences() {
    // TODO(jcollins-g): Put enum members in allModelElements with useful hrefs without blowing up other assumptions about what that means.
    // TODO(jcollins-g): This doesn't provide good warnings if an enum and class have the same name in different libraries in the same package.  Fix that.
    if (codeRefChompedParts.length >= 2) {
      var maybeEnumName = codeRefChompedParts
          .sublist(0, codeRefChompedParts.length - 1)
          .join('.');
      var maybeEnumMember = codeRefChompedParts.last;
      if (packageGraph.findRefElementCache.containsKey(maybeEnumName)) {
        for (final modelElement
            in packageGraph.findRefElementCache[maybeEnumName]) {
          if (modelElement is Enum) {
            if (modelElement.constantFields
                .any((e) => e.name == maybeEnumMember)) {
              results.add(modelElement);
              break;
            }
          }
        }
      }
    }
  }

  /// Returns the unnamed constructor for class [toConvert] or the class for
  /// constructor [toConvert], or just [toConvert], based on heuristics.
  ///
  /// * If an unnamed constructor is implied in the comment reference, and
  ///   [toConvert] is a class with the same name, the class's unnamed
  ///   constructor is returned.
  /// * Otherwise, if [toConvert] is an unnamed constructor, its enclosing
  ///   class is returned.
  /// * Otherwise, [toConvert] is returned.
  ModelElement _convertConstructors(ModelElement toConvert) {
    if (_impliedUnnamedConstructor != null) {
      if (toConvert is Class && toConvert.name == _impliedUnnamedConstructor) {
        return toConvert.unnamedConstructor;
      }
      return toConvert;
    } else {
      if (toConvert is Constructor &&
          (toConvert.enclosingElement as Class).unnamedConstructor ==
              toConvert) {
        return toConvert.enclosingElement;
      }
      return toConvert;
    }
  }

  void _findReferenceFromPrefixes() {
    if (element is! ModelElement) return;
    var prefixToLibrary =
        (element as ModelElement).definingLibrary.prefixToLibrary;
    if (prefixToLibrary.containsKey(codeRefChompedParts.first)) {
      if (codeRefChompedParts.length == 1) {
        results.addAll(prefixToLibrary[codeRefChompedParts.first]);
      } else {
        var lookup = codeRefChompedParts.sublist(1).join('.');
        prefixToLibrary[codeRefChompedParts.first]?.forEach((l) => l
            .modelElementsNameMap[lookup]
            ?.map(_convertConstructors)
            ?.forEach((m) => _addCanonicalResult(m)));
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
          _addCanonicalResult(_convertConstructors(modelElement));
        }
      }
    }
  }

  void _findPartiallyQualifiedMatches() {
    // Only look for partially qualified matches if we didn't find a fully qualified one.
    if (library.modelElementsNameMap.containsKey(codeRefChomped)) {
      for (final modelElement in library.modelElementsNameMap[codeRefChomped]) {
        _addCanonicalResult(_convertConstructors(modelElement));
      }
    }
  }

  void _findWithinRefElementCache() {
    // We now need the ref element cache to keep from repeatedly searching [Package.allModelElements].
    // But if not, look for a fully qualified match.  (That only makes sense
    // if the codeRef might be qualified, and contains periods.)
    if (codeRefChomped.contains('.') &&
        packageGraph.findRefElementCache.containsKey(codeRefChomped)) {
      for (var modelElement
          in packageGraph.findRefElementCache[codeRefChomped]) {
        _addCanonicalResult(_convertConstructors(modelElement));
      }
    }
  }

  void _findWithinTryClasses() {
    // Maybe this is local to a class.
    // TODO(jcollins-g): tryClasses is a strict subset of the superclass chain.  Optimize.
    var tryClasses = <Class>[preferredClass];
    var realClass = tryClasses.first;
    if (element is Inheritable) {
      var overriddenElement = (element as Inheritable).overriddenElement;
      while (overriddenElement != null) {
        tryClasses
            .add((element as Inheritable).overriddenElement.enclosingElement);
        overriddenElement = overriddenElement.overriddenElement;
      }
    }

    for (var tryClass in tryClasses) {
      if (tryClass != null) {
        if (codeRefChomped.contains('.') &&
            !codeRefChomped.startsWith(tryClass.name)) {
          continue;
        }
        _getResultsForClass(tryClass);
      }
      results.remove(null);
      if (results.isNotEmpty) break;
    }

    if (results.isEmpty && realClass != null) {
      for (var superClass
          in realClass.publicSuperChain.map((et) => et.modelElement)) {
        if (!tryClasses.contains(superClass)) {
          _getResultsForClass(superClass);
        }
        results.remove(null);
        if (results.isNotEmpty) break;
      }
    }
  }

  void _findAnalyzerReferences() {
    var refElement = _getRefElementFromCommentRefs(element, codeRef);
    if (refElement == null) return;

    ModelElement refModelElement;
    if (refElement is MultiplyDefinedElement) {
      var elementNames = refElement.conflictingElements
          .map((e) => "'${_fullyQualifiedElementName(e)}'");
      element.warn(PackageWarning.ambiguousDocReference,
          message: '[$codeRef] => [${elementNames.join(', ')}]');
      refModelElement = ModelElement.fromElement(
          // Continue; just use the first conflicting element.
          refElement.conflictingElements.first,
          element.packageGraph);
    } else {
      refModelElement =
          ModelElement.fromElement(refElement, element.packageGraph);
    }
    if (refModelElement is Accessor) {
      refModelElement = (refModelElement as Accessor).enclosingCombo;
    }
    refModelElement = refModelElement.canonicalModelElement ?? refModelElement;
    results.add(refModelElement);
  }

  /// Generates a fully-qualified name, similar to that of
  /// [ModelElement.fullyQualifiedName], for an Element.
  static String _fullyQualifiedElementName(Element element) {
    var enclosingElement = element.enclosingElement;

    var enclosingName = enclosingElement == null
        ? null
        : _fullyQualifiedElementName(enclosingElement);
    var name = element.name;
    if (name == null) {
      if (element is ExtensionElement) {
        name = '<unnamed extension>';
      } else if (element is LibraryElement) {
        name = '<unnamed library>';
      } else if (element is CompilationUnitElement) {
        return enclosingName;
      } else {
        name = '<unnamed ${element.runtimeType}>';
      }
    }

    return enclosingName == null ? name : '$enclosingName.$name';
  }

  // Add a result, but make it canonical.
  void _addCanonicalResult(ModelElement modelElement) {
    results.add(modelElement.canonicalModelElement);
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
          .modelElement);
    } else {
      // People like to use 'this' in docrefs too.
      if (codeRef == 'this') {
        _addCanonicalResult(tryClass);
      } else {
        // TODO(jcollins-g): get rid of reimplementation of identifier resolution
        //                   or integrate into ModelElement in a simpler way.
        var superChain = <Class>[tryClass];
        superChain.addAll(tryClass.interfaces.map((t) => t.modelElement));
        // This seems duplicitous with our caller, but the preferredClass
        // hint matters with findCanonicalModelElementFor.
        // TODO(jcollins-g): This makes our caller ~O(n^2) vs length of superChain.
        //                   Fortunately superChains are short, but optimize this if it matters.
        superChain.addAll(tryClass.superChain.map((t) => t.modelElement));
        for (final c in superChain) {
          _getResultsForSuperChainElement(c);
          if (results.isNotEmpty) break;
        }
      }
    }
  }

  /// Get any possible results for this class in the superChain.   Returns
  /// true if we found something.
  void _getResultsForSuperChainElement(Class c) {
    var membersToCheck = (c.allModelElementsByNamePart[codeRefChomped] ?? [])
        .map(_convertConstructors);
    for (var modelElement in membersToCheck) {
      // [thing], a member of this class
      _addCanonicalResult(modelElement);
    }
    if (codeRefChompedParts.length < 2 ||
        codeRefChompedParts[codeRefChompedParts.length - 2] == c.name) {
      membersToCheck =
          (c.allModelElementsByNamePart[codeRefChompedParts.last] ??
                  <ModelElement>[])
              .map(_convertConstructors);
      membersToCheck.forEach((m) => _addCanonicalResult(m));
    }
    results.remove(null);
    if (results.isNotEmpty) return;
    if (c.fullyQualifiedNameWithoutLibrary == codeRefChomped) {
      results.add(c);
    }
  }
}

const _referenceLookupWarnings = {
  PackageWarning.referenceLookupDiffersWithNew,
  PackageWarning.referenceLookupFoundWithNew,
  PackageWarning.referenceLookupMissingWithNew,
};

md.Node _makeLinkNode(String codeRef, Warnable warnable) {
  var result = getMatchingLinkElement(warnable, codeRef);
  var textContent = htmlEscape.convert(codeRef);
  var linkedElement = result.commentReferable;
  if (linkedElement != null) {
    if (linkedElement.href != null) {
      var anchor = md.Element.text('a', textContent);
      if (linkedElement is ModelElement && linkedElement.isDeprecated) {
        anchor.attributes['class'] = 'deprecated';
      }
      anchor.attributes['href'] = linkedElement.href;
      return anchor;
    }
    // else this would be linkedElement.linkedName, but link bodies are slightly
    // different for doc references, so fall out.
  } else {
    if (result.warn) {
      // Avoid claiming documentation is inherited when it comes from the
      // current element.
      warnable.warn(PackageWarning.unresolvedDocReference,
          message: codeRef,
          referredFrom: warnable.documentationIsLocal
              ? null
              : warnable.documentationFrom);
    }
  }

  return md.Element.text('code', textContent);
}

@visibleForTesting
MatchingLinkResult getMatchingLinkElement(Warnable warnable, String codeRef,
    {bool enhancedReferenceLookup}) {
  enhancedReferenceLookup ??= warnable.config.enhancedReferenceLookup;
  MatchingLinkResult result, resultOld, resultNew;
  // Do a comparison between result types only if the warnings for them are
  // enabled, because there's a significant performance penalty.
  var doComparison = warnable.config.packageWarningOptions.warningModes.entries
      .where((entry) => _referenceLookupWarnings.contains(entry.key))
      .any((entry) => entry.value != PackageWarningMode.ignore);
  if (doComparison) {
    resultNew = _getMatchingLinkElementCommentReferable(codeRef, warnable);
    resultOld = _getMatchingLinkElementLegacy(codeRef, warnable);
    if (resultNew.commentReferable != null) {
      markdownStats.resolvedNewLookupReferences++;
    }
    result = enhancedReferenceLookup ? resultNew : resultOld;
    if (resultOld.commentReferable != null) {
      markdownStats.resolvedOldLookupReferences++;
    }
  } else {
    if (enhancedReferenceLookup) {
      result = _getMatchingLinkElementCommentReferable(codeRef, warnable);
    } else {
      result = _getMatchingLinkElementLegacy(codeRef, warnable);
    }
  }
  if (doComparison) {
    if (resultOld.isEquivalentTo(resultNew)) {
      markdownStats.resolvedEquivalentlyReferences++;
    } else {
      if (resultNew.commentReferable == null &&
          resultOld.commentReferable != null) {
        warnable.warn(PackageWarning.referenceLookupMissingWithNew,
            message: '[$codeRef] => ' + resultOld.toString(),
            referredFrom: warnable.documentationFrom);
      } else if (resultNew.commentReferable != null &&
          resultOld.commentReferable == null) {
        warnable.warn(PackageWarning.referenceLookupFoundWithNew,
            message: '[$codeRef] => ' + resultNew.toString(),
            referredFrom: warnable.documentationFrom);
      } else {
        warnable.warn(PackageWarning.referenceLookupDiffersWithNew,
            message:
                '[$codeRef] => new: ${resultNew.toString()} old: ${resultOld.toString()}',
            referredFrom: warnable.documentationFrom);
      }
    }
  }
  markdownStats.totalReferences++;
  if (result.commentReferable != null) markdownStats.resolvedReferences++;
  return result;
}

// Maximum number of characters to display before a suspected generic.
const maxPriorContext = 20;
// Maximum number of characters to display after the beginning of a suspected generic.
const maxPostContext = 30;

final RegExp allBeforeFirstNewline = RegExp(r'^.*\n', multiLine: true);
final RegExp allAfterLastNewline = RegExp(r'\n.*$', multiLine: true);

// Generics should be wrapped into `[]` blocks, to avoid handling them as HTML tags
// (like, [Apple<int>]). @Hixie asked for a warning when there's something, that looks
// like a non HTML tag (a generic?) outside of a `[]` block.
// https://github.com/dart-lang/dartdoc/issues/1250#issuecomment-269257942
void showWarningsForGenericsOutsideSquareBracketsBlocks(
    String text, Warnable element) {
  // Skip this if not warned for performance and for dart-lang/sdk#46419.
  if (element.config.packageWarningOptions
          .warningModes[PackageWarning.typeAsHtml] !=
      PackageWarningMode.ignore) {
    for (var position in findFreeHangingGenericsPositions(text)) {
      var priorContext =
          '${text.substring(max(position - maxPriorContext, 0), position)}';
      var postContext =
          '${text.substring(position, min(position + maxPostContext, text.length))}';
      priorContext = priorContext.replaceAll(allBeforeFirstNewline, '');
      postContext = postContext.replaceAll(allAfterLastNewline, '');
      var errorMessage = '$priorContext$postContext';
      // TODO(jcollins-g):  allow for more specific error location inside comments
      element.warn(PackageWarning.typeAsHtml, message: errorMessage);
    }
  }
}

Iterable<int> findFreeHangingGenericsPositions(String string) sync* {
  var currentPosition = 0;
  var squareBracketsDepth = 0;
  while (true) {
    final nextOpenBracket = string.indexOf('[', currentPosition);
    final nextCloseBracket = string.indexOf(']', currentPosition);
    final nextNonHTMLTag = string.indexOf(nonHTML, currentPosition);
    final nextPositions = [nextOpenBracket, nextCloseBracket, nextNonHTMLTag]
        .where((p) => p != -1);

    if (nextPositions.isEmpty) {
      break;
    }

    currentPosition = nextPositions.reduce(min);
    if (nextOpenBracket == currentPosition) {
      squareBracketsDepth += 1;
    } else if (nextCloseBracket == currentPosition) {
      squareBracketsDepth = max(squareBracketsDepth - 1, 0);
    } else if (nextNonHTMLTag == currentPosition) {
      if (squareBracketsDepth == 0) {
        yield currentPosition;
      }
    }
    currentPosition++;
  }
}

class MarkdownDocument extends md.Document {
  factory MarkdownDocument.withElementLinkResolver(Canonicalization element) {
    md.Node /*?*/ linkResolver(String name, [String /*?*/ _]) {
      if (name.isEmpty) {
        return null;
      }
      return _makeLinkNode(name, element);
    }

    return MarkdownDocument(
        inlineSyntaxes: _markdownSyntaxes,
        blockSyntaxes: _markdownBlockSyntaxes,
        linkResolver: linkResolver);
  }

  MarkdownDocument(
      {Iterable<md.BlockSyntax> blockSyntaxes,
      Iterable<md.InlineSyntax> inlineSyntaxes,
      md.ExtensionSet extensionSet,
      md.Resolver linkResolver,
      md.Resolver imageLinkResolver})
      : super(
            blockSyntaxes: blockSyntaxes,
            inlineSyntaxes: inlineSyntaxes,
            extensionSet: extensionSet,
            linkResolver: linkResolver,
            imageLinkResolver: imageLinkResolver);

  /// Parses markdown text, collecting the first [md.Node] or all of them
  /// if [processFullText] is `true`. If more than one node is present,
  /// then [DocumentationParseResult.hasExtendedDocs] will be set to `true`.
  DocumentationParseResult parseMarkdownText(
      String text, bool processFullText) {
    var hasExtendedContent = false;
    var lines = LineSplitter.split(text).toList();
    md.Node firstNode;
    var nodes = <md.Node>[];
    for (var node in IterableBlockParser(lines, this).parseLinesGenerator()) {
      if (firstNode != null) {
        hasExtendedContent = true;
        if (!processFullText) break;
      }
      firstNode ??= node;
      nodes.add(node);
    }
    _parseInlineContent(nodes);
    return DocumentationParseResult(nodes, hasExtendedContent);
  }

  // From package:markdown/src/document.dart
  // TODO(jcollins-g): consider making this a public method in markdown package
  void _parseInlineContent(List<md.Node> nodes) {
    for (var i = 0; i < nodes.length; i++) {
      var node = nodes[i];
      if (node is md.UnparsedContent) {
        var inlineNodes = md.InlineParser(node.textContent, this).parse();
        nodes.removeAt(i);
        nodes.insertAll(i, inlineNodes);
        i += inlineNodes.length - 1;
      } else if (node is md.Element && node.children != null) {
        _parseInlineContent(node.children);
      }
    }
  }
}

class DocumentationParseResult {
  static const empty = DocumentationParseResult([], false);

  final List<md.Node> nodes;
  final bool hasExtendedDocs;

  const DocumentationParseResult(this.nodes, this.hasExtendedDocs);
}

class _InlineCodeSyntax extends md.InlineSyntax {
  _InlineCodeSyntax() : super(r'\[:\s?((?:.|\n)*?)\s?:\]');

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var element = md.Element.text('code', htmlEscape.convert(match[1] /*!*/));
    parser.addNode(element);
    return true;
  }
}

class _AutolinkWithoutScheme extends md.AutolinkSyntax {
  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var url = match[1] /*!*/;
    var text = htmlEscape.convert(url).replaceFirst(_hideSchemes, '');
    var anchor = md.Element.text('a', text);
    anchor.attributes['href'] = url;
    parser.addNode(anchor);

    return true;
  }
}
