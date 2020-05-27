{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{>feature_set}}

{{#hasNoGetterSetter}}
{{{ linkedReturnType }}} {{>name_summary}}  {{!two spaces intentional}}
{{>features}}

{{>documentation}}

{{>source_code}}
{{/hasNoGetterSetter}}

{{#hasExplicitGetter}}
{{>accessor_getter}}
{{/hasExplicitGetter}}

{{#hasExplicitSetter}}
{{>accessor_setter}}
{{/hasExplicitSetter}}
{{/self}}

{{>footer}}
