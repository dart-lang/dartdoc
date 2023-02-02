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

## Manual testing

We have not set up programmatic tests for the behavior of the front-end. Two
areas of complexity which should be tested for any front-end change are:

1. Search - this includes the search box at the top right of the desktop view,
   the search box in the mobile view, and the search results in the
   `search.html` page.
2. "Base href" - This is complicated. But documentation for some code makes
   use of the `base` HTML element, and some does not, as determined by the
   `data-using-base-href` attribute on the `body` tag. Some URLs are constructed
   using this attribute, so manual testing must include a case where it is used,
   and a case where it is not.

For the "base-href" behavior, you can manually test with the following grinder
commands:

1. `dart run grinder serve-test-package-doc` - This serves the docs for the
   `testing/test_package` package at http://localhost:8002/. The "base href"
   settings result in a `body` tag like:
   `<body data-base-href data-using-base-href="false">`.

2. `dart run grinder serve-pub-package` - This serves the docs for a pub
   package at http://localhost:9000/. Environment variables are used to pass the
   package name and version. For example:
   `PACKAGE_NAME=collection PACKAGE_VERSION=1.17.0 dart run grinder serve-pub-package`.
   The "base href" settings result in a `body` tag like:
   `<body data-base-href="./" data-using-base-href="false">`. Serving up a
   package's docs gives the opportunity for many search results.

   The trick here is to test on different pages, which should change that
   `data-base-href` attribute to different values. I think typically the value
   is `"../"` on a library page or library member page, and `"../../"` on a
   library member's member page (like a constructor of a class).

3. `flutter pub run grinder serve-flutter-docs` (warning: takes a crazy long time)
   - This serves the docs for Flutter at http://localhost:8001/. The "base
   href" settings result in a `body` tag like:
   `<body data-base-href data-using-base-href="true">` and a `base` tag in the
   `head` like `<base href="./flutter/">`.

   TODO(srawlins): Yikes that flutter step is too expensive. Figure out a simple
   grinder task for using "base href" with a simple package.