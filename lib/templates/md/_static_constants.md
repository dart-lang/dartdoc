{{! All constants on classes, enums, extensions, and mixins are static, but the
    file is named this way for organization purposes. }}

{{ #hasDocumentedConstantFields }}
## Constants

{{ #documentedConstantFieldsSorted }}
{{ >constant }}

{{ /documentedConstantFieldsSorted }}
{{ /hasDocumentedConstantFields }}