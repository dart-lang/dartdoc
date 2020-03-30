{{>head}}

# {{ title }}

{{#packageGraph.defaultPackage}}
{{>documentation}}
{{/packageGraph.defaultPackage}}

{{#packageGraph}}
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
{{/packageGraph}}

{{>footer}}
