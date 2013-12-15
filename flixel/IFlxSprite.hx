package flixel;

import flixel.util.FlxPoint;

 /**
 * The interface for properties of <code>FlxSprite</code>
 * It makes possible to add <code>FlxSpriteGroup</code> to <code>FlxSpriteGroup</code>
 */
interface IFlxSprite extends IFlxBasic 
{
	public var x(default, set):Float;
	public var y(default, set):Float;
	public var alpha(default, set):Float;
	public var angle(default, set):Float;
	public var facing(default, set):Int;
	public var moves(default, set):Bool;
	public var immovable(default, set):Bool;
	
	public var offset(default, set):FlxPoint;
	public var origin(default, set):FlxPoint;
	public var scale(default, set):FlxPoint;
	public var velocity:FlxPoint;
	public var maxVelocity:FlxPoint;
	public var acceleration:FlxPoint;
	public var drag:FlxPoint;
	public var scrollFactor(default, set):FlxPoint;

	public function reset(X:Float, Y:Float):Void;
	public function setPosition(X:Float = 0, Y:Float = 0):Void;
}