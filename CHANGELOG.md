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

## 0.0.2

* documenation generated in `doc/api` directory
* support for readme files in plain text
* fixed resolving references in library comments
* generate docs even when output directory exists
* show inherited operators
* visually indicate deprecated api

## 0.0.2+1

* handle packages that don't have a readme
* fixed linking to references from other libraries in comments
* resolve [new Constructor] in comments
* link to exported library in comment references
* visually show library is deprecated
* fixed one liner documentation

## 0.0.2+2

* add a --package-root option
* resource handler support for package root

## 0.0.2+3

* do not drop brackets in comments
* replace ':' in library names with '-'
* support multiple anonymous libraries
* show generic information for classes
* signature of method on same line as name
* error if command line argument is not recognized
* fixed href for property accesssor
* fixed generation of docs for exported libraries

## 0.0.3

* tweaks to margins, fonts and header
* mobile ui improvements
* support user defined library mapping using --url-mapping option
* warning if library is undocumented
* fixed linking for parameters
