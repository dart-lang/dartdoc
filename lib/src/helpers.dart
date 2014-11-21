library dartdoc.helpers;

import 'package:analyzer/src/generated/element.dart';

import 'model_utils.dart';
import 'utils.dart';

class LibraryHelper {
  LibraryElement library;

  LibraryHelper(this.library);

  List<VariableHelper> getVariables() {
    List<TopLevelVariableElement> variables = [];

    variables.addAll(library.definingCompilationUnit.topLevelVariables);
    for (CompilationUnitElement cu in library.parts) {
      variables.addAll(cu.topLevelVariables);
    }

    variables..removeWhere(isPrivate)..sort(elementCompare);

    return variables.map((e) => new VariableHelper(e)).toList();
  }

  List<AccessorHelper> getAccessors() {
    List<PropertyAccessorElement> accessors = [];

    accessors.addAll(library.definingCompilationUnit.accessors);
    for (CompilationUnitElement cu in library.parts) {
      accessors.addAll(cu.accessors);
    }

    accessors..removeWhere(isPrivate)..sort(elementCompare);
    accessors.removeWhere((e) => e.isSynthetic);

    return accessors.map((e) => new AccessorHelper(e)).toList();
  }

  List<TypedefHelper> getTypedefs() {
    List<FunctionTypeAliasElement> functions = [];

    functions.addAll(library.definingCompilationUnit.functionTypeAliases);
    for (CompilationUnitElement cu in library.parts) {
      functions.addAll(cu.functionTypeAliases);
    }

    functions..removeWhere(isPrivate)..sort(elementCompare);

    return functions.map((e) => new TypedefHelper(e)).toList();
  }

  List<FunctionHelper> getFunctions() {
    List<FunctionElement> functions = [];

    functions.addAll(library.definingCompilationUnit.functions);
    for (CompilationUnitElement cu in library.parts) {
      functions.addAll(cu.functions);
    }

    functions..removeWhere(isPrivate)..sort(elementCompare);

    return functions.map((e) => new FunctionHelper(e)).toList();
  }

  List<ClassHelper> getTypes() {
    List<ClassElement> types = [];

    types.addAll(library.definingCompilationUnit.types);
    for (CompilationUnitElement cu in library.parts) {
      types.addAll(cu.types);
    }

    types..removeWhere(isPrivate)..sort(elementCompare);

    return types.map((e) => new ClassHelper(e)).toList();
  }
}

abstract class ElementHelper {
  Element element;

  ElementHelper(this.element);

  String get typeName;

  String createLinkedSummary(Generator generator) {
    return generator.createLinkedName(element);
  }

  String createLinkedDescription(Generator generator);
}

class ClassHelper extends ElementHelper {

  ClassHelper(ClassElement element): super(element);

  String get typeName => 'Classes';

  ClassElement get _cls => element as ClassElement;

  String createLinkedDescription(Generator generator) {
    return '';
  }

  List<FieldElement> _getAllfields() {
    return _cls.fields.toList()..removeWhere(isPrivate)..sort(elementCompare);
  }

  List<FieldHelper> getStaticFields() {
    List<FieldElement> fields = _getAllfields()..removeWhere((e) => !isStatic(e));
    return fields.map((e) => new StaticFieldHelper(e)).toList();
  }

  List<FieldHelper> getInstanceFields() {
    List<FieldElement> fields = _getAllfields()..removeWhere(isStatic);
    return fields.map((e) => new FieldHelper(e)).toList();
  }

  List<AccessorHelper> getAccessors() {
    List<PropertyAccessorElement> accessors =
        _cls.accessors.toList()..removeWhere(isPrivate)..sort(elementCompare);
    accessors.removeWhere((e) => e.isSynthetic);
    return accessors.map((e) => new AccessorHelper(e)).toList();
  }

  List<ConstructorHelper> getCtors() {
    List<ConstructorElement> c = _cls.constructors.toList()..removeWhere(isPrivate)..sort(elementCompare);
    return c.map((e) => new ConstructorHelper(e)).toList();
  }

  List<MethodHelper> getMethods() {
    List<MethodElement> m = _cls.methods.toList()..removeWhere(isPrivate)..sort(elementCompare);
    return m.map((e) => new MethodHelper(e)).toList();
  }
}

abstract class PropertyInducingHelper extends ElementHelper {
  PropertyInducingHelper(PropertyInducingElement element): super(element);

  PropertyInducingElement get _var => (element as PropertyInducingElement);

  String createLinkedSummary(Generator generator) {
    StringBuffer buf = new StringBuffer();

    buf.write('${generator.createLinkedName(_var)}');

    String type = generator.createLinkedName(_var.type == null ? null : _var.type.element);

    if (!type.isEmpty) {
      buf.write(': $type');
    }

    return buf.toString();
  }

  String createLinkedDescription(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_var.isStatic) {
      buf.write('static ');
    }
    if (_var.isFinal) {
      buf.write('final ');
    }
    if (_var.isConst) {
      buf.write('const ');
    }

    buf.write(generator.createLinkedName(_var.type == null ? null : _var.type.element));
    buf.write(' ${_var.name}');

    // write out any constant value
    Object value = getConstantValue(_var);

    if (value != null) {
      if (value is String) {
        String str = stringEscape(value, "'");
        buf.write(" = '${str}'");
      } else if (value is num) {
        buf.write(" = ${value}");
      }
      //NumberFormat.decimalPattern
    }

    return buf.toString();
  }
}

class VariableHelper extends PropertyInducingHelper {
  VariableHelper(TopLevelVariableElement element): super(element);

  String get typeName => 'Top-Level Variables';
}

class FieldHelper extends PropertyInducingHelper {
  FieldHelper(FieldElement element): super(element);

  String get typeName => 'Fields';
}

