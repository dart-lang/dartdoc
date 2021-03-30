{{#isCallable}}
  {{#asCallable}}
    {{>callable_multiline}}
  {{/asCallable}}
{{/isCallable}}
{{^isCallable}}
  {{>type_multiline}}
{{/isCallable}}
