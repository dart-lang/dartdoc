{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{/self}}

{{#constructor}}
{{#hasAnnotations}}
{{#annotations}}
- {{{.}}}
{{/annotations}}
{{/hasAnnotations}}

{{#isConst}}const{{/isConst}}
{{{nameWithGenerics}}}({{#hasParameters}}{{{linkedParamsLines}}}{{/hasParameters}})

{{>documentation}}

{{>source_code}}

{{/constructor}}

{{>footer}}
