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
for Dartdoc. For a time, dartdoc used the mustache package. At that time, the
majority of dartdoc's execution time was spent generating the HTML output from
package metadata. Benchmarking showed that much time was spent using mirrors.

[Mustache templating]: https://mustache.github.io/
[mustache]: https://pub.dev/packages/mustache
[mustache4dart]: https://pub.dev/packages/mustache4dart
[mirrors]: https://api.dart.dev/stable/dart-mirrors/dart-mirrors-library.html
[mustache_template]: https://pub.dev/packages/mustache_template

## Motivation

The primary motivation to design a new template rendering solution is to reduce
the time to generate package documentation. A system that uses static dispatch
in lieu of mirror-based dispatch is faster on the Dart VM.

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

[Parser]: https://github.com/dart-lang/dartdoc/blob/main/lib/src/mustachio/parser.dart
[Text]: https://github.com/dart-lang/dartdoc/blob/main/lib/src/mustachio/parser.dart#L422
[Variable]: https://github.com/dart-lang/dartdoc/blob/main/lib/src/mustachio/parser.dart#L436
[Section]: https://github.com/dart-lang/dartdoc/blob/main/lib/src/mustachio/parser.dart#L456
[Partial]: https://github.com/dart-lang/dartdoc/blob/main/lib/src/mustachio/parser.dart#L477

## Generated renderer for a specific type which interprets templates at runtime

Mustachio's first set of generated renderers render objects into
runtime-interpreted Mustache template blocks. Each template block may be the
content of a Mustache template file, a Mustache partial file, or a Mustache
section.

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
  bool get isFeatured;
  List<Post>? get posts;
  Post? featuredPost;
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

### Render function

Each generated renderer is paired with a generated _public render function_,
which is the public interface for rendering objects into Mustache templates,
and _private render function_, which is a convenience function for constructing
a renderer and rendering an AST with it.

```dart
String renderUser(User context, Template template) {
  return _render_User(context, template.ast, template);
}

String _render_User(User context, List<MustachioNode> ast, Template template,
    {RendererBase<Object> parent}) {
  var renderer = _Renderer_User(context, parent, template);
  renderer.renderBlock(ast);
  return renderer.buffer.toString();
}
```

In order to use the public render function, one first needs a Template object.
This is a container for a parsed Mustache template. The `Template.parse`
constructor accepts a file path and an optional partial resolver. It parses the
Mustache template at the given file path, and also reads and parses all partials
referenced in the template. The returned Template object contains a mapping of
all partial keys to partial file paths, and also a mapping of all partial file
paths to partial Template objects. This Template object can be used to render
various context objects, without needing to re-read or re-parse the template
file or any referenced partial files.

The `renderUser` function just requires two arguments, the User object to
render, and the Mustache Template object that it should be rendered into.

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

The RendererBase class defines a very simple `renderBlock` method. This method
iterates over an AST, delegating to other methods depending on the type of each
node:

```dart
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
```

Text is rendered verbatim.

Rendering a variable is mostly a matter of resolving the variable (see below).

Sections and Partials are complex enough to warrant their own methods.

#### Resolving a variable key

Rendering a variable requires _resolution_; the variable's _key_ may consist of
multiple _names_, (e.g. `{{ foo.bar.baz }}` is a variable node with a key of
"foo.bar.baz"; this key has three names: "foo", "bar", and "baz") and resolution
may require context objects further down in the stack. This resolution is
performed in the renderer's `getFields` method.

```dart
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
        throw MustachioResolutionError(...);
      }
    } else if (parent != null) {
      return parent.getFields(node);
    } else {
      throw MustachioResolutionError(...);
    }
  }
```

We can see the entire resolution process here:

* If the key is just ".", then we render the current context object as a String.
* If the first name (which is often the whole key) is found on the context
  object's property map, then we resolve the name as a property on the context
  object.
  * For each remaining name in the key names, we search the resolved object for
    a property with this name. If it is found, we resolve the name as a property
    on the previously resolved object. If it is not found, resolution has
    failed.
