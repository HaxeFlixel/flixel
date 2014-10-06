package flixel.overlap;

import flixel.FlxSprite;
import flixel.math.FlxRect;
import flixel.math.FlxVector;


class FlxRay {
	public var start : FlxVector;
	public var end : FlxVector;
	
	public var isInfinite : Bool;
	
	public function new(Start : FlxVector, End : FlxVector, IsInfinite : Bool)
	{
		start = Start;
		end = End;
		isInfinite = IsInfinite;
	}
}