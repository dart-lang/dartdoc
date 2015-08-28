#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

pub global activate grinder

pub global activate dart_style

# add globally activated packages to the path
export PATH="$PATH":"~/.pub-cache/bin"

if [ "$GEN_SDK_DOCS" = "true" ]
then
 # Build the SDK docs
  # silence stdout but echo stderr
  echo ""
  echo "Building SDK docs..."
  grind build-sdk-docs
  echo "SDK docs process finished"
else
  echo ""
  echo "Skipping SDK docs, because GEN_SDK_DOCS is $GEN_SDK_DOCS"
  echo ""

  $(dirname -- "$0")/ensure_dartfmt.sh

  # Verify that the libraries are error free.
  grind analyze

  # Run dartdoc on test_package.
  cd test_package
  dart -c ../bin/dartdoc.dart
  cd ..

  # checks the test_package results
  grind check-links

  # And on test_package_small.
  cd test_package_small
  dart -c ../bin/dartdoc.dart
  cd ..

  # Run the tests.
  grind test

  # Gather and send coverage data.
  if [ "$REPO_TOKEN" ]; then
    pub global activate dart_coveralls
    pub global run dart_coveralls report \
      --token $REPO_TOKEN \
      --retry 2 \
      --exclude-test-files \
      test/all.dart
  fi

  # Push a copy of the dartdoc docs to firebase.
  # This was timing out
  # grind firebase
fi
