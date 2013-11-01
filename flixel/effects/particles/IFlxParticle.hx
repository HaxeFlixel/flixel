package flixel.effects.particles;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.util.FlxPoint;

interface IFlxParticle
{
	public var ID:Int;
	public var cameras:Array<FlxCamera>;
	public var active(default, set):Bool;
	public var visible(default, set):Bool;
	public var alive(default, set):Bool;
	public var exists(default, set):Bool;
	
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
	public var velocity(default, set):FlxPoint;
	public var maxVelocity(default, set):FlxPoint;
	public var acceleration(default, set):FlxPoint;
	public var drag(default, set):FlxPoint;
	public var scrollFactor(default, set):FlxPoint;
	
	public var lifespan:Float;
	public var friction:Float;
	public var useFading:Bool;
	public var useScaling:Bool;
	public var useColoring:Bool;
	public var maxLifespan:Float;
	public var startAlpha:Float;
	public var rangeAlpha:Float;
	public var startScale:Float;
	public var rangeScale:Float;
	public var startRed:Float;
	public var startGreen:Float;
	public var startBlue:Float;
	public var rangeRed:Float;
	public var rangeGreen:Float;
	public var rangeBlue:Float;

	public function draw():Void;
	public function update():Void;
	public function destroy():Void;
	public function toString():String;
	
	public function kill():Void;
	public function revive():Void;

	#if !FLX_NO_DEBUG
	public var ignoreDrawDebug:Bool;
	public function drawDebug():Void;
	public function drawDebugOnCamera(?Camera:FlxCamera):Void;
	#end

	public function reset(X:Float, Y:Float):Void;
	public function setPosition(X:Float = 0, Y:Float = 0):Void;
	
	public function onEmit():Void;
}