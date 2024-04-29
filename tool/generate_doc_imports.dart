// Copyright (c) 2024, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:collection';
import 'dart:io';

import 'package:args/args.dart';

void main(List<String> args) async {
  // --file with a file name.
  final argParser = ArgParser()..addOption('file');
  final argResults = argParser.parse(args);
  final filePath = argResults['file'] as String?;
  if (filePath != null) {
    printFileDocImports(filePath);
  } else {
    printFileDocImports('tool/test_dd.dart');
  }
}

void printFileDocImports(String filePath) {
  print('file $filePath');

  var errorPrefix =
      'error: unresolved doc reference [analyzerRef NULL other result is';

  var inputFile = File(filePath);
  var lines = inputFile.readAsLinesSync();
  print('there are ${lines.length} lines');

  var hrefPattern = RegExp(r'[a-z,A-Z,-.\/,0-9,_]+.html');
  var dartFilePattern = RegExp(r'\/tmp[a-z,A-Z,,0-9,_,\/]+.dart');

  var docImportMap = <String, Set<String>>{};
  var i = 0;
  while (i < lines.length) {
    var line = lines[i];
    if (!line.contains(errorPrefix)) {
      i++;
      continue;
    }
    // print(line);

    String? packageDocImport;
    var hrefMatch = hrefPattern.firstMatch(line);
    if (hrefMatch case var href?) {
      var hrefString = line.substring(href.start, href.end);
      var hrefIndex = hrefString.indexOf('/');
      if (hrefIndex == -1) {
        print(line);
        i++;
        continue;
      }

      var packageName = hrefString.substring(0, hrefIndex);
      packageDocImport = buildDocImport(packageName);
      // print('Package: $packageDocImport');
    }

    if (packageDocImport == null) {
      i++;
      continue;
    }

    // Find the file we want to add this to.
    var nextLine = lines[i + 1];
    // print(nextLine); // Print the matching line
    var match = dartFilePattern.firstMatch(nextLine);
    if (match case var dartFile?) {
      var fileToAddDocImports =
          nextLine.substring(dartFile.start, dartFile.end);
      // print(fileToAddDocImports);

      docImportMap.putIfAbsent(fileToAddDocImports, () => {});
      docImportMap[fileToAddDocImports]!.add(packageDocImport);
    }

    // Skip the next line.
    i = i + 2;
  }

  // printDocImportMap(docImportMap);
  print('\n${docImportMap.keys.length} files to fix.');
}

String? buildDocImport(String packageName) {
  var packageDashString = 'package-';

  if (packageName.startsWith('dart-')) {
    var dartPackageName = packageName.replaceFirst('-', ':');
    return "/// @docImport '$dartPackageName';";
  } else if (packageName.startsWith('flutter_test')) {
    return "/// @docImport 'package:flutter_test/flutter_test.dart';";
  } else if (packageName.startsWith('flutter_driver_extension')) {
    return "/// @docImport 'package:flutter_driver/driver_extension.dart';";
  } else if (packageName.startsWith('flutter_driver')) {
    return "/// @docImport 'package:flutter_driver/flutter_driver.dart';";
  } else if (packageName.startsWith('flutter_web_plugins')) {
    return "/// @docImport 'package:flutter_web_plugins/flutter_web_plugins.dart';";
  } else if (packageName.startsWith('flutter_localizations')) {
    return "/// @docImport 'package:flutter_localizations/flutter_localizations.dart';";
  } else if (packageName.contains('test_api.scaffolding')) {
    return "/// @docImport 'package:test_api/scaffolding.dart';";
  } else if (packageName.contains('test_api')) {
    return "/// @docImport 'package:test_api/test_api.dart';";
  } else if (packageName.startsWith('intl')) {
    return "/// @docImport 'package:intl/intl.dart';";
  } else if (packageName.startsWith('characters')) {
    return "/// @docImport 'package:characters/characters.dart';";
  } else if (packageName.startsWith('vector_math_64')) {
    return "/// @docImport 'package:vector_math/vector_math_64.dart';";
  } else if (packageName.startsWith(packageDashString)) {
    var packageIndex = packageName.indexOf(packageDashString);
    var restPackageName =
        packageName.substring(packageIndex + packageDashString.length);

    var importPath = restPackageName;
    if (restPackageName.contains('integration_test')) {
      importPath = restPackageName.replaceFirst(
          'integration_test_', 'integration_test/');
      return "/// @docImport 'package:$importPath.dart';";
    } else if (restPackageName.contains('fake_async')) {
      importPath = restPackageName.replaceFirst('fake_async_', 'fake_async/');
      return "/// @docImport 'package:$importPath.dart';";
    } else if (restPackageName.contains('test_api')) {
      importPath = restPackageName.replaceFirst('test_api_', 'test_api/');
      return "/// @docImport 'package:$importPath.dart';";
    } else if (restPackageName.contains('_')) {
      importPath = restPackageName.replaceFirst('_', '/');
      return "/// @docImport 'package:$importPath.dart';";
    }

    // ERROR: this should not be a valid uri, but needs to be checked.
    return "/// @docImport 'package:$packageName.dart';";
  }
  return "/// @docImport 'package:flutter/$packageName.dart';";
}

