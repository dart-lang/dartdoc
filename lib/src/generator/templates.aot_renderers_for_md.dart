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
import 'package:dartdoc/src/model/category.dart';
import 'package:dartdoc/src/model/class.dart';
import 'package:dartdoc/src/model/constructor.dart';
import 'package:dartdoc/src/model/container.dart';
import 'package:dartdoc/src/model/enum.dart';
import 'package:dartdoc/src/model/extension.dart';
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
import 'package:dartdoc/src/warnings.dart';

String renderCategory(CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderCategory_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.writeEscaped(context1.name);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderCategory_partial_documentation_1(context1));
  buffer.writeln();
  if (context1.hasPublicLibraries) {
    buffer.writeln();
    buffer.write('''
## Libraries
''');
    var context2 = context1.publicLibrariesSorted;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_library_2(context3));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
## Classes
''');
    var context4 = context1.publicClassesSorted;
    for (var context5 in context4) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_container_3(context5));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
## Mixins
''');
    var context6 = context1.publicMixinsSorted;
    for (var context7 in context6) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_container_3(context7));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
## Extensions
''');
    var context8 = context1.publicExtensionsSorted;
    for (var context9 in context8) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_extension_4(context9));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
## Constants
''');
    var context10 = context1.publicConstantsSorted;
    for (var context11 in context10) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_constant_5(context11));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context12 = context1.publicPropertiesSorted;
    for (var context13 in context12) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_property_6(context13));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
## Functions
''');
    var context14 = context1.publicFunctionsSorted;
    for (var context15 in context14) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_callable_7(context15));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
## Enums
''');
    var context16 = context1.publicEnumsSorted;
    for (var context17 in context16) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_container_3(context17));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
