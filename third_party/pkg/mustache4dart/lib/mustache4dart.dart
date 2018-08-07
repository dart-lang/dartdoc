library mustache4dart;

import 'mustache_context.dart';

part 'src/mustache.dart';
part 'src/tokens.dart';
part 'src/tmpl.dart';

const EMPTY_STRING = '';
const SPACE = ' ';
const NL = '\n';
const CRNL = '\r\n';

/// Returns a StringSink, if one is passed in, otherwise returns
/// a string of the rendered template.
typedef dynamic TemplateRenderer(ctx,
    {StringSink out,
    bool errorOnMissingProperty,
    bool assumeNullNonExistingProperty});
