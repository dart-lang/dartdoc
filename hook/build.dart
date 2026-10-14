// Copyright (c) 2026, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';
import 'dart:io';

import 'package:hooks/hooks.dart';
import 'package:native_toolchain_c/native_toolchain_c.dart';

void main(List<String> args) async {
  await build(args, (input, output) async {
    if (!input.config.linkingEnabled) {
      // In JIT mode (`dart run`, `dart test`), `Isolate.resolvePackageUri`
      // resolves `package:dartdoc/resources` directly from the package
      // directory.
      return;
    }

    var resourcesDirUri = input.packageRoot.resolve('lib/resources/');
    var resourcesDir = Directory.fromUri(resourcesDirUri);
    var files = resourcesDir.listSync().whereType<File>().toList()
      ..sort((a, b) => a.path.compareTo(b.path));

    var resourceMap = <String, String>{};
    for (var file in files) {
      var name = file.uri.pathSegments.last;
      resourceMap[name] = base64.encode(file.readAsBytesSync());
    }

    output.dependencies.addAll(files.map((f) => f.uri));

    var compressed = zlib.encode(utf8.encode(json.encode(resourceMap)));

    var cFile = File.fromUri(
      input.outputDirectoryShared.resolve('dartdoc_resources.c'),
    );
    var sb = StringBuffer()
      ..writeln('#include <stdint.h>')
      ..writeln('#if defined(_WIN32)')
      ..writeln('#define EXPORT __declspec(dllexport)')
      ..writeln('#else')
      ..writeln('#define EXPORT __attribute__((visibility("default")))')
      ..writeln('#endif')
      ..writeln('EXPORT const uint8_t dartdoc_resources_bundle[] = {');
    for (var i = 0; i < compressed.length; i += 16) {
      var end = i + 16 < compressed.length ? i + 16 : compressed.length;
      sb.writeln('  ${compressed.sublist(i, end).join(', ')},');
    }
    sb
      ..writeln('};')
      ..writeln(
        'EXPORT const uint64_t dartdoc_resources_bundle_len = '
        '${compressed.length}ULL;',
      );
    var cSource = sb.toString();
    if (!cFile.existsSync() || cFile.readAsStringSync() != cSource) {
      await cFile.writeAsString(cSource);
    }

    var cbuilder = CBuilder.library(
      name: 'dartdoc_resources',
      assetName: 'src/generator/resource_loader.dart',
      sources: [cFile.path],
    );
    await cbuilder.run(input: input, output: output);
    // `cFile` is an intermediate artifact generated during the build; the
    // actual input dependencies are the files in `lib/resources/` added above.
    (output.json['dependencies'] as List<Object?>?)?.remove(
      cFile.uri.toFilePath(),
    );
  });
}
