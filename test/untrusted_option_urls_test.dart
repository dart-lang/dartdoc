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
    defineReflectiveTests(UntrustedOptionUrlsTest);
  });
}

/// Tests that URLs from `dartdoc_options.yaml`, which may belong to a
/// dependency rather than to the package being documented, cannot inject HTML
/// into the generated documentation.
@reflectiveTest
class UntrustedOptionUrlsTest extends DartdocTestBase {
  /// Breaks out of an `href="..."` attribute if written into HTML unescaped.
  static const breakoutPayload = 'x"><img src=x onerror=alert(1)><a x="';

  @override
  String get libraryName => 'victim';

  @override
  Map<String, String> get pubDependencyPaths =>
      const {'evil_dep': './vendor/evil_dep'};

  /// Boots the package being documented with a dependency `evil_dep` whose
  /// `dartdoc_options.yaml` is [depDartdocOptions].
  ///
  /// `evil_dep` has one library, `lib/evil.dart`, declaring `EvilType` with a
  /// method `evilMethod`.
  Future<PackageGraph> bootPackageWithEvilDependency({
    required String depDartdocOptions,
    required String libraryContent,
    String? dartdocOptions,
  }) {
    return bootPackageFromFiles([
      d.file('lib/victim.dart', libraryContent),
      if (dartdocOptions != null)
        d.file('dartdoc_options.yaml', dartdocOptions),
      d.dir(
        ResourceProviderExtension(resourceProvider)
            .convertPath('vendor/evil_dep'),
        [
          d.file('pubspec.yaml', '''
name: evil_dep
version: 0.0.1
'''),
          d.file('dartdoc_options.yaml', depDartdocOptions),
          d.dir('lib', [
            d.file('evil.dart', '''
class EvilType {
  void evilMethod() {}
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
    var graph = await bootPackageWithEvilDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://example.com/src/%f%#L%l%'
''',
      libraryContent: '''
export 'package:evil_dep/evil.dart';
''',
    );
    var evilType = graph.libraries.named('victim').classes.named('EvilType');

    expect(evilType.sourceHref, 'https://example.com/src/lib/evil.dart#L1');
    expect(graph.packageWarningCounter.hasWarnings, isFalse);
  }

  void test_linkToSource_dependency_attributeBreakout_isNotLinked() async {
    var graph = await bootPackageWithEvilDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: '$breakoutPayload%f%'
''',
      libraryContent: '''
export 'package:evil_dep/evil.dart';
''',
    );
    var evilType = graph.libraries.named('victim').classes.named('EvilType');

    expect(evilType.sourceHref, isEmpty);
    expect(evilType.hasSourceHref, isFalse);
    expect(evilType.instanceMethods.named('evilMethod').sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate '$breakoutPayload%f%'"));
    expect(graph, hasInvalidUrlWarning(graph, 'in package:evil_dep'));
  }

  void test_linkToSource_dependency_javascriptScheme_isNotLinked() async {
    var graph = await bootPackageWithEvilDependency(
      depDartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'javascript:alert(1)//%f%'
''',
      libraryContent: '''
export 'package:evil_dep/evil.dart';
''',
    );
    var evilType = graph.libraries.named('victim').classes.named('EvilType');

    expect(evilType.sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate 'javascript:alert(1)//%f%'"));
  }

  // The package's own options are validated too.

  void test_linkToSource_ownPackage_attributeBreakout_isNotLinked() async {
    var graph = await bootPackageWithEvilDependency(
      depDartdocOptions: '',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: '$breakoutPayload%f%'
''',
      libraryContent: '''
class Victim {}
''',
    );
    var victim = graph.libraries.named('victim').classes.named('Victim');

    expect(victim.sourceHref, isEmpty);
    expect(
        graph,
        hasInvalidUrlWarning(
            graph, "linkToSource.uriTemplate '$breakoutPayload%f%'"));
    expect(graph, hasInvalidUrlWarning(graph, 'in package:test_package'));
  }

  void test_linkToSource_ownPackage_validUrl_isEscapedForAttribute() async {
    var graph = await bootPackageWithEvilDependency(
      depDartdocOptions: '',
      dartdocOptions: '''
dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://example.com/src?f=%f%&l=%l%'
''',
      libraryContent: '''
class Victim {}
''',
    );
    var victim = graph.libraries.named('victim').classes.named('Victim');

    expect(
        victim.sourceHref, 'https://example.com/src?f=lib/victim.dart&amp;l=1');
  }
}
