package flixel.util.typeLimit;

/**
 * Useful to limit a Dynamic function argument's type to the specified
 * type parameters. This does NOT make the use of Dynamic type-safe in
 * any way (the underlying type is still Dynamic and Std.is() checks +
 * casts are necessary).
 */
abstract OneOfNine<T1, T2, T3, T4, T5, T6, T7, T8, T9>(Dynamic) from T1 from T2 from T3 from T4 from T5 from T6 from T7 from T8 from T9 to T1 to T2 to T3 to T4 to T5 to T6 to T7 to T8 to T9{}