* If the first name is not found on the context object, we request that the
  parent renderer resolve the key.
* If there is no parent, resolution has failed.

#### Rendering a section

A section key is not allowed to have multiple names. We first search for a
property on the context object with the key as its name. If we don't find it, we
search the parent context:

```dart
    var key = node.key.first;
    var property = getProperty(key);
    if (property == null) {
      if (parent == null) {
        throw MustachioResolutionError(...);
      } else {
        return parent.section(node);
      }
    }
```

The `getProperty` method returns the Property instance for the specified name,
which has various methods on it which can access the property for various
purposes.

##### Conditional section

First we check if the property can be used in a conditional section:

```dart
    if (property.getBool != null) {
      var boolResult = property.getBool(context);
      if ((boolResult && !node.invert) || (!boolResult && node.invert)) {
        renderBlock(node.children);
      }
      return;
    }
```

If the getter's return type is not `bool?` or `bool`, then `getBool` returns
`null`.

If the getter's return type is `bool?` or `bool`, then `getBool` is a function
which takes the context object as an argument, and returns the non-nullable
`bool` value of the property on the context object (resolving a `null` value as
`false`).

Since a conditional section can be inverted, we have to account for this when
deciding to render the children.

##### Repeated section

If the getter does not result in a conditional section, we check whether it is
iterable:

```dart
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
```

If the getter's return type is not a subtype of `Iterable<Object?>?`, then
`renderIterable` returns `null`.

If the getter's return type is a subtype of `Iterable<Object?>?`, then
`renderIterable`, [detailed here][renderIterable], is a function which returns
the non-nullable String value of the rendered section.

An inverted repeated section is rendered with the current context if the
iterable is `null` or empty.

##### Value section

If the getter does not result in a conditional section, nor a repeated section, we render the section as a value section:

```dart
    if (node.invert && property.isNullValue(context)) {
      renderBlock(node.children);
    } else if (!node.invert && !property.isNullValue(context)) {
      write(property.renderValue(context, this, node.children));
    }
```

An inverted value section is rendered with the current context if the value is
`null`.

The `renderValue` function, [detailed here][renderValue], takes the context
object, the renderer, and the section's children as arguments, and returns the
non-nullable String value of the rendered section.

#### Rendering a partial

A partial key is not resolved as a sequence of names; it is instead a free form
text key which maps to a partial file. Mustachio can either use a built-in
partial resolver, in which case each key is a path which is relative to the
template in which the key is found, or a custom partial resolver which can use
custom logic to map the key to a file path. The keys have been mapped ahead of
time (when the Template was parsed) to paths and the paths have been mapped
ahead of time to Template objects. We map the key to the partial's file path,
and map the partial's file path to the partial's Template:

```dart
  void partial(Partial node) {
    var key = node.key;
    var partialFile = template.partials[key];
    var partialTemplate = template.partialTemplates[partialFile];
    var outerTemplate = _template;
    _template = partialTemplate;
    renderBlock(partialTemplate.ast);
    _template = outerTemplate;
  }
```

To render the partial, we first replace the renderer's template with the
partial's template (for further partial key resolution of any partial tags found
inside this partial) and render the partial with the same renderer, using
`renderBlock`.

[value section]: https://mustache.github.io/mustache.5.html#Sections
[Rendering a block]: #rendering-a-block
[variable node]: https://mustache.github.io/mustache.5.html#Variables
[renderIterable]: #the-renderIterable-function
[renderValue]: #the-renderValue-function

### High level design for generating renderers

TODO(srawlins): Write.

## Generated renderer for a specific type and a pre-compiled static template

Mustachio's second set of generated renderers render objects into
ahead-of-time compiled Mustache template blocks. Each template block may be the
content of a Mustache template file, a Mustache partial file, or a Mustache
section.

