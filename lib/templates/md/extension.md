{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}
on {{#extendedType}}{{{linkedName}}}{{/extendedType}}

{{>source_link}}

{{>categorization}}
{{/self}}

{{#extension}}
{{>documentation}}

{{#hasPublicProperties}}
## Properties

{{#allPublicInstanceProperties}}
{{>property}}

{{/allPublicInstanceProperties}}
{{/hasPublicProperties}}

{{#hasPublicMethods}}
## Methods

{{#allPublicInstanceMethods}}
{{>callable}}

{{/allPublicInstanceMethods}}
{{/hasPublicMethods}}

{{#hasPublicOperators}}
## Operators

{{#allPublicOperators}}
{{>callable}}

{{/allPublicOperators}}
{{/hasPublicOperators}}

{{#hasPublicStaticProperties}}
## Static Properties

{{#publicStaticProperties}}
{{>property}}

{{/publicStaticProperties}}
{{/hasPublicStaticProperties}}

{{#hasPublicStaticMethods}}
## Static Methods

{{#publicStaticMethods}}
{{>callable}}

{{/publicStaticMethods}}
{{/hasPublicStaticMethods}}

{{#hasPublicConstants}}
## Constants

{{#publicConstants}}
{{>constant}}

{{/publicConstants}}
{{/hasPublicConstants}}
{{/extension}}

{{>footer}}
