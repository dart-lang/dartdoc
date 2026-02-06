# dartdoc-vitepress — Iteration 1 (MVP)

## Goal

Fork of dartdoc that generates VitePress-compatible markdown documentation
instead of HTML. Users get modern, beautiful API docs powered by VitePress
while keeping full customization of the VitePress project.

Based on dart-lang/dartdoc v9.0.2 (commit af008503).

---

## Architecture Overview

dartdoc pipeline:

```
Dart source -> [analyzer] -> PackageGraph/Model -> [GeneratorBackend] -> Output files
```

We replace the last step:

```
                                        +- HtmlGeneratorBackend -> .html (existing)
Model -> TemplateData -> GeneratorBackend-+
                                        +- VitePressGeneratorBackend -> .md + sidebar.ts (ours)
```

### Extension Point

`GeneratorBackend` (`lib/src/generator/generator_backend.dart:60-254`) is an abstract class
with **17 methods** (not ~15 as previously estimated):

Container-level (produce page files):
- `generatePackage()` (line 216)
- `generateLibrary()` (line 188) -- also writes redirect file
- `generateClass()` (line 133)
- `generateEnum()` (line 151)
- `generateMixin()` (line 208)
- `generateExtension()` (line 159)
- `generateExtensionType()` (line 168)
- `generateTypeDef()` (line 244)
- `generateFunction()` (line 178)
- `generateTopLevelProperty()` (line 234)
- `generateCategory()` (line 120) -- also writes redirect file

Member-level (produce per-member page files in HTML -- no-ops for VitePress):
- `generateConstructor()` (line 141)
- `generateMethod()` (line 198)
- `generateProperty()` (line 224)

Infrastructure:
- `generateSearchIndex()` (line 107) -- writes `index.json`
- `generateCategoryJson()` (line 93) -- writes `categories.json`
- `generateAdditionalFiles()` (line 253) -- abstract, copies static assets

### Constructor signature

```dart
GeneratorBackend(this.options, this.templates, this.writer, this.resourceProvider)
```

Requires `Templates` (HTML-specific) -- we pass a `_NoOpTemplates` stub.
Requires `DartdocGeneratorBackendOptions` -- we reuse as-is, ignoring irrelevant fields.

### The `write()` helper (lines 73-90)

The base class `write()` method does `htmlBasePlaceholder` replacement.
We override it to write markdown files directly with VitePress-compatible paths.

### Generator traversal

`Generator._generateDocs()` (`generator.dart:67-269`) iterates the full model graph
and calls backend methods for every documented element. This traversal is ~200 lines
we get for free by extending `GeneratorBackend`. **We do NOT rewrite the traversal.**

---

## Critical Design Decisions (ADRs)

### ADR-1: Extend GeneratorBackend, override everything

**Decision:** Extend `GeneratorBackend`, override ALL 17 `generate*()` methods.
Do NOT call `super.generate*()` in any override (super produces HTML).

**Rationale:**
- `Generator` at `generator.dart:43` takes a `GeneratorBackend` -- this is the only
  extension point. We get the full traversal loop for free.
- `HtmlGeneratorBackend` demonstrates the pattern: extend base, override what you need.
- Pass `_NoOpTemplates()` stub to constructor (templates are never called).

**Alternative rejected:** Creating a custom pipeline bypassing `GeneratorBackend`.
This would require duplicating 200 lines of traversal logic and losing future
upstream improvements.

### ADR-2: Compute VitePress paths independently -- NEVER read model's filePath/href

**Decision:** Create `VitePressPathResolver` class that computes all paths from
raw `name` and `library.dirName`. Never read `element.fileName`, `element.filePath`,
or `element.href`.

**Rationale:** The model layer hardcodes `.html` extensions in 15+ files:

| Model class | fileName pattern | Source |
|-------------|-----------------|--------|
| ModelElement | `$name.html` | `model_element.dart:567` |
| Class | `$name-class.html` | `class.dart:38` |
| Enum | `$name.html` / `$name-enum.html` | `enum.dart:25` |
| Mixin | `$name-mixin.html` | `mixin.dart:24` |
| ExtensionType | `$name-extension-type.html` | `extension_type.dart:64` |
| Constructor | `$enclosingElement.name.html` / `$name.html` | `constructor.dart:46-48` |
| Operator | `operator_${operatorNames[referenceName]}.html` | `operator.dart:45` |
| Field | `$name.html` / `$name-constant.html` | `field.dart:145` |
| ModelFunction | `$name.html` / `$name-function.html` | `model_function.dart:54` |
| Typedef | `$name.html` / `$name-typedef.html` | `typedef.dart:36` |
| Library | `index.html` | `library.dart:185` |
| Package | `index.html` | `package.dart:171` |

Additionally, `href` uses `htmlBasePlaceholder` (`%%__HTMLBASE_dartdoc_internal__%%`)
defined at `package.dart:28`, post-processed by `GeneratorBackend.write()` at lines 80-86.

These are all `late final` -- cannot be changed after initialization.

### ADR-3: Use `documentation` getter, not `documentationAsHtml`

**Decision:** Use the `documentation` property on `ModelElement` (line 539-540) as
the source for doc comment content. This is processed markdown (macros injected,
directives handled) but NOT yet converted to HTML. Create custom link resolution
for `[references]` to produce markdown links.

**CONFIRMED (100%):** Expert code review with test proof verified that bracket
references `[ClassName]` survive completely intact in the `documentation` getter.
No regex in the pipeline matches `[ClassName]` patterns. Test proof from dartdoc:
`expect(cb3Typedef.documentation, 'Not unlike [Cb2].');` (`model_test.dart:2144`).

**Pipeline stages:**

```
Raw /// text
  -> stripCommentDelimiters()          (documentation_comment.dart:78)
  -> processDirectives()               ({@youtube}, {@animation}, {@template}, etc.)
  -> injectMacros()                    (documentation_comment.dart:827-837)
  = documentation                      [WE INTERCEPT HERE]
  -> MarkdownDocument + linkResolver   (markdown_processor.dart:263-269)
  -> md.HtmlRenderer                   (documentation_renderer.dart:31)
  = documentationAsHtml                [TOO LATE -- already HTML]
```

**`<p>` joiner — effectively dead code:**
The `documentation` getter at line 540 joins with `<p>`:
```dart
documentationFrom.map((e) => e.documentationLocal).join('<p>')
```
Expert analysis confirmed `documentationFrom` NEVER returns multiple elements in
practice. The only override is in `GetterSetterCombo`, which merges getter+setter
docs using `\n\n` already (not `<p>`). We still apply `<p>` → `\n\n` replacement
as a safety net, but this code path is dead in all known cases.

