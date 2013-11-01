package flixel.effects.particles;

import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.IFlxSprite;
import flixel.util.FlxPoint;

interface IFlxParticle extends IFlxSprite
{
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
	
	public function onEmit():Void;
}