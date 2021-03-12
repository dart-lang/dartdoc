{{#hasAnnotations}}
{{#annotations}}
- {{{.}}}
{{/annotations}}
{{/hasAnnotations}}

{{{ modelType.returnType.linkedName }}} {{>name_summary}}{{{genericParameters}}}({{#hasParameters}}{{{linkedParamsLines}}}{{/hasParameters}})
