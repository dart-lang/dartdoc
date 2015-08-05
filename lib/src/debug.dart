library debugger_helper;

import "dart:developer" as dev;

get debugger =>
    const String.fromEnvironment('DEBUG') == null ? _nodebugger : dev.debugger;
_nodebugger({when, message}) {}
