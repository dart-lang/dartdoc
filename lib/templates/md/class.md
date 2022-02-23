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

{{#hasPublicConstructors}}
## Constructors

{{#publicConstructorsSorted}}
{{{linkedName}}} ({{{ linkedParams }}})

{{{ oneLineDoc }}}  {{!two spaces intentional}}
{{#isConst}}_const_{{/isConst}} {{#isFactory}}_factory_{{/isFactory}}

{{/publicConstructorsSorted}}
{{/hasPublicConstructors}}

{{#hasPublicInstanceFields}}
## Properties

{{#publicInstanceFieldsSorted}}
{{>property}}

{{/publicInstanceFieldsSorted}}
{{/hasPublicInstanceFields}}

{{ >instance_methods }}

{{ >instance_operators }}

{{#hasPublicVariableStaticFields}}
## Static Properties

{{#publicVariableStaticFieldsSorted}}
{{>property}}

{{/publicVariableStaticFieldsSorted}}
{{/hasPublicVariableStaticFields}}

{{#hasPublicStaticMethods}}
## Static Methods

{{#publicStaticMethodsSorted}}
{{>callable}}

{{/publicStaticMethodsSorted}}
{{/hasPublicStaticMethods}}

{{#hasPublicConstantFields}}
## Constants

{{#publicConstantFieldsSorted}}
{{>constant}}

{{/publicConstantFieldsSorted}}
{{/hasPublicConstantFields}}
{{/clazz}}

{{>footer}}
