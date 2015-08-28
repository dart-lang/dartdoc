# dartdoc

Use _dartdoc_ to generate HTML documentaton for your Dart package.

Note: As of Dart 1.12-dev.5.10, `dartdoc` is shipped with the Dart SDK and
replaces `docgen` and `dartdoc-viewer`.

If you want to _contribute_ to the dartdoc project, see the
[contributor docs](CONTRIBUTOR.md). This page contains information
about _using_ the dartdoc tool.

## Installing dartdoc

### From the Dart SDK

[Download the Dart SDK](https://www.dartlang.org/downloads/),
version 1.12-dev.5.10 or later.
If not already added, add the SDK's `bin` directory to your PATH.

### From pub.dartlang.org

You can install the latest version of dartdoc with `pub`:

$ pub global activate dartdoc

Note: to ensure that this version is run when you type dartdoc on
the command line, make sure that ~/.pub-cache/bin is on your PATH, and
before the path to the Dart SDK.

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

Success! Open file:///<path-to-server-code-lab>/server_code_lab/doc/api/index.html
```

By default, the documentation is generated to the `doc/api` directory as static HTML files.

### Viewing docs

You can view the generated docs directly from the file system,
but if you want to use the search
function, you must load them with an HTTP server.

An easy way to run an HTTP server locally is to use the
`simple_http_server` package. For example:

```
$ pub global activate simple_http_server
$ dhttpd --path doc/api
```

Navigate to `localhost:8080` in your browser. The search function should now work.

## Options

Command-line options for dartdoc include:

<dl>
<dt><code>`-h`</code> or <code>`--help`</code></dt>
<dd>Display help.</dd>

<dt><code>--header=&lt;<em>file</em>&gt;</code></dt>
<dd>
Insert the specified file, which contains HTML code, into the footer of every page.
</dd>

<dt><code>--footer=&lt;<em>file</em>&gt;</code></dt>
<dd>
Insert the specifing file, which contains HTML code, into the header of every page.
</dd>

<dt><code>--input=&lt;<em>directory</em>&gt;</code></dt>
<dd>
Generate the docs from the specified directory. If not specified, it defaults to
the current directory.
</dd>

<dt><code>--output=&lt;<em>directory</em>&gt;</code></dt>
<dd>
Generate the output to the specified directory. If not specified, it defaults to
`doc/api`.
</dd>

<dt><code>--package-root=&lt;<em>directory</em>&gt;</code></dt>
<dd>
Specify the package root of the library.
</dd>

<dt><code>--exclude=&lt;<em>lib1</em>,<em>lib2</em>,<em>lib3</em>,...&gt;</code></dt>
<dd>
Exclude the specified libraries from the generated docs.
</dd>

<dt><code>--include=&lt;<em>lib1</em>,<em>lib2</em>,<em>lib3</em>,...&gt;</code></dt>
<dd>
Generate docs for the specified libraries.
</dd>

<dt><code>--hosted-url=&lt;<em>url</em>&gt;</code></dt>
<dd>
Build a docs sitemap using the specified URL for your website.
</dd>

<dt><code>--url-mapping=&lt;<em>libraryUri</em>&gt;,&lt;<em>path-to-library</em>&gt;/&lt;<em>lib</em>&gt;.dart</code></dt>
<dd>
Use the specified library as the source for that particular import.
</dd>
</dl>

The following options are used only when generating docs for Dart SDK.

<dl>
<dt><code>--dart-sdk=&lt;<em>path</em>&gt;</code></dt>
<dd>
Specify the location of the Dart SDK, if it can't be detected automatically.
</dd>

<dt><code>--sdk-docs</code></dt>
<dd>
Generate only docs for the Dart SDK.
</dd>

<dt><code>--sdk-readme=&lt;<em>file</em>&gt;</code></dt>
<dd>
Specify the README file for the SDK.
</dd>
</dl>

## Issues and bugs

Please file reports on the [GitHub Issue Tracker][issues].

## License

Please see the [dartdoc license](https://github.com/dart-lang/dartdoc/blob/master/LICENSE).

[issues]: https://github.com/dart-lang/dartdoc/issues
