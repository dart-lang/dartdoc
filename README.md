# dartdoc

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg?branch=master)](https://travis-ci.org/dart-lang/dartdoc)

Use `dartdoc` to generate HTML documentaton for your Dart package.

For information about contributing to the dartdoc project, see the
[contributor docs][].

For issues/details related to hosted Dart API docs, see
[dart-lang/api.dartlang.org](https://github.com/dart-lang/api.dartlang.org/).

## Installing dartdoc

- download the [Dart SDK](https://www.dartlang.org/downloads/)
- add the SDK's `bin` directory to your `PATH`

## Generating docs

Run `dartdoc` from the root directory of package. For example:

```
$ dartdoc
Generating documentation for 'server_code_lab' into <path-to-server-code-lab>/server_code_lab/doc/api/

parsing lib/client/piratesapi.dart...
parsing lib/common/messages.dart...
parsing lib/common/utils.dart...
parsing lib/server/piratesapi.dart...
Parsed 4 files in 8.1 seconds.

generating docs for library pirate.messages from messages.dart...
generating docs for library pirate.server from piratesapi.dart...
generating docs for library pirate.utils from utils.dart...
generating docs for library server_code_lab.piratesApi.client from piratesapi.dart...
Documented 4 libraries in 9.6 seconds.

Success! Docs generated into <path-to-server-code-lab>/server_code_lab/doc/api/index.html
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
[Effective Dart: Documentation guide](https://www.dartlang.org/effective-dart/documentation/).

The guide covers formatting, linking, markup, and general best practices when
authoring doc comments for Dart with `dartdoc`.

## Excluding from documentation

`dartdoc` will not generate documentation for a Dart element and its children that have the
`@nodoc` tag in the documentation comment.

## Advanced features

### dartdoc_options.yaml

Creating a file named dartdoc_options.yaml at the top of your package can change how Dartdoc
generates docs.  

```yaml
dartdoc:
  categoryOrder: ["First Category", "Second Category"]
  linkTo:
    url: "https://my.dartdocumentationsite.org/dev/%v%"
```

Unrecognized options will be ignored.  Supported options:

  * **categoryOrder**:  Specify the order of categories, below, for display in the sidebar and
    the package page.
  * **linkTo**:  For other packages depending on this one, if this map is defined those packages
    will use the settings here to control how hyperlinks to the package are generated.
    This will override the default for packages hosted on pub.dartlang.org.
    * **url**:  A string indicating the base URL for documentation of this package.  Ordinarily
      you do not need to set this in the package: consider --link-to-hosted and
      --link-to-sdks instead of this option if you need to build your own website with
      dartdoc.

      The following strings will be substituted in to complete the URL:
      * `%b%`: The branch as indicated by text in the version.  2.0.0-dev.3 is branch "dev".
        No branch is considered to be "stable".
      * `%n%`: The name of this package, as defined in pubspec.yaml.
      * `%v%`: The version of this package as defined in pubspec.yaml.

The following are experimental options whose semantics are in flux and may be buggy.  If you
use one, please keep a close eye on the changing semantics.  In general, paths are relative
to the directory the dartdoc_options.yaml the option is defined in and should be specified
as POSIX paths.  Dartdoc will convert POSIX paths automatically on Windows.

  * **ambiguousReexportScorerMinConfidence**:  The ambiguous reexport scorer will emit a warning if
  it is not at least this confident.  Default: 0.1
  * **examplePathPrefix**:  Specify the prefix for the example paths, defaulting to the project root.
  * **exclude**:  Specify a list of library names to avoid generating docs for, ignoring all others.
  * **favicon**:  A path to a favicon for the generated docs.
  * **footer**: A list of paths to footer files containing HTML text.
  * **footerText**: A list of paths to text files for optional text next to the package name and version
  * **header**:  A list of paths to header files containing HTML text.
  * **include**:  Specify a list of library names to generate docs for, ignoring all others.
  * **includeExternal**:  Specify a list of library filenames to add to the list of documented libraries.
 
### Categories

You can tag libraries in their documentation with the string `{@category YourCategory}`, and
that will cause the library to appear in a category when showing the sidebar on the Package
and Library pages.

```dart
/// Here is my library.
/// 
/// {@category Amazing}
library my_library;
```

### Macros

You can specify "macros", i.e. reusable pieces of documentation. For that, first specify a template
anywhere in the comments, like:

```
/// {@template template_name}
/// Some shared docs
/// {@endtemplate}
```

and then you can insert it via `{@macro template_name}`, like

```
/// Some comment
/// {@macro template_name}
/// More comments
```

Template definitions are currently unscoped -- if dartdoc reads a file containing a template, it can be used in anything
dartdoc is currently documenting.  This can lead to inconsistent behavior between runs on different
packages, especially if different command lines are used for dartdoc.  It is recommended to use collision-resistant
naming for any macros by including the package name and/or library it is defined in within the name.

### Auto including dependencies

If `--auto-include-dependencies` flag is provided, dartdoc tries to automatically add
all the used libraries, even from other packages, to the list of the documented libraries.

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
