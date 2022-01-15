const inferredTypeSet = const {1, 3, 5};
const Set<int> specifiedSet = const {};
const untypedMap = const {};
const typedSet = const <String>{};
const untypedMapWithoutConst = {};

class AClassContainingLiterals {
  final int value1;
  final int value2;

  const AClassContainingLiterals(this.value1, this.value2);
}

const aComplexSet = const {const AClassContainingLiterals(3, 5)};