The mechanics of the tool which generates these renderers is a separate concern
from the mechanics of the renderers themselves. This section is primarily
concerned with documenting how the renderers work. At the end, a higher level
description of the code generator can be found.

### Annotation

The code generation trigger is a `@Renderer` annotation, which specifies a
render function name, a context type, and a template file. The code generator
parses the specified template file, and uses the context type to resolve all tag
keys at the time of code generation. For example, given the following template:

```html
<h1>{{ name }}</h1>
<div class="posts">
{{ #featuredPost }}<h2>{{ title }}</h2>{{ /featuredPost }}
{{ #posts }}
  {{ #isPublished }}
    <h2>{{ title }}</h2>
  {{ /isPublished }}
{{ /posts }}
</div>
```

The code generator resolves `name` to a String getter on User, `featuredPost` to
a Post getter on User, `posts` to a `List<Post>` getter on User, `isPublished`
to a `bool` getter on `Post`, and `title` to a String getter on `Post`. It has
all of the information it needs to write out the logic of the template as a
simple state machine. This state machine is written out as the render function
and helper functions for partials:

```dart
String renderUser(User context0) {
  final buffer = StringBuffer();
  // ...
  return buffer.toString();
}
```

The `renderUser` function takes a `User` object, the context object, as
`context0`. Since the context objects exist in a stack and can each be accessed,
we must enumerate them. We write various text to the buffer, according to the
template, and then return the rendered output.

### Rendering plain text

Rendering plain text is as simple as writing it to the buffer:

```dart
  buffer.write('''<h1>''');
```

### Rendering a variable

Rendering a variable requires one or more getter calls. During code generation,
variable keys have been resolved so that the renderer knows the context objects
that provide each getter.

`{{ name }}` compiles to:

```dart
  buffer.write(htmlEscape.convert(context0.name.toString()));
```

This code calls the `name` getter on `context0`, and then `toString()`. Since
`{{ name }}` uses two brackets, the output must be HTML-escaped. If it were
written `{{{ name }}}`, then the HTML-escaping call would not be made.

### Rendering a section

A section could be a conditional section, a repeated section, or a value
section. The code generator will know, and will write the correct behavior into
the renderer.

#### Rendering a conditional section

`{{ #isFeatured }}<strong>Featured</strong>{{ /isFeatured }}` compiles to:

```dart
  if (context0.isFeatured) {
    buffer.write('''<strong>Featured</strong>''');
  }
```

The text is written only if `isFeatured` is `true`. If the section were
inverted (starting with `{{ ^isFeatured }}`), then the condition would be
`!context0.isFeatured`.

#### Rendering a repeated section

`{{ #posts }}<h2>{{ title }}</h2>{{ /posts }}`

compiles to:

```dart
  var context1 = context0.posts;
  if (context1 != null) {
    for (var context2 in context1) {
      buffer.write('''<h2>''');
      buffer.write(htmlEscape.convert(context2.title.toString()));
      buffer.write('''</h2>''');
    }
  }
```

The section contents are written for each value in `context0.posts` (only if
`context0.posts` is not `null`). In order to avoid accessing the getter multiple
times (and to make the value type-promotable), the value is stored in a local
variable.

#### Rendering a value section

`{{ #featuredPost }}<h2>{{ title }}</h2>{{ /featuredPost }}`

compiles to:

```dart
  var context2 = context0.featuredPost;
  if (context2 != null) {
    buffer.write('''<h2>''');
    buffer.write(htmlEscape.convert(context2.title.toString()));
    buffer.write('''</h2>''');
  }
```

The section contents are written only if `context0.featuredPost` is not `null`.
Additionally, the section needs `context0.featuredPost` pushed onto the context
stack, which becomes `context2`. This new context object is used to render the
featured post's `title`.

### Rendering a partial

Partials are allowed to reference themselves, so they must be implemented as
separate functions which can call themselves recursively. This template code:

```html
{{ #posts }}{{ >post }}{{ /posts }}
```

