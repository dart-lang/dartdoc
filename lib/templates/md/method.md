{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{>feature_set}}
{{/self}}

{{#method}}
{{>callable_multiline}}
{{ >attributes }}

{{>documentation}}

{{>source_code}}

{{/method}}

{{>footer}}
