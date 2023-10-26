{{ >head }}

{{ #self }}
# {{{ nameWithGenerics }}} {{ kind }}
on {{ #representationType }}{{{ linkedName }}}{{ /representationType }}

{{ >source_link }}

{{ >categorization }}
{{ >feature_set }}
{{ /self }}

{{ #extensionType }}
{{ >documentation }}

{{ >annotations }}

{{ >constructors }}

{{ #hasPublicInstanceFields }}
## Properties

{{ #publicInstanceFieldsSorted }}
{{ >property }}

{{ /publicInstanceFieldsSorted }}
{{ /hasPublicInstanceFields }}

{{ >instance_methods }}

{{ >instance_operators }}

{{ >static_properties }}

{{ >static_methods }}

{{ >static_constants }}
{{ /extension }}

{{ >footer }}
