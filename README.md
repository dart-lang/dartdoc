# dartdoc

Use `dartdoc` to generate HTML documentaton for your Dart package.

Note: As of Dart 1.12, `dartdoc` is shipped with the Dart SDK and replaces the
older `docgen` tool.

If you want to _contribute_ to the dartdoc project, see the
[contributor docs][]. This page contains information about _using_ the dartdoc
tool.

## Installing dartdoc

### From the Dart SDK

[Download the Dart SDK](https://www.dartlang.org/downloads/), version
1.12-dev.5.10 or later. If not already added, add the SDK's `bin` directory to
your `PATH`.

### From pub.dartlang.org

You can install the latest version of dartdoc with `pub`:

    $ pub global activate dartdoc

Note: to ensure that this version is run when you type `dartdoc` on the command
line, make sure that `~/.pub-cache/bin` is on your `PATH`, and before the path
to the Dart SDK.

## Running dartdoc

### Generating docs

Run `dartdoc` from the root directory of package.  For example:

```
$ dartdoc
Generating documentation for 'server_code_lab' into <path-to-server-code-lab>/server_code_lab/doc/api/

parsing lib/client/piratesapi.dart...
parsing lib/common/messages.dart...
parsing lib/common/utils.dart...
parsing lib/server/piratesapi.dart...
Parsed 4 files in 8.1 seconds.

generating docs for library pirate.messages from messages.dart...
generating docs for library pirate.server from piratesapi.dart...
generating docs for library pirate.utils from utils.dart...
generating docs for library server_code_lab.piratesApi.client from piratesapi.dart...
Documented 4 libraries in 9.6 seconds.

Success! Docs generated into <path-to-server-code-lab>/server_code_lab/doc/api/index.html
```

By default, the documentation is generated to the `doc/api` directory as static
HTML files.

### Viewing docs

You can view the generated docs directly from the file system, but if you want
to use the search function, you must load them with an HTTP server.

An easy way to run an HTTP server locally is to use the `dhttpd` package. For
example:

```
$ pub global activate dhttpd
$ dhttpd --path doc/api
```

Navigate to `http://localhost:8080` in your browser; the search function should
now work.

## Options

Command-line options for dartdoc include:

- `-h` or `--help` Display help.
- `--header=<file>` Insert the specified file, which contains HTML code, into
  the footer of every page.
- `--footer=<file>` Insert the specifying file, which contains HTML code, into
  the header of every page.
- `--input=<directory>` Generate the docs from the specified directory. If not
  specified, it defaults to the current directory.
- `--output=<directory>` Generate the output to the specified directory. If not
  specified, it defaults to `doc/api`.
- `--package-root=<directory>` Specify the package root of the library.
- `--exclude=<lib1,lib2,lib3,...>` Exclude the specified libraries from the
  generated docs.
- `--include=<lib1,lib2,lib3,...>` Generate docs for the specified libraries.
- `--hosted-url=<url>` Build a docs sitemap using the specified URL for your
  website.
- `--url-mapping=<libraryUri>,<path-to-library>/<lib>.dart` Use the specified
  library as the source for that particular import.

The following options are used only when generating docs for the Dart SDK.

- `--dart-sdk=<path>` Specify the location of the Dart SDK, if it can't be
  detected automatically.
- `--sdk-docs` Generate only docs for the Dart SDK.
- `--sdk-readme=<file>` Specify the README file for the Dart SDK.

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][].

## License

Please see the [dartdoc license][].

[GitHub Issue Tracker]: https://github.com/dart-lang/dartdoc/issues
[contributor docs]: https://github.com/dart-lang/dartdoc/blob/master/CONTRIBUTING.md
[dartdoc license]: https://github.com/dart-lang/dartdoc/blob/master/LICENSE
