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
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:convert' as _i23;

import 'package:dartdoc/src/generator/template_data.dart' as _i1;
import 'package:dartdoc/src/model/accessor.dart' as _i22;
import 'package:dartdoc/src/model/category.dart' as _i4;
import 'package:dartdoc/src/model/class.dart' as _i10;
import 'package:dartdoc/src/model/constructor.dart' as _i12;
import 'package:dartdoc/src/model/container.dart' as _i6;
import 'package:dartdoc/src/model/documentable.dart' as _i3;
import 'package:dartdoc/src/model/enum.dart' as _i13;
import 'package:dartdoc/src/model/extension.dart' as _i2;
import 'package:dartdoc/src/model/field.dart' as _i11;
import 'package:dartdoc/src/model/getter_setter_combo.dart' as _i19;
import 'package:dartdoc/src/model/inheriting_container.dart' as _i20;
import 'package:dartdoc/src/model/library.dart' as _i5;
import 'package:dartdoc/src/model/method.dart' as _i15;
import 'package:dartdoc/src/model/mixin.dart' as _i16;
import 'package:dartdoc/src/model/model_element.dart' as _i18;
import 'package:dartdoc/src/model/model_function.dart' as _i8;
import 'package:dartdoc/src/model/operator.dart' as _i21;
import 'package:dartdoc/src/model/package.dart' as _i14;
import 'package:dartdoc/src/model/top_level_variable.dart' as _i7;
import 'package:dartdoc/src/model/typedef.dart' as _i9;
import 'package:dartdoc/src/warnings.dart' as _i17;