**Directive HTML output:**
- `{@youtube URL}` produces `<iframe>` HTML — pass through (VitePress handles raw HTML)
- `{@animation}` produces `<div>` + `<video>` HTML — pass through
- `{@template}` content can contain bracket refs that survive through `{@macro}` — works correctly
- `{@inject-html}` — replaced with `<dartdoc-html>SHA1_DIGEST</dartdoc-html>` placeholder
  in `documentation` getter (`documentation_comment.dart:634-643`). Real HTML fragments are
  stored in `packageGraph._htmlFragments`. Must resolve BEFORE markdown parsing:
  ```dart
  text = text.replaceAllMapped(
    RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>'),
    (m) => packageGraph.getHtmlFragment(m[1]!) ?? '',
  );
  ```
  The resolved HTML (e.g., `<div>custom content</div>`) passes through VitePress as raw HTML.

**Cross-references — MUST use markdown parser, NOT regex:**

`[ClassName]` references in `documentation` are unresolved bracket notation. Expert
analysis proved that a **regex-based approach is unacceptable** due to edge cases:

| Edge case | Why regex fails |
|-----------|----------------|
| `[operator []]` | Nested brackets confuse regex |
| `` `code with [brackets]` `` | Inline code should not be resolved |
| ```` ```dart\n[list]\n``` ```` | Code fences should not be resolved |
| `[text](url)` | Already-resolved markdown links |
| `[a] and [b]` | Multiple refs per line |

**Chosen approach — markdown parser with link collector:**

1. Parse `documentation` text through `md.Document` (already a dependency)
2. Pass a custom `linkResolver` callback to collect all bracket references and their
   resolved targets (using `getMatchingLinkElement()` from `markdown_processor.dart:164-180`)
3. Build a `Map<String, String>` of `bracketRef → vitePressUrl`
4. Serialize the AST back to markdown with resolved links using a lightweight
   `MarkdownRenderer` (walks AST nodes, outputs markdown text)

The markdown parser already handles ALL edge cases (code blocks, inline code,
existing links, nested brackets) correctly — we get this for free.

**Alternative considered:** Use linkResolver as collector only, then do targeted
string replacements on the original text using exact match positions. Simpler but
fragile — requires exact position tracking through AST.

### ADR-4: All-in-one class pages with anchors

**Decision:** Embed ALL members (constructors, methods, properties, operators)
on the class/enum/mixin/extension page. Make `generateMethod()`, `generateConstructor()`,
`generateProperty()` no-ops.

**Rationale:**

| Criterion | Separate pages | All-in-one |
|-----------|---------------|------------|
| File count | Hundreds (20 members = 21 files) | One per class |
| VitePress build | Slow (each .md = Vue SFC) | Fast |
| Navigation | Page reload per member | Anchor nav + `outline: [2, 3]` TOC |
| Search | Per-page isolation | VitePress still indexes anchors |
| VitePress idiom | Not typical | Standard for API docs |
| Incremental gen | Complex tracking | Simple (one file per class) |

Cross-references to members use anchor syntax:
- `[Binder.get]` -> `[Binder.get](/api/modularity_contracts/Binder#get)`

### ADR-5: String building, not Mustache templates

**Decision:** Direct StringBuffer-based rendering.

**Rationale:** Markdown is structurally simpler than HTML. Mustache templates
use AOT-compiled Mustachio renderers -- setting up parallel pipeline would be
enormous overhead. String building gives precise control and fast iteration.

### ADR-6: Never use `linkedName`, `linkedParams`, or HTML-producing model properties

**Decision:** Access raw model properties only. Build markdown strings ourselves.

**HTML-producing properties to AVOID:**

| Property | What it produces | Use instead |
|----------|-----------------|-------------|
| `linkedName` | `<a href="...">text</a>` (model_element.dart:715-744) | `name` + `VitePressPathResolver.linkFor()` |
| `linkedParams` | HTML `<span>` tags | iterate `parameters` manually |
| `linkedGenericParameters` | HTML with `&lt;` entities | `typeParameters` + escape |
| `modelType.linkedName` | HTML `<a>` tags | `modelType.name` |
| `documentationAsHtml` | full HTML | `documentation` getter |
| `attributesAsString` | HTML `<span>` tags (model_element.dart:443-449) | iterate annotations |
| `arrow` (getter_setter_combo.dart:253) | HTML entities (`&#8594;`) | unicode `->` |
| `nameWithGenerics` (multiple) | HTML entities | `name` + `typeParameters` |

### ADR-7: Generic type escaping strategy

**Decision:** Build plain-text generic names manually from `name` + `typeParameters`.
Apply context-dependent escaping.

**Problem:** `nameWithGenerics` on `ModelElement` (via `TypeParameters` mixin at
`type_parameter.dart:64-95`) ALWAYS produces HTML-escaped output (`&lt;`, `<span>`,
`<wbr>`). There is NO `nameWithGenericsPlain` on `ModelElement` — it only exists
on `ElementType` (at `element_type_renderer.dart:45-66` via `plain: true`).

**Solution:** Build plain name from raw properties:
```dart
String plainNameWithGenerics(ModelElement element) {
  if (element is TypeParameters && element.typeParameters.isNotEmpty) {
    final params = element.typeParameters.map((tp) => tp.name).join(', ');
    return '${element.name}<$params>';
  }
  return element.name;
}
```

**Context-dependent escaping rules:**

| Context | Input | Output | Why |
|---------|-------|--------|-----|
| Markdown heading | `Map<String, List<int>>` | `Map\<String, List\<int\>\>` | `<>` parsed as HTML tags |
| Inline text | `Map<String, List<int>>` | `Map\<String, List\<int\>\>` | Same reason |
| Code fence (` ``` `) | `Map<String, List<int>>` | `Map<String, List<int>>` | Raw, no escaping needed |
| Inline code (`` ` ``) | `Map<String, List<int>>` | `Map<String, List<int>>` | Raw, no escaping needed |
| YAML frontmatter title | `Map<String, List<int>>` | `"Map<String, List<int>>"` | Quoted string, safe |
| Anchor `{#id}` | `get<T>` | `{#get}` | Strip generics from anchors |

**IMPORTANT — `TypeParameter.name` contains HTML:**
`TypeParameter.name` (at `type_parameter.dart:40-42`) uses `boundType!.nameWithGenerics`,
which produces HTML. Must use `tp.element.name!` for plain name and
`tp.boundType?.nameWithGenericsPlain` for the bound.

**For type parameters with bounds** (e.g., `<T extends Comparable<T>>`):
```dart
String plainTypeParam(TypeParameter tp) {
  var result = tp.element.name!;  // NOT tp.name — that contains HTML!
  final bound = tp.boundType;
  if (bound != null) result += ' extends ${bound.nameWithGenericsPlain}';
  return result;
}
```

---

## Output Specification

### File structure

