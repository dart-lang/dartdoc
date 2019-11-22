# dartdoc examples

Dartdoc is typically used as a command line utility to support generating
documentation served on websites.  In the future this directory may contain
direct examples, but for now, here are pointers to the main users of dartdoc
in the Dart ecosystem.

## Dart SDK

The Dart team builds docs for the [Dart API reference](https://api.dart.dev/)
with each new version of the SDK, via
[this script](https://github.com/dart-lang/sdk/blob/master/tools/bots/dart_sdk.py).
Look for `BuildDartdocAPIDocs`.

## Flutter

The Flutter team builds [API documentation for the Flutter SDK](https://api.flutter.dev)
automatically.  A [shell script](https://github.com/flutter/flutter/blob/master/dev/bots/docs.sh)
wraps a [small dart program](https://github.com/flutter/flutter/blob/master/dev/tools/dartdoc.dart)
that manages the process.

## pub

The [pub package website](https://pub.dev) automatically builds Dart
[API documentation](https://pub.dev/documentation/dartdoc/latest/)
for [uploaded packages](https://pub.dev/packages/dartdoc).

Note, unlike the other two examples, here dartdoc is used as a library.  While we make some
effort not to regularly break simple uses of the library interface, we strongly recommend
you use the command line and focus our semantic versioning around that case.   However, if
that doesn't work for your case, the pub site usage may be of interest.  See
[this script](https://github.com/dart-lang/pub-dev/blob/master/pkg/pub_dartdoc/bin/pub_dartdoc.dart)
for the entry point.