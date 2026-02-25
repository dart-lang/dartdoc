// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// @docImport 'package:dartdoc/src/model/model_element.dart';
library;

import 'package:collection/collection.dart';
import 'package:dartdoc/src/model/package_graph.dart';
import 'package:dartdoc/src/model/referable.dart';
import 'package:test/test.dart';

const _separator = '.';

abstract class Base with Referable {
  @override
  PackageGraph get packageGraph => throw UnimplementedError();

  List<Base> get children;

  Base? parent;

  /// Utility function to quickly build structures similar to [ModelElement]
  /// hierarchies in dartdoc in tests.
  /// Returns the added (or already existing) [Base].
  Base add(String newName);

  Referable? lookup<T extends Referable?>(
    String value, {
    bool Function(Referable?)? filter,
  }) {
    return referenceBy(value.split(_separator), filter: filter ?? (_) => true);
  }

  @override
  Iterable<Referable>? get referenceGrandparentOverrides => null;
}

class Top extends Base {
  @override
  final String name;
  @override
  final List<TopChild> children;

  Top(this.name, this.children);

  @override
  Base add(String newName) {
    Base retval;
    var newNameSplit = newName.split(_separator).toList();
    var parent = children.firstWhereOrNull((c) => c.name == newNameSplit.first);
    if (parent == null) {
      parent = TopChild(newNameSplit.last, [], this);
      children.add(parent);
      retval = parent;
    }
    retval = parent;
    if (newNameSplit.length > 1) {
      retval = parent.add(newNameSplit.sublist(1).join(_separator));
    }
    return retval;
  }

  @override
  Map<String, Referable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<Referable> get referenceParents => [];
}

abstract class Child extends Base {
  @override
  List<Child> get children;

  @override
  Base add(String newName) {
    Base retval;
    var newNameSplit = newName.split(_separator).toList();
    var child = children.firstWhereOrNull((c) => c.name == newNameSplit.first);
    if (child == null) {
      child = GenericChild(newNameSplit.last, [], this);
      children.add(child);
    }

    retval = child;
    if (newNameSplit.length > 1) {
      retval = child.add(newNameSplit.sublist(1).join(_separator));
    }
    return retval;
  }
}

class TopChild extends Child {
  @override
  final String name;
  @override
  final List<GenericChild> children;
  final Top _parent;
  @override
  Top get parent => _parent;

  TopChild(this.name, this.children, this._parent);

  @override
  Map<String, Referable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<Referable> get referenceParents => [parent];
}

class GenericChild extends Child {
  @override
  final String name;
  @override
  final List<GenericChild> children;
  final Base _parent;
  @override
  Base get parent => _parent;

  GenericChild(this.name, this.children, this._parent);

  @override
  Map<String, Referable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<Referable> get referenceParents => [parent];
}

class GrandparentOverrider extends GenericChild {
  @override
  final Iterable<Base> referenceGrandparentOverrides;

  GrandparentOverrider(super.name, super.children, super.parent,
      this.referenceGrandparentOverrides);
}

void main() {
  group('Basic comment reference lookups', () {
    late Top referable;

    setUp(() {
      referable = Top('top', []);
      referable.add('lib1');
      referable.add('lib2');
      referable.add('lib3');
      referable.add('lib1.class1');
      referable.add('lib1.class2');
      referable.add('lib1.class2.member1');
      referable.add('lib2');
      referable.add('lib2.class3');
      referable.add('lib3.lib3.lib3');
    });

    test('Check that basic lookups work', () {
      expect(referable.lookup('lib1')?.name, equals('lib1'));
      expect(referable.lookup('lib2')?.name, equals('lib2'));
      expect(referable.lookup('lib1.class2.member1')?.name, equals('member1'));
      expect(referable.lookup('lib2.class3')?.name, equals('class3'));
    });

    test('Check that filters work', () {
      expect(referable.lookup('lib3'), isA<TopChild>());
      expect(referable.lookup('lib3', filter: (r) => r is GenericChild),
          isA<GenericChild>());
    });

    test('Check that grandparent overrides work', () {
      referable.add('lib4');
      var i1 = referable.add('lib4.intermediate1');
      var i1target = referable.add('lib4.intermediate1.target');
      referable.add('lib4.intermediate2');
      var i2target = referable.add('lib4.intermediate2.target');
      var i2other = referable.add('lib4.intermediate2.other');
      var i2notFromHere = referable.add('lib4.intermediate2.notFromHere');
      var overrider = GrandparentOverrider('fromHere', [], i2other, [i1]);
      i2other.children.add(overrider);
      expect(i2notFromHere.lookup('target'), i2target);
      // Ordinarily, since overrider's parent is i2target, we would expect this
      // to work the same.  But it has an override.
      expect(overrider.lookup('target'), i1target);
      expect(overrider.lookup('intermediate2.target'), i2target);
    });
  });
}
