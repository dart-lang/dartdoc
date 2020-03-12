{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{/self}}

{{#property}}
{{{ linkedReturnType }}} {{>name_summary}} = {{{ constantValue }}}

{{>documentation}}

{{>source_code}}
{{/property}}

{{>footer}}
