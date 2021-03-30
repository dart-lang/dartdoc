// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/privacy.dart';
import 'package:dartdoc/src/model/nameable.dart';

/// A "feature" includes both explicit annotations in code (e.g. `deprecated`)
/// as well as others added by the documentation systme (`read-write`);
class Feature extends Privacy with Nameable {
  final String _name;
  /// TODO(jcollins-g): refactor to allow const construction of common features?
  Feature(this._name);

  String get rendered => name;

  @override
  String get name => _name;

  @override
  bool get isPublic => !name.startsWith('_');
}