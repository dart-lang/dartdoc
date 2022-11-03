// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// See the Mustachio README at tool/mustachio/README.md for high-level
// documentation.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:meta/meta.dart';

/// Specifies information for generating both a runtime-interpreted Mustache
/// renderer and a pre-compiled Mustache renderer for a [context] object, using
/// a Mustache template located at [standardHtmlTemplate] and at
/// [standardMdTemplate], for an HTML template, and for a Markdown template,
/// respectively.
// Update `test/builder_test_base.dart` when updating this.
class Renderer {
  /// The name of the render function to generate.
  final Symbol name;

  /// The type of the context type, specified as the [Context] type argument.
  final Context<Object> context;

  /// The unparsed, string form of the URI of the _standard_ HTML template.
  ///
  /// This represents the Mustache template that dartdoc uses out-of-the-box to
  /// render the [context] object while generating documentation in HTML.
  final String standardHtmlTemplate;

  /// The unparsed, string form of the URI of the _standard_ Markdown template.
  ///
  /// This represents the Mustache template that dartdoc uses out-of-the-box to
  /// render the [context] object while generating documentation in Markdown.
  final String standardMdTemplate;

  /// A set of types which are "visible" to the Mustache runtime interpreter.
  /// Mustache runtime-rendering has access to all of a type's public getters if
  /// the type is visible to Mustache.
  ///
  /// Note that all subtypes and supertypes of a "visible" type are also visible
  /// to Mustache.
  final Set<Type> visibleTypes;

  /// Returns a Renderer with the specified renderer function [name] which can
  /// render [context] objects.
  ///
  /// [standardTemplateBasename] is used as a basename in an
  /// Asset URL, in both [standardHtmlTemplate] and [standardMdTemplate],
  /// in order to render with the out-of-the-box Mustache templates.
  const Renderer(
    this.name,
    this.context,
    String standardTemplateBasename, {
    this.visibleTypes = const {},
  })  : standardHtmlTemplate =
            'package:dartdoc/templates/html/$standardTemplateBasename.html',
        standardMdTemplate =
            'package:dartdoc/templates/md/$standardTemplateBasename.md';

  @visibleForTesting
  const Renderer.forTest(
    this.name,
    this.context,
    String standardTemplateBasename, {
    this.visibleTypes = const {},
  })  : standardHtmlTemplate = 'templates/$standardTemplateBasename.html',
        standardMdTemplate = 'templates/$standardTemplateBasename.md';
}

/// A container for a type, [T], which is the type of a context object,
/// referenced in a `@Renderer` annotation.
///
/// An instance of this class holds zero information, except for [T], a type.
// Update `test/builder_test_base.dart` when updating this.
class Context<T> {
  const Context();
}

/// The specification of a renderer, as derived from a @Renderer annotation.
///
/// This is only meant to be used by dartdoc's builders.
@internal
class RendererSpec {
  /// The name of the render function.
  final String name;

  final InterfaceType contextType;

  // TODO(srawlins): I think this should be `Set<InterfaceType>`.
  final Set<DartType> visibleTypes;

  final String standardHtmlTemplate;

  final String standardMdTemplate;

  final Map<TemplateFormat, Uri?> standardTemplateUris;

  RendererSpec(
    this.name,
    this.contextType,
    this.visibleTypes,
    this.standardHtmlTemplate,
    this.standardMdTemplate,
  ) : standardTemplateUris = {
          TemplateFormat.html: _parseUriFromAnnotation(standardHtmlTemplate),
          TemplateFormat.md: _parseUriFromAnnotation(standardMdTemplate),
        };

  /// Parses a URI from a String which comes from a const annotation object.
  ///
  /// The String value may be the literal value, 'null'.
  static Uri? _parseUriFromAnnotation(String unparsed) =>
      unparsed == 'null' ? null : Uri.parse(unparsed);

  InterfaceElement get contextElement => contextType.element;
}

enum TemplateFormat {
  html,
  md,
}
