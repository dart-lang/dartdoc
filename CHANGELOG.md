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
