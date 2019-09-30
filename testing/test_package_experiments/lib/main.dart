const inferredTypeSet = {1, 2.5, 3};
const Set<int> specifiedSet = {};
const untypedMap = {};
const typedSet = <String>{};

class AClassContainingLiterals {
  final int value1;
  final int value2;

  const AClassContainingLiterals(this.value1, this.value2);

  @override
  bool operator ==(Object other) =>
      other is AClassContainingLiterals && value1 == other.value1;
}

const aComplexSet = {AClassContainingLiterals(3, 5)};
