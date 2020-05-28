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

{{#hasPublicInstanceFields}}
## Properties

{{#publicInstanceFieldsSorted}}
{{>property}}

{{/publicInstanceFieldsSorted}}
{{/hasPublicInstanceFields}}

{{#hasPublicInstanceMethods}}
## Methods

{{#publicInstanceMethodsSorted}}
{{>callable}}

{{/publicInstanceMethodsSorted}}
{{/hasPublicInstanceMethods}}

{{#hasPublicInstanceOperators}}
## Operators

{{#publicInstanceOperatorsSorted}}
{{>callable}}

{{/publicInstanceOperatorsSorted}}
{{/hasPublicInstanceOperators}}

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
{{/extension}}

{{>footer}}
