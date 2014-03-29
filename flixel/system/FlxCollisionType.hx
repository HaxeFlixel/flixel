package flixel.system;

/**
 * Types of collidable objects.
 * 
 * Abstracted from an Int type for fast comparrison code:
 * http://nadako.tumblr.com/post/64707798715/cool-feature-of-upcoming-haxe-3-2-enum-abstracts
 */
@:enum
abstract FlxCollisionType(Int)
{
	var NONE        = 0;
	var OBJECT      = 1;
	var GROUP       = 2;
	var TILEMAP     = 3;
	var SPRITEGROUP = 4;
}