# dartdoc

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg?branch=master)](https://travis-ci.org/dart-lang/dartdoc)
[![Appveyor Build Status](https://ci.appveyor.com/api/projects/status/s6sh69et2ga00dlu?svg=true)](https://ci.appveyor.com/project/devoncarew/dartdoc)
[![Coverage Status](https://coveralls.io/repos/github/dart-lang/dartdoc/badge.svg?branch=master)](https://coveralls.io/github/dart-lang/dartdoc?branch=master)


Use `dartdoc` to generate HTML documentaton for your Dart package.

For information about contributing to the dartdoc project, see the
[contributor docs][].

For issues/details related to hosted Dart API docs, see
[dart-lang/api.dart.dev](https://github.com/dart-lang/api.dart.dev/).

## Installing dartdoc

- download the [Dart SDK](https://dart.dev/get-dart)
- add the SDK's `bin` directory to your `PATH`

## Generating docs

Run `dartdoc` from the root directory of a package.  Here is an example of dartdoc documenting itself:

```
$ dartdoc
Documenting dartdoc...
Initialized dartdoc with 766 libraries in 63.9 seconds
Generating docs for library dartdoc from package:dartdoc/dartdoc.dart...
Validating docs...
no issues found
Documented 1 public library in 17.9 seconds
Success! Docs generated into <path to dartdoc>/doc/api
```

By default, the documentation is generated to the `doc/api` directory as static
HTML files.

Run `dartdoc -h` to see the available command-line options.

## Viewing docs

You can view the generated docs directly from the file system, but if you want
to use the search function, you must load them with an HTTP server.

An easy way to run an HTTP server locally is to use the `dhttpd` package. For
example:

```
$ pub global activate dhttpd
$ dhttpd --path doc/api
```

Navigate to `http://localhost:8080` in your browser; the search function should
now work.

## Link structure

dartdoc produces static files with a predictable link structure.

```
index.html                          # homepage
index.json                          # machine-readable index
library-name/                       # : is turned into a - e.g. dart:core => dart-core
  ClassName-class.html              # "homepage" for a class (and enum)
  ClassName/
    ClassName.html                  # constructor
    ClassName.namedConstructor.html # named constructor
    method.html
    property.html
  CONSTANT.html
  property.html
  top-level-function.html
```

File names are _case-sensitive_.

## Writing docs

Check out the
[Effective Dart: Documentation guide](https://dart.dev/guides/language/effective-dart/documentation).

The guide covers formatting, linking, markup, and general best practices when
authoring doc comments for Dart with `dartdoc`.

## Excluding from documentation

`dartdoc` will not generate documentation for a Dart element and its children that have the
`@nodoc` tag in the documentation comment.

## Advanced features

### dartdoc_options.yaml

Creating a file named dartdoc_options.yaml at the top of your package can change how Dartdoc
generates docs.  

An example (not necessarily recommended settings):

```yaml
dartdoc:
  categories: 
    "First Category":
      markdown: doc/First.md
      name: Awesome
    "Second Category":
      markdown: doc/Second.md
      name: Great
  categoryOrder: ["First Category", "Second Category"]
  examplePathPrefix: 'subdir/with/examples'
  includeExternal: ['bin/unusually_located_library.dart']
  linkTo:
    url: "https://my.dartdocumentationsite.org/dev/%v%"
  showUndocumentedCategories: true
  ignore:
    - ambiguous-doc-reference
  errors:
    - unresolved-doc-reference
  warnings:
    - tool-error
```

#### dartdoc_options.yaml fields

In general, **paths are relative** to the directory of the `dartdoc_options.yaml` file in which the option
is defined, and should be specified as POSIX paths.  Dartdoc will convert POSIX paths automatically on Windows.
Unrecognized options will be ignored.  Supported options:

  * **categories**:  More details for each category/topic.  For topics you'd like to document, specify
    the markdown file with `markdown:` to use for the category page.  Optionally, rename the
    category from the source code into a display name with `name:`.  If there is no matching category
    defined in dartdoc_options.yaml, those declared categories in the source code will be invisible.
  * **categoryOrder**:  Specify the order of topics for display in the sidebar and
    the package page.
  * **examplePathPrefix**: Specify the location of the example directory for resolving `@example`
    directives.
  * **exclude**:  Specify a list of library names to avoid generating docs for,
    overriding any specified in include.  All libraries listed must be local to this package, unlike
    the command line `--exclude`.
  * **errors**:  Specify warnings to be treated as errors.  See the lists of valid warnings in the command
    line help for `--errors`, `--warnings`, and `--ignore`.
  * **favicon**:  A path to a favicon for the generated docs.
  * **footer**: A list of paths to footer files containing HTML text.
  * **footerText**: A list of paths to text files for optional text next to the package name and version
  * **header**:  A list of paths to header files containing HTML text.
  * **ignore**:  Specify warnings to be completely ignored.  See the lists of valid warnings in the command
    line help for `--errors`, `--warnings`, and `--ignore`.
  * **include**:  Specify a list of library names to generate docs for, ignoring all others.  All libraries
    listed must be local to this package (unlike the command line `--include`).
  * **includeExternal**:  Specify a list of library filenames to add to the list of documented libraries.
  * **linkTo**:  For other packages depending on this one, if this map is defined those packages
    will use the settings here to control how hyperlinks to the package are generated.
    This will override the default for packages hosted on [pub.dev](https://pub.dev) and
    [api.flutter.dev](https://api.flutter.dev).
    * **url**:  A string indicating the base URL for documentation of this package.  Ordinarily
      you do not need to set this in the package: consider `--link-to-hosted` and
      `--link-to-sdks` instead of this option if you need to build your own website with
      dartdoc.

      The following strings will be substituted in to complete the URL:
      * `%b%`: The branch as indicated by text in the version.  2.0.0-dev.3 is branch "dev".
        No branch is considered to be "stable".
      * `%n%`: The name of this package, as defined in `pubspec.yaml`.
      * `%v%`: The version of this package as defined in `pubspec.yaml`.
  * **linkToSource**: Generate links to a source code repository based on given templates and
    revision information.
    * **excludes**: A list of directories to exclude from processing source links.
    * **root**: The directory to consider the 'root' for inserting relative paths into the template.
      Source code outside the root directory will not be linked.
    * **uriTemplate**: A template to substitute revision and file path information.  If revision
      is present in the template but not specified, or if root is not specified, dartdoc will
      throw an exception.  To hard-code a revision, don't specify it with `%r%`.
      
      The following strings will be substituted in to complete the URL:
      * `%f%`:  Relative path of file to the repository root
      * `%r%`:  Revision
      * `%l%`:  Line number
  * **warnings**:  Specify otherwise ignored or set-to-error warnings to simply warn.  See the lists
    of valid warnings in the command line help for `--errors`, `--warnings`, and `--ignore`.

Unsupported and experimental options:

   * **ambiguousReexportScorerMinConfidence**:  The ambiguous reexport scorer will emit a warning if
     it is not at least this confident.  Adjusting this may be necessary for some complex
     packages but most of the time, the default is OK.  Default: 0.1

### Categories

You can tag libraries or top level classes, functions, and variables in their documentation with
the string `{@category YourCategory}`.  For libraries, that will cause the library to appear in a
category when showing the sidebar on the Package and Library pages.  For other types of objects,
the `{@category}` will be shown with a link to the category page **but only if specified in
dartdoc_options.yaml**, as above.

```dart
/// Here is my library.
/// 
/// {@category Amazing}
library my_library;
```

#### Other category tags and categories.json

A file `categories.json` will be generated at the top level of the documentation tree with
information about categories collected from objects in the source tree.  The directives
`@category`, `@subCategory`, `@image`, and `@samples` are understood and saved into this json.
Future versions of dartdoc may make direct use of the image and samples tags.

As an example, if we document the class Icon in flutter using the following:

```dart
/// {@category Basics}
/// {@category Assets, Images, and Icons}
/// {@subCategory Information displays}
/// {@image <image alt='' src='/images/catalog-widget-placeholder.png'>}
class Icon extends StatelessWidget {}
```

that will result in the following json:

```json
  {
    "name": "Icon",
    "qualifiedName": "widgets.Icon",
    "href": "widgets/Icon-class.html",
    "type": "class",
    "categories": [
      "Assets, Images, and Icons",
      "Basics"
    ],
    "subcategories": [
      "Information displays"
    ],
    "image": "<image alt='' src='/images/catalog-widget-placeholder.png'>"
  }
```

### Animations

You can specify links to videos inline that will be handled with a simple HTML5 player:

```dart
/// This widget is a dancing Linux penguin.
///
/// {@animation name 100 200 http://host.com/path/to/video.mp4}
```

'name' is user defined, and the numbers are the width and height of the animation in pixels.

### Macros

You can specify "macros", i.e. reusable pieces of documentation. For that, first specify a template
anywhere in the comments, like:

```dart
/// {@template template_name}
/// Some shared docs
/// {@endtemplate}
```

and then you can insert it via `{@macro template_name}`, like

```dart
/// Some comment
/// {@macro template_name}
/// More comments
```

Template definitions are currently unscoped -- if dartdoc reads a file containing a template, it can be used in anything
dartdoc is currently documenting.  This can lead to inconsistent behavior between runs on different
packages, especially if different command lines are used for dartdoc.  It is recommended to use collision-resistant
naming for any macros by including the package name and/or library it is defined in within the name.

### Tools

Dartdoc allows you to filter parts of the documentation through an external tool
and then include the output of that tool in place of the given input.

First, you have to configure the tools that will be used in the `dartdoc_options.yaml` file:

```yaml
dartdoc:
  tools:
    drill:
      command: ["bin/drill.dart"]
      setup_command: ["bin/setup.dart"]
      description: "Puts holes in things."
    echo:
      macos: ['/bin/sh', '-c', 'echo']
      setup_macos: ['/bin/sh', '-c', 'setup.sh']
      linux: ['/bin/sh', '-c', 'echo']
      setup_linux: ['/bin/sh', '-c', 'setup.sh']
      windows: ['C:\\Windows\\System32\\cmd.exe', '/c', 'echo']
      setup_windows: ['/bin/sh', '-c', 'setup.sh']
      description: 'Works on everything'
```

The `command` tag is used to describe the command executable, and any options
that are common among all executions. If the first element of this list is a
filename that ends in `.dart`, then the dart executable will automatically be
used to invoke that script. The `command` defined will be run on all platforms.

If the `command` is a Dart script, then the first time it is run, a snapshot
will be created using the input and first-time arguments as training arguments,
and will be run from the snapshot from then on. Note that the `Platform.script`
property will point to the snapshot location during the snapshot runs. You can
obtain the original `.dart` script location in a tool by looking at the
`TOOL_COMMAND` environment variable.

The `setup_command` tag is used to describe a command executable, and any
options, for a command that is run once before running a tool for the first
time. If the first element of this list is a filename that ends in `.dart`, then
the dart executable will automatically be used to invoke that script. The
`setup_command` defined will be run on all platforms. If the setup command is a
Dart script, then it will be run with the Dart executable, but will not be
snapshotted, as it will only be run once.

The `macos`, `linux`, and `windows` tags are used to describe the commands to be
run on each of those platforms, and the `setup_macos`, `setup_linux`, and
`setup_windows` tags define setup commands for their respective platforms.

The `description` is just a short description of the tool for use as help text. 

Only tools which are configured in the `dartdoc_options.yaml` file are able to
be invoked.

To use the tools in comment documentation, use the `{@tool <name> [<options>
...] [$INPUT]}` directive to invoke the tool:

```dart
/// {@tool drill --flag --option="value" $INPUT}
/// This is the text that will be sent to the tool as input.
/// {@end-tool}
```

The `$INPUT` argument is a special token that will be replaced with the name of
a temporary file that the tool needs to read from. It can appear anywhere in the
options, and can appear multiple times.

If the example `drill` tool with those options is a tool that turns the content
of its input file into a code-font heading, then the directive above would be
the equivalent of having the following comment in the code:

```dart
/// # `This is the text that will be sent to the tool as input.`
```

#### Tool Environment Variables

Tools have a number of environment variables available to them. They will be
interpolated into any arguments given to the tool as `$ENV_VAR` or `$(ENV_VAR)`,
as well as available in the process environment.

- `SOURCE_LINE`: The source line number in the original source code.
- `SOURCE_COLUMN`: The source column in the original source code.
- `SOURCE_PATH`: The relative path from the package root to the original source file.
- `PACKAGE_PATH`: The path to the package root.
- `PACKAGE_NAME`: The name of the package.
- `LIBRARY_NAME`: The name of the library, if any.
- `ELEMENT_NAME`: The name of the element that this doc is attached to.
- `TOOL_COMMAND`: The path to the original `.dart` script or command executable.
- `DART_SNAPSHOT_CACHE`: The path to the directory containing the snapshot files
   of the tools. This directory will be removed before Dartdoc exits.
- `DART_SETUP_COMMAND`: The path to the setup command script, if any.
- `INVOCATION_INDEX`: An index for how many times a tool directive has been
  invoked on the current dartdoc block. Allows multiple tool invocations on the
  same block to be differentiated.

### Injecting HTML

It happens rarely, but sometimes what you really need is to inject some raw HTML
into the dartdoc output, without it being subject to Markdown processing
beforehand. This can be useful when the output of an external tool is HTML, for
instance. This is where the `{@inject-html}...{@end-inject-html}` tags come in.

For security reasons, the `{@inject-html}` directive will be ignored unless the
`--inject-html` flag is given on the dartdoc command line.

Since this HTML fragment doesn't undergo Markdown processing, reference links
and other normal processing won't happen on the contained fragment.

So, this:
```dart
  ///     {@inject-html}
  ///     <p>[The HTML to inject.]()</p>
  ///     {@end-inject-html}
```

Will result in this be emitted in its place in the HTML output (notice that the
markdown link isn't linked).
```
<p>[The HTML to inject.]()</p>
```

It's best to only inject HTML that is self-contained and doesn't depend upon
other elements on the page, since those may change in future versions of Dartdoc.

### Auto including dependencies

If `--auto-include-dependencies` flag is provided, dartdoc tries to automatically add
all the used libraries, even from other packages, to the list of the documented libraries.

### Using link-to-source

The source linking feature in dartdoc is a little tricky to use, since pub packages do not actually
include enough information to link back to source code and that's the context in which documentation
is generated for the pub site.  This means that for now, it must be manually specified in
dartdoc_options.yaml what revision to use.  It is currently recommended practice to
specify a revision in dartdoc_options.yaml that points to the same revision as your public package.
If you're using a documentation staging system outside of Dart's pub site, override the template and
revision on the command line with the head revision number.  You can use the branch name,
but generated docs will generate locations that may start drifting with further changes to the branch.

Example dartdoc_options.yaml:
```yaml
link-to-source:
  root: '.'
  uriTemplate: 'https://github.com/dart-lang/dartdoc/blob/v0.28.0/%f%#L%l%'
```

Example staging command line:
```bash
pub global run dartdoc --link-to-source-root '.' --link-to-source-revision 6fac6f770d271312c88e8ae881861702a9a605be --link-to-source-uri-template 'https://github.com/dart-lang/dartdoc/blob/%r%/%f#L%l%'
```

This gets more complicated with `--auto-include-dependencies` as these command line flags
will override all settings from individual packages.  In that case, to preserve
source links from third party packages it may be necessary to generate
dartdoc_options.yaml options for each package you are intending to add source links
to yourself.

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][].  Issues are labeled with
priority based on how much impact to the ecosystem the issue addresses and
the number of generated pages that show the anomaly (widespread vs. not
widespread).

Some examples of likely triage priorities:

* P0
  * Broken links, widespread
  * Uncaught exceptions, widespread
  * Incorrect linkage, widespread
  * Very ugly or navigation impaired generated pages, widespread

* P1
  * Broken links, few or on edge cases
  * Uncaught exceptions, very rare or with simple workarounds
  * Incorrect linkage, few or on edge cases
  * Incorrect doc contents, widespread or with high impact
  * Minor display warts not significantly impeding navigation, widespread
  * Default-on warnings that are misleading or wrong, widespread
  * Generation problems that should be detected but aren't warned, widespread
  * Enhancements that have significant data around them indicating they are a big win
  * User performance problem (e.g. page load, search), widespread

* P2
  * Incorrect doc contents, not widespread
  * Minor display warts not significantly impeding navigation, not widespread
  * Generation problems that should be detected but aren't warned, not widespread
  * Default-on warnings that are misleading or wrong, few or on edge cases  
  * Non-default warnings that are misleading or wrong, widespread
  * Enhancements considered important but without significant data indicating they are a big win
  * User performance problem (e.g. page load, search), not widespread
  * Generation performance problem, widespread

* P3
  * Theoretical or extremely rare problems with generation
  * Minor display warts on edge cases only
  * Non-default warnings that are misleading or wrong, few or on edge cases
  * Enhancements whose importance is uncertain
  * Generation performance problem, limited impact or not widespread


## License

Please see the [dartdoc license][].

Generated docs include:

 * Highlight.js -
   [LICENSE](https://github.com/isagalaev/highlight.js/blob/master/LICENSE)
   * With `github.css` (c) Vasily Polovnyov <vast@whiteants.net>

[GitHub Issue Tracker]: https://github.com/dart-lang/dartdoc/issues
[contributor docs]: https://github.com/dart-lang/dartdoc/blob/master/CONTRIBUTING.md
[dartdoc license]: https://github.com/dart-lang/dartdoc/blob/master/LICENSE
