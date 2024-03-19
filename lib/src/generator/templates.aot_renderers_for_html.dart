// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// There are a few deduplicated render functions which are generated but not
// used.
// TODO(srawlins): Detect these and do not write them.
// ignore_for_file: unused_element
// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable
// ignore_for_file: non_constant_identifier_names, unnecessary_string_escapes

import 'dart:convert';

import 'package:dartdoc/src/generator/template_data.dart';
import 'package:dartdoc/src/model/accessor.dart';
import 'package:dartdoc/src/model/canonicalization.dart';
import 'package:dartdoc/src/model/category.dart';
import 'package:dartdoc/src/model/class.dart';
import 'package:dartdoc/src/model/constructor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/documentable.dart';
import 'package:dartdoc/src/model/enum.dart';
import 'package:dartdoc/src/model/extension.dart';
import 'package:dartdoc/src/model/extension_type.dart';
import 'package:dartdoc/src/model/field.dart';
import 'package:dartdoc/src/model/getter_setter_combo.dart';
import 'package:dartdoc/src/model/inheriting_container.dart';
import 'package:dartdoc/src/model/library.dart';
import 'package:dartdoc/src/model/method.dart';
import 'package:dartdoc/src/model/mixin.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:dartdoc/src/model/model_function.dart';
import 'package:dartdoc/src/model/operator.dart';
import 'package:dartdoc/src/model/package.dart';
import 'package:dartdoc/src/model/top_level_variable.dart';
import 'package:dartdoc/src/model/typedef.dart';

