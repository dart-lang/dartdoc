// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer_testing/utilities/extensions/resource_provider.dart';
import 'package:dartdoc/src/model/model.dart';
import 'package:dartdoc/src/warnings.dart';
import 'package:test/test.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import 'dartdoc_test_base.dart';
import 'src/test_descriptor_utils.dart' as d;
import 'src/utils.dart';

void main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(OptionUrlsTest);
  });
}

/// Tests that URLs from `dartdoc_options.yaml` which are not plain http(s)
/// URLs, including those of a dependency, produce no link and are never
/// written into the generated HTML unescaped.
@reflectiveTest
class OptionUrlsTest extends DartdocTestBase {
  /// Breaks out of an `href="..."` attribute if written into HTML unescaped.
  static const attributeBreakingUrl = 'x"><img src=x onerror=alert(1)><a x="';

  @override
  String get libraryName => 'victim';

  @override
  Map<String, String> get pubDependencyPaths =>
      const {'other_dep': './vendor/other_dep'};

  /// Boots the package being documented with a dependency `other_dep` whose
  /// `dartdoc_options.yaml` is [depDartdocOptions].
  ///
  /// `other_dep` has one library, `lib/other.dart`, declaring `OtherType` with
  /// a method `otherMethod`.
  Future<PackageGraph> bootPackageWithDependency({
    required String depDartdocOptions,
    required String libraryContent,
    String? dartdocOptions,
    List<String> additionalArguments = const [],
  }) {
    return bootPackageFromFiles(additionalArguments: additionalArguments, [
      d.file('lib/victim.dart', libraryContent),
      if (dartdocOptions != null)
        d.file('dartdoc_options.yaml', dartdocOptions),
      d.dir(
        ResourceProviderExtension(resourceProvider)
            .convertPath('vendor/other_dep'),
        [
          d.file('pubspec.yaml', '''
name: other_dep
version: 0.0.1
'''),
          d.file('dartdoc_options.yaml', depDartdocOptions),
          d.dir('lib', [
            d.file('other.dart', '''
class OtherType {
  void otherMethod() {}
}
'''),
          ]),
        ],
      ),
    ]);
  }

  Matcher hasInvalidUrlWarning(PackageGraph graph, String messageFragment) =>
      predicate(
          (_) => graph.packageWarningCounter.hasWarning(
              graph.defaultPackage, PackageWarning.invalidUrl, messageFragment),
          "has an 'invalid-url' warning containing '$messageFragment'");

  // A dependency's `linkToSource.uriTemplate` is used for the "view source"
  // link of its elements re-exported by the package being documented.

  void test_linkToSource_dependency_validUrl_isLinked() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://example.com/src/%f%#L%l%'
''',
      libraryContent: '''
export 'package:other_dep/other.dart';
''',
    );
    var otherType = graph.libraries.named('victim').classes.named('OtherType');

    expect(otherType.sourceHref, 'https://example.com/src/lib/other.dart#L1');
    expect(graph.packageWarningCounter.hasWarnings, isFalse);
  }

  void test_linkToSource_dependency_attributeBreakout_isNotLinked() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: '$attributeBreakingUrl%f%'
''',
      libraryContent: '''
export 'package:other_dep/other.dart';
''',
    );
    var otherType = graph.libraries.named('victim').classes.named('OtherType');

    expect(otherType.sourceHref, isEmpty);
    expect(otherType.hasSourceHref, isFalse);
    expect(otherType.instanceMethods.named('otherMethod').sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate '$attributeBreakingUrl%f%'"));
    expect(graph, hasInvalidUrlWarning(graph, 'in package:other_dep'));
  }

  void test_linkToSource_dependency_javascriptScheme_isNotLinked() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'javascript:alert(1)//%f%'
''',
      libraryContent: '''
export 'package:other_dep/other.dart';
''',
    );
    var otherType = graph.libraries.named('victim').classes.named('OtherType');

    expect(otherType.sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate 'javascript:alert(1)//%f%'"));
  }

  // The package's own options are validated too.

  void test_linkToSource_ownPackage_attributeBreakout_isNotLinked() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: '$attributeBreakingUrl%f%'
''',
      libraryContent: '''
class C {}
''',
    );
    var c = graph.libraries.named('victim').classes.named('C');

    expect(c.sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate '$attributeBreakingUrl%f%'"));
    expect(graph, hasInvalidUrlWarning(graph, 'in package:test_package'));
  }

  void test_linkToSource_ownPackage_validUrl_isEscapedForAttribute() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://example.com/src?f=%f%&l=%l%'
''',
      libraryContent: '''
class C {}
''',
    );
    var c = graph.libraries.named('victim').classes.named('C');

    expect(c.sourceHref, 'https://example.com/src?f=lib/victim.dart&amp;l=1');
  }

  void test_linkToSource_ownPackage_invalidRevision_isNamedInWarning() async {
    var graph = await bootPackageWithDependency(
      depDartdocOptions: '',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://example.com/src/%r%/%f%'
''',
      libraryContent: '''
class C {}
''',
      additionalArguments: ['--link-to-source-revision', attributeBreakingUrl],
    );
    var c = graph.libraries.named('victim').classes.named('C');

    expect(c.sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph,
            "linkToSource.uriTemplate 'https://example.com/src/%r%/%f%' "
            "with revision '$attributeBreakingUrl' in package:test_package"));
  }
}
