Dartdoc supports several **directives** within Dart doc comments. Each directive
is then processed during documentation generation, and new text is inserted in
place of the directive. Not all directives are supported for package
documentation at https://pub.dev/.

A doc comment directive consists of either one directive tag, which looks
something like `{@DIRECTIVE ARG=VALUE ...}`, or two such tags (an opening and a
closing tag), with content in between.

The supported directives are listed below:

## `@nodoc` - Do not include documentation

An element whose doc comment should not appear in the generated documentation
can include the `@nodoc` directive.

Note that the `@nodoc` directive does not have curly braces, like most of the
other directives.

## `{@category}` and `{@subCategory}` - Categories

Elements such as libraries and classes can be grouped into categories and
sub-categories by adding `{@category CATEGORY NAME}` and
`{@subCategory SUB-CATEGORY NAME}` in doc comments. Each category then gets its
own documentation page, listing all of the categorized elements.

## `{@template}` and `{@macro}` - Templates and macros

TODO(srawlins): Document.

## `{@inject-html}` - Injected HTML

HTML can be rendered unmodified by including it between `{@inject-html}` and
`{@end-inject-html}` directive tags. The tags take no arguments:

```none
/// {@inject-html}
/// <p>Injected HTML.</p>
/// {@end-inject-html}
```

The `{@inject-html}` directive is only available when the `--inject-html` flag
is passed to `dart doc`. It is not available for documentation published on
https://pub.dev.

## `{@animation}` - Animations

HTML5 videos can be embedded with the `{@animation}` directive. This directive
accepts width and height arguments, and an optional ID argument:

```none
/// {@animation 320 240 URL [id=ID]}
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
/// {@youtube 320 240 https://www.youtube.com/watch?v=oHg5SJYRHA0}
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
/// {@canonicalFor some_library.SomeClass}
```

When this directive is used on a library's doc comment, that library is marked
as the canonical library for `some_library.SomeClass`.

## {@example}

Replaces the `{@example}` directive in API comments with a fenced code block containing the contents of an external file. This is a block-level directive and must appear on its own line.

### Syntax

```markdown
{@example <path>[#<region>] [lang=LANGUAGE] [indent=keep|strip]}
```

*   **`<path>`**: The path to the file to inject. If the path starts with a leading `/`, it is resolved relative to the package root. Otherwise, it is resolved relative to the directory of the current file containing the directive.
*   **`#<region>`** (Optional): A specific region of the file to extract. If omitted, the entire file is included.
*   **`lang`** (Optional): Specifies the language for the fenced markdown code block. If not provided, it defaults to the file extension of the path.
*   **`indent`** (Optional): How to handle indentation.
    *   `strip` (Default): Removes common indentation from all lines. Whitespace-only lines are ignored for calculation and normalized to empty lines. If any line has non-space characters in its indentation, stripping is disabled to prevent broken formatting.
    *   `keep`: The original indentation is left as-is.


### Regions and Hiding Code

You can extract a specific portion of an external file by defining regions and appending `#<region>` to the file path.

*   A region is bounded by `#region <region>` and `#endregion` markers.
*   When a region is targeted, any lines containing `#region`, `#endregion`, or `#hide` markers are completely omitted from the extracted output.
*   The `#hide` marker is especially useful for hiding setup, teardown, or assertion code that is necessary for the example to compile, but is irrelevant to the documentation (e.g., `exit(0); // #hide`).
*   **Format-Agnostic:** The markers do not need to be within a code comment. Any line containing `#region <name>`, `#endregion`, or `#hide` will be matched and stripped. This makes the feature compatible with any language (HTML, SQL, YAML, etc.).
*   If no region is specified in the directive, the entire file is included and no markers are stripped.

### Examples

**Basic usage:**
```dart
/// {@example /examples/my_example.dart}
```

**Extracting a specific region:**
```dart
/// {@example /examples/my_example.dart#my_region}
```

**Overriding the language and keeping indentation:**
```dart
/// {@example ../subdir/utils.txt lang=dart indent=keep}
```
