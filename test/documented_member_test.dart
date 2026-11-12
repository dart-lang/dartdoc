// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:test/test.dart';
import 'package:test_descriptor/test_descriptor.dart' as d;
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(DocumentedMemberTest);
  });
}

/// Tests that a doc comment reference to a member links to the page where the
/// member is documented, also when the member is declared in a class that has
/// no page.
@reflectiveTest
class DocumentedMemberTest extends DartdocTestBase {
  @override
  String get libraryName => 'documented';

  void test_declaredInPublicClass_linksToDeclaration() async {
    var library = await bootPackageWithLibrary('''
class Base {
  /// The builder.
  int get itemBuilder => 0;
}

class Public extends Base {}

/// See [Public.itemBuilder].
class User {}
''');
    var user = library.classes.named('User');
    var result = getMatchingLinkElement('Public.itemBuilder', user);
    // The declaration has a page; the reference links to it.
    expect(result.referable?.href, contains('Base/itemBuilder.html'));
  }

  void test_declaredInPrivateClass_linksToNamedClass() async {
    var library = await bootPackageWithLibrary('''
abstract class _Base {
  /// The builder.
  int get itemBuilder => 0;

  /// Marks.
  void markNeedsClip() {}
}

class Public extends _Base {}

class Other extends _Base {}

/// See [Public.itemBuilder] and [Other.markNeedsClip].
class User {}
''');
    var user = library.classes.named('User');
    // The declaring class has no page. The members are documented on the
    // public classes that inherit them; the class named in the reference
    // decides which.
    var itemBuilder = getMatchingLinkElement('Public.itemBuilder', user);
    expect(itemBuilder.referable?.href, contains('Public/itemBuilder.html'));
    var markNeedsClip = getMatchingLinkElement('Other.markNeedsClip', user);
    expect(markNeedsClip.referable?.href, contains('Other/markNeedsClip.html'));
  }

  void test_declaredInPrivateClass_unqualified_linksToEnclosingClass() async {
    var library = await bootPackageWithLibrary('''
abstract class _Base {
  void helper() {}
}

class Public extends _Base {
  /// Calls [helper].
  void m() {}
}
''');
    var m = library.classes.named('Public').instanceMethods.named('m');
    var result = getMatchingLinkElement('helper', m);
    expect(result.referable?.href, contains('Public/helper.html'));
  }

  void test_declaredInPrivateClass_overriddenByNamedClass() async {
    var library = await bootPackageWithLibrary('''
abstract class _Hooks {
  void addCallback() {}

  void removeCallback() {}
}

class Dispatcher extends _Hooks {
  @override
  void removeCallback() {}
}

/// See [Dispatcher.removeCallback].
class User {}
''');
    var user = library.classes.named('User');
    var result = getMatchingLinkElement('Dispatcher.removeCallback', user);
    expect(result.referable?.href, contains('Dispatcher/removeCallback.html'));
  }

  void test_declaredInPrivateClass_field() async {
    var library = await bootPackageWithLibrary('''
abstract class _Base {
  /// The count.
  final int count = 0;
}

class Public extends _Base {}

/// See [Public.count].
class User {}
''');
    var user = library.classes.named('User');
    var result = getMatchingLinkElement('Public.count', user);
    expect(result.referable?.href, contains('Public/count.html'));
  }

  void test_qualifierIsTypedef_linksToAliasedClass() async {
    var library = await bootPackageWithLibrary('''
abstract class _Base {
  void helper() {}
}

class Public extends _Base {}

typedef Alias = Public;

/// See [Alias.helper].
class User {}
''');
    var user = library.classes.named('User');
    // A typedef qualifier names the class it aliases.
    var result = getMatchingLinkElement('Alias.helper', user);
    expect(result.referable?.href, contains('Public/helper.html'));
  }

  void test_declaredInPrivateClass_noDocumentedClass_noLink() async {
    var library = await bootPackageWithLibrary('''
abstract class _Base {
  void helper() {}
}

/// Not a subclass; see [_Base.helper].
class User {}
''');
    var user = library.classes.named('User');
    var result = getMatchingLinkElement('_Base.helper', user);
    // Nothing with a page has this member.
    expect(result.referable?.href, isNull);
  }

  void test_extensionMemberInUndocumentedLibrary_noLink() async {
    var library = await bootPackageWithLibrary('''
import 'src/ext.dart';

class Public {
  /// The class's own helper.
  void helper() {}

  /// See [Ext.helper].
  void m() {}
}
''', extraFiles: [
      d.dir('lib', [
        d.dir('src', [
          d.file('ext.dart', '''
import '../library.dart';

extension Ext on Public {
  void helper() {}
}
'''),
        ]),
      ]),
    ]);
    var m = library.classes.named('Public').instanceMethods.named('m');
    var result = getMatchingLinkElement('Ext.helper', m);
    // `Ext` has no page; the reference must not be redirected to the class's
    // own member of the same name.
    expect(result.referable?.href, isNull);
  }
}
