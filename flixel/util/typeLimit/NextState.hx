package flixel.util.typeLimit;


/**
 * A utility type that allows methods to accept multiple types, when dealing with "future" `FlxStates`.
 * Prior to haxeFlixel 6, the `FlxGame` constructor took a `FlxState` class which meant initial
 * `FlxStates`could not have constructor args. In version 6.0.0 and higher, it now takes a function
 * that returns a newly created instance.
 * 
 * ## examples:
 * You can pass the state's contructor in directly:
 * ```haxe
 * FlxG.switchState(PlayState.new);
 * ```
 * You can use short lambas (arrow functions) that return a newly created instance:
 * ```haxe
 * var levelID = 1;
 * FlxG.switchState(()->new PlayState(levelID));
 * ```
 * You can do things the long way, and use an anonymous function:
 * ```haxe
 * FlxG.switchState(function () { return new PlayState(); });
 * ```
 * [Deprecated] Lastly, you can use the old way and pass in a type (until it's removed):
 * ```haxe
 * FlxG.switchState(PlayState);
 * ```
 * 
 * @since 5.6.0
 * @see [HaxeFlixel issue #2541](https://github.com/HaxeFlixel/flixel/issues/2541)
 */
abstract NextState(()->FlxState) from ()->FlxState to ()->FlxState
{
	@:from
	public static function fromType(state:Class<FlxState>):NextState
	{
		return ()->Type.createInstance(state, []);
	}
	
	@:op(a())
	public function createInstance():FlxState
	{
		return this();
	}
}