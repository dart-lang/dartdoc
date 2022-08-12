{{ #hasDocumentedConstructors }}
## Constructors

{{ #documentedConstructorsSorted }}
{{{ linkedName }}} ({{{ linkedParams }}})

{{{ oneLineDoc }}}  {{ !two spaces intentional }}
{{ #isConst }}_const_{{ /isConst }} {{ #isFactory }}_factory_{{ /isFactory }}

{{ /documentedConstructorsSorted }}
{{ /hasDocumentedConstructors }}