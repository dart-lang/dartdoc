// Copyright (c) 2020, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.comment_reference_test;

import 'package:analyzer/dart/element/element.dart';
import 'package:dartdoc/src/model/comment_referable.dart';
import 'package:dartdoc/src/model/nameable.dart';
import 'package:test/test.dart';

const SEPARATOR = '.';

abstract class Base extends Nameable with CommentReferable {
  /// Utility function to quickly build structures similar to [ModelElement]
  /// hierarchies in dartdoc in tests.
  /// Returns the added (or already existing) [Base].
  Base add(String newName);

  Base lookup(String value) => referenceBy(value.split(SEPARATOR));

  @override
  Element get element => throw UnimplementedError();
}

class Top extends Base {
  @override
  final String name;
  final List<TopChild> children;

  Top(this.name, this.children);

  @override
  Base add(String newName) {
    Base retval;
    var newNameSplit = newName.split(SEPARATOR).toList();
    var parent = children.firstWhere((c) => c.name == newNameSplit.first,
        orElse: () => null);
    if (parent == null) {
      parent = TopChild(newNameSplit.last, [], this);
      children.add(parent);
      retval = parent;
    }
    if (newNameSplit.length > 1) {
      retval = parent.add(newNameSplit.sublist(1).join(SEPARATOR));
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
  List<Child> get children;

  @override
  Base add(String newName) {
    Base retval;
    var newNameSplit = newName.split(SEPARATOR).toList();
    var child = children.firstWhere((c) => c.name == newNameSplit.first,
        orElse: () => null);
    if (child == null) {
      child = GenericChild(newNameSplit.last, [], this);
      children.add(child);
      retval = child;
    }
    if (newNameSplit.length > 1) {
      retval = child.add(newNameSplit.sublist(1).join(SEPARATOR));
    }
    return retval;
  }
}

class TopChild extends Child {
  @override
  final String name;
  @override
  final List<GenericChild> children;
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
  final Base parent;

  GenericChild(this.name, this.children, this.parent);

  @override
  Map<String, CommentReferable> get referenceChildren =>
      Map.fromEntries(children.map((c) => MapEntry(c.name, c)));

  @override
  Iterable<CommentReferable> get referenceParents => [parent];
}

void main() {
  group('Basic comment reference lookups', () {
    Top referable;

    setUpAll(() {
      referable = Top('top', []);
      referable.add('lib1');
      referable.add('lib2');
      referable.add('lib3');
      referable.add('lib1.class1');
      referable.add('lib1.class2');
      referable.add('lib1.class2.member1');
      referable.add('lib2');
      referable.add('lib2.class3');
    });

    test('Check that basic lookups work', () {
      expect(referable.lookup('lib1').name, equals('lib1'));
      expect(referable.lookup('lib2').name, equals('lib2'));
      expect(referable.lookup('lib1.class2.member1').name, equals('member1'));
      expect(referable.lookup('lib2.class3').name, equals('class3'));
    });
  });
}
