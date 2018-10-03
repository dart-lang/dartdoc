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
  pub run grinder validate-flutter-docs
elif [ "$DARTDOC_BOT" = "packages" ]; then
  echo "Running packages dartdoc bot"
  PACKAGE_NAME=angular PACKAGE_VERSION=">=5.0.0-beta" DARTDOC_PARAMS="--include=angular,angular.security" pub run grinder build-pub-package
elif [ "$DARTDOC_BOT" = "sdk-analyzer" ]; then
  echo "Running main dartdoc bot against the SDK analyzer"
  DARTDOC_GRIND_STEP=buildbot pub run grinder test-with-analyzer-sdk
else
  echo "Running main dartdoc bot"
  pub run grinder buildbot
fi
