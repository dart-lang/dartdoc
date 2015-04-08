# dartdoc

A documentation generator for Dart.

[![Build Status](https://travis-ci.org/dart-lang/dartdoc.svg)](https://travis-ci.org/dart-lang/dartdoc)
[![Coverage Status](https://img.shields.io/coveralls/dart-lang/dartdoc.svg)](https://coveralls.io/r/dart-lang/dartdoc)

Note: This tool is currently in alpha stage.

## Running dartdoc

### Generating documentation for a package

Run `dartdoc` from the root directory of package. `dartdoc` produces HTML files as documentation for the 
`.dart` files it finds in the package. The documentation is output to the `docs` directory.

### Generating documentation for Dart SDK

Run `dartdoc` with the following command line arguments:

- `--dart-sdk /pathTo/dart-sdk`
- `--sdk-docs`
- `--readme /pathTo/sdk_readme.md`

The documentation for the SDK will be generated in the `docs` folder of the current directory.

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

## License

You can view our license
[here](https://github.com/dart-lang/dartdoc/blob/master/LICENSE).

[issues]: https://github.com/dart-lang/dartdoc/issues
