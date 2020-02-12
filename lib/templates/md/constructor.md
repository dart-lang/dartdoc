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
{{#isDeprecated}}~~{{/isDeprecated}}{{{nameWithGenerics}}}({{#hasParameters}}{{{linkedParamsLines}}}{{/hasParameters}}){{#isDeprecated}}~~{{/isDeprecated}}

{{>documentation}}

{{>source_code}}

{{/constructor}}

{{>footer}}
