// Copied from source at github.com/kseo/tuple/blob/470ed3aeb/lib/src/tuple.dart

// Original copyright:
// Copyright (c) 2014, the tuple project authors. Please see the AUTHORS
// file for details. All rights reserved. Use of this source code is governed
// by a BSD-style license that can be found in the LICENSE file.

import 'package:quiver/core.dart';

/// Represents a 2-tuple, or pair.
class Tuple2<T1, T2> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Creates a new tuple value with the specified items.
  const Tuple2(this.item1, this.item2);

  @override
  String toString() => '[$item1, $item2]';

  @override
  bool operator ==(o) => o is Tuple2 && o.item1 == item1 && o.item2 == item2;

  @override
  int get hashCode => hash2(item1.hashCode, item2.hashCode);
}

/// Represents a 3-tuple, or triple.
class Tuple3<T1, T2, T3> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Returns the third item of the tuple
  final T3 item3;

  /// Creates a new tuple value with the specified items.
  const Tuple3(this.item1, this.item2, this.item3);

  @override
  String toString() => '[$item1, $item2, $item3]';

  @override
  bool operator ==(o) =>
      o is Tuple3 && o.item1 == item1 && o.item2 == item2 && o.item3 == item3;

  @override
  int get hashCode => hash3(item1.hashCode, item2.hashCode, item3.hashCode);
}

/// Represents a 4-tuple, or quadruple.
class Tuple4<T1, T2, T3, T4> {
  /// Returns the first item of the tuple
  final T1 item1;

  /// Returns the second item of the tuple
  final T2 item2;

  /// Returns the third item of the tuple
  final T3 item3;

  /// Returns the fourth item of the tuple
  final T4 item4;

  /// Creates a new tuple value with the specified items.
  const Tuple4(this.item1, this.item2, this.item3, this.item4);

  @override
  String toString() => '[$item1, $item2, $item3, $item4]';

  @override
  bool operator ==(o) =>
      o is Tuple4 &&
      o.item1 == item1 &&
      o.item2 == item2 &&
      o.item3 == item3 &&
      o.item4 == item4;

  @override
  int get hashCode =>
      hash4(item1.hashCode, item2.hashCode, item3.hashCode, item4.hashCode);
}
