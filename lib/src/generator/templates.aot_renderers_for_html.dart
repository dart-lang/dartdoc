// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable

// It is hard to track exact imports without using package:code_builder.
// ignore_for_file: unused_import

import 'dart:convert' show htmlEscape;

import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/generator/template_data.dart';
import 'templates.dart';

String renderCategory(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderCategory_partial_head_0(context0));
  buffer.write('''

<div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
  <h1><span class="kind-category">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write('''</h1>
  ''');
    buffer.write(_renderCategory_partial_documentation_1(context1, context0));
    buffer.writeln();
    if (context1.hasPublicLibraries == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="libraries">
    <h2>Libraries</h2>

    <dl>''');
      for (var context2 in context1.publicLibrariesSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_library_2(context2, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicClasses == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="classes">
    <h2>Classes</h2>

    <dl>''');
      for (var context3 in context1.publicClassesSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_class_3(context3, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicMixins == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="mixins">
    <h2>Mixins</h2>

    <dl>''');
      for (var context4 in context1.publicMixinsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_mixin_4(context4, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicConstants == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="constants">
    <h2>Constants</h2>

    <dl class="properties">''');
      for (var context5 in context1.publicConstantsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_constant_5(context5, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicProperties == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="properties">
    <h2>Properties</h2>

    <dl class="properties">''');
      for (var context6 in context1.publicPropertiesSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_property_6(context6, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicFunctions == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="functions">
    <h2>Functions</h2>

    <dl class="callables">''');
      for (var context7 in context1.publicFunctionsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_callable_7(context7, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicEnums == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="enums">
    <h2>Enums</h2>

    <dl>''');
      for (var context8 in context1.publicEnumsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_class_3(context8, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicTypedefs == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="typedefs">
    <h2>Typedefs</h2>

    <dl class="callables">''');
      for (var context9 in context1.publicTypedefsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_typedef_8(context9, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
    buffer.writeln();
    if (context1.hasPublicExceptions == true) {
      buffer.write('''
  <section class="summary offset-anchor" id="exceptions">
    <h2>Exceptions / Errors</h2>

    <dl>''');
      for (var context10 in context1.publicExceptionsSorted) {
        buffer.write('\n      ');
        buffer.write(
            _renderCategory_partial_class_3(context10, context1, context0));
      }
      buffer.write('''
    </dl>
  </section>''');
    }
  }
  buffer.write('''

</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderCategory_partial_search_sidebar_9(context0));
  buffer.write('''
  <h5><span class="package-name">''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write('''</span> <span class="package-kind">''');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</span></h5>
  ''');
  buffer.write(_renderCategory_partial_packages_10(context0));
  buffer.write('''
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  <h5>''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.self.kind.toString()));
  buffer.write('''</h5>
  ''');
  buffer.write(_renderCategory_partial_sidebar_for_category_11(context0));
  buffer.write('''
</div>
<!--/sidebar-offcanvas-right-->
''');
  buffer.write(_renderCategory_partial_footer_12(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_head_0(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderCategory_partial_documentation_1(
    Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_library_2(
    Library context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderCategory_partial_library_2_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>''');
  if (context2.isDocumented == true) {
    buffer.write(context2.oneLineDoc.toString());
    buffer.write(' ');
    buffer.write(context2.extendedDocLink.toString());
  }
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_library_2_partial_categorization_0(
    Library context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_class_3(
    Class context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderCategory_partial_class_3_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_class_3_partial_categorization_0(
    Class context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_mixin_4(
    Mixin context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderCategory_partial_mixin_4_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_mixin_4_partial_categorization_0(
    Mixin context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_constant_5(TopLevelVariable context2,
    Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderCategory_partial_constant_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderCategory_partial_constant_5_partial_features_1(
      context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context2.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_constant_5_partial_categorization_0(
    TopLevelVariable context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderCategory_partial_constant_5_partial_features_1(
    TopLevelVariable context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_property_6(TopLevelVariable context2,
    Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderCategory_partial_property_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderCategory_partial_property_6_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_property_6_partial_categorization_0(
    TopLevelVariable context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderCategory_partial_property_6_partial_features_1(
    TopLevelVariable context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_callable_7(ModelFunctionTyped context2,
    Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderCategory_partial_callable_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderCategory_partial_callable_7_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderCategory_partial_callable_7_partial_categorization_0(
    ModelFunctionTyped context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderCategory_partial_callable_7_partial_features_1(
    ModelFunctionTyped context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_typedef_8(
    Typedef context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isCallable == true) {
    if (context2.asCallable != null) {
      var context3 = context2.asCallable;
      buffer.write('\n    ');
      buffer.write(__renderCategory_partial_typedef_8_partial_callable_0(
          context3, context2, context1, context0));
    }
  }
  if (context2.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(__renderCategory_partial_typedef_8_partial_type_1(
        context2, context1, context0));
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderCategory_partial_typedef_8_partial_callable_0(
    FunctionTypedef context3,
    Typedef context2,
    Category context1,
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context3.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context3.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context3.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context3.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      ___renderCategory_partial_typedef_8_partial_callable_0_partial_categorization_0(
          context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(
      ___renderCategory_partial_typedef_8_partial_callable_0_partial_features_1(
          context3, context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    ___renderCategory_partial_typedef_8_partial_callable_0_partial_categorization_0(
        FunctionTypedef context3,
        Typedef context2,
        Category context1,
        CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String
    ___renderCategory_partial_typedef_8_partial_callable_0_partial_features_1(
        FunctionTypedef context3,
        Typedef context2,
        Category context1,
        CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderCategory_partial_typedef_8_partial_type_1(
    Typedef context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''
    = ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''
  </span>
  ''');
  buffer.write(
      ___renderCategory_partial_typedef_8_partial_type_1_partial_categorization_0(
          context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(
      ___renderCategory_partial_typedef_8_partial_type_1_partial_features_1(
          context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    ___renderCategory_partial_typedef_8_partial_type_1_partial_categorization_0(
        Typedef context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String ___renderCategory_partial_typedef_8_partial_type_1_partial_features_1(
    Typedef context2, Category context1, CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderCategory_partial_search_sidebar_9(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderCategory_partial_packages_10(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  for (var context1 in context0.localPackages) {
    if (context1.isFirstPackage == true) {
      if (context1.hasDocumentedCategories == true) {
        buffer.write('''
      <li class="section-title">Topics</li>''');
        for (var context2 in context1.documentedCategoriesSorted) {
          buffer.write('''
        <li>''');
          buffer.write(context2.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.write('''
      <li class="section-title">Libraries</li>''');
    }
    if (context1.isFirstPackage != true) {
      buffer.write('''
      <li class="section-title">''');
      buffer.write(htmlEscape.convert(context1.name.toString()));
      buffer.write('''</li>''');
    }
    if (context1.defaultCategory != null) {
      var context3 = context1.defaultCategory;
      for (var context4 in context3.publicLibrariesSorted) {
        buffer.write('''
      <li>''');
        buffer.write(context4.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    for (var context5 in context1.categoriesWithPublicLibraries) {
      buffer.write('''
      <li class="section-subtitle">''');
      buffer.write(htmlEscape.convert(context5.name.toString()));
      buffer.write('''</li>''');
      for (var context6 in context5.publicLibrariesSorted) {
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context6.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String _renderCategory_partial_sidebar_for_category_11(
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  if (context0.self != null) {
    var context1 = context0.self;
    if (context1.hasPublicLibraries == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#libraries">Libraries</a></li>''');
      if (context0.self != null) {
        var context2 = context0.self;
        for (var context3 in context2.publicLibrariesSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context3.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context4 = context0.self;
    if (context4.hasPublicMixins == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#mixins">Mixins</a></li>''');
      if (context0.self != null) {
        var context5 = context0.self;
        for (var context6 in context5.publicMixinsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context6.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context7 = context0.self;
    if (context7.hasPublicClasses == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#classes">Classes</a></li>''');
      if (context0.self != null) {
        var context8 = context0.self;
        for (var context9 in context8.publicClassesSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context9.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context10 = context0.self;
    if (context10.hasPublicConstants == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#constants">Constants</a></li>''');
      if (context0.self != null) {
        var context11 = context0.self;
        for (var context12 in context11.publicConstantsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context12.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context13 = context0.self;
    if (context13.hasPublicProperties == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#properties">Properties</a></li>''');
      if (context0.self != null) {
        var context14 = context0.self;
        for (var context15 in context14.publicPropertiesSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context15.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context16 = context0.self;
    if (context16.hasPublicFunctions == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#functions">Functions</a></li>''');
      if (context0.self != null) {
        var context17 = context0.self;
        for (var context18 in context17.publicFunctionsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context18.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context19 = context0.self;
    if (context19.hasPublicEnums == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#enums">Enums</a></li>''');
      if (context0.self != null) {
        var context20 = context0.self;
        for (var context21 in context20.publicEnumsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context21.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context22 = context0.self;
    if (context22.hasPublicTypedefs == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#typedefs">Typedefs</a></li>''');
      if (context0.self != null) {
        var context23 = context0.self;
        for (var context24 in context23.publicTypedefsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context24.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.writeln();
  if (context0.self != null) {
    var context25 = context0.self;
    if (context25.hasPublicExceptions == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context0.self.href.toString());
      buffer.write('''#exceptions">Exceptions</a></li>''');
      if (context0.self != null) {
        var context26 = context0.self;
        for (var context27 in context26.publicExceptionsSorted) {
          buffer.write('''
  <li>''');
          buffer.write(context27.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String _renderCategory_partial_footer_12(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderClass<T extends Class>(ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderClass_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderClass_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-class">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderClass_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderClass_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.clazz != null) {
    var context2 = context0.clazz;
    buffer.write('\n    ');
    buffer.write(_renderClass_partial_documentation_4(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      buffer.write('''
    <section>
      <dl class="dl-horizontal">''');
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.write('''
        <dt>Inheritance</dt>
        <dd><ul class="gt-separated dark clazz-relationships">
          <li>''');
        buffer.write(context0.linkedObjectType.toString());
        buffer.write('''</li>''');
        for (var context3 in context2.publicSuperChainReversed) {
          buffer.write('''
          <li>''');
          buffer.write(context3.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          <li>''');
        buffer.write(context2.name.toString());
        buffer.write('''</li>
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicInterfaces == true) {
        buffer.write('''
        <dt>Implemented types</dt>
        <dd>
          <ul class="comma-separated clazz-relationships">''');
        for (var context4 in context2.publicInterfaces) {
          buffer.write('''
            <li>''');
          buffer.write(context4.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          </ul>
        </dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicMixedInTypes == true) {
        buffer.write('''
        <dt>Mixed in types</dt>
        <dd><ul class="comma-separated clazz-relationships">''');
        for (var context5 in context2.publicMixedInTypes) {
          buffer.write('''
          <li>''');
          buffer.write(context5.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicImplementors == true) {
        buffer.write('''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated clazz-relationships">''');
        for (var context6 in context2.publicImplementorsSorted) {
          buffer.write('''
          <li>''');
          buffer.write(context6.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPotentiallyApplicableExtensions == true) {
        buffer.write('''
        <dt>Available Extensions</dt>
        <dd><ul class="comma-separated clazz-relationships">''');
        for (var context7 in context2.potentiallyApplicableExtensionsSorted) {
          buffer.write('''
          <li>''');
          buffer.write(context7.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.write('''
        <dt>Annotations</dt>
        <dd><ul class="annotation-list clazz-relationships">''');
        for (var context8 in context2.annotations) {
          buffer.write('''
          <li>''');
          buffer.write(context8.linkedNameWithParameters.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstructors == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constructors">
      <h2>Constructors</h2>

      <dl class="constructor-summary-list">''');
      for (var context9 in context2.publicConstructorsSorted) {
        buffer.write('''
        <dt id="''');
        buffer.write(htmlEscape.convert(context9.htmlId.toString()));
        buffer.write('''" class="callable">
          <span class="name">''');
        buffer.write(context9.linkedName.toString());
        buffer.write('''</span><span class="signature">(''');
        buffer.write(context9.linkedParams.toString());
        buffer.write(''')</span>
        </dt>
        <dd>
          ''');
        buffer.write(context9.oneLineDoc.toString());
        buffer.write(' ');
        buffer.write(context9.extendedDocLink.toString());
        if (context9.isConst == true) {
          buffer.write('''
          <div class="constructor-modifier features">const</div>''');
        }
        if (context9.isFactory == true) {
          buffer.write('''
          <div class="constructor-modifier features">factory</div>''');
        }
        buffer.write('''
        </dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceFields == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
      for (var context10 in context2.publicInstanceFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_property_5(context10, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceMethods == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-methods">
      <h2>Methods</h2>
      <dl class="callables">''');
      for (var context11 in context2.publicInstanceMethodsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_callable_6(context11, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceOperators == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="operators">
      <h2>Operators</h2>
      <dl class="callables">''');
      for (var context12 in context2.publicInstanceOperatorsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_callable_6(context12, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-properties">
      <h2>Static Properties</h2>

      <dl class="properties">''');
      for (var context13 in context2.publicVariableStaticFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_property_5(context13, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-methods">
      <h2>Static Methods</h2>
      <dl class="callables">''');
      for (var context14 in context2.publicStaticMethodsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_callable_6(context14, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
      for (var context15 in context2.publicConstantFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderClass_partial_constant_7(context15, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderClass_partial_search_sidebar_8(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderClass_partial_footer_9(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_head_0<T extends Class>(
    ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderClass_partial_source_link_1<T extends Class>(
    Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_feature_set_2<T extends Class>(
    Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_categorization_3<T extends Class>(
    Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_documentation_4<T extends Class>(
    Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_property_5<T extends Class>(
    Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderClass_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderClass_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    __renderClass_partial_property_5_partial_categorization_0<T extends Class>(
        Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderClass_partial_property_5_partial_features_1<T extends Class>(
    Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_callable_6<T extends Class>(
    Method context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderClass_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderClass_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    __renderClass_partial_callable_6_partial_categorization_0<T extends Class>(
        Method context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderClass_partial_callable_6_partial_features_1<T extends Class>(
    Method context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_constant_7<T extends Class>(
    Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderClass_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderClass_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context2.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String
    __renderClass_partial_constant_7_partial_categorization_0<T extends Class>(
        Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderClass_partial_constant_7_partial_features_1<T extends Class>(
    Field context2, Class context1, ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderClass_partial_search_sidebar_8<T extends Class>(
    ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderClass_partial_footer_9<T extends Class>(
    ClassTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderConstructor(ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderConstructor_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderConstructor_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-constructor">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderConstructor_partial_feature_set_2(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.constructor != null) {
    var context2 = context0.constructor;
    buffer.write('''
    <section class="multi-line-signature">''');
    if (context2.hasAnnotations == true) {
      buffer.write('''
      <div>
        <ol class="annotation-list">''');
      for (var context3 in context2.annotations) {
        buffer.write('''
          <li>''');
        buffer.write(context3.linkedNameWithParameters.toString());
        buffer.write('''</li>''');
      }
      buffer.write('''
        </ol>
      </div>''');
    }
    if (context2.isConst == true) {
      buffer.write('''const''');
    }
    buffer.write('''
      <span class="name ''');
    if (context2.isDeprecated == true) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context2.nameWithGenerics.toString());
    buffer.write('''</span>(<wbr>''');
    if (context2.hasParameters == true) {
      buffer.write(context2.linkedParamsLines.toString());
    }
    buffer.write(''')
    </section>

    ''');
    buffer
        .write(_renderConstructor_partial_documentation_3(context2, context0));
    buffer.write('\n\n    ');
    buffer.write(_renderConstructor_partial_source_code_4(context2, context0));
    buffer.writeln();
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderConstructor_partial_search_sidebar_5(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderConstructor_partial_footer_6(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderConstructor_partial_head_0(ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderConstructor_partial_source_link_1(
    Constructor context1, ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderConstructor_partial_feature_set_2(
    Constructor context1, ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderConstructor_partial_documentation_3(
    Constructor context1, ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderConstructor_partial_source_code_4(
    Constructor context1, ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderConstructor_partial_search_sidebar_5(
    ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderConstructor_partial_footer_6(ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderEnum(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderEnum_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderEnum_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-enum">''');
    buffer.write(context1.name.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderEnum_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderEnum_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.eNum != null) {
    var context2 = context0.eNum;
    buffer.write('\n    ');
    buffer.write(_renderEnum_partial_documentation_4(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      buffer.write('''
    <section>
      <dl class="dl-horizontal">''');
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.write('''
        <dt>Inheritance</dt>
        <dd><ul class="gt-separated dark eNum-relationships">
          <li>''');
        buffer.write(context0.linkedObjectType.toString());
        buffer.write('''</li>''');
        for (var context3 in context2.publicSuperChainReversed) {
          buffer.write('''
          <li>''');
          buffer.write(context3.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          <li>''');
        buffer.write(context2.name.toString());
        buffer.write('''</li>
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicInterfaces == true) {
        buffer.write('''
        <dt>Implemented types</dt>
        <dd>
          <ul class="comma-separated eNum-relationships">''');
        for (var context4 in context2.publicInterfaces) {
          buffer.write('''
            <li>''');
          buffer.write(context4.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          </ul>
        </dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicMixedInTypes == true) {
        buffer.write('''
        <dt>Mixed in types</dt>
        <dd><ul class="comma-separated eNum-relationships">''');
        for (var context5 in context2.publicMixedInTypes) {
          buffer.write('''
          <li>''');
          buffer.write(context5.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicImplementors == true) {
        buffer.write('''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated eNum-relationships">''');
        for (var context6 in context2.publicImplementorsSorted) {
          buffer.write('''
          <li>''');
          buffer.write(context6.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.write('''
        <dt>Annotations</dt>
        <dd><ul class="annotation-list eNum-relationships">''');
        for (var context7 in context2.annotations) {
          buffer.write('''
          <li>''');
          buffer.write(context7.linkedNameWithParameters.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
      for (var context8 in context2.publicConstantFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_constant_5(context8, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstructors == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constructors">
      <h2>Constructors</h2>

      <dl class="constructor-summary-list">''');
      for (var context9 in context2.publicConstructorsSorted) {
        buffer.write('''
        <dt id="''');
        buffer.write(htmlEscape.convert(context9.htmlId.toString()));
        buffer.write('''" class="callable">
          <span class="name">''');
        buffer.write(context9.linkedName.toString());
        buffer.write('''</span><span class="signature">(''');
        buffer.write(context9.linkedParams.toString());
        buffer.write(''')</span>
        </dt>
        <dd>
          ''');
        buffer.write(context9.oneLineDoc.toString());
        buffer.write(' ');
        buffer.write(context9.extendedDocLink.toString());
        if (context9.isConst == true) {
          buffer.write('''
          <div class="constructor-modifier features">const</div>''');
        }
        if (context9.isFactory == true) {
          buffer.write('''
          <div class="constructor-modifier features">factory</div>''');
        }
        buffer.write('''
        </dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceFields == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
      for (var context10 in context2.publicInstanceFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_property_6(context10, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceMethods == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-methods">
      <h2>Methods</h2>
      <dl class="callables">''');
      for (var context11 in context2.publicInstanceMethodsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_callable_7(context11, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceOperators == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="operators">
      <h2>Operators</h2>
      <dl class="callables">''');
      for (var context12 in context2.publicInstanceOperatorsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_callable_7(context12, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-properties">
      <h2>Static Properties</h2>

      <dl class="properties">''');
      for (var context13 in context2.publicVariableStaticFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_property_6(context13, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-methods">
      <h2>Static Methods</h2>
      <dl class="callables">''');
      for (var context14 in context2.publicStaticMethodsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderEnum_partial_callable_7(context14, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderEnum_partial_search_sidebar_8(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderEnum_partial_footer_9(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_head_0(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderEnum_partial_source_link_1(
    Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_feature_set_2(
    Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_categorization_3(
    Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_documentation_4(
    Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_constant_5(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderEnum_partial_constant_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderEnum_partial_constant_5_partial_features_1(
      context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context2.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String __renderEnum_partial_constant_5_partial_categorization_0(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderEnum_partial_constant_5_partial_features_1(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_property_6(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderEnum_partial_property_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderEnum_partial_property_6_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderEnum_partial_property_6_partial_categorization_0(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderEnum_partial_property_6_partial_features_1(
    Field context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_callable_7(
    Method context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderEnum_partial_callable_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderEnum_partial_callable_7_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderEnum_partial_callable_7_partial_categorization_0(
    Method context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderEnum_partial_callable_7_partial_features_1(
    Method context2, Enum context1, EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderEnum_partial_search_sidebar_8(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderEnum_partial_footer_9(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderError(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderError_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">
    <h1>404: Something\'s gone wrong :-(</h1>

    <section class="desc">
      <p>You\'ve tried to visit a page that doesn\'t exist.  Luckily this site
         has other <a href="index.html">pages</a>.</p>
      <p>If you were looking for something specific, try searching:
      <form class="search-body" role="search">
        <input type="text" id="search-body" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
      </form>
      </p>

    </section>
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderError_partial_search_sidebar_1(context0));
  buffer.write('''
    <h5><span class="package-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</span> <span class="package-kind">''');
  buffer.write(htmlEscape.convert(context0.self.kind.toString()));
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderError_partial_packages_2(context0));
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div>

''');
  buffer.write(_renderError_partial_footer_3(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderError_partial_head_0(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderError_partial_search_sidebar_1(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderError_partial_packages_2(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  for (var context1 in context0.localPackages) {
    if (context1.isFirstPackage == true) {
      if (context1.hasDocumentedCategories == true) {
        buffer.write('''
      <li class="section-title">Topics</li>''');
        for (var context2 in context1.documentedCategoriesSorted) {
          buffer.write('''
        <li>''');
          buffer.write(context2.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.write('''
      <li class="section-title">Libraries</li>''');
    }
    if (context1.isFirstPackage != true) {
      buffer.write('''
      <li class="section-title">''');
      buffer.write(htmlEscape.convert(context1.name.toString()));
      buffer.write('''</li>''');
    }
    if (context1.defaultCategory != null) {
      var context3 = context1.defaultCategory;
      for (var context4 in context3.publicLibrariesSorted) {
        buffer.write('''
      <li>''');
        buffer.write(context4.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    for (var context5 in context1.categoriesWithPublicLibraries) {
      buffer.write('''
      <li class="section-subtitle">''');
      buffer.write(htmlEscape.convert(context5.name.toString()));
      buffer.write('''</li>''');
      for (var context6 in context5.publicLibrariesSorted) {
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context6.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String _renderError_partial_footer_3(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderExtension<T extends Extension>(ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtension_partial_head_0(context0));
  buffer.write('''

<div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
    <div>''');
    buffer.write(_renderExtension_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-class">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderExtension_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderExtension_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.extension != null) {
    var context2 = context0.extension;
    buffer.write('\n    ');
    buffer.write(_renderExtension_partial_documentation_4(context2, context0));
    buffer.write('''
    <section>
        <dl class="dl-horizontal">
        <dt>on</dt>
        <dd>
            <ul class="comma-separated clazz-relationships">''');
    if (context2.extendedType != null) {
      var context3 = context2.extendedType;
      buffer.write('''
            <li>''');
      buffer.write(context3.linkedName.toString());
      buffer.write('''</li>''');
    }
    buffer.write('''
            </ul>
        </dd>
        </dl>
    </section>
''');
    if (context2.hasPublicInstanceFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="instance-properties">
        <h2>Properties</h2>

        <dl class="properties">''');
      for (var context4 in context2.publicInstanceFieldsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_property_5(context4, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="instance-methods">
        <h2>Methods</h2>
        <dl class="callables">''');
      for (var context5 in context2.publicInstanceMethodsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_callable_6(context5, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="operators">
        <h2>Operators</h2>
        <dl class="callables">''');
      for (var context6 in context2.publicInstanceOperatorsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_callable_6(context6, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-properties">
        <h2>Static Properties</h2>

        <dl class="properties">''');
      for (var context7 in context2.publicVariableStaticFieldsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_property_5(context7, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-methods">
        <h2>Static Methods</h2>
        <dl class="callables">''');
      for (var context8 in context2.publicStaticMethodsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_callable_6(context8, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constants">
        <h2>Constants</h2>

        <dl class="properties">''');
      for (var context9 in context2.publicConstantFieldsSorted) {
        buffer.write('\n            ');
        buffer.write(
            _renderExtension_partial_constant_7(context9, context2, context0));
      }
      buffer.write('''
        </dl>
    </section>''');
    }
  }
  buffer.write('''

</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderExtension_partial_search_sidebar_8(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderExtension_partial_footer_9(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_head_0<T extends Extension>(
    ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderExtension_partial_source_link_1<T extends Extension>(
    Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_feature_set_2<T extends Extension>(
    Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_categorization_3<T extends Extension>(
    Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_documentation_4<T extends Extension>(
    Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_property_5<T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderExtension_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderExtension_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderExtension_partial_property_5_partial_categorization_0<
        T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderExtension_partial_property_5_partial_features_1<
        T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_callable_6<T extends Extension>(
    Method context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderExtension_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderExtension_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderExtension_partial_callable_6_partial_categorization_0<
        T extends Extension>(
    Method context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderExtension_partial_callable_6_partial_features_1<
        T extends Extension>(
    Method context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_constant_7<T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderExtension_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderExtension_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context2.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String __renderExtension_partial_constant_7_partial_categorization_0<
        T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderExtension_partial_constant_7_partial_features_1<
        T extends Extension>(
    Field context2, Extension context1, ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderExtension_partial_search_sidebar_8<T extends Extension>(
    ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderExtension_partial_footer_9<T extends Extension>(
    ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderFunction(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFunction_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderFunction_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-function">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderFunction_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderFunction_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.function != null) {
    var context2 = context0.function;
    buffer.write('''
    <section class="multi-line-signature">
        ''');
    buffer.write(
        _renderFunction_partial_callable_multiline_4(context2, context0));
    buffer.write('''
    </section>
    ''');
    buffer.write(_renderFunction_partial_documentation_5(context2, context0));
    buffer.write('\n\n    ');
    buffer.write(_renderFunction_partial_source_code_6(context2, context0));
    buffer.writeln();
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderFunction_partial_search_sidebar_7(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderFunction_partial_footer_8(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_head_0(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderFunction_partial_source_link_1(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_feature_set_2(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_categorization_3(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_callable_multiline_4(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    buffer.write('''
<div>
  <ol class="annotation-list">''');
    for (var context2 in context1.annotations) {
      buffer.write('''
    <li>''');
      buffer.write(context2.linkedNameWithParameters.toString());
      buffer.write('''</li>''');
    }
    buffer.write('''
  </ol>
</div>''');
  }
  buffer.write('''

<span class="returntype">''');
  buffer.write(context1.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
''');
  buffer.write(
      __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write('''(<wbr>''');
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines.toString());
  }
  buffer.write(''')
''');
  return buffer.toString();
}

String __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context1.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String _renderFunction_partial_documentation_5(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_source_code_6(
    ModelFunction context1, FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderFunction_partial_search_sidebar_7(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderFunction_partial_footer_8(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderIndex(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderIndex_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.defaultPackage != null) {
    var context1 = context0.defaultPackage;
    buffer.write('\n      ');
    buffer.write(_renderIndex_partial_documentation_1(context1, context0));
  }
  buffer.writeln();
  for (var context2 in context0.localPackages) {
    buffer.write('''
      <section class="summary">''');
    if (context2.isFirstPackage == true) {
      buffer.write('''
          <h2>Libraries</h2>''');
    }
    if (context2.isFirstPackage != true) {
      buffer.write('''
          <h2>''');
      buffer.write(htmlEscape.convert(context2.name.toString()));
      buffer.write('''</h2>''');
    }
    buffer.write('''
        <dl>''');
    if (context2.defaultCategory != null) {
      var context3 = context2.defaultCategory;
      for (var context4 in context3.publicLibrariesSorted) {
        buffer.write('\n          ');
        buffer.write(_renderIndex_partial_library_2(
            context4, context3, context2, context0));
      }
    }
    for (var context5 in context2.categoriesWithPublicLibraries) {
      buffer.write('''
          <h3>''');
      buffer.write(htmlEscape.convert(context5.name.toString()));
      buffer.write('''</h3>''');
      for (var context6 in context5.publicLibrariesSorted) {
        buffer.write('\n            ');
        buffer.write(_renderIndex_partial_library_2(
            context6, context5, context2, context0));
      }
    }
    buffer.write('''
        </dl>
      </section>''');
  }
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderIndex_partial_search_sidebar_3(context0));
  buffer.write('''
    <h5 class="hidden-xs"><span class="package-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</span> <span class="package-kind">''');
  buffer.write(htmlEscape.convert(context0.self.kind.toString()));
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderIndex_partial_packages_4(context0));
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div>

''');
  buffer.write(_renderIndex_partial_footer_5(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderIndex_partial_head_0(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderIndex_partial_documentation_1(
    Package context1, PackageTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderIndex_partial_library_2(Library context3,
    LibraryContainer context2, Package context1, PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''">
  <span class="name">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderIndex_partial_library_2_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd>''');
  if (context3.isDocumented == true) {
    buffer.write(context3.oneLineDoc.toString());
    buffer.write(' ');
    buffer.write(context3.extendedDocLink.toString());
  }
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderIndex_partial_library_2_partial_categorization_0(
    Library context3,
    LibraryContainer context2,
    Package context1,
    PackageTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderIndex_partial_search_sidebar_3(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderIndex_partial_packages_4(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  for (var context1 in context0.localPackages) {
    if (context1.isFirstPackage == true) {
      if (context1.hasDocumentedCategories == true) {
        buffer.write('''
      <li class="section-title">Topics</li>''');
        for (var context2 in context1.documentedCategoriesSorted) {
          buffer.write('''
        <li>''');
          buffer.write(context2.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.write('''
      <li class="section-title">Libraries</li>''');
    }
    if (context1.isFirstPackage != true) {
      buffer.write('''
      <li class="section-title">''');
      buffer.write(htmlEscape.convert(context1.name.toString()));
      buffer.write('''</li>''');
    }
    if (context1.defaultCategory != null) {
      var context3 = context1.defaultCategory;
      for (var context4 in context3.publicLibrariesSorted) {
        buffer.write('''
      <li>''');
        buffer.write(context4.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    for (var context5 in context1.categoriesWithPublicLibraries) {
      buffer.write('''
      <li class="section-subtitle">''');
      buffer.write(htmlEscape.convert(context5.name.toString()));
      buffer.write('''</li>''');
      for (var context6 in context5.publicLibrariesSorted) {
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context6.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String _renderIndex_partial_footer_5(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderLibrary(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderLibrary_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderLibrary_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-library">''');
    buffer.write(context1.name.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderLibrary_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderLibrary_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.library != null) {
    var context2 = context0.library;
    buffer.write('\n    ');
    buffer.write(_renderLibrary_partial_documentation_4(context2, context0));
  }
  buffer.writeln();
  if (context0.library != null) {
    var context3 = context0.library;
    if (context3.hasPublicClasses == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="classes">
      <h2>Classes</h2>

      <dl>''');
      if (context3.library != null) {
        var context4 = context3.library;
        for (var context5 in context4.publicClassesSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_class_5(
              context5, context4, context3, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context6 = context0.library;
    if (context6.hasPublicMixins == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="mixins">
      <h2>Mixins</h2>

      <dl>''');
      if (context6.library != null) {
        var context7 = context6.library;
        for (var context8 in context7.publicMixinsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_mixin_6(
              context8, context7, context6, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context9 = context0.library;
    if (context9.hasPublicExtensions == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="extensions">
      <h2>Extensions</h2>

      <dl>''');
      if (context9.library != null) {
        var context10 = context9.library;
        for (var context11 in context10.publicExtensionsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_extension_7(
              context11, context10, context9, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context12 = context0.library;
    if (context12.hasPublicConstants == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
      if (context12.library != null) {
        var context13 = context12.library;
        for (var context14 in context13.publicConstantsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_constant_8(
              context14, context13, context12, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context15 = context0.library;
    if (context15.hasPublicProperties == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="properties">
      <h2>Properties</h2>

      <dl class="properties">''');
      if (context15.library != null) {
        var context16 = context15.library;
        for (var context17 in context16.publicPropertiesSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_property_9(
              context17, context16, context15, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context18 = context0.library;
    if (context18.hasPublicFunctions == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="functions">
      <h2>Functions</h2>

      <dl class="callables">''');
      if (context18.library != null) {
        var context19 = context18.library;
        for (var context20 in context19.publicFunctionsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_callable_10(
              context20, context19, context18, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context21 = context0.library;
    if (context21.hasPublicEnums == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="enums">
      <h2>Enums</h2>

      <dl>''');
      if (context21.library != null) {
        var context22 = context21.library;
        for (var context23 in context22.publicEnumsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_class_5(
              context23, context22, context21, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context24 = context0.library;
    if (context24.hasPublicTypedefs == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="typedefs">
      <h2>Typedefs</h2>

      <dl>''');
      if (context24.library != null) {
        var context25 = context24.library;
        for (var context26 in context25.publicTypedefsSorted) {
          buffer.write('\n          ');
          buffer.write(_renderLibrary_partial_typedef_11(
              context26, context25, context24, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.writeln();
  if (context0.library != null) {
    var context27 = context0.library;
    if (context27.hasPublicExceptions == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="exceptions">
      <h2>Exceptions / Errors</h2>

      <dl>''');
      if (context27.library != null) {
        var context28 = context27.library;
        for (var context29 in context28.publicExceptionsSorted) {
          buffer.write('\n        ');
          buffer.write(_renderLibrary_partial_class_5(
              context29, context28, context27, context0));
        }
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderLibrary_partial_search_sidebar_12(context0));
  buffer.write('''
    <h5><span class="package-name">''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write('''</span> <span class="package-kind">''');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderLibrary_partial_packages_13(context0));
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    <h5>''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.self.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div><!--/sidebar-offcanvas-right-->

''');
  buffer.write(_renderLibrary_partial_footer_14(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_head_0(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderLibrary_partial_source_link_1(
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_feature_set_2(
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_categorization_3(
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_documentation_4(
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_class_5(Class context3, Library context2,
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''">
  <span class="name ''');
  if (context3.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderLibrary_partial_class_5_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderLibrary_partial_class_5_partial_categorization_0(Class context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_mixin_6(Mixin context3, Library context2,
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''">
  <span class="name ''');
  if (context3.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderLibrary_partial_mixin_6_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderLibrary_partial_mixin_6_partial_categorization_0(Mixin context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_extension_7(Extension context3, Library context2,
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''">
    <span class="name ''');
  if (context3.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderLibrary_partial_extension_7_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd>
    ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('''
</dd>

''');
  return buffer.toString();
}

String __renderLibrary_partial_extension_7_partial_categorization_0(
    Extension context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_constant_8(TopLevelVariable context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context3.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderLibrary_partial_constant_8_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderLibrary_partial_constant_8_partial_features_1(
      context3, context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context3.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String __renderLibrary_partial_constant_8_partial_categorization_0(
    TopLevelVariable context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderLibrary_partial_constant_8_partial_features_1(
    TopLevelVariable context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_property_9(TopLevelVariable context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context3.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context3.arrow.toString());
  buffer.write(' ');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderLibrary_partial_property_9_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderLibrary_partial_property_9_partial_features_1(
      context3, context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderLibrary_partial_property_9_partial_categorization_0(
    TopLevelVariable context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderLibrary_partial_property_9_partial_features_1(
    TopLevelVariable context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_callable_10(ModelFunctionTyped context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context3.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context3.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context3.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context3.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderLibrary_partial_callable_10_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderLibrary_partial_callable_10_partial_features_1(
      context3, context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderLibrary_partial_callable_10_partial_categorization_0(
    ModelFunctionTyped context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderLibrary_partial_callable_10_partial_features_1(
    ModelFunctionTyped context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_typedef_11(Typedef context3, Library context2,
    Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.isCallable == true) {
    if (context3.asCallable != null) {
      var context4 = context3.asCallable;
      buffer.write('\n    ');
      buffer.write(__renderLibrary_partial_typedef_11_partial_callable_0(
          context4, context3, context2, context1, context0));
    }
  }
  if (context3.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(__renderLibrary_partial_typedef_11_partial_type_1(
        context3, context2, context1, context0));
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderLibrary_partial_typedef_11_partial_callable_0(
    FunctionTypedef context4,
    Typedef context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context4.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context4.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context4.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context4.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context4.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context4.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context4.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      ___renderLibrary_partial_typedef_11_partial_callable_0_partial_categorization_0(
          context4, context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context4.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context4.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context4.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(
      ___renderLibrary_partial_typedef_11_partial_callable_0_partial_features_1(
          context4, context3, context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    ___renderLibrary_partial_typedef_11_partial_callable_0_partial_categorization_0(
        FunctionTypedef context4,
        Typedef context3,
        Library context2,
        Library context1,
        LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context4.hasCategoryNames == true) {
    for (var context5 in context4.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context5.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String
    ___renderLibrary_partial_typedef_11_partial_callable_0_partial_features_1(
        FunctionTypedef context4,
        Typedef context3,
        Library context2,
        Library context1,
        LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context4.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context4.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderLibrary_partial_typedef_11_partial_type_1(Typedef context3,
    Library context2, Library context1, LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context3.htmlId.toString()));
  buffer.write('''" class="''');
  if (context3.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context3.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''
    = ''');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.write('''
  </span>
  ''');
  buffer.write(
      ___renderLibrary_partial_typedef_11_partial_type_1_partial_categorization_0(
          context3, context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(
      ___renderLibrary_partial_typedef_11_partial_type_1_partial_features_1(
          context3, context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String
    ___renderLibrary_partial_typedef_11_partial_type_1_partial_categorization_0(
        Typedef context3,
        Library context2,
        Library context1,
        LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    for (var context4 in context3.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context4.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String ___renderLibrary_partial_typedef_11_partial_type_1_partial_features_1(
    Typedef context3,
    Library context2,
    Library context1,
    LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderLibrary_partial_search_sidebar_12(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderLibrary_partial_packages_13(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  for (var context1 in context0.localPackages) {
    if (context1.isFirstPackage == true) {
      if (context1.hasDocumentedCategories == true) {
        buffer.write('''
      <li class="section-title">Topics</li>''');
        for (var context2 in context1.documentedCategoriesSorted) {
          buffer.write('''
        <li>''');
          buffer.write(context2.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.write('''
      <li class="section-title">Libraries</li>''');
    }
    if (context1.isFirstPackage != true) {
      buffer.write('''
      <li class="section-title">''');
      buffer.write(htmlEscape.convert(context1.name.toString()));
      buffer.write('''</li>''');
    }
    if (context1.defaultCategory != null) {
      var context3 = context1.defaultCategory;
      for (var context4 in context3.publicLibrariesSorted) {
        buffer.write('''
      <li>''');
        buffer.write(context4.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    for (var context5 in context1.categoriesWithPublicLibraries) {
      buffer.write('''
      <li class="section-subtitle">''');
      buffer.write(htmlEscape.convert(context5.name.toString()));
      buffer.write('''</li>''');
      for (var context6 in context5.publicLibrariesSorted) {
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context6.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String _renderLibrary_partial_footer_14(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderMethod(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMethod_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderMethod_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-method">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderMethod_partial_feature_set_2(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.method != null) {
    var context2 = context0.method;
    buffer.write('''
    <section class="multi-line-signature">
      ''');
    buffer
        .write(_renderMethod_partial_callable_multiline_3(context2, context0));
    buffer.write('\n      ');
    buffer.write(_renderMethod_partial_features_4(context2, context0));
    buffer.write('''
    </section>
    ''');
    buffer.write(_renderMethod_partial_documentation_5(context2, context0));
    buffer.write('\n\n    ');
    buffer.write(_renderMethod_partial_source_code_6(context2, context0));
    buffer.writeln();
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderMethod_partial_search_sidebar_7(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMethod_partial_footer_8(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_head_0(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderMethod_partial_source_link_1(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_feature_set_2(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_callable_multiline_3(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    buffer.write('''
<div>
  <ol class="annotation-list">''');
    for (var context2 in context1.annotations) {
      buffer.write('''
    <li>''');
      buffer.write(context2.linkedNameWithParameters.toString());
      buffer.write('''</li>''');
    }
    buffer.write('''
  </ol>
</div>''');
  }
  buffer.write('''

<span class="returntype">''');
  buffer.write(context1.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
''');
  buffer.write(
      __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write('''(<wbr>''');
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines.toString());
  }
  buffer.write(''')
''');
  return buffer.toString();
}

String __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context1.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String _renderMethod_partial_features_4(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_documentation_5(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_source_code_6(
    Method context1, MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMethod_partial_search_sidebar_7(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderMethod_partial_footer_8(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderMixin(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMixin_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderMixin_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-mixin">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderMixin_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderMixin_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.mixin != null) {
    var context2 = context0.mixin;
    buffer.write('\n    ');
    buffer.write(_renderMixin_partial_documentation_4(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      buffer.write('''
    <section>
      <dl class="dl-horizontal">''');
      if (context2.hasPublicSuperclassConstraints == true) {
        buffer.write('''
        <dt>Superclass Constraints</dt>
        <dd><ul class="comma-separated dark mixin-relationships">''');
        for (var context3 in context2.publicSuperclassConstraints) {
          buffer.write('''
          <li>''');
          buffer.write(context3.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.write('''
        <dt>Inheritance</dt>
        <dd><ul class="gt-separated dark mixin-relationships">
          <li>''');
        buffer.write(context0.linkedObjectType.toString());
        buffer.write('''</li>''');
        for (var context4 in context2.publicSuperChainReversed) {
          buffer.write('''
          <li>''');
          buffer.write(context4.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          <li>''');
        buffer.write(context2.name.toString());
        buffer.write('''</li>
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicInterfaces == true) {
        buffer.write('''
        <dt>Implements</dt>
        <dd>
          <ul class="comma-separated mixin-relationships">''');
        for (var context5 in context2.publicInterfaces) {
          buffer.write('''
            <li>''');
          buffer.write(context5.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
          </ul>
        </dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicMixedInTypes == true) {
        buffer.write('''
        <dt>Mixes-in</dt>
        <dd><ul class="comma-separated mixin-relationships">''');
        for (var context6 in context2.publicMixedInTypes) {
          buffer.write('''
          <li>''');
          buffer.write(context6.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasPublicImplementors == true) {
        buffer.write('''
        <dt>Implemented by</dt>
        <dd><ul class="comma-separated mixin-relationships">''');
        for (var context7 in context2.publicImplementorsSorted) {
          buffer.write('''
          <li>''');
          buffer.write(context7.linkedName.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.write('''
        <dt>Annotations</dt>
        <dd><ul class="annotation-list mixin-relationships">''');
        for (var context8 in context2.annotations) {
          buffer.write('''
          <li>''');
          buffer.write(context8.linkedNameWithParameters.toString());
          buffer.write('''</li>''');
        }
        buffer.write('''
        </ul></dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstructors == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constructors">
      <h2>Constructors</h2>

      <dl class="constructor-summary-list">''');
      for (var context9 in context2.publicConstructorsSorted) {
        buffer.write('''
        <dt id="''');
        buffer.write(htmlEscape.convert(context9.htmlId.toString()));
        buffer.write('''" class="callable">
          <span class="name">''');
        buffer.write(context9.linkedName.toString());
        buffer.write('''</span><span class="signature">(''');
        buffer.write(context9.linkedParams.toString());
        buffer.write(''')</span>
        </dt>
        <dd>
          ''');
        buffer.write(context9.oneLineDoc.toString());
        buffer.write(' ');
        buffer.write(context9.extendedDocLink.toString());
        if (context9.isConst == true) {
          buffer.write('''
          <div class="constructor-modifier features">const</div>''');
        }
        if (context9.isFactory == true) {
          buffer.write('''
          <div class="constructor-modifier features">factory</div>''');
        }
        buffer.write('''
        </dd>''');
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceFields == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
      for (var context10 in context2.publicInstanceFields) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_property_5(context10, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceMethods == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="instance-methods">
      <h2>Methods</h2>
      <dl class="callables">''');
      for (var context11 in context2.publicInstanceMethods) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_callable_6(context11, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.write('''
    <section class="summary offset-anchor''');
      if (context2.publicInheritedInstanceOperators == true) {
        buffer.write(''' inherited''');
      }
      buffer.write('''" id="operators">
      <h2>Operators</h2>
      <dl class="callables">''');
      for (var context12 in context2.publicInstanceOperatorsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_callable_6(context12, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-properties">
      <h2>Static Properties</h2>

      <dl class="properties">''');
      for (var context13 in context2.publicVariableStaticFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_property_5(context13, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="static-methods">
      <h2>Static Methods</h2>
      <dl class="callables">''');
      for (var context14 in context2.publicStaticMethods) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_callable_6(context14, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
      for (var context15 in context2.publicConstantFieldsSorted) {
        buffer.write('\n        ');
        buffer.write(
            _renderMixin_partial_constant_7(context15, context2, context0));
      }
      buffer.write('''
      </dl>
    </section>''');
    }
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderMixin_partial_search_sidebar_8(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMixin_partial_footer_9(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_head_0(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderMixin_partial_source_link_1(
    Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_feature_set_2(
    Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_categorization_3(
    Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_documentation_4(
    Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_property_5(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="property''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span> ''');
  buffer.write(__renderMixin_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderMixin_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderMixin_partial_property_5_partial_categorization_0(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderMixin_partial_property_5_partial_features_1(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_callable_6(
    Method context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="callable''');
  if (context2.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated == true) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(__renderMixin_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderMixin_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.write('''
</dd>
''');
  return buffer.toString();
}

String __renderMixin_partial_callable_6_partial_categorization_0(
    Method context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderMixin_partial_callable_6_partial_features_1(
    Method context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_constant_7(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.write(htmlEscape.convert(context2.htmlId.toString()));
  buffer.write('''" class="constant">
  <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName.toString());
  buffer.write('''</span>
  <span class="signature">&#8594; const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.write('''</span>
  ''');
  buffer.write(__renderMixin_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('\n  ');
  buffer.write(__renderMixin_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.write('''
  <div>
    <span class="signature"><code>''');
  buffer.write(context2.constantValueTruncated.toString());
  buffer.write('''</code></span>
  </div>
</dd>
''');
  return buffer.toString();
}

String __renderMixin_partial_constant_7_partial_categorization_0(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    for (var context3 in context2.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderMixin_partial_constant_7_partial_features_1(
    Field context2, Mixin context1, MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderMixin_partial_search_sidebar_8(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderMixin_partial_footer_9(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderProperty(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderProperty_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderProperty_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-property">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderProperty_partial_feature_set_2(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.writeln();
  if (context0.self != null) {
    var context2 = context0.self;
    if (context2.hasNoGetterSetter == true) {
      buffer.write('''
        <section class="multi-line-signature">
          ''');
      buffer.write(context2.modelType.linkedName.toString());
      buffer.write('\n          ');
      buffer.write(_renderProperty_partial_name_summary_3(context2, context0));
      buffer.write('\n          ');
      buffer.write(_renderProperty_partial_features_4(context2, context0));
      buffer.write('''
        </section>
        ''');
      buffer.write(_renderProperty_partial_documentation_5(context2, context0));
      buffer.write('\n        ');
      buffer.write(_renderProperty_partial_source_code_6(context2, context0));
    }
    buffer.writeln();
    if (context2.hasGetterOrSetter == true) {
      if (context2.hasGetter == true) {
        buffer.write('\n        ');
        buffer.write(
            _renderProperty_partial_accessor_getter_7(context2, context0));
      }
      buffer.writeln();
      if (context2.hasSetter == true) {
        buffer.write('\n        ');
        buffer.write(
            _renderProperty_partial_accessor_setter_8(context2, context0));
      }
    }
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderProperty_partial_search_sidebar_9(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderProperty_partial_footer_10(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_head_0(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderProperty_partial_source_link_1(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_feature_set_2(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_name_summary_3(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context1.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String _renderProperty_partial_features_4(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_documentation_5(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_source_code_6(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_accessor_getter_7(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.getter != null) {
    var context2 = context1.getter;
    buffer.write('''
<section id="getter">

<section class="multi-line-signature">
  <span class="returntype">''');
    buffer.write(context2.modelType.returnType.linkedName.toString());
    buffer.write('''</span>
  ''');
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('\n  ');
    buffer.write(__renderProperty_partial_accessor_getter_7_partial_features_1(
        context2, context1, context0));
    buffer.write('''
</section>

''');
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_documentation_2(
            context2, context1, context0));
    buffer.writeln();
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_source_code_3(
            context2, context1, context0));
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_name_summary_0(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context2.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_features_1(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_documentation_2(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context2.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_source_code_3(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context2.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_accessor_setter_8(
    Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.setter != null) {
    var context2 = context1.setter;
    buffer.write('''
<section id="setter">

<section class="multi-line-signature">
  <span class="returntype">void</span>
  ''');
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('''<span class="signature">(<wbr>''');
    buffer.write(context2.linkedParamsNoMetadata.toString());
    buffer.write(''')</span>
  ''');
    buffer.write(__renderProperty_partial_accessor_setter_8_partial_features_1(
        context2, context1, context0));
    buffer.write('''
</section>

''');
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_documentation_2(
            context2, context1, context0));
    buffer.writeln();
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_source_code_3(
            context2, context1, context0));
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_name_summary_0(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context2.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_features_1(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_documentation_2(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context2.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_source_code_3(
    ContainerAccessor context2, Field context1, PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context2.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderProperty_partial_search_sidebar_9(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderProperty_partial_footer_10(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderSidebarForContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  if (context0.container != null) {
    var context1 = context0.container;
    buffer.writeln();
    if (context1.isClass == true) {
      if (context1.hasPublicConstructors == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#constructors">Constructors</a></li>''');
        for (var context2 in context1.publicConstructorsSorted) {
          buffer.write('''
    <li><a''');
          if (context2.isDeprecated == true) {
            buffer.write(''' class="deprecated"''');
          }
          buffer.write(''' href="''');
          buffer.write(context2.href.toString());
          buffer.write('''">''');
          buffer.write(htmlEscape.convert(context2.shortName.toString()));
          buffer.write('''</a></li>''');
        }
      }
    }
    buffer.writeln();
    if (context1.isEnum == true) {
      if (context1.hasPublicConstantFields == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#constants">Constants</a></li>''');
        for (var context3 in context1.publicConstantFieldsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context3.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
    buffer.writeln();
    if (context1.isClassOrEnum == true) {
      if (context1.hasPublicInstanceFields == true) {
        buffer.write('''
    <li class="section-title''');
        if (context1.publicInheritedInstanceFields == true) {
          buffer.write(''' inherited''');
        }
        buffer.write('''">
      <a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#instance-properties">Properties</a>
    </li>''');
        for (var context4 in context1.publicInstanceFieldsSorted) {
          buffer.write('''
    <li''');
          if (context4.isInherited == true) {
            buffer.write(''' class="inherited"''');
          }
          buffer.write('''>''');
          buffer.write(context4.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicInstanceMethods == true) {
        buffer.write('''
    <li class="section-title''');
        if (context1.publicInheritedInstanceMethods == true) {
          buffer.write(''' inherited''');
        }
        buffer.write('''"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#instance-methods">Methods</a></li>''');
        for (var context5 in context1.publicInstanceMethodsSorted) {
          buffer.write('''
    <li''');
          if (context5.isInherited == true) {
            buffer.write(''' class="inherited"''');
          }
          buffer.write('''>''');
          buffer.write(context5.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicInstanceOperators == true) {
        buffer.write('''
    <li class="section-title''');
        if (context1.publicInheritedInstanceOperators == true) {
          buffer.write(''' inherited''');
        }
        buffer.write('''"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#operators">Operators</a></li>''');
        for (var context6 in context1.publicInstanceOperatorsSorted) {
          buffer.write('''
    <li''');
          if (context6.isInherited == true) {
            buffer.write(''' class="inherited"''');
          }
          buffer.write('''>''');
          buffer.write(context6.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
    buffer.writeln();
    if (context1.isExtension == true) {
      if (context1.hasPublicInstanceFields == true) {
        buffer.write('''
    <li class="section-title"> <a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#instance-properties">Properties</a>
    </li>''');
        for (var context7 in context1.publicInstanceFieldsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context7.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicInstanceMethods == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#instance-methods">Methods</a></li>''');
        for (var context8 in context1.publicInstanceMethodsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context8.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicInstanceOperators == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#operators">Operators</a></li>''');
        for (var context9 in context1.publicInstanceOperatorsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context9.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
    buffer.writeln();
    if (context1.isClassOrExtension == true) {
      if (context1.hasPublicVariableStaticFields == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#static-properties">Static properties</a></li>''');
        for (var context10 in context1.publicVariableStaticFieldsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context10.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicStaticMethods == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#static-methods">Static methods</a></li>''');
        for (var context11 in context1.publicStaticMethodsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context11.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      if (context1.hasPublicConstantFields == true) {
        buffer.write('''
    <li class="section-title"><a href="''');
        buffer.write(context1.href.toString());
        buffer.write('''#constants">Constants</a></li>''');
        for (var context12 in context1.publicConstantFieldsSorted) {
          buffer.write('''
    <li>''');
          buffer.write(context12.linkedName.toString());
          buffer.write('''</li>''');
        }
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String renderSidebarForLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  if (context0.library != null) {
    var context1 = context0.library;
    if (context1.hasPublicClasses == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#classes">Classes</a></li>''');
      for (var context2 in context1.publicClassesSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context2.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicExtensions == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#extension">Extensions</a></li>''');
      for (var context3 in context1.publicExtensionsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context3.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicMixins == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#mixins">Mixins</a></li>''');
      for (var context4 in context1.publicMixinsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context4.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicConstants == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#constants">Constants</a></li>''');
      for (var context5 in context1.publicConstantsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context5.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicProperties == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#properties">Properties</a></li>''');
      for (var context6 in context1.publicPropertiesSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context6.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicFunctions == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#functions">Functions</a></li>''');
      for (var context7 in context1.publicFunctionsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context7.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicEnums == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#enums">Enums</a></li>''');
      for (var context8 in context1.publicEnumsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context8.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicTypedefs == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#typedefs">Typedefs</a></li>''');
      for (var context9 in context1.publicTypedefsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context9.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicExceptions == true) {
      buffer.write('''
  <li class="section-title"><a href="''');
      buffer.write(context1.href.toString());
      buffer.write('''#exceptions">Exceptions</a></li>''');
      for (var context10 in context1.publicExceptionsSorted) {
        buffer.write('''
  <li>''');
        buffer.write(context10.linkedName.toString());
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('''
</ol>
''');
  return buffer.toString();
}

String renderTopLevelProperty(TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTopLevelProperty_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(
        _renderTopLevelProperty_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-top-level-property">''');
    buffer.write(context1.name.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(
        _renderTopLevelProperty_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(
        _renderTopLevelProperty_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>
''');
    if (context1.hasNoGetterSetter == true) {
      buffer.write('''
        <section class="multi-line-signature">
          ''');
      buffer.write(context1.modelType.linkedName.toString());
      buffer.write('\n          ');
      buffer.write(
          _renderTopLevelProperty_partial_name_summary_4(context1, context0));
      buffer.write('\n          ');
      buffer.write(
          _renderTopLevelProperty_partial_features_5(context1, context0));
      buffer.write('''
        </section>
        ''');
      buffer.write(
          _renderTopLevelProperty_partial_documentation_6(context1, context0));
      buffer.write('\n        ');
      buffer.write(
          _renderTopLevelProperty_partial_source_code_7(context1, context0));
    }
    buffer.writeln();
    if (context1.hasExplicitGetter == true) {
      buffer.write('\n        ');
      buffer.write(_renderTopLevelProperty_partial_accessor_getter_8(
          context1, context0));
    }
    buffer.writeln();
    if (context1.hasExplicitSetter == true) {
      buffer.write('\n        ');
      buffer.write(_renderTopLevelProperty_partial_accessor_setter_9(
          context1, context0));
    }
  }
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderTopLevelProperty_partial_search_sidebar_10(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTopLevelProperty_partial_footer_11(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_head_0(
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderTopLevelProperty_partial_source_link_1(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_feature_set_2(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_categorization_3(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_name_summary_4(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context1.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String _renderTopLevelProperty_partial_features_5(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_documentation_6(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_source_code_7(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_accessor_getter_8(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.getter != null) {
    var context2 = context1.getter;
    buffer.write('''
<section id="getter">

<section class="multi-line-signature">
  <span class="returntype">''');
    buffer.write(context2.modelType.returnType.linkedName.toString());
    buffer.write('''</span>
  ''');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('\n  ');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_features_1(
            context2, context1, context0));
    buffer.write('''
</section>

''');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_documentation_2(
            context2, context1, context0));
    buffer.writeln();
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_source_code_3(
            context2, context1, context0));
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_getter_8_partial_name_summary_0(
        Accessor context2,
        TopLevelVariable context1,
        TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context2.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_getter_8_partial_features_1(
    Accessor context2,
    TopLevelVariable context1,
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_getter_8_partial_documentation_2(
        Accessor context2,
        TopLevelVariable context1,
        TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context2.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_getter_8_partial_source_code_3(
    Accessor context2,
    TopLevelVariable context1,
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context2.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_accessor_setter_9(
    TopLevelVariable context1, TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.setter != null) {
    var context2 = context1.setter;
    buffer.write('''
<section id="setter">

<section class="multi-line-signature">
  <span class="returntype">void</span>
  ''');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('''<span class="signature">(<wbr>''');
    buffer.write(context2.linkedParamsNoMetadata.toString());
    buffer.write(''')</span>
  ''');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_features_1(
            context2, context1, context0));
    buffer.write('''
</section>

''');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_documentation_2(
            context2, context1, context0));
    buffer.writeln();
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_source_code_3(
            context2, context1, context0));
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_setter_9_partial_name_summary_0(
        Accessor context2,
        TopLevelVariable context1,
        TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context2.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_setter_9_partial_features_1(
    Accessor context2,
    TopLevelVariable context1,
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''</div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_setter_9_partial_documentation_2(
        Accessor context2,
        TopLevelVariable context1,
        TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context2.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_setter_9_partial_source_code_3(
    Accessor context2,
    TopLevelVariable context1,
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context2.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTopLevelProperty_partial_search_sidebar_10(
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderTopLevelProperty_partial_footer_11(
    TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}

String renderTypedef(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTypedef_partial_head_0(context0));
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  if (context0.self != null) {
    var context1 = context0.self;
    buffer.write('''
      <div>''');
    buffer.write(_renderTypedef_partial_source_link_1(context1, context0));
    buffer.write('''<h1><span class="kind-typedef">''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write('''</span> ''');
    buffer.write(htmlEscape.convert(context1.kind.toString()));
    buffer.write(' ');
    buffer.write(_renderTypedef_partial_feature_set_2(context1, context0));
    buffer.write(' ');
    buffer.write(_renderTypedef_partial_categorization_3(context1, context0));
    buffer.write('''</h1></div>''');
  }
  buffer.write('''

    <section class="multi-line-signature">''');
  if (context0.typeDef != null) {
    var context2 = context0.typeDef;
    buffer.write('\n        ');
    buffer
        .write(_renderTypedef_partial_typedef_multiline_4(context2, context0));
  }
  buffer.write('''
    </section>
''');
  if (context0.typeDef != null) {
    var context3 = context0.typeDef;
    buffer.write('\n    ');
    buffer.write(_renderTypedef_partial_documentation_5(context3, context0));
    buffer.write('\n    ');
    buffer.write(_renderTypedef_partial_source_code_6(context3, context0));
  }
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderTypedef_partial_search_sidebar_7(context0));
  buffer.write('''
    <h5>''');
  buffer.write(htmlEscape.convert(context0.parent.name.toString()));
  buffer.write(' ');
  buffer.write(htmlEscape.convert(context0.parent.kind.toString()));
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary.toString());
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTypedef_partial_footer_8(context0));
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_head_0(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.write(htmlEscape.convert(context0.version.toString()));
    buffer.write('''">''');
  }
  buffer.write('''
  <meta name="description" content="''');
  buffer.write(htmlEscape.convert(context0.metaDescription.toString()));
  buffer.write('''">
  <title>''');
  buffer.write(htmlEscape.convert(context0.title.toString()));
  buffer.write('''</title>''');
  if (context0.relCanonicalPrefix != null) {
    var context1 = context0.relCanonicalPrefix;
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix.toString());
    buffer.write('''/''');
    buffer.write(context0.bareHref.toString());
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref == true) {
    if (context0.htmlBase != null) {
      var context2 = context0.htmlBase;
      buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
      buffer.write(context0.htmlBase.toString());
      buffer.write('''">''');
    }
  }
  buffer.write('\n\n  ');
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/icon?family=Material+Icons" rel="stylesheet">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png">

  ''');
  buffer.write(context0.customHeader.toString());
  buffer.write('''
</head>

''');
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase.toString());
  buffer.write('''"
      data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''">

<div id="overlay-under-drawer"></div>

<header id="title">
  <button id="sidenav-left-toggle" type="button">&nbsp;</button>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  for (var context3 in context0.navLinks) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context3.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context3.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context4 in context0.navLinksWithGenerics) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context4.name.toString()));
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.write(htmlEscape.convert(context0.self.name.toString()));
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<main>
''');
  return buffer.toString();
}

String _renderTypedef_partial_source_link_1(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context1.sourceHref.toString());
    buffer.write('''"><i class="material-icons">description</i></a></div>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_feature_set_2(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    for (var context2 in context1.displayedLanguageFeatures) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_categorization_3(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    for (var context2 in context1.displayedCategories) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel.toString());
    }
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_typedef_multiline_4(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isCallable == true) {
    if (context1.asCallable != null) {
      var context2 = context1.asCallable;
      buffer.write('\n    ');
      buffer.write(
          __renderTypedef_partial_typedef_multiline_4_partial_callable_multiline_0(
              context2, context1, context0));
    }
  }
  if (context1.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(
        __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_1(
            context1, context0));
  }
  buffer.writeln();
  return buffer.toString();
}

String __renderTypedef_partial_typedef_multiline_4_partial_callable_multiline_0(
    FunctionTypedef context2, Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasAnnotations == true) {
    buffer.write('''
<div>
  <ol class="annotation-list">''');
    for (var context3 in context2.annotations) {
      buffer.write('''
    <li>''');
      buffer.write(context3.linkedNameWithParameters.toString());
      buffer.write('''</li>''');
    }
    buffer.write('''
  </ol>
</div>''');
  }
  buffer.write('''

<span class="returntype">''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.write('''</span>
''');
  buffer.write(
      ___renderTypedef_partial_typedef_multiline_4_partial_callable_multiline_0_partial_name_summary_0(
          context2, context1, context0));
  buffer.write(context2.genericParameters.toString());
  buffer.write('''(<wbr>''');
  if (context2.hasParameters == true) {
    buffer.write(context2.linkedParamsLines.toString());
  }
  buffer.write(''')
''');
  return buffer.toString();
}

String
    ___renderTypedef_partial_typedef_multiline_4_partial_callable_multiline_0_partial_name_summary_0(
        FunctionTypedef context2,
        Typedef context1,
        TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context2.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_1(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    buffer.write('''
<div>
  <ol class="annotation-list">''');
    for (var context2 in context1.annotations) {
      buffer.write('''
    <li>''');
      buffer.write(context2.linkedNameWithParameters.toString());
      buffer.write('''</li>''');
    }
    buffer.write('''
  </ol>
</div>''');
  }
  buffer.writeln();
  buffer.write(
      ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_1_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write(''' = ''');
  buffer.write(context1.modelType.linkedName.toString());
  buffer.write('''</span>
''');
  return buffer.toString();
}

String
    ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_1_partial_name_summary_0(
        Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(htmlEscape.convert(context1.name.toString()));
  buffer.write('''</span>''');
  return buffer.toString();
}

String _renderTypedef_partial_documentation_5(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml.toString());
    buffer.write('''
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_source_code_6(
    Typedef context1, TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode.toString());
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();
  return buffer.toString();
}

String _renderTypedef_partial_search_sidebar_7(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  for (var context1 in context0.navLinks) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context1.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context1.name.toString()));
    buffer.write('''</a></li>''');
  }
  for (var context2 in context0.navLinksWithGenerics) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context2.href.toString());
    buffer.write('''">''');
    buffer.write(htmlEscape.convert(context2.name.toString()));
    if (context2.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context2.genericParameters.toString());
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
    buffer.write('''
  <li><a href="''');
    buffer.write(context0.homepage.toString());
    buffer.write('''">''');
    buffer.write(context0.layoutTitle.toString());
    buffer.write('''</a></li>''');
  }
  buffer.write('''
</ol>

''');
  return buffer.toString();
}

String _renderTypedef_partial_footer_8(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.write(htmlEscape.convert(context0.defaultPackage.name.toString()));
  if (context0.hasFooterVersion == true) {
    buffer.write('\n      ');
    buffer
        .write(htmlEscape.convert(context0.defaultPackage.version.toString()));
  }
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter.toString());
  buffer.write('''
</footer>

''');
  buffer.write('''
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js"></script>
<script src="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/script.js"></script>

''');
  buffer.write(context0.customFooter.toString());
  buffer.write('''

</body>

</html>
''');
  return buffer.toString();
}
