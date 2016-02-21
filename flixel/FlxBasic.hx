package flixel;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxStringUtil;

/**
 * This is a useful "generic" Flixel object. Both FlxObject and 
 * FlxGroup extend this class. Has no size, position or graphical data.
 */
class FlxBasic implements IFlxDestroyable
{
	#if !FLX_NO_DEBUG
	/**
	 * Static counters for performance tracking.
	 */
	@:allow(flixel.FlxGame)
	private static var activeCount:Int = 0;
	@:allow(flixel.FlxGame)
	private static var visibleCount:Int = 0;
	#end
	
	/**
	 * IDs seem like they could be pretty useful, huh?
	 * They're not actually used for anything yet though.
	 */
	public var ID:Int = -1;
	/**
	 * Controls whether update() is automatically called by FlxState/FlxGroup.
	 */
	public var active(default, set):Bool = true;
	/**
	 * Controls whether draw() is automatically called by FlxState/FlxGroup.
	 */
	public var visible(default, set):Bool = true;
	/**
	 * Useful state for many game objects - "dead" (!alive) vs alive. kill() and
	 * revive() both flip this switch (along with exists, but you can override that).
	 */
	public var alive(default, set):Bool = true;
	/**
	 * Controls whether update() and draw() are automatically called by FlxState/FlxGroup.
	 */
	public var exists(default, set):Bool = true;
	
	/**
	 * Gets ot sets the first camera of this object.
	 */
	public var camera(get, set):FlxCamera;
	/**
	 * This determines on which FlxCameras this object will be drawn. If it is null / has not been
	 * set, it uses FlxCamera.defaultCameras, which is a reference to FlxG.cameras.list (all cameras) by default.
	 */
	public var cameras(get, set):Array<FlxCamera>;
	
	/**
	 * Enum that informs the collision system which type of object this is (to avoid expensive type casting).
	 */
	private var flixelType(default, null):FlxType = NONE;
	
	private var _cameras:Array<FlxCamera>;
	
	public function new() {}
	
	/**
	 * WARNING: This will remove this object entirely. Use kill() if you want to disable it temporarily only and revive() it later.
	 * Override this function to null out variables manually or call destroy() on class members if necessary. Don't forget to call super.destroy()!
	 */
	public function destroy():Void 
	{
		exists = false;
		_cameras = null;
	}
	
	/**
	 * Handy function for "killing" game objects. Use reset() to revive them. Default behavior is to flag them as nonexistent AND dead. However, if you want the 
	 * "corpse" to remain in the game, like to animate an effect or whatever, you should override this, setting only alive to false, and leaving exists true.
	 */
	public function kill():Void
	{
		alive = false;
		exists = false;
	}
	
	/**
	 * Handy function for bringing game objects "back to life". Just sets alive and exists back to true.
	 * In practice, this function is most often called by FlxObject.reset().
	 */
	public function revive():Void
	{
		alive = true;
		exists = true;
	}
	
	/**
	 * Override this function to update your class's position and appearance.
	 * This is where most of your game rules and behavioral code will go.
	 */
	public function update(elapsed:Float):Void 
	{ 
		#if !FLX_NO_DEBUG
		activeCount++;
		#end
	}
	
	/**
	 * Override this function to control how the object is drawn.
	 * Overriding draw() is rarely necessary, but can be very useful.
	 */
	public function draw():Void
	{
		#if !FLX_NO_DEBUG
		visibleCount++;
		#end
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("visible", visible),
			LabelValuePair.weak("alive", alive),
			LabelValuePair.weak("exists", exists)]);
	}
	
	private function set_visible(Value:Bool):Bool
	{
		return visible = Value;
	}
	
	private function set_active(Value:Bool):Bool
	{
		return active = Value;
	}
	
	private function set_exists(Value:Bool):Bool
	{
		return exists = Value;
	}
	
	private function set_alive(Value:Bool):Bool
	{
		return alive = Value;
	}
	
	private function get_camera():FlxCamera
	{
		return (_cameras == null || _cameras.length == 0) ? FlxCamera.defaultCameras[0] : _cameras[0];
	}
	
	private function set_camera(Value:FlxCamera):FlxCamera
	{
		if (_cameras == null)
			_cameras = [Value];
		else
			_cameras[0] = Value;
		return Value;
	}
	
	private function get_cameras():Array<FlxCamera>
	{
		return (_cameras == null) ? FlxCamera.defaultCameras : _cameras;
	}
	
	private function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		return _cameras = Value;
	}
}

/**
 * Types of flixel objects - mainly for collisions.
 * 
 * Abstracted from an Int type for fast comparison code:
 * http://nadako.tumblr.com/post/64707798715/cool-feature-of-upcoming-haxe-3-2-enum-abstracts
 */
@:enum
abstract FlxType(Int)
{
	var NONE        = 0;
	var OBJECT      = 1;
	var GROUP       = 2;
	var TILEMAP     = 3;
	var SPRITEGROUP = 4;
}

interface IFlxBasic
{
	public var ID:Int;
	public var active(default, set):Bool;
	public var visible(default, set):Bool;
	public var alive(default, set):Bool;
	public var exists(default, set):Bool;

	public function draw():Void;
	public function update(elapsed:Float):Void;
	public function destroy():Void;
	
	public function kill():Void;
	public function revive():Void;
	
	public function toString():String;
}