```
<output>/
+-- .vitepress/
|   +-- generated/
|       +-- api-sidebar.ts                    <- auto-generated sidebar data
+-- api/
|   +-- index.md                              <- package overview
|   +-- <library_dirName>/
|   |   +-- index.md                          <- library overview
|   |   +-- <ClassName>.md                    <- class page (ALL members as sections)
|   |   +-- <EnumName>.md                     <- enum page (ALL members as sections)
|   |   +-- <MixinName>.md                    <- mixin page (ALL members as sections)
|   |   +-- <ExtensionName>.md                <- extension page
|   |   +-- <ExtensionTypeName>.md            <- extension type page
|   |   +-- <FunctionName>.md                 <- top-level function (one page each)
|   |   +-- <PropertyName>.md                 <- top-level property/constant
|   |   +-- <TypedefName>.md                  <- typedef
|   +-- <library2_dirName>/
|       +-- ...
+-- topics/                                   <- only if categories exist
|   +-- <CategoryName>.md
+-- (init-only scaffold, never overwritten)
    +-- package.json
    +-- index.md                              <- hero landing page
    +-- .vitepress/
        +-- config.ts
```

### Complete element type coverage

| Element | Page type | Output path | Source for members |
|---------|-----------|-------------|-------------------|
| Package | overview | `api/index.md` | `package.libraries` |
| Category | topic page | `topics/<name>.md` | `category.dart:100-112` |
| Library | overview + table | `api/<dirName>/index.md` | all `publicXxxSorted` getters |
| Class | full page + all members | `api/<dirName>/<Name>.md` | constructors, methods, fields, operators |
| Enum | full page + values + members | `api/<dirName>/<Name>.md` | enum values, methods, fields |
| Mixin | full page + members | `api/<dirName>/<Name>.md` | superclass constraints, methods, fields |
| Extension | full page + members | `api/<dirName>/<Name>.md` | extended type, methods, fields |
| ExtensionType | full page + members | `api/<dirName>/<Name>.md` | representation type, constructors, methods |
| Top-level function | single page | `api/<dirName>/<Name>.md` | signature, docs, source |
| Top-level property | single page | `api/<dirName>/<Name>.md` | type, docs, source |
| Top-level constant | single page | `api/<dirName>/<Name>.md` | type, value, docs |
| Typedef | single page | `api/<dirName>/<Name>.md` | aliased type, docs |
| Constructor | NO separate page | anchor `#<name>` on class page | -- |
| Method | NO separate page | anchor `#<name>` on class page | -- |
| Property/Field | NO separate page | anchor `#<name>` on class page | -- |
| Operator | NO separate page | anchor `#operator-<name>` on class page | -- |

### Collision avoidance

Elements named "index" would collide with library `index.md`:
- Function "index" -> `index-function.md`
- Enum "index" -> `index-enum.md`
- Typedef "index" -> `index-typedef.md`
- Class "index" -> `index-class.md`
- Property "index" -> `index-property.md`

### Ownership rules

| Path | Owner | When updated |
|------|-------|-------------|
| `api/**/*.md` | Tool | Every `generate` (incremental) |
| `topics/**/*.md` | Tool | Every `generate` |
| `.vitepress/generated/api-sidebar.ts` | Tool | Every `generate` |
| `package.json` | User | `--init` only, never overwritten |
| `.vitepress/config.ts` | User | `--init` only, never overwritten |
| `index.md` (root) | User | `--init` only, never overwritten |
| Everything else | User | Never touched |

---

## Path Mapping: dartdoc HTML -> VitePress

| dartdoc HTML path | VitePress path | VitePress URL |
|---|---|---|
| `index.html` | `api/index.md` | `/api/` |
| `topics/MyTopic-topic.html` | `topics/MyTopic.md` | `/topics/MyTopic` |
| `modularity_core/index.html` | `api/modularity_core/index.md` | `/api/modularity_core/` |
| `modularity_core/SimpleBinder-class.html` | `api/modularity_core/SimpleBinder.md` | `/api/modularity_core/SimpleBinder` |
| `modularity_core/SimpleBinder/get.html` | (anchor on class page) | `/api/modularity_core/SimpleBinder#get` |
| `modularity_core/SimpleBinder/SimpleBinder.html` | (anchor on class page) | `/api/modularity_core/SimpleBinder#simplebinder` |
| `modularity_core/ModuleRetentionPolicy.html` | `api/modularity_core/ModuleRetentionPolicy.md` | `/api/modularity_core/ModuleRetentionPolicy` |
| `modularity_core/MyMixin-mixin.html` | `api/modularity_core/MyMixin.md` | `/api/modularity_core/MyMixin` |
| `modularity_core/MyExtType-extension-type.html` | `api/modularity_core/MyExtType.md` | `/api/modularity_core/MyExtType` |

### Cross-reference link rules

| Reference in doc comment | Generated markdown link |
|---|---|
| `[SimpleBinder]` | `[SimpleBinder](/api/modularity_core/SimpleBinder)` |
| `[Binder.get]` | `[Binder.get](/api/modularity_contracts/Binder#get)` |
| `[DependencyNotFoundException]` | `[DependencyNotFoundException](/api/modularity_contracts/DependencyNotFoundException)` |
| `[ModuleRetentionPolicy.lazy]` | `[ModuleRetentionPolicy.lazy](/api/modularity_core/ModuleRetentionPolicy#lazy)` |

Rule:
- Container-level elements -> `/api/<dirName>/<Name>`
- Member-level elements -> `/api/<dirName>/<ContainerName>#<memberName>`

---

## Markdown Page Templates

### Class page

```markdown
---
title: "SimpleBinder"
description: "API documentation for SimpleBinder class from modularity_core"
outline: [2, 3]
---

# SimpleBinder

`sealed class SimpleBinder implements Binder, RegistrationAwareBinder`

Default in-memory dependency injection container for the Modularity framework.

## Constructors

### SimpleBinder() {#simplebinder}

```dart
SimpleBinder({Binder? parent, List<Binder> imports = const []})
```

Creates a new binder with optional [parent](/api/modularity_core/SimpleBinder#parent)
scope and [imports](/api/modularity_core/SimpleBinder#imports).

## Properties

### parent {#parent}

```dart
Binder? get parent
```

The parent binder for hierarchical lookups.

### imports {#imports}

```dart
List<Binder> get imports
```

List of imported binders whose public registrations are accessible.

## Methods

### get\<T\>() {#get}

```dart
T get<T>()
```

Resolves a dependency of type [T]. Lookup order: local -> imports -> parent.

**Throws:** [DependencyNotFoundException](/api/modularity_contracts/DependencyNotFoundException)
if [T] is not registered.

## Operators

### operator ==() {#operator-equals}

```dart
bool operator ==(Object other)
```

*Inherited from Object.*

## Static Methods

(if any)

## Constants

(if any)
```

Section order within container page:
1. Constructors (if `Constructable`)
2. Properties (instance fields, declared + inherited)
3. Methods (instance methods, declared + inherited)
4. Operators (instance operators)
5. Static Properties
6. Static Methods
7. Constants

### Class declaration line

Must render Dart 3 class modifiers from `containerModifiers` (`inheriting_container.dart:83-90`):
- `sealed class`, `abstract base class`, `final class`, `interface class`, `mixin class`
- Plus `implements`, `extends`, `with` clauses

### Library overview page

