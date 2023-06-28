import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart' as crypto;
import 'package:path/path.dart' as p;
import 'package:yaml/yaml.dart' as yaml;

import 'subprocess_launcher.dart';

void main(List<String> args) async {
  var parser = ArgParser();
  parser.addCommand('build');
  var results = parser.parse(args);
  var commandResults = results.command;
  if (commandResults == null) {
    return;
  }

  return switch (commandResults.name) {
    'build' => await runBuild(commandResults),
    // TODO(srawlins): Implement tasks that document various code.
    'doc' => throw UnimplementedError(),
    // TODO(srawlins): Implement tasks that serve various docs, after generating
    // them.
    'serve' => throw UnimplementedError(),
    _ => throw ArgumentError(),
  };
}

String _getPackageVersion() {
  var pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    throw StateError('Cannot find pubspec.yaml in ${Directory.current}');
  }
  var yamlDoc = yaml.loadYaml(pubspec.readAsStringSync()) as yaml.YamlMap;
  return yamlDoc['version'] as String;
}

Future<void> runBuild(ArgResults commandResults) async {
  for (var target in commandResults.rest) {
    // ignore: unnecessary_statements, unnecessary_parenthesis
    (switch (target) {
      'renderers' => await buildRenderers(),
      'dartdoc-options' => await buildDartdocOptions(),
      'web' => await buildWeb(),
      _ => throw UnimplementedError('Unknown build target: "$target"'),
    });
  }
}

Future<void> buildRenderers() async =>
    await SubprocessLauncher('build').runStreamed(Platform.resolvedExecutable,
        [p.join('tool', 'mustachio', 'builder.dart')]);

Future<void> buildDartdocOptions() async {
  var version = _getPackageVersion();
  var dartdocOptions = File('dartdoc_options.yaml');
  await dartdocOptions.writeAsString('''dartdoc:
  linkToSource:
    root: '.'
    uriTemplate: 'https://github.com/dart-lang/dartdoc/blob/v$version/%f%#L%l%'
''');
}

Future<void> buildWeb() async {
  await SubprocessLauncher('build').runStreamed(Platform.resolvedExecutable, [
    'compile',
    'js',
    '--output=lib/resources/docs.dart.js',
    'web/docs.dart',
    '-O4',
  ]);
  delete(File('lib/resources/docs.dart.js.deps'));

  var compileSig = await calcDartFilesSig(Directory('web'));
  File(p.join('web', 'sig.txt')).writeAsStringSync('$compileSig\n');
}

/// Delete the given file entity reference.
void delete(FileSystemEntity entity) {
  if (entity.existsSync()) {
    print('deleting ${entity.path}');
    entity.deleteSync(recursive: true);
  }
}

Future<String> calcDartFilesSig(Directory dir) async {
  final digest = await _dartFileLines(dir)
      .transform(utf8.encoder)
      .transform(crypto.md5)
      .single;

  return digest.bytes
      .map((byte) => byte.toRadixString(16).padLeft(2, '0').toUpperCase())
      .join();
}

/// Yields all of the trimmed lines of all of the `.dart` files in [dir].
Stream<String> _dartFileLines(Directory dir) {
  var files = dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList()
    ..sort((a, b) => compareAsciiLowerCase(a.path, b.path));

  return Stream.fromIterable([
    for (var file in files)
      for (var line in file.readAsLinesSync()) line.trim(),
  ]);
}
