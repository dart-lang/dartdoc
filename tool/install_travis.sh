#!/bin/bash

# Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Echo commands as they execute.
set -x

if uname | grep -q Linux ; then
  sudo gem install coveralls-lcov
  coveralls-lcov --help
fi

exit 0
