# Tests

Most of dartdoc's tests are large end-to-end tests which read real files in
real packages, in the `testing/` directory. Unit tests exist in `test/unit/`.

Many of the end-to-end test cases should be rewritten as unit tests.

At some point, the distinction should flip, such that unit tests are generally
located in `test/`, and end-to-end tests are found in a specific directory, or
in files whose names signify the distinction.
