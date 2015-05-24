#!/bin/bash

# Copyright (c) 2014, Google Inc. Please see the AUTHORS file for details.
# All rights reserved. Use of this source code is governed by a BSD-style
# license that can be found in the LICENSE file.

# Fast fail the script on failures.
set -e

$(dirname -- "$0")/ensure_dartfmt.sh

# Globally install grinder.
pub global activate grinder
export PATH="$PATH":"~/.pub-cache/bin"

# Verify that the libraries are error free.
grind analyze

# Run dartdoc on ourself.
grind test-dartdoc

# Build the SDK docs
# silence stdout but echo stderr
echo "Building SDK docs..."
grind build-sdk-docs 2>&1 >/dev/null | echo

# Another smoke test: Run dartdoc on test_package.
cd test_package
dart -c ../bin/dartdoc.dart
cd ..

# Run the tests.
grind test

# Gather and send coverage data.
if [ "$REPO_TOKEN" ]; then
  pub global activate --source git https://github.com/kevmoo/dart_coveralls_hacking.git
  pub global run dart_coveralls report \
    --token $REPO_TOKEN \
    --retry 2 \
    --exclude-test-files \
    --debug \
    test/all.dart
fi
