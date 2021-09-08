{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{>feature_set}}
{{/self}}

{{#eNum}}
{{>documentation}}

{{#hasModifiers}}
{{#hasPublicSuperChainReversed}}
**Inheritance**

- {{{linkedObjectType}}}
{{#publicSuperChainReversed}}
- {{{linkedName}}}
{{/publicSuperChainReversed}}
- {{{name}}}
{{/hasPublicSuperChainReversed}}

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{linkedNameWithParameters}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{#hasPublicConstantFields}}
## Constants

{{#publicConstantFieldsSorted}}
{{>constant}}

{{/publicConstantFieldsSorted}}
{{/hasPublicConstantFields}}

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
{{/eNum}}

{{>footer}}
