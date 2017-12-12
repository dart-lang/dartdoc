#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures, and echo commands as they execute.
set -ex

# add globally activated packages to the path
export PATH="$PATH":"~/.pub-cache/bin"

if [ "$DARTDOC_BOT" = "sdk-docs" ]; then
  # Build the SDK docs
  # silence stdout but echo stderr
  echo ""
  echo "Building and validating SDK docs..."

  pub run grinder validate-sdk-docs

  echo "SDK docs process finished"
elif [ "$DARTDOC_BOT" = "flutter" ]; then
  echo "Running flutter dartdoc bot"

  pub run grinder build-flutter-docs
else
  echo "Running main dartdoc bot"

  # Verify that the libraries are error free.
  pub run grinder analyze

  # Run dartdoc on test_package.
  (cd testing/test_package; dart -c ../../bin/dartdoc.dart)

  # And on test_package_small.
  (cd testing/test_package_small; dart -c ../../bin/dartdoc.dart)

  # Run the tests.
  pub run test
fi