```markdown
---
title: "modularity_core"
description: "API documentation for the modularity_core library"
outline: [2, 3]
---

# modularity_core

Core dependency injection and module lifecycle management.

## Classes

| Class | Description |
|---|---|
| [SimpleBinder](/api/modularity_core/SimpleBinder) | Default in-memory DI container. |
| [ModuleController](/api/modularity_core/ModuleController) | Controls module lifecycle. |

## Enums

| Enum | Description |
|---|---|
| [ModuleRetentionPolicy](/api/modularity_core/ModuleRetentionPolicy) | Policy for retaining module state. |

## Functions

| Function | Description |
|---|---|
| [resolveGraph](/api/modularity_core/resolveGraph) | Resolves the dependency graph. |

## Extensions

(if any, with "on Type" column)

## Extension Types

(if any)

## Typedefs

(if any)
```

Element groups in library pages, in this order:
1. Classes (from `lib.publicClassesSorted`)
2. Exceptions (from `lib.publicExceptionsSorted`)
3. Enums (from `lib.publicEnumsSorted`)
4. Mixins (from `lib.publicMixinsSorted`)
5. Extensions (from `lib.publicExtensionsSorted`)
6. Extension Types (from `lib.publicExtensionTypesSorted`)
7. Constants (from `lib.publicConstantsSorted`)
8. Properties (from `lib.publicPropertiesSorted`)
9. Functions (from `lib.publicFunctionsSorted`)
10. Typedefs (from `lib.publicTypedefsSorted`)

Empty groups are omitted.

### Frontmatter per page type

All generated pages include these VitePress frontmatter keys to disable irrelevant features:

```yaml
---
editLink: false      # no "Edit this page" link (generated, not hand-written)
lastUpdated: false   # no "Last updated" timestamp
prev: false          # no prev/next navigation (API docs are non-linear)
next: false
---
```

| Page type | `outline` | Rationale |
|-----------|-----------|-----------|
| Package overview | `false` | High-level, no useful TOC |
| Library overview | `[2, 3]` | Groups + element names in TOC |
| Class/Enum/Mixin/Extension page | `[2, 3]` | Sections + members in TOC |
| Top-level function | `false` | Single function, minimal structure |
| Top-level property/constant | `false` | Single item |
| Typedef | `false` | Single item |

---

## Sidebar Specification

### File: `.vitepress/generated/api-sidebar.ts`

```typescript
// AUTO-GENERATED by dartdoc-vitepress -- do not edit manually.
import type { DefaultTheme } from 'vitepress'

export const apiSidebar: DefaultTheme.SidebarItem[] = [
  {
    text: 'modularity_contracts',
    collapsed: false,
    items: [
      { text: 'Overview', link: '/api/modularity_contracts/' },
      {
        text: 'Classes',
        collapsed: false,
        items: [
          { text: 'Binder', link: '/api/modularity_contracts/Binder' },
          { text: 'ExportableBinder', link: '/api/modularity_contracts/ExportableBinder' },
          { text: 'Module', link: '/api/modularity_contracts/Module' },
        ],
      },
      {
        text: 'Exceptions',
        collapsed: false,
        items: [
          { text: 'ModularityException', link: '/api/modularity_contracts/ModularityException' },
          { text: 'CircularDependencyException', link: '/api/modularity_contracts/CircularDependencyException' },
          { text: 'DependencyNotFoundException', link: '/api/modularity_contracts/DependencyNotFoundException' },
          { text: 'ModuleConfigurationException', link: '/api/modularity_contracts/ModuleConfigurationException' },
          { text: 'ModuleLifecycleException', link: '/api/modularity_contracts/ModuleLifecycleException' },
        ],
      },
    ],
  },
]
```

### Sidebar generation rules

1. One `SidebarItem` per library in `packageGraph.localPackages` -> `package.libraries.whereDocumented`
2. Within each library, sub-groups by kind in this order:
   Classes, Exceptions, Enums, Mixins, Extensions, Extension Types, Functions, Properties, Typedefs
3. Empty groups omitted
4. **Collapse thresholds** (based on real-world package analysis):
   - `collapsed: false` for groups with ≤8 items (classes) or ≤10 items (functions)
   - `collapsed: true` for groups exceeding threshold
   - Library-level groups: `collapsed: false` for libraries with ≤30 total elements
5. Multi-package: if `localPackages.length > 1`, wrap libraries in package-level groups

### Category-based sub-grouping (optional)

If a library uses `{@category}` annotations (`category.dart:100-112`), sub-group
elements within their kind group by category:

```typescript
{
  text: 'Classes',
  collapsed: false,
  items: [
    {
      text: 'Binders',         // ← category name
      collapsed: false,
      items: [
        { text: 'Binder', link: '/api/modularity_contracts/Binder' },
        { text: 'ExportableBinder', link: '/api/modularity_contracts/ExportableBinder' },
      ],
    },
    {
      text: 'Exceptions',      // ← category name
      collapsed: false,
      items: [
        { text: 'ModularityException', link: '/api/modularity_contracts/ModularityException' },
      ],
    },
  ],
}
```

Category grouping activates only when ≥2 categories exist in a kind group.
Uncategorized elements appear in an "Other" sub-group at the end.

### Sidebar `base` property for path deduplication

Use VitePress `base` property on library groups to eliminate path repetition (~30% size reduction):

```typescript
{
  text: 'modularity_contracts',
  collapsed: false,
  base: '/api/modularity_contracts/',    // ← all child links are relative to this
  items: [
    { text: 'Overview', link: '/' },     // ← resolves to /api/modularity_contracts/
    {
      text: 'Classes',
      items: [
        { text: 'Binder', link: '/Binder' },   // ← resolves to /api/modularity_contracts/Binder
        { text: 'Module', link: '/Module' },
      ],
    },
  ],
}
```

### Path-based sidebar routing for large monorepos

For multi-package workspaces, use VitePress path-based sidebar routing to show
only the current library's sidebar:

```typescript
// .vitepress/config.ts
sidebar: {
  '/api/modularity_contracts/': contractsSidebar,
  '/api/modularity_core/': coreSidebar,
  '/api/modularity_flutter/': flutterSidebar,
  '/api/': overviewSidebar,  // ← fallback for package index
}
```

This is generated as separate exports in `api-sidebar.ts`:
```typescript
export const apiSidebar: Record<string, DefaultTheme.SidebarItem[]> = { ... }
```

**Threshold:** Path-based routing activates when total element count > 100 across
all libraries. Below that, a single flat sidebar is used.

---

## Deprecated Element Rendering

Elements with `@Deprecated` annotation are rendered with visual indicators using VitePress components:

### On container pages (class/enum/mixin/extension)

```markdown
# ~~DeprecatedClass~~ <Badge type="warning" text="deprecated" />

`class DeprecatedClass`

:::warning DEPRECATED
Use [NewClass](/api/lib/NewClass) instead.
:::

Rest of documentation...
```

### In library overview tables

```markdown
| Class | Description |
|---|---|
| [ActiveClass](/api/lib/ActiveClass) | Does something useful. |
| ~~[DeprecatedClass](/api/lib/DeprecatedClass)~~ | **Deprecated.** Use NewClass instead. |
```

