# Mustache for Dart

[![Build Status](https://travis-ci.org/valotas/mustache4dart.svg?branch=master)](https://travis-ci.org/valotas/mustache4dart)
[![Coverage Status](https://coveralls.io/repos/github/valotas/mustache4dart/badge.svg?branch=master)](https://coveralls.io/github/valotas/mustache4dart?branch=master)

A simple implementation of [Mustache][mustache] for the
[Dart language][dartlang], which passes happily all the
[mustache v1.1.2+λ specs][specs]. If you want to have a look at how it works,
just check the [tests][tests]. For more info, just read further.

Using it
--------
In order to use the library, just add it to your `pubspec.yaml` as a dependency

	dependencies:
	  mustache4dart: '>= 2.0.0 < 3.0.0'

and then import the package

```dart
import 'package:mustache4dart/mustache4dart.dart';
```

and you are good to go. You can use the render toplevel function to render your
template.

For example:

```dart
var salutation = render('Hello {{name}}!', {'name': 'Bob'});
print(salutation); //shoud print Hello Bob!
```

### Context objects
mustache4dart will look at your given object for operators, fields or methods.
For example, if you give the template `{{firstname}}` for rendering,
mustache4dart will try the followings

1. use the `[]` operator with `firstname` as the parameter
2. search for a field named `firstname`
3. search for a getter named `firstname`
4. search for a method named `firstname` (see Lambdas support)

in each case the first valid value will be used.

#### @MirrorsUsed
In order to do the stuff described above the mirror library is being used which
could lead to big js files when compiling the library with dartjs. In order to
preserve the type information you have to annotate the objects used as
contextes with `@MirrorsUsed`. Have in mind though that [as documented][mirrorsused]
this is experimental.

In order to avoid the use of the mirrors package, make sure that you compile
your library with `dart2js -DMIRRORS=false `. In that case though you must
always make sure that your context object have a right implementation of the
`[]` operator as no other checks on the object will be available.

### Partials
mustache4dart support partials but it needs somehow to know how to find a
partial. You can do that by providing a function that returns a template
given a name:

```dart
String partialProvider(String partialName) => "this is the partial with name: ${partialName}";
expect(render('[{{>p}}]', null, partial: partialProvider), '[this is the partial with name: p]'));
```

### Compiling to functions
If you have a template that you are going to reuse with different contexts,
you can compile it to a function using the toplevel function compile:

```dart
var salut = compile('Hello {{name}}!');
print(salut({'name': 'Alice'})); //should print Hello Alice!
``` 

### Lambdas support
The library passes all the optional [lambda specs][lambda_specs] based on
which lambdas must be treatable as arity 0 or 1 functions.
As dart provides optional named parameters, you can pass to a given lambda
function the `nestedContext`. In that case the current nested context will be
given as parameter to the lambda function.


Developing
----------
The project passes all the [Mustache specs][specs].  You have to make sure
though that you've downloaded them. Just make sure that you have done the
steps described below.

```sh
git clone git://github.com/valotas/mustache4dart.git
git submodule init
git submodule update
pub get
```

If you are with Linux, you can use what [travis][travis] does:

```sh
./build.sh
```

Alternatively, if you have [Dart Test Runner][testrunner] installed you can
just do:

```
pub global run test_runner
```

### Observatory

To start the observatory after running test:

```sh
dart --pause-isolates-on-exit --enable-vm-service=NNNN ./test/mustache_all.dart
```

Then [`coverage`][coverage] can be used in order to collect and format data:

```sh
pub global run coverage:collect_coverage --uri=http://... -o /tmp/mustache4dart.coverage.json --resume-isolates
pub global run coverage:format_coverage --packages=app_package/.packages -i /tmp/mustache4dart.coverage.json
```

Contributing
------------
If you found a bug, just create a [new issue][new_issue] or even better fork
and issue a pull request with you fix.

Versioning
----------
The library will follow a [semantic versioning][semver]

[mustache]: http://mustache.github.com/
[dartlang]: https://www.dartlang.org/
[tests]: http://github.com/valotas/mustache4dart/blob/master/test/mustache_tests.dart
[specs]: http://github.com/mustache/spec
[lambda_specs]: https://github.com/mustache/spec/blob/master/specs/~lambdas.yml
[new_issue]: https://github.com/valotas/mustache4dart/issues/new
[semver]: http://semver.org/
[mirrorsused]: https://api.dartlang.org/apidocs/channels/stable/#dart-mirrors.MirrorsUsed
[testrunner]: https://pub.dartlang.org/packages/test_runner
[travis]: https://travis-ci.org/valotas/mustache4dart
[coverage]: https://pub.dartlang.org/packages/coverage
