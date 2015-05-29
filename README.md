# dartdoc

A documentation generator for Dart. This tool creates static HTML files
generated from Dart source code.

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg)](https://travis-ci.org/dart-lang/dartdoc)
[![Build status](https://ci.appveyor.com/api/projects/status/s6sh69et2ga00dlu?svg=true)](https://ci.appveyor.com/project/devoncarew/dartdoc)
[![Coverage Status](https://img.shields.io/coveralls/dart-lang/dartdoc.svg)](https://coveralls.io/r/dart-lang/dartdoc)

## Installing dartdoc

Run `pub global activate dartdoc` to install `dartdoc`.

## Running dartdoc

Run `dartdoc` from the root directory of package. By default, the documentation
is geterated to the `doc/api/` directory.

## FAQ

#### What about `docgen` / `dartdocgen` / `dartdoc-viewer`?
This tool intends to replace our existing set of API documentation tools. We'll
take the best ideas and implementations from our existing doc tools and fold
them into `dartdoc`.

#### Can I help?
Yes! Start by using the tool and filing issues and requests. If you want to
contribute, check out the [issue tracker][issues] and see if there's an issue
that you're passionate about. If you want to add a new feature that's not yet in
the issue tracker, start by opening an issue. Thanks!

#### Generating documentation for Dart SDK

If you want to generatr documentation for the SDK, run `dartdoc` with the
following command line arguments:

- `--dart-sdk /pathTo/dart-sdk` (optional)
- `--sdk-docs`

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][issues].

## License

You can view our license
[here](https://github.com/dart-lang/dartdoc/blob/master/LICENSE).

[issues]: https://github.com/dart-lang/dartdoc/issues
