{{ >head }}

{{ #self }}
# {{{ nameWithGenerics }}} {{ kind }}

{{ >source_link }}
{{ >feature_set }}
{{ /self}}

{{ #eNum }}
{{ >documentation }}

{{ #hasModifiers }}
{{ >super_chain }}
{{ >interfaces }}

{{ #hasAnnotations }}
**Annotations**

{{ #annotations }}
- {{{ linkedNameWithParameters }}}
{{ /annotations }}
{{ /hasAnnotations }}
{{ /hasModifiers }}

{{ #hasPublicConstantFields }}
## Constants

{{ #publicConstantFieldsSorted }}
{{ >constant }}

{{ /publicConstantFieldsSorted }}
{{ /hasPublicConstantFields }}

{{ #hasPublicInstanceFields }}
## Properties

{{ #publicInstanceFieldsSorted }}
{{ >property }}

{{ /publicInstanceFieldsSorted }}
{{ /hasPublicInstanceFields }}

{{ >instance_methods }}

{{ >instance_operators }}

{{ #hasPublicVariableStaticFields }}
## Static Properties

{{ #publicVariableStaticFieldsSorted }}
{{ >property }}

{{ /publicVariableStaticFieldsSorted }}
{{ /hasPublicVariableStaticFields }}

{{ >static_methods }}
{{ /eNum }}

{{ >footer }}
