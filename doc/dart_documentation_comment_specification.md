# **Dart Documentation Comments Specification**
Version: 1.0.0

[TOC]

## **1\. Introduction**

### **1.1. Purpose**

The purpose of this document is to provide a single specification for documentation comments in the Dart programming language. Its goal is to ensure that documentation is parsed consistently by all tools and to serve as a definitive standard for developers and tool authors.

### **1.2. Scope**

**In Scope**

This specification covers the following topics:

* The *syntax* for writing documentation comments.
* The rules governing where documentation comments can be *placed*.
* The mechanism for *resolving* references between elements.
* The logic for *associating* documentation with code elements.

**Out of Scope**

This document does not cover:

* The implementation details of specific documentation tools (e.g., `dartdoc`, `analysis server`).
* The syntax and behavior of tool-specific directives (e.g., `@template`, `@canonicalFor`).
* Any details related to the visual styling or HTML layout of generated documentation.
* Best practices or style guides for writing effective documentation content.

### **1.3. Terminology**

* **Doc Comment:** A comment intended to be processed by documentation generation tools, like  dartdoc.
* **Element**: Dart declarations or directives that can have documentation or be referenced in a doc comment: library directives, import prefixes, top-level, or member declarations such as class, menthod, or variable, parameters such as type parameters, method parameters, record fields.
* **Identifier:** An individual name in the code (e.g., `MyClass`, `myMethod`, `prefix`).
* **Qualified Name:** A name composed of two or more *identifiers* separated by dots, used to access an element within a specific namespace (e.g., MyClass.myMethod, prefix.MyClass).
* **Name:** A name is either a single *identifier* or a *qualified name*.
* **Reference:** A name enclosed in square brackets within a doc comment (e.g., `[MyClass]` or `[MyClass.myMethod]`) that links to an element.

## **2\. Syntax of Documentation Comments**

### **2.1. Line-Based Doc Comments (Recommended standard)**

A line-based doc comment is a comment that starts with `///`. One or more consecutive lines that begin with `///` form a doc comment block.

The block continues even if interrupted by single-line non-doc comments (lines starting with `//`) or by blank lines. The interrupting lines are ignored when extracting documentation text.

