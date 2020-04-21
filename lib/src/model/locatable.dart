// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/element/element.dart' show Element;

/// Something that can be located for warning purposes.
abstract class Locatable {
  List<Locatable> get documentationFrom;

  /// True if documentationFrom contains only one item, [this].
  bool get documentationIsLocal =>
      documentationFrom.length == 1 && identical(documentationFrom.first, this);

  String get fullyQualifiedName;

  String get href;

  /// A string indicating the URI of this Locatable, usually derived from
  /// [Element.location].
  String get location;
}

final RegExp locationSplitter = RegExp(r'(package:|[\\/;.])');
