{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{>feature_set}}
{{/self}}

{{#function}}
{{ >callable_multiline }}
{{ >attributes }}

{{>documentation}}

{{>source_code}}

{{/function}}

{{>footer}}