### Member sections on container pages

```markdown
### ~~oldMethod()~~ {#oldmethod} <Badge type="warning" text="deprecated" />

\`\`\`dart
void oldMethod()
\`\`\`

:::warning DEPRECATED
Use [newMethod](#newmethod) instead.
:::
```

### Detection

- Check `element.isDeprecated` (bool property on `ModelElement`)
- Deprecation message from `element.annotations` → find `@Deprecated('message')`

---

## oneLineDoc Strategy

Library overview tables need a one-line description for each element. The model's `oneLineDoc`
property produces HTML. Instead, extract the first paragraph from the raw `documentation` getter:

```dart
String extractOneLineDoc(ModelElement element) {
  final doc = element.documentation;
  if (doc.isEmpty) return '';
  // Take first paragraph (up to first blank line or end)
  final firstPara = doc.split(RegExp(r'\n\s*\n')).first.trim();
  // Collapse to single line
  return firstPara.replaceAll('\n', ' ');
}
```

This returns raw markdown (may contain `[references]`) which gets processed by the
doc processor like any other documentation text.

---

## canonicalLibrary for Re-exported Elements

When computing paths for cross-references, elements may be re-exported from multiple
libraries. Always use `canonicalLibrary` (not `library`) for path resolution:

```dart
String pathForElement(ModelElement element) {
  final lib = element.canonicalLibrary;
  if (lib == null) {
    // Private element or unresolvable — skip link, render as plain text
    return element.name;
  }
  return '/api/${lib.dirName}/${element.name}';
}
```

`canonicalLibrary` is nullable for private elements — always use null-safety guard.

---

## Implementation Phases

### Phase 1: Skeleton + CLI wiring (Day 1-3)

**Modified files (3):**

1. **`lib/src/dartdoc_options.dart`** (~5 lines)
   - Add `format` option in `createDartdocOptions()`:
     ```dart
     DartdocOptionArgFile<String>('format', 'html', resourceProvider,
         help: 'Output format: html or vitepress.',
         allowedValues: ['html', 'vitepress']),
     ```
   - Expose in `DartdocOptionContext`: `String get format => optionSet['format'].valueAt(context);`

2. **`lib/src/dartdoc.dart`** (~10 lines)
   - In `Dartdoc.fromContext()` at line 182, branch on format:
     ```dart
     var generator = context.format == 'vitepress'
         ? initVitePressGenerator(context, writer: writer)
         : initHtmlGenerator(context, writer: writer);
     ```
   - Skip HTML link validator for VitePress format (lines 203-208)

3. **`lib/src/generator/generator.dart`** (~15 lines)
   - Add `initVitePressGenerator()` function:
     ```dart
     Generator initVitePressGenerator(
       DartdocGeneratorOptionContext context, {
       required FileWriter writer,
     }) {
       var options = DartdocGeneratorBackendOptions.fromContext(context);
       var generatorBackend = VitePressGeneratorBackend(
           options, writer, context.resourceProvider);
       return Generator(generatorBackend);
     }
     ```

**New file:**

4. **`lib/src/generator/vitepress_generator_backend.dart`** (~300-400 lines)
   - `extends GeneratorBackend`
   - Constructor passes `_NoOpTemplates()` to super
   - Overrides all 17 `generate*()` methods:
     - `generatePackage()` -- writes `api/index.md` via renderer
     - `generateLibrary()` -- writes `api/<dirName>/index.md` via renderer
     - `generateClass()` -- writes `api/<dirName>/<Name>.md` with all members inlined
     - `generateEnum()` -- same pattern, plus enum values
     - `generateMixin()` -- same pattern, plus superclass constraints
     - `generateExtension()` -- same pattern, plus extended type
     - `generateExtensionType()` -- same pattern, plus representation type
     - `generateFunction()` -- writes `api/<dirName>/<Name>.md` for top-level function
     - `generateTopLevelProperty()` -- writes `api/<dirName>/<Name>.md`
     - `generateTypeDef()` -- writes `api/<dirName>/<Name>.md`
     - `generateCategory()` -- writes `topics/<Name>.md` (no redirect)
     - `generateConstructor()` -- **NO-OP** (embedded in class page)
     - `generateMethod()` -- **NO-OP** (embedded in class page)
     - `generateProperty()` -- **NO-OP** (embedded in class page)
     - `generateSearchIndex()` -- **NO-OP** (VitePress has built-in search)
     - `generateCategoryJson()` -- **NO-OP**
     - `generateAdditionalFiles()` -- **NO-OP** (called BEFORE traversal at generator.dart:48!)
   - **Sidebar generated in `generatePackage()`** — this is the LAST container-level method
     called by the traversal. At this point the full PackageGraph is available.
     Sidebar is built from `packageGraph.localPackages` → libraries → elements.
   - Overrides `write()` to skip `htmlBasePlaceholder` logic, write .md files

**Verify:** `dartdoc --format vitepress --output docs/` produces empty-stub .md files.

### Phase 2: Path resolver + doc processor (Day 3-5)

**New files:**

5. **`lib/src/generator/vitepress_paths.dart`** (~100 lines)
   - `VitePressPathResolver` class:
     ```dart
     String filePathFor(Documentable element)  // -> api/<dir>/<Name>.md
     String urlFor(Documentable element)       // -> /api/<dir>/<Name>
     String anchorFor(ModelElement element)     // -> #memberName
     String linkFor(Documentable element)      // -> full URL or URL#anchor
     ```
   - Handles collision avoidance (elements named "index")
   - Uses `library.dirName` (computed at `library.dart:147-175`)
   - Never reads `element.fileName`, `element.filePath`, or `element.href`

