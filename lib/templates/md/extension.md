{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}
on {{#extendedType}}{{{linkedName}}}{{/extendedType}}

{{>source_link}}

{{>categorization}}
{{>feature_set}}
{{/self}}

{{#extension}}
{{>documentation}}

{{ >annotations }}

{{#hasDocumentedInstanceFields}}
## Properties

{{#documentedInstanceFieldsSorted}}
{{>property}}

{{/documentedInstanceFieldsSorted}}
{{/hasDocumentedInstanceFields}}

{{> instance_methods }}

{{ >instance_operators }}

{{ >static_properties }}

{{ >static_methods }}

{{ >static_constants }}
{{/extension}}

{{>footer}}
