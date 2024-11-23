#!/bin/bash

# Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Fast fail the script on failures, and echo commands as they execute.
set -ex

DART_VERSION=`dart --version 2>&1 | awk '{print $4}'`

if [ "$DARTDOC_BOT" = "sdk-docs" ]; then
  # Build the SDK docs
  # silence stdout but echo stderr
  echo ""
  echo "Building and validating SDK docs..."
  dart run task validate sdk-docs
  echo "SDK docs process finished"
elif [ "$DARTDOC_BOT" = "flutter" ]; then
  echo "Running flutter dartdoc bot"
  dart run task doc flutter
elif [ "$DARTDOC_BOT" = "packages" ]; then
  echo "Running packages dartdoc bot"
  dart run task doc package --name=access --version=">=3.0.0"
  # Negative test for flutter_plugin_tools, make sure right error message is displayed.
  dart run task doc package --name=flutter_plugin_tools --version=">=0.0.14+1" 2>&1 | grep "warning: package:flutter_plugin_tools has no documentable libraries"
else
  echo "Running main dartdoc bot"
  dart run task buildbot
fi
