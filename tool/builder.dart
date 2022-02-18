// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as p;

String _resourcesFile(Iterable<String> packagePaths) => '''
// WARNING: This file is auto-generated. Do not edit.

const List<String> resourceNames = [
${packagePaths.map((p) => "  '$p',").join('\n')}
];
''';

class ResourceBuilder implements Builder {
  final BuilderOptions builderOptions;

  ResourceBuilder(this.builderOptions);

  static const _resourcesPath = 'lib/resources';

  @override
  Future<void> build(BuildStep buildStep) async {
    var resourceAssets =
        await buildStep.findAssets(Glob('$_resourcesPath/**')).toList();
    var packagePaths = [
      for (var asset in resourceAssets)
        p.url.relative(asset.path, from: _resourcesPath),
    ]..sort();
    await buildStep.writeAsString(
        AssetId(buildStep.inputId.package,
            p.url.join('lib', 'src', 'generator', 'html_resources.g.dart')),
        _resourcesFile(packagePaths));
  }

  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$lib$': ['src/generator/html_resources.g.dart']
  };
}

Builder resourceBuilder(BuilderOptions options) => ResourceBuilder(options);
