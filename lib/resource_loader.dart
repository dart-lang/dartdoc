/// Attempts to make it possible to load
/// resources, independent of how the Dart
/// app is run.
///
/// TODO: consider making this a stand-alone package, if useful
library resource_loader;

import 'dart:io' show Platform, File;
import 'package:path/path.dart' as path;
import 'package:pub_cache/pub_cache.dart';
import 'package:http/http.dart' as http;
import 'dart:async' show Future;
import 'dart:typed_data';

/// Loads a `package:` resource as a String.
Future<String> loadAsString(String path) async {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }
  Uint8List bytes = await _doLoad(path);
  return new String.fromCharCodes(bytes);
}

Future<Uint8List> loadAsBytes(String path) {
  if (!path.startsWith('package:')) {
    throw new ArgumentError('path must begin with package:');
  }
  return _doLoad(path);
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
    return _doLoadOverFileFromLocation(resourcePath,
      fullPath.contains("git") ? path.join(fullPath, "lib")) : fullPath;
  } else {
    // maybe we're a snapshot next to a packages/ dir?
    return _doLoadFromFileFromPackagesDir(resourcePath);
  }
}

Future<Uint8List> _doLoadOverHttp(final String resourcePath) {
  var scriptUri = Platform.script;
  var convertedResourcePath = _convertPackageSchemeToPackagesDir(resourcePath);
  // strip file name from script uri, append path to resource
  var segmentsToResource = scriptUri.pathSegments.sublist(
      0, scriptUri.pathSegments.length - 1)
    ..addAll(path.split(convertedResourcePath));
  var fullPath = scriptUri.replace(pathSegments: segmentsToResource);

  return http.readBytes(fullPath);
}

Future<Uint8List> _doLoadOverFileFromLocation(
    final String resourcePath, final String baseDir) {
  var convertedPath = _convertPackageSchemeToPackagesDir(resourcePath);
  // remove 'packages' and package name
  var pathInsideLib = path.split(convertedPath).sublist(2);
  // put the baseDir in front
  pathInsideLib.insert(0, baseDir);
  // put it all back together
  var fullPath = path.joinAll(pathInsideLib);
  return _readFile(resourcePath, fullPath);
}

// TODO: respect package root
// Meanwhile, assume packages/ is next to entry point of script
Future<Uint8List> _doLoadFromFileFromPackagesDir(final String resourcePath) {
  var convertedPath = _convertPackageSchemeToPackagesDir(resourcePath);
  var scriptFile = new File(Platform.script.toFilePath());
  var baseDir = path.dirname(scriptFile.path);
  var fullPath = path.join(baseDir, convertedPath);
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
  var withoutScheme =
      resourcePath.substring('package:'.length, resourcePath.length);
  return path.join('packages', withoutScheme);
}

/// Tries to determine the app name, which is the same as the directory
/// name when globally installed.
///
/// Only call this if your app is globally installed.
String _appNameWhenGloballyInstalled() {
  var parts = path.split(Platform.script.toFilePath());
  var marker = parts.indexOf('global_packages');
  if (marker < 0) {
    throw new StateError(
        '${Platform.script.toFilePath()} does not include global_packages');
  }
  return parts[marker + 1];
}

String _packageNameForResource(final String resourcePath) {
  var parts = path.split(_convertPackageSchemeToPackagesDir(resourcePath));
  // first part is 'packages', second part is the package name
  return parts[1];
}
