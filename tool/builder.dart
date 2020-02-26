// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:build/build.dart';
import 'package:glob/glob.dart';
import 'package:path/path.dart' as path;

String _resourcesFile(Iterable<String> packagePaths) => '''
// WARNING: This file is auto-generated. Do not taunt.

const List<String> resource_names = [
${packagePaths.map((p) => "  '$p'").join(',\n')}
];
''';

class ResourceBuilder implements Builder {
  final BuilderOptions builderOptions;
  ResourceBuilder(this.builderOptions);

  static final _allResources = Glob('lib/resources/**');
  @override
  Future build(BuildStep buildStep) async {
    var packagePaths = <String>[];
    await for (AssetId asset in buildStep.findAssets(_allResources)) {
      packagePaths.add(asset.uri.toString());
    }
    packagePaths.sort();
    await buildStep.writeAsString(
        AssetId(buildStep.inputId.package,
            path.url.join('lib', 'src', 'generator', 'html_resources.g.dart')),
        _resourcesFile(packagePaths));
  }

  @override
  final Map<String, List<String>> buildExtensions = const {
    r'$lib$': ['src/generator/html_resources.g.dart']
  };
}

Builder resourceBuilder(BuilderOptions options) => ResourceBuilder(options);
