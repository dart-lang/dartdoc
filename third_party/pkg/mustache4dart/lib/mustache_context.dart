library mustache_context;

import 'dart:collection';

import 'package:mustache4dart/src/mirrors.dart';

const String DOT = '\.';

typedef NoParamLambda();
typedef OptionalParamLambda({nestedContext});
typedef TwoParamLambda(String s, {nestedContext});

abstract class MustacheContext {
  factory MustacheContext(ctx,
      {MustacheContext parent, assumeNullNonExistingProperty: true}) {
    return _createMustacheContext(ctx,
        parent: parent,
        assumeNullNonExistingProperty: assumeNullNonExistingProperty);
  }

  get ctx;

  value([arg]);

  bool get isFalsey;

  bool get isLambda;

  MustacheContext field(String key);

  MustacheContext _getMustacheContext(String key);
}

_createMustacheContext(obj,
    {MustacheContext parent, bool assumeNullNonExistingProperty}) {
  if (obj is Iterable) {
    return new _IterableMustacheContextDecorator(obj,
        parent: parent,
        assumeNullNonExistingProperty: assumeNullNonExistingProperty);
  }
  if (obj == false) {
    return falseyContext;
  }
  return new _MustacheContext(obj,
      parent: parent,
      assumeNullNonExistingProperty: assumeNullNonExistingProperty);
}

final falseyContext = new _MustacheContext(false);

class _MustacheContext implements MustacheContext {
  final ctx;
  final _MustacheContext parent;
  final bool assumeNullNonExistingProperty;
  Reflection _ctxReflection;

  _MustacheContext(this.ctx,
      {_MustacheContext this.parent, this.assumeNullNonExistingProperty});

  bool get isLambda => ctx is Function;

  bool get isFalsey => ctx == null || ctx == false;

  value([arg]) => isLambda ? callLambda(arg) : ctx.toString();

  callLambda(arg) {
    if (ctx is NoParamLambda) {
      return ctx is OptionalParamLambda ? ctx(nestedContext: this) : ctx();
    }
    if (ctx is TwoParamLambda) {
      return ctx(arg, nestedContext: this);
    }
    return ctx(arg);
  }

  MustacheContext field(String key) {
    if (ctx == null) return null;
    return _getInThisOrParent(key);
  }

  MustacheContext _getInThisOrParent(String key) {
    var result = _getContextForKey(key);
    //if the result is null, try the parent context

    if (result == null) {
      final hasSlot = ctxReflector.field(key).exists;
      if (!assumeNullNonExistingProperty && !hasSlot && parent == null) {
        throw new StateError('Could not find "$key" in given context');
      }

      //if the result is null, try the parent context
      if (!hasSlot && parent != null) {
        result = parent.field(key);
        if (result != null) {
          return _createChildMustacheContext(result.ctx);
        }
      }
    }
    return result;
  }

  MustacheContext _getContextForKey(String key) {
    if (key == DOT) {
      return this;
    }
    if (key.contains(DOT)) {
      final Iterator<String> i = key.split(DOT).iterator;
      MustacheContext val = this;
      while (i.moveNext()) {
        val = val._getMustacheContext(i.current);
        if (val == null) {
          return null;
        }
      }
      return val;
    }
    //else
    return _getMustacheContext(key);
  }

  MustacheContext _getMustacheContext(String fieldName) {
    final v = ctxReflector.field(fieldName).val();
    return _createChildMustacheContext(v);
  }

  _createChildMustacheContext(obj) {
    if (obj == null) {
      return null;
    }
    return _createMustacheContext(obj,
        parent: this,
        assumeNullNonExistingProperty: this.assumeNullNonExistingProperty);
  }

  Reflection get ctxReflector {
    if (_ctxReflection == null) {
      _ctxReflection = reflect(ctx);
    }
    return _ctxReflection;
  }
}

class _IterableMustacheContextDecorator extends IterableBase<_MustacheContext>
    implements MustacheContext {
  final Iterable ctx;
  final _MustacheContext parent;
  final bool assumeNullNonExistingProperty;

  _IterableMustacheContextDecorator(this.ctx,
      {this.parent, this.assumeNullNonExistingProperty});

  value([arg]) =>
      throw new Exception('Iterable can not be called as a function');

  Iterator<_MustacheContext> get iterator =>
      new _MustacheContextIteratorDecorator(ctx.iterator,
          parent: parent,
          assumeNullNonExistingProperty: assumeNullNonExistingProperty);

  int get length => ctx.length;

  bool get isEmpty => ctx.isEmpty;

  bool get isFalsey => isEmpty;

  bool get isLambda => false;

  field(String key) {
    assert(key ==
        DOT); // 'Iterable can only be iterated. No [] implementation is available'
    return this;
  }

  _getMustacheContext(String key) {
    // 'Iterable can only be asked for empty or isEmpty keys or be iterated'
    assert(key == 'empty' || key == 'isEmpty');
    return new _MustacheContext(isEmpty,
        parent: parent,
        assumeNullNonExistingProperty: assumeNullNonExistingProperty);
  }
}

class _MustacheContextIteratorDecorator extends Iterator<_MustacheContext> {
  final Iterator delegate;
  final _MustacheContext parent;
  final bool assumeNullNonExistingProperty;

  _MustacheContext current;

  _MustacheContextIteratorDecorator(this.delegate,
      {this.parent, this.assumeNullNonExistingProperty});

  bool moveNext() {
    if (delegate.moveNext()) {
      current = new _MustacheContext(delegate.current,
          parent: parent,
          assumeNullNonExistingProperty: assumeNullNonExistingProperty);
      return true;
    } else {
      current = null;
      return false;
    }
  }
}