6. **`lib/src/generator/vitepress_doc_processor.dart`** (~250 lines)
   - Takes a `ModelElement`, reads its `documentation` getter (pre-HTML markdown)
   - Replaces `<p>` joiners with `\n\n` (safety net — confirmed dead code in practice)
   - **Resolves `{@inject-html}` placeholders BEFORE markdown parsing:**
     ```dart
     text = text.replaceAllMapped(
       RegExp(r'<dartdoc-html>([a-f0-9]+)</dartdoc-html>'),
       (m) => packageGraph.getHtmlFragment(m[1]!) ?? '',
     );
     ```
   - **Cross-reference resolution via markdown parser (NOT regex):**
     1. Parse documentation through `md.Document` with `encodeHtml: false` and custom `linkResolver`
     2. `linkResolver` callback uses `getMatchingLinkElement()` from
        `markdown_processor.dart:164-180` to resolve each bracket reference
     3. Returns `md.Element('a', [md.Text(referenceText)])..attributes['href'] = vitePressUrl`
     4. `MarkdownRenderer` (~250 lines) walks AST, serializes back to markdown
        with resolved links: `[ClassName]` → `[ClassName](/api/lib/ClassName)`
   - **`encodeHtml: false` requirement:**
     Must pass `encodeHtml: false` to `md.Document` so HTML in documentation
     (from `{@youtube}`, `{@inject-html}`, etc.) is NOT escaped to `&lt;`/`&gt;`.
   - **Note on `_htmlEscape` in markdown_processor.dart:**
     Three locations use `_htmlEscape.convert()` for HTML output:
     - `_makeLinkNode()` (line 309-339) — `<a>` tag generation
     - `_InlineCodeSyntax` (line 342-351) — inline code
     - `_AutolinkWithoutScheme` (line 353-364) — auto-links
     These are NOT called in our pipeline (we use our own `linkResolver` callback
     that returns `Element` nodes directly, not HTML strings). No changes needed.
   - Handles `{@youtube}` / `{@animation}` HTML output (pass through as raw HTML)
   - Escapes generic types in non-fenced text: `<T>` → `\<T\>` (per ADR-7)

   The `MarkdownRenderer` (~250 lines) serializes the markdown v7 AST back to markdown.
   **IMPORTANT:** markdown v7 uses only `Element` (with `tag` string) and `Text` nodes —
   there are NO named classes like `Emph`, `Strong`, `Link` etc.

   AST node types handled (via `element.tag`):
   - `Text` node — literal text content
   - `Element` with tag `em` — `*text*`
   - `Element` with tag `strong` — `**text**`
   - `Element` with tag `code` — `` `text` `` (no escaping inside)
   - `Element` with tag `a` — `[text](href)` (resolved links)
   - `Element` with tag `p` — paragraph with trailing `\n\n`
   - `Element` with tag `h1`..`h6` — `#`..`######` heading
   - `Element` with tag `blockquote` — `> text`
   - `Element` with tag `li` — list item with `- ` or `1. ` prefix
   - `Element` with tag `pre` > `code` — fenced code block (no escaping inside)
   - `Element` with tag `table`, `thead`, `tbody`, `tr`, `th`, `td` — markdown tables
   - Raw HTML nodes — pass through (handles `{@youtube}` iframes, resolved `{@inject-html}`)

### Phase 3: Renderers (Day 5-10)

**New file:**

7. **`lib/src/generator/vitepress_renderer.dart`** (~500 lines)
   - Pure functions taking model objects (NOT TemplateData) + path resolver + doc processor:
     ```dart
     String renderPackagePage(Package package, VitePressPathResolver paths)
     String renderLibraryPage(Library library, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderClassPage(Class clazz, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderEnumPage(Enum enumeration, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderMixinPage(Mixin mixin_, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderExtensionPage(Extension ext, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderExtensionTypePage(ExtensionType et, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderFunctionPage(ModelFunction func, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderPropertyPage(TopLevelVariable prop, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderTypedefPage(Typedef td, VitePressPathResolver paths, VitePressDocProcessor docs)
     String renderCategoryPage(Category cat, VitePressPathResolver paths)
     ```
   - Shared helpers: `MarkdownPageBuilder` for frontmatter, escaping, sections
   - Accesses model data through raw properties:
     - `element.name` (not `linkedName`)
     - `element.documentation` (not `documentationAsHtml`)
     - `element.parameters` (iterate manually, not `linkedParams`)
     - `modelType.name` (not `modelType.linkedName`)
     - `modelNode?.sourceCode` for source embedding (**NOT** `element.sourceCode` —
       `ModelElement.sourceCode` at `model_element.dart:823` applies `HtmlEscape().convert()`.
       Use `SourceCodeMixin.sourceCode` from `source_code_mixin.dart:17-20` via `modelNode`
       which returns raw, unescaped source code)
   - Each container page renders ALL its members:
     - `clazz.publicConstructorsSorted`
     - `clazz.availableInstanceFieldsSorted`
     - `clazz.availableInstanceMethodsSorted`
     - `clazz.availableInstanceOperatorsSorted`
     - `clazz.publicVariableStaticFieldsSorted`
     - `clazz.publicStaticMethodsSorted`
     - `clazz.publicConstantFieldsSorted`
   - Renders class modifiers from `containerModifiers` (sealed/base/final/interface/mixin)
   - Marks inherited members with `*Inherited from ClassName.*`
   - Escapes `<T>` generics in headers: `### get\<T\>()`

### Phase 4: Sidebar generator (Day 10-12)

**New file:**

8. **`lib/src/generator/vitepress_sidebar_generator.dart`** (~180 lines)
   - Traverses `PackageGraph` -> libraries -> elements
   - Groups by kind: Classes, Exceptions, Enums, Mixins, Extensions,
     ExtensionTypes, Functions, Properties, Typedefs
   - **Category-based sub-grouping:** If `{@category}` annotations present,
     group elements within kind groups by category name
   - **Adaptive collapse thresholds:** ≤8 items (classes) or ≤10 items (functions)
     → expanded; above → collapsed
   - **Path-based routing:** If total elements > 100, generate per-library sidebar
     exports as `Record<string, SidebarItem[]>` for VitePress path-based routing
   - **Single sidebar:** If total elements ≤ 100, generate flat `SidebarItem[]`
   - Generates `.vitepress/generated/api-sidebar.ts`
   - Multi-package support with package-level nesting

### Phase 5: Init scaffold (Day 12-14)

**New file:**

9. **`lib/src/generator/vitepress_init.dart`** (~100 lines)
   - `dartdoc --format vitepress --output docs/ --init` creates:
     - `package.json` with `vitepress: ^1.6.4`
     - `.vitepress/config.ts` importing `./generated/api-sidebar`
     - `index.md` with VitePress hero section
   - Only creates files that don't exist (never overwrites)
   - `--init` should NOT trigger doc generation (scaffold only)

### Phase 6: Incremental generation + polish (Day 14-18)

**Modify:** `vitepress_generator_backend.dart`
- Content comparison before write (skip if identical)
- **Manifest-based stale file deletion:**
  - Collect all expected output paths during generation into a `Set<String>`
  - After generation, scan `api/` directory for existing `.md` files
  - Delete files not in the manifest (stale from renamed/removed elements)
  - Write manifest to `.vitepress/generated/.manifest` for debugging
- Summary logging: `Generated: 12 written, 3 unchanged, 2 deleted`

---

## Files Changed Summary

### Modified existing files (3):

| File | Change | Lines |
|------|--------|-------|
| `lib/src/dartdoc_options.dart` | Add `format` option | ~5 |
| `lib/src/dartdoc.dart` | Branch in `fromContext()`, skip validator | ~10 |
| `lib/src/generator/generator.dart` | Add `initVitePressGenerator()` | ~15 |

### New files (6):

| File | Purpose | Lines |
|------|---------|-------|
| `lib/src/generator/vitepress_generator_backend.dart` | Backend extending GeneratorBackend | ~300-400 |
| `lib/src/generator/vitepress_renderer.dart` | Markdown rendering functions | ~500 |
| `lib/src/generator/vitepress_paths.dart` | VitePress path computation | ~100 |
| `lib/src/generator/vitepress_doc_processor.dart` | Doc processing + {@inject-html} resolution + markdown parser link resolution + MarkdownRenderer (~250 lines) | ~400 |
| `lib/src/generator/vitepress_sidebar_generator.dart` | Sidebar TS generation (category grouping, path-based routing) | ~180 |
| `lib/src/generator/vitepress_init.dart` | Project scaffold generation | ~100 |

