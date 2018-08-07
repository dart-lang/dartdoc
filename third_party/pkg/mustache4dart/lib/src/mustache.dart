part of mustache4dart;

render(String template, Object context,
    {Function partial,
    Delimiter delimiter,
    String ident: EMPTY_STRING,
    StringSink out,
    bool errorOnMissingProperty: false,
    bool assumeNullNonExistingProperty: true}) {
  return compile(template,
          partial: partial, delimiter: delimiter, ident: ident)(context,
      out: out,
      errorOnMissingProperty: errorOnMissingProperty,
      assumeNullNonExistingProperty: assumeNullNonExistingProperty);
}

TemplateRenderer compile(String template,
    {Function partial, Delimiter delimiter, String ident: EMPTY_STRING}) {
  if (delimiter == null) {
    delimiter = new Delimiter('{{', '}}');
  }
  return new _Template(
      template: template, delimiter: delimiter, ident: ident, partial: partial);
}
