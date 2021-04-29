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

Mustachio's first set of generated renderers render objects into
runtime-interpreted Mustache template blocks. Each template block may be the
content of a Mustache template file, a Mustache partial file, or a Mustache
section. The design for a tool which can generate such a renderer is included
after the design for the renderer.

The mechanics of the tool which generates these renderers is a separate concern
from the mechanics of the renderers themselves. This section is primarily
concerned with documenting how the renderers work. At the end, a higher level
description of the code generator can be found.

### Example types

Any examples in this section will use the following types:

```dart
abstract class User {
  String get name;
  UserProfile get profile;
  List<Post>? get posts;
}

abstract class UserProfile {
  String get avatarUrl;
  String get biography;
}

abstract class Post {
  String get title;
  String get content;
  bool? get isPublished;
}
```

A User object can be rendered into the following Mustache template:

```dart
<h1>{{ name }}</h1>
{{ #profile }}
  <img src=”{{ avatarUrl }}” />
  <p>{{ biography }}</p>
{{ /profile }}
{{ #posts }}
  {{ #isPublished }}
    <div>
      <h2>{{ title }}</h2>
      <p>{{ content }}</h2>
    </div>
  {{ /isPublished }}
{{ /posts }}
```

### Renderer outline

In order to support repeated sections and value sections, a renderer for a type
_T_ requires renderers for other types:

* If _T_ has a getter of type _S_, then a renderer for type _T_ may be called
  upon to render a [value section][] for that getter, which requires a renderer
  for type _S_.
* If _T_ has a getter of type _Iterable&lt;S>_ for some type _S_, then a
  renderer for type _T_ may be called upon to render a repeated section for that
  getter, which requires a renderer for type _S_.

An instance of a renderer needs four things in order to render an object using a
Mustache syntax tree (a _template block_):

* the context object,
* the Mustache template block (a list of nodes),
* the path to the directory in which the Mustache template is located, in order
  to locate partials,
* optionally, a parent renderer

Additionally, a renderer needs various functions in order to render each getter
for the renderer's context type. It may need to render each getter (1) as a
variable, (2) possibly as a conditional section, (3) possibly as a repeated
section, and (4) possibly as a value section).

Here are all of the elements of such a renderer for the User class:

```dart
class Renderer_User extends RendererBase<User> {
  static final Map<String, Property<CT_>> propertyMap<CT_ extends User>() => ...;

  Renderer_User(User context, RendererBase<Object> parent, Template template)
      : super(context, parent, template);

  @override
  Property<User> getProperty(String key) {
    if (propertyMap<User>().containsKey(key)) {
      return propertyMap<User>()[key];
    } else {
      return null;
    }
  }
}
```

* The base class, **RendererBase**, provides functionality common to all
  renderers, for example a buffer to which output may be written; each of the
  methods discussed in [Rendering a block][] below.
* The map of properties forms the bulk of each individual renderer. The Property
  class is described just below.
* The renderer instance may be asked to render multiple blocks; while rendering
  a list of nodes, the children of certain nodes are rendered without changing
  context, and so can use the same renderer. In particular:
  * when rendering a conditional section,
  * when rendering an inverted repeated section or inverted value section,
  * when rendering a partial.

#### Map of properties

The core functionality of accessing getters on an object by name (as a String)
is a static map of properties for each type which may be used as a context
object during the rendering process. Each getter names is mapped to a Property
object which holds functions that allow performing certain rendering actions
using the given property.

The property map is actually a function because it needs to be type
parameterized on `CT_`, a type variable bounded to the type of the context
object. This is an unfortunate complication which arises from the design of
Property being a collection of functions. Since a renderer can be used to
render _subtypes_ of the context type, we cannot type all of the functions in
the Properties with the context type; they must each be typed with the runtime
type of the context object.

Here is the Property interface:

```dart
class Property<T> {
  final Object Function(T context) getValue;
  final String Function(T, Property<T>, List<String>) renderVariable;
  final bool Function(T context) getBool;
  final Iterable<String> Function(T, RendererBase<T>, List<MustachioNode>)
      renderIterable;
  final bool Function(T) isNullValue;
  final String Function(T, RendererBase<T>, List<MustachioNode>) renderValue;
}
```

For each valid getter on a type, the renderer will map out a Property object
with non-`null` values for the appropriate functions, and `null` values for
inappropriate functions.

##### The `getValue` function

For every valid getter, the Property object will contain a function named
`getValue` which calls the getter and returns the result. This function is used
to render a property in a [variable node][]. For example, the Property for
`name` on the User renderer has the following `getValue` function:

```dart
(CT_ c) => c.name
```

##### The `renderVariable` function

TODO(srawlins): Write.

##### The `getBool` function

For every valid getter with a `bool?` or `bool` return type, the Property object
contains a function named `getBool` which returns the non-`null` `bool` value of
the getter (`null` is converted to `false`). This function is used to render a
property in a conditional section node (or an inverted one). For example, the
Property for `isPublished` on the Post renderer has the following `getBool`
function:

```dart
(CT_ c) => c.isPublished == true
```

##### The `renderIterable` function

For every valid getter with a return type assignable to `Iterable<Object?>?`,
the Property object contains a function named `renderIterable` which requires
some parameters: the context object, the current renderer, and the AST to
render. This function is used to render a property in a repeated section node
(or an inverted one). For example, the Property for `posts` on the User renderer
has the following `renderIterable` function:

```dart
(CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
  return c.posts.map(
      (e) => _render_Post(e, ast, r.template, parent: r));
}
```

This function needs the three arguments so that it can iterate over the `posts`
of the context object, and then create new instances of the Post renderer, which
requires the AST to render, and the parent context.

##### The `isNullValue` and `renderValue` functions

For each valid getter which has neither a `bool` return type nor an `Iterable`
return type, the Property object contains a function named `isNullValue` which
returns whether the value of the getter is `null` or not. It also contains a
function named `renderValue` which requires more parameters: the context object,
the current renderer, and the AST to render. These functions are used to render
a property in a value section node (or an inverted one). For example, the
Property for `profile` on the User renderer has the following `isNullValue`
function:

```dart
(CT_ c) => c.profile == null
```

and `renderValue` function:

```dart
(CT_ c, RendererBase<CT_> r, List<MustachioNode> ast) {
  return _render_UserProfile(c.profile, ast, r.template, parent: r);
}
```

The `renderValue` function needs the three arguments so that it can render the
property value using a new `UserProfile` renderer, which requires the AST to
render, and the parent context.

#### Rendering a block

TODO(srawlins): Write.

#### Resolving a variable key

TODO(srawlins): Write.

#### Rendering a section

TODO(srawlins): Write.

##### Conditional section

##### Repeated section

##### Value section

#### Rendering a partial

TODO(srawlins): Write.

[value section]: https://mustache.github.io/mustache.5.html#Sections
[Rendering a block]: #rendering-a-block
[variable node]: https://mustache.github.io/mustache.5.html#Variables

### High level design for generating renderers

TODO(srawlins): Write.

## Generated renderer for a specific type and a static template which pre-compiles the templates

TODO(srawlins): Write.