// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.options_test;

import 'package:analyzer/file_system/file_system.dart';
import 'package:dartdoc/dartdoc.dart';
import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:dartdoc/src/io_utils.dart';
import 'package:path/path.dart' as path;
import 'package:test/test.dart';
import 'package:yaml/yaml.dart';

class ConvertedOption {
  final String param1;
  final String param2;
  final String myContextPath;

  ConvertedOption._(this.param1, this.param2, this.myContextPath);

  static ConvertedOption fromYamlMap(YamlMap yamlMap, String canonicalYamlPath,
      ResourceProvider resourceProvider) {
    String p1;
    String p2;

    for (var entry in yamlMap.entries) {
      switch (entry.key.toString()) {
        case 'param1':
          p1 = entry.value.toString();
          break;
        case 'param2':
          p2 = entry.value.toString();
          break;
      }
    }
    return ConvertedOption._(p1, p2, canonicalYamlPath);
  }
}

void main() {
  var resourceProvider = pubPackageMetaProvider.resourceProvider;

  DartdocOptionSet dartdocOptionSetFiles;
  DartdocOptionSet dartdocOptionSetArgs;
  DartdocOptionSet dartdocOptionSetAll;
  DartdocOptionSet dartdocOptionSetSynthetic;
  Folder tempDir;
  Folder firstDir;
  Folder secondDir;
  Folder secondDirFirstSub;
  Folder secondDirSecondSub;

  File dartdocOptionsOne;
  File dartdocOptionsTwo;
  File dartdocOptionsTwoFirstSub;
  File firstExisting;

  setUpAll(() {
    dartdocOptionSetSynthetic = DartdocOptionSet('dartdoc', resourceProvider);
    dartdocOptionSetSynthetic.add(
        DartdocOptionArgFile<int>('mySpecialInteger', 91, resourceProvider));
    dartdocOptionSetSynthetic.add(
        DartdocOptionSyntheticOnly<List<String>>('vegetableLoader',
            (DartdocSyntheticOption<List<String>> option, Folder dir) {
      if (option.root['mySpecialInteger'].valueAt(dir) > 20) {
        return <String>['existing.dart'];
      } else {
        return <String>['not_existing.dart'];
      }
    }, resourceProvider));
    dartdocOptionSetSynthetic.add(
        DartdocOptionSyntheticOnly<List<String>>('vegetableLoaderChecked',
            (DartdocSyntheticOption<List<String>> option, Folder dir) {
      return option.root['vegetableLoader'].valueAt(dir);
    }, resourceProvider, optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetSynthetic.add(DartdocOptionFileSynth<double>('double',
        (DartdocSyntheticOption<double> option, Folder dir) {
      return 3.7 + 4.1;
    }, resourceProvider));
    dartdocOptionSetSynthetic.add(
        DartdocOptionArgSynth<String>('nonCriticalFileOption',
            (DartdocSyntheticOption<String> option, Folder dir) {
      return option.root['vegetableLoader'].valueAt(dir).first;
    }, resourceProvider, optionIs: OptionKind.file));

    dartdocOptionSetFiles = DartdocOptionSet('dartdoc', resourceProvider);
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<List<String>>(
        'categoryOrder', [], resourceProvider));
    dartdocOptionSetFiles
        .add(DartdocOptionFileOnly<double>('double', 3.0, resourceProvider));
    dartdocOptionSetFiles.add(
        DartdocOptionFileOnly<int>('mySpecialInteger', 42, resourceProvider));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<Map<String, String>>(
        'mapOption', {'hello': 'world'}, resourceProvider));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<List<String>>(
        'fileOptionList', [], resourceProvider,
        optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<String>(
        'fileOption', null, resourceProvider,
        optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<String>(
        'parentOverride', 'oops', resourceProvider,
        parentDirOverridesChild: true));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<String>(
        'nonCriticalFileOption', null, resourceProvider,
        optionIs: OptionKind.file));
    dartdocOptionSetFiles.add(DartdocOptionSet('nestedOption', resourceProvider)
      ..addAll([DartdocOptionFileOnly<bool>('flag', false, resourceProvider)]));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<String>(
        'dirOption', null, resourceProvider,
        optionIs: OptionKind.dir, mustExist: true));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<String>(
        'nonCriticalDirOption', null, resourceProvider,
        optionIs: OptionKind.dir));
    dartdocOptionSetFiles.add(DartdocOptionFileOnly<ConvertedOption>(
      'convertThisMap',
      null,
      resourceProvider,
      convertYamlToType: ConvertedOption.fromYamlMap,
    ));

    dartdocOptionSetArgs = DartdocOptionSet('dartdoc', resourceProvider);
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<bool>(
        'cauliflowerSystem', false, resourceProvider));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<String>(
        'extraSpecial', 'something', resourceProvider));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<List<String>>(
        'excludeFiles', ['one', 'two'], resourceProvider));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<int>(
        'number_of_heads', 3, resourceProvider,
        abbr: 'h'));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<double>(
        'respawnProbability', 0.2, resourceProvider));
    dartdocOptionSetArgs.add(DartdocOptionSet('warn', resourceProvider)
      ..addAll([
        DartdocOptionArgOnly<bool>(
            'unrecognizedVegetable', false, resourceProvider)
      ]));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<Map<String, String>>(
        'aFancyMapVariable', {'hello': 'map world'}, resourceProvider,
        splitCommas: true));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<List<String>>(
        'filesFlag', [], resourceProvider,
        optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<String>(
        'singleFile', 'hello', resourceProvider,
        optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetArgs.add(DartdocOptionArgOnly<String>(
        'unimportantFile', 'whatever', resourceProvider,
        optionIs: OptionKind.file));

    dartdocOptionSetAll = DartdocOptionSet('dartdoc', resourceProvider);
    dartdocOptionSetAll.add(DartdocOptionArgFile<List<String>>(
        'categoryOrder', [], resourceProvider));
    dartdocOptionSetAll.add(
        DartdocOptionArgFile<int>('mySpecialInteger', 91, resourceProvider));
    dartdocOptionSetAll.add(DartdocOptionSet('warn', resourceProvider)
      ..addAll([
        DartdocOptionArgFile<bool>(
            'unrecognizedVegetable', false, resourceProvider)
      ]));
    dartdocOptionSetAll.add(DartdocOptionArgFile<Map<String, String>>(
        'mapOption', {'hi': 'there'}, resourceProvider));
    dartdocOptionSetAll.add(DartdocOptionArgFile<String>(
        'notInAnyFile', 'so there', resourceProvider));
    dartdocOptionSetAll.add(DartdocOptionArgFile<String>(
        'fileOption', null, resourceProvider,
        optionIs: OptionKind.file, mustExist: true));
    dartdocOptionSetAll.add(DartdocOptionArgFile<List<String>>(
      'globOption',
      [],
      resourceProvider,
      optionIs: OptionKind.glob,
    ));

    tempDir = resourceProvider.createSystemTemp('options_test');
    firstDir = resourceProvider
        .getFolder(resourceProvider.pathContext.join(tempDir.path, 'firstDir'))
          ..create();
    firstExisting = resourceProvider.getFile(
        resourceProvider.pathContext.join(firstDir.path, 'existing.dart'))
      ..writeAsStringSync('');
    secondDir = resourceProvider
        .getFolder(resourceProvider.pathContext.join(tempDir.path, 'secondDir'))
          ..create();
    resourceProvider
        .getFile(
            resourceProvider.pathContext.join(secondDir.path, 'existing.dart'))
        .writeAsStringSync('');

    secondDirFirstSub = resourceProvider.getFolder(
        resourceProvider.pathContext.join(secondDir.path, 'firstSub'))
      ..create();
    secondDirSecondSub = resourceProvider.getFolder(
        resourceProvider.pathContext.join(secondDir.path, 'secondSub'))
      ..create();

    dartdocOptionsOne = resourceProvider.getFile(resourceProvider.pathContext
        .join(firstDir.path, 'dartdoc_options.yaml'));
    dartdocOptionsTwo = resourceProvider.getFile(resourceProvider.pathContext
        .join(secondDir.path, 'dartdoc_options.yaml'));
    dartdocOptionsTwoFirstSub = resourceProvider.getFile(resourceProvider
        .pathContext
        .join(secondDirFirstSub.path, 'dartdoc_options.yaml'));

    dartdocOptionsOne.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_one']
  mySpecialInteger: 30
  nestedOption:
    flag: true
  mapOption:
    firstThing: yes
    secondThing: stuff
  fileOption: "existing.dart"
  dirOption: "notHere"
  nonCriticalFileOption: "whatever"
  double: 3.3
  convertThisMap:
    param1: value1
    param2: value2
        ''');
    dartdocOptionsTwo.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two']
  parentOverride: 'parent'
  dirOption: 'firstSub'
  fileOptionList: ['existing.dart', 'thing/that/does/not/exist']
  mySpecialInteger: 11
  globOption: ['q*.html', 'e*.dart']
  fileOption: "not existing"
        ''');
    dartdocOptionsTwoFirstSub.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two_first_sub']
  parentOverride: 'child'
  nonCriticalDirOption: 'not_existing'
  globOption: ['**/*.dart']
    ''');
  });

  tearDownAll(() {
    tempDir.delete();
  });

  group('new style synthetic option', () {
    test('validate argument override changes value', () {
      dartdocOptionSetSynthetic.parseArguments(['--my-special-integer', '12']);
      expect(dartdocOptionSetSynthetic['vegetableLoader'].valueAt(tempDir),
          orderedEquals(['not_existing.dart']));
    });

    test('validate default value of synthetic', () {
      dartdocOptionSetSynthetic.parseArguments([]);
      expect(dartdocOptionSetSynthetic['vegetableLoader'].valueAt(tempDir),
          orderedEquals(['existing.dart']));
    });

    test('file validation of synthetic', () {
      dartdocOptionSetSynthetic.parseArguments([]);
      expect(
          dartdocOptionSetSynthetic['vegetableLoaderChecked'].valueAt(firstDir),
          orderedEquals([path.canonicalize(firstExisting.path)]));

      String errorMessage;
      try {
        dartdocOptionSetSynthetic['vegetableLoaderChecked'].valueAt(tempDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      var missingPath = resourceProvider.pathContext.canonicalize(
          resourceProvider.pathContext.join(
              resourceProvider.pathContext.absolute(tempDir.path),
              'existing.dart'));
      expect(
          errorMessage,
          equals('Synthetic configuration option vegetableLoaderChecked from '
              '<internal>, computed as [existing.dart], resolves to missing '
              'path: "$missingPath"'));
    });

    test('file can override synthetic in FileSynth', () {
      dartdocOptionSetSynthetic.parseArguments([]);
      expect(
          dartdocOptionSetSynthetic['double'].valueAt(firstDir), equals(3.3));
      expect(dartdocOptionSetSynthetic['double'].valueAt(tempDir), equals(7.8));
    });

    test('arg can override synthetic in ArgSynth', () {
      dartdocOptionSetSynthetic
          .parseArguments(['--non-critical-file-option', 'stuff.zip']);
      // Since this is an ArgSynth, it ignores the yaml option and resolves to the CWD
      expect(
          dartdocOptionSetSynthetic['nonCriticalFileOption'].valueAt(firstDir),
          equals(resourceProvider.pathContext.canonicalize('stuff.zip')));
    });

    test('ArgSynth defaults to synthetic', () {
      dartdocOptionSetSynthetic.parseArguments([]);
      // This option is composed of FileOptions which make use of firstDir.
      expect(
          dartdocOptionSetSynthetic['nonCriticalFileOption'].valueAt(firstDir),
          equals(path.canonicalize(path.join(firstDir.path, 'existing.dart'))));
    });
  });

  group('new style dartdoc both file and argument options', () {
    test(
        'validate argument with wrong file throws error even if dartdoc_options is right',
        () {
      dartdocOptionSetAll
          .parseArguments(['--file-option', 'override-not-existing.dart']);
      String errorMessage;
      try {
        dartdocOptionSetAll['fileOption'].valueAt(firstDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      var missingPath = resourceProvider.pathContext.join(
          resourceProvider.pathContext
              .canonicalize(resourceProvider.pathContext.current),
          'override-not-existing.dart');
      expect(
          errorMessage,
          equals('Argument --file-option, set to override-not-existing.dart, '
              'resolves to missing path: "$missingPath"'));
    });

    test('validate argument can override missing file', () {
      dartdocOptionSetAll.parseArguments(
          ['--file-option', path.canonicalize(firstExisting.path)]);
      expect(dartdocOptionSetAll['fileOption'].valueAt(secondDir),
          equals(path.canonicalize(firstExisting.path)));
    });

    test('File errors still get passed through', () {
      dartdocOptionSetAll.parseArguments([]);
      String errorMessage;
      try {
        dartdocOptionSetAll['fileOption'].valueAt(secondDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Field dartdoc.fileOption from ${path.canonicalize(dartdocOptionsTwo.path)}, set to not existing, resolves to missing path: '
              '"${path.join(path.canonicalize(secondDir.path), "not existing")}"'));
    });

    test('validate override behavior basic', () {
      dartdocOptionSetAll.parseArguments(
          ['--not-in-any-file', 'aha', '--map-option', 'over::theSea']);
      expect(dartdocOptionSetAll['mapOption'].valueAt(tempDir),
          equals({'over': 'theSea'}));
      expect(dartdocOptionSetAll['mapOption'].valueAt(firstDir),
          equals({'over': 'theSea'}));
      expect(
          dartdocOptionSetAll['notInAnyFile'].valueAt(firstDir), equals('aha'));
      expect(dartdocOptionSetAll['mySpecialInteger'].valueAt(firstDir),
          equals(30));
    });

    test('validate override behavior for parent directories', () {
      dartdocOptionSetAll.parseArguments(['--my-special-integer', '14']);
      expect(dartdocOptionSetAll['mySpecialInteger'].valueAt(secondDirFirstSub),
          equals(14));
    });

    test('validate arg defaults do not override file', () {
      dartdocOptionSetAll.parseArguments([]);
      expect(dartdocOptionSetAll['mySpecialInteger'].valueAt(secondDir),
          equals(11));
    });

    test(
        'validate setting the default manually in an argument overrides the file',
        () {
      dartdocOptionSetAll.parseArguments(['--my-special-integer', '91']);
      expect(dartdocOptionSetAll['mySpecialInteger'].valueAt(secondDir),
          equals(91));
    });

    group('glob options', () {
      String canonicalize(String path) =>
          resourceProvider.pathContext.canonicalize(path);

      test('work via the command line', () {
        dartdocOptionSetAll
            .parseArguments(['--glob-option', path.join('foo', '**')]);
        expect(
            dartdocOptionSetAll['globOption'].valueAtCurrent(),
            equals([
              resourceProvider.pathContext.joinAll([
                canonicalize(resourceProvider.pathContext.current),
                'foo',
                '**'
              ])
            ]));
      });

      test('work via files', () {
        dartdocOptionSetAll.parseArguments([]);
        expect(
            dartdocOptionSetAll['globOption'].valueAt(secondDir),
            equals([
              canonicalize(
                  resourceProvider.pathContext.join(secondDir.path, 'q*.html')),
              canonicalize(
                  resourceProvider.pathContext.join(secondDir.path, 'e*.dart')),
            ]));
        // No child override, should be the same as parent
        expect(
            dartdocOptionSetAll['globOption'].valueAt(secondDirSecondSub),
            equals([
              canonicalize(
                  resourceProvider.pathContext.join(secondDir.path, 'q*.html')),
              canonicalize(
                  resourceProvider.pathContext.join(secondDir.path, 'e*.dart')),
            ]));
        // Child directory overrides
        expect(
            dartdocOptionSetAll['globOption'].valueAt(secondDirFirstSub),
            equals([
              resourceProvider.pathContext.joinAll(
                  [canonicalize(secondDirFirstSub.path), '**', '*.dart'])
            ]));
      });
    });
  });

  group('new style dartdoc arg-only options', () {
    test('DartdocOptionArgOnly loads arg defaults', () {
      dartdocOptionSetArgs.parseArguments([]);
      expect(
          dartdocOptionSetArgs['cauliflowerSystem'].valueAt(tempDir), isFalse);
      expect(dartdocOptionSetArgs['extraSpecial'].valueAt(tempDir),
          equals('something'));
      expect(dartdocOptionSetArgs['excludeFiles'].valueAt(tempDir),
          orderedEquals(['one', 'two']));
      expect(
          dartdocOptionSetArgs['number_of_heads'].valueAt(tempDir), equals(3));
      expect(dartdocOptionSetArgs['respawnProbability'].valueAt(tempDir),
          equals(0.2));
      expect(
          dartdocOptionSetArgs['warn']['unrecognizedVegetable']
              .valueAt(tempDir),
          isFalse);
      expect(dartdocOptionSetArgs['aFancyMapVariable'].valueAt(tempDir),
          equals({'hello': 'map world'}));
      expect(
          dartdocOptionSetArgs['singleFile'].valueAt(tempDir), equals('hello'));
    });

    test('DartdocOptionArgOnly checks file existence', () {
      String errorMessage;
      dartdocOptionSetArgs.parseArguments(['--single-file', 'not_found.txt']);
      try {
        dartdocOptionSetArgs['singleFile'].valueAt(tempDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      var missingPath = resourceProvider.pathContext.join(
          resourceProvider.pathContext
              .canonicalize(resourceProvider.pathContext.current),
          'not_found.txt');
      expect(
          errorMessage,
          equals('Argument --single-file, set to not_found.txt, resolves to '
              'missing path: "$missingPath"'));
    });

    test('DartdocOptionArgOnly checks file existence on multi-options', () {
      String errorMessage;
      dartdocOptionSetArgs.parseArguments([
        '--files-flag',
        resourceProvider.pathContext.absolute(firstExisting.path),
        '--files-flag',
        'other_not_found.txt'
      ]);
      try {
        dartdocOptionSetArgs['filesFlag'].valueAt(tempDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      var missingPath = resourceProvider.pathContext.join(
          resourceProvider.pathContext
              .canonicalize(resourceProvider.pathContext.current),
          'other_not_found.txt');
      expect(
          errorMessage,
          equals('Argument --files-flag, set to '
              '[${resourceProvider.pathContext.absolute(firstExisting.path)}, '
              'other_not_found.txt], resolves to missing path: '
              '"$missingPath"'));
    });

    test(
        'DartdocOptionArgOnly does not check for file existence when mustExist is false',
        () {
      dartdocOptionSetArgs
          .parseArguments(['--unimportant-file', 'this-will-never-exist']);
      expect(
          dartdocOptionSetArgs['unimportantFile'].valueAt(tempDir),
          equals(resourceProvider.pathContext.join(
              resourceProvider.pathContext
                  .canonicalize(resourceProvider.pathContext.current),
              'this-will-never-exist')));
    });

    test('DartdocOptionArgOnly has correct flag names', () {
      dartdocOptionSetArgs.parseArguments([]);
      expect(
          (dartdocOptionSetArgs['cauliflowerSystem'] as DartdocOptionArgOnly)
              .argName,
          equals('cauliflower-system'));
      expect(
          (dartdocOptionSetArgs['number_of_heads'] as DartdocOptionArgOnly)
              .argName,
          equals('number-of-heads'));
      expect(
          (dartdocOptionSetArgs['warn']['unrecognizedVegetable']
                  as DartdocOptionArgOnly)
              .argName,
          equals('warn-unrecognized-vegetable'));
    });

    test('DartdocOptionArgOnly abbreviations work', () {
      dartdocOptionSetArgs.parseArguments(['-h', '125']);
      expect(dartdocOptionSetArgs['number_of_heads'].valueAt(tempDir),
          equals(125));
    });

    test('DartdocOptionArgOnly correctly handles some arguments', () {
      dartdocOptionSetArgs.parseArguments([
        '--cauliflower-system',
        '--exclude-files',
        'one',
        '--exclude-files',
        'three',
        '--number-of-heads',
        '14',
        '--warn-unrecognized-vegetable',
        '--extra-special',
        'whatever',
        '--respawn-probability',
        '0.123',
        '--a-fancy-map-variable',
        'aKey::aValue,another key::another value',
      ]);
      expect(
          dartdocOptionSetArgs['cauliflowerSystem'].valueAt(tempDir), isTrue);
      expect(
          dartdocOptionSetArgs['number_of_heads'].valueAt(tempDir), equals(14));
      expect(dartdocOptionSetArgs['respawnProbability'].valueAt(tempDir),
          equals(0.123));
      expect(dartdocOptionSetArgs['excludeFiles'].valueAt(tempDir),
          equals(['one', 'three']));
      expect(
          dartdocOptionSetArgs['warn']['unrecognizedVegetable']
              .valueAt(tempDir),
          isTrue);
      expect(dartdocOptionSetArgs['extraSpecial'].valueAt(tempDir),
          equals('whatever'));
      expect(dartdocOptionSetArgs['aFancyMapVariable'].valueAt(tempDir),
          equals({'aKey': 'aValue', 'another key': 'another value'}));
    });

    test('DartdocOptionArgOnly throws on double type mismatch', () {
      dartdocOptionSetArgs.parseArguments(['--respawn-probability', 'unknown']);
      String errorMessage;
      try {
        dartdocOptionSetArgs['respawnProbability'].valueAt(tempDir);
      } on DartdocOptionError catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Invalid argument value: --respawn-probability, set to "unknown", must be a double.  Example:  --respawn-probability 0.76'));
    });

    test('DartdocOptionArgOnly throws on integer type mismatch', () {
      dartdocOptionSetArgs.parseArguments(['--number-of-heads', '3.6']);
      expect(() => dartdocOptionSetArgs['number_of_heads'].valueAt(tempDir),
          throwsA(const TypeMatcher<DartdocOptionError>()));
      String errorMessage;
      try {
        dartdocOptionSetArgs['number_of_heads'].valueAt(tempDir);
      } on DartdocOptionError catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Invalid argument value: --number-of-heads, set to "3.6", must be a int.  Example:  --number-of-heads 32'));
    });

    test('DartdocOptionArgOnly throws on a map type mismatch', () {
      dartdocOptionSetArgs
          .parseArguments(['--a-fancy-map-variable', 'not a map']);
      String errorMessage;
      try {
        dartdocOptionSetArgs['aFancyMapVariable'].valueAt(tempDir);
      } on DartdocOptionError catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Invalid argument value: --a-fancy-map-variable, set to "not a map", must be a Map<String, String>.  Example:  --a-fancy-map-variable key::value'));
    });
  });

  group('new style dartdoc file-only options', () {
    test('DartdocOptionSetFile can convert YamlMaps to structured data', () {
      ConvertedOption converted =
          dartdocOptionSetFiles['convertThisMap'].valueAt(firstDir);

      expect(converted.param1, equals('value1'));
      expect(converted.param2, equals('value2'));
      expect(converted.myContextPath, equals(path.canonicalize(firstDir.path)));
      expect(
          dartdocOptionSetFiles['convertThisMap'].valueAt(secondDir), isNull);
    });

    test('DartdocOptionSetFile checks file existence when appropriate', () {
      String errorMessage;
      try {
        dartdocOptionSetFiles['fileOptionList'].valueAt(secondDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Field dartdoc.fileOptionList from ${path.canonicalize(dartdocOptionsTwo.path)}, set to [existing.dart, thing/that/does/not/exist], resolves to missing path: '
              '"${path.joinAll([
            path.canonicalize(secondDir.path),
            'thing',
            'that',
            'does',
            'not',
            'exist'
          ])}"'));
      // It doesn't matter that this fails.
      expect(dartdocOptionSetFiles['nonCriticalFileOption'].valueAt(firstDir),
          equals(path.joinAll([path.canonicalize(firstDir.path), 'whatever'])));
    });

    test(
        'DartdocOptionSetFile resolves paths for files relative to where they are declared',
        () {
      String errorMessage;
      try {
        dartdocOptionSetFiles['fileOption'].valueAt(secondDirFirstSub);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Field dartdoc.fileOption from ${path.canonicalize(dartdocOptionsTwo.path)}, set to not existing, resolves to missing path: '
              '"${path.joinAll([
            path.canonicalize(secondDir.path),
            "not existing"
          ])}"'));
    });

    test('DartdocOptionSetFile works for directory options', () {
      expect(
          dartdocOptionSetFiles['nonCriticalDirOption']
              .valueAt(secondDirFirstSub),
          equals(path.join(
              path.canonicalize(secondDirFirstSub.path), 'not_existing')));
    });

    test('DartdocOptionSetFile checks errors for directory options', () {
      expect(dartdocOptionSetFiles['dirOption'].valueAt(secondDir),
          equals(path.canonicalize(path.join(secondDir.path, 'firstSub'))));
      String errorMessage;
      try {
        dartdocOptionSetFiles['dirOption'].valueAt(firstDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Field dartdoc.dirOption from ${path.canonicalize(dartdocOptionsOne.path)}, set to notHere, resolves to missing path: '
              '"${path.canonicalize(path.join(firstDir.path, "notHere"))}"'));
    });

    test('DartdocOptionSetFile loads defaults', () {
      expect(dartdocOptionSetFiles['categoryOrder'].valueAt(tempDir), isEmpty);
      expect(dartdocOptionSetFiles['nestedOption']['flag'].valueAt(tempDir),
          equals(false));
      expect(dartdocOptionSetFiles['double'].valueAt(tempDir), equals(3.0));
      expect(dartdocOptionSetFiles['parentOverride'].valueAt(tempDir),
          equals('oops'));
      expect(dartdocOptionSetFiles['mySpecialInteger'].valueAt(tempDir),
          equals(42));
      expect(dartdocOptionSetFiles['mapOption'].valueAt(tempDir),
          equals({'hello': 'world'}));
    });

    test('DartdocOptionSetFile loads a file', () {
      expect(dartdocOptionSetFiles['categoryOrder'].valueAt(firstDir),
          orderedEquals(['options_one']));
      expect(dartdocOptionSetFiles['nestedOption']['flag'].valueAt(firstDir),
          equals(true));
      expect(dartdocOptionSetFiles['double'].valueAt(firstDir), equals(3.3));
      expect(dartdocOptionSetFiles['mySpecialInteger'].valueAt(firstDir),
          equals(30));
      expect(dartdocOptionSetFiles['mapOption'].valueAt(firstDir),
          equals({'firstThing': 'yes', 'secondThing': 'stuff'}));
    });

    test('DartdocOptionSetFile loads a file in parent directories', () {
      expect(dartdocOptionSetFiles['categoryOrder'].valueAt(secondDirSecondSub),
          orderedEquals(['options_two']));
    });

    test('DartdocOptionSetFile loads the override file instead of parents', () {
      expect(dartdocOptionSetFiles['categoryOrder'].valueAt(secondDirFirstSub),
          orderedEquals(['options_two_first_sub']));
    });

    test('DartdocOptionSetFile lets parents override children when appropriate',
        () {
      expect(dartdocOptionSetFiles['parentOverride'].valueAt(secondDirFirstSub),
          equals('parent'));
    });
  });
}