**Total: ~30 modified lines, ~1610 new lines**

---

## Known Edge Cases

| Edge case | Handling | Confidence |
|-----------|---------|------------|
| `<T>` generics in markdown headers | Escape: `\<T\>` outside code fences (ADR-7) | **Confirmed** |
| `<T>` generics in inline text | Escape: `\<T\>` (ADR-7) | **Confirmed** |
| `<T>` generics in code fences/inline code | No escaping needed — raw text | **Confirmed** |
| `<T>` generics in YAML frontmatter | Quote the title string | **Confirmed** |
| `<T extends Comparable<T>>` bounded types | Build from `tp.element.name!` + `tp.boundType?.nameWithGenericsPlain` | **Confirmed** |
| Elements named "index" | Append suffix: `index-class.md` | Confirmed |
| `{@youtube}` producing `<iframe>` HTML | Pass through (VitePress handles raw HTML) | **Confirmed** |
| `{@animation}` producing `<div>` + `<video>` | Pass through | **Confirmed** |
| `{@template}` with bracket refs inside | Refs survive through `{@macro}` substitution | **Confirmed** |
| `{@inject-html}` directive | Resolve `<dartdoc-html>DIGEST</dartdoc-html>` via `packageGraph.getHtmlFragment()` BEFORE markdown parsing | **Confirmed** |
| `[ClassName]` bracket references | Resolved via markdown parser + linkResolver (NOT regex) | **Confirmed** |
| `[operator []]` nested brackets | Handled by markdown parser (regex would fail) | **Confirmed** |
| `` `code [with brackets]` `` | Markdown parser skips inline code | **Confirmed** |
| `[text](url)` existing links | Markdown parser preserves them | **Confirmed** |
| Operator names (`operator ==`) | Anchor: `#operator-equals` using `operatorNames` map | Confirmed |
| Anonymous libraries (no `library` directive) | `library.dirName` handles this (library.dart:147-175) | Confirmed |
| Inherited members | Transparently handled by `documentation` getter — follows inheritance chain | **Confirmed** |
| `documentation` joining with `<p>` | Dead code — never fires in practice. Safety: replace `<p>` with `\n\n` | **Confirmed** |
| Getter+setter doc merging | Already uses `\n\n` (`getter_setter_combo.dart:196-210`) — no special handling | **Confirmed** |
| `htmlBasePlaceholder` in doc strings | Strip during doc processing | Confirmed |
| Dart 3 class modifiers (sealed/base/final) | Render from `containerModifiers` | Confirmed |
| Multi-package workspace | Package-level sidebar nesting or path-based routing | Confirmed |
| Large packages (100+ public elements) | Path-based sidebar routing, category sub-grouping | **Confirmed** |
| `nameWithGenerics` on ModelElement | NO plain-text variant exists — build manually (ADR-7) | **Confirmed** |
| `element.sourceCode` HTML-escaped | Use `modelNode?.sourceCode` (raw) from `source_code_mixin.dart:17-20` | **Confirmed** |
| `oneLineDoc` produces HTML | Extract first paragraph from `documentation` getter instead | **Confirmed** |
| `constantValue` HTML-escaped | Use `constantValueBase` without `_htmlEscape.convert()` — or un-escape | **Confirmed** |
| Re-exported elements (`canonicalLibrary`) | Use `element.canonicalLibrary?.dirName` with null-safety guard | **Confirmed** |
| Deprecated elements rendering | VitePress `<Badge type="warning">` + `:::warning DEPRECATED` container | **Confirmed** |
| `TypeParameter.name` contains HTML | Use `tp.element.name!` + `tp.boundType?.nameWithGenericsPlain` | **Confirmed** |

---

## CLI Interface

```bash
# Generate VitePress docs (main command)
dartdoc --format vitepress --output docs/

# Initialize VitePress project scaffold (first time, no generation)
dartdoc --format vitepress --output docs/ --init

# Original HTML generation (unchanged, default)
dartdoc --output doc/api/
```

`--watch` mode deferred to post-MVP.

---

## What We DON'T Change

- Model layer (`lib/src/model/`) -- untouched (we bypass HTML-producing properties, not modify them)
- Analyzer integration -- untouched
- PackageGraph building -- untouched
- Existing HTML generation -- untouched (still default)
- CLI parsing infrastructure -- only add `format` option
- `bin/dartdoc.dart` -- no changes (format switch is in `Dartdoc.fromContext`)
- Comment reference resolution logic (`getMatchingLinkElement`) -- reused as-is (called from our `linkResolver`)
- `markdown` package dependency -- reused for AST parsing (already in pubspec)

---

## Testing Strategy

### Tier 1: Unit tests

- `test/vitepress_paths_test.dart` -- path computation for every element type (~15 tests)
- `test/vitepress_renderer_test.dart` -- markdown output for each element type (~30 tests)
- `test/vitepress_sidebar_test.dart` -- sidebar TypeScript generation (~10 tests)
- `test/vitepress_doc_processor_test.dart` -- link resolution, escaping (~10 tests)

### Tier 2: Integration tests

- `test/vitepress_generator_test.dart` -- follow `html_generator_test.dart` pattern:
  create `VitePressGeneratorBackend` with `MemoryResourceProvider`, generate docs
  for test package, verify file existence and content (~10 tests)

### Tier 3: End-to-end (post-MVP)

- Generate docs for `modularity_contracts`
- Verify `npx vitepress build docs/` succeeds
- Requires Node.js in CI

---

## Dependencies

No new Dart dependencies needed. Existing dependencies used:
- `markdown: ^7.2.1` -- for markdown AST (already in pubspec)
- `html: ^0.15.3` -- for HTML fragment handling if needed (already in pubspec)
- `path: ^1.8.3` -- path manipulation (already in pubspec)

For the generated VitePress project:
- `vitepress: ^1.6.4` (stable)
- Node.js 18+ (VitePress requirement)

---

## Expert Review Summary (5 deep-dives)

Five focused investigations were conducted on the highest-risk areas of the plan.
Results below. All findings are incorporated into the ADRs and edge cases above.

### 1. Cross-reference resolution (was: High risk → now: Low)

**Finding:** Regex-based approach is unacceptable — fails on `[operator []]`,
code blocks, inline code, existing `[text](url)` links. Must use markdown parser
with custom `linkResolver` callback. The `md.Document` parser already handles
all edge cases correctly. We write a `MarkdownRenderer` (~250 lines, including table support)
to serialize the resolved AST back to markdown.

### 2. Generic type escaping (was: Medium risk → now: Low)

**Finding:** `nameWithGenerics` on `ModelElement` ALWAYS produces HTML (`&lt;`,
`<span>`, `<wbr>`). No plain-text variant exists. Must build from raw `name` +
`typeParameters`. Context-dependent escaping: `\<T\>` in headers/text, raw in
code fences, quoted in YAML. See ADR-7 for full table.

