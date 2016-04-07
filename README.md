# dartdoc

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg?branch=master)](https://travis-ci.org/dart-lang/dartdoc)

Use `dartdoc` to generate HTML documentaton for your Dart package.

For informtion about contributing to the dartdoc project, see the [contributor docs][].

## Installing dartdoc

### From the Dart SDK

[Download the Dart SDK](https://www.dartlang.org/downloads/); if not already added,
add the SDK's `bin` directory to your `PATH`.

### From pub.dartlang.org

You can install the latest version of dartdoc with `pub`:

    $ pub global activate dartdoc

Note: to ensure that this version is run when you type `dartdoc` on the command
line, make sure that `~/.pub-cache/bin` is on your `PATH`, and before the path
to the Dart SDK.

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

### Link structure

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

### Excluding from documentation

`dartdoc` will not generate documentation for a Dart element and its children that
has the `<nodoc>` tag in the documentation comment.

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][].

## License

Please see the [dartdoc license][].

[GitHub Issue Tracker]: https://github.com/dart-lang/dartdoc/issues
[contributor docs]: https://github.com/dart-lang/dartdoc/blob/master/CONTRIBUTING.md
[dartdoc license]: https://github.com/dart-lang/dartdoc/blob/master/LICENSE