will use a custom partial resolver to resolve `post` to a file at `_post.html`,
which contains the following template:

```html
<h2>{{ title }}</h2>
<p>by {{ name }}</p>
```

These two templates compile into the following two render functions:

```dart
String renderUser(User context0) {
  final buffer = StringBuffer();
  for (var context1 in context0.posts) {
    buffer.write(_renderUser_partial_user_post_0(context1, context0));
  }
  return buffer.toString();
}

String _renderUser_partial_user_post_0(Post context1, User context0) {
  final buffer = StringBuffer();
  buffer.write('''<h2>''');
  buffer.write(htmlEscape.convert(context1.title.toString()));
  buffer.write('''</h2>
<p>by ''');
  buffer.write(htmlEscape.convert(context0.name.toString()));
  buffer.write('''</p>''');
  return buffer.toString();
}
```

Note that the partial function is written to accept each context object as a
separate parameter, so that they are easily accessed by name. `context1` is
accessed in order to write the post's `title`, and `context0` is accessed in
order to write the author's `name`.

### Compiler for generating renderers

The AOT compiler is a tool that builds render functions from Mustache templates.
In order to understand the types of Mustache keys encounted in the templates,
the compiler must also know the singular static context type that will be
"rendered into" each template.

The AOT compiler only needs to be executed by a Dartdoc developer, when a
template changes, or when any one of the types that may be rendered into a
template changes, or when the complier changes. The generated renderer functions
are checked in as Dartdoc source code. In other words, the ahead-of-time
compiled renderer functions only need to be compiled when making a change to
Dartdoc. These renderer functions, on the other hand, need to run every single
time Dartdoc runs, generating HTML documentation. Therefore we generally aim to
remove complexity from the renderer functions, even at the cost of added
complexity in the AOT compiler.

#### Basic example

As a basic example of how the compiler chooses what to write into a renderer
function, see the code below. The User class is rendered into the `user.html`
template, as specified in this `@Renderer` annotation:

```dart
@Renderer(#renderUser, Context<User>(), 'user')
```

```dart
abstract class User {
  String get name;
  Post? get featuredPost;
  List<Post> get posts;
}
```

```html
<h1>{{ name }}</h1>
{{ #featuredPost }}{{ >post }}{{ /featuredPost }}
```

The AOT compiler takes the parsed Mustache template, which contains a rendered
variable (`{{ name }}`) and a section (`{{ #featuredPost }}...`).

The first step is to write the function name and parameters. The `@Renderer`
annotation specifies that the public name for the renderer function is
`renderUser`. As a top-level, public render function, there is only one context
variable in the context stack, which is `User`. The only parameter therefore is
`User context0`:

```dart
String renderUser(User context0) {
  final buffer = StringBuffer();
  // ...
  return buffer.toString();
}
```

The compiler looks up the `name` property on `User`, finds that it exists, and
returns a `String`, which is valid for a rendered variable. When generating the
renderer, the compiler can just write to the function's `buffer`.

The compiler then looks up the `featuredPost` property on `User`, finds that it
exists, and returns a nullable `Post`. This means the section is a "value"
section; the compiler writes the renderer to only write to `buffer` if
`context0.featuredPost` is non-`null`. If instead the compiler were to see that
`featuredPost` were a `bool`-typed property, it would write the renderer to
write the section content depending on whether the property is `true` or
`false`. And finally if instead the compiler were to see that `featuredPost`
were an `Iterable`-typed property, it would write the renderer to loop over the
value of the property and write the section repeatedly.

#### Partials

Most of the complexity in the AOT compiler is found in the handling of partials.
The compiler attempts to generate a minimal amount of code for the renderer
functions.

Each partial template is compiled into it's own (private) renderer function,
complete with a name, a list of parameters, and a body. They must be very
flexible in order to satisfy a variety of legal situations allowed by the
Mustache template system:

