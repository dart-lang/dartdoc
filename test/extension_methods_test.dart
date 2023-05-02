// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/markdown_processor.dart';
import 'package:dartdoc/src/model/extension.dart';
import 'package:dartdoc/src/model/method.dart';
import 'package:dartdoc/src/model/model_element.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    if (classModifiersAllowed) {
      defineReflectiveTests(ExtensionMethodsTest);
    }
  });
}

@reflectiveTest
class ExtensionMethodsTest extends DartdocTestBase {
  @override
  String get libraryName => 'extension_methods';

  static const String reexportedContent = '''
class AClassNotNeedingExtending {}

class AClassNeedingExtending {}

extension AnExtension on AClassNeedingExtending {
  void aMethod() {}
}
''';

  static const String libraryContent = '''
/// This is an amazing public function.
var aPublicFunction() {}
''';

  void expectReferenceValid(
      ModelElement reference, ModelElement expected, String href) {
    expect(identical(reference.canonicalModelElement, expected), isTrue);
    expect(expected.isCanonical, isTrue);
    expect(expected.href, endsWith(href));
  }

  void test_reexportWithShow() async {
    var library = await bootPackageWithReexportedLibrary(
        reexportedContent, libraryContent,
        reexportPrivate: true, show: ['AClassNeedingExtending', 'AnExtension']);
    var aPublicFunction = library.functions.named('aPublicFunction');
    var anExtension = library.package.publicLibraries
        .named('${libraryName}_lib')
        .extensions
        .named('AnExtension');
    var anExtensionMethod = anExtension.instanceMethods.named('aMethod');
    var anExtensionReference =
        getMatchingLinkElement('AnExtension', aPublicFunction).commentReferable
            as Extension;
    expectReferenceValid(anExtensionReference, anExtension,
        '%extension_methods_lib/AnExtension.html');
    var anExtensionMethodReference =
        getMatchingLinkElement('AnExtension.aMethod', aPublicFunction)
            .commentReferable as Method;
    expectReferenceValid(anExtensionMethodReference, anExtensionMethod,
        '%extension_methods_lib/AnExtension/aMethod.html');
  }

  void test_reexportWithHide() async {
    var library = await bootPackageWithReexportedLibrary(
        reexportedContent, libraryContent,
        reexportPrivate: true, hide: ['AClassNotNeedingExtending']);
    var aPublicFunction = library.functions.named('aPublicFunction');
    var anExtension = library.package.publicLibraries
        .named('${libraryName}_lib')
        .extensions
        .named('AnExtension');
    var anExtensionMethod = anExtension.instanceMethods.named('aMethod');
    var anExtensionReference =
        getMatchingLinkElement('AnExtension', aPublicFunction).commentReferable
            as Extension;
    expectReferenceValid(anExtensionReference, anExtension,
        '%extension_methods_lib/AnExtension.html');
    var anExtensionMethodReference =
        getMatchingLinkElement('AnExtension.aMethod', aPublicFunction)
            .commentReferable as Method;
    expectReferenceValid(anExtensionMethodReference, anExtensionMethod,
        '%extension_methods_lib/AnExtension/aMethod.html');
  }

  void test_reexportFull() async {
    var library = await bootPackageWithReexportedLibrary(
        reexportedContent, libraryContent,
        reexportPrivate: true);
    var aPublicFunction = library.functions.named('aPublicFunction');
    var anExtension = library.package.publicLibraries
        .named('${libraryName}_lib')
        .extensions
        .named('AnExtension');
    var anExtensionMethod = anExtension.instanceMethods.named('aMethod');
    var anExtensionReference =
        getMatchingLinkElement('AnExtension', aPublicFunction).commentReferable
            as Extension;
    expectReferenceValid(anExtensionReference, anExtension,
        '%extension_methods_lib/AnExtension.html');
    var anExtensionMethodReference =
        getMatchingLinkElement('AnExtension.aMethod', aPublicFunction)
            .commentReferable as Method;
    expectReferenceValid(anExtensionMethodReference, anExtensionMethod,
        '%extension_methods_lib/AnExtension/aMethod.html');
  }
}
