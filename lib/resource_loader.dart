// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Make it possible to load resources, independent of how the Dart app is run.
///
///     Future<String> getTemplateFile(String templatePath) {
///       return loadAsString('package:dartdoc/templates/$templatePath');
///     }
///
library dartdoc.resource_loader;

import 'dart:async' show Future;
import 'dart:io' show Platform, File, Directory;
import 'dart:typed_data' show Uint8List;

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:pub_cache/pub_cache.dart';

/// Loads a `package:` resource as a String.
Future<String> loadAsString(String path) {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }

  // TODO: Remove once https://github.com/dart-lang/pub/issues/22 is fixed.
  return _doLoad(path)
      .then((bytes) => new String.fromCharCodes(bytes))
      .catchError((_) {
    return new Resource(path).readAsString();
  });
}

/// Loads a `package:` resource as an [List<int>].
Future<List<int>> loadAsBytes(String path) async {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }

  // TODO: Remove once https://github.com/dart-lang/pub/issues/22 is fixed.
  try {
    return await _doLoad(path);
  } catch (_) {
    return new Resource(path).readAsBytes();
  }
}

/// Determine how to do the load. HTTP? Snapshotted? From source?
Future<Uint8List> _doLoad(final String path) {
  var scriptUri = Platform.script;
  if (scriptUri.toString().startsWith('http')) {
    return _doLoadOverHttp(path);
  } else if (scriptUri.toString().endsWith('.snapshot')) {
    return _doLoadWhenSnapshot(path);
  } else {
    return _doLoadFromFileFromPackagesDir(path);
  }
}

Future<Uint8List> _doLoadWhenSnapshot(final String resourcePath) {
  var scriptFilePath = Platform.script.toFilePath();
  // Check if we're running as a pub globally installed package
  // Jump back out to where our source is
  var cacheDirPath = PubCache.getSystemCacheLocation().path;
  if (scriptFilePath.startsWith(cacheDirPath)) {
    // find packages installed with pub
    var appName = _appNameWhenGloballyInstalled();
    var installedApplication = new PubCache()
        .getGlobalApplications()
        .firstWhere((app) => app.name == appName);
    if (installedApplication == null) {
      throw new StateError(
          'Could not find globally installed app $appName. Are you running as a snapshot from the global_packages directory?');
    }
    var resourcePackageName = _packageNameForResource(resourcePath);
    var resourcePackageRef = installedApplication
        .getPackageRefs()
        .firstWhere((ref) => ref.name == resourcePackageName);
    if (resourcePackageRef == null) {
      throw new StateError(
          'Could not find package dependency for $resourcePackageName');
    }
    var resourcePackage = resourcePackageRef.resolve();
    var resourcePackageDir = resourcePackage.location;
    var fullPath = resourcePackageDir.path;
    return _doLoadOverFileFromLocation(resourcePath, p.join(fullPath, "lib"));
  } else {
    // maybe we're a snapshot next to a packages/ dir?
    return _doLoadFromFileFromPackagesDir(resourcePath);
  }
}

Future<Uint8List> _doLoadOverHttp(final String resourcePath) {
  var scriptUri = Platform.script;
  var convertedResourcePath = _convertPackageSchemeToPackagesDir(resourcePath);
  // strip file name from script uri, append path to resource
  var segmentsToResource = scriptUri.pathSegments
      .sublist(0, scriptUri.pathSegments.length - 1)
        ..addAll(p.split(convertedResourcePath));
  var fullPath = scriptUri.replace(pathSegments: segmentsToResource);

  return http.readBytes(fullPath);
}

Future<Uint8List> _doLoadOverFileFromLocation(
    final String resourcePath, final String baseDir) {
  var convertedPath = _convertPackageSchemeToPackagesDir(resourcePath);
  // remove 'packages' and package name
  var pathInsideLib = p.split(convertedPath).sublist(2);
  // put the baseDir in front
  pathInsideLib.insert(0, baseDir);
  // put it all back together
  var fullPath = p.joinAll(pathInsideLib);
  return _readFile(resourcePath, fullPath);
}

/// First, try a packages/ dir next to the entry point (Platform.script).
/// If that doesn't exist, try a packages/ dir inside of the current
/// working directory.
Future<Uint8List> _doLoadFromFileFromPackagesDir(final String resourcePath) {
  var convertedPath = _convertPackageSchemeToPackagesDir(resourcePath);
  var scriptFile = new File(Platform.script.toFilePath());
  String baseDir = p.dirname(scriptFile.path);

  if (!new Directory(p.join(baseDir, 'packages')).existsSync()) {
    // try CWD
    baseDir = Directory.current.path;
  }

  var fullPath = p.join(baseDir, convertedPath);
  return _readFile(resourcePath, fullPath);
}

Future<Uint8List> _readFile(
    final String resourcePath, final String fullPath) async {
  var file = new File(fullPath);
  if (!file.existsSync()) {
    throw new ArgumentError('$resourcePath does not exist, tried $fullPath');
  }
  var bytes = await file.readAsBytes();
  return new Uint8List.fromList(bytes);
}

String _convertPackageSchemeToPackagesDir(String resourcePath) {
  var withoutScheme = _removePackageScheme(resourcePath);
  return p.join('packages', withoutScheme);
}

String _removePackageScheme(final String resourcePath) {
  return resourcePath.substring('package:'.length, resourcePath.length);
}

/// Tries to determine the app name, which is the same as the directory
/// name when globally installed.
///
/// Only call this if your app is globally installed.
String _appNameWhenGloballyInstalled() {
  var parts = p.split(Platform.script.toFilePath());
  var marker = parts.indexOf('global_packages');
  if (marker < 0) {
    throw new StateError(
        '${Platform.script.toFilePath()} does not include global_packages');
  }
  return parts[marker + 1];
}

String _packageNameForResource(final String resourcePath) {
  var parts = p.split(_convertPackageSchemeToPackagesDir(resourcePath));
  // first part is 'packages', second part is the package name
  return parts[1];
}
