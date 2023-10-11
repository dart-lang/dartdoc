Dartdoc supports several **directives** within Dart doc comments. Each directive
is then processed during documentation generation, and new text is inserted in
place of the directive. Not all directives are supported for package
documentation at https://pub.dev/.

A doc comment directive consists of either one directive tag, which looks
something like `{@DIRECTIVE ARG=VALUE ...}`, or two such tags (an opening and a
closing tag), with content in between.

The supported directives are listed below:

## `@nodoc` - Do not include documentation

An element whose doc comment should not appear in the generated documenation can
include the `@nodoc` directive.

## `{@category}` and `{@subCategory}` - Categories

Elements such as libraries and classes can be grouped into categories and
sub-categories by adding `{@category CATEGORY NAME}` and
`{@subCategory SUB-CATEGORY NAME}` in doc comments. Each category then gets its
own documentation page, listing all of the categorized elements.

## `{@template}` and `{@macro}` - Templates and macros

TODO(srawlins): Document

## `{@example}` - Examples (deprecated)

Examples from the file system can be inlined by using the `{@example}`
directive. The file path, the region, and the example language can all be
specified with the following syntax:

```none
{@example PATH [region=NAME] [lang=NAME]}
```

All example file names must have the extension, `.md`, and this extension must
not be specified in the example `PATH`. `PATH` must be specified as a relative
path from the root of the project for which documentation is being generated.
Given `dir/file.dart` as `PATH`, an example will be extracted from
`dir/file.dart.md`, relative to the project root directory.

During doc generation, dartdoc will replace the `{@example}` directive with the
contents of the example file, verbatim.

TODO(srawlins): Document region, lang, `--example-path-prefix`.

## `{@inject-html}` - Injected HTML

HTML can be rendered unmodified by including it between `{@inject-html}` and
`{@end-inject-html}` directive tags. The tags take no arguments:

```none
{@inject-html}
INJECTED HTML
{@end-inject-html}
```

The `{@inject-html}` directive is only available when the `--inject-html` flag
is passed to `dart doc`. It is not available for documentation published on
https://pub.dev.

## `{@animation}` - Animations

HTML5 videos can be embedded with the `{@animation}` directive. This directive
accepts width and height arguments, and an optional ID argument:

```none
{@animation 320 240 URL [id=ID]}
```

This directive renders the HTML which embeds an HTML5 video.

The optional ID should be a unique id that is a valid JavaScript identifier, and
will be used as the id for the video tag. If no ID is supplied, then a unique
identifier (starting with "animation_") will be generated.

The width and height must be integers specifying the dimensions of the video
file in pixels.

## `{@youtube}` - YouTube videos

A YouTube video can be embedded with the `{@youtube}` directive. This directive
accepts width and height arguments, using the following syntax:

```none
{@youtube 320 240 https://www.youtube.com/watch?v=oHg5SJYRHA0}
```

This directive embeds the YouTube video with id "oHg5SJYRHA0" into the
documentation page, with a width of 320 pixels, and a height of 240 pixels. The
height and width are used to calculate the aspect ratio of the video; the video
is always rendered to take up all available horizontal space to accommodate
different screen sizes on desktop and mobile.

The video URL must have the following format:
`https://www.youtube.com/watch?v=oHg5SJYRHA0`. This format can usually be found
in the address bar of the browser when viewing a YouTube video.

## `{@tool}` - External tools

TODO(srawlins): Document.

## `{@canonicalFor}` - Canonicalization

Dartdoc uses some heuristics to decide what the public-facing libraries are,
and which public-facing library is the "canonical" location for an element.
When that heuristic needs to be overridden, a user can use this directive.
Example:

```none
{@canonicalFor some_library.SomeClass}
```

When this directive is used on a library's doc comment, that library is marked
as the canonical library for `some_library.SomeClass`.