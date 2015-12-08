// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// A CLI tool to generate documentation for packages from pub.dartlang.org.
library dartdoc.doc_packages;

import 'dart:async';
import 'dart:convert' show JSON, UTF8;
import 'dart:io';

import 'package:args/args.dart';
import 'package:http/http.dart' as http;
import 'package:pub_semver/pub_semver.dart';
import 'package:yaml/yaml.dart';

// TODO: Use isolates; Platform.numberOfProcessors.

const String _rootDir = 'pub.dartlang.org';

/// To use:
///
///     dart tool/doc_packages.dart foo_package bar_package
///
/// or:
///
///     dart tool/doc_packages.dart --list --page=1
///
/// or:
///
///     dart tool/doc_packages.dart --generate --page=3
///
void main(List<String> _args) {
  var parser = _createArgsParser();
  var args = parser.parse(_args);

  if (args['help']) {
    _printUsageAndExit(parser);
  } else if (args['list']) {
    performList(int.parse(args['page']));
  } else if (args['generate']) {
    performGenerate(int.parse(args['page']));
  } else if (args.rest.isEmpty) {
    _printUsageAndExit(parser, exitCode: 1);
  } else {
    // Handle args.rest.
    generateForPackages(args.rest);
  }
}

ArgParser _createArgsParser() {
  var parser = new ArgParser();
  parser.addFlag('help',
      abbr: 'h', negatable: false, help: 'Show command help.');
  parser.addFlag('list', help: 'Show available pub packages', negatable: false);
  parser.addFlag('generate',
      help: 'Generate docs for available pub packages.', negatable: false);
  parser.addOption('page',
      help: 'The pub.dartlang.org page to list or generate for.',
      defaultsTo: '1');
  return parser;
}

/// Print help if we are passed the help option or invalid arguments.
void _printUsageAndExit(ArgParser parser, {int exitCode: 0}) {
  print('Generate documentation for published pub packages.\n');
  print('Usage: _doc_packages [OPTIONS] <package1> <package2>\n');
  print(parser.usage);
  exit(exitCode);
}

void performList(int page) {
  print('Listing pub packages for page ${page}');
  print('');

  _packageUrls(page).then((List<String> packages) {
    return _getPackageInfos(packages).then((List<PackageInfo> infos) {
      infos.forEach(print);
    });
  });
}

void performGenerate(int page) {
  print('Generating docs for page ${page} into ${_rootDir}/');
  print('');

  _packageUrls(page).then((List<String> packages) {
    return _getPackageInfos(packages).then((List<PackageInfo> infos) {
      return Future.forEach(infos, (info) {
        return _printGenerationResult(info, _generateFor(info));
      });
    });
  });
}

void generateForPackages(List<String> packages) {
  print('Generating docs into ${_rootDir}/');
  print('');

  List<String> urls = packages
      .map((s) => 'https://pub.dartlang.org/packages/${s}.json')
      .toList();

  _getPackageInfos(urls).then((List<PackageInfo> infos) {
    return Future.forEach(infos, (PackageInfo info) {
      return _printGenerationResult(info, _generateFor(info));
    });
  });
}

Future _printGenerationResult(PackageInfo package, Future generationResult) {
  String name = package.name.padRight(20);

  return generationResult.then((bool result) {
    if (result) {
      print('${name}: passed');
    } else {
      print('${name}: (skipped)');
    }
  }).catchError((e) {
    print('${name}: * failed *');
  });
}

Future<List<String>> _packageUrls(int page) {
  return http
      .get('https://pub.dartlang.org/packages.json?page=${page}')
      .then((response) {
    return JSON.decode(response.body)['packages'];
  });
}

Future<List<PackageInfo>> _getPackageInfos(List<String> packageUrls) {
  List<Future> futures = packageUrls.map((String p) {
    return http.get(p).then((response) {
      var json = JSON.decode(response.body);
      String name = json['name'];
      List<Version> versions =
          json['versions'].map((v) => new Version.parse(v)).toList();
      return new PackageInfo(name, Version.primary(versions));
    });
  }).toList();

  return Future.wait(futures);
}

StringBuffer _logBuffer;

/// Generate the docs for the given package into _rootDir. Return whether
/// generation was performed or was skipped (due to an older package).
Future<bool> _generateFor(PackageInfo package) async {
  _logBuffer = new StringBuffer();

  // Get the package archive (tar zxvf foo.tar.gz).
  var response = await http.get(package.archiveUrl);
  if (response.statusCode != 200) throw response;

  Directory output = new Directory('${_rootDir}/${package.name}');
  output.createSync(recursive: true);

  try {
    new File(output.path + '/archive.tar.gz')
        .writeAsBytesSync(response.bodyBytes);

    await _exec('tar', ['zxvf', 'archive.tar.gz'],
        cwd: output.path, quiet: true);

    // Rule out any old packages (old sdk constraints).
    File pubspecFile = new File(output.path + '/pubspec.yaml');
    var pubspecInfo = loadYaml(pubspecFile.readAsStringSync());

    // Check for old versions.
    if (_isOldSdkConstraint(pubspecInfo)) {
      _log('skipping ${package.name} - non-matching sdk constraint');
      return false;
    }

    // Run pub get.
    await _exec('pub', ['get'],
        cwd: output.path, timeout: new Duration(seconds: 30));

    // Run dartdoc.
    await _exec('dart', ['../../bin/dartdoc.dart'], cwd: output.path);

    return true;
  } catch (e, st) {
    _log(e.toString());
    _log(st.toString());
    rethrow;
  } finally {
    new File(output.path + '/output.txt')
        .writeAsStringSync(_logBuffer.toString());
  }
}

Future _exec(String command, List<String> args,
    {String cwd,
    bool quiet: false,
    Duration timeout: const Duration(seconds: 60)}) {
  return Process
      .start(command, args, workingDirectory: cwd)
      .then((Process process) {
    if (!quiet) {
      process.stdout.listen((bytes) => _log(UTF8.decode(bytes)));
      process.stderr.listen((bytes) => _log(UTF8.decode(bytes)));
    }

    Future f = process.exitCode.then((code) {
      if (code != 0) throw code;
    });

    if (timeout != null) {
      return f.timeout(timeout, onTimeout: () {
        _log('Timing out operation ${command}.');
        process.kill();
        throw 'timeout on ${command}';
      });
    } else {
      return f;
    }
  });
}

bool _isOldSdkConstraint(var pubspecInfo) {
  var environment = pubspecInfo['environment'];
  if (environment != null) {
    var sdk = environment['sdk'];
    if (sdk != null) {
      VersionConstraint constraint = new VersionConstraint.parse(sdk);
      String version = Platform.version;
      if (version.contains(' '))
        version = version.substring(0, version.indexOf(' '));
      if (!constraint.allows(new Version.parse(version))) {
        _log('sdk constraint = ${constraint}');
        return true;
      } else {
        return false;
      }
    }
  }

  return false;
}

void _log(String str) {
  _logBuffer.write(str);
}

class PackageInfo {
  final String name;
  final Version version;

  PackageInfo(this.name, this.version);

  String get archiveUrl =>
      'https://storage.googleapis.com/pub.dartlang.org/packages/${name}-${version}.tar.gz';

  String toString() => '${name}, ${version}';
}
