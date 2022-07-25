{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{>feature_set}}
{{/self}}

{{#mixin}}
{{>documentation}}

{{#hasModifiers}}
{{#hasDocumentedSuperclassConstraints}}
**Superclass Constraints**

{{#documentedSuperclassConstraints}}
- {{{linkedName}}}
{{/documentedSuperclassConstraints}}
{{/hasDocumentedSuperclassConstraints}}

{{ >super_chain }}
{{ >interfaces }}

{{#hasDocumentedImplementors}}
**Mixin Applications**

{{#documentedImplementorsSorted}}
- {{{linkedName}}}
{{/documentedImplementorsSorted}}
{{/hasDocumentedImplementors}}

{{ >annotations }}
{{/hasModifiers}}

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
{{/mixin}}

{{>footer}}
