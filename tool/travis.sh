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
grind docitself

# Another smoke test: Run dartdoc on fake_package.
cd test/fake_package
dart ../../bin/dartdoc.dart
cd ../..

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
