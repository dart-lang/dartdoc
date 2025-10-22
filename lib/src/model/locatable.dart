// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

/// Something that can be located for warning purposes.
abstract interface class HasLocation {
  /// The [Locatable](s) from which we will get documentation.
  ///
  /// Can be more than one if this is a [Field] composing documentation from
  /// multiple [Accessor]s.
  ///
  /// This will walk up the inheritance hierarchy to find docs, if the current
  /// class doesn't have docs for this element.
  List<HasLocation> get documentationFrom;

  String get fullyQualifiedName;

  String? get href;

  /// A string indicating the URI of this Locatable.
  String get location;

  /// Whether this is the "canonical" copy of an element.
  ///
  /// Generally, a canonical element must be public, along with possible other
  /// requirements.
  ///
  /// In order for an element to be documented, it must be canonical, and have
  /// documentation.
  bool get isCanonical;
}

extension NullableHasLocation on HasLocation? {
  String get safeWarnableName =>
      this?.fullyQualifiedName.replaceFirst(':', '-') ?? '<unknown>';
}
