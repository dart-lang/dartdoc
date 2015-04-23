# dartdoc

A documentation generator for Dart. This tool produces static HTML files,
produced from Dart source code.

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg)](https://travis-ci.org/dart-lang/dartdoc)
[![Coverage Status](https://img.shields.io/coveralls/dart-lang/dartdoc.svg)](https://coveralls.io/r/dart-lang/dartdoc)

Note: This tool is currently in alpha stage.

## Installing dartdoc

Run `pub global activate dartdoc` to install the `dartdoc` tool.

## Running dartdoc

### Generating documentation for a package

Run `dartdoc` from the root directory of package. By default, the documentation
is output to the `docs` directory. You can use `--output` to specify the output directory.

### Generating documentation for Dart SDK

Run `dartdoc` with the following command line arguments:

- `--dart-sdk /pathTo/dart-sdk`
- `--sdk-docs`
- `--sdk-readme /pathTo/sdk_readme.md`

The `sdk-readme` is found in the SDK source repo. Specifically, `$DART_SDK_SOURCE/dart/sdk/api_readme.md`.
In the future, this file might be included in an SDK distribution (see https://code.google.com/p/dart/issues/detail?id=23203).

## FAQ

#### What about docgen/dartdocgen/dartdoc-viewer?
This new tool intends to replace our existing set of API documentation
tools. We'll take the best ideas and implementations from our existing doc
tools and fold them into this tool.

#### Can I help?
Yes! Start by using the tool and filing issues and requests. If you want
to contribute, check out the [issue tracker][issues] and see if there's an issue
that you're passionate about. If you want to add a new feature that's not
yet in the issue tracker, start by opening an issue. Thanks!

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][issues].

## Developing

### Publishing to pub

It's easy to publish to pub. The following command will bump the build version
and run `pub publish`.

`grinder publish`

## License

You can view our license
[here](https://github.com/dart-lang/dartdoc/blob/master/LICENSE).

[issues]: https://github.com/dart-lang/dartdoc/issues
