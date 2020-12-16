// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:meta/meta.dart';
import 'parser.dart';

/// The base class for a generated Mustache renderer.
abstract class RendererBase<T> {
  /// The context object which this renderer can render.
  final T context;

  /// The renderer of the parent context, if any, otherwise `null`.
  final RendererBase parent;

  /// The output buffer into which [context] is rendered, using a template.
  final buffer = StringBuffer();

  RendererBase(this.context, this.parent);

  void write(String text) => buffer.write(text);

  String get contextChainString =>
      parent == null ? '$T' : '${parent.contextChainString} > $T';

  /// Returns the [Property] on this renderer named [name].
  ///
  /// If no property named [name] exists for this renderer, `null` is returned.
  Property<T> getProperty(String key);

  /// Resolves [names] into one or more field accesses, returning the result as
  /// a String.
  ///
  /// [names] may have multiple dot-separate names, and [names] may not be a
  /// valid property of _this_ context type, in which the [parent] renderer is
  /// referenced.
  String getFields(List<String> names) {
    if (names.length == 1 && names.single == '.') {
      return context.toString();
    }
    var property = getProperty(names.first);
    if (property != null) {
      try {
        return property.renderVariable(context, property, [...names.skip(1)]);
      } on PartialMustachioResolutionError catch (e) {
        // The error thrown by [Property.renderVariable] does not have all of
        // the names required for a decent error. We throw a new error here.
        throw MustachioResolutionError(
            "Failed to resolve '${e.name}' on ${e.contextType} while resolving "
            '${names.skip(1)} as a property chain on any types in the context '
            "chain: $contextChainString, after first resolving '${names.first}'"
            'to a property on $T');
      }
    } else if (parent != null) {
      return parent.getFields(names);
    } else {
      throw MustachioResolutionError(
          'Failed to resolve ${names.first} as a property on any types in the '
          'context chain: $contextChainString');
    }
  }

  /// Renders a block of Mustache template, the [ast], into [buffer].
  void renderBlock(List<MustachioNode> ast) {
    for (var node in ast) {
      if (node is Text) {
        write(node.content);
      } else if (node is Variable) {
        var content = getFields(node.key);
        write(content);
      } else if (node is Section) {
        section(node);
      } else if (node is Partial) {
        partial(node);
      }
    }
  }

  void section(Section node) {
    var key = node.key.first;
    var property = getProperty(key);
    if (property == null) {
      if (parent == null) {
        throw MustachioResolutionError(
            'Failed to resolve $key as a property on any types in the current '
            'context');
      } else {
        return parent.section(node);
      }
    }

    if (property.getBool != null) {
      var boolResult = property.getBool(context);
      if ((boolResult && !node.invert) || (!boolResult && node.invert)) {
        renderBlock(node.children);
      }
      return;
    }

    if (property.renderIterable != null) {
      // An inverted section is rendered with the current context.
      if (node.invert && property.isEmptyIterable(context)) {
        renderBlock(node.children);
      }
      if (!node.invert && !property.isEmptyIterable(context)) {
        write(property.renderIterable(context, this, node.children));
      }
      return;
    }

    // If this section is not a conditional or repeated section, it is a value
    // section, regardless of type.
    if (node.invert && property.isNullValue(context)) {
      renderBlock(node.children);
    } else if (!node.invert && !property.isNullValue(context)) {
      write(property.renderValue(context, this, node.children));
    }
  }

  void partial(Partial node) {
    // TODO(srawlins): Implement.
  }
}

String renderSimple(Object context, List<MustachioNode> ast,
    {RendererBase parent}) {
  var renderer = SimpleRenderer(context, parent);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class SimpleRenderer extends RendererBase<Object> {
  SimpleRenderer(Object context, RendererBase<Object> parent)
      : super(context, parent);

  @override
  Property<Object> getProperty(String key) => null;

  @override
  String getFields(List<String> keyParts) {
    if (keyParts.length == 1 && keyParts.single == '.') {
      return context.toString();
    }
    if (parent != null) {
      return parent.getFields(keyParts);
    } else {
      return 'null';
    }
  }
}

/// An individual property of objects of type [T], including functions for
/// rendering various types of Mustache nodes.
class Property<T> {
  /// Gets the value of this property on the object [context].
  final Object /*?*/ Function(T context) /*!*/ getValue;

  final String /*!*/ Function(
      T, Property<T>, List<String> /*!*/) /*?*/ renderVariable;

  /// Gets the bool value (true or false, never null) of this property on the
  /// object [context].
  final bool /*!*/ Function(T context) /*?*/ getBool;

  final bool /*!*/ Function(T) /*?*/ isEmptyIterable;

  final String /*!*/ Function(
          T, RendererBase<T>, List<MustachioNode> /*!*/) /*?*/
      renderIterable;

  final bool /*!*/ Function(T) /*?*/ isNullValue;

  final String /*!*/ Function(
      T, RendererBase<T>, List<MustachioNode> /*!*/) /*?*/ renderValue;

  Property(
      {@required this.getValue,
      this.renderVariable,
      this.getBool,
      this.isEmptyIterable,
      this.renderIterable,
      this.isNullValue,
      this.renderValue});
}

/// An error indicating that a renderer failed to resolve a key.
class MustachioResolutionError extends Error {
  String message;

  MustachioResolutionError([this.message]);

  @override
  String toString() => 'MustachioResolutionError: $message';
}

/// An error indicating that a renderer failed to resolve a follow-on name in a
/// multi-name key.
class PartialMustachioResolutionError extends Error {
  String name;

  Type contextType;

  PartialMustachioResolutionError(this.name, this.contextType);
}
