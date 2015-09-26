Flixel Unit Tests
-----------------

This is a unit test project using [munit](https://github.com/massiveinteractive/MassiveUnit). It's good practice to add tests for fixed bugs or new features. The unit tests are automatically run on TravisCI.

There's a 1:1 mapping between `.hx` files in Flixel and the unit test project - tests for `flixel.ui.FlxButton` go into `flixel.ui.FlxButtonTest` etc.


### Building

- Flash: `haxelib run munit test` (or build from FlashDevelop using `FlixelUnitTests.hxproj`)
- Neko: `haxelib run lime test neko`
- Cpp: `haxelib run lime test cpp`


### Limitations

- there's currently no way to run the tests on HTML5
- there are various issues with including assets, which is why tests that need graphic assets generally create `BitmapData` objects at runtime rather than loading `.png` files

### Code Style

The [Flixel Code Styleguide](http://haxeflixel.com/documentation/code-style/) applies, except for a few minor differences:

- the `private` keyword is omitted
- `:Void` return values of functions may be omitted

#### Functions

- `@Before` functions are named `before()`
- Each `@Test` function starts with `test` and describes what exactly it tests. This can lead to long function names like `FlxEmitter#testStartShouldNotReviveMembers()` and serves as self-documentation.
- Another thing that helps with self-documentation is adding a comment for tests that are related an issue on GitHub.

	```haxe
	@Test // #1203
	function testColorWithAlphaComparison()
	```

### `FlxTest` base class

Test classes extend `FlxTest`, which is a base class with some utility functions for testing.

### `step()`

`step()` advances the `FlxGame` exactly one step. This is useful for tests that depend on game time advancing / `FlxGame#step()` being executed, such as physics of `add()`ed objects, state switches, or just time passing for tweens or timers.

There are two parameters:
- `steps` - specifies the amount of steps to advance (defaults to 1)
- `callback` - an optional callback function that is executed after each step

### `testDestroy()`

`testDestroy()` tests whether an `IFlxDestroyable` can safely be `destroy()`ed more than once (null reference errors are fairly common here). For this, `destroyable` has to be set during `before()` of the test class.