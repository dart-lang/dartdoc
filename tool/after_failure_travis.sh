#!/bin/bash

# Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
# for details. All rights reserved. Use of this source code is governed by a
# BSD-style license that can be found in the LICENSE file.

# Echo commands as they execute.
set -x

# Display backtrace for a single core.
function do_core() {
  local corefile="$1"

  echo "Processing core file: $corefile"
  gdb -c "$corefile" -ex "thread apply all bt" -ex "set pagination 0" -batch
}

# Find core files in likely locations for dartdoc.
if uname | grep -q Linux ; then
  COREFILES=$(find . -type f -name "core*" 2>/dev/null | egrep -v '(.yaml|.dart|.expect|.gni)$') # find core files
  COREFILES_TMP="$(cd /tmp ; find . -type f -name "core*" 2>/dev/null | egrep -v '(.yaml|.dart|.expect|.gni)$')"
  for f in ${COREFILES} ; do {
    do_core "$f"
  } ; done
  for f in ${COREFILES_TMP} ; do {
    do_core "/tmp/$f"
  } ; done
fi

