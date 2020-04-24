{{>head}}

{{#self}}
# {{name}} {{kind}}

{{>documentation}}

{{#hasPublicLibraries}}
## Libraries

{{#publicLibraries}}
{{>library}}

{{/publicLibraries}}
{{/hasPublicLibraries}}

{{#hasPublicClasses}}
## Classes

{{#publicClasses}}
{{>class}}

{{/publicClasses}}
{{/hasPublicClasses}}

{{#hasPublicMixins}}
## Mixins

{{#publicMixins}}
{{>mixin}}

{{/publicMixins}}
{{/hasPublicMixins}}

{{#hasPublicConstants}}
## Constants

{{#publicConstants}}
{{>constant}}

{{/publicConstants}}
{{/hasPublicConstants}}

{{#hasPublicProperties}}
## Properties

{{#publicProperties}}
{{>property}}

{{/publicProperties}}
{{/hasPublicProperties}}

{{#hasPublicFunctions}}
## Functions

{{#publicFunctions}}
{{>callable}}

{{/publicFunctions}}
{{/hasPublicFunctions}}

{{#hasPublicEnums}}
## Enums

{{#publicEnums}}
{{>class}}

{{/publicEnums}}
{{/hasPublicEnums}}

{{#hasPublicTypedefs}}
## Typedefs

{{#publicTypedefs}}
{{>callable}}

{{/publicTypedefs}}
{{/hasPublicTypedefs}}

{{#hasPublicExceptions}}
## Exceptions / Errors

{{#publicExceptions}}
{{>class}}

{{/publicExceptions}}
{{/hasPublicExceptions}}
{{/self}}

{{>footer}}
