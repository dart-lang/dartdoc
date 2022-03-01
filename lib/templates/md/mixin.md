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
{{#hasPublicSuperclassConstraints}}
**Superclass Constraints**

{{#publicSuperclassConstraints}}
- {{{linkedName}}}
{{/publicSuperclassConstraints}}
{{/hasPublicSuperclassConstraints}}

{{ >super_chain }}
{{ >interfaces }}

{{#hasPublicImplementors}}
**Mixin Applications**

{{#publicImplementorsSorted}}
- {{{linkedName}}}
{{/publicImplementorsSorted}}
{{/hasPublicImplementors}}

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{linkedNameWithParameters}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{#hasPublicInstanceFields}}
## Properties

{{#publicInstanceFieldsSorted}}
{{>property}}

{{/publicInstanceFieldsSorted}}
{{/hasPublicInstanceFields}}

{{> instance_methods }}

{{ >instance_operators }}

{{#hasPublicVariableStaticFields}}
## Static Properties

{{#publicVariableStaticFieldsSorted}}
{{>property}}

{{/publicVariableStaticFieldsSorted}}
{{/hasPublicVariableStaticFields}}

{{ >static_methods }}

{{#hasPublicConstantFields}}
## Constants

{{#publicConstantFieldsSorted}}
{{>constant}}

{{/publicConstantFieldsSorted}}
{{/hasPublicConstantFields}}
{{/mixin}}

{{>footer}}