void printDocImportMap(Map<String, Set<String>> docImportMap) {
  for (var MapEntry(key: file, value: docImports) in docImportMap.entries) {
    // /tmp/flutterOOFHUB/packages/flutter/lib/src/scheduler/debug.dart
    print('\nFor file $file:');

    final sortedDocImports = SplayTreeSet<String>.from(docImports);
    writeToFile(file, sortedDocImports);
    for (var import in sortedDocImports) {
      print(import);
    }
  }
}

// void printDocImports() {
//   var sampleInput =
//       'flutter-docs:  error: unresolved doc reference [analyzerRef NULL other result is Class ImplicitlyAnimatedWidget with href widgets/ImplicitlyAnimatedWidget-class.html]';

//   // **1. Extract the HTML link portion**
//   var hrefStart = sampleInput.indexOf('href ');
//   var hrefEnd = sampleInput.indexOf(']');

//   if (hrefStart != -1 && hrefEnd != -1) {
//     var rawLink = sampleInput.substring(hrefStart + 5, hrefEnd);
//     var widgets = rawLink.indexOf('/');
//     rawLink = rawLink.substring(0, widgets - 1);
//     print('raw link is $rawLink');

//     // **2. Construct a well-formed HTML link**
//     var docImport = "/// @docImport 'package:flutter/$rawLink.dart;";

//     // **3. Print the output**
//     print(docImport);
//   } else {
//     print('HTML link not found in the input line.');
//   }
// }

void writeToFile(String filePath, SplayTreeSet<String> sortedDocImports) {
  var file = File(filePath);
  final lines = file.readAsLinesSync();

  var foundLicense = false;
  var addedDocImports = false;
  final newLines = <String>[];

  for (var line in lines) {
    if (!addedDocImports && foundLicense && !line.startsWith('//')) {
      if (filePath.contains('src')) {
        newLines.add('');
        newLines.addAll(sortedDocImports);
        addedDocImports = true;

        newLines.add('library;\n');
        foundLicense = false; // Only insert once after the license line
        continue;
      } else if (line.startsWith('library')) {
        newLines.add('///');
        newLines.addAll(sortedDocImports);
        addedDocImports = true;

        newLines.add(line);
        foundLicense = false; // Only insert once after the license line
        continue;
      }
    }

    newLines.add(line);

    if (line.trim() == '// found in the LICENSE file.') {
      foundLicense = true;
    }
  }

  newLines.add('');
  file.writeAsStringSync(newLines.join('\n'));
  print('File ${file.path} modified!');
}
