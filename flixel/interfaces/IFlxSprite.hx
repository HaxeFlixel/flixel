package flixel.interfaces;

import flixel.util.FlxPoint;

 /**
  * The interface for properties of FlxSprite
  * It makes possible to add FlxSpriteGroup to FlxSpriteGroup
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
	
	public var offset(default, null):FlxPoint;
	public var origin(default, null):FlxPoint;
	public var scale(default, null):FlxPoint;
	public var velocity(default, null):FlxPoint;
	public var maxVelocity(default, null):FlxPoint;
	public var acceleration(default, null):FlxPoint;
	public var drag(default, null):FlxPoint;
	public var scrollFactor(default, null):FlxPoint;

	public function reset(X:Float, Y:Float):Void;
	public function setPosition(X:Float = 0, Y:Float = 0):Void;
}