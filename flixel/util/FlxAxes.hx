package flixel.util;

#if (haxe >= "4")
enum FlxAxes
{
	X;
	Y;
	XY;
}
#else
// Use abstract in 3.4.7 to allow default arguments
@:enum abstract FlxAxes(Int)
{
	var X = 1;
	var Y = 2;
	var XY = 3;
}
#end
