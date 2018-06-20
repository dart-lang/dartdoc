// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as pathLib;

String _resourcesFile(Iterable<String> packagePaths) => '''
// WARNING: This file is auto-generated. Do not taunt.

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
    await for (String fileName in buildStep
        .findAssets(_allResources)
        .map((a) => pathLib.posix.joinAll(pathLib.split(a.path)))) {
      String packageified =
          fileName.replaceFirst(pathLib.join('lib', ''), 'package:dartdoc');
      packagePaths.add(packageified);
    }
    packagePaths.sort();
    await buildStep.writeAsString(
        new AssetId(buildStep.inputId.package,
            pathLib.join('lib', 'src', 'html', 'resources.g.dart')),
        _resourcesFile(packagePaths));
  }

  @override
  Map<String, List<String>> get buildExtensions => {
        r'$lib$': ['src/html/resources.g.dart']
      };
}

Builder resourceBuilder(BuilderOptions options) => new ResourceBuilder(options);
