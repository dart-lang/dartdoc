#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures, and echo commands as they execute.
set -ex

# add globally activated packages to the path
export PATH="$PATH":"~/.pub-cache/bin"
DART_VERSION=`dart --version 2>&1 | awk '{print $4}'`
# Do not run coverage on non-dev builds or non-Linux platforms.
if ! echo "${DART_VERSION}" | grep -q dev || ! uname | grep -q Linux ; then
  unset COVERAGE_TOKEN
fi

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
  if [ ${DART_VERSION} != 2.2.0 ] ; then
    PACKAGE_NAME=angular PACKAGE_VERSION=">=5.1.0" DARTDOC_PARAMS="--include=angular,angular.security" pub run grinder build-pub-package
  else
    PACKAGE_NAME=angular PACKAGE_VERSION=">=5.0.0-beta <5.1.0" DARTDOC_PARAMS="--include=angular,angular.security" pub run grinder build-pub-package
  fi
  PACKAGE_NAME=access PACKAGE_VERSION=">=1.0.1+2" pub run grinder build-pub-package
  # Negative test for flutter_plugin_tools, make sure right error message is displayed.
  PACKAGE_NAME=flutter_plugin_tools PACKAGE_VERSION=">=0.0.14+1" pub run grinder build-pub-package 2>&1 | grep "dartdoc failed: dartdoc could not find any libraries to document.$"
  PACKAGE_NAME=shelf_exception_handler PACKAGE_VERSION=">=0.2.0" pub run grinder build-pub-package
elif [ "$DARTDOC_BOT" = "sdk-analyzer" ]; then
  echo "Running all tests against the SDK analyzer"
  unset COVERAGE_TOKEN
  pub run grinder test-with-analyzer-sdk
else
  echo "Running main dartdoc bot"
  pub run grinder buildbot
  if [ -n "$COVERAGE_TOKEN" ] ; then
    coveralls-lcov --repo-token="${COVERAGE_TOKEN}" lcov.info
  fi
fi
