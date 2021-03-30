// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';

import 'package:analyzer/file_system/file_system.dart';
import 'package:meta/meta.dart';
import 'parser.dart';

/// The signature of a partial resolver function.
typedef PartialResolver = Future<File> Function(String uri);

/// The signature of a generated render function.
typedef RenderFunction<T> = String Function(T context, Template template);

/// A parsed Mustache template.
///
/// This container includes Templates for all partials parsed in the template
/// file.
class Template {
  /// The parsed Mustache syntax tree.
  final List<MustachioNode> ast;

  /// A mapping of partial keys to partial [File]s.
  ///
  /// This may appear redundant with [partialTemplates], the mapping of partial
  /// files to partial templates. The reason for two mappings is that
  /// [partialTemplates] functions as a cache, so that each [File] containing a
  /// partial template is only parsed once, and also so that partial templates
  /// can reference themselves, or otherwise recurse. The cache is passed down
  /// from template to partial. Mapping a partial key to a partial [File],
  /// however, cannot be shared between templates and partials because they
  /// typically contain relative file paths. Each partial file path is given
  /// relative to the template or partial making the reference.
  // TODO(srawlins): Resolving partials from the Parser rather than
  // [Template.parse] would allow the [File] to be stored on the [Partial] node,
  // removing the need for this mapping.
  final Map<String, File> partials;

  /// A mapping of partial [File]s to parsed Mustache templates.
  final Map<File, Template> partialTemplates;

  Template._(
      {@required this.ast,
      @required this.partials,
      @required this.partialTemplates});

  /// Parses [file] as a Mustache template, returning a [Template].
  ///
  /// A [partialResolver] can be passed if custom partial resolution is required
  /// (for example, to load any partial from a single directory, and to append a
  /// particular suffix).
  ///
  /// By default, a partial key is resolved as a file path which is either
  /// absolute, or relative to the directory containing the template which
  /// references the partial.
  ///
  /// For example, if the Mustache template at `/foo/template.html` includes a
  /// Partial node, `{{>partials/p1.html}}`, then the partial file path is
  /// resolved as `/foo/partials/p1.html`. If this template includes a Partial
  /// node, `{{>p2.html}}`, then this partial file path is resolved (relative to
  /// the directory containing `p1.html`, not relative to the top-level
  /// template), as `/foo/partials/p2.html`.
  static Future<Template> parse(File file,
      {PartialResolver partialResolver,
      @internal Map<File, Template> partialTemplates}) async {
    partialTemplates ??= <File, Template>{};
    if (partialResolver == null) {
      var pathContext = file.provider.pathContext;
      // By default, resolve partials as absolute file paths, or as relative
      // file paths, relative to the template directory from which they are
      // referenced.
      partialResolver = (String path) async {
        var partialPath = pathContext.isAbsolute(path)
            ? path
            : pathContext.join(file.parent2.path, path);
        var partialFile =
            file.provider.getFile(pathContext.normalize(partialPath));
        return partialFile;
      };
    }

    // If we fail to read [file], and an exception is thrown, one of two
    // things happen:
    // 1) In the case of a reference from a partial, the exception is caught
    //    below, when parsing partials, and rethrown with information about the
    //    template with the reference.
    // 2) In the case of a reference from a top-level template, user code has
    //    called [Template.parse], and the user is responsible for handling the
    //    exception.
    var ast = MustachioParser(file.readAsStringSync(), file.toUri()).parse();
    var nodeQueue = Queue.of(ast);
    var partials = <String, File>{};

    // Walk the Mustache syntax tree, looking for Partial nodes.
    while (nodeQueue.isNotEmpty) {
      var node = nodeQueue.removeFirst();
      if (node is Text) {
        // Nothing to do.
      } else if (node is Variable) {
        // Nothing to do.
      } else if (node is Section) {
        nodeQueue.addAll(node.children);
      } else if (node is Partial) {
        var key = node.key;
        if (!partials.containsKey(key)) {
          partials[key] = await partialResolver(key);
        }
        var partialFile = partials[key];
        if (!partialTemplates.containsKey(partialFile)) {
          try {
            var partialTemplate = await Template.parse(partialFile,
                partialResolver: partialResolver,
                partialTemplates: {...partialTemplates});
            partialTemplates[partialFile] = partialTemplate;
          } on FileSystemException catch (e) {
            throw MustachioResolutionError(node.span.message(
                'FileSystemException (${e.message}) when reading partial:'));
          }
        }
      }
    }

    return Template._(
        ast: ast, partials: partials, partialTemplates: partialTemplates);
  }
}

/// The base class for a generated Mustache renderer.
abstract class RendererBase<T> {
  /// The context object which this renderer can render.
  final T context;

  /// The renderer of the parent context, if any, otherwise `null`.
  final RendererBase parent;

  /// The current template being rendered.
  ///
  /// When rendering a partial, the [context] object, and hence the
  /// [RendererBase] does not change, only this current template.
  Template _template;

  /// The output buffer into which [context] is rendered, using a template.
  final buffer = StringBuffer();

