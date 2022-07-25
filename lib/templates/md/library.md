{{>head}}

{{#self}}
# {{{ name }}} {{ kind }}

{{>source_link}}
{{>categorization}}
{{>feature_set}}
{{/self}}

{{#library}}
{{>documentation}}
{{/library}}

{{#library.hasDocumentedClasses}}
## Classes

{{#library.documentedClassesSorted}}
{{>container}}

{{/library.documentedClassesSorted}}
{{/library.hasDocumentedClasses}}

{{#library.hasDocumentedMixins}}
## Mixins

{{#library.documentedMixinsSorted}}
{{>container}}

{{/library.documentedMixinsSorted}}
{{/library.hasDocumentedMixins}}

{{#library.hasDocumentedExtensions}}
## Extensions

{{#library.documentedExtensionsSorted}}
{{>extension}}

{{/library.documentedExtensionsSorted}}
{{/library.hasDocumentedExtensions}}

{{#library.hasDocumentedConstants}}
## Constants

{{#library.documentedConstantsSorted}}
{{>constant}}

{{/library.documentedConstantsSorted}}
{{/library.hasDocumentedConstants}}

{{#library.hasDocumentedProperties}}
## Properties

{{#library.documentedPropertiesSorted}}
{{>property}}

{{/library.documentedPropertiesSorted}}
{{/library.hasDocumentedProperties}}

{{#library.hasDocumentedFunctions}}
## Functions

{{#library.documentedFunctionsSorted}}
{{>callable}}

{{/library.documentedFunctionsSorted}}
{{/library.hasDocumentedFunctions}}

{{#library.hasDocumentedEnums}}
## Enums

{{#library.documentedEnumsSorted}}
{{>container}}

{{/library.documentedEnumsSorted}}
{{/library.hasDocumentedEnums}}

{{#library.hasDocumentedTypedefs}}
## Typedefs

{{#library.documentedTypedefsSorted}}
{{>typedef}}

{{/library.documentedTypedefsSorted}}
{{/library.hasDocumentedTypedefs}}

{{#library.hasDocumentedExceptions}}
## Exceptions / Errors

{{#library.documentedExceptionsSorted}}
{{>container}}

{{/library.documentedExceptionsSorted}}
{{/library.hasDocumentedExceptions}}

{{>footer}}
