{{>head}}

# {{ title }}

{{#defaultPackage}}
{{>documentation}}
{{/defaultPackage}}

{{#localPackages}}
{{#isFirstPackage}}
## Libraries
{{/isFirstPackage}}
{{^isFirstPackage}}
## {{name}}
{{/isFirstPackage}}

{{#defaultCategory.documentedLibrariesSorted}}
{{>library}}
{{/defaultCategory.documentedLibrariesSorted}}

{{#categoriesWithDocumentedLibraries}}
### Category {{{categoryLabel}}}

{{#documentedLibrariesSorted}}
{{>library}}
{{/documentedLibrariesSorted}}
{{/categoriesWithDocumentedLibraries}}
{{/localPackages}}

{{>footer}}
