{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{>feature_set}}
{{/self}}

{{#property}}
{{{ linkedReturnType }}} {{>name_summary}} = {{{ constantValue }}}

{{>documentation}}

{{>source_code}}
{{/property}}

{{>footer}}
