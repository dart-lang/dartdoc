{{#isCallable}}
  {{#asCallable}}
    ##### {{{linkedName}}}{{{linkedGenericParameters}}} = {{{modelType.linkedName}}}
    {{>categorization}}

    {{{ oneLineDoc }}}  {{!two spaces intentional}}
    {{ >attributes }}
  {{/asCallable}}
{{/isCallable}}
{{^isCallable}}
  {{>type}}
{{/isCallable}}
