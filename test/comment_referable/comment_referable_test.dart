// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.comment_reference_test;

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/model_element_builder.dart';
import 'package:dartdoc/src/model/nameable.dart';
import 'package:test/test.dart';

const _separator = '.';

abstract class Base extends Nameable with CommentReferable {
  @override
  ModelElementBuilder get modelBuilder =>
      throw UnimplementedError('not needed for this test');

  List<Base> children;

  Base parent;

  /// Utility function to quickly build structures similar to [ModelElement]
  /// hierarchies in dartdoc in tests.
  /// Returns the added (or already existing) [Base].
  Base add(String newName);

  T lookup<T extends CommentReferable>(String value,
          {bool Function(CommentReferable) allowTree,
          bool Function(CommentReferable) filter}) =>
      referenceBy(value.split(_separator),
          allowTree: allowTree, filter: filter);

  @override
  Element get element => throw UnimplementedError();

  @override
  Iterable<CommentReferable> get referenceGrandparentOverrides => null;
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
    var parent = children.firstWhere((c) => c.name == newNameSplit.first,
        orElse: () => null);
    if (parent == null) {
      parent = TopChild(newNameSplit.last, [], this);
      children.add(parent);
      retval = parent;
    }
    if (newNameSplit.length > 1) {
      retval = parent.add(newNameSplit.sublist(1).join(_separator));
    }
    return retval;
  }

  @override
  Map<String, CommentReferable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<CommentReferable> get referenceParents => [];
}

abstract class Child extends Base {
  @override
  List<Child> get children;

  @override
  Base add(String newName) {
    Base retval;
    var newNameSplit = newName.split(_separator).toList();
    var child = children.firstWhere((c) => c.name == newNameSplit.first,
        orElse: () => null);
    if (child == null) {
      child = GenericChild(newNameSplit.last, [], this);
      children.add(child);
      retval = child;
    }
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
  @override
  final Top parent;

  TopChild(this.name, this.children, this.parent);

  @override
  Map<String, CommentReferable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<CommentReferable> get referenceParents => [parent];
}

class GenericChild extends Child {
  @override
  final String name;
  @override
  final List<GenericChild> children;
  @override
  final Base parent;

  GenericChild(this.name, this.children, this.parent);

  @override
  Map<String, CommentReferable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<CommentReferable> get referenceParents => [parent];
}

class GrandparentOverrider extends GenericChild {
  @override
  final Iterable<Base> referenceGrandparentOverrides;

  GrandparentOverrider(String name, List<GenericChild> children, Base parent,
      this.referenceGrandparentOverrides)
      : super(name, children, parent);
}

void main() {
  group('Basic comment reference lookups', () {
    Top referable;

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
      expect(referable.lookup('lib1').name, equals('lib1'));
      expect(referable.lookup('lib2').name, equals('lib2'));
      expect(referable.lookup('lib1.class2.member1').name, equals('member1'));
      expect(referable.lookup('lib2.class3').name, equals('class3'));
    });

    test('Check that filters work', () {
      expect(referable.lookup('lib3'), isA<TopChild>());
      expect(referable.lookup('lib3', filter: ((r) => r is GenericChild)),
          isA<GenericChild>());
    });

    test('Check that allowTree works', () {
      referable.add('lib4');
      var lib4lib4 = referable.add('lib4.lib4');
      var tooDeepSub1 = referable.add('lib4.lib4.sub1');
      var sub1 = referable.add('lib4.sub1');
      var sub2 = referable.add('lib4.sub2');
      expect(sub2.lookup('lib4.lib4'), equals(lib4lib4));
      expect(sub2.lookup('lib4.sub1'), equals(tooDeepSub1));
      expect(
          sub2.lookup('lib4.sub1',
              allowTree: ((r) => r is Base && (r.parent is Top))),
          equals(sub1));
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
