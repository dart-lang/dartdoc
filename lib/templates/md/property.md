{{#self}}
# {{name}} {{kind}}

{{>source_link}}
{{/self}}

{{#self}}
{{#hasNoGetterSetter}}
{{{ linkedReturnType }}} {{>name_summary}}
{{>features}}

{{>documentation}}
{{>source_code}}
{{/hasNoGetterSetter}}

{{#hasGetterOrSetter}}
{{#hasGetter}}
{{>accessor_getter}}
{{/hasGetter}}

{{#hasSetter}}
{{>accessor_setter}}
{{/hasSetter}}
{{/hasGetterOrSetter}}
{{/self}}
