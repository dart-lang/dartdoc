{{ >foo_header }}

s1: {{ s1 }}
b1? {{ #b1 }}yes{{ /b1 }}{{ ^b1 }}no{{ /b1 }}
l1:
{{ #l1 }}item: {{.}}{{ /l1 }}
{{ ^l1 }}no items{{ /l1 }}
baz:
{{ #baz }}
Baz has a {{ bar.s2 }}
{{ /baz }}
{{ ^baz }}baz is null{{ /baz }}