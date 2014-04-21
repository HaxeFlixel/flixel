package flixel.util;

@:enum
abstract FlxAxis(Int) 
{
	var NONE = 0; //0b00 (default value)
	var X 	 = 1; //0b01
	var Y	 = 2; //0b10
	var BOTH = 3; //0b11
}