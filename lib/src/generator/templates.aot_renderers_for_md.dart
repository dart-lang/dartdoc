// GENERATED CODE. DO NOT EDIT.
//
// To change the contents of this library, make changes to the builder source
// files in the tool/mustachio/ directory.

// Sometimes we enter a new section which triggers creating a new variable, but
// the variable is not used; generally when the section is checking if a
// non-bool, non-Iterable field is non-null.
// ignore_for_file: unused_local_variable
// @dart=2.9
// ignore_for_file: non_constant_identifier_names, unnecessary_string_escapes

import 'dart:convert' as _i19;

import 'package:dartdoc/src/generator/template_data.dart' as _i1;
import 'package:dartdoc/src/model/accessor.dart' as _i17;
import 'package:dartdoc/src/model/category.dart' as _i2;
import 'package:dartdoc/src/model/class.dart' as _i8;
import 'package:dartdoc/src/model/constructor.dart' as _i11;
import 'package:dartdoc/src/model/container.dart' as _i4;
import 'package:dartdoc/src/model/documentable.dart' as _i18;
import 'package:dartdoc/src/model/enum.dart' as _i12;
import 'package:dartdoc/src/model/extension.dart' as _i13;
import 'package:dartdoc/src/model/field.dart' as _i9;
import 'package:dartdoc/src/model/library.dart' as _i3;
import 'package:dartdoc/src/model/library_container.dart' as _i15;
import 'package:dartdoc/src/model/method.dart' as _i10;
import 'package:dartdoc/src/model/mixin.dart' as _i16;
import 'package:dartdoc/src/model/model_function.dart' as _i6;
import 'package:dartdoc/src/model/package.dart' as _i14;
import 'package:dartdoc/src/model/top_level_variable.dart' as _i5;
import 'package:dartdoc/src/model/typedef.dart' as _i7;

