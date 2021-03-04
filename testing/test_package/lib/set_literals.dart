// @dart=2.9

const inferredTypeSet = {1, 3, 5};
const Set<int> specifiedSet = {};
const untypedMap = {};
const typedSet = <String>{};

class AClassContainingLiterals {
  final int value1;
  final int value2;

  const AClassContainingLiterals(this.value1, this.value2);
}

const aComplexSet = {AClassContainingLiterals(3, 5)};
