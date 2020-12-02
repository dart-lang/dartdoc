{{>head}}

{{#self}}
# {{name}} {{kind}}

{{>documentation}}

{{#hasPublicLibraries}}
## Libraries

{{#publicLibrariesSorted}}
{{>library}}

{{/publicLibrariesSorted}}
{{/hasPublicLibraries}}

{{#hasPublicClasses}}
## Classes

{{#publicClassesSorted}}
{{>class}}

{{/publicClassesSorted}}
{{/hasPublicClasses}}

{{#hasPublicMixins}}
## Mixins

{{#publicMixinsSorted}}
{{>mixin}}

{{/publicMixinsSorted}}
{{/hasPublicMixins}}

{{#hasPublicConstants}}
## Constants

{{#publicConstantsSorted}}
{{>constant}}

{{/publicConstantsSorted}}
{{/hasPublicConstants}}

{{#hasPublicProperties}}
## Properties

{{#publicPropertiesSorted}}
{{>property}}

{{/publicPropertiesSorted}}
{{/hasPublicProperties}}

{{#hasPublicFunctions}}
## Functions

{{#publicFunctionsSorted}}
{{>callable}}

{{/publicFunctionsSorted}}
{{/hasPublicFunctions}}

{{#hasPublicEnums}}
## Enums

{{#publicEnumsSorted}}
{{>class}}

{{/publicEnumsSorted}}
{{/hasPublicEnums}}

{{#hasPublicTypedefs}}
## Typedefs

{{#publicTypedefsSorted}}
{{>callable}}

{{/publicTypedefsSorted}}
{{/hasPublicTypedefs}}

{{#hasPublicExceptions}}
## Exceptions / Errors

{{#publicExceptionsSorted}}
{{>class}}

{{/publicExceptionsSorted}}
{{/hasPublicExceptions}}
{{/self}}

{{>footer}}
