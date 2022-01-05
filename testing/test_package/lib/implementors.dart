// Copyright (c) 2021, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

// A library useful to check implementer chain edge cases.
library implementors;

import 'src/intermediate_implements.dart';

abstract class ImplementBase {}

abstract class _APrivateThingToImplement implements ImplementBase {}

abstract class ImplementerOfThings implements IntermediateImplementer {}

abstract class ImplementerOfDeclaredPrivateClasses
    implements _APrivateThingToImplement {}