### 3. `documentation` getter verification (was: Medium risk → now: Confirmed)

**Finding:** 100% confirmed with test proof (`model_test.dart:2144`). Bracket
references `[ClassName]` survive completely intact. `{@template}` content with
bracket refs survives through `{@macro}` substitution. `{@youtube}` produces
`<iframe>`, `{@animation}` produces `<div>`+`<video>` — both pass through in
VitePress markdown.

### 4. Inherited documentation (was: Medium risk → now: None)

**Finding:** `documentationFrom` returning multiple elements is effectively dead
code — never happens in practice. `<p>` joiner never fires. Getter+setter doc
merging already uses `\n\n` (`getter_setter_combo.dart:196-210`). Inherited
members get documentation from defining superclass transparently via
`documentation` getter's inheritance chain.

### 5. DX for large packages (was: High risk → now: Low)

**Finding:** Real package analysis — test_package has ~100+ public classes,
modularity has ~50. Category system (`{@category}`) well-suited for sidebar
sub-grouping. Collapse thresholds should be 8 for classes (not 5 as originally
proposed). VitePress search works with anchor-based pages. For monorepos >100
elements, use path-based sidebar routing. See updated Sidebar Specification.

---

## Risk Assessment

| Risk | Severity | Mitigation | Status |
|------|----------|-----------|--------|
| dartdoc upstream breaks GeneratorBackend API | Medium | Only 3 modified files; rebase monthly | Open |
| New element types added upstream (augmentations) | Medium | Missing types = incomplete docs, not crashes | Open |
| `analyzer` dependency bumps | High | Must track upstream quarterly | Open |
| Cross-reference link resolution complexity | ~~High~~ **Low** | Markdown parser approach handles all edge cases (ADR-3) | **Resolved** |
| Markdown escaping with complex generics | ~~Medium~~ **Low** | Definitive escaping strategy per context (ADR-7) | **Resolved** |
| `documentation` getter reliability | ~~Medium~~ **None** | 100% confirmed with test proof (ADR-3) | **Resolved** |
| `<p>` joiner corrupting docs | ~~Medium~~ **None** | Dead code — never fires in practice | **Resolved** |
| Inherited documentation handling | ~~Medium~~ **None** | Transparently handled by getter inheritance chain | **Resolved** |
| DX for large packages (100+ elements) | ~~High~~ **Low** | Category grouping + adaptive thresholds + path-based routing | **Resolved** |
| VitePress 2.0 changes config format | Low | config.ts is user-owned; sidebar format unlikely to change | Open |

---

## Success Criteria

1. `dartdoc --format vitepress --output docs/` generates valid VitePress site
2. All public classes, methods, properties, enums, mixins, extensions, extension types, typedefs documented
3. Cross-references between elements work as markdown links
4. Sidebar navigation reflects package structure with all element kinds
5. `npx vitepress build docs/` produces working static site
6. Running against `modularity_contracts` produces correct output
7. Dart 3 class modifiers (sealed/base/final) rendered correctly

---

## Confidence Assessment

After 5 focused expert deep-dives + 3 rounds of team review, confidence upgraded from **7/10 → 9/10**.

**Estimated timeline: 18 working days** (revised from initial 9-day estimate after team review).

| Area | Before | After | Why |
|------|--------|-------|-----|
| Cross-reference resolution | Uncertain | **Solved** | Markdown parser approach proven correct |
| Generic escaping | Uncertain | **Solved** | Definitive strategy with context table |
| `documentation` getter | Probable | **Confirmed** | Test proof from dartdoc's own test suite |
| Inherited documentation | Uncertain | **Confirmed** | Dead code paths identified and verified |
| Large package DX | Uncertain | **Solved** | Category grouping + adaptive thresholds + path routing |
| Sidebar timing | Wrong | **Solved** | Generate in `generatePackage()`, not `generateAdditionalFiles()` |
| `{@inject-html}` handling | Wrong | **Solved** | Resolve placeholders BEFORE markdown parsing |
| `sourceCode` HTML escaping | Unknown | **Solved** | Use `modelNode?.sourceCode` (raw) |
| `oneLineDoc` HTML output | Unknown | **Solved** | Parse first paragraph from `documentation` getter |
| `TypeParameter.name` HTML | Unknown | **Solved** | Use `tp.element.name!` + `tp.boundType?.nameWithGenericsPlain` |
| `canonicalLibrary` nullable | Unknown | **Solved** | Null-safety guard for private elements |
| Deprecated rendering | Missing | **Solved** | VitePress Badge + :::warning containers |
| Stale file cleanup | Missing | **Solved** | Manifest-based deletion |

**Remaining 1/10 uncertainty:** Undiscovered edge cases in real-world packages
(complex generics with multiple nesting levels, very large codebases with 500+
elements). Mitigated by testing against `test_package` in dartdoc's own test suite.

### Team Review Decisions

3 rounds of review by 5 experts (4 Senior Engineers + 1 Tech Lead). Final verdicts:

| # | Issue | Decision |
|---|-------|----------|
| 1 | Sidebar in `generateAdditionalFiles()` | **Accepted** — move to `generatePackage()` |
| 2 | `TypeParameter.name` contains HTML | **Accepted** — use `tp.element.name!` |
| 3 | `{@inject-html}` not pass-through | **Accepted** — resolve before markdown parsing |
| 4 | AST model has no named classes | **Accepted** — Element with tag strings |
| 5 | Always add type suffix to filenames | **Rejected** — keep suffix only for "index" collisions |
| 6 | `sourceCode` HTML-escaped | **Accepted** — use `modelNode?.sourceCode` |
| 7 | MarkdownRenderer ~80 lines | **Accepted** — revised to ~250 lines with tables |
| 8 | `oneLineDoc` produces HTML | **Accepted** — parse first paragraph from `documentation` |
| 9 | Sidebar `base` property | **Accepted** — ~30% size reduction |
| 10 | LinkResolver facade interface | **Deferred** to post-MVP — function factory sufficient |
| 11 | Deprecated element rendering | **Accepted** — Badge + :::warning |
| 12 | Frontmatter editLink/prev/next | **Accepted** — disable for generated pages |
| 13 | `canonicalLibrary` nullable | **Accepted** — null-safety guard required |
| 14 | Stale file manifest | **Accepted** — manifest-based cleanup in Phase 6 |

---

## Future Iterations (post-MVP)

- `LinkResolver` facade wrapping `getMatchingLinkElement()` + `VitePressPathResolver`
  (deferred from MVP — function factory is sufficient for initial implementation)
- `--watch` mode (regenerate on source changes)
- Source code embedding (collapsible `:::details` sections)
- Dark/light code theme support
- GitHub "Edit this page" links pointing to source .dart files
- Version selector (multiple versions of docs)
- Inheritance diagrams (mermaid.js in VitePress)
- Custom search enhancement via VitePress search plugin