  RendererBase(this.context, this.parent, this._template);

  Template get template => _template;

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
  String getFields(Variable node) {
    var names = node.key;
    if (names.length == 1 && names.single == '.') {
      return context.toString();
    }
    var property = getProperty(names.first);
    if (property != null) {
      var remainingNames = [...names.skip(1)];
      try {
        return property.renderVariable(context, property, remainingNames);
      } on PartialMustachioResolutionError catch (e) {
        // The error thrown by [Property.renderVariable] does not have all of
        // the names required for a decent error. We throw a new error here.
        throw MustachioResolutionError(node.keySpan.message(
            "Failed to resolve '${e.name}' on ${e.contextType} while resolving "
            '$remainingNames as a property chain on any types in the context '
            "chain: $contextChainString, after first resolving '${names.first}' "
            'to a property on $T'));
      }
    } else if (parent != null) {
      return parent.getFields(node);
    } else {
      throw MustachioResolutionError(node.keySpan.message(
          "Failed to resolve '${names.first}' as a property on any types in the "
          'context chain: $contextChainString'));
    }
  }

  /// Renders a block of Mustache template, the [ast], into [buffer].
  void renderBlock(List<MustachioNode> ast) {
    for (var node in ast) {
      if (node is Text) {
        write(node.content);
      } else if (node is Variable) {
        var content = getFields(node);
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
        throw MustachioResolutionError(node.keySpan.message(
            "Failed to resolve '$key' as a property on any types in the "
            'current context'));
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
      var renderedIterable =
          property.renderIterable(context, this, node.children);
      if (node.invert && renderedIterable.isEmpty) {
        // An inverted section is rendered with the current context.
        renderBlock(node.children);
      } else if (!node.invert && renderedIterable.isNotEmpty) {
        var buffer = StringBuffer()..writeAll(renderedIterable);
        write(buffer.toString());
      }
      // Otherwise, render nothing.

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
    var key = node.key;
    var partialFile = template.partials[key];
    var partialTemplate = template.partialTemplates[partialFile];
    var outerTemplate = _template;
    _template = partialTemplate;
    renderBlock(partialTemplate.ast);
    _template = outerTemplate;
  }
}

String renderSimple(Object context, List<MustachioNode> ast, Template template,
    {RendererBase parent}) {
  var renderer = SimpleRenderer(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}

class SimpleRenderer extends RendererBase<Object> {
  SimpleRenderer(Object context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<Object> getProperty(String key) => null;

  @override
  String getFields(Variable node) {
    var names = node.key;
    if (names.length == 1 && names.single == '.') {
      return context.toString();
    }
    if (parent != null) {
      return parent.getFields(node);
    } else {
      return 'null';
    }
  }
}

/// An individual property of objects of type [T], including functions for
/// rendering various types of Mustache nodes.
@immutable
class Property<T> {
  /// Gets the value of this property on the object [context].
  final Object /*?*/ Function(T context) /*!*/ getValue;

  final String /*!*/ Function(
      T, Property<T>, List<String> /*!*/) /*?*/ renderVariable;

  /// Gets the bool value (true or false, never null) of this property on the
  /// object [context].
  final bool /*!*/ Function(T context) /*?*/ getBool;

  final Iterable<String> /*!*/ Function(
          T, RendererBase<T>, List<MustachioNode> /*!*/) /*?*/
      renderIterable;

  final bool /*!*/ Function(T) /*?*/ isNullValue;

  final String /*!*/ Function(
      T, RendererBase<T>, List<MustachioNode> /*!*/) /*?*/ renderValue;

  Property(
      {@required this.getValue,
      this.renderVariable,
      this.getBool,
      this.renderIterable,
      this.isNullValue,
      this.renderValue});

  String /*!*/ renderSimpleVariable(
      T c, List<String> /*!*/ remainingNames, String /*!*/ typeString) {
    if (remainingNames.isEmpty) {
      return getValue(c).toString();
    } else {
      throw MustachioResolutionError(
          _simpleResolveErrorMessage(remainingNames, typeString));
    }
  }

  static String _simpleResolveErrorMessage(List<String> key, String type) =>
      'Failed to resolve $key property chain on $type using a simple renderer; '
      'expose the properties of $type by adding it to the @Renderer '
      "annotation's 'visibleTypes' list";
}

/// An error indicating that a renderer failed to resolve a key.
class MustachioResolutionError extends Error {
  final String message;

  MustachioResolutionError([this.message]);

  @override
  String toString() => 'MustachioResolutionError: $message';
}

/// An error indicating that a renderer failed to resolve a follow-on name in a
/// multi-name key.
class PartialMustachioResolutionError extends Error {
  final String name;

  final Type contextType;

  PartialMustachioResolutionError(this.name, this.contextType);
}

extension MapExtensions<T> on Map<String, Property<T>> {
  Property<T> getValue(String name) {
    if (containsKey(name)) {
      return this[name];
    } else {
      throw PartialMustachioResolutionError(name, T);
    }
  }
}