## Typedefs
''');
    var context18 = context1.publicTypedefsSorted;
    for (var context19 in context18) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_typedef_8(context19));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context1.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
## Exceptions / Errors
''');
    var context20 = context1.publicExceptionsSorted;
    for (var context21 in context20) {
      buffer.writeln();
      buffer.write(_renderCategory_partial_container_3(context21));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderCategory_partial_footer_9(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderClass(ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderClass_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderClass_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderClass_partial_feature_set_3(context1));
  buffer.writeln();
  var context2 = context0.clazz;
  buffer.writeln();
  buffer.write(_renderClass_partial_documentation_4(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    buffer.writeln();
    buffer.write(_renderClass_partial_super_chain_5(context2));
    buffer.writeln();
    buffer.write(_renderClass_partial_interfaces_6(context2));
    buffer.writeln();
    buffer.write(_renderClass_partial_mixed_in_types_7(context2));
    buffer.writeln();
    if (context2.hasPublicImplementors) {
      buffer.writeln();
      buffer.write('''
**Implementers**
''');
      var context3 = context2.publicImplementorsSorted;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context4.linkedName);
      }
    }
    buffer.writeln();
    if (context2.hasPotentiallyApplicableExtensions) {
      buffer.writeln();
      buffer.write('''
**Available Extensions**
''');
      var context5 = context2.potentiallyApplicableExtensionsSorted;
      for (var context6 in context5) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context6.linkedName);
      }
    }
    buffer.write('\n\n');
    buffer.write(_renderClass_partial_annotations_8(context2));
  }
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_constructors_9(context2));
  buffer.writeln();
  if (context2.hasPublicInstanceFields) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context7 = context2.publicInstanceFieldsSorted;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write(_renderClass_partial_property_10(context8));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_instance_methods_11(context2));
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_instance_operators_12(context2));
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_static_properties_13(context2));
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_static_methods_14(context2));
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_static_constants_15(context2));
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_footer_16(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderConstructor(ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderConstructor_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderConstructor_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderConstructor_partial_feature_set_2(context1));
  buffer.writeln();
  var context2 = context0.constructor;
  if (context2.hasAnnotations) {
    var context3 = context2.annotations;
    for (var context4 in context3) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context4.linkedNameWithParameters);
    }
  }
  buffer.writeln();
  if (context2.isConst) {
    buffer.write('''const''');
  }
  buffer.writeln();
  buffer.write(context2.nameWithGenerics);
  buffer.write('''(''');
  if (context2.hasParameters) {
    buffer.write(context2.linkedParamsLines);
  }
  buffer.write(''')

''');
  buffer.write(_renderConstructor_partial_documentation_3(context2));
  buffer.write('\n\n');
  buffer.write(_renderConstructor_partial_source_code_4(context2));
  buffer.writeln();
  buffer.write('\n\n');
  buffer.write(_renderConstructor_partial_footer_5(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderEnum(EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderEnum_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderEnum_partial_feature_set_2(context1));
  buffer.writeln();
  var context2 = context0.eNum;
  buffer.writeln();
  buffer.write(_renderEnum_partial_documentation_3(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    buffer.writeln();
    buffer.write(_renderEnum_partial_super_chain_4(context2));
    buffer.writeln();
    buffer.write(_renderEnum_partial_interfaces_5(context2));
    buffer.writeln();
    buffer.write(_renderEnum_partial_mixed_in_types_6(context2));
    buffer.write('\n\n');
    buffer.write(_renderEnum_partial_annotations_7(context2));
  }
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_constructors_8(context2));
  buffer.writeln();
  if (context2.hasPublicEnumValues) {
    buffer.writeln();
    buffer.write('''
## Values
''');
    var context3 = context2.publicEnumValues;
    for (var context4 in context3) {
      buffer.writeln();
      buffer.write(_renderEnum_partial_constant_9(context4));
      buffer.writeln();
    }
  }
  buffer.writeln();
  if (context2.hasPublicInstanceFields) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context5 = context2.publicInstanceFieldsSorted;
    for (var context6 in context5) {
      buffer.writeln();
      buffer.write(_renderEnum_partial_property_10(context6));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_instance_methods_11(context2));
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_instance_operators_12(context2));
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_static_properties_13(context2));
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_static_methods_14(context2));
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_static_constants_15(context2));
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_footer_16(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderError() {
  final buffer = StringBuffer();
  buffer.write('''# 404

Oops, something\'s gone wrong :-(

You\'ve tried to visit a page that doesn\'t exist. Luckily this site has other
[pages](index.md).
''');

  return buffer.toString();
}

String renderExtension<T extends Extension>(ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtension_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.writeln();
  buffer.write('''
on ''');
  var context2 = context1.extendedType;
  buffer.write(context2.linkedName);
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_source_link_1(context1));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderExtension_partial_feature_set_3(context1));
  buffer.writeln();
  var context3 = context0.extension;
  buffer.writeln();
  buffer.write(_renderExtension_partial_documentation_4(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_annotations_5(context3));
  buffer.writeln();
  if (context3.hasPublicInstanceFields) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context4 = context3.publicInstanceFieldsSorted;
    for (var context5 in context4) {
      buffer.writeln();
      buffer.write(_renderExtension_partial_property_6(context5));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_instance_methods_7(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_instance_operators_8(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_static_properties_9(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_static_methods_10(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_static_constants_11(context3));
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_footer_12(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderFunction(FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFunction_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderFunction_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderFunction_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderFunction_partial_feature_set_3(context1));
  buffer.writeln();
  var context2 = context0.function;
  buffer.writeln();
  buffer.write(_renderFunction_partial_callable_multiline_4(context2));
  buffer.writeln();
  buffer.write(_renderFunction_partial_attributes_5(context2));
  buffer.write('\n\n');
  buffer.write(_renderFunction_partial_documentation_6(context2));
  buffer.write('\n\n');
  buffer.write(_renderFunction_partial_source_code_7(context2));
  buffer.writeln();
  buffer.write('\n\n');
  buffer.write(_renderFunction_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderIndex(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderIndex_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

# ''');
  buffer.writeEscaped(context0.title);
  buffer.writeln();
  var context1 = context0.defaultPackage;
  buffer.writeln();
  buffer.write(_renderIndex_partial_documentation_1(context1));
  buffer.writeln();
  var context2 = context0.localPackages;
  for (var context3 in context2) {
    if (context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
## Libraries''');
    }
    if (!context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
## ''');
      buffer.writeEscaped(context3.name);
    }
    buffer.writeln();
    var context4 = context3.defaultCategory;
    var context5 = context4.publicLibrariesSorted;
    for (var context6 in context5) {
      buffer.writeln();
      buffer.write(_renderIndex_partial_library_2(context6));
    }
    buffer.writeln();
    var context7 = context3.categoriesWithPublicLibraries;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write('''
### Category ''');
      buffer.write(context8.categoryLabel);
      buffer.writeln();
      var context9 = context8.publicLibrariesSorted;
      for (var context10 in context9) {
        buffer.writeln();
        buffer.write(_renderIndex_partial_library_2(context10));
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderIndex_partial_footer_3(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderLibrary(LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderLibrary_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.name);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderLibrary_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderLibrary_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderLibrary_partial_feature_set_3(context1));
  buffer.writeln();
  var context2 = context0.library;
  buffer.writeln();
  buffer.write(_renderLibrary_partial_documentation_4(context2));
  buffer.writeln();
  var context3 = context0.library;
  if (context3.hasPublicClasses) {
    buffer.writeln();
    buffer.write('''
## Classes
''');
    var context4 = context3.library;
    var context5 = context4.publicClassesSorted;
    for (var context6 in context5) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_container_5(context6));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context7 = context0.library;
  if (context7.hasPublicMixins) {
    buffer.writeln();
    buffer.write('''
## Mixins
''');
    var context8 = context7.library;
    var context9 = context8.publicMixinsSorted;
    for (var context10 in context9) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_container_5(context10));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context11 = context0.library;
  if (context11.hasPublicExtensions) {
    buffer.writeln();
    buffer.write('''
## Extensions
''');
    var context12 = context11.library;
    var context13 = context12.publicExtensionsSorted;
    for (var context14 in context13) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_extension_6(context14));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context15 = context0.library;
  if (context15.hasPublicConstants) {
    buffer.writeln();
    buffer.write('''
## Constants
''');
    var context16 = context15.library;
    var context17 = context16.publicConstantsSorted;
    for (var context18 in context17) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_constant_7(context18));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context19 = context0.library;
  if (context19.hasPublicProperties) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context20 = context19.library;
    var context21 = context20.publicPropertiesSorted;
    for (var context22 in context21) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_property_8(context22));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context23 = context0.library;
  if (context23.hasPublicFunctions) {
    buffer.writeln();
    buffer.write('''
## Functions
''');
    var context24 = context23.library;
    var context25 = context24.publicFunctionsSorted;
    for (var context26 in context25) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_callable_9(context26));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context27 = context0.library;
  if (context27.hasPublicEnums) {
    buffer.writeln();
    buffer.write('''
## Enums
''');
    var context28 = context27.library;
    var context29 = context28.publicEnumsSorted;
    for (var context30 in context29) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_container_5(context30));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context31 = context0.library;
  if (context31.hasPublicTypedefs) {
    buffer.writeln();
    buffer.write('''
## Typedefs
''');
    var context32 = context31.library;
    var context33 = context32.publicTypedefsSorted;
    for (var context34 in context33) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_typedef_10(context34));
      buffer.writeln();
    }
  }
  buffer.writeln();
  var context35 = context0.library;
  if (context35.hasPublicExceptions) {
    buffer.writeln();
    buffer.write('''
## Exceptions / Errors
''');
    var context36 = context35.library;
    var context37 = context36.publicExceptionsSorted;
    for (var context38 in context37) {
      buffer.writeln();
      buffer.write(_renderLibrary_partial_container_5(context38));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderLibrary_partial_footer_11(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMethod(MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMethod_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderMethod_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderMethod_partial_feature_set_2(context1));
  buffer.writeln();
  var context2 = context0.method;
  buffer.writeln();
  buffer.write(_renderMethod_partial_callable_multiline_3(context2));
  buffer.writeln();
  buffer.write(_renderMethod_partial_attributes_4(context2));
  buffer.write('\n\n');
  buffer.write(_renderMethod_partial_documentation_5(context2));
  buffer.write('\n\n');
  buffer.write(_renderMethod_partial_source_code_6(context2));
  buffer.writeln();
  buffer.write('\n\n');
  buffer.write(_renderMethod_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderMixin(MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMixin_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderMixin_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderMixin_partial_feature_set_3(context1));
  buffer.writeln();
  var context2 = context0.mixin;
  buffer.writeln();
  buffer.write(_renderMixin_partial_documentation_4(context2));
  buffer.writeln();
  if (context2.hasModifiers) {
    if (context2.hasPublicSuperclassConstraints) {
      buffer.writeln();
      buffer.write('''
**Superclass Constraints**
''');
      var context3 = context2.publicSuperclassConstraints;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context4.linkedName);
      }
    }
    buffer.write('\n\n');
    buffer.write(_renderMixin_partial_super_chain_5(context2));
    buffer.writeln();
    buffer.write(_renderMixin_partial_interfaces_6(context2));
    buffer.writeln();
    if (context2.hasPublicImplementors) {
      buffer.writeln();
      buffer.write('''
**Mixin Applications**
''');
      var context5 = context2.publicImplementorsSorted;
      for (var context6 in context5) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context6.linkedName);
      }
    }
    buffer.write('\n\n');
    buffer.write(_renderMixin_partial_annotations_7(context2));
  }
  buffer.writeln();
  if (context2.hasPublicInstanceFields) {
    buffer.writeln();
    buffer.write('''
## Properties
''');
    var context7 = context2.publicInstanceFieldsSorted;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write(_renderMixin_partial_property_8(context8));
      buffer.writeln();
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_instance_methods_9(context2));
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_instance_operators_10(context2));
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_static_properties_11(context2));
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_static_methods_12(context2));
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_static_constants_13(context2));
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_footer_14(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderProperty(PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderProperty_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.writeEscaped(context1.name);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderProperty_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderProperty_partial_feature_set_2(context1));
  buffer.writeln();
  var context2 = context0.self;
  if (context2.hasNoGetterSetter) {
    buffer.writeln();
    buffer.write(_renderProperty_partial_annotations_3(context2));
    buffer.writeln();
    buffer.write(context2.modelType.linkedName);
    buffer.write(' ');
    buffer.write(_renderProperty_partial_name_summary_4(context2));
    buffer.write('  ');
    buffer.writeln();
    buffer.write(_renderProperty_partial_attributes_5(context2));
    buffer.write('\n\n');
    buffer.write(_renderProperty_partial_documentation_6(context2));
    buffer.write('\n\n');
    buffer.write(_renderProperty_partial_source_code_7(context2));
  }
  buffer.writeln();
  if (context2.hasGetterOrSetter) {
    if (context2.hasGetter) {
      buffer.writeln();
      buffer.write(_renderProperty_partial_accessor_getter_8(context2));
    }
    buffer.writeln();
    if (context2.hasSetter) {
      buffer.writeln();
      buffer.write(_renderProperty_partial_accessor_setter_9(context2));
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderProperty_partial_footer_10(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderSearchPage(PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderSearchPage_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

# ''');
  buffer.writeEscaped(context0.title);
  buffer.writeln();
  var context1 = context0.defaultPackage;
  buffer.writeln();
  buffer.write(_renderSearchPage_partial_documentation_1(context1));
  buffer.writeln();
  var context2 = context0.localPackages;
  for (var context3 in context2) {
    if (context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
## Libraries''');
    }
    if (!context3.isFirstPackage) {
      buffer.writeln();
      buffer.write('''
## ''');
      buffer.writeEscaped(context3.name);
    }
    buffer.writeln();
    var context4 = context3.defaultCategory;
    var context5 = context4.publicLibrariesSorted;
    for (var context6 in context5) {
      buffer.writeln();
      buffer.write(_renderSearchPage_partial_library_2(context6));
    }
    buffer.writeln();
    var context7 = context3.categoriesWithPublicLibraries;
    for (var context8 in context7) {
      buffer.writeln();
      buffer.write('''
### Category ''');
      buffer.write(context8.categoryLabel);
      buffer.writeln();
      var context9 = context8.publicLibrariesSorted;
      for (var context10 in context9) {
        buffer.writeln();
        buffer.write(_renderSearchPage_partial_library_2(context10));
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderSearchPage_partial_footer_3(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderSidebarForContainer() {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderSidebarForLibrary() {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderTopLevelProperty(TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTopLevelProperty_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.name);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderTopLevelProperty_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderTopLevelProperty_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderTopLevelProperty_partial_feature_set_3(context1));
  buffer.writeln();
  if (context1.hasNoGetterSetter) {
    buffer.writeln();
    buffer.write(_renderTopLevelProperty_partial_annotations_4(context1));
    buffer.writeln();
    buffer.write(context1.modelType.linkedName);
    buffer.write(' ');
    buffer.write(_renderTopLevelProperty_partial_name_summary_5(context1));
    buffer.write('  ');
    buffer.writeln();
    buffer.write(_renderTopLevelProperty_partial_attributes_6(context1));
    buffer.write('\n\n');
    buffer.write(_renderTopLevelProperty_partial_documentation_7(context1));
    buffer.write('\n\n');
    buffer.write(_renderTopLevelProperty_partial_source_code_8(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitGetter) {
    buffer.writeln();
    buffer.write(_renderTopLevelProperty_partial_accessor_getter_9(context1));
  }
  buffer.writeln();
  if (context1.hasExplicitSetter) {
    buffer.writeln();
    buffer.write(_renderTopLevelProperty_partial_accessor_setter_10(context1));
  }
  buffer.write('\n\n');
  buffer.write(_renderTopLevelProperty_partial_footer_11(context0));
  buffer.writeln();

  return buffer.toString();
}

String renderTypedef(TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTypedef_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  buffer.writeln();
  buffer.write('''
# ''');
  buffer.write(context1.nameWithGenerics);
  buffer.write(' ');
  buffer.writeEscaped(context1.kind.toString());
  buffer.write('\n\n');
  buffer.write(_renderTypedef_partial_source_link_1(context1));
  buffer.writeln();
  buffer.write(_renderTypedef_partial_categorization_2(context1));
  buffer.writeln();
  buffer.write(_renderTypedef_partial_feature_set_3(context1));
  buffer.writeln();
  var context2 = context0.typeDef;
  buffer.writeln();
  buffer.write(_renderTypedef_partial_typedef_multiline_4(context2));
  buffer.write('\n\n');
  buffer.write(_renderTypedef_partial_documentation_5(context2));
  buffer.write('\n\n');
  buffer.write(_renderTypedef_partial_source_code_6(context2));
  buffer.write('\n\n');
  buffer.write(_renderTypedef_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_head_0(CategoryTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderCategory_partial_documentation_1(Category context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderCategory_partial_library_2(Library context2) =>
    _deduplicated_lib_templates_md__library_md(context2);

String _renderCategory_partial_container_3(Container context2) =>
    _deduplicated_lib_templates_md__container_md(context2);

String _renderCategory_partial_extension_4(Extension context2) =>
    _deduplicated_lib_templates_md__extension_md(context2);

String _renderCategory_partial_constant_5(TopLevelVariable context2) =>
    _deduplicated_lib_templates_md__constant_md(context2);

String _renderCategory_partial_property_6(TopLevelVariable context2) =>
    _deduplicated_lib_templates_md__property_md(context2);

String _renderCategory_partial_callable_7(ModelFunctionTyped context2) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName);
  buffer.write(context2.linkedGenericParameters);
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata);
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName);
  buffer.writeln();
  buffer.write(
      __renderCategory_partial_callable_7_partial_categorization_0(context2));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      __renderCategory_partial_callable_7_partial_attributes_1(context2));
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_callable_7_partial_categorization_0(
        ModelFunctionTyped context2) =>
    _deduplicated_lib_templates_md__categorization_md(context2);

String __renderCategory_partial_callable_7_partial_attributes_1(
        ModelFunctionTyped context2) =>
    _deduplicated_lib_templates_md__attributes_md(context2);

String _renderCategory_partial_typedef_8(Typedef context2) =>
    _deduplicated_lib_templates_md__typedef_md(context2);

String _renderCategory_partial_footer_9(CategoryTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderClass_partial_head_0(ClassTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderClass_partial_source_link_1(Class context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderClass_partial_categorization_2(Class context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderClass_partial_feature_set_3(Class context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderClass_partial_documentation_4(Class context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderClass_partial_super_chain_5(Class context1) =>
    _deduplicated_lib_templates_md__super_chain_md(context1);

String _renderClass_partial_interfaces_6(Class context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces) {
    buffer.writeln();
    buffer.write('''
**Implemented types**
''');
    var context2 = context1.publicInterfaces;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedName);
    }
  }

  return buffer.toString();
}

String _renderClass_partial_mixed_in_types_7(Class context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes) {
    buffer.writeln();
    buffer.write('''
**Mixed in types**
''');
    var context2 = context1.publicMixedInTypes;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedName);
    }
  }

  return buffer.toString();
}

String _renderClass_partial_annotations_8(Class context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderClass_partial_constructors_9(Class context1) =>
    _deduplicated_lib_templates_md__constructors_md(context1);

String _renderClass_partial_property_10(Field context2) =>
    _deduplicated_lib_templates_md__property_md(context2);

String _renderClass_partial_instance_methods_11(Class context1) =>
    _deduplicated_lib_templates_md__instance_methods_md(context1);

String _renderClass_partial_instance_operators_12(Class context1) =>
    _deduplicated_lib_templates_md__instance_operators_md(context1);

String _renderClass_partial_static_properties_13(Class context1) =>
    _deduplicated_lib_templates_md__static_properties_md(context1);

String _renderClass_partial_static_methods_14(Class context1) =>
    _deduplicated_lib_templates_md__static_methods_md(context1);

String _renderClass_partial_static_constants_15(Class context1) =>
    _deduplicated_lib_templates_md__static_constants_md(context1);

String _renderClass_partial_footer_16(ClassTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderConstructor_partial_head_0(ConstructorTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderConstructor_partial_source_link_1(Constructor context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderConstructor_partial_feature_set_2(Constructor context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderConstructor_partial_documentation_3(Constructor context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderConstructor_partial_source_code_4(Constructor context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderConstructor_partial_footer_5(ConstructorTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderEnum_partial_head_0(EnumTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderEnum_partial_source_link_1(Enum context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderEnum_partial_feature_set_2(Enum context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderEnum_partial_documentation_3(Enum context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderEnum_partial_super_chain_4(Enum context1) =>
    _deduplicated_lib_templates_md__super_chain_md(context1);

String _renderEnum_partial_interfaces_5(Enum context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces) {
    buffer.writeln();
    buffer.write('''
**Implemented types**
''');
    var context2 = context1.publicInterfaces;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedName);
    }
  }

  return buffer.toString();
}

String _renderEnum_partial_mixed_in_types_6(Enum context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicMixedInTypes) {
    buffer.writeln();
    buffer.write('''
**Mixed in types**
''');
    var context2 = context1.publicMixedInTypes;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedName);
    }
  }

  return buffer.toString();
}

String _renderEnum_partial_annotations_7(Enum context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderEnum_partial_constructors_8(Enum context1) =>
    _deduplicated_lib_templates_md__constructors_md(context1);

String _renderEnum_partial_constant_9(Field context2) =>
    _deduplicated_lib_templates_md__constant_md(context2);

String _renderEnum_partial_property_10(Field context2) =>
    _deduplicated_lib_templates_md__property_md(context2);

String _renderEnum_partial_instance_methods_11(Enum context1) =>
    _deduplicated_lib_templates_md__instance_methods_md(context1);

String _renderEnum_partial_instance_operators_12(Enum context1) =>
    _deduplicated_lib_templates_md__instance_operators_md(context1);

String _renderEnum_partial_static_properties_13(Enum context1) =>
    _deduplicated_lib_templates_md__static_properties_md(context1);

String _renderEnum_partial_static_methods_14(Enum context1) =>
    _deduplicated_lib_templates_md__static_methods_md(context1);

String _renderEnum_partial_static_constants_15(Enum context1) =>
    _deduplicated_lib_templates_md__static_constants_md(context1);

String _renderEnum_partial_footer_16(EnumTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderExtension_partial_head_0<T extends Extension>(
        ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderExtension_partial_source_link_1(Extension context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderExtension_partial_categorization_2(Extension context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderExtension_partial_feature_set_3(Extension context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderExtension_partial_documentation_4(Extension context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderExtension_partial_annotations_5(Extension context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderExtension_partial_property_6(Field context2) =>
    _deduplicated_lib_templates_md__property_md(context2);

String _renderExtension_partial_instance_methods_7(Extension context1) =>
    _deduplicated_lib_templates_md__instance_methods_md(context1);

String _renderExtension_partial_instance_operators_8(Extension context1) =>
    _deduplicated_lib_templates_md__instance_operators_md(context1);

String _renderExtension_partial_static_properties_9(Extension context1) =>
    _deduplicated_lib_templates_md__static_properties_md(context1);

String _renderExtension_partial_static_methods_10(Extension context1) =>
    _deduplicated_lib_templates_md__static_methods_md(context1);

String _renderExtension_partial_static_constants_11(Extension context1) =>
    _deduplicated_lib_templates_md__static_constants_md(context1);

String _renderExtension_partial_footer_12<T extends Extension>(
        ExtensionTemplateData<T> context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderFunction_partial_head_0(FunctionTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderFunction_partial_source_link_1(ModelFunction context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderFunction_partial_categorization_2(ModelFunction context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderFunction_partial_feature_set_3(ModelFunction context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderFunction_partial_callable_multiline_4(ModelFunction context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedNameWithParameters);
    }
  }
  buffer.write('\n\n');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write(' ');
  buffer.write(
      __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write('''(''');
  if (context1.hasParameters) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
        ModelFunction context1) =>
    _deduplicated_lib_templates_md__name_summary_md(context1);

String _renderFunction_partial_attributes_5(ModelFunction context1) =>
    _deduplicated_lib_templates_md__attributes_md(context1);

String _renderFunction_partial_documentation_6(ModelFunction context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderFunction_partial_source_code_7(ModelFunction context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderFunction_partial_footer_8(FunctionTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderIndex_partial_head_0(PackageTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderIndex_partial_documentation_1(Package context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderIndex_partial_library_2(Library context3) =>
    _deduplicated_lib_templates_md__library_md(context3);

String _renderIndex_partial_footer_3(PackageTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderLibrary_partial_head_0(LibraryTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderLibrary_partial_source_link_1(Library context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderLibrary_partial_categorization_2(Library context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderLibrary_partial_feature_set_3(Library context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderLibrary_partial_documentation_4(Library context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderLibrary_partial_container_5(Container context3) =>
    _deduplicated_lib_templates_md__container_md(context3);

String _renderLibrary_partial_extension_6(Extension context3) =>
    _deduplicated_lib_templates_md__extension_md(context3);

String _renderLibrary_partial_constant_7(TopLevelVariable context3) =>
    _deduplicated_lib_templates_md__constant_md(context3);

String _renderLibrary_partial_property_8(TopLevelVariable context3) =>
    _deduplicated_lib_templates_md__property_md(context3);

String _renderLibrary_partial_callable_9(ModelFunctionTyped context3) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName);
  buffer.write(context3.linkedGenericParameters);
  buffer.write('''(''');
  buffer.write(context3.linkedParamsNoMetadata);
  buffer.write(''') ''');
  buffer.write(context3.modelType.returnType.linkedName);
  buffer.writeln();
  buffer.write(
      __renderLibrary_partial_callable_9_partial_categorization_0(context3));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer
      .write(__renderLibrary_partial_callable_9_partial_attributes_1(context3));
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_callable_9_partial_categorization_0(
        ModelFunctionTyped context3) =>
    _deduplicated_lib_templates_md__categorization_md(context3);

String __renderLibrary_partial_callable_9_partial_attributes_1(
        ModelFunctionTyped context3) =>
    _deduplicated_lib_templates_md__attributes_md(context3);

String _renderLibrary_partial_typedef_10(Typedef context3) =>
    _deduplicated_lib_templates_md__typedef_md(context3);

String _renderLibrary_partial_footer_11(LibraryTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderMethod_partial_head_0(MethodTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderMethod_partial_source_link_1(Method context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderMethod_partial_feature_set_2(Method context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderMethod_partial_callable_multiline_3(Method context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedNameWithParameters);
    }
  }
  buffer.write('\n\n');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.write(' ');
  buffer.write(
      __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write('''(''');
  if (context1.hasParameters) {
    buffer.write(context1.linkedParamsLines);
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
        Method context1) =>
    _deduplicated_lib_templates_md__name_summary_md(context1);

String _renderMethod_partial_attributes_4(Method context1) =>
    _deduplicated_lib_templates_md__attributes_md(context1);

String _renderMethod_partial_documentation_5(Method context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderMethod_partial_source_code_6(Method context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderMethod_partial_footer_7(MethodTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderMixin_partial_head_0(MixinTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderMixin_partial_source_link_1(Mixin context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderMixin_partial_categorization_2(Mixin context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderMixin_partial_feature_set_3(Mixin context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderMixin_partial_documentation_4(Mixin context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderMixin_partial_super_chain_5(Mixin context1) =>
    _deduplicated_lib_templates_md__super_chain_md(context1);

String _renderMixin_partial_interfaces_6(Mixin context1) {
  final buffer = StringBuffer();
  if (context1.hasPublicInterfaces) {
    buffer.writeln();
    buffer.write('''
**Implemented types**
''');
    var context2 = context1.publicInterfaces;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedName);
    }
  }

  return buffer.toString();
}

String _renderMixin_partial_annotations_7(Mixin context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderMixin_partial_property_8(Field context2) =>
    _deduplicated_lib_templates_md__property_md(context2);

String _renderMixin_partial_instance_methods_9(Mixin context1) =>
    _deduplicated_lib_templates_md__instance_methods_md(context1);

String _renderMixin_partial_instance_operators_10(Mixin context1) =>
    _deduplicated_lib_templates_md__instance_operators_md(context1);

String _renderMixin_partial_static_properties_11(Mixin context1) =>
    _deduplicated_lib_templates_md__static_properties_md(context1);

String _renderMixin_partial_static_methods_12(Mixin context1) =>
    _deduplicated_lib_templates_md__static_methods_md(context1);

String _renderMixin_partial_static_constants_13(Mixin context1) =>
    _deduplicated_lib_templates_md__static_constants_md(context1);

String _renderMixin_partial_footer_14(MixinTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderProperty_partial_head_0(PropertyTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderProperty_partial_source_link_1(Field context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderProperty_partial_feature_set_2(Field context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderProperty_partial_annotations_3(Field context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderProperty_partial_name_summary_4(Field context1) =>
    _deduplicated_lib_templates_md__name_summary_md(context1);

String _renderProperty_partial_attributes_5(Field context1) =>
    _deduplicated_lib_templates_md__attributes_md(context1);

String _renderProperty_partial_documentation_6(Field context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderProperty_partial_source_code_7(Field context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderProperty_partial_accessor_getter_8(Field context1) =>
    _deduplicated_lib_templates_md__accessor_getter_md(context1);

String _renderProperty_partial_accessor_setter_9(Field context1) =>
    _deduplicated_lib_templates_md__accessor_setter_md(context1);

String _renderProperty_partial_footer_10(PropertyTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderSearchPage_partial_head_0(PackageTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderSearchPage_partial_documentation_1(Package context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderSearchPage_partial_library_2(Library context3) =>
    _deduplicated_lib_templates_md__library_md(context3);

String _renderSearchPage_partial_footer_3(PackageTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderTopLevelProperty_partial_head_0(
        TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderTopLevelProperty_partial_source_link_1(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderTopLevelProperty_partial_categorization_2(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderTopLevelProperty_partial_feature_set_3(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderTopLevelProperty_partial_annotations_4(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__annotations_md(context1);

String _renderTopLevelProperty_partial_name_summary_5(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__name_summary_md(context1);

String _renderTopLevelProperty_partial_attributes_6(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__attributes_md(context1);

String _renderTopLevelProperty_partial_documentation_7(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderTopLevelProperty_partial_source_code_8(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderTopLevelProperty_partial_accessor_getter_9(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__accessor_getter_md(context1);

String _renderTopLevelProperty_partial_accessor_setter_10(
        TopLevelVariable context1) =>
    _deduplicated_lib_templates_md__accessor_setter_md(context1);

String _renderTopLevelProperty_partial_footer_11(
        TopLevelPropertyTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _renderTypedef_partial_head_0(TypedefTemplateData context0) =>
    _deduplicated_lib_templates_md__head_md(context0);

String _renderTypedef_partial_source_link_1(Typedef context1) =>
    _deduplicated_lib_templates_md__source_link_md(context1);

String _renderTypedef_partial_categorization_2(Typedef context1) =>
    _deduplicated_lib_templates_md__categorization_md(context1);

String _renderTypedef_partial_feature_set_3(Typedef context1) =>
    _deduplicated_lib_templates_md__feature_set_md(context1);

String _renderTypedef_partial_typedef_multiline_4(Typedef context1) {
  final buffer = StringBuffer();
  if (context1.isCallable) {
    var context2 = context1.asCallable;
    if (context2.hasAnnotations) {
      var context3 = context2.annotations;
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write('''
    - ''');
        buffer.write(context4.linkedNameWithParameters);
      }
    }
    buffer.write('\n\n    ');
    buffer.write(context2.modelType.returnType.linkedName);
    buffer.write(' ');
    buffer.writeEscaped(context2.name);
    buffer.write(context2.linkedGenericParameters);
    buffer.write(''' = ''');
    buffer.write(context2.modelType.linkedName);
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
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedNameWithParameters);
    }
  }
  buffer.write('\n\n');
  buffer.write(
      ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
          context1));
  buffer.write(context1.genericParameters);
  buffer.write(''' = ''');
  buffer.write(context1.modelType.linkedName);
  buffer.writeln();

  return buffer.toString();
}

String
    ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
            Typedef context1) =>
        _deduplicated_lib_templates_md__name_summary_md(context1);

String _renderTypedef_partial_documentation_5(Typedef context1) =>
    _deduplicated_lib_templates_md__documentation_md(context1);

String _renderTypedef_partial_source_code_6(Typedef context1) =>
    _deduplicated_lib_templates_md__source_code_md(context1);

String _renderTypedef_partial_footer_7(TypedefTemplateData context0) =>
    _deduplicated_lib_templates_md__footer_md(context0);

String _deduplicated_lib_templates_md__head_md(TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader);
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__documentation_md(Warnable context0) {
  final buffer = StringBuffer();
  if (context0.hasDocumentation) {
    buffer.writeln();
    buffer.write(context0.documentationAsHtml);
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__library_md(Library context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  if (context0.isDocumented) {
    buffer.writeln();
    buffer.write(context0.oneLineDoc);
    buffer.writeln();
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__container_md(Container context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.write(context0.linkedGenericParameters);
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__container_md_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__container_md_partial_categorization_0(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__categorization_md(
    ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__extension_md(Extension context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__extension_md_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__extension_md_partial_categorization_0(
    Extension context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__constant_md(GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.write(''' const ''');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__constant_md_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__constant_md_partial_attributes_1(
          context0));
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__constant_md_partial_categorization_0(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__constant_md_partial_attributes_1(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context0.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__attributes_md(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context0.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__property_md(GetterSetterCombo context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.write(' ');
  buffer.write(context0.arrow);
  buffer.write(' ');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__property_md_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__property_md_partial_attributes_1(
          context0));
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__property_md_partial_categorization_0(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__property_md_partial_attributes_1(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context0.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__typedef_md(Typedef context0) {
  final buffer = StringBuffer();
  if (context0.isCallable) {
    var context1 = context0.asCallable;
    buffer.writeln();
    buffer.write('''
    ##### ''');
    buffer.write(context1.linkedName);
    buffer.write(context1.linkedGenericParameters);
    buffer.write(''' = ''');
    buffer.write(context1.modelType.linkedName);
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates_md__typedef_md_partial_categorization_0(
            context1));
    buffer.write('\n\n    ');
    buffer.write(context1.oneLineDoc);
    buffer.write('  ');
    buffer.write('\n    ');
    buffer.write(
        __deduplicated_lib_templates_md__typedef_md_partial_attributes_1(
            context1));
  }
  if (!context0.isCallable) {
    buffer.write('\n  ');
    buffer.write(
        __deduplicated_lib_templates_md__typedef_md_partial_type_2(context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__typedef_md_partial_categorization_0(
    FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__typedef_md_partial_attributes_1(
    FunctionTypedef context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__typedef_md_partial_type_2(
    Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.write(context0.linkedGenericParameters);
  buffer.write(''' = ''');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__typedef_md_partial_type_2_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__typedef_md_partial_type_2_partial_attributes_1(
          context0));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__typedef_md_partial_type_2_partial_categorization_0(
        Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__typedef_md_partial_type_2_partial_attributes_1(
        Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context0.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__type_md(Typedef context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context0.linkedName);
  buffer.write(context0.linkedGenericParameters);
  buffer.write(''' = ''');
  buffer.write(context0.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__type_md_partial_categorization_0(
          context0));
  buffer.write('\n\n');
  buffer.write(context0.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      __deduplicated_lib_templates_md__type_md_partial_attributes_1(context0));
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__type_md_partial_categorization_0(
    Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context1 = context0.displayedCategories;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__type_md_partial_attributes_1(
    Typedef context0) {
  final buffer = StringBuffer();
  if (context0.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context0.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__footer_md(TemplateDataBase context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter);
  buffer.writeln();
  buffer.write(context0.customFooter);
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__source_link_md(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceHref) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context0.sourceHref);
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__feature_set_md(ModelElement context0) {
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

String _deduplicated_lib_templates_md__super_chain_md(
    InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicSuperChainReversed) {
    buffer.writeln();
    buffer.write('''
**Inheritance**

- ''');
    buffer.write(context0.linkedObjectType);
    var context1 = context0.publicSuperChainReversed;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context2.linkedName);
    }
    buffer.writeln();
    buffer.write('''
- ''');
    buffer.write(context0.name);
  }

  return buffer.toString();
}

String _deduplicated_lib_templates_md__annotations_md(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
**Annotations**
''');
    var context1 = context0.annotations;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context2.linkedNameWithParameters);
    }
  }

  return buffer.toString();
}

String _deduplicated_lib_templates_md__constructors_md(
    InheritingContainer context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicConstructors) {
    buffer.writeln();
    buffer.write('''
## Constructors
''');
    var context1 = context0.publicConstructorsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(context2.linkedName);
      buffer.write(''' (''');
      buffer.write(context2.linkedParams);
      buffer.write(''')

''');
      buffer.write(context2.oneLineDoc);
      buffer.write('  ');
      if (context2.isConst) {
        buffer.write('''_const_''');
      }
      buffer.write(' ');
      if (context2.isFactory) {
        buffer.write('''_factory_''');
      }
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String _deduplicated_lib_templates_md__instance_methods_md(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceMethods) {
    buffer.writeln();
    buffer.write('''
## Methods
''');
    var context1 = context0.publicInstanceMethodsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(
          __deduplicated_lib_templates_md__instance_methods_md_partial_callable_0(
              context2));
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String __deduplicated_lib_templates_md__instance_methods_md_partial_callable_0(
    Method context1) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context1.linkedName);
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''(''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''') ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__instance_methods_md_partial_callable_0_partial_categorization_0(
          context1));
  buffer.write('\n\n');
  buffer.write(context1.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__instance_methods_md_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__instance_methods_md_partial_callable_0_partial_categorization_0(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__instance_methods_md_partial_callable_0_partial_attributes_1(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__instance_operators_md(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicInstanceOperators) {
    buffer.writeln();
    buffer.write('''
## Operators
''');
    var context1 = context0.publicInstanceOperatorsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(
          __deduplicated_lib_templates_md__instance_operators_md_partial_callable_0(
              context2));
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__instance_operators_md_partial_callable_0(
        Operator context1) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context1.linkedName);
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''(''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''') ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__instance_operators_md_partial_callable_0_partial_categorization_0(
          context1));
  buffer.write('\n\n');
  buffer.write(context1.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__instance_operators_md_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__instance_operators_md_partial_callable_0_partial_categorization_0(
        Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__instance_operators_md_partial_callable_0_partial_attributes_1(
        Operator context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__static_properties_md(
    Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicVariableStaticFields) {
    buffer.writeln();
    buffer.write('''
## Static Properties
''');
    var context1 = context0.publicVariableStaticFieldsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(
          __deduplicated_lib_templates_md__static_properties_md_partial_property_0(
              context2));
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String __deduplicated_lib_templates_md__static_properties_md_partial_property_0(
    Field context1) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context1.linkedName);
  buffer.write(' ');
  buffer.write(context1.arrow);
  buffer.write(' ');
  buffer.write(context1.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_properties_md_partial_property_0_partial_categorization_0(
          context1));
  buffer.write('\n\n');
  buffer.write(context1.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_properties_md_partial_property_0_partial_attributes_1(
          context1));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_properties_md_partial_property_0_partial_categorization_0(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_properties_md_partial_property_0_partial_attributes_1(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__static_methods_md(Container context0) {
  final buffer = StringBuffer();
  if (context0.hasPublicStaticMethods) {
    buffer.writeln();
    buffer.write('''
## Static Methods
''');
    var context1 = context0.publicStaticMethodsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(
          __deduplicated_lib_templates_md__static_methods_md_partial_callable_0(
              context2));
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String __deduplicated_lib_templates_md__static_methods_md_partial_callable_0(
    Method context1) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context1.linkedName);
  buffer.write(context1.linkedGenericParameters);
  buffer.write('''(''');
  buffer.write(context1.linkedParamsNoMetadata);
  buffer.write(''') ''');
  buffer.write(context1.modelType.returnType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_methods_md_partial_callable_0_partial_categorization_0(
          context1));
  buffer.write('\n\n');
  buffer.write(context1.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_methods_md_partial_callable_0_partial_attributes_1(
          context1));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_methods_md_partial_callable_0_partial_categorization_0(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_methods_md_partial_callable_0_partial_attributes_1(
        Method context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__static_constants_md(Container context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  if (context0.hasPublicConstantFields) {
    buffer.writeln();
    buffer.write('''
## Constants
''');
    var context1 = context0.publicConstantFieldsSorted;
    for (var context2 in context1) {
      buffer.writeln();
      buffer.write(
          __deduplicated_lib_templates_md__static_constants_md_partial_constant_0(
              context2));
      buffer.writeln();
    }
  }

  return buffer.toString();
}

String __deduplicated_lib_templates_md__static_constants_md_partial_constant_0(
    Field context1) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context1.linkedName);
  buffer.write(''' const ''');
  buffer.write(context1.modelType.linkedName);
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_constants_md_partial_constant_0_partial_categorization_0(
          context1));
  buffer.write('\n\n');
  buffer.write(context1.oneLineDoc);
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___deduplicated_lib_templates_md__static_constants_md_partial_constant_0_partial_attributes_1(
          context1));
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_constants_md_partial_constant_0_partial_categorization_0(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write(context3!.categoryLabel);
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String
    ___deduplicated_lib_templates_md__static_constants_md_partial_constant_0_partial_attributes_1(
        Field context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__source_code_md(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context0.sourceCode);
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__name_summary_md(ModelElement context0) {
  final buffer = StringBuffer();
  if (context0.isConst) {
    buffer.write('''const ''');
  }
  if (context0.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context0.name);
  if (context0.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__accessor_getter_md(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.getter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_md__accessor_getter_md_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write(context1.modelType.returnType.linkedName);
    buffer.write(' ');
    buffer.write(
        __deduplicated_lib_templates_md__accessor_getter_md_partial_name_summary_1(
            context1));
    buffer.write('  ');
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_md__accessor_getter_md_partial_attributes_2(
            context1));
    buffer.write('\n\n');
    buffer.write(
        __deduplicated_lib_templates_md__accessor_getter_md_partial_documentation_3(
            context1));
    buffer.write('\n\n');
    buffer.write(
        __deduplicated_lib_templates_md__accessor_getter_md_partial_source_code_4(
            context1));
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_getter_md_partial_annotations_0(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
**Annotations**
''');
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedNameWithParameters);
    }
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_getter_md_partial_name_summary_1(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name);
  if (context1.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__accessor_getter_md_partial_attributes_2(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_getter_md_partial_documentation_3(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml);
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_getter_md_partial_source_code_4(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode);
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _deduplicated_lib_templates_md__accessor_setter_md(
    GetterSetterCombo context0) {
  final buffer = StringBuffer();
  var context1 = context0.setter;
  if (context1 != null) {
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_md__accessor_setter_md_partial_annotations_0(
            context1));
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_md__accessor_setter_md_partial_name_summary_1(
            context1));
    buffer.write('''(''');
    buffer.write(context1.linkedParamsNoMetadata);
    buffer.write(''')  ''');
    buffer.writeln();
    buffer.write(
        __deduplicated_lib_templates_md__accessor_setter_md_partial_attributes_2(
            context1));
    buffer.write('\n\n');
    buffer.write(
        __deduplicated_lib_templates_md__accessor_setter_md_partial_documentation_3(
            context1));
    buffer.write('\n\n');
    buffer.write(
        __deduplicated_lib_templates_md__accessor_setter_md_partial_source_code_4(
            context1));
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_setter_md_partial_annotations_0(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations) {
    buffer.writeln();
    buffer.write('''
**Annotations**
''');
    var context2 = context1.annotations;
    for (var context3 in context2) {
      buffer.writeln();
      buffer.write('''
- ''');
      buffer.write(context3.linkedNameWithParameters);
    }
  }

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_setter_md_partial_name_summary_1(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.isConst) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name);
  if (context1.isDeprecated) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __deduplicated_lib_templates_md__accessor_setter_md_partial_attributes_2(
    Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasAttributes) {
    buffer.write('''_''');
    buffer.write(context1.attributesAsString);
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_setter_md_partial_documentation_3(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml);
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __deduplicated_lib_templates_md__accessor_setter_md_partial_source_code_4(
        Accessor context1) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode);
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

extension on StringBuffer {
  void writeEscaped(String? value) {
    write(htmlEscape.convert(value ?? ''));
  }
}
