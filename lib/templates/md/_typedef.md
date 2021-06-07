{{#isCallable}}
  {{#asCallable}}
    ##### {{{linkedName}}}{{{linkedGenericParameters}}} = {{{modelType.linkedName}}}
    {{>categorization}}

    {{{ oneLineDoc }}} {{{ extendedDocLink }}}  {{!two spaces intentional}}
    {{>features}}
  {{/asCallable}}
{{/isCallable}}
{{^isCallable}}
  {{>type}}
{{/isCallable}}