String renderCategory(_i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderCategory_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.writeEscaped(context1.name.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderCategory_partial_documentation_1(context1, context0));
    buffer.writeln();
    if (context1.hasPublicLibraries == true) {
      buffer.writeln();
      buffer.write('''
## Libraries
''');
      var context2 = context1.publicLibrariesSorted;
      if (context2 != null) {
        for (var context3 in context2) {
          buffer.writeln();
          buffer.write(
              _renderCategory_partial_library_2(context3, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicClasses == true) {
      buffer.writeln();
      buffer.write('''
## Classes
''');
      var context4 = context1.publicClassesSorted;
      if (context4 != null) {
        for (var context5 in context4) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_container_3(
              context5, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicMixins == true) {
      buffer.writeln();
      buffer.write('''
## Mixins
''');
      var context6 = context1.publicMixinsSorted;
      if (context6 != null) {
        for (var context7 in context6) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_container_3(
              context7, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicConstants == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context8 = context1.publicConstantsSorted;
      if (context8 != null) {
        for (var context9 in context8) {
          buffer.writeln();
          buffer.write(
              _renderCategory_partial_constant_4(context9, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicProperties == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context10 = context1.publicPropertiesSorted;
      if (context10 != null) {
        for (var context11 in context10) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_property_5(
              context11, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicFunctions == true) {
      buffer.writeln();
      buffer.write('''
## Functions
''');
      var context12 = context1.publicFunctionsSorted;
      if (context12 != null) {
        for (var context13 in context12) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_callable_6(
              context13, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicEnums == true) {
      buffer.writeln();
      buffer.write('''
## Enums
''');
      var context14 = context1.publicEnumsSorted;
      if (context14 != null) {
        for (var context15 in context14) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_container_3(
              context15, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicTypedefs == true) {
      buffer.writeln();
      buffer.write('''
## Typedefs
''');
      var context16 = context1.publicTypedefsSorted;
      if (context16 != null) {
        for (var context17 in context16) {
          buffer.writeln();
          buffer.write(
              _renderCategory_partial_typedef_7(context17, context1, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context1.hasPublicExceptions == true) {
      buffer.writeln();
      buffer.write('''
## Exceptions / Errors
''');
      var context18 = context1.publicExceptionsSorted;
      if (context18 != null) {
        for (var context19 in context18) {
          buffer.writeln();
          buffer.write(_renderCategory_partial_container_3(
              context19, context1, context0));
          buffer.writeln();
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderCategory_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_head_0(_i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_documentation_1(
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_library_2(_i3.Library context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  if (context2.isDocumented == true) {
    buffer.writeln();
    buffer.write(context2.oneLineDoc.toString());
    buffer.write(' ');
    buffer.write(context2.extendedDocLink.toString());
    buffer.writeln();
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_container_3(_i4.Container context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.writeln();
  buffer.write(__renderCategory_partial_container_3_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_container_3_partial_categorization_0(
    _i4.Container context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_constant_4(_i5.TopLevelVariable context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderCategory_partial_constant_4_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderCategory_partial_constant_4_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_constant_4_partial_categorization_0(
    _i5.TopLevelVariable context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_constant_4_partial_features_1(
    _i5.TopLevelVariable context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_property_5(_i5.TopLevelVariable context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(' ');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderCategory_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderCategory_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_property_5_partial_categorization_0(
    _i5.TopLevelVariable context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_property_5_partial_features_1(
    _i5.TopLevelVariable context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_callable_6(_i6.ModelFunctionTyped context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderCategory_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderCategory_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_callable_6_partial_categorization_0(
    _i6.ModelFunctionTyped context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_callable_6_partial_features_1(
    _i6.ModelFunctionTyped context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_typedef_7(_i7.Typedef context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isCallable == true) {
    var context3 = context2.asCallable;
    if (context3 != null) {
      buffer.writeln();
      buffer.write('''
    ##### ''');
      buffer.write(context3.linkedName.toString());
      buffer.write(context3.linkedGenericParameters.toString());
      buffer.write(''' = ''');
      buffer.write(context3.modelType.linkedName.toString());
      buffer.write('\n    ');
      buffer.write(__renderCategory_partial_typedef_7_partial_categorization_0(
          context3, context2, context1, context0));
      buffer.write('\n\n    ');
      buffer.write(context3.oneLineDoc.toString());
      buffer.write(' ');
      buffer.write(context3.extendedDocLink.toString());
      buffer.write('  ');
      buffer.write('\n    ');
      buffer.write(__renderCategory_partial_typedef_7_partial_features_1(
          context3, context2, context1, context0));
    }
  }
  if (context2.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(__renderCategory_partial_typedef_7_partial_type_2(
        context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_typedef_7_partial_categorization_0(
    _i7.FunctionTypedef context3,
    _i7.Typedef context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_typedef_7_partial_features_1(
    _i7.FunctionTypedef context3,
    _i7.Typedef context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderCategory_partial_typedef_7_partial_type_2(_i7.Typedef context2,
    _i2.Category context1, _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write(''' = ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(
      ___renderCategory_partial_typedef_7_partial_type_2_partial_categorization_0(
          context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___renderCategory_partial_typedef_7_partial_type_2_partial_features_1(
          context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String
    ___renderCategory_partial_typedef_7_partial_type_2_partial_categorization_0(
        _i7.Typedef context2,
        _i2.Category context1,
        _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String ___renderCategory_partial_typedef_7_partial_type_2_partial_features_1(
    _i7.Typedef context2,
    _i2.Category context1,
    _i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderCategory_partial_footer_8(_i1.CategoryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderClass(_i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderClass_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderClass_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderClass_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderClass_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.clazz;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(_renderClass_partial_documentation_4(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.writeln();
        buffer.write('''
**Inheritance**

- ''');
        buffer.write(context0.linkedObjectType.toString());
        var context3 = context2.publicSuperChainReversed;
        if (context3 != null) {
          for (var context4 in context3) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context4.linkedName.toString());
          }
        }
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context2.name.toString());
      }
      buffer.writeln();
      if (context2.hasPublicInterfaces == true) {
        buffer.writeln();
        buffer.write('''
**Implemented types**
''');
        var context5 = context2.publicInterfaces;
        if (context5 != null) {
          for (var context6 in context5) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context6.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasPublicMixedInTypes == true) {
        buffer.writeln();
        buffer.write('''
**Mixed in types**
''');
        var context7 = context2.publicMixedInTypes;
        if (context7 != null) {
          for (var context8 in context7) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context8.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasPublicImplementors == true) {
        buffer.writeln();
        buffer.write('''
**Implementers**
''');
        var context9 = context2.publicImplementorsSorted;
        if (context9 != null) {
          for (var context10 in context9) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context10.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasPotentiallyApplicableExtensions == true) {
        buffer.writeln();
        buffer.write('''
**Available Extensions**
''');
        var context11 = context2.potentiallyApplicableExtensions;
        if (context11 != null) {
          buffer.writeln();
          buffer.write('''
- ''');
          buffer.write(context2.linkedName.toString());
        }
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.writeln();
        buffer.write('''
**Annotations**
''');
        var context12 = context2.annotations;
        if (context12 != null) {
          for (var context13 in context12) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context13.linkedNameWithParameters.toString());
          }
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicConstructors == true) {
      buffer.writeln();
      buffer.write('''
## Constructors
''');
      var context14 = context2.publicConstructorsSorted;
      if (context14 != null) {
        for (var context15 in context14) {
          buffer.writeln();
          buffer.write(context15.linkedName.toString());
          buffer.write(''' (''');
          buffer.write(context15.linkedParams.toString());
          buffer.write(''')

''');
          buffer.write(context15.oneLineDoc.toString());
          buffer.write(' ');
          buffer.write(context15.extendedDocLink.toString());
          buffer.write('  ');
          if (context15.isConst == true) {
            buffer.write('''_const_''');
          }
          buffer.write(' ');
          if (context15.isFactory == true) {
            buffer.write('''_factory_''');
          }
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context16 = context2.publicInstanceFieldsSorted;
      if (context16 != null) {
        for (var context17 in context16) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_property_5(context17, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.writeln();
      buffer.write('''
## Methods
''');
      var context18 = context2.publicInstanceMethodsSorted;
      if (context18 != null) {
        for (var context19 in context18) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_callable_6(context19, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.writeln();
      buffer.write('''
## Operators
''');
      var context20 = context2.publicInstanceOperatorsSorted;
      if (context20 != null) {
        for (var context21 in context20) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_callable_6(context21, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.writeln();
      buffer.write('''
## Static Properties
''');
      var context22 = context2.publicVariableStaticFieldsSorted;
      if (context22 != null) {
        for (var context23 in context22) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_property_5(context23, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.writeln();
      buffer.write('''
## Static Methods
''');
      var context24 = context2.publicStaticMethodsSorted;
      if (context24 != null) {
        for (var context25 in context24) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_callable_6(context25, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context26 = context2.publicConstantFieldsSorted;
      if (context26 != null) {
        for (var context27 in context26) {
          buffer.writeln();
          buffer.write(
              _renderClass_partial_constant_7(context27, context2, context0));
          buffer.writeln();
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderClass_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_head_0(_i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_source_link_1(
    _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_categorization_2(
    _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_feature_set_3(
    _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_documentation_4(
    _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_property_5(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(' ');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderClass_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderClass_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_property_5_partial_categorization_0(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_property_5_partial_features_1(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_callable_6(
    _i10.Method context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderClass_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderClass_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_callable_6_partial_categorization_0(
    _i10.Method context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_callable_6_partial_features_1(
    _i10.Method context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_constant_7(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderClass_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderClass_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_constant_7_partial_categorization_0(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderClass_partial_constant_7_partial_features_1(
    _i9.Field context2, _i8.Class context1, _i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderClass_partial_footer_8(_i1.ClassTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderConstructor(_i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderConstructor_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderConstructor_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderConstructor_partial_feature_set_2(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.constructor;
  if (context2 != null) {
    if (context2.hasAnnotations == true) {
      var context3 = context2.annotations;
      if (context3 != null) {
        for (var context4 in context3) {
          buffer.writeln();
          buffer.write('''
- ''');
          buffer.write(context4.linkedNameWithParameters.toString());
        }
      }
    }
    buffer.writeln();
    if (context2.isConst == true) {
      buffer.write('''const''');
    }
    buffer.writeln();
    buffer.write(context2.nameWithGenerics.toString());
    buffer.write('''(''');
    if (context2.hasParameters == true) {
      buffer.write(context2.linkedParamsLines.toString());
    }
    buffer.write(''')

''');
    buffer
        .write(_renderConstructor_partial_documentation_3(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderConstructor_partial_source_code_4(context2, context0));
    buffer.writeln();
  }
  buffer.write('\n\n');
  buffer.write(_renderConstructor_partial_footer_5(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_head_0(_i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_source_link_1(
    _i11.Constructor context1, _i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_feature_set_2(
    _i11.Constructor context1, _i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_documentation_3(
    _i11.Constructor context1, _i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_source_code_4(
    _i11.Constructor context1, _i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderConstructor_partial_footer_5(
    _i1.ConstructorTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderEnum(_i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderEnum_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.name.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderEnum_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderEnum_partial_feature_set_2(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.eNum;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(_renderEnum_partial_documentation_3(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.writeln();
        buffer.write('''
**Inheritance**

- ''');
        buffer.write(context0.linkedObjectType.toString());
        var context3 = context2.publicSuperChainReversed;
        if (context3 != null) {
          for (var context4 in context3) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context4.linkedName.toString());
          }
        }
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context2.name.toString());
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.writeln();
        buffer.write('''
**Annotations**
''');
        var context5 = context2.annotations;
        if (context5 != null) {
          for (var context6 in context5) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context6.linkedNameWithParameters.toString());
          }
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context7 = context2.publicConstantFieldsSorted;
      if (context7 != null) {
        for (var context8 in context7) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_constant_4(context8, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context9 = context2.publicInstanceFieldsSorted;
      if (context9 != null) {
        for (var context10 in context9) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_property_5(context10, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.writeln();
      buffer.write('''
## Methods
''');
      var context11 = context2.publicInstanceMethodsSorted;
      if (context11 != null) {
        for (var context12 in context11) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_callable_6(context12, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.writeln();
      buffer.write('''
## Operators
''');
      var context13 = context2.publicInstanceOperatorsSorted;
      if (context13 != null) {
        for (var context14 in context13) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_callable_6(context14, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.writeln();
      buffer.write('''
## Static Properties
''');
      var context15 = context2.publicVariableStaticFieldsSorted;
      if (context15 != null) {
        for (var context16 in context15) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_property_5(context16, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.writeln();
      buffer.write('''
## Static Methods
''');
      var context17 = context2.publicStaticMethodsSorted;
      if (context17 != null) {
        for (var context18 in context17) {
          buffer.writeln();
          buffer.write(
              _renderEnum_partial_callable_6(context18, context2, context0));
          buffer.writeln();
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderEnum_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_head_0(_i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_source_link_1(
    _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_feature_set_2(
    _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_documentation_3(
    _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_constant_4(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderEnum_partial_constant_4_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderEnum_partial_constant_4_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_constant_4_partial_categorization_0(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_constant_4_partial_features_1(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_property_5(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(' ');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderEnum_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderEnum_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_property_5_partial_categorization_0(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_property_5_partial_features_1(
    _i9.Field context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_callable_6(
    _i10.Method context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderEnum_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderEnum_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_callable_6_partial_categorization_0(
    _i10.Method context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderEnum_partial_callable_6_partial_features_1(
    _i10.Method context2, _i12.Enum context1, _i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderEnum_partial_footer_7(_i1.EnumTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderError(_i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''# 404

Oops, something\'s gone wrong :-(

You\'ve tried to visit a page that doesn\'t exist. Luckily this site has other
[pages](index.md).
''');

  return buffer.toString();
}

String renderExtension<T extends _i13.Extension>(
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(_renderExtension_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.writeln();
    buffer.write('''
on ''');
    var context2 = context1.extendedType;
    if (context2 != null) {
      buffer.write(context2.linkedName.toString());
    }
    buffer.write('\n\n');
    buffer.write(_renderExtension_partial_source_link_1(context1, context0));
    buffer.write('\n\n');
    buffer.write(_renderExtension_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderExtension_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context3 = context0.extension;
  if (context3 != null) {
    buffer.writeln();
    buffer.write(_renderExtension_partial_documentation_4(context3, context0));
    buffer.writeln();
    if (context3.hasPublicInstanceFields == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context4 = context3.publicInstanceFieldsSorted;
      if (context4 != null) {
        for (var context5 in context4) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_property_5(
              context5, context3, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context3.hasPublicInstanceMethods == true) {
      buffer.writeln();
      buffer.write('''
## Methods
''');
      var context6 = context3.publicInstanceMethodsSorted;
      if (context6 != null) {
        for (var context7 in context6) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_callable_6(
              context7, context3, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context3.hasPublicInstanceOperators == true) {
      buffer.writeln();
      buffer.write('''
## Operators
''');
      var context8 = context3.publicInstanceOperatorsSorted;
      if (context8 != null) {
        for (var context9 in context8) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_callable_6(
              context9, context3, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context3.hasPublicVariableStaticFields == true) {
      buffer.writeln();
      buffer.write('''
## Static Properties
''');
      var context10 = context3.publicVariableStaticFieldsSorted;
      if (context10 != null) {
        for (var context11 in context10) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_property_5(
              context11, context3, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context3.hasPublicStaticMethods == true) {
      buffer.writeln();
      buffer.write('''
## Static Methods
''');
      var context12 = context3.publicStaticMethodsSorted;
      if (context12 != null) {
        for (var context13 in context12) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_callable_6(
              context13, context3, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context3.hasPublicConstantFields == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context14 = context3.publicConstantFieldsSorted;
      if (context14 != null) {
        for (var context15 in context14) {
          buffer.writeln();
          buffer.write(_renderExtension_partial_constant_7(
              context15, context3, context0));
          buffer.writeln();
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderExtension_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_head_0<T extends _i13.Extension>(
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_source_link_1<T extends _i13.Extension>(
    _i13.Extension context1, _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_categorization_2<T extends _i13.Extension>(
    _i13.Extension context1, _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_feature_set_3<T extends _i13.Extension>(
    _i13.Extension context1, _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_documentation_4<T extends _i13.Extension>(
    _i13.Extension context1, _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_property_5<T extends _i13.Extension>(
    _i9.Field context2,
    _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(' ');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderExtension_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderExtension_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_property_5_partial_categorization_0<
        T extends _i13.Extension>(_i9.Field context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_property_5_partial_features_1<
        T extends _i13.Extension>(_i9.Field context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_callable_6<T extends _i13.Extension>(
    _i10.Method context2,
    _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderExtension_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderExtension_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_callable_6_partial_categorization_0<
        T extends _i13.Extension>(_i10.Method context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_callable_6_partial_features_1<
        T extends _i13.Extension>(_i10.Method context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_constant_7<T extends _i13.Extension>(
    _i9.Field context2,
    _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderExtension_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderExtension_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_constant_7_partial_categorization_0<
        T extends _i13.Extension>(_i9.Field context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderExtension_partial_constant_7_partial_features_1<
        T extends _i13.Extension>(_i9.Field context2, _i13.Extension context1,
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderExtension_partial_footer_8<T extends _i13.Extension>(
    _i1.ExtensionTemplateData<T> context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderFunction(_i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderFunction_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderFunction_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderFunction_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderFunction_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.function;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(
        _renderFunction_partial_callable_multiline_4(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderFunction_partial_documentation_5(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderFunction_partial_source_code_6(context2, context0));
    buffer.writeln();
  }
  buffer.write('\n\n');
  buffer.write(_renderFunction_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_head_0(_i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_source_link_1(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_categorization_2(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_feature_set_3(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_callable_multiline_4(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    var context2 = context1.annotations;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context3.linkedNameWithParameters.toString());
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(context1.modelType.returnType.linkedName.toString());
  buffer.write(' ');
  buffer.write(
      __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write('''(''');
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines.toString());
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderFunction_partial_callable_multiline_4_partial_name_summary_0(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name.toString());
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_documentation_5(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_source_code_6(
    _i6.ModelFunction context1, _i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderFunction_partial_footer_7(_i1.FunctionTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderIndex(_i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderIndex_partial_head_0(context0));
  buffer.writeln();
  buffer.write('''

# ''');
  buffer.writeEscaped(context0.title.toString());
  buffer.writeln();
  var context1 = context0.defaultPackage;
  if (context1 != null) {
    buffer.writeln();
    buffer.write(_renderIndex_partial_documentation_1(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.localPackages;
  if (context2 != null) {
    for (var context3 in context2) {
      if (context3.isFirstPackage == true) {
        buffer.writeln();
        buffer.write('''
## Libraries''');
      }
      if (context3.isFirstPackage != true) {
        buffer.writeln();
        buffer.write('''
## ''');
        buffer.writeEscaped(context3.name.toString());
      }
      buffer.writeln();
      var context4 = context3.defaultCategory;
      if (context4 != null) {
        var context5 = context4.publicLibrariesSorted;
        if (context5 != null) {
          for (var context6 in context5) {
            buffer.writeln();
            buffer.write(_renderIndex_partial_library_2(
                context6, context4, context3, context0));
          }
        }
      }
      buffer.writeln();
      var context7 = context3.categoriesWithPublicLibraries;
      if (context7 != null) {
        for (var context8 in context7) {
          buffer.writeln();
          buffer.write('''
### Category ''');
          buffer.write(context8.categoryLabel.toString());
          buffer.writeln();
          var context9 = context8.publicLibrariesSorted;
          if (context9 != null) {
            for (var context10 in context9) {
              buffer.writeln();
              buffer.write(_renderIndex_partial_library_2(
                  context10, context8, context3, context0));
            }
          }
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderIndex_partial_footer_3(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderIndex_partial_head_0(_i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderIndex_partial_documentation_1(
    _i14.Package context1, _i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderIndex_partial_library_2(
    _i3.Library context3,
    _i15.LibraryContainer context2,
    _i14.Package context1,
    _i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  if (context3.isDocumented == true) {
    buffer.writeln();
    buffer.write(context3.oneLineDoc.toString());
    buffer.write(' ');
    buffer.write(context3.extendedDocLink.toString());
    buffer.writeln();
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderIndex_partial_footer_3(_i1.PackageTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderLibrary(_i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderLibrary_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.name.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderLibrary_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderLibrary_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderLibrary_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.library;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(_renderLibrary_partial_documentation_4(context2, context0));
  }
  buffer.writeln();
  var context3 = context0.library;
  if (context3 != null) {
    if (context3.hasPublicClasses == true) {
      buffer.writeln();
      buffer.write('''
## Classes
''');
      var context4 = context3.library;
      if (context4 != null) {
        var context5 = context4.publicClassesSorted;
        if (context5 != null) {
          for (var context6 in context5) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_container_5(
                context6, context4, context3, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context7 = context0.library;
  if (context7 != null) {
    if (context7.hasPublicMixins == true) {
      buffer.writeln();
      buffer.write('''
## Mixins
''');
      var context8 = context7.library;
      if (context8 != null) {
        var context9 = context8.publicMixinsSorted;
        if (context9 != null) {
          for (var context10 in context9) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_container_5(
                context10, context8, context7, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context11 = context0.library;
  if (context11 != null) {
    if (context11.hasPublicExtensions == true) {
      buffer.writeln();
      buffer.write('''
## Extensions
''');
      var context12 = context11.library;
      if (context12 != null) {
        var context13 = context12.publicExtensionsSorted;
        if (context13 != null) {
          for (var context14 in context13) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_extension_6(
                context14, context12, context11, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context15 = context0.library;
  if (context15 != null) {
    if (context15.hasPublicConstants == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context16 = context15.library;
      if (context16 != null) {
        var context17 = context16.publicConstantsSorted;
        if (context17 != null) {
          for (var context18 in context17) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_constant_7(
                context18, context16, context15, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context19 = context0.library;
  if (context19 != null) {
    if (context19.hasPublicProperties == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context20 = context19.library;
      if (context20 != null) {
        var context21 = context20.publicPropertiesSorted;
        if (context21 != null) {
          for (var context22 in context21) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_property_8(
                context22, context20, context19, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context23 = context0.library;
  if (context23 != null) {
    if (context23.hasPublicFunctions == true) {
      buffer.writeln();
      buffer.write('''
## Functions
''');
      var context24 = context23.library;
      if (context24 != null) {
        var context25 = context24.publicFunctionsSorted;
        if (context25 != null) {
          for (var context26 in context25) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_callable_9(
                context26, context24, context23, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context27 = context0.library;
  if (context27 != null) {
    if (context27.hasPublicEnums == true) {
      buffer.writeln();
      buffer.write('''
## Enums
''');
      var context28 = context27.library;
      if (context28 != null) {
        var context29 = context28.publicEnumsSorted;
        if (context29 != null) {
          for (var context30 in context29) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_container_5(
                context30, context28, context27, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context31 = context0.library;
  if (context31 != null) {
    if (context31.hasPublicTypedefs == true) {
      buffer.writeln();
      buffer.write('''
## Typedefs
''');
      var context32 = context31.library;
      if (context32 != null) {
        var context33 = context32.publicTypedefsSorted;
        if (context33 != null) {
          for (var context34 in context33) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_typedef_10(
                context34, context32, context31, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.writeln();
  var context35 = context0.library;
  if (context35 != null) {
    if (context35.hasPublicExceptions == true) {
      buffer.writeln();
      buffer.write('''
## Exceptions / Errors
''');
      var context36 = context35.library;
      if (context36 != null) {
        var context37 = context36.publicExceptionsSorted;
        if (context37 != null) {
          for (var context38 in context37) {
            buffer.writeln();
            buffer.write(_renderLibrary_partial_container_5(
                context38, context36, context35, context0));
            buffer.writeln();
          }
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderLibrary_partial_footer_11(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_head_0(_i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_source_link_1(
    _i3.Library context1, _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_categorization_2(
    _i3.Library context1, _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_feature_set_3(
    _i3.Library context1, _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_documentation_4(
    _i3.Library context1, _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_container_5(
    _i4.Container context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.writeln();
  buffer.write(__renderLibrary_partial_container_5_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_container_5_partial_categorization_0(
    _i4.Container context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_extension_6(
    _i13.Extension context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderLibrary_partial_extension_6_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_extension_6_partial_categorization_0(
    _i13.Extension context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_constant_7(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderLibrary_partial_constant_7_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderLibrary_partial_constant_7_partial_features_1(
      context3, context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_constant_7_partial_categorization_0(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_constant_7_partial_features_1(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_property_8(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.write(' ');
  buffer.write(context3.arrow.toString());
  buffer.write(' ');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderLibrary_partial_property_8_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderLibrary_partial_property_8_partial_features_1(
      context3, context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_property_8_partial_categorization_0(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_property_8_partial_features_1(
    _i5.TopLevelVariable context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_callable_9(
    _i6.ModelFunctionTyped context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context3.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context3.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderLibrary_partial_callable_9_partial_categorization_0(
      context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderLibrary_partial_callable_9_partial_features_1(
      context3, context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_callable_9_partial_categorization_0(
    _i6.ModelFunctionTyped context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_callable_9_partial_features_1(
    _i6.ModelFunctionTyped context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_typedef_10(
    _i7.Typedef context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.isCallable == true) {
    var context4 = context3.asCallable;
    if (context4 != null) {
      buffer.writeln();
      buffer.write('''
    ##### ''');
      buffer.write(context4.linkedName.toString());
      buffer.write(context4.linkedGenericParameters.toString());
      buffer.write(''' = ''');
      buffer.write(context4.modelType.linkedName.toString());
      buffer.write('\n    ');
      buffer.write(__renderLibrary_partial_typedef_10_partial_categorization_0(
          context4, context3, context2, context1, context0));
      buffer.write('\n\n    ');
      buffer.write(context4.oneLineDoc.toString());
      buffer.write(' ');
      buffer.write(context4.extendedDocLink.toString());
      buffer.write('  ');
      buffer.write('\n    ');
      buffer.write(__renderLibrary_partial_typedef_10_partial_features_1(
          context4, context3, context2, context1, context0));
    }
  }
  if (context3.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(__renderLibrary_partial_typedef_10_partial_type_2(
        context3, context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_typedef_10_partial_categorization_0(
    _i7.FunctionTypedef context4,
    _i7.Typedef context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context4.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context5 = context4.displayedCategories;
    if (context5 != null) {
      for (var context6 in context5) {
        buffer.writeln();
        buffer.write(context6.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_typedef_10_partial_features_1(
    _i7.FunctionTypedef context4,
    _i7.Typedef context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context4.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context4.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderLibrary_partial_typedef_10_partial_type_2(
    _i7.Typedef context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context3.linkedName.toString());
  buffer.write(context3.linkedGenericParameters.toString());
  buffer.write(''' = ''');
  buffer.write(context3.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(
      ___renderLibrary_partial_typedef_10_partial_type_2_partial_categorization_0(
          context3, context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context3.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context3.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(
      ___renderLibrary_partial_typedef_10_partial_type_2_partial_features_1(
          context3, context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String
    ___renderLibrary_partial_typedef_10_partial_type_2_partial_categorization_0(
        _i7.Typedef context3,
        _i3.Library context2,
        _i3.Library context1,
        _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context4 = context3.displayedCategories;
    if (context4 != null) {
      for (var context5 in context4) {
        buffer.writeln();
        buffer.write(context5.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String ___renderLibrary_partial_typedef_10_partial_type_2_partial_features_1(
    _i7.Typedef context3,
    _i3.Library context2,
    _i3.Library context1,
    _i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  if (context3.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context3.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderLibrary_partial_footer_11(_i1.LibraryTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderMethod(_i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMethod_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderMethod_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderMethod_partial_feature_set_2(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.method;
  if (context2 != null) {
    buffer.writeln();
    buffer
        .write(_renderMethod_partial_callable_multiline_3(context2, context0));
    buffer.writeln();
    buffer.write(_renderMethod_partial_features_4(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderMethod_partial_documentation_5(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderMethod_partial_source_code_6(context2, context0));
    buffer.writeln();
  }
  buffer.write('\n\n');
  buffer.write(_renderMethod_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_head_0(_i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_source_link_1(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_feature_set_2(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_callable_multiline_3(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    var context2 = context1.annotations;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context3.linkedNameWithParameters.toString());
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(context1.modelType.returnType.linkedName.toString());
  buffer.write(' ');
  buffer.write(
      __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write('''(''');
  if (context1.hasParameters == true) {
    buffer.write(context1.linkedParamsLines.toString());
  }
  buffer.write(''')
''');

  return buffer.toString();
}

String __renderMethod_partial_callable_multiline_3_partial_name_summary_0(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name.toString());
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_features_4(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_documentation_5(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_source_code_6(
    _i10.Method context1, _i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMethod_partial_footer_7(_i1.MethodTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderMixin(_i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderMixin_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderMixin_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderMixin_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderMixin_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.mixin;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(_renderMixin_partial_documentation_4(context2, context0));
    buffer.writeln();
    if (context2.hasModifiers == true) {
      if (context2.hasPublicSuperclassConstraints == true) {
        buffer.writeln();
        buffer.write('''
**Superclass Constraints**
''');
        var context3 = context2.publicSuperclassConstraints;
        if (context3 != null) {
          for (var context4 in context3) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context4.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasPublicSuperChainReversed == true) {
        buffer.writeln();
        buffer.write('''
**Inheritance**

- ''');
        buffer.write(context0.linkedObjectType.toString());
        var context5 = context2.publicSuperChainReversed;
        if (context5 != null) {
          for (var context6 in context5) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context6.linkedName.toString());
          }
        }
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context2.name.toString());
      }
      buffer.writeln();
      if (context2.hasPublicInterfaces == true) {
        buffer.writeln();
        buffer.write('''
**Implemented types**
''');
        var context7 = context2.publicInterfaces;
        if (context7 != null) {
          for (var context8 in context7) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context8.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasPublicImplementors == true) {
        buffer.writeln();
        buffer.write('''
**Mixin Applications**
''');
        var context9 = context2.publicImplementorsSorted;
        if (context9 != null) {
          for (var context10 in context9) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context10.linkedName.toString());
          }
        }
      }
      buffer.writeln();
      if (context2.hasAnnotations == true) {
        buffer.writeln();
        buffer.write('''
**Annotations**
''');
        var context11 = context2.annotations;
        if (context11 != null) {
          for (var context12 in context11) {
            buffer.writeln();
            buffer.write('''
- ''');
            buffer.write(context12.linkedNameWithParameters.toString());
          }
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceFields == true) {
      buffer.writeln();
      buffer.write('''
## Properties
''');
      var context13 = context2.publicInstanceFieldsSorted;
      if (context13 != null) {
        for (var context14 in context13) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_property_5(context14, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceMethods == true) {
      buffer.writeln();
      buffer.write('''
## Methods
''');
      var context15 = context2.publicInstanceMethodsSorted;
      if (context15 != null) {
        for (var context16 in context15) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_callable_6(context16, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicInstanceOperators == true) {
      buffer.writeln();
      buffer.write('''
## Operators
''');
      var context17 = context2.publicInstanceOperatorsSorted;
      if (context17 != null) {
        for (var context18 in context17) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_callable_6(context18, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicVariableStaticFields == true) {
      buffer.writeln();
      buffer.write('''
## Static Properties
''');
      var context19 = context2.publicVariableStaticFieldsSorted;
      if (context19 != null) {
        for (var context20 in context19) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_property_5(context20, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicStaticMethods == true) {
      buffer.writeln();
      buffer.write('''
## Static Methods
''');
      var context21 = context2.publicStaticMethodsSorted;
      if (context21 != null) {
        for (var context22 in context21) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_callable_6(context22, context2, context0));
          buffer.writeln();
        }
      }
    }
    buffer.writeln();
    if (context2.hasPublicConstantFields == true) {
      buffer.writeln();
      buffer.write('''
## Constants
''');
      var context23 = context2.publicConstantFieldsSorted;
      if (context23 != null) {
        for (var context24 in context23) {
          buffer.writeln();
          buffer.write(
              _renderMixin_partial_constant_7(context24, context2, context0));
          buffer.writeln();
        }
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderMixin_partial_footer_8(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_head_0(_i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_source_link_1(
    _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_categorization_2(
    _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_feature_set_3(
    _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_documentation_4(
    _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_property_5(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(' ');
  buffer.write(context2.arrow.toString());
  buffer.write(' ');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderMixin_partial_property_5_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderMixin_partial_property_5_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_property_5_partial_categorization_0(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_property_5_partial_features_1(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_callable_6(
    _i10.Method context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(context2.linkedGenericParameters.toString());
  buffer.write('''(''');
  buffer.write(context2.linkedParamsNoMetadata.toString());
  buffer.write(''') ''');
  buffer.write(context2.modelType.returnType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderMixin_partial_callable_6_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderMixin_partial_callable_6_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_callable_6_partial_categorization_0(
    _i10.Method context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_callable_6_partial_features_1(
    _i10.Method context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_constant_7(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write('''##### ''');
  buffer.write(context2.linkedName.toString());
  buffer.write(''' const ''');
  buffer.write(context2.modelType.linkedName.toString());
  buffer.writeln();
  buffer.write(__renderMixin_partial_constant_7_partial_categorization_0(
      context2, context1, context0));
  buffer.write('\n\n');
  buffer.write(context2.oneLineDoc.toString());
  buffer.write(' ');
  buffer.write(context2.extendedDocLink.toString());
  buffer.write('  ');
  buffer.writeln();
  buffer.write(__renderMixin_partial_constant_7_partial_features_1(
      context2, context1, context0));
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_constant_7_partial_categorization_0(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context3 = context2.displayedCategories;
    if (context3 != null) {
      for (var context4 in context3) {
        buffer.writeln();
        buffer.write(context4.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderMixin_partial_constant_7_partial_features_1(
    _i9.Field context2, _i16.Mixin context1, _i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderMixin_partial_footer_8(_i1.MixinTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderProperty(_i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderProperty_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.writeEscaped(context1.name.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderProperty_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderProperty_partial_feature_set_2(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.self;
  if (context2 != null) {
    if (context2.hasNoGetterSetter == true) {
      buffer.writeln();
      buffer.write(context2.modelType.linkedName.toString());
      buffer.write(' ');
      buffer.write(_renderProperty_partial_name_summary_3(context2, context0));
      buffer.write('  ');
      buffer.writeln();
      buffer.write(_renderProperty_partial_features_4(context2, context0));
      buffer.write('\n\n');
      buffer.write(_renderProperty_partial_documentation_5(context2, context0));
      buffer.write('\n\n');
      buffer.write(_renderProperty_partial_source_code_6(context2, context0));
    }
    buffer.writeln();
    if (context2.hasGetterOrSetter == true) {
      if (context2.hasGetter == true) {
        buffer.writeln();
        buffer.write(
            _renderProperty_partial_accessor_getter_7(context2, context0));
      }
      buffer.writeln();
      if (context2.hasSetter == true) {
        buffer.writeln();
        buffer.write(
            _renderProperty_partial_accessor_setter_8(context2, context0));
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderProperty_partial_footer_9(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_head_0(_i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_source_link_1(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_feature_set_2(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_name_summary_3(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name.toString());
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_features_4(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_documentation_5(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_source_code_6(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_accessor_getter_7(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  var context2 = context1.getter;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(context2.modelType.returnType.linkedName.toString());
    buffer.write(' ');
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('  ');
    buffer.writeln();
    buffer.write(__renderProperty_partial_accessor_getter_7_partial_features_1(
        context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_documentation_2(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderProperty_partial_accessor_getter_7_partial_source_code_3(
            context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_name_summary_0(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context2.name.toString());
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_features_1(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_documentation_2(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context2.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_getter_7_partial_source_code_3(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context2.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_accessor_setter_8(
    _i9.Field context1, _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  var context2 = context1.setter;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('''(''');
    buffer.write(context2.linkedParamsNoMetadata.toString());
    buffer.write(''')  ''');
    buffer.writeln();
    buffer.write(__renderProperty_partial_accessor_setter_8_partial_features_1(
        context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_documentation_2(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderProperty_partial_accessor_setter_8_partial_source_code_3(
            context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_name_summary_0(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context2.name.toString());
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_features_1(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_documentation_2(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context2.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderProperty_partial_accessor_setter_8_partial_source_code_3(
    _i17.ContainerAccessor context2,
    _i9.Field context1,
    _i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context2.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderProperty_partial_footer_9(_i1.PropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderSidebarForContainer<T extends _i18.Documentable>(
    _i1.TemplateDataWithContainer<T> context0) {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderSidebarForLibrary<T extends _i18.Documentable>(
    _i1.TemplateDataWithLibrary<T> context0) {
  final buffer = StringBuffer();

  return buffer.toString();
}

String renderTopLevelProperty(_i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTopLevelProperty_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.name.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(
        _renderTopLevelProperty_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(
        _renderTopLevelProperty_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(
        _renderTopLevelProperty_partial_feature_set_3(context1, context0));
    buffer.writeln();
    if (context1.hasNoGetterSetter == true) {
      buffer.writeln();
      buffer.write(context1.modelType.linkedName.toString());
      buffer.write(' ');
      buffer.write(
          _renderTopLevelProperty_partial_name_summary_4(context1, context0));
      buffer.write('  ');
      buffer.writeln();
      buffer.write(
          _renderTopLevelProperty_partial_features_5(context1, context0));
      buffer.write('\n\n');
      buffer.write(
          _renderTopLevelProperty_partial_documentation_6(context1, context0));
      buffer.write('\n\n');
      buffer.write(
          _renderTopLevelProperty_partial_source_code_7(context1, context0));
    }
    buffer.writeln();
    if (context1.hasExplicitGetter == true) {
      buffer.writeln();
      buffer.write(_renderTopLevelProperty_partial_accessor_getter_8(
          context1, context0));
    }
    buffer.writeln();
    if (context1.hasExplicitSetter == true) {
      buffer.writeln();
      buffer.write(_renderTopLevelProperty_partial_accessor_setter_9(
          context1, context0));
    }
  }
  buffer.write('\n\n');
  buffer.write(_renderTopLevelProperty_partial_footer_10(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_head_0(
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_source_link_1(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_categorization_2(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_feature_set_3(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_name_summary_4(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name.toString());
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_features_5(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context1.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_documentation_6(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_source_code_7(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_accessor_getter_8(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  var context2 = context1.getter;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(context2.modelType.returnType.linkedName.toString());
    buffer.write(' ');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('  ');
    buffer.writeln();
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_features_1(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_documentation_2(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_getter_8_partial_source_code_3(
            context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_getter_8_partial_name_summary_0(
        _i17.Accessor context2,
        _i5.TopLevelVariable context1,
        _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context2.name.toString());
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_getter_8_partial_features_1(
    _i17.Accessor context2,
    _i5.TopLevelVariable context1,
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_getter_8_partial_documentation_2(
        _i17.Accessor context2,
        _i5.TopLevelVariable context1,
        _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context2.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_getter_8_partial_source_code_3(
    _i17.Accessor context2,
    _i5.TopLevelVariable context1,
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context2.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_accessor_setter_9(
    _i5.TopLevelVariable context1, _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  var context2 = context1.setter;
  if (context2 != null) {
    buffer.writeln();
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_name_summary_0(
            context2, context1, context0));
    buffer.write('''(''');
    buffer.write(context2.linkedParamsNoMetadata.toString());
    buffer.write(''')  ''');
    buffer.writeln();
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_features_1(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_documentation_2(
            context2, context1, context0));
    buffer.write('\n\n');
    buffer.write(
        __renderTopLevelProperty_partial_accessor_setter_9_partial_source_code_3(
            context2, context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_setter_9_partial_name_summary_0(
        _i17.Accessor context2,
        _i5.TopLevelVariable context1,
        _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.isConst == true) {
    buffer.write('''const ''');
  }
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context2.name.toString());
  if (context2.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_setter_9_partial_features_1(
    _i17.Accessor context2,
    _i5.TopLevelVariable context1,
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasFeatures == true) {
    buffer.write('''_''');
    buffer.write(context2.featuresAsString.toString());
    buffer.write('''_''');
  }
  buffer.writeln();

  return buffer.toString();
}

String
    __renderTopLevelProperty_partial_accessor_setter_9_partial_documentation_2(
        _i17.Accessor context2,
        _i5.TopLevelVariable context1,
        _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context2.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTopLevelProperty_partial_accessor_setter_9_partial_source_code_3(
    _i17.Accessor context2,
    _i5.TopLevelVariable context1,
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  if (context2.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context2.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTopLevelProperty_partial_footer_10(
    _i1.TopLevelPropertyTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

String renderTypedef(_i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(_renderTypedef_partial_head_0(context0));
  buffer.writeln();
  var context1 = context0.self;
  if (context1 != null) {
    buffer.writeln();
    buffer.write('''
# ''');
    buffer.write(context1.nameWithGenerics.toString());
    buffer.write(' ');
    buffer.writeEscaped(context1.kind.toString());
    buffer.write('\n\n');
    buffer.write(_renderTypedef_partial_source_link_1(context1, context0));
    buffer.writeln();
    buffer.write(_renderTypedef_partial_categorization_2(context1, context0));
    buffer.writeln();
    buffer.write(_renderTypedef_partial_feature_set_3(context1, context0));
  }
  buffer.writeln();
  var context2 = context0.typeDef;
  if (context2 != null) {
    buffer.writeln();
    buffer
        .write(_renderTypedef_partial_typedef_multiline_4(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderTypedef_partial_documentation_5(context2, context0));
    buffer.write('\n\n');
    buffer.write(_renderTypedef_partial_source_code_6(context2, context0));
  }
  buffer.write('\n\n');
  buffer.write(_renderTypedef_partial_footer_7(context0));
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_head_0(_i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.write(context0.customHeader.toString());
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_source_link_1(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceHref == true) {
    buffer.writeln();
    buffer.write('''
[view source](''');
    buffer.write(context1.sourceHref.toString());
    buffer.write(''')''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_categorization_2(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasCategoryNames == true) {
    buffer.writeln();
    buffer.write('''
Categories:''');
    var context2 = context1.displayedCategories;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write(context3.categoryLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_feature_set_3(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasFeatureSet == true) {
    var context2 = context1.displayedLanguageFeatures;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.write('\n    ');
        buffer.write(context3.featureLabel.toString());
      }
    }
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_typedef_multiline_4(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isCallable == true) {
    var context2 = context1.asCallable;
    if (context2 != null) {
      if (context2.hasAnnotations == true) {
        var context3 = context2.annotations;
        if (context3 != null) {
          for (var context4 in context3) {
            buffer.writeln();
            buffer.write('''
    - ''');
            buffer.write(context4.linkedNameWithParameters.toString());
          }
        }
      }
      buffer.write('\n\n    ');
      buffer.write(context2.modelType.returnType.linkedName.toString());
      buffer.write(' ');
      buffer.writeEscaped(context2.name.toString());
      buffer.write(context2.linkedGenericParameters.toString());
      buffer.write(''' = ''');
      buffer.write(context2.modelType.linkedName.toString());
    }
  }
  if (context1.isCallable != true) {
    buffer.write('\n  ');
    buffer.write(
        __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
            context1, context0));
  }
  buffer.writeln();

  return buffer.toString();
}

String __renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasAnnotations == true) {
    var context2 = context1.annotations;
    if (context2 != null) {
      for (var context3 in context2) {
        buffer.writeln();
        buffer.write('''
- ''');
        buffer.write(context3.linkedNameWithParameters.toString());
      }
    }
  }
  buffer.write('\n\n');
  buffer.write(
      ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
          context1, context0));
  buffer.write(context1.genericParameters.toString());
  buffer.write(''' = ''');
  buffer.write(context1.modelType.linkedName.toString());
  buffer.writeln();

  return buffer.toString();
}

String
    ___renderTypedef_partial_typedef_multiline_4_partial_type_multiline_0_partial_name_summary_0(
        _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.isConst == true) {
    buffer.write('''const ''');
  }
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeEscaped(context1.name.toString());
  if (context1.isDeprecated == true) {
    buffer.write('''~~''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_documentation_5(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasDocumentation == true) {
    buffer.writeln();
    buffer.write(context1.documentationAsHtml.toString());
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_source_code_6(
    _i7.Typedef context1, _i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  if (context1.hasSourceCode == true) {
    buffer.writeln();
    buffer.write('''
## Implementation

```dart
''');
    buffer.write(context1.sourceCode.toString());
    buffer.writeln();
    buffer.write('''
```''');
  }
  buffer.writeln();

  return buffer.toString();
}

String _renderTypedef_partial_footer_7(_i1.TypedefTemplateData context0) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.write(context0.customInnerFooter.toString());
  buffer.writeln();
  buffer.write(context0.customFooter.toString());
  buffer.writeln();

  return buffer.toString();
}

extension on StringBuffer {
  void writeEscaped(String value) {
    write(_i19.htmlEscape.convert(value));
  }
}
