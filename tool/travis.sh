#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

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
  echo "Building and validating SDK docs..."
  grind build-sdk-docs
  grind validate-sdk-docs
  echo "SDK docs process finished"
else
  echo ""
  echo "Skipping SDK docs, because GEN_SDK_DOCS is $GEN_SDK_DOCS"
  echo ""

  # Verify that the libraries are error free.
  grind analyze

  # Run dartdoc on test_package.
  (cd testing/test_package; dart -c ../../bin/dartdoc.dart)

  # checks the test_package results
  grind check-links

  # And on test_package_small.
  (cd testing/test_package_small; dart -c ../../bin/dartdoc.dart)

  # Run the tests.
  grind test
fi
