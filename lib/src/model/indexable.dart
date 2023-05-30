// Copyright (c) 2019, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:dartdoc/src/model/model.dart';

enum Kind {
  accessor,
  constant,
  constructor,
  class_,
  dynamic,
  enum_,
  extension,
  function,
  library,
  method,
  mixin,
  never,
  package,
  parameter,
  prefix,
  property,
  sdk,
  topic,
  topLevelConstant,
  topLevelProperty,
  typedef,
  typeParameter;

  @override
  String toString() => switch (this) {
        accessor => 'accessor',
        constant => 'constant',
        constructor => 'constructor',
        class_ => 'class',
        dynamic => 'dynamic',
        enum_ => 'enum',
        extension => 'extension',
        function => 'function',
        library => 'library',
        method => 'method',
        mixin => 'mixin',
        never => 'Never',
        package => 'package',
        parameter => 'parameter',
        prefix => 'prefix',
        property => 'property',
        sdk => 'SDK',
        topic => 'topic',
        topLevelConstant => 'top-level constant',
        topLevelProperty => 'top-level property',
        typedef => 'typedef',
        typeParameter => 'type parameter',
      };

  static Kind parse(String value) => switch (value) {
        'accessor' => accessor,
        'constant' => constant,
        'constructor' => constructor,
        'class' => class_,
        'dynamic' => dynamic,
        'enum' => enum_,
        'extension' => extension,
        'function' => function,
        'library' => library,
        'method' => method,
        'mixin' => mixin,
        'Never' => never,
        'package' => package,
        'parameter' => parameter,
        'prefix' => prefix,
        'property' => property,
        'SDK' => sdk,
        'topic' => topic,
        'top-level constant' => topLevelConstant,
        'top-level property' => topLevelProperty,
        'typedef' => typedef,
        'type parameter' => typeParameter,
        _ => throw ArgumentError('Unknown kind "$value"'),
      };
}

/// Something able to be indexed.
mixin Indexable implements Nameable {
  String? get href;

  Kind get kind;

  int? get overriddenDepth => 0;
}
