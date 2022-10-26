# Tests

Many of dartdoc's tests are large end-to-end tests which read real files in
real packages, in the `testing/` directory. These tests are found in
`test/end2end/`. Smaller unit tests are found in `test/` and other
subdirectories.

Many of the end-to-end test cases are being rewritten as unit tests. Eventually,
the content in the `testing/` directory should dwindle down to very targeted
tests which cannot be rewritten as unit tests.

There are some end-to-end tests which would require a serious refactoring of the
implementation in order to migrate to unit tests, such as any "tool" test
(testing the `{@tool}` directive).