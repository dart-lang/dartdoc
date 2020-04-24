{{>head}}

{{#self}}
# {{{nameWithGenerics}}} {{kind}}

{{>source_link}}
{{>categorization}}
{{/self}}

{{#clazz}}
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

{{#hasPublicInterfaces}}
**Implemented types**

{{#publicInterfaces}}
- {{{linkedName}}}
{{/publicInterfaces}}
{{/hasPublicInterfaces}}

{{#hasPublicMixins}}
**Mixed in types**

{{#publicMixins}}
- {{{linkedName}}}
{{/publicMixins}}
{{/hasPublicMixins}}

{{#hasPublicImplementors}}
**Implementers**

{{#publicImplementors}}
- {{{linkedName}}}
{{/publicImplementors}}
{{/hasPublicImplementors}}

{{#hasPotentiallyApplicableExtensions}}
**Available Extensions**

{{#potentiallyApplicableExtensions}}
- {{{linkedName}}}
{{/potentiallyApplicableExtensions}}
{{/hasPotentiallyApplicableExtensions}}

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{.}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{#hasPublicConstructors}}
## Constructors

{{#publicConstructors}}
{{{linkedName}}} ({{{ linkedParams }}})

{{{ oneLineDoc }}} {{{ extendedDocLink }}}  {{!two spaces intentional}}
{{#isConst}}_const_{{/isConst}} {{#isFactory}}_factory_{{/isFactory}}

{{/publicConstructors}}
{{/hasPublicConstructors}}

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
{{/clazz}}

{{>footer}}
