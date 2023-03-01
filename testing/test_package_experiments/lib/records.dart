// Copyright (c) 2023, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Exercise some Record type features within Dartdoc.
library records;

var anInt = 12;

/// A simple record variable.
var recordVariable = (anInt, a: "34", 56.7, b: 89);

const recordConst = (98, c: "76", 54.3, d: 21);

/// A parameterized record type.
typedef RecordTypedef<T> = (T, int, String);

/// A function returning a parameterized record type.
RecordTypedef<U> foo<U>(U aThing, int x) {
  return (aThing, x, x.toString());
}

/// A variable using a parameterized record type.
RecordTypedef<double> fromParameterizedRecordType = (3.5, 10, "A string");

/// Implicit dynamic type parameter.
RecordTypedef dynamicParameterizedRecordType = ([1,2,3], 5, "Another string");

/// Not using the typedef, but it could.
var nonTypeDefRecordType = (["hello", "there"], 12, "From a record");

abstract class A<T> {
  (int, double) aMethod();
  RecordTypedef<T> aParameterizedTypedefRecordReturner();
  void aMethodParametersWithRecords((String, List) aRecord, {required (int, String) b});
}