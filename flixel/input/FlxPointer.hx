package flixel.input;

import flixel.FlxCamera;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;

class FlxPointer
{
	/** The position in the world */
	public var x(default, null):Int = 0;
	/** The position in the world */
	public var y(default, null):Int = 0;
	
	/** The world position relative to the main camera's scroll position */
	@:deprecated("screenX is deprecated, use viewX, instead")
	public var screenX(default, never):Int = 0;
	/** The world position relative to the main camera's scroll position */
	@:deprecated("screenY is deprecated, use viewY, instead")
	public var screenY(default, never):Int = 0;
	
	/**
	 * The world position relative to the main camera's scroll position, `cam.viewMarginX` or
	 * `cam.viewMarginLeft` is the left edge of the camera and `cam.viewMarginRight` is the right
	 * 
	 * @since 5.9.0
	 */
	public var viewX(default, null):Int = 0;
	/**
	 * The world position relative to the main camera's scroll position, `cam.viewMarginY` or
	 * `cam.viewMarginTop` is the top edge of the camera and `cam.viewMarginBottom` is the bottom
	 * 
	 * @since 5.9.0
	 */
	public var viewY(default, null):Int = 0;
	
	/**
	 * The position relative to the `FlxGame`'s position in the window,
	 * where `0` is the left edge of the game and `FlxG.width` is the right
	 * 
	 * @since 5.9.0
	 */
	public var gameX(default, null):Int = 0;
	/**
	 * The position relative to the `FlxGame`'s position in the window,
	 * where `0` is the top edge of the game and `FlxG.height` is the bottom
	 * 
	 * @since 5.9.0
	 */
	public var gameY(default, null):Int = 0;

	@:deprecated("_globalScreenX is deprecated, use gameX, instead") // 5.9.0
	var _globalScreenX(get, set):Int;
	@:deprecated("_globalScreenY is deprecated, use gameY, instead") // 5.9.0
	var _globalScreenY(get, set):Int;
	
	var _rawX(default, null):Float = 0;
	var _rawY(default, null):Float = 0;

	static var _cachedPoint:FlxPoint = new FlxPoint();

	public function new() {}

	/**
	 * Fetch the world position of the pointer on any given camera
	 * 
	 * **Note:** Fields `x` and `y` also store this result
	 *
	 * @param   camera  If unspecified, `FlxG.camera` is used, instead
	 * @param   result  An existing point to store the results, if unspecified, one is created
	 */
	public function getWorldPosition(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		if (camera == null)
			camera = FlxG.camera;
		
		result = getViewPosition(camera, result);
		result.addPoint(camera.scroll);
		return result;
	}
	
	/**
	 * The position relative to the game's position in the window, where `(0, 0)` is the
	 * top-left edge of the game and `(FlxG.width, FlxG.height)` is the bottom-right
	 * 
	 * **Note:** Fields `gameX` and `gameY` also store this result
	 * 
	 * @param   result  An existing point to store the results, if unspecified, one is created
	 * @since 5.9.0
	 */
	public function getGamePosition(?result:FlxPoint):FlxPoint
	{
		if (result == null)
			return FlxPoint.get();
		
		return result.set(Std.int(_rawX), Std.int(_rawY));
	}
	
	/**
	 * Fetch the world position relative to the main camera's `scroll` position, where
	 * `(cam.viewMarginLeft, cam.viewMarginTop)` is the top-left of the camera and
	 * `(cam.viewMarginRight, cam.viewMarginBottom)` is the bottom right
	 * 
	 * **Note:** Fields `viewX` and `viewY` also store this result
	 *
	 * @param   camera  If unspecified, `FlxG.camera` is used, instead
	 * @param   result  An existing point to store the results, if unspecified, one is created
	 */
	public function getViewPosition(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		if (camera == null)
			camera = FlxG.camera;
		
		if (result == null)
			result = FlxPoint.get();
		
		result.x = Std.int((gameX - camera.x) / camera.zoom + camera.viewMarginX);
		result.y = Std.int((gameY - camera.y) / camera.zoom + camera.viewMarginY);
		
		return result;
	}
	
