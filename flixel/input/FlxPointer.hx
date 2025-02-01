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
	 * Directly set the underyling position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 * @since 5.9.0
	 */
	public function setRawPositionUnsafe(x:Float, y:Float)
	{
		_rawX = x / FlxG.scaleMode.scale.x;
		_rawY = y / FlxG.scaleMode.scale.y;
		
		updatePositions();
	}
	
	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, viewX, and viewY variables based on the default camera.
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
}