class StaticFieldHelper extends PropertyInducingHelper {
  StaticFieldHelper(FieldElement element): super(element);

  String get typeName => 'Static Fields';
}

class AccessorHelper extends ElementHelper {
  AccessorHelper(PropertyAccessorElement element): super(element);

  String get typeName => 'Getters and Setters';

  PropertyAccessorElement get _acc => (element as PropertyAccessorElement);

  String createLinkedSummary(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_acc.isGetter) {
      buf.write(generator.createLinkedName(element));
      buf.write(': ');
      buf.write(generator.createLinkedReturnTypeName(_acc.type));
    } else {
      buf.write('${generator.createLinkedName(element)}('
          '${generator.printParams(_acc.parameters)})');
    }

    return buf.toString();
  }

  String createLinkedDescription(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_acc.isStatic) {
      buf.write('static ');
    }

    if (_acc.isGetter) {
      buf.write('${generator.createLinkedReturnTypeName(_acc.type)} get ${_acc.name}');
    } else {
      buf.write('set ${_acc.name}(${generator.printParams(_acc.parameters)})');
    }

    return buf.toString();
  }
}

class FunctionHelper extends ElementHelper {
  FunctionHelper(FunctionElement element): super(element);

  String get typeName => 'Functions';

  FunctionElement get _func => (element as FunctionElement);

  String createLinkedSummary(Generator generator) {
    String retType = generator.createLinkedReturnTypeName(_func.type);

    return '${generator.createLinkedName(element)}'
        '(${generator.printParams(_func.parameters)})'
        '${retType.isEmpty ? '' : ': $retType'}';
  }

  String createLinkedDescription(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_func.isStatic) {
      buf.write('static ');
    }

    buf.write(generator.createLinkedReturnTypeName(_func.type));
    buf.write(' ${_func.name}(${generator.printParams(_func.parameters)})');

    return buf.toString();
  }
}

class TypedefHelper extends ElementHelper {
  TypedefHelper(FunctionTypeAliasElement element): super(element);

  String get typeName => 'Typedefs';

  FunctionTypeAliasElement get _typedef => (element as FunctionTypeAliasElement);

  String createLinkedSummary(Generator generator) {
    // Comparator<T>(T a, T b): int
    StringBuffer buf = new StringBuffer();

    buf.write(generator.createLinkedName(element));
    if (!_typedef.typeParameters.isEmpty) {
      buf.write('&lt;');
      for (int i = 0; i < _typedef.typeParameters.length; i++) {
        if (i > 0) {
          buf.write(', ');
        }
        buf.write(_typedef.typeParameters[i].name);
      }
      buf.write('&gt;');
    }
    buf.write('(${generator.printParams(_typedef.parameters)}): ');
    buf.write(generator.createLinkedReturnTypeName(_typedef.type));

    return buf.toString();
  }

  String createLinkedDescription(Generator generator) {
    // typedef int Comparator<T>(T a, T b)

    StringBuffer buf = new StringBuffer();

    buf.write('typedef ${generator.createLinkedReturnTypeName(_typedef.type)} ${_typedef.name}');
    if (!_typedef.typeParameters.isEmpty) {
      buf.write('&lt;');
      for (int i = 0; i < _typedef.typeParameters.length; i++) {
        if (i > 0) {
          buf.write(', ');
        }
        buf.write(_typedef.typeParameters[i].name);
      }
      buf.write('&gt;');
    }
    buf.write('(${generator.printParams(_typedef.parameters)}): ');

    return buf.toString();
  }
}

abstract class ExecutableHelper extends ElementHelper {
  ExecutableHelper(ExecutableElement element): super(element);

  ExecutableElement get _ex => (element as ExecutableElement);

  String createLinkedSummary(Generator generator) {
    String retType = generator.createLinkedReturnTypeName(_ex.type);

    return '${generator.createLinkedName(element)}'
        '(${generator.printParams(_ex.parameters)})'
        '${retType.isEmpty ? '' : ': $retType'}';
  }

  String createLinkedDescription(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_ex.isStatic) {
      buf.write('static ');
    }

    buf.write(generator.createLinkedReturnTypeName(_ex.type));
    buf.write(' ${_ex.name}(${generator.printParams(_ex.parameters)})');

    return buf.toString();
  }
}

class ConstructorHelper extends ExecutableHelper {
  ConstructorHelper(ConstructorElement element): super(element);

  String get typeName => 'Constructors';

  ConstructorElement get _ctor => (element as ConstructorElement);

  String createLinkedSummary(Generator generator) {
    return '${generator.createLinkedName(element)}'
        '(${generator.printParams(_ex.parameters)})';
  }

  String createLinkedDescription(Generator generator) {
    StringBuffer buf = new StringBuffer();

    if (_ex.isStatic) {
      buf.write('static ');
    }
    if (_ctor.isFactory) {
      buf.write('factory ');
    }

    buf.write('${_ctor.type.returnType.name}${_ctor.name.isEmpty?'':'.'}'
        '${_ctor.name}(${generator.printParams(_ex.parameters)})');

    return buf.toString();
  }
}

class MethodHelper extends ExecutableHelper {
  MethodHelper(MethodElement element): super(element);

  String get typeName => 'Methods';
}

bool isStatic(PropertyInducingElement e) => e.isStatic;

bool isPrivate(Element e) => e.name.startsWith('_');

int elementCompare(Element a, Element b) => a.name.compareTo(b.name);

abstract class Generator {
  String createLinkedName(Element e, [bool appendParens = false]);
  String createLinkedReturnTypeName(FunctionType type);
  String createLinkedTypeName(DartType type);
  String printParams(List<ParameterElement> params);
  String createHrefFor(Element e);
  bool isDocumented(Element e);
}
