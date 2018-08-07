#!/bin/bash

# bail on error
set -e

echo "Analyzing with `dartanalyzer --version`"
dartanalyzer="dartanalyzer --strong --fatal-warnings lib/*.dart test/*.dart"
if [ "$TRAVIS_DART_VERSION" = "dev" ]; then
  dartanalyzer="$dartanalyzer --preview-dart-2"
fi
$dartanalyzer

pub deps

# run the tests
pub run test

# Only run with the stable version of dart.
if [ "$TRAVIS_DART_VERSION" = "stable" ]; then
  pub global activate dart_style
  dirty_code=$(pub global run dart_style:format --dry-run lib/ test/ example/)
  if [[ -n "$dirty_code" ]]; then
    echo Unformatted files:
    echo "$dirty_code" | sed 's/^/    /'
    exit 1
  else
    echo All Dart source files are formatted.
  fi

  # Install dart_coveralls; gather and send coverage data.
  if [ "$COVERALLS_TOKEN" ]; then
    pub global activate dart_coveralls
    pub global run dart_coveralls report \
      --retry 2 \
      --exclude-test-files \
      test/mustache_all.dart
  fi


  pub run test -p chrome,firefox
fi
