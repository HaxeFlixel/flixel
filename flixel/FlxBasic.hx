package flixel;

import flixel.util.FlxDestroyUtil.IFlxDestroyable;
import flixel.util.FlxStringUtil;

/**
 * This is a useful "generic" Flixel object. Both `FlxObject` and
 * `FlxGroup` extend this class. Has no size, position or graphical data.
 */
class FlxBasic implements IFlxDestroyable
{
	#if FLX_DEBUG
	/**
	 * Static counters for performance tracking.
	 */
	@:allow(flixel.FlxGame)
	static var activeCount:Int = 0;

	@:allow(flixel.FlxGame)
	static var visibleCount:Int = 0;
	#end

	/**
	 * A unique ID starting from 0 and increasing by 1 for each subsequent `FlxBasic` that is created.
	 */
	public var ID:Int = idEnumerator++;

	@:noCompletion
	static var idEnumerator:Int = 0;

	/**
	 * Controls whether `update()` is automatically called by `FlxState`/`FlxGroup`.
	 */
	public var active(default, set):Bool = true;

	/**
	 * Controls whether `draw()` is automatically called by `FlxState`/`FlxGroup`.
	 */
	public var visible(default, set):Bool = true;

	/**
	 * Useful state for many game objects - "dead" (`!alive`) vs `alive`. `kill()` and
	 * `revive()` both flip this switch (along with `exists`, but you can override that).
	 */
	public var alive(default, set):Bool = true;

	/**
	 * Controls whether `update()` and `draw()` are automatically called by `FlxState`/`FlxGroup`.
	 */
	public var exists(default, set):Bool = true;

	/**
	 * Gets or sets the first camera of this object.
	 */
	public var camera(get, set):FlxCamera;

	/**
	 * This determines on which `FlxCamera`s this object will be drawn. If it is `null` / has not been
	 * set, it uses the list of default draw targets, which is controlled via `FlxG.camera.setDefaultDrawTarget`
	 * as well as the `DefaultDrawTarget` argument of `FlxG.camera.add`.
	 */
	public var cameras(get, set):Array<FlxCamera>;

	/**
	 * Enum that informs the collision system which type of object this is (to avoid expensive type casting).
	 */
	@:noCompletion
	var flixelType(default, null):FlxType = NONE;

	@:noCompletion
	var _cameras:Array<FlxCamera>;

	public function new() {}

	/**
	 * **WARNING:** A destroyed `FlxBasic` can't be used anymore.
	 * It may even cause crashes if it is still part of a group or state.
	 * You may want to use `kill()` instead if you want to disable the object temporarily only and `revive()` it later.
	 *
	 * This function is usually not called manually (Flixel calls it automatically during state switches for all `add()`ed objects).
	 *
	 * Override this function to `null` out variables manually or call `destroy()` on class members if necessary.
	 * Don't forget to call `super.destroy()`!
	 */
	public function destroy():Void
	{
		exists = false;
		_cameras = null;
	}

	/**
	 * Handy function for "killing" game objects. Use `reset()` to revive them.
	 * Default behavior is to flag them as nonexistent AND dead.
	 * However, if you want the "corpse" to remain in the game, like to animate an effect or whatever,
	 * you should `override` this, setting only `alive` to `false`, and leaving `exists` `true`.
	 */
	public function kill():Void
	{
		alive = false;
		exists = false;
	}

	/**
	 * Handy function for bringing game objects "back to life". Just sets `alive` and `exists` back to `true`.
	 * In practice, this function is most often called by `FlxObject#reset()`.
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
		#if FLX_DEBUG
		activeCount++;
		#end
	}

	/**
	 * Override this function to control how the object is drawn.
	 * Doing so is rarely necessary, but can be very useful.
	 */
	public function draw():Void
	{
		#if FLX_DEBUG
		visibleCount++;
		#end
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("active", active),
			LabelValuePair.weak("visible", visible),
			LabelValuePair.weak("alive", alive),
			LabelValuePair.weak("exists", exists)
		]);
	}

	@:noCompletion
	function set_visible(Value:Bool):Bool
	{
		return visible = Value;
	}

	@:noCompletion
	function set_active(Value:Bool):Bool
	{
		return active = Value;
	}

	@:noCompletion
	function set_exists(Value:Bool):Bool
	{
		return exists = Value;
	}

	@:noCompletion
	function set_alive(Value:Bool):Bool
	{
		return alive = Value;
	}

	@:noCompletion
	function get_camera():FlxCamera
	{
		return (_cameras == null || _cameras.length == 0) ? FlxCamera._defaultCameras[0] : _cameras[0];
	}

	@:noCompletion
	function set_camera(Value:FlxCamera):FlxCamera
	{
		if (_cameras == null)
			_cameras = [Value];
		else
			_cameras[0] = Value;
		return Value;
	}

	@:noCompletion
	function get_cameras():Array<FlxCamera>
	{
		return (_cameras == null) ? FlxCamera._defaultCameras : _cameras;
	}

	@:noCompletion
	function set_cameras(Value:Array<FlxCamera>):Array<FlxCamera>
	{
		return _cameras = Value;
	}
}

/**
 * Types of flixel objects - mainly for collisions.
 */
@:enum
abstract FlxType(Int)
{
	var NONE = 0;
	var OBJECT = 1;
	var GROUP = 2;
	var TILEMAP = 3;
	var SPRITEGROUP = 4;
}

interface IFlxBasic
{
	var ID:Int;
	var active(default, set):Bool;
	var visible(default, set):Bool;
	var alive(default, set):Bool;
	var exists(default, set):Bool;

	function draw():Void;
	function update(elapsed:Float):Void;
	function destroy():Void;

	function kill():Void;
	function revive():Void;

	function toString():String;
}