String renderCategory(_i1.CategoryTemplateData context0) {
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
  buffer.writeEscaped(context1.kind);
  buffer.write('''</h1>
  ''');
  buffer.write(_renderCategory_partial_documentation_1(context1));
  buffer.writeln();
  if (context1.hasPublicLibraries == true) {
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
  if (context1.hasPublicClasses == true) {
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
  if (context1.hasPublicMixins == true) {
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
  if (context1.hasPublicExtensions == true) {
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
  if (context1.hasPublicConstants == true) {
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
  if (context1.hasPublicProperties == true) {
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
  if (context1.hasPublicFunctions == true) {
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
  if (context1.hasPublicEnums == true) {
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
  if (context1.hasPublicTypedefs == true) {
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
  if (context1.hasPublicExceptions == true) {
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
  buffer.writeEscaped(context0.parent!.kind);
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
  buffer.writeEscaped(context0.self.kind);
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

String renderClass(_i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderClass_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderClass_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-class">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  if (context2.hasModifiers == true) {
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
    if (context2.hasPublicImplementors == true) {
      buffer.writeln();
      buffer.write('''
        <dt>Implementers</dt>
        <dd><ul class="comma-separated clazz-relationships">''');
      var context3 = context2.publicImplementorsSorted;
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
    if (context2.hasPotentiallyApplicableExtensions == true) {
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
  buffer.writeln();
  if (context2.hasPublicInstanceFields == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor''');
    if (context2.publicInheritedInstanceFields == true) {
      buffer.write(''' inherited''');
    }
    buffer.write('''" id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
    var context7 = context2.publicInstanceFieldsSorted;
    for (var context8 in context7) {
      buffer.write('\n        ');
      buffer.write(_renderClass_partial_property_10(context8));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderClass_partial_footer_17(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderConstructor(_i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderConstructor_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderConstructor_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-constructor">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  if (context2.isConst == true) {
    buffer.write('''const''');
  }
  buffer.writeln();
  buffer.write('''
      <span class="name ''');
  if (context2.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context2.nameWithGenerics);
  buffer.write('''</span>(<wbr>''');
  if (context2.hasParameters == true) {
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderConstructor_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderEnum(_i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderEnum_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
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
  buffer.writeEscaped(context1.kind);
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
  if (context2.hasModifiers == true) {
    buffer.writeln();
    buffer.write('''
    <section>
      <dl class="dl-horizontal">
        ''');
    buffer.write(_renderEnum_partial_super_chain_5(context2));
    buffer.write('\n        ');
    buffer.write(_renderEnum_partial_interfaces_6(context2));
    buffer.write('\n        ');
    buffer.write(_renderEnum_partial_mixed_in_types_7(context2));
    buffer.write('\n        ');
    buffer.write(_renderEnum_partial_container_annotations_8(context2));
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderEnum_partial_constructors_9(context2));
  buffer.writeln();
  if (context2.hasPublicEnumValues == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="values">
      <h2>Values</h2>

      <dl class="properties">''');
    var context3 = context2.publicEnumValues;
    for (var context4 in context3) {
      buffer.write('\n          ');
      buffer.write(_renderEnum_partial_constant_10(context4));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  if (context2.hasPublicInstanceFields == true) {
    buffer.writeln();
    buffer.write('''
    <section
        class="
          summary
          offset-anchor''');
    if (context2.publicInheritedInstanceFields == true) {
      buffer.write('''inherited''');
    }
    buffer.write('''"
        id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
    var context5 = context2.publicInstanceFieldsSorted;
    for (var context6 in context5) {
      buffer.write('\n        ');
      buffer.write(_renderEnum_partial_property_11(context6));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!-- /.sidebar-offcanvas -->

''');
  buffer.write(_renderEnum_partial_footer_18(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderError(_i1.PackageTemplateData context0) {
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
  buffer.writeEscaped(context0.self.kind);
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

String renderExtension<T extends _i2.Extension>(
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtension_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

<div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
    <div>''');
  buffer.write(_renderExtension_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-class">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  if (context2.hasPublicInstanceFields == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="instance-properties">
        <h2>Properties</h2>

        <dl class="properties">''');
    var context4 = context2.publicInstanceFieldsSorted;
    for (var context5 in context4) {
      buffer.write('\n            ');
      buffer.write(_renderExtension_partial_property_6(context5));
    }
    buffer.writeln();
    buffer.write('''
        </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
  buffer.write(_renderExtension_partial_instance_methods_7(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_instance_operators_8(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_properties_9(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_methods_10(context2));
  buffer.write('\n    ');
  buffer.write(_renderExtension_partial_static_constants_11(context2));
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
</div>

<div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
</div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderExtension_partial_footer_13(context0));
  buffer.writeln();
  buffer.writeln();

  return buffer.toString();
}

String renderFunction(_i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFunction_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderFunction_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-function">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  buffer.write(_renderFunction_partial_features_5(context2));
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderFunction_partial_footer_9(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderIndex(_i1.PackageTemplateData context0) {
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
    if (context3.isFirstPackage == true) {
      buffer.writeln();
      buffer.write('''
          <h2>Libraries</h2>''');
    }
    if (context3.isFirstPackage != true) {
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
      var context9 = context8.publicLibrariesSorted;
      for (var context10 in context9) {
        buffer.write('\n            ');
        buffer.write(_renderIndex_partial_library_2(context10));
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
  buffer.writeEscaped(context0.self.kind);
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

String renderLibrary(_i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderLibrary_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">
    ''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderLibrary_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-library">''');
  buffer.write(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
  buffer.write(' ');
  buffer.write(_renderLibrary_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderLibrary_partial_categorization_3(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.library;
  buffer.write('\n    ');
  buffer.write(_renderLibrary_partial_documentation_4(context2));
  buffer.writeln();
  var context3 = context0.library;
  if (context3.hasPublicClasses == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="classes">
      <h2>Classes</h2>

      <dl>''');
    var context4 = context3.library;
    var context5 = context4.publicClassesSorted;
    for (var context6 in context5) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_container_5(context6));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context7 = context0.library;
  if (context7.hasPublicMixins == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="mixins">
      <h2>Mixins</h2>

      <dl>''');
    var context8 = context7.library;
    var context9 = context8.publicMixinsSorted;
    for (var context10 in context9) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_container_5(context10));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context11 = context0.library;
  if (context11.hasPublicExtensions == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="extensions">
      <h2>Extensions</h2>

      <dl>''');
    var context12 = context11.library;
    var context13 = context12.publicExtensionsSorted;
    for (var context14 in context13) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_extension_6(context14));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context15 = context0.library;
  if (context15.hasPublicConstants == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="constants">
      <h2>Constants</h2>

      <dl class="properties">''');
    var context16 = context15.library;
    var context17 = context16.publicConstantsSorted;
    for (var context18 in context17) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_constant_7(context18));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context19 = context0.library;
  if (context19.hasPublicProperties == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="properties">
      <h2>Properties</h2>

      <dl class="properties">''');
    var context20 = context19.library;
    var context21 = context20.publicPropertiesSorted;
    for (var context22 in context21) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_property_8(context22));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context23 = context0.library;
  if (context23.hasPublicFunctions == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="functions">
      <h2>Functions</h2>

      <dl class="callables">''');
    var context24 = context23.library;
    var context25 = context24.publicFunctionsSorted;
    for (var context26 in context25) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_callable_9(context26));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context27 = context0.library;
  if (context27.hasPublicEnums == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="enums">
      <h2>Enums</h2>

      <dl>''');
    var context28 = context27.library;
    var context29 = context28.publicEnumsSorted;
    for (var context30 in context29) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_container_5(context30));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context31 = context0.library;
  if (context31.hasPublicTypedefs == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="typedefs">
      <h2>Typedefs</h2>

      <dl>''');
    var context32 = context31.library;
    var context33 = context32.publicTypedefsSorted;
    for (var context34 in context33) {
      buffer.write('\n          ');
      buffer.write(_renderLibrary_partial_typedef_10(context34));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  var context35 = context0.library;
  if (context35.hasPublicExceptions == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor" id="exceptions">
      <h2>Exceptions / Errors</h2>

      <dl>''');
    var context36 = context35.library;
    var context37 = context36.publicExceptionsSorted;
    for (var context38 in context37) {
      buffer.write('\n        ');
      buffer.write(_renderLibrary_partial_container_5(context38));
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
  buffer.write(_renderLibrary_partial_search_sidebar_11(context0));
  buffer.writeln();
  buffer.write('''
    <h5><span class="package-name">''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write('''</span> <span class="package-kind">''');
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</span></h5>
    ''');
  buffer.write(_renderLibrary_partial_packages_12(context0));
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    <h5>''');
  buffer.writeEscaped(context0.self.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.self.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div><!--/sidebar-offcanvas-right-->

''');
  buffer.write(_renderLibrary_partial_footer_13(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMethod(_i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMethod_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
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
  buffer.write(_renderMethod_partial_features_4(context2));
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
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMethod_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMixin(_i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMixin_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderMixin_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-mixin">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  if (context2.hasModifiers == true) {
    buffer.writeln();
    buffer.write('''
    <section>
      <dl class="dl-horizontal">''');
    if (context2.hasPublicSuperclassConstraints == true) {
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
    buffer.write('\n\n        ');
    buffer.write(_renderMixin_partial_super_chain_5(context2));
    buffer.write('\n        ');
    buffer.write(_renderMixin_partial_interfaces_6(context2));
    buffer.writeln();
    if (context2.hasPublicImplementors == true) {
      buffer.writeln();
      buffer.write('''
        <dt>Mixin Applications</dt>
        <dd>
          <ul class="comma-separated mixin-relationships">''');
      var context5 = context2.publicImplementorsSorted;
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
    buffer.write('\n\n        ');
    buffer.write(_renderMixin_partial_annotations_7(context2));
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.writeln();
  if (context2.hasPublicInstanceFields == true) {
    buffer.writeln();
    buffer.write('''
    <section class="summary offset-anchor''');
    if (context2.publicInheritedInstanceFields == true) {
      buffer.write(''' inherited''');
    }
    buffer.write('''" id="instance-properties">
      <h2>Properties</h2>

      <dl class="properties">''');
    var context7 = context2.publicInstanceFields;
    for (var context8 in context7) {
      buffer.write('\n        ');
      buffer.write(_renderMixin_partial_property_8(context8));
    }
    buffer.writeln();
    buffer.write('''
      </dl>
    </section>''');
  }
  buffer.write('\n\n    ');
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div>

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderMixin_partial_footer_15(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderProperty(_i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderProperty_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderProperty_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-property">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
  buffer.write(' ');
  buffer.write(_renderProperty_partial_feature_set_2(context1));
  buffer.write('''</h1></div>''');
  buffer.writeln();
  var context2 = context0.self;
  if (context2.hasNoGetterSetter == true) {
    buffer.writeln();
    buffer.write('''
        <section class="multi-line-signature">
          ''');
    buffer.write(_renderProperty_partial_annotations_3(context2));
    buffer.write('\n          ');
    buffer.write(context2.modelType.linkedName);
    buffer.write('\n          ');
    buffer.write(_renderProperty_partial_name_summary_4(context2));
    buffer.write('\n          ');
    buffer.write(_renderProperty_partial_features_5(context2));
    buffer.writeln();
    buffer.write('''
        </section>
        ''');
    buffer.write(_renderProperty_partial_documentation_6(context2));
    buffer.write('\n        ');
    buffer.write(_renderProperty_partial_source_code_7(context2));
  }
  buffer.writeln();
  if (context2.hasGetterOrSetter == true) {
    if (context2.hasGetter == true) {
      buffer.write('\n        ');
      buffer.write(_renderProperty_partial_accessor_getter_8(context2));
    }
    buffer.writeln();
    if (context2.hasSetter == true) {
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
  buffer.writeln();
  buffer.write('''
    <h5>''');
  buffer.writeEscaped(context0.parent!.name);
  buffer.write(' ');
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForContainer);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderProperty_partial_footer_11(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderSearchPage(_i1.PackageTemplateData context0) {
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
  buffer.writeEscaped(context0.self.kind);
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

String renderSidebarForContainer<T extends _i3.Documentable>(
    _i1.TemplateDataWithContainer<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.container;
  buffer.writeln();
  if (context1.isClassOrEnum == true) {
    if (context1.hasPublicConstructors == true) {
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
        if (context3.isDeprecated == true) {
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
  if (context1.isEnum == true) {
    if (context1.hasPublicEnumValues == true) {
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
  buffer.writeln();
  if (context1.isClassOrEnum == true) {
    if (context1.hasPublicInstanceFields == true) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceFields == true) {
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
        if (context7.isInherited == true) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context7.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceMethods == true) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceMethods == true) {
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
        if (context9.isInherited == true) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context9.linkedName);
        buffer.write('''</li>''');
      }
    }
    buffer.writeln();
    if (context1.hasPublicInstanceOperators == true) {
      buffer.writeln();
      buffer.write('''
        <li class="section-title''');
      if (context1.publicInheritedInstanceOperators == true) {
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
        if (context11.isInherited == true) {
          buffer.write(''' class="inherited"''');
        }
        buffer.write('''>''');
        buffer.write(context11.linkedName);
        buffer.write('''</li>''');
      }
    }
  }
  buffer.writeln();
  if (context1.isExtension == true) {
    if (context1.hasPublicInstanceFields == true) {
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
    if (context1.hasPublicInstanceMethods == true) {
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
    if (context1.hasPublicInstanceOperators == true) {
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
  buffer.writeln();
  if (context1.isClassOrEnumOrExtension == true) {
    if (context1.hasPublicVariableStaticFields == true) {
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
    if (context1.hasPublicStaticMethods == true) {
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
    if (context1.hasPublicConstantFields == true) {
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

String renderSidebarForLibrary<T extends _i3.Documentable>(
    _i1.TemplateDataWithLibrary<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.library;
  if (context1.hasPublicClasses == true) {
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
  if (context1.hasPublicExtensions == true) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#extensions">Extensions</a></li>''');
    var context4 = context1.publicExtensionsSorted;
    for (var context5 in context4) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context5.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicMixins == true) {
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
  if (context1.hasPublicConstants == true) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#constants">Constants</a></li>''');
    var context8 = context1.publicConstantsSorted;
    for (var context9 in context8) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context9.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicProperties == true) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#properties">Properties</a></li>''');
    var context10 = context1.publicPropertiesSorted;
    for (var context11 in context10) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context11.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicFunctions == true) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#functions">Functions</a></li>''');
    var context12 = context1.publicFunctionsSorted;
    for (var context13 in context12) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context13.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicEnums == true) {
    buffer.writeln();
    buffer.write('''
      <li class="section-title"><a href="''');
    buffer.write(context1.href);
    buffer.write('''#enums">Enums</a></li>''');
    var context14 = context1.publicEnumsSorted;
    for (var context15 in context14) {
      buffer.writeln();
      buffer.write('''
        <li>''');
      buffer.write(context15.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  if (context1.hasPublicTypedefs == true) {
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
  if (context1.hasPublicExceptions == true) {
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
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String renderTopLevelProperty(_i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTopLevelProperty_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderTopLevelProperty_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-top-level-property">''');
  buffer.write(context1.name);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
  buffer.write(' ');
  buffer.write(_renderTopLevelProperty_partial_feature_set_2(context1));
  buffer.write(' ');
  buffer.write(_renderTopLevelProperty_partial_categorization_3(context1));
  buffer.write('''</h1></div>
''');
  if (context1.hasNoGetterSetter == true) {
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
    buffer.write(_renderTopLevelProperty_partial_features_6(context1));
    buffer.writeln();
    buffer.write('''
        </section>
        ''');
    buffer.write(_renderTopLevelProperty_partial_documentation_7(context1));
    buffer.write('\n        ');
    buffer.write(_renderTopLevelProperty_partial_source_code_8(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitGetter == true) {
    buffer.write('\n        ');
    buffer.write(_renderTopLevelProperty_partial_accessor_getter_9(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitSetter == true) {
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTopLevelProperty_partial_footer_12(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderTypedef(_i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTypedef_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

  <div id="dartdoc-main-content" class="main-content">''');
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
      <div>''');
  buffer.write(_renderTypedef_partial_source_link_1(context1));
  buffer.write('''<h1><span class="kind-typedef">''');
  buffer.write(context1.nameWithGenerics);
  buffer.write('''</span> ''');
  buffer.writeEscaped(context1.kind);
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
  buffer.writeEscaped(context0.parent!.kind);
  buffer.write('''</h5>
    ''');
  buffer.write(context0.sidebarForLibrary);
  buffer.writeln();
  buffer.write('''
  </div><!--/.sidebar-offcanvas-left-->

  <div id="dartdoc-sidebar-right" class="sidebar sidebar-offcanvas-right">
  </div><!--/.sidebar-offcanvas-->

''');
  buffer.write(_renderTypedef_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_head_0(_i1.CategoryTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderCategory_partial_documentation_1(_i4.Category context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderCategory_partial_library_2(_i5.Library context2) =>
    _deduplicated_lib_templates_html__library_html(context2);
String _renderCategory_partial_container_3(_i6.Container context2) =>
    _deduplicated_lib_templates_html__container_html(context2);
String _renderCategory_partial_extension_4(_i2.Extension context2) =>
    _deduplicated_lib_templates_html__extension_html(context2);
String _renderCategory_partial_constant_5(_i7.TopLevelVariable context2) =>
    _deduplicated_lib_templates_html__constant_html(context2);
String _renderCategory_partial_property_6(_i7.TopLevelVariable context2) =>
    _deduplicated_lib_templates_html__property_html(context2);
String _renderCategory_partial_callable_7(_i8.ModelFunctionTyped context2) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context2.htmlId);
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
  if (context2.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context2.oneLineDoc);
  buffer.write('\n  ');
  buffer
      .write(__renderCategory_partial_callable_7_partial_features_1(context2));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __renderCategory_partial_callable_7_partial_categorization_0(
        _i8.ModelFunctionTyped context2) =>
    _deduplicated_lib_templates_html__categorization_html(context2);
String __renderCategory_partial_callable_7_partial_features_1(
        _i8.ModelFunctionTyped context2) =>
    _deduplicated_lib_templates_html__features_html(context2);
String _renderCategory_partial_typedef_8(_i9.Typedef context2) =>
    _deduplicated_lib_templates_html__typedef_html(context2);
String _renderCategory_partial_search_sidebar_9(
        _i1.CategoryTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderCategory_partial_packages_10(_i1.CategoryTemplateData context0) =>
    _deduplicated_lib_templates_html__packages_html(context0);
String _renderCategory_partial_sidebar_for_category_11(
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.self;
  if (context1.hasPublicLibraries == true) {
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
  if (context5.hasPublicMixins == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#mixins">Mixins</a></li>''');
    var context6 = context0.self;
    var context7 = context6.publicMixinsSorted;
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
  if (context9.hasPublicClasses == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#classes">Classes</a></li>''');
    var context10 = context0.self;
    var context11 = context10.publicClassesSorted;
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
  if (context13.hasPublicConstants == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#constants">Constants</a></li>''');
    var context14 = context0.self;
    var context15 = context14.publicConstantsSorted;
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
  if (context17.hasPublicProperties == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#properties">Properties</a></li>''');
    var context18 = context0.self;
    var context19 = context18.publicPropertiesSorted;
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
  if (context21.hasPublicFunctions == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#functions">Functions</a></li>''');
    var context22 = context0.self;
    var context23 = context22.publicFunctionsSorted;
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
  if (context25.hasPublicEnums == true) {
    buffer.writeln();
    buffer.write('''
    <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#enums">Enums</a></li>''');
    var context26 = context0.self;
    var context27 = context26.publicEnumsSorted;
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
  if (context29.hasPublicTypedefs == true) {
    buffer.writeln();
    buffer.write('''
  <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#typedefs">Typedefs</a></li>''');
    var context30 = context0.self;
    var context31 = context30.publicTypedefsSorted;
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
  if (context33.hasPublicExceptions == true) {
    buffer.writeln();
    buffer.write('''
  <li class="section-title"><a href="''');
    buffer.write(context0.self.href);
    buffer.write('''#exceptions">Exceptions</a></li>''');
    var context34 = context0.self;
    var context35 = context34.publicExceptionsSorted;
    for (var context36 in context35) {
      buffer.writeln();
      buffer.write('''
  <li>''');
      buffer.write(context36.linkedName);
      buffer.write('''</li>''');
    }
  }
  buffer.writeln();
  buffer.write('''
</ol>
''');

  return buffer.toString();
}

String _renderCategory_partial_footer_12(_i1.CategoryTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderClass_partial_head_0(_i1.ClassTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderClass_partial_source_link_1(_i10.Class context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderClass_partial_feature_set_2(_i10.Class context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderClass_partial_categorization_3(_i10.Class context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderClass_partial_documentation_4(_i10.Class context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderClass_partial_super_chain_5(_i10.Class context1) =>
    _deduplicated_lib_templates_html__super_chain_html(context1);
String _renderClass_partial_interfaces_6(_i10.Class context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces == true) {
    buffer.writeln();
    buffer.write('''
  <dt>Implemented types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context1.relationshipsClass);
    buffer.write('''">''');
    var context2 = context1.publicInterfaces;
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

String _renderClass_partial_mixed_in_types_7(_i10.Class context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes == true) {
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

String _renderClass_partial_container_annotations_8(_i10.Class context1) =>
    _deduplicated_lib_templates_html__container_annotations_html(context1);
String _renderClass_partial_constructors_9(_i10.Class context1) =>
    _deduplicated_lib_templates_html__constructors_html(context1);
String _renderClass_partial_property_10(_i11.Field context2) =>
    _deduplicated_lib_templates_html__property_html(context2);
String _renderClass_partial_instance_methods_11(_i10.Class context1) =>
    _deduplicated_lib_templates_html__instance_methods_html(context1);
String _renderClass_partial_instance_operators_12(_i10.Class context1) =>
    _deduplicated_lib_templates_html__instance_operators_html(context1);
String _renderClass_partial_static_properties_13(_i10.Class context1) =>
    _deduplicated_lib_templates_html__static_properties_html(context1);
String _renderClass_partial_static_methods_14(_i10.Class context1) =>
    _deduplicated_lib_templates_html__static_methods_html(context1);
String _renderClass_partial_static_constants_15(_i10.Class context1) =>
    _deduplicated_lib_templates_html__static_constants_html(context1);
String _renderClass_partial_search_sidebar_16(_i1.ClassTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderClass_partial_footer_17(_i1.ClassTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderConstructor_partial_head_0(
        _i1.ConstructorTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderConstructor_partial_source_link_1(_i12.Constructor context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderConstructor_partial_feature_set_2(_i12.Constructor context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderConstructor_partial_annotations_3(_i12.Constructor context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String _renderConstructor_partial_documentation_4(_i12.Constructor context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderConstructor_partial_source_code_5(_i12.Constructor context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderConstructor_partial_search_sidebar_6(
        _i1.ConstructorTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderConstructor_partial_footer_7(
        _i1.ConstructorTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderEnum_partial_head_0(_i1.EnumTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderEnum_partial_source_link_1(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderEnum_partial_feature_set_2(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderEnum_partial_categorization_3(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderEnum_partial_documentation_4(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderEnum_partial_super_chain_5(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__super_chain_html(context1);
String _renderEnum_partial_interfaces_6(_i13.Enum context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces == true) {
    buffer.writeln();
    buffer.write('''
  <dt>Implemented types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context1.relationshipsClass);
    buffer.write('''">''');
    var context2 = context1.publicInterfaces;
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

String _renderEnum_partial_mixed_in_types_7(_i13.Enum context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes == true) {
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

String _renderEnum_partial_container_annotations_8(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__container_annotations_html(context1);
String _renderEnum_partial_constructors_9(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__constructors_html(context1);
String _renderEnum_partial_constant_10(_i11.Field context2) =>
    _deduplicated_lib_templates_html__constant_html(context2);
String _renderEnum_partial_property_11(_i11.Field context2) =>
    _deduplicated_lib_templates_html__property_html(context2);
String _renderEnum_partial_instance_methods_12(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__instance_methods_html(context1);
String _renderEnum_partial_instance_operators_13(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__instance_operators_html(context1);
String _renderEnum_partial_static_properties_14(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__static_properties_html(context1);
String _renderEnum_partial_static_methods_15(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__static_methods_html(context1);
String _renderEnum_partial_static_constants_16(_i13.Enum context1) =>
    _deduplicated_lib_templates_html__static_constants_html(context1);
String _renderEnum_partial_search_sidebar_17(_i1.EnumTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderEnum_partial_footer_18(_i1.EnumTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderError_partial_head_0(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderError_partial_search_sidebar_1(
        _i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderError_partial_packages_2(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__packages_html(context0);
String _renderError_partial_footer_3(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderExtension_partial_head_0<T extends _i2.Extension>(
        _i1.ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderExtension_partial_source_link_1(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderExtension_partial_feature_set_2(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderExtension_partial_categorization_3(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderExtension_partial_documentation_4(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderExtension_partial_container_annotations_5(
        _i2.Extension context1) =>
    _deduplicated_lib_templates_html__container_annotations_html(context1);
String _renderExtension_partial_property_6(_i11.Field context2) =>
    _deduplicated_lib_templates_html__property_html(context2);
String _renderExtension_partial_instance_methods_7(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__instance_methods_html(context1);
String _renderExtension_partial_instance_operators_8(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__instance_operators_html(context1);
String _renderExtension_partial_static_properties_9(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__static_properties_html(context1);
String _renderExtension_partial_static_methods_10(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__static_methods_html(context1);
String _renderExtension_partial_static_constants_11(_i2.Extension context1) =>
    _deduplicated_lib_templates_html__static_constants_html(context1);
String _renderExtension_partial_search_sidebar_12<T extends _i2.Extension>(
        _i1.ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderExtension_partial_footer_13<T extends _i2.Extension>(
        _i1.ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderFunction_partial_head_0(_i1.FunctionTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderFunction_partial_source_link_1(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderFunction_partial_feature_set_2(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderFunction_partial_categorization_3(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderFunction_partial_callable_multiline_4(
    _i8.ModelFunction context1) {
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
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderFunction_partial_callable_multiline_4_partial_annotations_0(
        _i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String __renderFunction_partial_callable_multiline_4_partial_name_summary_1(
        _i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__name_summary_html(context1);
String _renderFunction_partial_features_5(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__features_html(context1);
String _renderFunction_partial_documentation_6(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderFunction_partial_source_code_7(_i8.ModelFunction context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderFunction_partial_search_sidebar_8(
        _i1.FunctionTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderFunction_partial_footer_9(_i1.FunctionTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderIndex_partial_head_0(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderIndex_partial_documentation_1(_i14.Package context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderIndex_partial_library_2(_i5.Library context3) =>
    _deduplicated_lib_templates_html__library_html(context3);
String _renderIndex_partial_search_sidebar_3(
        _i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderIndex_partial_packages_4(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__packages_html(context0);
String _renderIndex_partial_footer_5(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderLibrary_partial_head_0(_i1.LibraryTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderLibrary_partial_source_link_1(_i5.Library context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderLibrary_partial_feature_set_2(_i5.Library context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderLibrary_partial_categorization_3(_i5.Library context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderLibrary_partial_documentation_4(_i5.Library context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderLibrary_partial_container_5(_i6.Container context3) =>
    _deduplicated_lib_templates_html__container_html(context3);
String _renderLibrary_partial_extension_6(_i2.Extension context3) =>
    _deduplicated_lib_templates_html__extension_html(context3);
String _renderLibrary_partial_constant_7(_i7.TopLevelVariable context3) =>
    _deduplicated_lib_templates_html__constant_html(context3);
String _renderLibrary_partial_property_8(_i7.TopLevelVariable context3) =>
    _deduplicated_lib_templates_html__property_html(context3);
String _renderLibrary_partial_callable_9(_i8.ModelFunctionTyped context3) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context3.htmlId);
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
      __renderLibrary_partial_callable_9_partial_categorization_0(context3));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context3.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context3.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(__renderLibrary_partial_callable_9_partial_features_1(context3));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __renderLibrary_partial_callable_9_partial_categorization_0(
        _i8.ModelFunctionTyped context3) =>
    _deduplicated_lib_templates_html__categorization_html(context3);
String __renderLibrary_partial_callable_9_partial_features_1(
        _i8.ModelFunctionTyped context3) =>
    _deduplicated_lib_templates_html__features_html(context3);
String _renderLibrary_partial_typedef_10(_i9.Typedef context3) =>
    _deduplicated_lib_templates_html__typedef_html(context3);
String _renderLibrary_partial_search_sidebar_11(
        _i1.LibraryTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderLibrary_partial_packages_12(_i1.LibraryTemplateData context0) =>
    _deduplicated_lib_templates_html__packages_html(context0);
String _renderLibrary_partial_footer_13(_i1.LibraryTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderMethod_partial_head_0(_i1.MethodTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderMethod_partial_source_link_1(_i15.Method context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderMethod_partial_feature_set_2(_i15.Method context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderMethod_partial_callable_multiline_3(_i15.Method context1) {
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
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderMethod_partial_callable_multiline_3_partial_annotations_0(
        _i15.Method context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String __renderMethod_partial_callable_multiline_3_partial_name_summary_1(
        _i15.Method context1) =>
    _deduplicated_lib_templates_html__name_summary_html(context1);
String _renderMethod_partial_features_4(_i15.Method context1) =>
    _deduplicated_lib_templates_html__features_html(context1);
String _renderMethod_partial_documentation_5(_i15.Method context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderMethod_partial_source_code_6(_i15.Method context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderMethod_partial_search_sidebar_7(
        _i1.MethodTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderMethod_partial_footer_8(_i1.MethodTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderMixin_partial_head_0(_i1.MixinTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderMixin_partial_source_link_1(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderMixin_partial_feature_set_2(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderMixin_partial_categorization_3(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderMixin_partial_documentation_4(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderMixin_partial_super_chain_5(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__super_chain_html(context1);
String _renderMixin_partial_interfaces_6(_i16.Mixin context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces == true) {
    buffer.writeln();
    buffer.write('''
  <dt>Implemented types</dt>
  <dd>
    <ul class="comma-separated ''');
    buffer.writeEscaped(context1.relationshipsClass);
    buffer.write('''">''');
    var context2 = context1.publicInterfaces;
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

String _renderMixin_partial_annotations_7(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String _renderMixin_partial_property_8(_i11.Field context2) =>
    _deduplicated_lib_templates_html__property_html(context2);
String _renderMixin_partial_instance_methods_9(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__instance_methods_html(context1);
String _renderMixin_partial_instance_operators_10(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__instance_operators_html(context1);
String _renderMixin_partial_static_properties_11(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__static_properties_html(context1);
String _renderMixin_partial_static_methods_12(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__static_methods_html(context1);
String _renderMixin_partial_static_constants_13(_i16.Mixin context1) =>
    _deduplicated_lib_templates_html__static_constants_html(context1);
String _renderMixin_partial_search_sidebar_14(_i1.MixinTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderMixin_partial_footer_15(_i1.MixinTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderProperty_partial_head_0(_i1.PropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderProperty_partial_source_link_1(_i11.Field context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderProperty_partial_feature_set_2(_i11.Field context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderProperty_partial_annotations_3(_i11.Field context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String _renderProperty_partial_name_summary_4(_i11.Field context1) =>
    _deduplicated_lib_templates_html__name_summary_html(context1);
String _renderProperty_partial_features_5(_i11.Field context1) =>
    _deduplicated_lib_templates_html__features_html(context1);
String _renderProperty_partial_documentation_6(_i11.Field context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderProperty_partial_source_code_7(_i11.Field context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderProperty_partial_accessor_getter_8(_i11.Field context1) =>
    _deduplicated_lib_templates_html__accessor_getter_html(context1);
String _renderProperty_partial_accessor_setter_9(_i11.Field context1) =>
    _deduplicated_lib_templates_html__accessor_setter_html(context1);
String _renderProperty_partial_search_sidebar_10(
        _i1.PropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderProperty_partial_footer_11(_i1.PropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderSearchPage_partial_head_0(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderSearchPage_partial_search_sidebar_1(
        _i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderSearchPage_partial_packages_2(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__packages_html(context0);
String _renderSearchPage_partial_footer_3(_i1.PackageTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderTopLevelProperty_partial_head_0(
        _i1.TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderTopLevelProperty_partial_source_link_1(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderTopLevelProperty_partial_feature_set_2(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderTopLevelProperty_partial_categorization_3(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderTopLevelProperty_partial_annotations_4(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__annotations_html(context1);
String _renderTopLevelProperty_partial_name_summary_5(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__name_summary_html(context1);
String _renderTopLevelProperty_partial_features_6(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__features_html(context1);
String _renderTopLevelProperty_partial_documentation_7(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderTopLevelProperty_partial_source_code_8(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderTopLevelProperty_partial_accessor_getter_9(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__accessor_getter_html(context1);
String _renderTopLevelProperty_partial_accessor_setter_10(
        _i7.TopLevelVariable context1) =>
    _deduplicated_lib_templates_html__accessor_setter_html(context1);
String _renderTopLevelProperty_partial_search_sidebar_11(
        _i1.TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderTopLevelProperty_partial_footer_12(
        _i1.TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _renderTypedef_partial_head_0(_i1.TypedefTemplateData context0) =>
    _deduplicated_lib_templates_html__head_html(context0);
String _renderTypedef_partial_source_link_1(_i9.Typedef context1) =>
    _deduplicated_lib_templates_html__source_link_html(context1);
String _renderTypedef_partial_feature_set_2(_i9.Typedef context1) =>
    _deduplicated_lib_templates_html__feature_set_html(context1);
String _renderTypedef_partial_categorization_3(_i9.Typedef context1) =>
    _deduplicated_lib_templates_html__categorization_html(context1);
String _renderTypedef_partial_typedef_multiline_4(_i9.Typedef context1) {
  final buffer = StringBuffer();
  if (context1.isCallable == true) {
    var context2 = context1.asCallable;
    if (context2.hasAnnotations == true) {
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
    if (context2.isConst == true) {
      buffer.write('''const ''');
    }
    buffer.write('''<span class="name ''');
    if (context2.isDeprecated == true) {
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
  if (context1.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(
        __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
            context1));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
    _i9.Typedef context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
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
            _i9.Typedef context1) =>
        _deduplicated_lib_templates_html__name_summary_html(context1);
String _renderTypedef_partial_documentation_5(_i9.Typedef context1) =>
    _deduplicated_lib_templates_html__documentation_html(context1);
String _renderTypedef_partial_source_code_6(_i9.Typedef context1) =>
    _deduplicated_lib_templates_html__source_code_html(context1);
String _renderTypedef_partial_search_sidebar_7(
        _i1.TypedefTemplateData context0) =>
    _deduplicated_lib_templates_html__search_sidebar_html(context0);
String _renderTypedef_partial_footer_8(_i1.TypedefTemplateData context0) =>
    _deduplicated_lib_templates_html__footer_html(context0);
String _deduplicated_lib_templates_html__head_html(
    _i1.TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
  <meta name="viewport" content="width=device-width, height=device-height, initial-scale=1, user-scalable=no">''');
  if (context0.includeVersion == true) {
    buffer.writeln();
    buffer.write('''
  <meta name="generator" content="made with love by dartdoc ''');
    buffer.writeEscaped(context0.version);
    buffer.write('''">''');
  }
  buffer.writeln();
  buffer.write('''
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
  if (context0.useBaseHref == true) {
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
  <link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Outlined:opsz,wght,FILL,GRAD@48,400,0,0" rel="stylesheet">
  ''');
  buffer.writeln();
  buffer.write('''
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/github.css?v1">
  <link rel="stylesheet" href="''');
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/styles.css?v1">
  <link rel="icon" href="''');
  if (context0.useBaseHref != true) {
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
    buffer.writeEscaped(context4.name);
    buffer.write('''</a></li>''');
  }
  var context5 = context0.navLinksWithGenerics;
  for (var context6 in context5) {
    buffer.writeln();
    buffer.write('''
    <li><a href="''');
    buffer.write(context6.href);
    buffer.write('''">''');
    buffer.writeEscaped(context6.name);
    if (context6.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context6.genericParameters);
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.writeln();
    buffer.write('''
    <li class="self-crumb">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
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
  <div class="toggle" id="theme-button">
    <label for="theme">
      <input type="checkbox" id="theme" value="light-theme">
      <span id="dark-theme-button" class="material-symbols-outlined">
        brightness_4
      </span>
      <span id="light-theme-button" class="material-symbols-outlined">
        brightness_5
      </span>
    </label>
  </div>
</header>
<main>''');

  return buffer.toString();
}

String _deduplicated_lib_templates_html__documentation_html(
    _i17.Warnable context0) {
  final buffer = StringBuffer();
  if (context0.hasDocumentation == true) {
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

String _deduplicated_lib_templates_html__library_html(_i5.Library context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
  <span class="name">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates_html__library_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>''');
  if (context0.isDocumented == true) {
    buffer.write(context0.oneLineDoc);
  }
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates_html__library_html_partial_categorization_0(
    _i5.Library context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__categorization_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__container_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
  <span class="name ''');
  if (context0.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write(context0.linkedGenericParameters);
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates_html__container_html_partial_categorization_0(
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

String
    __deduplicated_lib_templates_html__container_html_partial_categorization_0(
        _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__extension_html(
    _i2.Extension context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''">
    <span class="name ''');
  if (context0.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.write(context0.linkedName);
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates_html__extension_html_partial_categorization_0(
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

String
    __deduplicated_lib_templates_html__extension_html_partial_categorization_0(
        _i2.Extension context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__constant_html(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="constant">''');
  if (context0.isEnumValue == true) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context0.isDeprecated == true) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context0.name);
    buffer.write('''</span>''');
  }
  if (context0.isEnumValue != true) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context0.isDeprecated == true) {
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
      __deduplicated_lib_templates_html__constant_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      __deduplicated_lib_templates_html__constant_html_partial_features_1(
          context0));
  if (context0.hasConstantValueForDisplay == true) {
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

String
    __deduplicated_lib_templates_html__constant_html_partial_categorization_0(
        _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__constant_html_partial_features_1(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__features_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__property_html(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="property''');
  if (context0.isInherited == true) {
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
  buffer.write('''</span> ''');
  buffer.write(
      __deduplicated_lib_templates_html__property_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      __deduplicated_lib_templates_html__property_html_partial_features_1(
          context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__property_html_partial_categorization_0(
        _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__property_html_partial_features_1(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__typedef_html(_i9.Typedef context0) {
  final buffer = StringBuffer();
  if (context0.isCallable == true) {
    var context1 = context0.asCallable;
    buffer.writeln();
    buffer.write('''
  <dt id="''');
    buffer.writeEscaped(context1.htmlId);
    buffer.write('''" class="callable''');
    if (context1.isInherited == true) {
      buffer.write(''' inherited''');
    }
    buffer.write('''">
    <span class="name''');
    if (context1.isDeprecated == true) {
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
        __deduplicated_lib_templates_html__typedef_html_partial_categorization_0(
            context1));
    buffer.writeln();
    buffer.write('''
  </dt>
  <dd''');
    if (context1.isInherited == true) {
      buffer.write(''' class="inherited"''');
    }
    buffer.write('''>
    ''');
    buffer.write(context1.oneLineDoc);
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates_html__typedef_html_partial_features_1(
            context1));
    buffer.writeln();
    buffer.write('''
  </dd>''');
  }
  if (context0.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(__deduplicated_lib_templates_html__typedef_html_partial_type_2(
        context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__typedef_html_partial_categorization_0(
    _i9.FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.write('\n    ');
      buffer.write(context3.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__typedef_html_partial_features_1(
    _i9.FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__typedef_html_partial_type_2(
    _i9.Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="''');
  if (context0.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context0.isDeprecated == true) {
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
      ___deduplicated_lib_templates_html__typedef_html_partial_type_2_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__typedef_html_partial_type_2_partial_features_1(
          context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_html__typedef_html_partial_type_2_partial_categorization_0(
        _i9.Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__typedef_html_partial_type_2_partial_features_1(
        _i9.Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__type_html(_i9.Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context0.htmlId);
  buffer.write('''" class="''');
  if (context0.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context0.isDeprecated == true) {
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
      __deduplicated_lib_templates_html__type_html_partial_categorization_0(
          context0));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context0.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context0.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(__deduplicated_lib_templates_html__type_html_partial_features_1(
      context0));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String __deduplicated_lib_templates_html__type_html_partial_categorization_0(
    _i9.Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames == true) {
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_html__type_html_partial_features_1(
    _i9.Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context0.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__search_sidebar_html(
    _i1.TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''<header id="header-search-sidebar" class="hidden-l">
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
    if (context4.hasGenericParameters == true) {
      buffer.write('''<span class="signature">''');
      buffer.write(context4.genericParameters);
      buffer.write('''</span>''');
    }
    buffer.write('''</a></li>''');
  }
  if (context0.hasHomepage != true) {
    buffer.writeln();
    buffer.write('''
  <li class="self-crumb">''');
    buffer.write(context0.layoutTitle);
    buffer.write('''</li>''');
  }
  if (context0.hasHomepage == true) {
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

String _deduplicated_lib_templates_html__packages_html(
    _i1.TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''<ol>''');
  var context1 = context0.localPackages;
  for (var context2 in context1) {
    if (context2.isFirstPackage == true) {
      if (context2.hasDocumentedCategories == true) {
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
    if (context2.isFirstPackage != true) {
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
      var context10 = context9.publicLibrariesSorted;
      for (var context11 in context10) {
        buffer.writeln();
        buffer.write('''
        <li class="section-subitem">''');
        buffer.write(context11.linkedName);
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

String _deduplicated_lib_templates_html__footer_html(
    _i1.TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write('''</main>

<footer>
  <span class="no-break">
    ''');
  buffer.writeEscaped(context0.defaultPackage.name);
  if (context0.hasFooterVersion == true) {
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
  if (context0.useBaseHref != true) {
    buffer.write('''%%__HTMLBASE_dartdoc_internal__%%''');
  }
  buffer.write('''static-assets/highlight.pack.js?v1"></script>
<script src="''');
  if (context0.useBaseHref != true) {
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

String _deduplicated_lib_templates_html__source_link_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceHref == true) {
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

String _deduplicated_lib_templates_html__feature_set_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasFeatureSet == true) {
    var context1 = context0.displayedLanguageFeatures;
    for (var context2 in context1) {
      buffer.write('\n    ');
      buffer.write(context2.featureLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__super_chain_html(
    _i20.InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicSuperChainReversed == true) {
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

String _deduplicated_lib_templates_html__container_annotations_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasAnnotations == true) {
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

String _deduplicated_lib_templates_html__constructors_html(
    _i20.InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicConstructors == true) {
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
      if (context2.isConst == true) {
        buffer.writeln();
        buffer.write('''
            <div class="constructor-modifier features">const</div>''');
      }
      if (context2.isFactory == true) {
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

String _deduplicated_lib_templates_html__instance_methods_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceMethods == true) {
    buffer.writeln();
    buffer.write('''
  <section
      class="summary offset-anchor''');
    if (context0.publicInheritedInstanceMethods == true) {
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
          __deduplicated_lib_templates_html__instance_methods_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__instance_methods_html_partial_callable_0(
        _i15.Method context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated == true) {
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
      ___deduplicated_lib_templates_html__instance_methods_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__instance_methods_html_partial_callable_0_partial_features_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_html__instance_methods_html_partial_callable_0_partial_categorization_0(
        _i15.Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__instance_methods_html_partial_callable_0_partial_features_1(
        _i15.Method context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__instance_operators_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceOperators == true) {
    buffer.writeln();
    buffer.write('''
  <section
      class="summary offset-anchor''');
    if (context0.publicInheritedInstanceOperators == true) {
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
          __deduplicated_lib_templates_html__instance_operators_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__instance_operators_html_partial_callable_0(
        _i21.Operator context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated == true) {
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
      ___deduplicated_lib_templates_html__instance_operators_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__instance_operators_html_partial_callable_0_partial_features_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_html__instance_operators_html_partial_callable_0_partial_categorization_0(
        _i21.Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__instance_operators_html_partial_callable_0_partial_features_1(
        _i21.Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__static_properties_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicVariableStaticFields == true) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="static-properties">
    <h2>Static Properties</h2>

    <dl class="properties">''');
    var context1 = context0.publicVariableStaticFieldsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates_html__static_properties_html_partial_property_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__static_properties_html_partial_property_0(
        _i11.Field context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="property''');
  if (context1.isInherited == true) {
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
  buffer.write('''</span> ''');
  buffer.write(
      ___deduplicated_lib_templates_html__static_properties_html_partial_property_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__static_properties_html_partial_property_0_partial_features_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_html__static_properties_html_partial_property_0_partial_categorization_0(
        _i11.Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__static_properties_html_partial_property_0_partial_features_1(
        _i11.Field context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__static_methods_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicStaticMethods == true) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="static-methods">
    <h2>Static Methods</h2>
    <dl class="callables">''');
    var context1 = context0.publicStaticMethodsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates_html__static_methods_html_partial_callable_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__static_methods_html_partial_callable_0(
        _i15.Method context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="callable''');
  if (context1.isInherited == true) {
    buffer.write(''' inherited''');
  }
  buffer.write('''">
  <span class="name''');
  if (context1.isDeprecated == true) {
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
      ___deduplicated_lib_templates_html__static_methods_html_partial_callable_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd''');
  if (context1.isInherited == true) {
    buffer.write(''' class="inherited"''');
  }
  buffer.write('''>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__static_methods_html_partial_callable_0_partial_features_1(
          context1));
  buffer.writeln();
  buffer.write('''
</dd>
''');

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_html__static_methods_html_partial_callable_0_partial_categorization_0(
        _i15.Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__static_methods_html_partial_callable_0_partial_features_1(
        _i15.Method context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__static_constants_html(
    _i6.Container context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  if (context0.hasPublicConstantFields == true) {
    buffer.writeln();
    buffer.write('''
  <section class="summary offset-anchor" id="constants">
    <h2>Constants</h2>

    <dl class="properties">''');
    var context1 = context0.publicConstantFieldsSorted;
    for (var context2 in context1) {
      buffer.write('\n        ');
      buffer.write(
          __deduplicated_lib_templates_html__static_constants_html_partial_constant_0(
              context2));
    }
    buffer.writeln();
    buffer.write('''
    </dl>
  </section>''');
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__static_constants_html_partial_constant_0(
        _i11.Field context1) {
  final buffer = StringBuffer();
  buffer.write('''<dt id="''');
  buffer.writeEscaped(context1.htmlId);
  buffer.write('''" class="constant">''');
  if (context1.isEnumValue == true) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context1.isDeprecated == true) {
      buffer.write('''deprecated''');
    }
    buffer.write('''">''');
    buffer.write(context1.name);
    buffer.write('''</span>''');
  }
  if (context1.isEnumValue != true) {
    buffer.writeln();
    buffer.write('''
    <span class="name ''');
    if (context1.isDeprecated == true) {
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
      ___deduplicated_lib_templates_html__static_constants_html_partial_constant_0_partial_categorization_0(
          context1));
  buffer.writeln();
  buffer.write('''
</dt>
<dd>
  ''');
  buffer.write(context1.oneLineDoc);
  buffer.write('\n  ');
  buffer.write(
      ___deduplicated_lib_templates_html__static_constants_html_partial_constant_0_partial_features_1(
          context1));
  if (context1.hasConstantValueForDisplay == true) {
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
    ___deduplicated_lib_templates_html__static_constants_html_partial_constant_0_partial_categorization_0(
        _i11.Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
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
    ___deduplicated_lib_templates_html__static_constants_html_partial_constant_0_partial_features_1(
        _i11.Field context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_html__annotations_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasAnnotations == true) {
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

String _deduplicated_lib_templates_html__source_code_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceCode == true) {
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

String _deduplicated_lib_templates_html__name_summary_html(
    _i18.ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context0.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context0.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String _deduplicated_lib_templates_html__accessor_getter_html(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.getter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
<section id="getter">

<section class="multi-line-signature">
  ''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_getter_html_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write('''
  <span class="returntype">''');
    buffer.write(context1.modelType.returnType.linkedName);
    buffer.write('''</span>
  ''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_getter_html_partial_name_summary_1(
            context1));
    buffer.write('\n  ');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_getter_html_partial_features_2(
            context1));
    buffer.writeln();
    buffer.write('''
</section>

''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_getter_html_partial_documentation_3(
            context1));
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_html__accessor_getter_html_partial_source_code_4(
            context1));
    buffer.writeln();
    buffer.write('''
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_getter_html_partial_annotations_0(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
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
    __deduplicated_lib_templates_html__accessor_getter_html_partial_name_summary_1(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_getter_html_partial_features_2(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_getter_html_partial_documentation_3(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
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

String
    __deduplicated_lib_templates_html__accessor_getter_html_partial_source_code_4(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
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

String _deduplicated_lib_templates_html__accessor_setter_html(
    _i19.GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.setter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
<section id="setter">

<section class="multi-line-signature">
  ''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_setter_html_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write('''
  <span class="returntype">void</span>
  ''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_setter_html_partial_name_summary_1(
            context1));
    buffer.write('''<span class="signature">(<wbr>''');
    buffer.write(context1.linkedParamsNoMetadata);
    buffer.write(''')</span>
  ''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_setter_html_partial_features_2(
            context1));
    buffer.writeln();
    buffer.write('''
</section>

''');
    buffer.write(
        __deduplicated_lib_templates_html__accessor_setter_html_partial_documentation_3(
            context1));
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_html__accessor_setter_html_partial_source_code_4(
            context1));
    buffer.writeln();
    buffer.write('''
</section>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_setter_html_partial_annotations_0(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
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
    __deduplicated_lib_templates_html__accessor_setter_html_partial_name_summary_1(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  buffer.write('''<span class="name ''');
  if (context1.isDeprecated == true) {
    buffer.write('''deprecated''');
  }
  buffer.write('''">''');
  buffer.writeEscaped(context1.name);
  buffer.write('''</span>''');

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_setter_html_partial_features_2(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''<div class="features">''');
    buffer.write(context1.featuresAsString);
    buffer.write('''</div>''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_html__accessor_setter_html_partial_documentation_3(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
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

String
    __deduplicated_lib_templates_html__accessor_setter_html_partial_source_code_4(
        _i22.Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
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
    write(_i23.htmlEscape.convert(value ?? ''));
  }
}