1. Just as with a top-level template, and as with a section, a partial has
   access to the entire context stack.

   As a quick example, if a reference to a partial is a point in a template with
   3 context variables, then the partial must also have access to those 3
   context variables; it will have 3 parameters (modulo the optimizations
   below).

2. A partial can reference itself. For this reason, partials are compiled into
   their own named functions.

3. A single partial can be referenced by multiple templates, and the context
   stacks of these templates may be completely different from each other.

   For example two templates may reference one partial, and one may have as the
   top context variable a `String`, while the other may have as the top context
   variable a `List<int>`. The partial may then contain a rendered variable for
   a property named `length`; this is all legal. Therefore, at the outset, it
   looks like each _reference_ to a partial, even the same partial, requires
   generating a separate renderer function. In this example, one partial
   renderer function will take a `String` parameter, and the other will take a
   `List<int>` parameter.

   (In practice, while a given partial template may be referenced by multiple
   templates with different context stacks, the types of corresponding context
   variables will typically have LUB types that are more narrow than `Object`
   and that can be legally used as parameter types. This allows for
   deduplication, and is described below.)

4. A partial may be referenced multiple times from the same template. Again, the
   points at which these references occur may have differing context stacks.
   This is just another reason that each reference to a partial _may_ require
   generating a separate renderer function.

Because we may need to generate a partial function for each _reference_ to a
partial template, they are uniquely named with their call stack. For example, if
the `renderUser` function references the `_post` partial, then the generated
renderer function for that partial is called `_renderUser_partial_post_0`. If it
references that partial twice, the second rendered function is called
`_renderUser_partial_post_1`. If one of these partials references the `_author`
partial, the generated rendered function for that partial is called
`_renderUser_partial_post_0_partial_author_0`. One can see how this can quickly
get out-of-hand, and how this system can really benefit from some optimizations.

#### High level code walkthrough

The AOT compiler is found in `tool/mustachio/codegen_aot_compiler.dart`. The
entrypoint into this code is the top-level `compileTemplatesToRenderers`
function. This function takes a set of `RendererSpec`s (just the info derived
from each `@Renderer` annotation) and returns a single String, the source text
for a Dart library containing all of the compiled renderer functions.

The `compileTemplatesToRenderers` function is fairly simple; it walks over the
`RendererSpec` objects, creating an `_AotCompiler` object for each. The
`_AotCompiler._readAndParse` function takes a context type, a renderer name, a
path to a template, and some extra data, parses the template, and returns an
`_AotCompiler` instance. The `compileTemplatesToRenderers` function then takes
that compiler instance, compiles the template into a renderer function (a String
of Dart source code), and also collects a mapping of partial renderer functions
that were compiled in the process. When the compiler instance compiles its given
template into a renderer, it recursvely creates a compiler instance for each
referenced partial and compiles the referenced partial into a renderer function
(see `_BlockCompiler._compilePartial`).

In this way, `compileTemplatesToRenderers` collects all of the compiler
instances and the renderer function source code that has been compiled by each.
Finally, it writes out all of the function source code to one giant
StringBuffer; some import directives are prepended, and everything is ultimately
written to a single file on disk.

We track the mapping of each compiler to the source code it compiled, in order
to perform some optimizations before the final list of renderer functions is
written to the StringBuffer. These are detailed below.

#### Used context stacks

The first optimization in Mustachio's partial renderer function generation is to
strip out unused context stacks.

For example, take the following template and partial:

```html
<!-- home template -->
{{ #loggedInUser }}
  {{ #featuredPost }}
    {{ #authors }}{{ >author }}{{ /authors }}
  {{ /featuredPost }}
{{ /loggedInUser }}

<!-- _author partial -->
{{ name }}
```

Let's say that some generic `HomePageData` object is rendered into this
template; the `loggedInUser` property has a `User` type; `featuredPost` is a
property on `User`, with a `Post` type; `authors` is a property on `Post` with a
`List<User>`. The `_author` partial template can legally access any property on
the context stack: `User`, `Post`, `User`, `HomePageData`. As per the rules of
Mustache, a renderer must first search the top context type, `User`, for a
property named `name`, and if that is not found, continue down the context
stack.

