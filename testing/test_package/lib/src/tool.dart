library test_package.tool;

abstract class GenericSuperProperty<T> {}

abstract class GenericSuperValue<T> extends GenericSuperProperty<T> {}

class _GenericSuper<T> extends GenericSuperValue<T> {}

class GenericSuperNum<T extends num> extends _GenericSuper<T> {}

class GenericSuperInt extends GenericSuperNum<int> {}
