#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

# Get the Dart SDK (only for travis-ci.org; otherwise, assume that Dart is already available).
if [ "$TRAVIS" = "true" ]; then
  DART_DIST=dartsdk-linux-x64-release.zip
  curl http://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/$DART_DIST > $DART_DIST
  unzip $DART_DIST > /dev/null
  rm $DART_DIST
  export DART_SDK="$PWD/dart-sdk"
  export PATH="$DART_SDK/bin:$PATH"
fi

# Display installed versions.
dart --version

# Get our packages.
pub get

# Verify that the libraries are error free.
dartanalyzer --fatal-warnings \
  bin/dartdoc.dart \
  lib/dartdoc.dart \
  test/all.dart

# Run the tests.
dart test/all.dart

# Gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate dart_coveralls
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    test/all.dart
fi

# Globally install grinder.
pub global activate grinder
export PATH=~/.pub-cache/bin:$PATH

# Run dartdoc.
pub global run grind test
