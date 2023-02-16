package flixel.util.typeLimit;

import flixel.FlxState;

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
	
	public function create():FlxState
	{
		if (Std.isOfType(this, FlxState))
			return cast this;
		else
			return cast this();
	}
	
	public function getConstructor():()->FlxState
	{
		if (Std.isOfType(this, FlxState))
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

abstract InitialState(Dynamic) to NextState
{
	@:from
	@:deprecated("use `MyState.new` or `()->new MyState()` instead of `new MyState()`)")
	public static function fromState(state:FlxState):InitialState
	{
		return cast state;
	}
	
	@:from
	@:deprecated("use `MyState.new` or `()->new MyState()` instead of `new MyState()`)")
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
		if (Std.isOfType(this, Class))
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

