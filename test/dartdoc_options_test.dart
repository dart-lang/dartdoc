// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dartdoc.options_test;

import 'dart:io';

import 'package:dartdoc/src/dartdoc_options.dart';
import 'package:path/path.dart' as pathLib;
import 'package:test/test.dart';

void main() {
  DartdocOptionSet dartdocOptionSetFiles;
  DartdocOptionSet dartdocOptionSetArgs;
  DartdocOptionSet dartdocOptionSetAll;
  DartdocOptionSet dartdocOptionSetSynthetic;
  Directory tempDir;
  Directory firstDir;
  Directory secondDir;
  Directory secondDirFirstSub;
  Directory secondDirSecondSub;

  File dartdocOptionsOne;
  File dartdocOptionsTwo;
  File dartdocOptionsTwoFirstSub;
  File firstExisting;

  setUpAll(() {
    dartdocOptionSetSynthetic = new DartdocOptionSet('dartdoc');
    dartdocOptionSetSynthetic
        .add(new DartdocOptionArgFile<int>('mySpecialInteger', 91));
    dartdocOptionSetSynthetic.add(
        new DartdocOptionSyntheticOnly<List<String>>('vegetableLoader',
            (DartdocSyntheticOption<List<String>> option, Directory dir) {
      if (option.root['mySpecialInteger'].valueAt(dir) > 20) {
        return <String>['existing.dart'];
      } else {
        return <String>['not_existing.dart'];
      }
    }));
    dartdocOptionSetSynthetic.add(
        new DartdocOptionSyntheticOnly<List<String>>('vegetableLoaderChecked',
            (DartdocSyntheticOption<List<String>> option, Directory dir) {
      return option.root['vegetableLoader'].valueAt(dir);
    }, isFile: true, mustExist: true));
    dartdocOptionSetSynthetic.add(new DartdocOptionFileSynth<double>('double',
        (DartdocSyntheticOption<double> option, Directory dir) {
      return 3.7 + 4.1;
    }));
    dartdocOptionSetSynthetic.add(
        new DartdocOptionArgSynth<String>('nonCriticalFileOption',
            (DartdocSyntheticOption<String> option, Directory dir) {
      return option.root['vegetableLoader'].valueAt(dir).first;
    }, isFile: true));

    dartdocOptionSetFiles = new DartdocOptionSet('dartdoc');
    dartdocOptionSetFiles
        .add(new DartdocOptionFileOnly<List<String>>('categoryOrder', []));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<double>('double', 3.0));
    dartdocOptionSetFiles
        .add(new DartdocOptionFileOnly<int>('mySpecialInteger', 42));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<Map<String, String>>(
        'mapOption', {'hello': 'world'}));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<List<String>>(
        'fileOptionList', [],
        isFile: true, mustExist: true));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<String>(
        'fileOption', null,
        isFile: true, mustExist: true));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<String>(
        'parentOverride', 'oops',
        parentDirOverridesChild: true));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<String>(
        'nonCriticalFileOption', null,
        isFile: true));
    dartdocOptionSetFiles.add(new DartdocOptionSet('nestedOption')
      ..addAll([new DartdocOptionFileOnly<bool>('flag', false)]));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<String>(
        'dirOption', null,
        isDir: true, mustExist: true));
    dartdocOptionSetFiles.add(new DartdocOptionFileOnly<String>(
        'nonCriticalDirOption', null,
        isDir: true));

    dartdocOptionSetArgs = new DartdocOptionSet('dartdoc');
    dartdocOptionSetArgs
        .add(new DartdocOptionArgOnly<bool>('cauliflowerSystem', false));
    dartdocOptionSetArgs
        .add(new DartdocOptionArgOnly<String>('extraSpecial', 'something'));
    dartdocOptionSetArgs.add(
        new DartdocOptionArgOnly<List<String>>('excludeFiles', ['one', 'two']));
    dartdocOptionSetArgs
        .add(new DartdocOptionArgOnly<int>('number_of_heads', 3, abbr: 'h'));
    dartdocOptionSetArgs
        .add(new DartdocOptionArgOnly<double>('respawnProbability', 0.2));
    dartdocOptionSetArgs.add(new DartdocOptionSet('warn')
      ..addAll(
          [new DartdocOptionArgOnly<bool>('unrecognizedVegetable', false)]));
    dartdocOptionSetArgs.add(new DartdocOptionArgOnly<Map<String, String>>(
        'aFancyMapVariable', {'hello': 'map world'},
        splitCommas: true));
    dartdocOptionSetArgs.add(new DartdocOptionArgOnly<List<String>>(
        'filesFlag', [],
        isFile: true, mustExist: true));
    dartdocOptionSetArgs.add(new DartdocOptionArgOnly<String>(
        'singleFile', 'hello',
        isFile: true, mustExist: true));
    dartdocOptionSetArgs.add(new DartdocOptionArgOnly<String>(
        'unimportantFile', 'whatever',
        isFile: true));

    dartdocOptionSetAll = new DartdocOptionSet('dartdoc');
    dartdocOptionSetAll
        .add(new DartdocOptionArgFile<List<String>>('categoryOrder', []));
    dartdocOptionSetAll
        .add(new DartdocOptionArgFile<int>('mySpecialInteger', 91));
    dartdocOptionSetAll.add(new DartdocOptionSet('warn')
      ..addAll(
          [new DartdocOptionArgFile<bool>('unrecognizedVegetable', false)]));
    dartdocOptionSetAll.add(new DartdocOptionArgFile<Map<String, String>>(
        'mapOption', {'hi': 'there'}));
    dartdocOptionSetAll
        .add(new DartdocOptionArgFile<String>('notInAnyFile', 'so there'));
    dartdocOptionSetAll.add(new DartdocOptionArgFile<String>('fileOption', null,
        isFile: true, mustExist: true));

    tempDir = Directory.systemTemp.createTempSync('options_test');
    firstDir = new Directory(pathLib.join(tempDir.path, 'firstDir'))
      ..createSync();
    firstExisting = new File(pathLib.join(firstDir.path, 'existing.dart'))
      ..createSync();
    secondDir = new Directory(pathLib.join(tempDir.path, 'secondDir'))
      ..createSync();
    new File(pathLib.join(secondDir.path, 'existing.dart'))..createSync();

    secondDirFirstSub = new Directory(pathLib.join(secondDir.path, 'firstSub'))
      ..createSync();
    secondDirSecondSub =
        new Directory(pathLib.join(secondDir.path, 'secondSub'))..createSync();

    dartdocOptionsOne =
        new File(pathLib.join(firstDir.path, 'dartdoc_options.yaml'));
    dartdocOptionsTwo =
        new File(pathLib.join(secondDir.path, 'dartdoc_options.yaml'));
    dartdocOptionsTwoFirstSub =
        new File(pathLib.join(secondDirFirstSub.path, 'dartdoc_options.yaml'));

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
        ''');
    dartdocOptionsTwo.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two']
  parentOverride: 'parent'
  dirOption: 'firstSub'
  fileOptionList: ['existing.dart', 'thing/that/does/not/exist']
  mySpecialInteger: 11
  fileOption: "not existing"
        ''');
    dartdocOptionsTwoFirstSub.writeAsStringSync('''
dartdoc:
  categoryOrder: ['options_two_first_sub']
  parentOverride: 'child'
  nonCriticalDirOption: 'not_existing'
    ''');
  });

  tearDownAll(() {
    tempDir.deleteSync(recursive: true);
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
          orderedEquals([pathLib.canonicalize(firstExisting.path)]));

      String errorMessage;
      try {
        dartdocOptionSetSynthetic['vegetableLoaderChecked'].valueAt(tempDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Synthetic configuration option dartdoc from <internal>, computed as [existing.dart], resolves to missing path: "${pathLib.canonicalize(pathLib.join(tempDir.absolute.path, 'existing.dart'))}"'));
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
          equals(pathLib.canonicalize(
              pathLib.join(Directory.current.path, 'stuff.zip'))));
    });

    test('ArgSynth defaults to synthetic', () {
      dartdocOptionSetSynthetic.parseArguments([]);
      // This option is composed of FileOptions which make use of firstDir.
      expect(
          dartdocOptionSetSynthetic['nonCriticalFileOption'].valueAt(firstDir),
          equals(pathLib
              .canonicalize(pathLib.join(firstDir.path, 'existing.dart'))));
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
      expect(
          errorMessage,
          equals(
              'Argument --file-option, set to override-not-existing.dart, resolves to missing path: "${pathLib.join(pathLib.canonicalize(Directory.current.path), "override-not-existing.dart")}"'));
    });

    test('validate argument can override missing file', () {
      dartdocOptionSetAll.parseArguments(
          ['--file-option', pathLib.canonicalize(firstExisting.path)]);
      expect(dartdocOptionSetAll['fileOption'].valueAt(secondDir),
          equals(pathLib.canonicalize(firstExisting.path)));
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
              'Field dartdoc.fileOption from ${pathLib.canonicalize(dartdocOptionsTwo.path)}, set to not existing, resolves to missing path: '
              '"${pathLib.join(pathLib.canonicalize(secondDir.path), "not existing")}"'));
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
      expect(
          errorMessage,
          equals(
              'Argument --single-file, set to not_found.txt, resolves to missing path: '
              '"${pathLib.join(pathLib.canonicalize(Directory.current.path), 'not_found.txt')}"'));
    });

    test('DartdocOptionArgOnly checks file existence on multi-options', () {
      String errorMessage;
      dartdocOptionSetArgs.parseArguments([
        '--files-flag',
        firstExisting.absolute.path,
        '--files-flag',
        'other_not_found.txt'
      ]);
      try {
        dartdocOptionSetArgs['filesFlag'].valueAt(tempDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Argument --files-flag, set to [${firstExisting.absolute.path}, other_not_found.txt], resolves to missing path: '
              '"${pathLib.join(pathLib.canonicalize(Directory.current.path), "other_not_found.txt")}"'));
    });

    test(
        'DartdocOptionArgOnly does not check for file existence when mustExist is false',
        () {
      dartdocOptionSetArgs
          .parseArguments(['--unimportant-file', 'this-will-never-exist']);
      expect(
          dartdocOptionSetArgs['unimportantFile'].valueAt(tempDir),
          equals(pathLib.join(pathLib.canonicalize(Directory.current.path),
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
          throwsA(const isInstanceOf<DartdocOptionError>()));
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
              'Field dartdoc.fileOptionList from ${pathLib.canonicalize(dartdocOptionsTwo.path)}, set to [existing.dart, thing/that/does/not/exist], resolves to missing path: '
              '"${pathLib.joinAll([pathLib.canonicalize(secondDir.path), 'thing', 'that', 'does', 'not', 'exist'])}"'));
      // It doesn't matter that this fails.
      expect(
          dartdocOptionSetFiles['nonCriticalFileOption'].valueAt(firstDir),
          equals(pathLib
              .joinAll([pathLib.canonicalize(firstDir.path), 'whatever'])));
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
              'Field dartdoc.fileOption from ${pathLib.canonicalize(dartdocOptionsTwo.path)}, set to not existing, resolves to missing path: '
              '"${pathLib.joinAll([pathLib.canonicalize(secondDir.path), "not existing"])}"'));
    });

    test('DartdocOptionSetFile works for directory options', () {
      expect(
          dartdocOptionSetFiles['nonCriticalDirOption']
              .valueAt(secondDirFirstSub),
          equals(pathLib.join(
              pathLib.canonicalize(secondDirFirstSub.path), 'not_existing')));
    });

    test('DartdocOptionSetFile checks errors for directory options', () {
      expect(
          dartdocOptionSetFiles['dirOption'].valueAt(secondDir),
          equals(
              pathLib.canonicalize(pathLib.join(secondDir.path, 'firstSub'))));
      String errorMessage;
      try {
        dartdocOptionSetFiles['dirOption'].valueAt(firstDir);
      } on DartdocFileMissing catch (e) {
        errorMessage = e.message;
      }
      expect(
          errorMessage,
          equals(
              'Field dartdoc.dirOption from ${pathLib.canonicalize(dartdocOptionsOne.path)}, set to notHere, resolves to missing path: '
              '"${pathLib.canonicalize(pathLib.join(firstDir.path, "notHere"))}"'));
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
