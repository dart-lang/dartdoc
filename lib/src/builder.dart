import 'dart:async';
import 'dart:io';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as pathLib;

String _resourcesFile(Iterable<String> packagePaths) => '''
// WARNING: This file is auto-generated. Do not taunt.

library dartdoc.html.resources;

const List<String> resource_names = const [
${packagePaths.map((p) => "  '$p'").join(',\n')}
];
''';

class ResourceBuilder implements Builder {
  final BuilderOptions builderOptions;
  ResourceBuilder(this.builderOptions);

  static final _allResources = new Glob('lib/resources/**');
  @override
  Future build(BuildStep buildStep) async {
    var packagePaths = <String>[];
    await for (String fileName in buildStep.findAssets(_allResources).map((a) => a.path)) {
      String packageified = fileName.replaceFirst(pathLib.join('lib', ''), 'package:dartdoc');
      packagePaths.add(packageified);
    }
    packagePaths.sort();
    await buildStep.writeAsString(new AssetId(buildStep.inputId.package, pathLib.join('lib', 'src', 'html', 'resources.g.dart')), _resourcesFile(packagePaths));
  }

  @override
  Map<String, List<String>> get buildExtensions => {r'$lib$': ['src/html/resources.g.dart']};
}

Builder resourceBuilder(BuilderOptions options) => new ResourceBuilder(options);