Without any further investigation, it looks like the renderer function for the
`_author` partial will have 4 parameters, `User context0`, `Post context1`,
`User context2`, and `HomePageData context3`. However, as we know the entire
parsed contents of the partial, we can simplify the list of parameters down to
the ones which are actually _used_.

(The attentive reader will note that right off the bat, if `name` is not found
on the first context variable, a `User`-typed variable, then it's not going to
be found on the third context variable, also a `User`, so we can immediately
strip out the 3rd parameter; this behavior comes out of the broader optimization
as well.)

In order to reduce the `_author` renderer function's parameters down to the ones
which are used, we must walk the parsed partial and track the variables on the
context stack which are used in order to access a variable or a section key. In
this example where `name` is the only property accessed, and where `name` is a
property on `User`, we can reduce the number of parameters from 4 down to 1.

Note that the `_author` partial template may itself reference other templates.
If it refers to an `_avatar` partial, and a `_badges` partial, then each of
those partials _can also legally access_ any variable in the context stack. So
when walking the parsed `_author` partial, tracking the used variables, we must
take `_avatar` and `_badges` into account, walking those partials, etc.

In practice this can immensely simplify the generated renderers as the vast
majority of rendered variables and section keys are properties on the top-most
context variable. This means reducing the number of parameters that each
renderer function takes and reducing the number of arguments that each renderer
function needs to pass to partial calls.

In the `codegen_aot_compiler.dart` source, here are the steps that carry out
this optimization:

1. The `_AotCompiler._compileToRenderer` function creates a `_BlockCompiler` (a
   class that compiles a single Mustache block into a String) with the current
   context stack, in order to compile the Mustache block that is the top-level
   unit of a template.
2. The `_BlockCompiler` compiles the block of Mustache into a series of Dart
   statements (as source code), and tracks the referenced context variables in a
   set, `_BlockCompiler._usedContextTypes`.
3. At this point we have the body of the renderer that we are creating, and its
   name. We write the return type (`String`) and the name of the render
   function, and then must write the list of parameters. Instead of writing the
   list of _all_ of the context variables as parameters, we only write the
   _used_ ones, collected up by the `_BlockCompiler` (and any nested
   `_AotCompiler`s and `_BlockCompiler`s that were also created).
4. (Sometimes type parameters must also be added to the render functions, and
   sometime type arguments must also be added to the parameter types; this is
   omitted here.)
5. After writing the parameters, we can write the body, and we're done.

Note that there is a shortcoming of this implementation in the names of the
parameters of a partial renderer function. A given `_BlockCompiler` has a
context stack and a template. The context stack is a list of "variable lookup"
objects, which each describe a contect variable's type and name. So before the
block compiler knows what the used context variables are, the names of all
context variables is hard-coded. The block compiler then generates statements
for the body of the function, using those variable names. Because of this
implementation, some partial renderer functions are created with a seemingly
arbitrary list of parameter names. For a given partial, maybe the 1st and 3rd
parameters (`context0` and `context2`) in the context stack are unused, and so 
the two parameters left that the function is written to accept are called
`context1` and `context3`.

#### Deduplicating partials

The second optimization the AOT compiler makes is to deduplicate the partial
renderer functions. Generating an entire set of partial functions for every call
stack of each reference to each partial yields a lot of code. In most cases of
real Mustache templates, simplification is possible.

