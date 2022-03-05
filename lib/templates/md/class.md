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

{{#hasPublicMixedInTypes}}
**Mixed in types**

{{#publicMixedInTypes}}
- {{{linkedName}}}
{{/publicMixedInTypes}}
{{/hasPublicMixedInTypes}}

{{#hasPublicImplementors}}
**Implementers**

{{#publicImplementorsSorted}}
- {{{linkedName}}}
{{/publicImplementorsSorted}}
{{/hasPublicImplementors}}

{{#hasPotentiallyApplicableExtensions}}
**Available Extensions**

{{#potentiallyApplicableExtensions}}
- {{{linkedName}}}
{{/potentiallyApplicableExtensions}}
{{/hasPotentiallyApplicableExtensions}}

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{linkedNameWithParameters}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{ >constructors }}

{{#hasPublicInstanceFields}}
## Properties

{{#publicInstanceFieldsSorted}}
{{>property}}

{{/publicInstanceFieldsSorted}}
{{/hasPublicInstanceFields}}

{{ >instance_methods }}

{{ >instance_operators }}

{{ >static_properties }}

{{ >static_methods }}

{{ >static_constants }}
{{/clazz}}

{{>footer}}
