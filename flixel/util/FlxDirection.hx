package flixel.util;

@:enum abstract FlxDirection(Int) from Int to Int
{
	var LEFT    = 0x0001;
	var RIGHT   = 0x0010;
	var UP      = 0x0100;
	var DOWN    = 0x1000;
	var NONE    = 0x0000;
	var CEILING = 0x0100;// UP;
	var FLOOR   = 0x1000;// DOWN;
	var WALL    = 0x0011;// LEFT | RIGHT;
	var ANY     = 0x1111;// LEFT | RIGHT | UP | DOWN;
	
	public inline function has(dir:FlxDirection):Bool return this & dir == dir;
	
	@:op(A & B)
	inline function and(dir:FlxDirection):FlxDirection return this & dir;
	
	@:op(A | B)
	inline function or(dir:FlxDirection):FlxDirection return this | dir;
	
	@:op(A > B)
	inline function gt(dir:Int):Bool return this > dir;
	
	@:op(A < B)
	inline function lt(dir:Int):Bool return this < dir;
	
	@:op(A >= B)
	inline function gte(dir:Int):Bool return this >= dir;
	
	@:op(A <= B)
	inline function lte(dir:Int):Bool return this <= dir;
	
	public function toString()
	{
		if (this == NONE)
			return "NONE";
		
		var str = "";
		if (has(LEFT )) str += " | " + dirs.push("L");
		if (has(RIGHT)) str += " | " + dirs.push("R");
		if (has(UP   )) str += " | " + dirs.push("U");
		if (has(DOWN )) str += " | " + dirs.push("D");
		
		// remove the first " | "
		return str.substr(3);
	}
}

