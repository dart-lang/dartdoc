// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library debugger_helper;

import "dart:developer" as dev;

get debugger =>
    const String.fromEnvironment('DEBUG') == null ? _nodebugger : dev.debugger;
_nodebugger({when, message}) {}