String renderCategory(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderCategory_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
  <h1><span class="kind-category">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('''</h1>
  ''');
  buffer.write(_renderCategory_partial_documentation_1(context1));
  buffer.writeln();
  if (context1.hasPublicLibraries) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="libraries">
    <h2>Libraries</h2>

    <dl>''');
    var context2 = context1.publicLibrariesSorted;
    for (var context3 in context2) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_library_2(context3));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="classes">
    <h2>Classes</h2>

    <dl>''');
    var context4 = context1.publicClassesSorted;
    for (var context5 in context4) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_container_3(context5));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="mixins">
    <h2>Mixins</h2>

    <dl>''');
    var context6 = context1.publicMixinsSorted;
    for (var context7 in context6) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_container_3(context7));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="extensions">
    <h2>Extensions</h2>

    <dl>''');
    var context8 = context1.publicExtensionsSorted;
    for (var context9 in context8) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_extension_4(context9));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="constants">
    <h2>Constants</h2>

    <dl class="properties">''');
    var context10 = context1.publicConstantsSorted;
    for (var context11 in context10) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_constant_5(context11));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="properties">
    <h2>Properties</h2>

    <dl class="properties">''');
    var context12 = context1.publicPropertiesSorted;
    for (var context13 in context12) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_property_6(context13));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="functions">
    <h2>Functions</h2>

    <dl class="callables">''');
    var context14 = context1.publicFunctionsSorted;
    for (var context15 in context14) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_callable_7(context15));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="enums">
    <h2>Enums</h2>

    <dl>''');
    var context16 = context1.publicEnumsSorted;
    for (var context17 in context16) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_container_3(context17));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="typedefs">
    <h2>Typedefs</h2>

    <dl class="callables">''');
    var context18 = context1.publicTypedefsSorted;
    for (var context19 in context18) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_typedef_8(context19));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  if (context1.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="exceptions">
    <h2>Exceptions / Errors</h2>

    <dl>''');
    var context20 = context1.publicExceptionsSorted;
    for (var context21 in context20) {
      buffer.write('\n      ');
      buffer.write(_renderCategory_partial_container_3(context21));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }
  buffer.writeln();
  buffer.write('''

</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderCategory_partial_search_sidebar_9(context0));
  buffer.writeln();
  buffer.write('''
  <h5><span class="package-name">''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</span></h5>
  ''');
  buffer.write(_renderCategory_partial_packages_10(context0));
  buffer.writeln();
  buffer.write('''
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  <h5>''');
  buffer.writeEscaped(context0.self.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.self.kind.toString());
  buffer.write('''</h5>
  ''');
  buffer.write(_renderCategory_partial_sidebar_for_category_11(context0));
  buffer.writeln();
  buffer.write('''
</div>
<!--/sidebar-offcanvas-right-->
''');
  buffer.write(_renderCategory_partial_footer_12(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderClass(ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderClass_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderClass_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-class">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderClass_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderClass_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.clazz;
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_documentation_4(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    buffer.writeln();
    buffer.write('''
    <section>
      <dl class="dl-horizontal">
        ''');
    buffer.write(_renderClass_partial_super_chain_5(context2));
    buffer.write('\n        ');
    buffer.write(_renderClass_partial_interfaces_6(context2));
    buffer.write('\n        ');
    buffer.write(_renderClass_partial_mixed_in_types_7(context2));
    buffer.writeln();
    if (context2.hasPublicImplementers) {
      buffer.writeln();
      buffer.write('''
          <dt>Implementers</dt>
          <dd><ul class="comma-separated clazz-relationships">''');
      var context3 = context2.publicImplementersSorted;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
              <li>''');
        buffer.write(context4.linkedName);
        buffer.write('''</li>''');
      }
      buffer.writeln();
      buffer.write('''
          </ul></dd>''');
    }
    buffer.writeln();
    if (context2.hasPotentiallyApplicableExtensions) {
      buffer.writeln();
      buffer.write('''
          <dt>Available Extensions</dt>
          <dd><ul class="comma-separated clazz-relationships">''');
      var context5 = context2.potentiallyApplicableExtensionsSorted;
      for (var context6 in context5) {
        buffer.writeln();
        buffer.write('''
              <li>''');
        buffer.write(context6.linkedName);
        buffer.write('''</li>''');
      }
      buffer.writeln();
      buffer.write('''
          </ul></dd>''');
    }
    buffer.write('\n\n        ');
    buffer.write(_renderClass_partial_container_annotations_8(context2));
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderClass_partial_constructors_9(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_instance_fields_10(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_instance_methods_11(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_instance_operators_12(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_static_properties_13(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_static_methods_14(context2));
  buffer.write('\n    ');
  buffer.write(_renderClass_partial_static_constants_15(context2));
  buffer.writeln();
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderClass_partial_search_sidebar_16(context0));
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
    <div id="dartdoc-sidebar-left-content"></div>
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderClass_partial_footer_17(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderConstructor(ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderConstructor_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div
      id="dartdoc-main-content"
      class="main-content"
      data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
      data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderConstructor_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-constructor">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderConstructor_partial_feature_set_2(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.constructor;
  buffer.writeln();
  buffer.write('''
    <section class="multi-line-signature">
      ''');
  buffer.write(_renderConstructor_partial_annotations_3(context2));
  if (context2.isConst) {
    buffer.write('''const''');
  }
  buffer.writeln();
  buffer.write('''
      <span class="name ''');
  if (context2.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.nameWithGenerics);
  buffer.write('''</span>(<wbr>''');
  if (context2.hasParameters) {
    buffer.write(context2.linkedParamsLines);
  }
  buffer.write(''')
    </section>

    ''');
  buffer.write(_renderConstructor_partial_documentation_4(context2));
  buffer.write('\n\n    ');
  buffer.write(_renderConstructor_partial_source_code_5(context2));
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderConstructor_partial_search_sidebar_6(context0));
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
    <div id="dartdoc-sidebar-left-content"></div>
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderConstructor_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderEnum(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderEnum_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderEnum_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write('''
      <h1>
        <span class="kind-enum">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span>
        ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderEnum_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderEnum_partial_categorization_3(context1));
  buffer.writeln();
  buffer.write('''
      </h1>
    </div>''');
  buffer.writeln();
  var context2 = context0.eNum;
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_documentation_4(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    buffer.writeln();
    buffer.write('''
      <section>
        <dl class="dl-horizontal">
          ''');
    buffer.write(_renderEnum_partial_super_chain_5(context2));
    buffer.write('\n          ');
    buffer.write(_renderEnum_partial_interfaces_6(context2));
    buffer.write('\n          ');
    buffer.write(_renderEnum_partial_mixed_in_types_7(context2));
    buffer.write('\n          ');
    buffer.write(_renderEnum_partial_container_annotations_8(context2));
    buffer.writeln();
    buffer.write('''
        </dl>
      </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderEnum_partial_constructors_9(context2));
  buffer.writeln();
  if (context2.hasPublicEnumValues) {
    buffer.writeln();
    buffer.write('''
      <section class="summary offset-anchor" id="values">
        <h2>Values</h2>

        <dl class="properties">''');
    var context3 = context2.publicEnumValues;
    for (var context4 in context3) {
      buffer.write('\n            ');
      buffer.write(_renderEnum_partial_constant_10(context4));
    }
    buffer.writeln();
    buffer.write('''
        </dl>
      </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderEnum_partial_instance_fields_11(context2));
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_instance_methods_12(context2));
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_instance_operators_13(context2));
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_static_properties_14(context2));
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_static_methods_15(context2));
  buffer.write('\n    ');
  buffer.write(_renderEnum_partial_static_constants_16(context2));
  buffer.writeln();
  buffer.write('''
</div><!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderEnum_partial_search_sidebar_17(context0));
  buffer.writeln();
  buffer.write('''
  <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
  <div id="dartdoc-sidebar-left-content"></div>
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!-- /.sidebar-offcanvas -->

''');
  buffer.write(_renderEnum_partial_footer_18(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderError(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderError_partial_head_0(context0));
  buffer.writeln();
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
  buffer.writeln();
  buffer.write('''
    <h5><span class="package-name">''');
  buffer.writeEscaped(context0.self.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.self.kind.toString());
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderError_partial_packages_2(context0));
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div>

''');
  buffer.write(_renderError_partial_footer_3(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderExtension<T extends Extension>(ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtension_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''
<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderExtension_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-class">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderExtension_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderExtension_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.extension;
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_documentation_4(context2));
  buffer.writeln();
  buffer.write('''
    <section>
      <dl class="dl-horizontal">
        <dt>on</dt>
        <dd>
          <ul class="comma-separated clazz-relationships">''');
  var context3 = context2.extendedType;
  buffer.writeln();
  buffer.write('''
              <li>''');
  buffer.write(context3.linkedName);
  buffer.write('''</li>''');
  buffer.writeln();
  buffer.write('''
          </ul>
        </dd>
      </dl>
      ''');
  buffer.write(_renderExtension_partial_container_annotations_5(context2));
  buffer.writeln();
  buffer.write('''
    </section>

    ''');
  buffer.write(_renderExtension_partial_instance_fields_6(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_instance_methods_7(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_instance_operators_8(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_properties_9(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_methods_10(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_constants_11(context2));
  var context4 = context0.extension;
  buffer.writeln();
  buffer.write('''

</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderExtension_partial_search_sidebar_12(context0));
  buffer.writeln();
  buffer.write('''
  <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
  <div id="dartdoc-sidebar-left-content"></div>
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderExtension_partial_footer_13(context0));
  buffer.writeln();
  buffer.writeln();
  buffer.writeln();

  return buffer.toString();
}

String renderExtensionType<T extends ExtensionType>(
    ExtensionTypeTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtensionType_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''
<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderExtensionType_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-class">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span>
      ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderExtensionType_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderExtensionType_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.extensionType;
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_documentation_4(context2));
  buffer.writeln();
  buffer.write('''
    <section>
      <dl class="dl-horizontal">
        <dt>on</dt>
        <dd>
          <ul class="comma-separated clazz-relationships">''');
  var context3 = context2.representationType;
  buffer.writeln();
  buffer.write('''
              <li>''');
  buffer.write(context3.linkedName);
  buffer.write('''</li>''');
  buffer.writeln();
  buffer.write('''
          </ul>
        </dd>
        ''');
  buffer.write(_renderExtensionType_partial_interfaces_5(context2));
  buffer.writeln();
  if (context2.hasPublicImplementers) {
    buffer.writeln();
    buffer.write('''
          <dt>Implementers</dt>
          <dd><ul class="comma-separated clazz-relationships">''');
    var context4 = context2.publicImplementersSorted;
    for (var context5 in context4) {
      buffer.writeln();
      buffer.write('''
              <li>''');
      buffer.write(context5.linkedName);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
          </ul></dd>''');
  }
  buffer.writeln();
  buffer.write('''
      </dl>
      ''');
  buffer.write(_renderExtensionType_partial_container_annotations_6(context2));
  buffer.writeln();
  buffer.write('''
    </section>

    ''');
  buffer.write(_renderExtensionType_partial_constructors_7(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_instance_fields_8(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_instance_methods_9(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_instance_operators_10(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_static_properties_11(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_static_methods_12(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtensionType_partial_static_constants_13(context2));
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
</div><!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderExtensionType_partial_search_sidebar_14(context0));
  buffer.writeln();
  buffer.write('''
  <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
  <div id="dartdoc-sidebar-left-content"></div>
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderExtensionType_partial_footer_15(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderFunction(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFunction_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div
      id="dartdoc-main-content"
      class="main-content"
      data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
      data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderFunction_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-function">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderFunction_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderFunction_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.function;
  buffer.writeln();
  buffer.write('''
    <section class="multi-line-signature">
        ''');
  buffer.write(_renderFunction_partial_callable_multiline_4(context2));
  buffer.write('\n        ');
  buffer.write(_renderFunction_partial_attributes_5(context2));
  buffer.writeln();
  buffer.write('''
    </section>
    ''');
  buffer.write(_renderFunction_partial_documentation_6(context2));
  buffer.write('\n\n    ');
  buffer.write(_renderFunction_partial_source_code_7(context2));
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderFunction_partial_search_sidebar_8(context0));
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
    <div id="dartdoc-sidebar-left-content"></div>
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderFunction_partial_footer_9(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderIndex(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderIndex_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.defaultPackage;
  buffer.write('\n      ');
  buffer.write(_renderIndex_partial_documentation_1(context1));
  buffer.writeln();
  var context2 = context0.localPackages;
  for (var context3 in context2) {
    buffer.writeln();
    buffer.write('''
      <section class="summary">''');
    if (context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
          <h2>Libraries</h2>''');
    }
    if (!context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
          <h2>''');
      buffer.writeEscaped(context3.name);
      buffer.write('''</h2>''');
    }
    buffer.writeln();
    buffer.write('''
        <dl>''');
    var context4 = context3.defaultCategory;
    var context5 = context4.publicLibrariesSorted;
    for (var context6 in context5) {
      buffer.write('\n          ');
      buffer.write(_renderIndex_partial_library_2(context6));
    }
    var context7 = context3.categoriesWithPublicLibraries;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write('''
          <h3>''');
      buffer.writeEscaped(context8.name);
      buffer.write('''</h3>''');
      if (context8.isDocumented) {
        buffer.writeln();
        buffer.write('''
          <p>''');
        buffer.write(context8.oneLineDoc);
        buffer.write('''</p>''');
      }
      var context9 = context8.externalItems;
      for (var context10 in context9) {
        buffer.writeln();
        buffer.write('''
            <dt>
              <span class="name">
                <a href="''');
        buffer.writeEscaped(context10.url);
        buffer.write('''" target="_blank">
                  ''');
        buffer.writeEscaped(context10.name);
        buffer.writeln();
        buffer.write('''
                  <span class="material-symbols-outlined">open_in_new</span>
                </a>
              </span>
            </dt>
            <dd>''');
        buffer.writeEscaped(context10.docs);
        buffer.write('''</dd>''');
      }
      var context11 = context8.publicLibrariesSorted;
      for (var context12 in context11) {
        buffer.write('\n            ');
        buffer.write(_renderIndex_partial_library_2(context12));
      }
    }
    buffer.writeln();
    buffer.write('''
        </dl>
      </section>''');
  }
  buffer.writeln();
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderIndex_partial_search_sidebar_3(context0));
  buffer.writeln();
  buffer.write('''
    <h5 class="hidden-xs"><span class="package-name">''');
  buffer.writeEscaped(context0.self.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.self.kind.toString());
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderIndex_partial_packages_4(context0));
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div>

''');
  buffer.write(_renderIndex_partial_footer_5(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderLibrary(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderLibrary_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">
  ''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>
      ''');
  buffer.write(_renderLibrary_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write('''
      <h1>
        <span class="kind-library">''');
  buffer.write(context1.displayName);
  buffer.write('''</span>
        ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderLibrary_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderLibrary_partial_categorization_3(context1));
  buffer.writeln();
  buffer.write('''
      </h1>
    </div>''');
  buffer.writeln();
  var context2 = context0.library;
  buffer.write('\n    ');
  buffer.write(_renderLibrary_partial_documentation_4(context2));
  buffer.writeln();
  var context3 = context0.library;
  if (context3.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="classes">
      <h2>Classes</h2>

      <dl>''');
    var context4 = context3.library;
    var context5 = context4.publicClassesSorted;
    for (var context6 in context5) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_container_5(context6));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context7 = context0.library;
  if (context7.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="enums">
      <h2>Enums</h2>

      <dl>''');
    var context8 = context7.library;
    var context9 = context8.publicEnumsSorted;
    for (var context10 in context9) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_container_5(context10));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context11 = context0.library;
  if (context11.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="mixins">
      <h2>Mixins</h2>

      <dl>''');
    var context12 = context11.library;
    var context13 = context12.publicMixinsSorted;
    for (var context14 in context13) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_container_5(context14));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context15 = context0.library;
  if (context15.hasPublicExtensionTypes) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="extension-types">
      <h2>Extension Types</h2>

      <dl>''');
    var context16 = context15.library;
    var context17 = context16.publicExtensionTypesSorted;
    for (var context18 in context17) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_extension_type_6(context18));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context19 = context0.library;
  if (context19.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="extensions">
      <h2>Extensions</h2>

      <dl>''');
    var context20 = context19.library;
    var context21 = context20.publicExtensionsSorted;
    for (var context22 in context21) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_extension_7(context22));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context23 = context0.library;
  if (context23.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
    var context24 = context23.library;
    var context25 = context24.publicConstantsSorted;
    for (var context26 in context25) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_constant_8(context26));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context27 = context0.library;
  if (context27.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="properties">
      <h2>Properties</h2>

      <dl class="properties">''');
    var context28 = context27.library;
    var context29 = context28.publicPropertiesSorted;
    for (var context30 in context29) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_property_9(context30));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context31 = context0.library;
  if (context31.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="functions">
      <h2>Functions</h2>

      <dl class="callables">''');
    var context32 = context31.library;
    var context33 = context32.publicFunctionsSorted;
    for (var context34 in context33) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_callable_10(context34));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context35 = context0.library;
  if (context35.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="typedefs">
      <h2>Typedefs</h2>

      <dl>''');
    var context36 = context35.library;
    var context37 = context36.publicTypedefsSorted;
    for (var context38 in context37) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_typedef_11(context38));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context39 = context0.library;
  if (context39.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="exceptions">
      <h2>Exceptions / Errors</h2>

      <dl>''');
    var context40 = context39.library;
    var context41 = context40.publicExceptionsSorted;
    for (var context42 in context41) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_container_5(context42));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderLibrary_partial_search_sidebar_12(context0));
  buffer.writeln();
  buffer.write('''
    <h5><span class="package-name">''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderLibrary_partial_packages_13(context0));
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    <h5>''');
  buffer.writeEscaped(context0.self.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.self.kind.toString());
  buffer.write('''</h5>
  </div><!--/sidebar-offcanvas-right-->

''');
  buffer.write(_renderLibrary_partial_footer_14(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMethod(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMethod_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderMethod_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-method">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.fullkind);
  buffer.write(' ');
  buffer.write(_renderMethod_partial_feature_set_2(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.method;
  buffer.writeln();
  buffer.write('''
    <section class="multi-line-signature">
      ''');
  buffer.write(_renderMethod_partial_callable_multiline_3(context2));
  buffer.write('\n      ');
  buffer.write(_renderMethod_partial_attributes_4(context2));
  buffer.writeln();
  buffer.write('''
    </section>
    ''');
  buffer.write(_renderMethod_partial_documentation_5(context2));
  buffer.write('\n\n    ');
  buffer.write(_renderMethod_partial_source_code_6(context2));
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderMethod_partial_search_sidebar_7(context0));
  if (context0.isParentExtension) {
    buffer.writeln();
    buffer.write('''
    <h5>''');
    buffer.writeEscaped(context0.parent!.name);
    buffer.write(' ');
    buffer.writeEscaped(context0.parent!.kind.toString());
    buffer.write(''' on ''');
    buffer.write(context0.parentAsExtension.extendedType.linkedName);
    buffer.write('''</h5>''');
  }
  if (!context0.isParentExtension) {
    buffer.writeln();
    buffer.write('''
    <h5>''');
    buffer.writeEscaped(context0.parent!.name);
    buffer.write(' ');
    buffer.writeEscaped(context0.parent!.kind.toString());
    buffer.write('''</h5>''');
  }
  buffer.writeln();
  buffer.write('''
    <div id="dartdoc-sidebar-left-content"></div>
  </div><!--/.sidebar-offcanvas-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMethod_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMixin(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMixin_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderMixin_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-mixin">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderMixin_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderMixin_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.mixin;
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_documentation_4(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    buffer.writeln();
    buffer.write('''
      <section>
        <dl class="dl-horizontal">''');
    if (context2.hasPublicSuperclassConstraints) {
      buffer.writeln();
      buffer.write('''
            <dt>Superclass Constraints</dt>
            <dd><ul class="comma-separated dark mixin-relationships">''');
      var context3 = context2.publicSuperclassConstraints;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
                <li>''');
        buffer.write(context4.linkedName);
        buffer.write('''</li>''');
      }
      buffer.writeln();
      buffer.write('''
            </ul></dd>''');
    }
    buffer.write('\n\n          ');
    buffer.write(_renderMixin_partial_super_chain_5(context2));
    buffer.write('\n          ');
    buffer.write(_renderMixin_partial_interfaces_6(context2));
    buffer.writeln();
    if (context2.hasPublicImplementers) {
      buffer.writeln();
      buffer.write('''
            <dt>Mixin Applications</dt>
            <dd>
              <ul class="comma-separated mixin-relationships">''');
      var context5 = context2.publicImplementersSorted;
      for (var context6 in context5) {
        buffer.writeln();
        buffer.write('''
                <li>''');
        buffer.write(context6.linkedName);
        buffer.write('''</li>''');
      }
      buffer.writeln();
      buffer.write('''
              </ul>
            </dd>''');
    }
    buffer.write('\n\n          ');
    buffer.write(_renderMixin_partial_annotations_7(context2));
    buffer.writeln();
    buffer.write('''
        </dl>
      </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderMixin_partial_instance_fields_8(context2));
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_instance_methods_9(context2));
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_instance_operators_10(context2));
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_static_properties_11(context2));
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_static_methods_12(context2));
  buffer.write('\n    ');
  buffer.write(_renderMixin_partial_static_constants_13(context2));
  buffer.writeln();
  buffer.write('''
</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderMixin_partial_search_sidebar_14(context0));
  buffer.writeln();
  buffer.write('''
  <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
  <div id="dartdoc-sidebar-left-content"></div>
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMixin_partial_footer_15(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderProperty(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderProperty_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div
    id="dartdoc-main-content"
    class="main-content"
    data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
    data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderProperty_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-property">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderProperty_partial_feature_set_2(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.self;
  if (context2.hasNoGetterSetter) {
    buffer.writeln();
    buffer.write('''
      <section class="multi-line-signature">
        ''');
    buffer.write(_renderProperty_partial_annotations_3(context2));
    buffer.write('\n        ');
    buffer.write(context2.modelType.linkedName);
    buffer.write('\n        ');
    buffer.write(_renderProperty_partial_name_summary_4(context2));
    buffer.write('\n        ');
    buffer.write(_renderProperty_partial_attributes_5(context2));
    buffer.writeln();
    buffer.write('''
      </section>
      ''');
    buffer.write(_renderProperty_partial_documentation_6(context2));
    buffer.write('\n      ');
    buffer.write(_renderProperty_partial_source_code_7(context2));
  }
  buffer.writeln();
  if (context2.hasGetterOrSetter) {
    if (context2.hasGetter) {
      buffer.write('\n        ');
      buffer.write(_renderProperty_partial_accessor_getter_8(context2));
    }
    buffer.writeln();
    if (context2.hasSetter) {
      buffer.write('\n        ');
      buffer.write(_renderProperty_partial_accessor_setter_9(context2));
    }
  }
  buffer.writeln();
  buffer.write('''
</div> <!-- /.main-content -->

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderProperty_partial_search_sidebar_10(context0));
  if (context0.isParentExtension) {
    buffer.writeln();
    buffer.write('''
  <h5>''');
    buffer.writeEscaped(context0.parent!.name);
    buffer.write(' ');
    buffer.writeEscaped(context0.parent!.kind.toString());
    buffer.write(''' on ''');
    buffer.write(context0.parentAsExtension.extendedType.linkedName);
    buffer.write('''</h5>''');
  }
  if (!context0.isParentExtension) {
    buffer.writeln();
    buffer.write('''
  <h5>''');
    buffer.writeEscaped(context0.parent!.name);
    buffer.write(' ');
    buffer.writeEscaped(context0.parent!.kind.toString());
    buffer.write('''</h5>''');
  }
  buffer.writeln();
  buffer.write('''
  <div id="dartdoc-sidebar-left-content"></div>
</div><!--/.sidebar-offcanvas-->

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderProperty_partial_footer_11(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderSearchPage(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderSearchPage_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div id="dartdoc-main-content" class="main-content">
</div>

<div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
  ''');
  buffer.write(_renderSearchPage_partial_search_sidebar_1(context0));
  buffer.writeln();
  buffer.write('''
  <h5 class="hidden-xs"><span class="package-name">''');
  buffer.writeEscaped(context0.self.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.self.kind.toString());
  buffer.write('''</span></h5>
  ''');
  buffer.write(_renderSearchPage_partial_packages_2(context0));
  buffer.writeln();
  buffer.write('''
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
</div>

''');
  buffer.write(_renderSearchPage_partial_footer_3(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderSidebarForContainer<T extends Documentable>(
    TemplateDataWithContainer<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.container;
  buffer.writeln();
  if (context1.isClassOrEnum) {
    if (context1.hasPublicConstructors) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#constructors">Constructors</a></li>''');
      var context2 = context1.publicConstructorsSorted;
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write('''
          <li><a''');
        if (context3.isDeprecated) {
          buffer.write(''' class="deprecated"''');
        }
        buffer.write(''' href="''');
        buffer.write(context3.href);
        buffer.write('''">''');
        buffer.writeEscaped(context3.shortName);
        buffer.write('''</a></li>''');
      }
    }
  }
  buffer.writeln();
  if (context1.isEnum) {
    if (context1.hasPublicEnumValues) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#values">Values</a></li>''');
      var context4 = context1.publicEnumValues;
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context5.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('\n\n    ');
  if (context1.isClassOrEnum) {
    if (context1.hasPublicInstanceFields) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceFields) {
        buffer.write(''' inherited''');
      }
      buffer.write('''">
          <a href="''');
      buffer.write(context1.href);
      buffer.write('''#instance-properties">Properties</a>
        </li>''');
      var context6 = context1.publicInstanceFieldsSorted;
      for (var context7 in context6) {
        buffer.writeln();
        buffer.write('''
          <li''');
        if (context7.isInherited) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context7.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceMethods) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceMethods) {
        buffer.write(''' inherited''');
      }
      buffer.write('''"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#instance-methods">Methods</a></li>''');
      var context8 = context1.publicInstanceMethodsSorted;
      for (var context9 in context8) {
        buffer.writeln();
        buffer.write('''
          <li''');
        if (context9.isInherited) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context9.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceOperators) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceOperators) {
        buffer.write(''' inherited''');
      }
      buffer.write('''"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#operators">Operators</a></li>''');
      var context10 = context1.publicInstanceOperatorsSorted;
      for (var context11 in context10) {
        buffer.writeln();
        buffer.write('''
          <li''');
        if (context11.isInherited) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context11.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('\n\n    ');
  if (context1.isExtension) {
    if (context1.hasPublicInstanceFields) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"> <a href="''');
      buffer.write(context1.href);
      buffer.write('''#instance-properties">Properties</a></li>''');
      var context12 = context1.publicInstanceFieldsSorted;
      for (var context13 in context12) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context13.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceMethods) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#instance-methods">Methods</a></li>''');
      var context14 = context1.publicInstanceMethodsSorted;
      for (var context15 in context14) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context15.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceOperators) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#operators">Operators</a></li>''');
      var context16 = context1.publicInstanceOperatorsSorted;
      for (var context17 in context16) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context17.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.write('\n\n    ');
  if (context1.isInterfaceOrExtension) {
    if (context1.hasPublicVariableStaticFields) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#static-properties">Static properties</a></li>''');
      var context18 = context1.publicVariableStaticFieldsSorted;
      for (var context19 in context18) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context19.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicStaticMethods) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#static-methods">Static methods</a></li>''');
      var context20 = context1.publicStaticMethodsSorted;
      for (var context21 in context20) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context21.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicConstantFields) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title"><a href="''');
      buffer.write(context1.href);
      buffer.write('''#constants">Constants</a></li>''');
      var context22 = context1.publicConstantFieldsSorted;
      for (var context23 in context22) {
        buffer.writeln();
        buffer.write('''
          <li>''');
        buffer.write(context23.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.writeln();
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String renderSidebarForLibrary<T extends Documentable>(
    TemplateDataWithLibrary<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.library;
  if (context1.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#classes">Classes</a></li>''');
    var context2 = context1.publicClassesSorted;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context3.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#enums">Enums</a></li>''');
    var context4 = context1.publicEnumsSorted;
    for (var context5 in context4) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context5.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#mixins">Mixins</a></li>''');
    var context6 = context1.publicMixinsSorted;
    for (var context7 in context6) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context7.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicExtensionTypes) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#extension-types">Extension Types</a></li>''');
    var context8 = context1.publicExtensionTypesSorted;
    for (var context9 in context8) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context9.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#constants">Constants</a></li>''');
    var context10 = context1.publicConstantsSorted;
    for (var context11 in context10) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context11.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#properties">Properties</a></li>''');
    var context12 = context1.publicPropertiesSorted;
    for (var context13 in context12) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context13.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#functions">Functions</a></li>''');
    var context14 = context1.publicFunctionsSorted;
    for (var context15 in context14) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context15.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#typedefs">Typedefs</a></li>''');
    var context16 = context1.publicTypedefsSorted;
    for (var context17 in context16) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context17.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#exceptions">Exceptions</a></li>''');
    var context18 = context1.publicExceptionsSorted;
    for (var context19 in context18) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context19.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#extensions">Extensions</a></li>''');
    var context20 = context1.publicExtensionsSorted;
    for (var context21 in context20) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context21.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String renderTopLevelProperty(TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTopLevelProperty_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div
      id="dartdoc-main-content"
      class="main-content"
      data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
      data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderTopLevelProperty_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-top-level-property">''');
  buffer.write(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderTopLevelProperty_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderTopLevelProperty_partial_categorization_3(context1));
  buffer.write('''</h1></div>
''');
  if (context1.hasNoGetterSetter) {
    buffer.writeln();
    buffer.write('''
        <section class="multi-line-signature">
          ''');
    buffer.write(_renderTopLevelProperty_partial_annotations_4(context1));
    buffer.write('\n          ');
    buffer.write(context1.modelType.linkedName);
    buffer.write('\n          ');
    buffer.write(_renderTopLevelProperty_partial_name_summary_5(context1));
    buffer.write('\n          ');
    buffer.write(_renderTopLevelProperty_partial_attributes_6(context1));
    buffer.writeln();
    buffer.write('''
        </section>
        ''');
    buffer.write(_renderTopLevelProperty_partial_documentation_7(context1));
    buffer.write('\n        ');
    buffer.write(_renderTopLevelProperty_partial_source_code_8(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitGetter) {
    buffer.write('\n        ');
    buffer.write(_renderTopLevelProperty_partial_accessor_getter_9(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitSetter) {
    buffer.write('\n        ');
    buffer.write(_renderTopLevelProperty_partial_accessor_setter_10(context1));
  }
  buffer.writeln();
  buffer.write('''
  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderTopLevelProperty_partial_search_sidebar_11(context0));
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
    <div id="dartdoc-sidebar-left-content"></div>
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTopLevelProperty_partial_footer_12(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderTypedef(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTypedef_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div
      id="dartdoc-main-content"
      class="main-content"
      data-above-sidebar="''');
  buffer.writeEscaped(context0.aboveSidebarPath);
  buffer.write('''"
      data-below-sidebar="''');
  buffer.writeEscaped(context0.belowSidebarPath);
  buffer.write('''">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderTypedef_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-typedef">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write(' ');
  buffer.write(_renderTypedef_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderTypedef_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  buffer.write('''

    <section class="multi-line-signature">''');
  var context2 = context0.typeDef;
  buffer.write('\n        ');
  buffer.write(_renderTypedef_partial_typedef_multiline_4(context2));
  buffer.writeln();
  buffer.write('''
    </section>
''');
  var context3 = context0.typeDef;
  buffer.write('\n    ');
  buffer.write(_renderTypedef_partial_documentation_5(context3));
  buffer.write('\n    ');
  buffer.write(_renderTypedef_partial_source_code_6(context3));
  buffer.writeln();
  buffer.write('''

  </div> <!-- /.main-content -->

  <div id="dartdoc-sidebar-left" class="sidebar sidebar-offcanvas-left">
    ''');
  buffer.write(_renderTypedef_partial_search_sidebar_7(context0));
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind.toString());
  buffer.write('''</h5>
    <div id="dartdoc-sidebar-left-content"></div>
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTypedef_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_head_0(CategoryTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderCategory_partial_documentation_1(Category context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderCategory_partial_library_2(Library context2) =>
    _deduplicated_lib_templates__library_html(context2);

String _renderCategory_partial_container_3(Container context2) =>
    _deduplicated_lib_templates__container_html(context2);

String _renderCategory_partial_extension_4(Extension context2) =>
    _deduplicated_lib_templates__extension_html(context2);

String _renderCategory_partial_constant_5(TopLevelVariable context2) =>
    _deduplicated_lib_templates__constant_html(context2);

String _renderCategory_partial_property_6(TopLevelVariable context2) =>
    _deduplicated_lib_templates__property_html(context2);

String _renderCategory_partial_callable_7(ModelFunctionTyped context2) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context2.htmlId);
  buffer.write('''" class="callable''');
  if (context2.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context2.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.linkedName);
  buffer.write('''</span>''');
  buffer.write(context2.linkedGenericParameters);
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context2.linkedParamsNoMetadata);
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context2.modelType.returnType.linkedName);
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      __renderCategory_partial_callable_7_partial_categorization_0(context2));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context2.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      __renderCategory_partial_callable_7_partial_attributes_1(context2));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __renderCategory_partial_callable_7_partial_categorization_0(
        ModelFunctionTyped context2) =>
    _deduplicated_lib_templates__categorization_html(context2);

String __renderCategory_partial_callable_7_partial_attributes_1(
        ModelFunctionTyped context2) =>
    _deduplicated_lib_templates__attributes_html(context2);

String _renderCategory_partial_typedef_8(Typedef context2) =>
    _deduplicated_lib_templates__typedef_html(context2);

String _renderCategory_partial_search_sidebar_9(
        CategoryTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderCategory_partial_packages_10(CategoryTemplateData context0) =>
    _deduplicated_lib_templates__packages_html(context0);

String _renderCategory_partial_sidebar_for_category_11(
    CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.self;
  if (context1.hasPublicLibraries) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#libraries">Libraries</a></li>''');
    var context2 = context0.self;
    var context3 = context2.publicLibrariesSorted;
    for (var context4 in context3) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context4.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context5 = context0.self;
  if (context5.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#classes">Classes</a></li>''');
    var context6 = context0.self;
    var context7 = context6.publicClassesSorted;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context8.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context9 = context0.self;
  if (context9.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#enums">Enums</a></li>''');
    var context10 = context0.self;
    var context11 = context10.publicEnumsSorted;
    for (var context12 in context11) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context12.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context13 = context0.self;
  if (context13.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#mixins">Mixins</a></li>''');
    var context14 = context0.self;
    var context15 = context14.publicMixinsSorted;
    for (var context16 in context15) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context16.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context17 = context0.self;
  if (context17.hasPublicExtensionTypes) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#extension-types">Extension Types</a></li>''');
    var context18 = context0.self;
    var context19 = context18.publicExtensionTypesSorted;
    for (var context20 in context19) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context20.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context21 = context0.self;
  if (context21.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#constants">Constants</a></li>''');
    var context22 = context0.self;
    var context23 = context22.publicConstantsSorted;
    for (var context24 in context23) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context24.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context25 = context0.self;
  if (context25.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#properties">Properties</a></li>''');
    var context26 = context0.self;
    var context27 = context26.publicPropertiesSorted;
    for (var context28 in context27) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context28.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context29 = context0.self;
  if (context29.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#functions">Functions</a></li>''');
    var context30 = context0.self;
    var context31 = context30.publicFunctionsSorted;
    for (var context32 in context31) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context32.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context33 = context0.self;
  if (context33.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
  <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#typedefs">Typedefs</a></li>''');
    var context34 = context0.self;
    var context35 = context34.publicTypedefsSorted;
    for (var context36 in context35) {
      buffer.writeln();
      buffer.write('''
  <li>''');
      buffer.write(context36.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context37 = context0.self;
  if (context37.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
  <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#exceptions">Exceptions</a></li>''');
    var context38 = context0.self;
    var context39 = context38.publicExceptionsSorted;
    for (var context40 in context39) {
      buffer.writeln();
      buffer.write('''
  <li>''');
      buffer.write(context40.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  var context41 = context0.self;
  if (context41.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
  <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#extensions">Extensions</a></li>''');
    var context42 = context0.self;
    var context43 = context42.publicExtensionsSorted;
    for (var context44 in context43) {
      buffer.writeln();
      buffer.write('''
  <li>''');
      buffer.write(context44.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String _renderCategory_partial_footer_12(CategoryTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderClass_partial_head_0(ClassTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderClass_partial_source_link_1(Class context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderClass_partial_feature_set_2(Class context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderClass_partial_categorization_3(Class context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderClass_partial_documentation_4(Class context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderClass_partial_super_chain_5(Class context1) =>
    _deduplicated_lib_templates__super_chain_html(context1);

String _renderClass_partial_interfaces_6(Class context1) =>
    _deduplicated_lib_templates__interfaces_html(context1);

String _renderClass_partial_mixed_in_types_7(Class context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes) {
    buffer.writeln();
    buffer.write('''
  <dt>Mixed in types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context1.relationshipsClass);
    buffer.write('''">''');
    var context2 = context1.publicMixedInTypes;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context3.linkedName);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ul>
  </dd>''');
  }

  return buffer.toString();
}

String _renderClass_partial_container_annotations_8(Class context1) =>
    _deduplicated_lib_templates__container_annotations_html(context1);

String _renderClass_partial_constructors_9(Class context1) =>
    _deduplicated_lib_templates__constructors_html(context1);

String _renderClass_partial_instance_fields_10(Class context1) =>
    _deduplicated_lib_templates__instance_fields_html(context1);

String _renderClass_partial_instance_methods_11(Class context1) =>
    _deduplicated_lib_templates__instance_methods_html(context1);

String _renderClass_partial_instance_operators_12(Class context1) =>
    _deduplicated_lib_templates__instance_operators_html(context1);

String _renderClass_partial_static_properties_13(Class context1) =>
    _deduplicated_lib_templates__static_properties_html(context1);

String _renderClass_partial_static_methods_14(Class context1) =>
    _deduplicated_lib_templates__static_methods_html(context1);

String _renderClass_partial_static_constants_15(Class context1) =>
    _deduplicated_lib_templates__static_constants_html(context1);

String _renderClass_partial_search_sidebar_16(ClassTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderClass_partial_footer_17(ClassTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderConstructor_partial_head_0(ConstructorTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderConstructor_partial_source_link_1(Constructor context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderConstructor_partial_feature_set_2(Constructor context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderConstructor_partial_annotations_3(Constructor context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String _renderConstructor_partial_documentation_4(Constructor context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderConstructor_partial_source_code_5(Constructor context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderConstructor_partial_search_sidebar_6(
        ConstructorTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderConstructor_partial_footer_7(ConstructorTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderEnum_partial_head_0(EnumTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderEnum_partial_source_link_1(Enum context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderEnum_partial_feature_set_2(Enum context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderEnum_partial_categorization_3(Enum context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderEnum_partial_documentation_4(Enum context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderEnum_partial_super_chain_5(Enum context1) =>
    _deduplicated_lib_templates__super_chain_html(context1);

String _renderEnum_partial_interfaces_6(Enum context1) =>
    _deduplicated_lib_templates__interfaces_html(context1);

String _renderEnum_partial_mixed_in_types_7(Enum context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes) {
    buffer.writeln();
    buffer.write('''
  <dt>Mixed in types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context1.relationshipsClass);
    buffer.write('''">''');
    var context2 = context1.publicMixedInTypes;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context3.linkedName);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ul>
  </dd>''');
  }

  return buffer.toString();
}

String _renderEnum_partial_container_annotations_8(Enum context1) =>
    _deduplicated_lib_templates__container_annotations_html(context1);

String _renderEnum_partial_constructors_9(Enum context1) =>
    _deduplicated_lib_templates__constructors_html(context1);

String _renderEnum_partial_constant_10(Field context2) =>
    _deduplicated_lib_templates__constant_html(context2);

String _renderEnum_partial_instance_fields_11(Enum context1) =>
    _deduplicated_lib_templates__instance_fields_html(context1);

String _renderEnum_partial_instance_methods_12(Enum context1) =>
    _deduplicated_lib_templates__instance_methods_html(context1);

String _renderEnum_partial_instance_operators_13(Enum context1) =>
    _deduplicated_lib_templates__instance_operators_html(context1);

String _renderEnum_partial_static_properties_14(Enum context1) =>
    _deduplicated_lib_templates__static_properties_html(context1);

String _renderEnum_partial_static_methods_15(Enum context1) =>
    _deduplicated_lib_templates__static_methods_html(context1);

String _renderEnum_partial_static_constants_16(Enum context1) =>
    _deduplicated_lib_templates__static_constants_html(context1);

String _renderEnum_partial_search_sidebar_17(EnumTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderEnum_partial_footer_18(EnumTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderError_partial_head_0(PackageTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderError_partial_search_sidebar_1(PackageTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderError_partial_packages_2(PackageTemplateData context0) =>
    _deduplicated_lib_templates__packages_html(context0);

String _renderError_partial_footer_3(PackageTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderExtension_partial_head_0<T extends Extension>(
        ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderExtension_partial_source_link_1(Extension context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderExtension_partial_feature_set_2(Extension context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderExtension_partial_categorization_3(Extension context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderExtension_partial_documentation_4(Extension context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderExtension_partial_container_annotations_5(Extension context1) =>
    _deduplicated_lib_templates__container_annotations_html(context1);

String _renderExtension_partial_instance_fields_6(Extension context1) =>
    _deduplicated_lib_templates__instance_fields_html(context1);

String _renderExtension_partial_instance_methods_7(Extension context1) =>
    _deduplicated_lib_templates__instance_methods_html(context1);

String _renderExtension_partial_instance_operators_8(Extension context1) =>
    _deduplicated_lib_templates__instance_operators_html(context1);

String _renderExtension_partial_static_properties_9(Extension context1) =>
    _deduplicated_lib_templates__static_properties_html(context1);

String _renderExtension_partial_static_methods_10(Extension context1) =>
    _deduplicated_lib_templates__static_methods_html(context1);

String _renderExtension_partial_static_constants_11(Extension context1) =>
    _deduplicated_lib_templates__static_constants_html(context1);

String _renderExtension_partial_search_sidebar_12<T extends Extension>(
        ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderExtension_partial_footer_13<T extends Extension>(
        ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderExtensionType_partial_head_0<T extends ExtensionType>(
        ExtensionTypeTemplateData<T> context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderExtensionType_partial_source_link_1(ExtensionType context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderExtensionType_partial_feature_set_2(ExtensionType context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderExtensionType_partial_categorization_3(ExtensionType context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderExtensionType_partial_documentation_4(ExtensionType context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderExtensionType_partial_interfaces_5(ExtensionType context1) =>
    _deduplicated_lib_templates__interfaces_html(context1);

String _renderExtensionType_partial_container_annotations_6(
        ExtensionType context1) =>
    _deduplicated_lib_templates__container_annotations_html(context1);

String _renderExtensionType_partial_constructors_7(ExtensionType context1) =>
    _deduplicated_lib_templates__constructors_html(context1);

String _renderExtensionType_partial_instance_fields_8(ExtensionType context1) =>
    _deduplicated_lib_templates__instance_fields_html(context1);

String _renderExtensionType_partial_instance_methods_9(
        ExtensionType context1) =>
    _deduplicated_lib_templates__instance_methods_html(context1);

String _renderExtensionType_partial_instance_operators_10(
        ExtensionType context1) =>
    _deduplicated_lib_templates__instance_operators_html(context1);

String _renderExtensionType_partial_static_properties_11(
        ExtensionType context1) =>
    _deduplicated_lib_templates__static_properties_html(context1);

String _renderExtensionType_partial_static_methods_12(ExtensionType context1) =>
    _deduplicated_lib_templates__static_methods_html(context1);

String _renderExtensionType_partial_static_constants_13(
        ExtensionType context1) =>
    _deduplicated_lib_templates__static_constants_html(context1);

String _renderExtensionType_partial_search_sidebar_14<T extends ExtensionType>(
        ExtensionTypeTemplateData<T> context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderExtensionType_partial_footer_15<T extends ExtensionType>(
        ExtensionTypeTemplateData<T> context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderFunction_partial_head_0(FunctionTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderFunction_partial_source_link_1(ModelFunction context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderFunction_partial_feature_set_2(ModelFunction context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderFunction_partial_categorization_3(ModelFunction context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderFunction_partial_callable_multiline_4(ModelFunction context1) {
  final buffer = StringBuffer();
  buffer.write(
      __renderFunction_partial_callable_multiline_4_partial_annotations_0(
          context1));
  buffer.writeln();
  buffer.write('''

<span class="returntype">''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write('''</span>
''');
  buffer.write(
      __renderFunction_partial_callable_multiline_4_partial_name_summary_1(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write('''(<wbr>''');
  if (context1.hasParameters) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderFunction_partial_callable_multiline_4_partial_annotations_0(
        ModelFunction context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String __renderFunction_partial_callable_multiline_4_partial_name_summary_1(
        ModelFunction context1) =>
    _deduplicated_lib_templates__name_summary_html(context1);

String _renderFunction_partial_attributes_5(ModelFunction context1) =>
    _deduplicated_lib_templates__attributes_html(context1);

String _renderFunction_partial_documentation_6(ModelFunction context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderFunction_partial_source_code_7(ModelFunction context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderFunction_partial_search_sidebar_8(
        FunctionTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderFunction_partial_footer_9(FunctionTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderIndex_partial_head_0(PackageTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderIndex_partial_documentation_1(Package context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderIndex_partial_library_2(Library context3) =>
    _deduplicated_lib_templates__library_html(context3);

String _renderIndex_partial_search_sidebar_3(PackageTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderIndex_partial_packages_4(PackageTemplateData context0) =>
    _deduplicated_lib_templates__packages_html(context0);

String _renderIndex_partial_footer_5(PackageTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderLibrary_partial_head_0(LibraryTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderLibrary_partial_source_link_1(Library context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderLibrary_partial_feature_set_2(Library context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderLibrary_partial_categorization_3(Library context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderLibrary_partial_documentation_4(Library context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderLibrary_partial_container_5(Container context3) =>
    _deduplicated_lib_templates__container_html(context3);

String _renderLibrary_partial_extension_type_6(ExtensionType context3) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context3.htmlId);
  buffer.write('''">
    <span class="name ''');
  if (context3.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName);
  buffer.write('''</span> ''');
  buffer.write(
      __renderLibrary_partial_extension_type_6_partial_categorization_0(
          context3));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
    ''');
  buffer.write(context3.oneLineDoc);
  buffer.writeln();
  buffer.write('''
</dd>

''');

  return buffer.toString();
}

String __renderLibrary_partial_extension_type_6_partial_categorization_0(
        ExtensionType context3) =>
    _deduplicated_lib_templates__categorization_html(context3);

String _renderLibrary_partial_extension_7(Extension context3) =>
    _deduplicated_lib_templates__extension_html(context3);

String _renderLibrary_partial_constant_8(TopLevelVariable context3) =>
    _deduplicated_lib_templates__constant_html(context3);

String _renderLibrary_partial_property_9(TopLevelVariable context3) =>
    _deduplicated_lib_templates__property_html(context3);

String _renderLibrary_partial_callable_10(ModelFunctionTyped context3) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context3.htmlId);
  buffer.write('''" class="callable''');
  if (context3.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context3.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context3.linkedName);
  buffer.write('''</span>''');
  buffer.write(context3.linkedGenericParameters);
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context3.linkedParamsNoMetadata);
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context3.modelType.returnType.linkedName);
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      __renderLibrary_partial_callable_10_partial_categorization_0(context3));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      __renderLibrary_partial_callable_10_partial_attributes_1(context3));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __renderLibrary_partial_callable_10_partial_categorization_0(
        ModelFunctionTyped context3) =>
    _deduplicated_lib_templates__categorization_html(context3);

String __renderLibrary_partial_callable_10_partial_attributes_1(
        ModelFunctionTyped context3) =>
    _deduplicated_lib_templates__attributes_html(context3);

String _renderLibrary_partial_typedef_11(Typedef context3) =>
    _deduplicated_lib_templates__typedef_html(context3);

String _renderLibrary_partial_search_sidebar_12(LibraryTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderLibrary_partial_packages_13(LibraryTemplateData context0) =>
    _deduplicated_lib_templates__packages_html(context0);

String _renderLibrary_partial_footer_14(LibraryTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderMethod_partial_head_0(MethodTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderMethod_partial_source_link_1(Method context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderMethod_partial_feature_set_2(Method context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderMethod_partial_callable_multiline_3(Method context1) {
  final buffer = StringBuffer();
  buffer.write(
      __renderMethod_partial_callable_multiline_3_partial_annotations_0(
          context1));
  buffer.writeln();
  buffer.write('''

<span class="returntype">''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write('''</span>
''');
  buffer.write(
      __renderMethod_partial_callable_multiline_3_partial_name_summary_1(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write('''(<wbr>''');
  if (context1.hasParameters) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderMethod_partial_callable_multiline_3_partial_annotations_0(
        Method context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String __renderMethod_partial_callable_multiline_3_partial_name_summary_1(
        Method context1) =>
    _deduplicated_lib_templates__name_summary_html(context1);

String _renderMethod_partial_attributes_4(Method context1) =>
    _deduplicated_lib_templates__attributes_html(context1);

String _renderMethod_partial_documentation_5(Method context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderMethod_partial_source_code_6(Method context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderMethod_partial_search_sidebar_7(MethodTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderMethod_partial_footer_8(MethodTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderMixin_partial_head_0(MixinTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderMixin_partial_source_link_1(Mixin context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderMixin_partial_feature_set_2(Mixin context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderMixin_partial_categorization_3(Mixin context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderMixin_partial_documentation_4(Mixin context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderMixin_partial_super_chain_5(Mixin context1) =>
    _deduplicated_lib_templates__super_chain_html(context1);

String _renderMixin_partial_interfaces_6(Mixin context1) =>
    _deduplicated_lib_templates__interfaces_html(context1);

String _renderMixin_partial_annotations_7(Mixin context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String _renderMixin_partial_instance_fields_8(Mixin context1) =>
    _deduplicated_lib_templates__instance_fields_html(context1);

String _renderMixin_partial_instance_methods_9(Mixin context1) =>
    _deduplicated_lib_templates__instance_methods_html(context1);

String _renderMixin_partial_instance_operators_10(Mixin context1) =>
    _deduplicated_lib_templates__instance_operators_html(context1);

String _renderMixin_partial_static_properties_11(Mixin context1) =>
    _deduplicated_lib_templates__static_properties_html(context1);

String _renderMixin_partial_static_methods_12(Mixin context1) =>
    _deduplicated_lib_templates__static_methods_html(context1);

String _renderMixin_partial_static_constants_13(Mixin context1) =>
    _deduplicated_lib_templates__static_constants_html(context1);

String _renderMixin_partial_search_sidebar_14(MixinTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderMixin_partial_footer_15(MixinTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderProperty_partial_head_0(PropertyTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderProperty_partial_source_link_1(Field context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderProperty_partial_feature_set_2(Field context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderProperty_partial_annotations_3(Field context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String _renderProperty_partial_name_summary_4(Field context1) =>
    _deduplicated_lib_templates__name_summary_html(context1);

String _renderProperty_partial_attributes_5(Field context1) =>
    _deduplicated_lib_templates__attributes_html(context1);

String _renderProperty_partial_documentation_6(Field context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderProperty_partial_source_code_7(Field context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderProperty_partial_accessor_getter_8(Field context1) =>
    _deduplicated_lib_templates__accessor_getter_html(context1);

String _renderProperty_partial_accessor_setter_9(Field context1) =>
    _deduplicated_lib_templates__accessor_setter_html(context1);

String _renderProperty_partial_search_sidebar_10(
        PropertyTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderProperty_partial_footer_11(PropertyTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderSearchPage_partial_head_0(PackageTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderSearchPage_partial_search_sidebar_1(
        PackageTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderSearchPage_partial_packages_2(PackageTemplateData context0) =>
    _deduplicated_lib_templates__packages_html(context0);

String _renderSearchPage_partial_footer_3(PackageTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderTopLevelProperty_partial_head_0(
        TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderTopLevelProperty_partial_source_link_1(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderTopLevelProperty_partial_feature_set_2(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderTopLevelProperty_partial_categorization_3(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderTopLevelProperty_partial_annotations_4(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__annotations_html(context1);

String _renderTopLevelProperty_partial_name_summary_5(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__name_summary_html(context1);

String _renderTopLevelProperty_partial_attributes_6(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__attributes_html(context1);

String _renderTopLevelProperty_partial_documentation_7(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderTopLevelProperty_partial_source_code_8(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderTopLevelProperty_partial_accessor_getter_9(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__accessor_getter_html(context1);

String _renderTopLevelProperty_partial_accessor_setter_10(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates__accessor_setter_html(context1);

String _renderTopLevelProperty_partial_search_sidebar_11(
        TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderTopLevelProperty_partial_footer_12(
        TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _renderTypedef_partial_head_0(TypedefTemplateData context0) =>
    _deduplicated_lib_templates__head_html(context0);

String _renderTypedef_partial_source_link_1(Typedef context1) =>
    _deduplicated_lib_templates__source_link_html(context1);

String _renderTypedef_partial_feature_set_2(Typedef context1) =>
    _deduplicated_lib_templates__feature_set_html(context1);

String _renderTypedef_partial_categorization_3(Typedef context1) =>
    _deduplicated_lib_templates__categorization_html(context1);

String _renderTypedef_partial_typedef_multiline_4(Typedef context1) {
  final buffer = StringBuffer();
  if (context1.isCallable) {
    var context2 = context1.asCallable;
    if (context2.hasAnnotations) {
      buffer.writeln();
      buffer.write('''
    <div>
      <ol class="annotation-list">''');
      var context3 = context2.annotations;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
      <li>''');
        buffer.write(context4.linkedNameWithParameters);
        buffer.write('''</li>''');
      }
      buffer.writeln();
      buffer.write('''
    </ol>
    </div>''');
    }
    if (context2.isConst) {
      buffer.write('''const ''');
    }
    buffer.write('''<span class="name ''');
    if (context2.isDeprecated) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.writeEscaped(context2.name);
    buffer.write('''</span>''');
    buffer.write(context2.linkedGenericParameters);
    buffer.write(''' =
     <span class="returntype">''');
    buffer.write(context2.modelType.linkedName);
    buffer.write('''</span>''');
  }
  if (!context1.isCallable) {
    buffer.write('\n  ');
    buffer.write(
        __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
            context1));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
    Typedef context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
<div>
  <ol class="annotation-list">''');
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
    <li>''');
      buffer.write(context3.linkedNameWithParameters);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
  </ol>
</div>''');
  }
  buffer.writeln();
  buffer.write(
      ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write(''' = ''');
  buffer.write(context1.modelType.linkedName);
  buffer.write('''</span>
''');

  return buffer.toString();
}

String
    ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
            Typedef context1) =>
        _deduplicated_lib_templates__name_summary_html(context1);

String _renderTypedef_partial_documentation_5(Typedef context1) =>
    _deduplicated_lib_templates__documentation_html(context1);

String _renderTypedef_partial_source_code_6(Typedef context1) =>
    _deduplicated_lib_templates__source_code_html(context1);

String _renderTypedef_partial_search_sidebar_7(TypedefTemplateData context0) =>
    _deduplicated_lib_templates__search_sidebar_html(context0);

String _renderTypedef_partial_footer_8(TypedefTemplateData context0) =>
    _deduplicated_lib_templates__footer_html(context0);

String _deduplicated_lib_templates__head_html(TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">
  <meta name="description" content="''');
  buffer.writeEscaped(context0.metaDescription);
  buffer.write('''">
  <title>''');
  buffer.writeEscaped(context0.title);
  buffer.write('''</title>''');
  var context1 = context0.relCanonicalPrefix;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
  <link rel="canonical" href="''');
    buffer.write(context0.relCanonicalPrefix);
    buffer.write('''/''');
    buffer.write(context0.bareHref);
    buffer.write('''">''');
  }
  buffer.writeln();
  if (context0.useBaseHref) {
    var context2 = context0.htmlBase;
    buffer.writeln();
    buffer.write('''
  <!-- required because all the links are pseudo-absolute -->
  <base href="''');
    buffer.write(context0.htmlBase);
    buffer.write('''">''');
  }
  buffer.write('\n\n  ');
  buffer.writeln();
  buffer.write('''
  <link rel="preconnect" href="https://fonts.gstatic.com">
  <link href="https://fonts.googleapis.com/css2?family=Roboto+Mono:ital,wght@0,300;0,400;0,500;0,700;1,400&display=swap" rel="stylesheet">
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@24,400,0,0" rel="stylesheet">
  ''');
  buffer.writeln();
  buffer.write('''
  <link rel="stylesheet" href="''');
  if (!context0.useBaseHref) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css?v1">
  <link rel="stylesheet" href="''');
  if (!context0.useBaseHref) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css?v1">
  <link rel="icon" href="''');
  if (!context0.useBaseHref) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/favicon.png?v1">

  ''');
  buffer.write(context0.customHeader);
  buffer.writeln();
  buffer.write('''
</head>

''');
  buffer.writeln();
  buffer.write('''
<body data-base-href="''');
  buffer.write(context0.htmlBase);
  buffer.write('''" data-using-base-href="''');
  buffer.write(context0.useBaseHref.toString());
  buffer.write('''" class="light-theme">

<div id="overlay-under-drawer"></div>

<header id="title">
  <span id="sidenav-left-toggle" class="material-symbols-outlined" role="button" tabindex="0">menu</span>
  <ol class="breadcrumbs gt-separated dark hidden-xs">''');
  var context3 = context0.navLinks;
  for (var context4 in context3) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href);
    buffer.write('''">''');
    buffer.writeEscaped(context4.breadcrumbName);
    buffer.write('''</a></li>''');
  }
  var context5 = context0.navLinksWithGenerics;
  for (var context6 in context5) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context6.href);
    buffer.write('''">''');
    buffer.writeEscaped(context6.breadcrumbName);
    if (context6.hasGenericParameters) {
      buffer.write('''<span class="signature">''');
      buffer.write(context6.genericParameters);
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (!context0.hasHomepage) {
    buffer.writeln();
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage);
    buffer.write('''">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</a></li>''');
  }
  buffer.writeln();
  buffer.write('''
  </ol>
  <div class="self-name">''');
  buffer.writeEscaped(context0.self.name);
  buffer.write('''</div>
  <form class="search navbar-right" role="search">
    <input type="text" id="search-box" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
  <div class="toggle" id="theme-button" title="Toggle brightness">
    <label for="theme">
      <input type="checkbox" id="theme" value="light-theme">
      <span id="dark-theme-button" class="material-symbols-outlined">
        dark_mode
      </span>
      <span id="light-theme-button" class="material-symbols-outlined">
        light_mode
      </span>
    </label>
  </div>
</header>
<main>''');

  return buffer.toString();
}

String _deduplicated_lib_templates__documentation_html(
    Canonicalization context0) {
  final buffer = StringBuffer();
  if (context0.hasDocumentation) {
    buffer.writeln();
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context0.documentationAsHtml);
    buffer.writeln();
    buffer.write('''
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__library_html(Library context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
  <span class="name">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates__library_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>''');
  if (context0.isDocumented) {
    buffer.write(context0.oneLineDoc);
  }
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates__library_html_partial_categorization_0(
    Library context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__categorization_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__container_html(Container context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
  <span class="name ''');
  if (context0.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write(context0.linkedGenericParameters);
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates__container_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates__container_html_partial_categorization_0(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__extension_html(Extension context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
  <span class="name ''');
  if (context0.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span>
  on ''');
  buffer.write(context0.extendedType.linkedName);
  buffer.write('\n  ');
  buffer.write(
      __deduplicated_lib_templates__extension_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.writeln();
  buffer.write('''
</dd>

''');

  return buffer.toString();
}

String __deduplicated_lib_templates__extension_html_partial_categorization_0(
    Extension context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__constant_html(GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="constant">''');
  if (context0.isEnumValue) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context0.isDeprecated) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context0.name);
    buffer.write('''</span>''');
  }
  if (!context0.isEnumValue) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context0.isDeprecated) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context0.linkedName);
    buffer.write('''</span>''');
  }
  buffer.writeln();
  buffer.write('''
  <span class="signature">&#8594; const ''');
  buffer.write(context0.modelType.linkedName);
  buffer.write('''</span>
  ''');
  buffer.write(
      __deduplicated_lib_templates__constant_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(__deduplicated_lib_templates__constant_html_partial_attributes_1(
      context0));
  if (context0.hasConstantValueForDisplay) {
    buffer.writeln();
    buffer.write('''
    <div>
      <span class="signature"><code>''');
    buffer.write(context0.constantValueTruncated);
    buffer.write('''</code></span>
    </div>''');
  }
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates__constant_html_partial_categorization_0(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__constant_html_partial_attributes_1(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__attributes_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__property_html(GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="property''');
  if (context0.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context0.arrow);
  buffer.write(' ');
  buffer.write(context0.modelType.linkedName);
  buffer.write('''</span>
  ''');
  buffer.write(
      __deduplicated_lib_templates__property_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(__deduplicated_lib_templates__property_html_partial_attributes_1(
      context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates__property_html_partial_categorization_0(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__property_html_partial_attributes_1(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__typedef_html(Typedef context0) {
  final buffer = StringBuffer();
  if (context0.isCallable) {
    var context1 = context0.asCallable;
    buffer.writeln();
    buffer.write('''
  <dt id="''');
    buffer.writeEscaped(context1.htmlId);
    buffer.write('''" class="callable''');
    if (context1.isInherited) {
      buffer.write(''' inherited''');
    }
    buffer.write('''">
    <span class="name''');
    if (context1.isDeprecated) {
      buffer.write(''' deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context1.linkedName);
    buffer.write('''</span>''');
    buffer.write(context1.linkedGenericParameters);
    buffer.write('''<span class="signature">
      <span class="returntype parameter">= ''');
    buffer.write(context1.modelType.linkedName);
    buffer.write('''</span>
    </span>
    ''');
    buffer.write(
        __deduplicated_lib_templates__typedef_html_partial_categorization_0(
            context1));
    buffer.writeln();
    buffer.write('''
  </dt>
  <dd''');
    if (context1.isInherited) {
      buffer.write(''' class="inherited"''');
    }
    buffer.write('''>
    ''');
    buffer.write(context1.oneLineDoc);
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates__typedef_html_partial_attributes_1(
            context1));
    buffer.writeln();
    buffer.write('''
  </dd>''');
  }
  if (!context0.isCallable) {
    buffer.write('\n  ');
    buffer.write(
        __deduplicated_lib_templates__typedef_html_partial_type_2(context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__typedef_html_partial_categorization_0(
    FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__typedef_html_partial_attributes_1(
    FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__typedef_html_partial_type_2(
    Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="''');
  if (context0.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context0.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span>''');
  buffer.write(context0.linkedGenericParameters);
  buffer.writeln();
  buffer.write('''
    = ''');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write('''
  </span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__typedef_html_partial_type_2_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__typedef_html_partial_type_2_partial_attributes_1(
          context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__typedef_html_partial_type_2_partial_categorization_0(
        Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__typedef_html_partial_type_2_partial_attributes_1(
        Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__type_html(Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="''');
  if (context0.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context0.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span>''');
  buffer.write(context0.linkedGenericParameters);
  buffer.writeln();
  buffer.write('''
    = ''');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write('''
  </span>
  ''');
  buffer.write(__deduplicated_lib_templates__type_html_partial_categorization_0(
      context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      __deduplicated_lib_templates__type_html_partial_attributes_1(context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates__type_html_partial_categorization_0(
    Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__type_html_partial_attributes_1(
    Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__search_sidebar_html(
    TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write(
      '''<!-- The search input and breadcrumbs below are only responsively visible at low resolutions. -->
<header id="header-search-sidebar" class="hidden-l">
  <form class="search-sidebar" role="search">
    <input type="text" id="search-sidebar" autocomplete="off" disabled class="form-control typeahead" placeholder="Loading search...">
  </form>
</header>

<ol class="breadcrumbs gt-separated dark hidden-l" id="sidebar-nav">''');
  var context1 = context0.navLinks;
  for (var context2 in context1) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context2.href);
    buffer.write('''">''');
    buffer.writeEscaped(context2.name);
    buffer.write('''</a></li>''');
  }
  var context3 = context0.navLinksWithGenerics;
  for (var context4 in context3) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context4.href);
    buffer.write('''">''');
    buffer.writeEscaped(context4.name);
    if (context4.hasGenericParameters) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters);
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (!context0.hasHomepage) {
    buffer.writeln();
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context0.homepage);
    buffer.write('''">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</a></li>''');
  }
  buffer.writeln();
  buffer.write('''
</ol>

''');

  return buffer.toString();
}

String _deduplicated_lib_templates__packages_html(TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.localPackages;
  for (var context2 in context1) {
    if (context2.isFirstPackage) {
      if (context2.hasDocumentedCategories) {
        buffer.writeln();
        buffer.write('''
      <li class="section-title">Topics</li>''');
        var context3 = context2.documentedCategoriesSorted;
        for (var context4 in context3) {
          buffer.writeln();
          buffer.write('''
        <li>''');
          buffer.write(context4.linkedName);
          buffer.write('''</li>''');
        }
      }
      buffer.writeln();
      buffer.write('''
      <li class="section-title">Libraries</li>''');
    }
    if (!context2.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
      <li class="section-title">''');
      buffer.writeEscaped(context2.name);
      buffer.write('''</li>''');
    }
    var context5 = context2.defaultCategory;
    var context6 = context5.publicLibrariesSorted;
    for (var context7 in context6) {
      buffer.writeln();
      buffer.write('''
      <li>''');
      buffer.write(context7.linkedName);
      buffer.write('''</li>''');
    }
    var context8 = context2.categoriesWithPublicLibraries;
    for (var context9 in context8) {
      buffer.writeln();
      buffer.write('''
      <li class="section-subtitle">''');
      buffer.writeEscaped(context9.name);
      buffer.write('''</li>''');
      var context10 = context9.externalItems;
      for (var context11 in context10) {
        buffer.writeln();
        buffer.write('''
        <li class="section-subitem">
          <a href="''');
        buffer.writeEscaped(context11.url);
        buffer.write('''" target="_blank">
            ''');
        buffer.writeEscaped(context11.name);
        buffer.writeln();
        buffer.write('''
            <span class="material-symbols-outlined">open_in_new</span>
          </a>
        </li>''');
      }
      var context12 = context9.publicLibrariesSorted;
      for (var context13 in context12) {
        buffer.writeln();
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context13.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.writeln();
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String _deduplicated_lib_templates__footer_html(TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.writeEscaped(context0.defaultPackage.name);
  if (context0.hasFooterVersion) {
    buffer.write('\n      ');
    buffer.writeEscaped(context0.defaultPackage.version);
  }
  buffer.writeln();
  buffer.write('''
  </span>

  ''');
  buffer.write(context0.customInnerFooter);
  buffer.writeln();
  buffer.write('''
</footer>

''');
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
<script src="''');
  if (!context0.useBaseHref) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js?v1"></script>
<script src="''');
  if (!context0.useBaseHref) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/docs.dart.js"></script>

''');
  buffer.write(context0.customFooter);
  buffer.writeln();
  buffer.write('''

</body>

</html>
''');

  return buffer.toString();
}

String _deduplicated_lib_templates__source_link_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceHref) {
    buffer.writeln();
    buffer.write('''
  <div id="external-links" class="btn-group"><a title="View source code" class="source-link" href="''');
    buffer.write(context0.sourceHref);
    buffer.write(
        '''"><span class="material-symbols-outlined">description</span></a></div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__feature_set_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatureSet) {
    var context1 = context0.displayedLanguageFeatures;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__super_chain_html(
    InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicSuperChainReversed) {
    buffer.writeln();
    buffer.write('''
  <dt>Inheritance</dt>
  <dd>
    <ul class="gt-separated dark ''');
    buffer.writeEscaped(context0.relationshipsClass);
    buffer.write('''">
      <li>''');
    buffer.write(context0.linkedObjectType);
    buffer.write('''</li>''');
    var context1 = context0.publicSuperChainReversed;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context2.linkedName);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
      <li>''');
    buffer.write(context0.name);
    buffer.write('''</li>
    </ul>
  </dd>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__interfaces_html(
    InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInterfaces) {
    buffer.writeln();
    buffer.write('''
  <dt>Implemented types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context0.relationshipsClass);
    buffer.write('''">''');
    var context1 = context0.publicInterfaces;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context2.linkedName);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ul>
  </dd>''');
  }

  return buffer.toString();
}

String _deduplicated_lib_templates__container_annotations_html(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
  <dt>Annotations</dt>
  <dd>
    <ul class="annotation-list ''');
    buffer.writeEscaped(context0.relationshipsClass);
    buffer.write('''">''');
    var context1 = context0.annotations;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context2.linkedNameWithParameters);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ul>
  </dd>''');
  }
  buffer.write('\n\n');

  return buffer.toString();
}

String _deduplicated_lib_templates__constructors_html(
    InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicConstructors) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="constructors">
    <h2>Constructors</h2>

    <dl class="constructor-summary-list">''');
    var context1 = context0.publicConstructorsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
        <dt id="''');
      buffer.writeEscaped(context2.htmlId);
      buffer.write('''" class="callable">
          <span class="name">''');
      buffer.write(context2.linkedName);
      buffer.write('''</span><span class="signature">(''');
      buffer.write(context2.linkedParams);
      buffer.write(''')</span>
        </dt>
        <dd>
          ''');
      buffer.write(context2.oneLineDoc);
      if (context2.isConst) {
        buffer.writeln();
        buffer.write('''
            <div class="constructor-modifier features">const</div>''');
      }
      if (context2.isFactory) {
        buffer.writeln();
        buffer.write('''
            <div class="constructor-modifier features">factory</div>''');
      }
      buffer.writeln();
      buffer.write('''
        </dd>''');
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String _deduplicated_lib_templates__instance_fields_html(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceFields) {
    buffer.writeln();
    buffer.write('''
  <section
      class="summary offset-anchor''');
    if (context0.publicInheritedInstanceFields) {
      buffer.write(''' inherited''');
    }
    buffer.write('''"
      id="instance-properties">
    <h2>Properties</h2>
    <dl class="properties">''');
    var context1 = context0.publicInstanceFieldsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__instance_fields_html_partial_property_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__instance_fields_html_partial_property_0(
    Field context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="property''');
  if (context1.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context1.linkedName);
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context1.arrow);
  buffer.write(' ');
  buffer.write(context1.modelType.linkedName);
  buffer.write('''</span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__instance_fields_html_partial_property_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__instance_fields_html_partial_property_0_partial_attributes_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_fields_html_partial_property_0_partial_categorization_0(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_fields_html_partial_property_0_partial_attributes_1(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__instance_methods_html(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceMethods) {
    buffer.writeln();
    buffer.write('''
  <section
      class="summary offset-anchor''');
    if (context0.publicInheritedInstanceMethods) {
      buffer.write(''' inherited''');
    }
    buffer.write('''"
      id="instance-methods">
    <h2>Methods</h2>
    <dl class="callables">''');
    var context1 = context0.publicInstanceMethodsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__instance_methods_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__instance_methods_html_partial_callable_0(
    Method context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context1.linkedName);
  buffer.write('''</span>''');
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__instance_methods_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__instance_methods_html_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_methods_html_partial_callable_0_partial_categorization_0(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_methods_html_partial_callable_0_partial_attributes_1(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__instance_operators_html(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceOperators) {
    buffer.writeln();
    buffer.write('''
  <section
      class="summary offset-anchor''');
    if (context0.publicInheritedInstanceOperators) {
      buffer.write(''' inherited''');
    }
    buffer.write('''"
      id="operators">
    <h2>Operators</h2>
    <dl class="callables">''');
    var context1 = context0.publicInstanceOperatorsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__instance_operators_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__instance_operators_html_partial_callable_0(
    Operator context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context1.linkedName);
  buffer.write('''</span>''');
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__instance_operators_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__instance_operators_html_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_operators_html_partial_callable_0_partial_categorization_0(
        Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__instance_operators_html_partial_callable_0_partial_attributes_1(
        Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__static_properties_html(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicVariableStaticFields) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="static-properties">
    <h2>Static Properties</h2>

    <dl class="properties">''');
    var context1 = context0.publicVariableStaticFieldsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__static_properties_html_partial_property_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__static_properties_html_partial_property_0(
    Field context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="property''');
  if (context1.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name">''');
  buffer.write(context1.linkedName);
  buffer.write('''</span>
  <span class="signature">''');
  buffer.write(context1.arrow);
  buffer.write(' ');
  buffer.write(context1.modelType.linkedName);
  buffer.write('''</span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__static_properties_html_partial_property_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__static_properties_html_partial_property_0_partial_attributes_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_properties_html_partial_property_0_partial_categorization_0(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_properties_html_partial_property_0_partial_attributes_1(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__static_methods_html(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicStaticMethods) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="static-methods">
    <h2>Static Methods</h2>
    <dl class="callables">''');
    var context1 = context0.publicStaticMethodsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__static_methods_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__static_methods_html_partial_callable_0(
    Method context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated) {
    buffer.write(''' deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context1.linkedName);
  buffer.write('''</span>''');
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''<span class="signature">(<wbr>''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''')
    <span class="returntype parameter">&#8594; ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write('''</span>
  </span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__static_methods_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__static_methods_html_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_methods_html_partial_callable_0_partial_categorization_0(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_methods_html_partial_callable_0_partial_attributes_1(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__static_constants_html(Container context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  if (context0.hasPublicConstantFields) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="constants">
    <h2>Constants</h2>

    <dl class="properties">''');
    var context1 = context0.publicConstantFieldsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates__static_constants_html_partial_constant_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String __deduplicated_lib_templates__static_constants_html_partial_constant_0(
    Field context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="constant">''');
  if (context1.isEnumValue) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context1.isDeprecated) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context1.name);
    buffer.write('''</span>''');
  }
  if (!context1.isEnumValue) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context1.isDeprecated) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context1.linkedName);
    buffer.write('''</span>''');
  }
  buffer.writeln();
  buffer.write('''
  <span class="signature">&#8594; const ''');
  buffer.write(context1.modelType.linkedName);
  buffer.write('''</span>
  ''');
  buffer.write(
      ___deduplicated_lib_templates__static_constants_html_partial_constant_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates__static_constants_html_partial_constant_0_partial_attributes_1(
          context1));
  if (context1.hasConstantValueForDisplay) {
    buffer.writeln();
    buffer.write('''
    <div>
      <span class="signature"><code>''');
    buffer.write(context1.constantValueTruncated);
    buffer.write('''</code></span>
    </div>''');
  }
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_constants_html_partial_constant_0_partial_categorization_0(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates__static_constants_html_partial_constant_0_partial_attributes_1(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__annotations_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
  <div>
    <ol class="annotation-list">''');
    var context1 = context0.annotations;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context2.linkedNameWithParameters);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ol>
  </div>''');
  }

  return buffer.toString();
}

String _deduplicated_lib_templates__source_code_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context0.sourceCode);
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__name_summary_html(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.isConst) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context0.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context0.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String _deduplicated_lib_templates__accessor_getter_html(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.getter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
  <section id="getter">

    <section class="multi-line-signature">
      ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_getter_html_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write('''
      <span class="returntype">''');
    buffer.write(context1.modelType.returnType.linkedName);
    buffer.write('''</span>
      ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_getter_html_partial_name_summary_1(
            context1));
    buffer.write('\n      ');
    buffer.write(
        __deduplicated_lib_templates__accessor_getter_html_partial_attributes_2(
            context1));
    buffer.writeln();
    buffer.write('''
    </section>

    ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_getter_html_partial_documentation_3(
            context1));
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates__accessor_getter_html_partial_source_code_4(
            context1));
    buffer.writeln();
    buffer.write('''
  </section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_getter_html_partial_annotations_0(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
  <div>
    <ol class="annotation-list">''');
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context3.linkedNameWithParameters);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ol>
  </div>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates__accessor_getter_html_partial_name_summary_1(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_getter_html_partial_attributes_2(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates__accessor_getter_html_partial_documentation_3(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation) {
    buffer.writeln();
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml);
    buffer.writeln();
    buffer.write('''
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_getter_html_partial_source_code_4(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode);
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates__accessor_setter_html(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.setter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
  <section id="setter">

    <section class="multi-line-signature">
      ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_setter_html_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write('''
      <span class="returntype">void</span>
      ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_setter_html_partial_name_summary_1(
            context1));
    buffer.write('''<span class="signature">(<wbr>''');
    buffer.write(context1.linkedParamsNoMetadata);
    buffer.write(''')</span>
      ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_setter_html_partial_attributes_2(
            context1));
    buffer.writeln();
    buffer.write('''
    </section>

    ''');
    buffer.write(
        __deduplicated_lib_templates__accessor_setter_html_partial_documentation_3(
            context1));
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates__accessor_setter_html_partial_source_code_4(
            context1));
    buffer.writeln();
    buffer.write('''
  </section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_setter_html_partial_annotations_0(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
  <div>
    <ol class="annotation-list">''');
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context3.linkedNameWithParameters);
      buffer.write('''</li>''');
    }
    buffer.writeln();
    buffer.write('''
    </ol>
  </div>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates__accessor_setter_html_partial_name_summary_1(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_setter_html_partial_attributes_2(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.attributesAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates__accessor_setter_html_partial_documentation_3(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation) {
    buffer.writeln();
    buffer.write('''
<section class="desc markdown">
  ''');
    buffer.write(context1.documentationAsHtml);
    buffer.writeln();
    buffer.write('''
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates__accessor_setter_html_partial_source_code_4(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
<section class="summary source-code" id="source">
  <h2><span>Implementation</span></h2>
  <pre class="language-dart"><code class="language-dart">''');
    buffer.write(context1.sourceCode);
    buffer.write('''</code></pre>
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

extension on StringBuffer {
  void writeEscaped(String? value) {
    write(htmlEscape.convert(value ?? ''));
  }
}
