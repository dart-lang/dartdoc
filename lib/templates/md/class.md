{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{>feature_set}}
{{/self}}

{{#clazz}}
{{>documentation}}

{{#hasModifiers}}
{{ >super_chain }}
{{ >interfaces }}
{{ >mixed_in_types }}

{{#hasDocumentedImplementors}}
**Implementers**

{{#documentedImplementorsSorted}}
- {{{linkedName}}}
{{/documentedImplementorsSorted}}
{{/hasDocumentedImplementors}}

{{#hasPotentiallyApplicableExtensions}}
**Available Extensions**

{{#potentiallyApplicableExtensions}}
- {{{linkedName}}}
{{/potentiallyApplicableExtensions}}
{{/hasPotentiallyApplicableExtensions}}

{{ >annotations }}
{{/hasModifiers}}

{{ >constructors }}

{{#hasDocumentedInstanceFields}}
## Properties

{{#documentedInstanceFieldsSorted}}
{{>property}}

{{/documentedInstanceFieldsSorted}}
{{/hasDocumentedInstanceFields}}

{{ >instance_methods }}

{{ >instance_operators }}

{{ >static_properties }}

{{ >static_methods }}

{{ >static_constants }}
{{/clazz}}

{{>footer}}