For each line that begins with `///`, the parser removes the three slashes and all leading whitespace to produce the documentation text. Exception: inside fenced code blocks (```), whitespace after the leading `///` is preserved to maintain code formatting.

**Example**

```dart
///   This line has leading whitespace after the slashes.
// This regular comment is ignored.
///
/// The line above is a rendered blank line (created by a `///` alone).
void myFunction() {}
```

The extracted documentation text from the example above would be:

```
This line has leading whitespace after the slashes.

This line above is a rendered blank line (created by a `///` alone).
```

**Example**

```
/// ```dart
///   void main() {
///     print('Hello, World!');
///   }
/// ```
void anotherFunction() {}
```

The extracted documentation text from the example above would be:

```
  void main() {
    print('Hello, World!');
  }
```

### **2.2. Block-Based Doc Comments (Historic, not recommended)**

A block-based doc comment is a comment that starts with `/**` and ends with the matching `*/`.

Block comments may contain nested comment sequences (for example: `/** outer /* inner */ outer */`). Documentation tools must respect nesting and ensure that the comment block only ends at the closing `*/` that matches the opening delimiter.

The content within the delimiters is treated as the documentation. On each line after the opening `/**`, any leading whitespace followed by a single asterisk (`*`) is considered stylistic and is stripped by doc generators. Any whitespace immediately following the asterisk is also stripped, if present.

**Example**

```
/**
 *
 *
 */
```

### **2.3. Content Format (Markdown)**

  The text within a documentation comment block is parsed as [GitHub Flavored Markdown (GFM)](https://github.github.com/gfm/), an extension of CommonMark, allowing for rich text formatting. This includes headings, lists, code blocks, tables, and emphasis, which are converted for instance to HTML in the generated documentation.

### **2.4. References**

A reference is a special directive within the Markdown content that creates a hyperlink to a Dart element. It is written by enclosing a name in square brackets (e.g., `[foo]`).  See [Section 4](#4.-referenceable-elements) for detailed information about which elements can be referenced.

Conceptually, these behave like [reference-style links](https://www.markdownguide.org/basic-syntax/#reference-style-links) in Markdown. The documentation generator resolves the name against the available source code to create the link's destination. See [Section 5](#5.-reference-lookup-and-resolution) for detailed resolution rules.

It is important to distinguish references from other link syntaxes in GFM. Documentation comment references use the shorthand reference link syntax (`[name]`) for their own purpose. Other forms of Markdown links are not treated as references and are parsed as standard Markdown. This includes:

* Inline links: `[A link](https://www.example.com)`
* Image links: `![An image](https://www.example.com/image.png)`
* Full reference links: `[A link][id]` (where `id` is a defined link reference `[id]:https://www.example.com "title"`)
* Footnotes: `[^1]`

Only a standalone `[name]` that does not correspond to a defined link reference in the Markdown document is treated as a reference to a Dart element.

## **3\. Placement of Documentation Comments**

Doc comments are associated with the declaration that immediately follows them. They are only considered valid when placed directly before the following types of declarations:

### **3.1. Directives**

* `library` directives.

### **3.2. Top-Level Declarations**

* `class`
* `mixin`
* `enum`
* `extension`
* `extension type`
* `typedef`
* Top-level functions
* Top-level variables
* Top-level getters or setters (See [Section 6.2.2](#6.2.2.-getters-and-setters) for details)

### **3.3. Member Declarations**

* Constructors (including factory and named constructors)
* Methods (instance, static)
* Operators
* Fields (instance, static)
* Getters or setters (See [Section 6.2.2](#6.2.2.-getters-and-setters) for details)

### **3.4. Enum Constants**

* A doc comment can be placed before an individual enum value.

### **3.5. Invalid Placements**

While not strictly disallowed by the language, any other placement of a comment with the /// syntax, is not considered a doc comment, and hence should be ignored by documentation tools.

**Note on Metadata Annotations:** Doc comments can be placed either before or after metadata annotations (e.g., `@override`, `@deprecated`). If doc comments appear in both locations, the doc comment closest to the declaration (after the annotation) takes precedence. The comment before the annotations is ignored, and documentation tools should issue a warning. For example:

```dart
/// This doc comment is ignored because there is another one after the
/// annotation.
@override
/// This doc comment takes precedence because it is closer to the declaration.
void foo(int s) {}
```

## **4\. Referenceable Elements**

A reference in a doc comment (e.g., `[name]`) can link to any Dart element that is visible from the Dart scope of the documented element. See [Section 5](#5.-reference-lookup-and-resolution) for more details about scoping. This includes:

### **4.1. Top-Level Declarations:**

* Classes (e.g., `[MyClass]`)
* Mixins (e.g., `[MyMixin]`)
* Enums (e.g., `[MyEnum]`)
* Named extensions (e.g., `[MyExtension]`)
* Extension types (e.g., `[MyExtensionType]`)
* Type aliases (Typedefs) (e.g., `[MyTypedef]`)
* Functions (e.g., `[myTopLevelFunction]`)
* Variables and constants (e.g., `[myTopLevelVar]`)
* Getters and Setters  (See [Section 6.2.2](#6.2.2.-getters-and-setters) for full details)

### **4.2. Members:**

* Methods (instance and static) (e.g., `[myMethod]`, `[MyClass.myMethod]`)
* Fields (instance and static) (e.g., `[myField]`, `[MyClass.myField]`)
* Getters and Setters  (See [Section 6.2.2](#6.2.2.-getters-and-setters) for full details)
* Constructors (e.g., `[MyClass.new]`, `[MyClass.named]`)
* Enum constants (e.g., `[MyEnum.value]`)

### **4.3. Parameters:**

* Formal parameters of the documented method/function (e.g., `[parameterName]`)
* Type parameters of the documented element and the enclosing element (e.g., `[T]`)
* Fields of record typedefs (e.g., `[field]`)
* Parameters in function type typedefs (e.g., `[param]`)

## **5\. Reference Lookup and Resolution**

When a name is enclosed in square brackets (e.g., `[MyClass.myMethod]`), documentation tools attempt to resolve it to a specific API member. This section details the principles of that resolution process, the scope hierarchy it follows, and how to handle special cases.

### **5.1. General Principles**

* **Resolution Follows Scope Hierarchy:** Lookup begins relative to the documented element and proceeds outwards through the well-defined Dart scope precedence hierarchy (see [Section 5.2](#5.2.-scope-precedence-hierarchy)). The first valid match found in this search is used.

* **Disambiguation via Qualification:** To prevent ambiguity or to reference an element from a distant scope, a reference should be qualified. This is done by prefixing the name with a class name (e.g., `[ClassName.memberName]`) or an import prefix (e.g., `[prefix.elementName]`).

* **Handling Ambiguity:** If a reference could resolve to multiple declarations within the same scope, it should not resolve to any element. If no resolution is found after checking all scopes, documentation tools should issue a warning.

### **5.2. Scope Precedence Hierarchy**

The resolution process for a reference `[name]` follows the standard Dart scope of the documented element with the extension of the doc imported scope at the end. The resolution starts with the first *identifier* of a name. Search is done in a specific order of precedence from the narrowest (most local) scope to the broadest (globally available).

The hierarchy is searched from the inside out. Below is an example for an instance method:
```
+--------------------------------------------------------------------------+
| 7. Doc Imported Scope (documentation-only imports with @docImport )      |
| +----------------------------------------------------------------------+ |
| | 6. Imported Scopes (all 'import' directives + implicit 'dart:core')  | |
| | +------------------------------------------------------------------+ | |
| | | 5. Library Scope (all declarations incl. prefixes in the file).  | | |
| | | +--------------------------------------------------------------+ | | |
| | | | 4. Class Type Parameter Scope (e.g., <T>)                    | | | |
| | | | +----------------------------------------------------------+ | | | |
| | | | | 3. Class Member Scope (e.g., static/instance members)    | | | | |
| | | | | +------------------------------------------------------+ | | | | |
| | | | | | 2. Method Type Parameter Scope (e.g., <R>)           | | | | | |
| | | | | | +--------------------------------------------------+ | | | | | |
| | | | | | | 1. Formal Parameter Scope (e.g., parameter names)| | | | | | |
| | | | | | +--------------------------------------------------+ | | | | | |
| | | | | +------------------------------------------------------+ | | | | |
| | | | +----------------------------------------------------------+ | | | |
| | | +--------------------------------------------------------------+ | | |
| | +------------------------------------------------------------------+ | |
| +----------------------------------------------------------------------+ |
+--------------------------------------------------------------------------+

```
### **5.3. Detailed Lookup Process**

The lookup process begins at a specific "starting scope" determined by the context of the doc comment and then follows the scope hierarchy.

The following sections detail the starting scope for each type of declaration.

#### **5.3.1. Instance Methods and Constructors**

This applies to doc comments on methods, constructors, and operators within a class, enum, mixin, extension, or extension type. The search begins with the method's own parameters.

* **Starting Scope**: Formal Parameter Scope

**Example**
```dart
/// @docImport 'dart:math';

import 'dart:convert';

class AnotherClass {}

class MyClass<T> {
  T? value;

  /// A method.
  ///
  /// Lookup examples:
  /// * [param]: Resolves to the parameter (Formal Parameter Scope).
  /// * [R]: Resolves to the method type parameter (Method Type Parameter Scope).
  /// * [value]: Resolves to the class member (Class Member Scope).
  /// * [myStaticMethod]: Resolves to the static class member (Class Member Scope).
  /// * [myMethod]: Resolves to this method itself (Class Member Scope).
  /// * [T]: Resolves to the class type parameter (Class Type Parameter Scope).
  /// * [MyClass]: Resolves to the parent class (Library Scope).
  /// * [AnotherClass]: Resolves to the library member (Library Scope).
  /// * [List]: Resolves from 'dart:core' (Imported Scopes).
  /// * [JsonCodec]: Resolves from 'dart:convert' (Imported Scope).
  /// * [Random]: Resolves from 'dart:math' (Doc Imported Scope).
  /// * [named] is not in scope (constructors are not in Class Member Scope)
  void myMethod<R>(T param) {
    // ...
  }

  /// A non-redirecting generative constructor.
  ///
  /// Lookup examples:
  /// * [value]: Resolves to the parameter (Formal Parameter Scope).
  /// * [param]: Resolves to the parameter (Formal Parameter Scope).
  /// * [named]: Resolves to this constructor itself (Class Member Scope).
  MyClass.named(this.value, int param);

  static void myStaticMethod() {
    // ...
  }

}

```

#### **5.3.2. Fields**

This applies to doc comments on fields within a class, enum, or mixin. Since fields have no parameters, the search starts at the member level, but otherwise follows the same route as instance methods.

* **Starting Scope**: Class Member Scope

#### **5.3.3. Top-Level Functions**

A top-level function operates like a method but without any enclosing class-like scopes.

* **Starting Scope**:  Formal Parameter Scope

#### **5.3.4. Top-Level Variables**

For top-level variables, the search has no local context and must begin at the file's library scope.

* **Starting Scope**: Library Scope

#### **5.3.5. Class-like Top-Level Declarations**

For doc comments placed directly on classes, enums, mixins, extensions, extension types.

* **Starting Scope**:  Class member scope

**Example**
```
/// @docImport 'dart:math';

/// A top-level function.
///
/// Lookup examples:
/// * [input]: Resolves to the parameter (Formal Parameter Scope).
/// * [R]: Resolves to the function type parameter (Function Type Parameter Scope).
/// * [globalConstant]: Resolves to the library member (Library Scope).
/// * [topLevelFunction]: Resolves to the function itself (Library Scope).
/// * [String]: Resolves from 'dart:core'(Imported Scope).
R topLevelFunction<R>(String input) {
  // ...
}

/// A top-level variable.
///
/// Lookup examples:
/// * [topLevelFunction]: Resolves to the library member (Library Scope).
/// * [globalConstant]: Resolves to the variable itself (Library Scope).
/// * [Duration]: Resolves from 'dart:core' (Imported Scope).
/// * [Random]: Resolves from 'dart:math' (Doc Imported Scope).
const int globalConstant = 10;

/// A class declaration.
///
/// Lookup examples:
/// * [myMethod]: Resolves to the class member (Class Member Scope).
/// * [T]: Resolves to the class type parameter (Class Type Parameter Scope).
/// * [topLevelFunction]: Resolves to the library member (Library Scope).
/// * [MyClass]: Resolves to the class itself (Library Scope).
/// * [List]: Resolves from 'dart:core' (Imported Scopes).
/// * [Random]: Resolves from 'dart:math' (Doc Imported Scope).
class MyClass<T> {

  /// A class member.
  void myMethod() {}

}
```

#### **5.3.6. Typedefs**

The starting scope for a typedef doc comment depends on what it is an alias for. For function and record types, the scope starts at the parameter/field level. For all other types, it starts at the typedef's own type parameter scope.

| Typedef Type    | Starting Scope |
| :---- | :---- |
| Function Type | Formal parameter scope |
| Record Type | Record fields scope |
| All Other Types | Typedef type parameter scope |

**Example**

```
/// @docImport 'dart:math';

class AnotherClass {}

/// A typedef for a Map.
///
/// Lookup examples:
/// * [T]: Resolves to the typedef type parameter (Typedef Type Parameter Scope).
/// * [JsonMap]: Resolves to the typedef itself (Library Scope).
/// * [AnotherClass]: Resolves to the library member (Library Scope).
/// * [Map]: Resolves from 'dart:core' (Imported Scope).
/// * [String]: Resolves from 'dart:core' (Imported Scope).
/// * [Random]: Resolves from 'dart:math' (Doc Imported Scope).
typedef JsonMap<T> = Map<String, T>;

/// A record typedef.
///
/// [a] : Resolves to record field
typedef MyRecord = ({int a, bool b});

/// A function type typedef.
///
/// [p] : Resolves to parameter
typedef MySecondTypedef<T> = void Function(int p);

/// A function type typedef (old syntax).
///
/// [p] : Resolves to parameter
typedef void MyTypedef<T>(int p);

/// A function type typedef with nested function functions.
///
/// [fun] : Resolves to parameter
/// [p] : is not in scope
typedef F<T> = void Function(void Function<S>(void Function(T p)) fun);
```

**Note on Nested Scopes:** The lookup only applies to the *immediate* parameters or fields of the typedef. It does not extend into parameters of nested function types.

### **5.4. Resolving Qualified Names**

When a reference contains a qualified name (e.g., `[prefix.ClassName.member]`), the resolution process is an iterative, left-to-right evaluation of each identifier.

#### **1\. Resolve the First Identifier**

The tool first resolves the first identifier in the qualified name (e.g., prefix) using the standard lookup process ([Section 5.3](#5.3.-detailed-lookup-process)), starting from the doc comment's current scope.

#### **2\. Resolve Subsequent Identifiers**

Once an identifier is resolved, the element it resolves to establishes a new **"**namespace**"** for resolving the *next* identifier in the chain. This process repeats until the entire qualified name is resolved.

The namespace available depends on the type of element the previous identifier resolved to. Below are the primary cases.

**Namespace-Providing Elements**

If an Identifier resolves to one of the following elements, it establishes a new namespace for resolving the next identifier in the chain.

*Case 1: Import Prefix*

* **Namespace:** The export scope of the imported library, as filtered by any show or hide combinators on the import directive.
* **Example:** In `[math.pi]`, the identifier `math` resolves to an import prefix (e.g., from `import 'dart:math' as math;`). The tool then searches the prefixed import namespace  for the identifier `pi`.
* **Combinator Example:** If the import was `import 'dart:math' as math show sin;`, the namespace for `math` would *only* contain `sin`. A reference to `[math.pi]` would fail to resolve, as `pi` was not included in the show list.

*Case 2: Class-like top-level declaration*

* **Namespace:** The set of all members accesible on that element, including:
  * Instance Members (fields, methods, etc.), including those inherited from supertypes.
  * Static Members
  * Constructors

* **Notes on Generics:**
  * The namespace does not include the element's own type parameters. For a class `MyClass<T>`, a reference like `[MyClass.T]` is invalid because `T` is not a member of `MyClass`'s namespace.
  * References are also made to the generic declaration, not a specific instantiation (e.g., write `[List.filled]`, not `[List<int>.filled]`).
* **Example:** To resolve the reference `[collection.BoolList.empty]`:
  * The identifier `collection` resolves to an import prefix.
  * The identifier `BoolList` resolves to a class element within the `collection` library's public namespace.
  * The identifier `empty` resolves to a named constructor element within the `BoolList` class's member namespace.

**Leaf Elements (Empty Namespace)**

The following elements are "leaf" nodes. If an Identifier resolves to one of these, it provides no further namespace, and the chain of resolution must end.

*Case 3: Function, or Method*

* **Namespace**: Empty.
* **Explanation**: A function or method element is a leaf node. While functions have parameters and type parameters, these are not accessible as a namespace using dot notation.
* **Example**: If `myFunction<T>(int param)` is a top-level function, references like `[myFunction.param]` or `[myFunction.T]` are invalid.

###

*Case 4: Variable, Field, or Formal Parameter*

* **Namespace:** Empty.
* **Explanation:** These elements are also "leaf" nodes. They represent values and do not have their own member namespaces.
* **Example**: If `myField` is a class field, a Reference like `[myField.something]` is invalid. Similarly, if `param` is a method parameter, `[param.something]` is also invalid.

*Case 5: Type Parameter*

* **Namespace:** Empty.
* **Explanation:** A type parameter (e.g., T from class `MyClass<T>`) is a "leaf" element representing a type. It does not provide a namespace for further resolution.
* **Example:** A reference like \[T.someMember\] is invalid because the identifier `T` resolves to a type parameter, which has no member namespace.

### **5.5. Disambiguation and Special Cases**

* **Constructors**: To refer to a named constructor, the syntax is `[ClassName.constructorName]`. Referencing the default, unnamed constructor requires the special syntax `[ClassName.new]`.

* **Constructor vs. Member Conflicts** A naming conflict can occur if a class declares a named constructor (e.g., `MyClass.foo`) and also contains an instance member with the same name (e.g., a method `foo()` or a field `foo`).
  * **Unqualified References** (`[foo]`): There is no ambiguity. A reference to `[foo]` always resolves to the member. A named constructor cannot be referenced by its name alone, it is not in scope as a simple identifier.
  * **Qualified References** (`[MyClass.foo]`): This syntax is ambiguous because it could validly refer to either the named constructor or the member (via the class namespace). In this specific conflict scenario, `[MyClass.foo]` resolves to the *named constructor*. It is recommended that documentation tools *issue a warning* when this shadowing occurs. To reference the member explicitly in this context, users should be advised to use the unqualified `[foo]` if within the class context.

**Example**

```
class A {
  /// A named constructor.
  A.foo();

  /// An instance method.
  void foo() {}

/// Usage in documentation:
/// * [foo]   -> Resolves to the method foo().
/// * [A.foo] -> Resolves to the constructor A.foo().

}
```

* **Getters and Setters:** A reference to a property name (e.g., `[value]`) resolves to the *conceptual property* rather than the individual getter or setter. See full discussion in [Section 6.2.2](#6.2.2.-getters-and-setters).

* **Shadowing**: A name in an inner scope (like a `[parameterName]`) "shadows" a name in an outer scope (like a class field). The shadowed outer element must be qualified to be referenced, e.g., `[MyClass.fieldName]`.

## **6\. Associating Documentation with Elements**

While the placement rules in [Section 3](#3.-placement-of-documentation-comments) define where a doc comment must be written, this section defines how documentation tools should associate a specific documentation block with a given code element, especially in cases where the association isn't direct.

### **6.1. The General Rule**

The documentation for a given Dart element is, by default, the single doc comment that *immediately precedes* its declaration in the source code.

### **6.2. Inheritance and Special Association Rules**

In some cases, the effective documentation for an element is determined by context, inheritance, or combination rules rather than by a direct preceding comment.

#### **6.2.1. Overridden Members**

When a member overrides an ancestor, its documentation is determined by a set of inheritance and precedence rules.

* **Explicit Documentation:** If an overriding member does have its own doc comment, that comment takes full precedence. The documentation from any base members is ignored.

* **Unambiguous Documentation Inheritance:** If a member overrides a member from an ancestor and does not have its own doc comment, it inherits the documentation from the base member. This rule applies when the source of the documentation is unambiguous (e.g., overriding a single method).  Documentation tools should display this inherited comment, ideally noting its origin (e.g., "Copied from BaseClass").

* **Ambiguous Documentation from Multiple Ancestors:** The behavior for resolving documentation when a member inherits conflicting documentation from multiple ancestors is *reserved for future standardization*. Currently, tools may handle this case at their discretion, or ignore inherited documentation in ambiguous scenarios. It is recommended that tools *issue a warning* when this scenario is encountered, prompting the user to provide explicit documentation to resolve the ambiguity.

#### **6.2.2. Getters and Setters**

A getter and a setter that share the same name are treated as a single *conceptual property* rather than the individual getter or setter.

Documentation tools should handle this property with the following rules:

* **Display:** The getter and setter should be presented as a single item in the API reference.
* **Precedence:**
  * Documentation for the property should only be placed on the getter.
  * The tooling should *issue a warning* if both a getter and its corresponding setter have unique doc comments.
  * The only situation the documentation of the setter is considered is in the case of no getter existing.
* **Reference:** A reference to a property name (e.g., `[value]`) resolves to the conceptual property rather than the individual getter or setter. This applies in all cases where a getter and setter share the same name, including:
  * When an explicit getter (`get value`) and setter (s`et value(...)`) are declared.
  * When a final field (which acts as an implicit getter) is paired with an explicit setter of the same name.
  * When a getter and setter for the same property are brought into scope, even if they are imported from different libraries.

#### **6.2.3. Parameters**

Parameters of functions, methods, and constructors do not have their own preceding doc comments. They are documented within the doc comment of their enclosing element and referenced using an element reference `[p]`.