The idea is based on the Least Upper Bound (LUB) of Dart types. If we generate 3
renderer functions for a partial template, that each have a context stack with 2
context variables, we might be able to replace the 3 functions with a new
function that uses slightly different context stack types. In particular, it is
often the case that one template refers to a partial with type `A` as the
topmost context type, and that another template refers to the same partial with
type `B` as the topmost context type, and that `A` and `B` are closely related
(for example they share the same base class, which is not `Object`, or one is a
supertype of the other). So we can often get away with calculating the Least
Upper Bound of pairwise items in each context stack, creating a new context
stack. If the context stacks of our 3 renderer functions have types `T1, U1`,
`T2, U2`, and `T3, U3`, then we can create a new context stack with types
`LUB(T1, LUB(T2, T3)), LUB(U1, LUB(U2, U3))`. (Given an LUB function that can
take arbitrarily many types, this can be written `LUB(T1, ..., Tn)` for each
of `n` context types in the set of context stacks.)

Care must be taken however, as using an LUB type may escape beyond the static
type on which properties have been previously resolved. If the partial compiled
into the 3 renderer functions above refers to a property `foo`, and the LUB of
the individual types does not have any property `foo`, then the LUB type does
not work, and cannot be used. In practice though, this strategy allows us to
deduplicate many renderer functions for Dartdoc.

In the `codegen_aot_compiler.dart` source, all template compilers and template
renderer functions are tracked in a "renderer cache" (`_RendererCache`). This
cache maps each template path to a collection of renderers (a
`_RenderersForPath`). The collection of renderers is a map, mapping each used
context stack to some renderer data (`_RendererData`). The renderer data is
simply the compler, the compiled renderer string, and a reference count of how
many other templates reference that renderer:

```none
renderer cache: {
  path1 -> renderers1 {
                        [context0, context1] => (compiler1, renderer1)
                        [context0, context1, context2] => (compiler2, renderer2)
  }
  path2 -> renderers2 {
                        [context1, context2, context3] => (compiler3, renderer3)
                        [context1, context3] => (compiler4, renderer4)
  }
}
```

As compilers are created and used to calculate used context stacks and compile
renderer functions, they are inserted into the renderer cache.

Here are the steps that carry out the deduplicating optimization:

1. After gathering all `_AotCompiler` instances that each compiled a renderer
   function (as Dart source code), we enter `_deduplicateRenderers` to
   deduplicate the list.

2. This function iterates over each partial path in the cache, looking at the
   list of used context stacks.

   1. We then calculate the LUB of the types in each position in the list, with
      the `contextStackLub` function. For example, if a list of used context
      stacks has 3 context stacks (derived from 3 compilers), and each context
      stack has 2 context variables, then the result is a context stack, again
      with 2 context variables, such that the first context variable is the LUB
      of the first variable in each of the 3 original context stacks, and the
      second context variable is the LUB of the second variable in each of the 3
      original context stacks. (If the context stacks in the list do not all
      have exactly the same length, we say the "LUB context stack" is `null`,
      and we cannot deduplicate the renderer functions.)
   2. If the context stacks have some valid LUB context stack, then we may be
      able to replace each renderer function that was compiled for this partial
      with a single renderer function that uses the LUB context stack. We
      proceed by creating a new `_AotCompiler` and a fresh, "deduplicated"
      renderer name.
   3. We try to compile the partial with the new deduplicated compiler. It is
      possible that this fails: if the partial depended on properties that were
      available on the individual context stacks, but are unavailable on the LUB
      context stack, then compilation will fail. In this case, we can just keep
      the individual renderer functions.
   4. If the new deduplicated compiler successfully compiles a renderer
      function, we move forward with it: for each replaced compiler, we replace
      its renderer function with a "redirecting" renderer function, that simply
      redirects to a call to the deduplicated renderer function.
   5. In order to reduce the amount of generated code, we also _mark for
      removal_ each of the replaced partial renderer functions. Since each
      partial may be referenced by more than one other template, we support the
      removals with reference-tracking; we track each reference from one
      template to another, and when renderer functions are marked for removal,
      those reference counts are decremented. A renderer function is only
      actually removed when the reference count reaches 0.

3. Finally, the new mapping of compilers to compiled renderer functions is
   passed back to the `compileTemplatesToRenderers` to be written out.