{{>head}}

{{#self}}
# {{{name}}} {{kind}}

{{>source_link}}
{{>categorization}}
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

{{#hasAnnotations}}
**Annotations**

{{#annotations}}
- {{{.}}}
{{/annotations}}
{{/hasAnnotations}}
{{/hasModifiers}}

{{#hasPublicConstants}}
## Constants

{{#publicConstants}}
{{>constant}}

{{/publicConstants}}
{{/hasPublicConstants}}

{{#hasPublicConstructors}}
## Constructors

{{#publicConstructors}}
{{{linkedName}}}({{{ linkedParams }}})

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
{{/eNum}}

{{>footer}}
