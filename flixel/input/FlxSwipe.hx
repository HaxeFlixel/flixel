package flixel.input;

import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.util.FlxPath;
import flixel.util.FlxStringUtil;

@:allow(flixel.input.mouse.FlxMouseButton)
@:allow(flixel.input.touch.FlxTouch)
class FlxSwipe
{
	public static var VELOCITY_THRESHOLD = 100;
	
	public static function filterSwipes(swipes:Array<FlxSwipe>)
	{
		for (swipe in swipes) 
		{
			if (swipe.released)
			{
				swipe.destroy();
				swipes.remove(swipe);
			}
		}
	}
	
	/**
	 * Either LEFT_MOUSE, MIDDLE_MOUSE or RIGHT_MOUSE, 
	 * or the touchPointID of a FlxTouch.
	 */
	public var ID(default, null):Int;
	
	public var path(default, null):FlxPath;
	
	/**
	 * The head of `path`
	 */
	public var start(get, null):FlxPoint;
	
	/**
	 * The tail of `path`
	 */
	public var end(get, null):FlxPoint;
	
	/**
	 * 
	 */
	public var velocity(get, null):FlxPoint;
	
	public var released(default, null):Bool = false;
	
	/**
	 * Checks if this FlxSwipe is qualifed as a swipe
	 * Prevents mistaken tap
	 */
	public var qualified(get, never):Bool;
	
	/**
	 * The distance from `start` to `end`
	 */
	public var distance(get, never):Float;
	
	public var angle(get, never):Float;
	public var duration(get, never):Float;
	
	private var _startTimeInTicks:Float;
	
	private function new(ID:Int, StartPosition:FlxPoint, StartTimeInTicks:Float)
	{
		this.ID = ID;
		path = new FlxPath();
		path.addPoint(StartPosition);
		velocity = FlxPoint.get();
		_startTimeInTicks = StartTimeInTicks;
	}
	
	public inline function release()
	{
		released = true;
	}
	
	public function destroy()
	{
		velocity.put();
		path.destroy();
	}
	
	private inline function toString():String
	{
		return released ? null : FlxStringUtil.getDebugString([
			LabelValuePair.weak("ID", ID), 
			LabelValuePair.weak("start", start),
			LabelValuePair.weak("end", end),
			LabelValuePair.weak("velocity", velocity),
			LabelValuePair.weak("distance", distance),
			LabelValuePair.weak("angle", angle),
			LabelValuePair.weak("duration", duration),
			LabelValuePair.weak("released", released),
			LabelValuePair.weak("qualified", qualified)]);
	}
	
	private function get_start():FlxPoint {
		return path.head();
	}
	
	private function get_end():FlxPoint {
		return path.tail();
	}
	
	private function get_velocity():FlxPoint
	{
		if (!released) {
			velocity.set(end.x - start.x, end.y - start.y);
			velocity.scale(1 / duration);
		}
		return velocity;
	}
	
	private inline function get_qualified():Bool
	{
		return velocity.distanceTo(FlxPoint.weak()) >= VELOCITY_THRESHOLD;
	}
	
	private inline function get_distance():Float
	{
		return FlxMath.vectorLength(start.x - end.x, start.y - end.y);
	}
	
	private inline function get_angle():Float
	{
		return start.angleBetween(end); 
	}
	
	private inline function get_duration():Float
	{
		return (FlxG.game.ticks - _startTimeInTicks) / 1000;
	}
	
}