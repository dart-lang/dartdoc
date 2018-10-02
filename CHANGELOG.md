## 0.21.2
* Fix incompatibility with head analyzer (endsWith exception). (#1768)
* Documentation updates. (#1760)

## 0.21.1
* Fix a problem where category ordering specified in categories option
  was not obeyed.  Reintroduce categoryOrder option to solve this problem.

## 0.21.0
* Expand categories to all top level items as well as libraries.  (#1681, #1353)
* The categoryOrder option in dartdoc_options.yaml and the command line
  is replaced with a more generic "categories" option.  See README.md.

## 0.20.4
* Hide pragma declarations from generated docs (#1726)
* Fix problems with lists in markdown not being handled correctly (#172)
* Properly escape types inside comment references (#1740)
* Generate a custom page, `__404error.html`, for use as an error page (#1704)
* Generate an error on unresolved exports instead of crashing (#1745)
* Generate anchors for headers in markdown (#1749)

## 0.20.3
* Update dependencies and fork mustache4dart into dartdoc so dartdoc can resolve
  dependencies on Dart 2.0 stable.

## 0.20.2
* Fix void problems (#1724)
* Fix crash building Angular docs and problems involving special objects
  (#1728, #1554)
* Run pub upgrade to get packages ready for 69.2.

## 0.20.1
* Remove name parameter from `@animation` parameter handling, with backwards compatibility
  (#1715)
* Scrollbar width increased for main body text (#1711)
* Make a missing FLUTTER_ROOT environment variable have a better error message
  (#1714)
* Add a missing static resource (#1708)
* Add test to make sure that static resource file is automatically rebuilt
  (#1708)

## 0.20.0
* include and exclude are now available in dartdoc_options.yaml as supported options
  (#1700, #1674)
* Support a new `{@animation}` directive in documentation comments to display
  videos in a simple player.
* Fix Dart 2.0 support (#1668) and expand test coverage to include --help.

## 0.19.1
* Update `package:markdown` to `2.0.0`, which includes many improvements –
  especially to the parsing of links.
* Update analyzer to 0.32.0, mustache4dart to 2.1.2, and grinder for 0.8.2 for Dart 2 fixes.
* Fix bug where --version printed help instead of the version number. (#1692)
* Switch dartdoc_test to an integration test and add basic Dart 2.0
  integration tests.
* Do not crash on unversioned packages (#1688).

## 0.19.0
* Build documentation through the Package object (#1659)
* New flag, --link-to-remote, which will cause Dartdoc to link symbols to their originating
  pub packages and/or the Flutter or Dart SDKs. (#739)
* New configuration refactor and addition of several experimental options in dartdoc_options.yaml
  (see README).
* Update analyzer version to 0.31.2-alpha.2 (#1682).

## 0.18.1
* Fix problems with the embedded SDK detection that cropped up in
  the package refactor (#1648, #1651)
* Fix issues with anonymous functions and type parameters (#1651)
* Add Menlo to the monospace font list to improve table
  formatting (#1647)

## 0.18.0
* Rename category_order flag to package_order. (#1634, #1636)
* Use Google's CDN for jquery. (#1637)
* Add the beginning of support for a dartdoc_options.yaml file. (#1638)
* Code cleanups and refactoring related to packages (#1639, #1636)
* Enable --preview-dart-2 in analyzer (#1630)
* Add basic categorization for libraries (#1641)

## 0.17.1+1
* Fix pub warning regarding unnecessary meta import.

## 0.17.1
* Fix rendering of bold markdown (#1618)
* Internal cleanups and refactors (#1626, #1624, #1622)
* Support void as a type parameter (#1625)

## 0.17.0
* More correctly deal with indentation inside documentation comments,
  fixing a set of minor markdown problems relating to indentation (like list
  handling) (#1608, #1507)
* Strong mode enabled in dartdoc -- dartdoc will no longer read code
  that isn't strong-mode clean beginning with this version. (#1561)
* Add a negatable flag (default on), --validate-links, to control whether
  Dartdoc's built-in link checker runs. (#1607)
* dartdoc now works in checked mode for Flutter, fixing some edge-case
  navigation/canonicalization problems.  (#1606)
* Dartdoc now uses AnalysisDriver to build the element tree.  (#1601, #1586)
* Grinder now has arbitrary serving of pub packages and can compare
  warnings from different versions (#1600, #1599)

## 0.16.0
* Cherrypick test changes from 0.15.1 and a fix for (#1603), updating
  dartdoc to the latest analyzer.

## 0.15.1
* Add SDK warning comparison to grind script (#1572)
* Improve rendering of inline `<code>` (#1573)
* Rename "Source Code" to "Implementation" (#1580)
* Make page titles more prominent (#1581)
* Detect macros declared in non-public symbols (#1584)
* Const value cosmetic improvements with some restored linking (#1585)
* Update to latest versions of args, resource, grinder (#1566, #1579)
* Update to grinder scripts to serve flutter, SDK, and the test
  package locally for testing (#1570, #1578)

## 0.15.0+1
* Move sdk_footer_text to resources directory for compatibility
  with SDK build system (#1563)

## 0.15.0
* Breaking change: Major internal refactoring of public/private,
  type definitions, templates, and warnings.   (#1524, #1539)
* Breaking change: Allow mixins that call their super-classes. (#1555)
* Breaking change: Anonymous libraries are now laid out on disk
  differently to avoid conflicts (#1526)
* Breaking change: The meaning of --auto-include-dependencies has changed to
  include all libraries in any package depended on by this package (determined
  by the .packages file) (#1524)
* Breaking change: The meaning of --include and --exclude has changed to
  require import paths for anonymous libraries, and accept them for other
  libraries. (#1524)
* The Interceptor class from the SDK is now cloaked (#1524)
* Type parameters for classes now appear next to them on the library page
  (#1558)
* GFM-style tables are now supported in Dartdoc markdown (#1557, #1453)
* Navigation and constructor docs now show generic types in more places
  (#1556, #1453)
* A new parameter, --exclude-packages, now enables dartdoc to hide entire
  packages from --auto-include-dependencies or other --include options.
* Document correct parameters for new-style generic function types
  (#1472)
* Allow super in mixins (#1541)
* Source code included with docs highlights again (#1525)
* Remove constant value linking via string substitution (#1535)
* Update version of mustache4dart and fix minor template errors (#1540)
* Eliminate remaining places where dartdoc exposed private interfaces
  (#1173)
* Fix private super classes appearing with dead links (#1476)
* Fix resolution of generic types (#1514)
* Limit width of code blocks (#1522)
* Add a `--json` flag to providing logging in a machine-readable format.
  (#1531)
* Use the logging package for dartdoc output. (#1518)
* Remove cc commons license text from default footer (#1262)

## 0.14.1
* Add better support for GenericFunctionTypeElementImpl (#1506, #1509)
* Fix up dartdoc so it can be used with the head analyzer again (#1509)
* SDK constraint fixed (#1503)

## 0.14.0
* Fix multiple issues with properties and top level variables in cases
of split inheritance (#1394, #1116)
* Fix issue with generation of 'null' value enum fields (#1445)
* Fix multiple issues with nodoc handling (#1352, #1337)
* Use highlight js for code blocks and fix colors (#1487)
* Eliminate excessive stack depth in link checker
* Use preferredClass in more cases to disambiguate doc links
* Add basic support and tests for MultiplyInheritedExecutableElements (#1478)

## 0.13.0+3
* Add support for GenericFunctionTypeElementImpl (#1495)

## 0.13.0+2
* Allow null annotation elements (#1491)

## 0.13.0+1
* Remove unnecessary dependency on meta.
* Drop --force from pub publish arguments to avoid publishing more broken
  packages.

## 0.13.0
* Fixed case where inherited members could be linked to the wrong mixin (#1434)
* Added broken link detection to the search index.
* Avoid parsing markdown for ModelElements unless we're actually going to use
  the docs, speeding up generation overall by ~10% (#1417)
* Add annotations to parameter documentation (#1432)
* Change dartdoc style to use multiple independent scrolling columns (#1350)
* Add scoring for ambiguous canonicalization, and a new comment directive,
  canonicalFor, to override its decisions (#1455)
* Add a hidden flag to drop text in docs imported from the SDK, and use this
  flag in the integration test to make that test less fragile (#1457)
* Add link to package homepage from index (#1460)

## 0.12.0
* Generation performance improved from 20-65% on large packages (more improvement on packages
  with lower usage of comment references and complex inheritance chains, like angular2).
* Improvements to warnings, including indicating referring elements where possible. #1405
* Enable support for generic function types.  #1321
* Update analyzer to 0.30.  #1403
* Enhancements to css style to better match dartlang.org.  #1372 (partial)

## 0.11.2
* Fix regression where warnings generated by the README could result in a fatal exception.  #1409

## 0.11.1
* Fix regression where a property or top level variable can be listed twice
  under some conditions.  #1401

## 0.11.0

* Fix resolution of ambiguous classes where the analyzer can help us. #1397
* Many cleanups to dartdoc stdout/stderr, error messages, and warnings:
  * Display fatal errors with 'fatal error' string to distinguish them from ordinary errors
  * Upgrades to new Package.warn system.
    * Fully integrated all scattered "warnings" (#1369) and added new ones for the link checker.
    * Allow for setting which warnings are errors in the library.
    * Change location output to something IntelliJ can understand and link to
    * Display location output for all warnings including line number plus column, when available
      from analyzer (still some bugs in our resolution). It still doesn't do code references quite
      right but at least gets you to the neighborhood.
    * Add a warn method to ModelElements so they can warn on themselves without help from the
      Package.
    * Warn correctly and squelch duplicates across doc inheritance and canonicalization almost
      everywhere.
    * Change --show-warnings to show all warnings, even those that might not be useful yet.
  * Display a count of all warnings/errors after document generation.
  * Make the progress counter tick slower.
* Added a built-in link checker and orphaned file checker, and tied it into Package.warn so
  that when debugging dartdoc we can breakpoint and discover what about that ModelElement
  caused us to create the broken link. (#1380)
* Fix bug where canonicalEnclosingElement could return a non-canonical Class.
* Fix bug where findCanonicalModelElementFor could return a non-canonical Class.
* Fix overriddenElement for Accessors to generate using enclosingCombo hint to ModelElement factory.
* Fix fullyQualifiedNameWithoutLibrary when periods are part of the library name.
* Add an allModelElements for Classes to support comment references.
* Make allModelElements for Libraries work using Class.allModelElements recursively.
* Squish some bugs related to duplicate logic for instantiating inherited class members.
  * Enum and a few other places could still generate duplicate ModelElements for the
    same thing.  This is now fixed.
  * EnumField is now handled by ModelElement.from factory, fixing #1239.
  * Added hints for EnumField and Accessors (index, enclosingCombo) to offload the buggy
    logic for figuring this out from callers to ModelElement.from.
* Fix broken link generation when a canonical class's defining library isn't canonical.
* Partial rewrite of GetterSetterCombo and Fields/TopLevelVariable handling
  * Link correctly to generic types for Fields/TopLevelVariables.
  * Use right, left, and bidirectional arrows for read-only, write-only, and read-write
    parameters.
* Partial rewrite of comment reference system (#1391, #1285 partial)
  * Handle gracefully a variety of things users try in the real world, like prefixing operators
    with 'operator', embedded newlines in comment references, and cases that shouldn't be
    considered at all (comment refs that are really array references in sample docs, etc).
  * Handle canonicalization correctly for comment references: point to the right places and
    only to canonical elements.
  * In general, warnings related to comment references should be much more useful now. (#1343)
    * Many fewer ambiguous doc reference warnings now and the ones that exist should be more
      easily understandable and fixable with the new warning message.
    * Understand references to parameters even though we don't do anything useful with them just yet
    * Generics outside square brackets (#1250) are now warned with better context information that
      takes newlines into account, but there are so many of them in complex packages like Flutter
      that we still only show those with --show-warnings.
  * Cache the traversal of allModelElements.
  * Change handling of enum constant linking in codeRefs to work properly, though warnings about
    that aren't right in some edge cases still.
  * Only use analyzer resolving of commentRefs as a last resort since they don't take dartdoc
    canonicalization into account.
* Added a new `--footer-text` command-line option, to allow adding additional
  text in the package name and copyright section of the footer.
* Reduced stack depth by not recomputing findCanonicalLibraryFor. (#1381)
* Workaround for (#1367) forces on enableAssertInitializer.
* Work around analyzer-0.29 bug where embedded SDK uri's aren't properly
  reversed.

## 0.10.0

* fix canonicalization problems and related issues introduced or not addressed
  in 0.9.11, including:
  * (#1361), (#1232), (#1239 (partial))- Broken links in enums
  * (#1345) and (#1090)- Reexports have wrong links in many places
  * (#1341), (#1197 (partial)) - Duplicate docs still in some cases
  * (#1334) - Some classes don't list their subclasses
  * Inheritable class members had incorrect canonicalization in many cases
  * ... and many other unfiled bugs relating to inheritance and duplicate files.
* Dartdoc no longer creates documentation for a given identifier more than once.
  This means dartdoc is 20-30% faster on complex packages.
* --auto-include-dependencies is now recursive past one layer (#589) It now drills
  all the way down and will dive into the SDK and other packages.
* Change display of warnings to be more consistent; warnings now always
  go to stderr and are printed on their own line.
* Dartdoc now warns when it is unable to find a canonical object to link to
* Dartdoc now warns if a package exports an identifier so that it is
  ambiguous which one should be treated as canonical
* Dartdoc now has a number of asserts in checked mode for issues solved
  and as-yet-unsolved, including (#1367) or canonicalization problems; try
  running in checked mode if you see structural problems in generated docs and
  see if an assert fires.
* Dartdoc internals have changed significantly:
  * Package now owns the calculation of recursive dependencies with a factory
    constructor, Package.withAutoincludedDependencies.
  * ModelElements and Libraries now have Package-scoped caches.
  * ModelElements and their subclasses now must be constructed from a single
    factory, ModelElements.from
  * Package has new methods to assist canonicalization, including
    findCanonicalLibraryFor and findCanonicalModelElementFor.
  * New mixin "Inheritable" helps class members calculate canonicalization
    for inheritable members
* change order of library, class, and enum members on displayed pages (#1323).
* change order of categories when using --use-categories, prioritizing
  this package first, the SDK second, packages with this package's name
  embedded third, and finally all other packages.  A new flag,
  --category-order, lets you change what order categories appear in. (#1323)
* fix broken masthead links in enums (#1225).

## 0.9.14-dev

This is a prerelease only, features listed as added here don't carry forward.

* Enable support for generic function types (#1321)

## 0.9.13

* fix grind check-links and check-sdk-links (#1360)
* fix multiple issues in annotation/feature list handling (#1268, #1162, #1081)
* Added `pretty-index-json` command line flag.
* `index.json` file entries are now sorted.

## 0.9.12

* add print styles
* fix for resolving references in comments (#1328)

## 0.9.11

* add annotations to features line for methods, properties, constants (#1265)
* fixed an issue where the search box wasn't selecting the correct result (#1330)

## 0.9.10
* de-emphasize and resort the inherited members (#641)
* fix bug with showing parameterized typdefs in return types of properties (#1263)
* add macros support, to help reuse documentation (#1264)
* de-emphasize reexported symbols in generated docs (#1158)
* fix for angular2 docs generation (#1315)
* generate warnings for generics not in `[]` in the documentation (#1250)
* Add support for stripping schema from display text for urls defined with
  brackets (#1147)

## 0.9.9
* resolve non-imported symbols in comments (#1153) - thanks @astashov!
* support `@example` insertion of .md file fragments (#1105) - thanks @chalin!
* go to the first suggestion in the search field on enter (#1149)
* rank parent class method higher than its overrides in search suggestions (#896)
* fix double props when inherited from parameterized class (#1228)
* add showing docs of overridden accessors (#1266)

## 0.9.8+1
* change the `--include-external` flag to help disambiguate files to include (#1236)

## 0.9.8
* support for generic methods.
* remove deps on cli_utils and which.
* removed some uses of deprecated analyzer APIs

## 0.9.7+6
* fixed an issue with generating docs with crossdart links.

## 0.9.7+5
* update Markdown dependency to 0.11.1.

## 0.9.7+4
* fixed an issue with documenting libraries starting with `packages`
* upgraded our dependency on `html` to 0.13.0
* upgraded our dependency on `package_config` and `markdown`

## 0.9.7+3
* Extended package_config dependency to include stable 1.0.0 api.

## 0.9.7+2
* fixed a regression with generating package docs (#1233)

## 0.9.7+1
* change how we truncate long constant values on the summary page
* show the full docs for enums on the summary page; just show the first line of
  docs for other contants

## 0.9.7
* fix the display of long constants
* fixed an issue with duplicate libraries in SDK
* show source code for more element types
* fix for issue with references in parameters and return type pointing to wrong element with same name
* updated to a new verion of the markdown library
* fix signatures for functions with typedef params (#1137)
* make dartdoc strong-mode clean (#1205)
* fix an issue w/ references in dartdoc not being hyperlinked
* show 'abstract' for methods that are abstract
* show the full value of enums
* cleanup bin/dartdoc to use public dartdoc API (#1199)
* add contribution instructions

## 0.9.6+2
* [bug] fix an issue involving escaping constants (#1084).
* [health] removed a dev dependency
* [health] removed check for dartfmt on travis

## 0.9.6+1
* [health] remove an unneeded package dependency
* [enhancement] show the full documentation summary text for elements

## 0.9.6
* [bug] fix enum indexes (#1176).
* [enhancement] added support for crossdart. If there is a `crossdart.json`
  file in the input dir (which can be generated by Crossdart), it will use that
  file to add links to `crossdart.info` in the source code block.

## 0.9.5
* [enhancement] support for `@example` tag to inject sample code into comments.
  eg. `{@example core/ts/bootstrap/bootstrap.dart region='bootstrap'}`, where
  path is path to source in the package examples directory, and region is
  specified by `#docregion` and `#enddocregion` in the file.
* [enhancement] do not document if there is a `@nodoc` in the doc comment.
   NOTE: &lt;nodoc> is now deprecated and will be removed in a later version.

## 0.9.4
* [enhancement] added a `--favicon` option to specify a favicon to use for the
  generated docs
* [enhancement] added a `--use-categories` flag to groups libraries into source
  packages in the overview page and the left-hand side navigation panel

## 0.9.3+1
* [bug] fix an issue with including duplicated libraries

## 0.9.3
* [enhancement] added support for URL-based search. If a query parameter named
  "search" is passed, the page navigates to the first search result for its
  value.
* [enhancement] added support for passing more than one `--header` or `--footer`
* [enhancement] added the ability to include libraries referenced by (but not
  directly inside) the project (`--include-external`)
* [bug] rev the analyzer version used to fix an issue generating docs for
  Flutter

## 0.9.2
* [bug] do not generate docs for `dart:_internal` and `dart:nativewrappers`, when defined
  in the `_embedder.yaml` file.
* [enhancement] print message to run pub if dartdoc does not find any libraries to
  document.

## 0.9.1
* [bug] fix generating docs for packages with _embedder.yaml

## 0.9.0
* **BREAKING** works with Dart SDK 1.14.0 and above
* [health] use package resource
* [enhancement] add support for packages with `_embedder.yaml`
* [bug] fix generating docs when input == '.'
* [bug] modify showing constants so that there is no double `const` shown in
  value.

## 0.8.5
* [enhancement] do not document if there is a &lt;nodoc> in the doc comment.
* [bug]link typdefs when used as parameters
* [bug] fix issue with processing &lt;pre> tags
* [health] run tests only once on travis
* [health] speed up dartdoc with caching and upgrade to latest analyzer package

## 0.8.4
* [enhancement] Only include generator metadata in the package `index.html` file.
* [bug] Fixed the display of deprecated properties.
* [bug] show generics for typedefs
* [bug] cleanly unzip docs on Mac
* [health] upgrade to latest analyzer package

## 0.8.3
* [enhancement] Added `--[no-]include-source` option.
* [enhancement] Dimmed inherited members in the right sidebar.

## 0.8.2
* [bug] fix exception due to change in analyzer, function types in parameters are no
  longer treated as typedefs.

## 0.8.1
* [bug] No longer includes `<base>` element in the package root.
* [bug] Eliminates a number of empty `class` attributes.
* [bug] Show deprecated libraries the same way in both package and library view.
* [bug] Process `readme.md` Markdown with the process that is used in document comments.

## 0.8.0
* [bug] fix annotation shown as raw HTML in constructors
* [bug] fix missing return type when Future
* [enhancement] do not show "Not documented." message for members without doc comments
* [enhancement] show constructors before properties in right side bar
* [enhancement] sort names with embedded integers lexicographically
* **BREAKING** `initGenerators` is now async. It returns `Future<List<Generator>>`.
* **BREAKING** `markdown_processor.dart` and `resource_loader.dart` are no
  longer exposed as public libraries.
  Use of these libraries by third-party code is no longer supported.
* **BREAKING** `generator.dart` is no longer exposed as a stand-alone library.
  You can access the `Generator` class by importing `dartdoc.dart`.

## 0.7.4
* [bug] In class documentation, move constructors before instance properties
* [bug] fix property pages to show documentation if not a setter/getter
* [bug] show indented code blocks in comments as code

## 0.7.3
* [bug] Add missing close `span` in accessor setter template
* [enhancement] Print usage if an invalid argument is provided
* [enhancement] Improve the output of asynchronous stack traces when an
  unhandled exception is thrown
* [health] removed doc uploads to firebase
* [bug] fixed incorrect 'link to Crossdart' links
* [health] upgraded packages, modified pubspec.lock

## 0.7.2
* [bug] do not show '///' in doc output

## 0.7.1
* [enhancement] restore the method signature at the top of
  method/ctor/function/operator pages
* [enhancement] search using fully qualified names
* [enhancement] better messaging when library itself lacks comments
* [enhancement] indicate when a class is an abstract class
* [enhancement] indicate when a constructor is a factory constructor

## 0.7.0
* [feature] --add-crossdart flag to add links to http://crossdart.info in
  the source code section
* [bug] show type information for Map with generics
* [bug] show methods/properties inherited from Object
* [health] remove --url-mappings option, the analyzer picks up SDK extensions
  from the package
* [style] changed how we display constant values

## 0.6.6
* [style] reduce number of fonts and styles used on a page
* [enhancement] do not show method signature for methods with source

## 0.6.5
* [new] --rel-canonical-prefix to help with SEO for many
        versions of the same docs
* [bug] fixed linking in the SDK docs
* [enhancement] do not display comments with actual source code
* [enhancement] show source code for constructors
* [style] tweaks to the footer
* [health] re-enable uploading dartdoc docs to firebase

## 0.6.4
* [upgrade] markdown ^0.8.0
* [health] clean up markdown files
* [enhancement] change callable metadata to be the same as class
* [enhancement] print annotations on separate lines

## 0.6.3
* [bug] remove duplicate property entries
* [enhancement] better distinction between getters and setters for properties
* [enhancement] link inherited elements to superclass pages if available
* [bug] fix README.md not rendering correctly on pub.dartlang
* [health] resume testing on stable channel

## 0.6.2
* Instructions on contributing moved to CONTRIBUTOR.md
* Fixed bug with doc comment with name in both current and imported
  library might be incorrectly linked
* Now linking to detail pages for inherited methods, operators, properties
* Strike-through deprecated names more often (e.g. on the sidebar)

## 0.6.1
* Removed the `--package-root` option. Dartdoc now uses the `--input` flag as
  the place to start looking for an analysis root. This better supports the
  `.packages` file and use cases where dartdoc is invoked from locations other
  than the project directory.
* Search box displays message when it fails to load its index
* Changed message printed when dartdoc finishes, pointing to path instead of URI
* Reduced color saturation in header and links
* Improved display of getters and setters on property pages

## 0.6.0+1
* [bug] fix for getting URI for sources in lib folder

## 0.6.0
* [enhancement] / key activates the search bar
* [bug] combined getter/setter docs were mangled
* [enhancement] exact matches in search now rank higher
* [enhancement] search box starts with "Loading..."
* [enhancement] provide a hint that there are more docs than the one-liner
* [sdk] bundle dartdoc with SDK
* [bug] links in right column of MapBase did not work
* [enhancement] reorder details about a class, like inheritance
* [sdk] fix links in SDK's front page README

## 0.5.0+3
* [bug] fixed issue with duplicate docs for properties

## 0.5.0+1
* [bug] fixed an issue running dartdoc as a pub global activated snapshot

## 0.5.0
* [health] remove calls to deprecated methods
* [health] remove workaround when sorting empty iterable
* [sdk] now requires Dart SDK 1.12-dev or greater
* [bug] homepage column widths now add up to 12
* [enhancement] display ellipse when text overflows out the one-liners
* [enhancement] section titles are larger, lighter
* [health] testing on Windows + 1.12-dev SDK
* [enhancement] property types are now on the right
* [enhancement] other various style tweaks
* [enhancement] main text is darker, links are more contrasty
* [enhancement] include dartdoc version in generated docs, as HTML comment
* [enhancement] remove empty-doc warnings for unnamed libraries
* [enhancement] dartdoc understands "sdk extensions"
* [enhancement] find-as-you-type search
* [bug] doc references to names with multiple underscores now link correctly

## 0.4.0
* Print the name of the thing above the right nav list
* Numerous fixes, tests, and cleanups to the code
* fix: top-level consts are linked correctly from doc references
* fix: if a doc comment cannot be resolved, it is wrapped in a code element
* fix: links generated on the Enum page
* fix: background is dark when left drawer is open
* fix: better error message when running dartdoc on empty directory
* fix: don't show left drawer toggle on homescreen
* fix: docs for a class that extends List showed double methods

## 0.3.0
* new: left nav now animates in on mobile
* new: white list certain libraries from the command line
* fix: syntax highlighting of inline code
* fix: exceptions and errors are not includes in the list of classes

## 0.2.2
* new: show the source code for methods, functions, and constructors
* fix: fixed an npe when generating docs for projects without readmes

## 0.2.1
* fix: documentation for fields was sometimes `null`

## 0.2.0

* fix: inconsistent heights in masthead
* new: alphabetize lists of names
* fix: fields w/ getters and setters were not displaying docs

## 0.1.0+5

* show peers in left navigation bar
* show inherited on a separate line
* fix links to anchors
* fix comments for properties

## 0.1.0+4

* display only named constructor in left nav
* do not show duplicates in implementors
* add dart identity to page
* left nav links to dedicated page for element

## 0.1.0+3

* added top navigation bar
* add left navigation section
* package page lists libraries in left nav
* bump version of grinder

## 0.1.0+2

* bump version of pub_cache

## 0.1.0+1

* remove unused dependencies (http and intl)

## 0.1.0

* display a left-hand nav for classes and libraries
* constants now display types in classes and libraries
* types for properties now show on the left
* files that act as indexes now use dash instead of underscores in their names
* display tabs for major in-page sections

## 0.0.3

* tweaks to margins, fonts and header
* mobile ui improvements
* support user defined library mapping using --url-mapping option
* warning if library is undocumented
* fixed linking for parameters

## 0.0.2+3

* do not drop brackets in comments
* replace ':' in library names with '-'
* support multiple anonymous libraries
* show generic information for classes
* signature of method on same line as name
* error if command line argument is not recognized
* fixed href for property accesssor
* fixed generation of docs for exported libraries

## 0.0.2+2

* add a --package-root option
* resource handler support for package root

## 0.0.2+1

* handle packages that don't have a readme
* fixed linking to references from other libraries in comments
* resolve [new Constructor] in comments
* link to exported library in comment references
* visually show library is deprecated
* fixed one liner documentation

## 0.0.2

* documenation generated in `doc/api` directory
* support for readme files in plain text
* fixed resolving references in library comments
* generate docs even when output directory exists
* show inherited operators
* visually indicate deprecated api
