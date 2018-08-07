import 'dart:mirrors' as mirrors;

const USE_MIRRORS = const bool.fromEnvironment('MIRRORS', defaultValue: true);

Reflection reflect(o, {bool useMirrors: USE_MIRRORS}) {
  if (o is Map) {
    return new MapReflection(o);
  }
  if (useMirrors && USE_MIRRORS) {
    return new Mirror(o, mirrors.reflect(o));
  }

  // in any other case fallback to a mirrorless reflection
  return new Reflection(o);
}

class Reflection {
  final dynamic object;

  Reflection(this.object);

  Field field(String name) {
    return new _BracketsField(object, name);
  }
}

class Field {
  bool get exists {
    return false;
  }

  dynamic val() => null;
}

class MapReflection extends Reflection {
  final Map map;

  MapReflection(map)
      : this.map = map,
        super(map);

  Field field(String name) {
    if (map.containsKey(name)) {
      return new _BracketsField(map, name, existingKey: true);
    }
    return _noField;
  }
}

final _noField = new Field();

final _bracketsOperator = new Symbol("[]");

class Mirror extends Reflection {
  final mirrors.InstanceMirror instanceMirror;

  Mirror(object, this.instanceMirror) : super(object);

  Field field(String name) {
    final Map<Symbol, mirrors.MethodMirror> members =
        _instanceMembers(instanceMirror);
    if (_isStringAssignableToBracketsOperator(members)) {
      return new _BracketsField(object, name);
    }
    final methodMirror = members[new Symbol(name)];
    if (methodMirror == null) {
      return _noField;
    }
    return new _MethodMirrorField(this.instanceMirror, methodMirror);
  }
}

Map<Symbol, mirrors.MethodMirror> _instanceMembers(mirrors.InstanceMirror m) {
  if (m != null && m.type != null) {
    return m.type.instanceMembers;
  }
  return null;
}

_isStringAssignableToBracketsOperator(
    Map<Symbol, mirrors.MethodMirror> members) {
  if (!members.containsKey(_bracketsOperator)) {
    return false;
  }
  try {
    mirrors.MethodMirror m = members[_bracketsOperator];
    return mirrors.reflectType(String).isAssignableTo(m.parameters[0].type);
  } catch (e) {
    return false;
  }
}

class _MethodMirrorField extends Field {
  final mirrors.InstanceMirror instance;
  final mirrors.MethodMirror method;

  _MethodMirrorField(this.instance, this.method);

  bool get exists => isVariable || isGetter || isLambda;

  bool get isGetter => method.isGetter;

  bool get isVariable => method is mirrors.VariableMirror;

  bool get isLambda => method.parameters.length >= 0;

  val() {
    if (!exists) {
      return null;
    }
    final resultMirror = instance.getField(method.simpleName);
    return resultMirror.reflectee;
  }
}

const Object empty = const Object();

class _BracketsField extends Field {
  final dynamic objectWithBracketsOperator;
  final String key;
  final bool existingKey;
  var value;

  _BracketsField(this.objectWithBracketsOperator, this.key,
      {this.existingKey: false}) {
    this.value = empty;
  }

  bool get exists => existingKey || val() != null;

  val() {
    if (value == empty) {
      try {
        value = objectWithBracketsOperator[key];
      } catch (e) {
        value = null;
      }
    }
    return value;
  }
}
