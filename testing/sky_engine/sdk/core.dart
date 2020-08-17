// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library dart.core;

// Required for analyzer for now; it assumes that all imports of dart:core
// also import dart:async somewhere.
// ignore: unused_import
import 'dart:async';

external bool identical(Object a, Object b);

void print(Object object) {}

class bool extends Object {}

abstract class Comparable<T> {
  int compareTo(T other);
}

class DateTime extends Object {}

class double extends num {}

class Function {}

abstract class int extends num {
  bool get isEven => false;
  int operator -();
  external static int parse(String source,
      {int radix, int onError(String source)});
}

abstract class Iterable<E> {
  bool get isEmpty;
  Iterator<E> get iterator;
}

class Iterator<E> {
  E get current;
  bool moveNext();
}

abstract class List<E> implements Iterable<E> {
  Iterator<E> get iterator => null;
  E operator [](int index);
  void operator []=(int index, E value);
  void add(E value);
  void clear();
}

abstract class Map<K, V> extends Object {
  Iterable<K> get keys;
  bool containsKey(Object key);
}

class Null extends Object {}

abstract class num implements Comparable<num> {
  num operator %(num other);
  num operator *(num other);
  num operator +(num other);
  num operator -(num other);
  num operator /(num other);
  bool operator <(num other);
  bool operator <=(num other);
  bool operator >(num other);
  bool operator >=(num other);
  num abs();
  int round();
  int toInt();
}

class Object {
  int get hashCode => 0;
  bool operator ==(other) => identical(this, other);
  String toString() => 'a string';
}

class StackTrace {}

abstract class String implements Comparable<String> {
  external factory String.fromCharCodes(Iterable<int> charCodes,
      [int start = 0, int end]);
  List<int> get codeUnits;
  bool get isEmpty => false;
  bool get isNotEmpty => false;
  int get length => 0;
  String toUpperCase();
}

class Symbol {}

class Type {}

class Uri {
  static List<int> parseIPv6Address(String host, [int start = 0, int end]) {
    int parseHex(int start, int end) {
      return 0;
    }

    return null;
  }
}
