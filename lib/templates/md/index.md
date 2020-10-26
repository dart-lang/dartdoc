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

{{#defaultCategory.publicLibraries}}
{{>library}}
{{/defaultCategory.publicLibraries}}

{{#categoriesWithPublicLibraries}}
### Category {{{categoryLabel}}}

{{#publicLibraries}}
{{>library}}
{{/publicLibraries}}
{{/categoriesWithPublicLibraries}}
{{/localPackages}}

{{>footer}}