	/**
	 * Fetch the position of the pointer relative to given camera's `scroll` position, where
	 * `(cam.viewMarginLeft, cam.viewMarginTop)` is the top-left of the camera and
	 * `(cam.viewMarginRight, cam.viewMarginBottom)` is the bottom right of the camera
	 * 
	 * **Note:** Fields `viewX` and `viewY` also store this result for `FlxG.camera`
	 * 
	 * @param   camera  If unspecified, `FlxG.camera` is used, instead
	 * @param   result  An existing point to store the results, if unspecified, one is created
	 */
	@:deprecated("getScreenPosition is deprecated, use getViewPosition, instead") // 5.9.0
	public function getScreenPosition(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		if (camera == null)
			camera = FlxG.camera;
		
		if (result == null)
			result = FlxPoint.get();
		
		result.x = (gameX - camera.x + 0.5 * camera.width * (camera.zoom - camera.initialZoom)) / camera.zoom;
		result.y = (gameY - camera.y + 0.5 * camera.height * (camera.zoom - camera.initialZoom)) / camera.zoom;
		
		return result;
	}
	
	/**
	 * Fetch the position of the pointer relative to given camera's `scroll` position, where
	 * `(cam.viewMarginLeft, cam.viewMarginTop)` is the top-left of the camera and
	 * `(cam.viewMarginRight, cam.viewMarginBottom)` is the bottom right of the camera
	 * 
	 * **Note:** Fields `viewX` and `viewY` also store this result for `FlxG.camera`
	 * 
	 * @param   camera  If unspecified, `FlxG.camera` is used, instead.
	 * @param   result  An existing point to store the results, if unspecified, one is created
	 * @return  The pointer's location relative to camera's viewport.
	 */
	@:deprecated("getPositionInCameraView is deprecated, use getViewPosition, instead") // 5.9.0
	public function getPositionInCameraView(?camera:FlxCamera, ?result:FlxPoint):FlxPoint
	{
		if (camera == null)
			camera = FlxG.camera;
		
		if (result == null)
			result = FlxPoint.get();
		
		result.x = (gameX - camera.x) / camera.zoom + camera.viewMarginX;
		result.y = (gameY - camera.y) / camera.zoom + camera.viewMarginY;
		
		return result;
	}
	
	/**
	 * Returns a FlxPoint with this input's x and y.
	 */
	public function getPosition(?result:FlxPoint):FlxPoint
	{
		if (result == null)
			return FlxPoint.get(x, y);
		
		return result.set(x, y);
	}
	
	/**
	 * Checks to see if this pointer overlaps some `FlxObject` or `FlxGroup`.
	 *
	 * @param   objectOrGroup  The object or group being tested
	 * @param   camera         Helps determine the world position. If unspecified, `FlxG.camera` is used
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function overlaps(objectOrGroup:FlxBasic, ?camera:FlxCamera):Bool
	{
		// check group
		final group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null)
		{
			for (basic in group.members)
			{
				if (basic != null && overlaps(basic, camera))
				{
					return true;
				}
			}
			return false;
		}
		// check object
		getWorldPosition(camera, _cachedPoint);
		final object = cast (objectOrGroup, FlxObject);
		return object.overlapsPoint(_cachedPoint, true, camera);
	}
	
	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	@:deprecated("setGlobalScreenPositionUnsafe is deprecated, use setRawPositionUnsafe, instead")
	public inline function setGlobalScreenPositionUnsafe(newX:Float, newY:Float):Void
	{
		setRawPositionUnsafe(newX, newY);
	}
	
	/**
	 * Directly set the underyling position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 * @since 5.9.0
	 */
	@:haxe.warning("-WDeprecated")
	public function setRawPositionUnsafe(x:Float, y:Float)
	{
		_rawX = x / FlxG.scaleMode.scale.x;
		_rawY = y / FlxG.scaleMode.scale.y;
		
		updatePositions();
	}
	
	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, screenX, and screenY variables based on the default camera.
	 */
	function updatePositions():Void
	{
		getGamePosition(_cachedPoint);
		gameX = Std.int(_cachedPoint.x);
		gameY = Std.int(_cachedPoint.y);
		
		getViewPosition(FlxG.camera, _cachedPoint);
		viewX = Std.int(_cachedPoint.x);
		viewY = Std.int(_cachedPoint.y);
		
		getWorldPosition(FlxG.camera, _cachedPoint);
		x = Std.int(_cachedPoint.x);
		y = Std.int(_cachedPoint.y);
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("x", x), LabelValuePair.weak("y", y)]);
	}
	
	inline function get__globalScreenX():Int
	{
		return gameX;
	}
	
	inline function get__globalScreenY():Int
	{
		return gameY;
	}
	
	inline function set__globalScreenX(value:Int):Int
	{
		_rawX = value * FlxG.scaleMode.scale.x;
		return value;
	}
	
	inline function set__globalScreenY(value:Int):Int
	{
		_rawY = value * FlxG.scaleMode.scale.y;
		return value;
	}
}
