{{>head}}

{{#self}}
# {{name}} {{kind}}

{{>documentation}}

{{#hasDocumentedLibraries}}
## Libraries

{{#documentedLibrariesSorted}}
{{>library}}

{{/documentedLibrariesSorted}}
{{/hasDocumentedLibraries}}

{{#hasDocumentedClasses}}
## Classes

{{#documentedClassesSorted}}
{{>container}}

{{/documentedClassesSorted}}
{{/hasDocumentedClasses}}

{{#hasDocumentedMixins}}
## Mixins

{{#documentedMixinsSorted}}
{{>container}}

{{/documentedMixinsSorted}}
{{/hasDocumentedMixins}}

{{#hasDocumentedExtensions}}
## Extensions

{{#documentedExtensionsSorted}}
{{>extension}}

{{/documentedExtensionsSorted}}
{{/hasDocumentedExtensions}}

{{#hasDocumentedConstants}}
## Constants

{{#documentedConstantsSorted}}
{{>constant}}

{{/documentedConstantsSorted}}
{{/hasDocumentedConstants}}

{{#hasDocumentedProperties}}
## Properties

{{#documentedPropertiesSorted}}
{{>property}}

{{/documentedPropertiesSorted}}
{{/hasDocumentedProperties}}

{{#hasDocumentedFunctions}}
## Functions

{{#documentedFunctionsSorted}}
{{>callable}}

{{/documentedFunctionsSorted}}
{{/hasDocumentedFunctions}}

{{#hasDocumentedEnums}}
## Enums

{{#documentedEnumsSorted}}
{{>container}}

{{/documentedEnumsSorted}}
{{/hasDocumentedEnums}}

{{#hasDocumentedTypedefs}}
## Typedefs

{{#documentedTypedefsSorted}}
{{>typedef}}

{{/documentedTypedefsSorted}}
{{/hasDocumentedTypedefs}}

{{#hasDocumentedExceptions}}
## Exceptions / Errors

{{#documentedExceptionsSorted}}
{{>container}}

{{/documentedExceptionsSorted}}
{{/hasDocumentedExceptions}}
{{/self}}

{{>footer}}
