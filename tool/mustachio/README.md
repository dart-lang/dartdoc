# Mustachio

_Mustachio_ is a code generation-based Mustache render system designed with
Dartdoc's needs in mind.

## Mustache background

[Mustache templating][] takes a _context object_ and renders it into a
_template_. For example, an instance of the Library class can be rendered into
the `library.html` template file. Mustache is primarily a templating syntax,
where tags specify how _keys_ on the context object are rendered into the
template. For example, consider the following template:

```mustache
<h1>{{ name }}</h1>
{{ #hasDetails }}
<ul>
  {{ #details }}
  <li>{{ text }}</li>
  {{ /details }}
</ul>
{{ /hasDetails }}
```

Mustache specifies that `{{ name }}` represents a _variable_ tag, where the
value of the context object's `name` property is interpolated into the
template. `{{ #hasDetails }}` and `{{ #details }}` each specify a _section_ tag,
where the template content between `{{ #hasDetails }}` and `{{ /hasDetails }}`
is rendered zero, one, or multiple times, possibly with a new context object,
depending on the value of the context object's `hasDetails` property. The catch
is in how a Dart program can access a property of an object via a
runtime-derived String name.

The two popular Mustache packages for Dart ([mustache][] and [mustache4dart][])
each use [mirrors][], which is slow, and whose future is unknown. The
[mustache_template][] package avoids mirrors by restricting context objects to
just Maps and Lists of values. Neither of these existing solutions were optimal
for Dartdoc. For a time, dartdoc used the mustache package. When dartdoc creates
documentation for a package, the majority of the time is spent generating the
HTML output from package metadata. Benchmarking shows that much time is spent
using mirrors.

[Mustache templating]: https://mustache.github.io/
[mustache]: https://pub.dev/packages/mustache
[mustache4dart]: https://pub.dev/packages/mustache4dart
[mirrors]: https://api.dart.dev/stable/dart-mirrors/dart-mirrors-library.html
[mustache_template]: https://pub.dev/packages/mustache_template

## Motivation

The primary motivation to design a new template rendering solution is to reduce
the time to generate package documentation. In mid-2020, on a current MacBook
Pro, it took 12 minutes to generate the Flutter documentation. A solution which
uses static dispatch instead of mirrors's runtime reflection will be much
faster. A prototype demonstrated that a new system which parses templates
ahead-of-time against known context types could render the Flutter documentation
in 3 minutes.

There are several secondary benefits:

* **Correct static typing** - a solution which uses property access on
  statically typed objects ensures that properties (getters, specifically)
  exist, illuminating typos.
* **Property usage** - a solution which uses normal property access (calling
  getters) on statically typed objects allows analyzers and IDEs to understand
  when a property is referenced within a template. This is required for
  automated refactoring, finding references, finding definition, and “unused”
  static analysis.
* **The possibility to restrict API usage** - currently, any custom template
  which a package author writes can walk the entire UML diagram of dartdoc's
  internals, and any types which can be accessed via public properties from the
  primary ModelElement types. This reaches out to include hundreds of types, and
  tens of thousands of properties. A code-generation solution allows dartdoc to
  declare only a supported, restricted subset.

## Mustache's dynamically typed background

Mustache was originally authored as a templating system to be used in
JavaScript. JavaScript's dynamic typing and use of objects and object properties
lends itself to simple ideas in parsing Mustache. A renderer can request from
any object a property with a String name parsed from a Mustache template
string. JavaScript also has notions of “falsey” and “truthy” which are used in
rendering sections and inverted sections.

This design is a perfect fit for JavaScript. A Mustache renderer for Dart which
accesses properties in "the normal way" (not using mirrors, and not using
dynamic dispatch) requires a non-trivial design. In fact, the two code-generated
renderer designs provided here each require ahead-of-time knowledge of the
complete set of types which may be rendered with Mustache templates. No design
is given for a Mustache renderer which can render arbitrary objects.

## Design overview

### Two rendering methods

When dartdoc generates documentation for a package, it renders context objects
using Mustache templates. For example, an EnumTemplateData instance (for a
specific enum) is rendered using a file, `enum.html`. When generating
documentation for api.dart.dev, pub.dev, and api.flutter.dev, standard, static
templates are used. When generating documentation for Fuchsia, custom templates
are used, which are only known and resolved at runtime.

Two code generation-based rendering methods are designed below. The first
design is for a tool which can generate the code to render objects of specific
types using runtime-interpreted Mustache template blocks. The second design is
for a tool which can generate the code to render objects of specific types using
pre-compiled Mustache template blocks.

**The first tool generates code specific to one set of known types, one renderer
per type.** Each generated renderer accepts an instance of the appropriate type,
and a Mustache template block.

The renderers access properties of objects via normal Dart property access
(without reflection, and without dynamic dispatch), but require complete
mappings from property names to property accessors for each type.

**The second tool generates code specific to one set of known types, and one
set of known templates and partials, one renderer per type-template pair.** Each
generated renderer accepts an instance of the appropriate type. Each template is
pre-encoded into the appropriate renderer, including the parse tree and all key
resolution.

The renderers access properties of objects via normal Dart property access
(without reflection, and without dynamic dispatch).

When using the standard templates to generate documentation, Dartdoc can make
use of the pre-compiled renderers. When using custom templates to generate
documentation, Dartdoc must make use of the renderers which interpret template
blocks at runtime.

## Limitations

Dartdoc's standard templates do not use all features of Mustache. Ergo,
Mustachio does not support all features of Mustache. Namely:

* no support for Lambda tags
* no support for Set Delimiter tags
* no support for resolving Map keys or List indexes

## Parser

The Mustache parser is shared between the two code-generation methods. Parsing
a Mustache template block of text (from a template or a partial) into a syntax
tree, without resolving keys, is a solved problem; Mustachio's [Parser] is not
novel.

The output of this parser is a syntax tree consisting of the following node
types:

* [Text][] node - plain text as it appears in the template
* [Variable][] node - a node containing the variable tag key
* [Section][] node - a node containing the section tag key, whether the section
  tag is inverted, and the syntax tree of the section block
* [Partial][] node - a node containing the partial tag key

[Parser]: https://github.com/dart-lang/dartdoc/blob/master/lib/src/mustachio/parser.dart
[Text]: https://github.com/dart-lang/dartdoc/blob/master/lib/src/mustachio/parser.dart#L422
[Variable]: https://github.com/dart-lang/dartdoc/blob/master/lib/src/mustachio/parser.dart#L436
[Section]: https://github.com/dart-lang/dartdoc/blob/master/lib/src/mustachio/parser.dart#L456
[Partial]: https://github.com/dart-lang/dartdoc/blob/master/lib/src/mustachio/parser.dart#L477

## Generated renderer for a specific type which interprets templates at runtime

TODO(srawlins): Write.

## Generated renderer for a specific type and a static template which pre-compiles the templates

TODO(srawlins): Write.