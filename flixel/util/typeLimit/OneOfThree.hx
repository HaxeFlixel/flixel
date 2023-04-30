package flixel.util.typeLimit;

/**
 * Useful to limit a Dynamic function argument's type to the specified
 * type parameters. This does NOT make the use of Dynamic type-safe in
 * any way (the underlying type is still Dynamic and Std.is() checks +
 * casts are necessary).
 */
abstract OneOfThree<T1, T2, T3>(Dynamic) from T1 from T2 from T3 to T1 to T2 to T3 {}
