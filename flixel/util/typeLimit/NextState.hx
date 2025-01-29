package flixel.util.typeLimit;

import flixel.FlxState;

/**
 * A utility type that allows methods to accept multiple types, when dealing with "future" `FlxStates`.
 * Prior to HaxeFlixel 6, `FlxG.switchState` and other similar methods took a `FlxState` instance,
 * which meant `FlxStates` were instantiated before the previous state was destroyed, potentially
 * causing errors. It also meant that states with args couldn't be reset via `FlxG.resetState`. In version
 * 5.6.0 and higher, these methods now take a function that returns a newly created state instance. This
 * allows the state's instantiation to happen after the previous state is destroyed.
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
 * [Deprecated] Lastly, you can use the old way and pass in an instance (until it's removed):
 * ```haxe
 * FlxG.switchState(new PlayState());
 * ```
 * 
 * @since 5.6.0
 * @see [HaxeFlixel issue #2541](https://github.com/HaxeFlixel/flixel/issues/2541)
 */
abstract NextState(Dynamic)
{
	@:from
	@:deprecated("use `MyState.new` or `()->new MyState()` instead of `new MyState()`)")
	public static function fromState(state:FlxState):NextState
	{
		return cast state;
	}
	
	@:from
	public static function fromMaker(func:()->FlxState):NextState
	{
		return cast func;
	}
	
	public function createInstance():FlxState
	{
		if (this is FlxState)
			return cast this;
		else if (this is Class)
			return Type.createInstance(this, []);
		else
			return cast this();
	}
	
	public function getConstructor():()->FlxState
	{
		if (this is FlxState)
		{
			return function ():FlxState
			{
				return cast Type.createInstance(Type.getClass(this), []);
			}
		}
		else
			return cast this;
	}
}

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
abstract InitialState(Dynamic) to NextState
{
	@:from
	public static function fromType(state:Class<FlxState>):InitialState
	{
		return cast state;
	}
	
	@:from
	public static function fromMaker(func:()->FlxState):InitialState
	{
		return cast func;
	}
	
	@:to
	public function toNextState():NextState
	{
		if (this is Class)
		{
			return function ():FlxState
			{
				return cast Type.createInstance(this, []);
			}
		}
		else
			return cast this;
	}
}