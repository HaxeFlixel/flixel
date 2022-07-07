package flixel.input;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.input.FlxInput;
import flixel.math.FlxPoint;
import flixel.util.FlxAxes;
import flixel.util.FlxStringUtil;

class FlxPointer
{
	/** World x Position of the pointer. */
	public var x(default, null):Int = 0;
	/** World y Position of the pointer. */
	public var y(default, null):Int = 0;
	
	/** Screen x Position of the pointer. */
	public var screenX(default, null):Int = 0;
	/** Screen y Position of the pointer. */
	public var screenY(default, null):Int = 0;
	
	/**
	 * Whether the pointer was stopped and started mving, this frame
	 * @since 5.0.0
	 */
	public var justMoved(get, never):Bool;
	
	/**
	 * Whether the pointer moved this frame
	 * @since 5.0.0
	 */
	public var moved(get, never):Bool;
	
	/**
	 * Whether the pointer was moving and stopped this frame
	 * @since 5.0.0
	 */
	public var justStopped(get, never):Bool;
	
	/** Whether the pointer did not move this frame
	 * @since 5.0.0
	 */
	public var stopped(get, never):Bool;
	
	/** Used to track the movement of the raw mouse values */
	var inputX = new FlxAnalogInput(FlxAxes.X, false);
	/** Used to track the movement of the raw mouse values */
	var inputY = new FlxAnalogInput(FlxAxes.Y, false);
	
	/** Helper for the raw position used to calculate world and screen coordinates */
	var currentX(get, never):Float;
	/** Helper for the raw position used to calculate world and screen coordinates */
	var currentY(get, never):Float;
	/** Helper for the previous position */
	var lastX(get, never):Float;
	/** Helper for the previous position */
	var lastY(get, never):Float;
	
	/** For backwards compatibility */
	@:deprecated("Use currentX and inputX.change()")
	var _globalScreenX(get, set):Int;
	
	/** For backwards compatibility */
	@:deprecated("Use currentY and inputY.change()")
	var _globalScreenY(get, set):Int;
	
	static var _cachedPoint:FlxPoint = new FlxPoint();
	
	public function new() {}
	
	function update():Void
	{
		inputX.update();
		inputY.update();
	}

	/**
	 * Fetch the world position of the pointer on any given camera.
	 * NOTE: x and y also store the world position of the pointer on the main camera.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   point   An existing point object to store the results (if you don't want a new one created).
	 * @return  The touch point's location in world space.
	 */
	public function getWorldPosition(?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (camera == null)
		{
			camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}
		getScreenPosition(camera, _cachedPoint);
		point.x = _cachedPoint.x + camera.scroll.x;
		point.y = _cachedPoint.y + camera.scroll.y;
		return point;
	}

	/**
	 * Fetch the screen position of the pointer on any given camera.
	 * NOTE: screenX and screenY also store the screen position of the pointer on the main camera.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   point   An existing point object to store the results (if you don't want a new one created).
	 * @return  The touch point's location in screen space.
	 */
	public function getScreenPosition(?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (camera == null)
		{
			camera = FlxG.camera;
		}
		if (point == null)
		{
			point = FlxPoint.get();
		}

		point.x = (currentX - camera.x + 0.5 * camera.width * (camera.zoom - camera.initialZoom)) / camera.zoom;
		point.y = (currentY - camera.y + 0.5 * camera.height * (camera.zoom - camera.initialZoom)) / camera.zoom;

		return point;
	}

	/**
	 * Fetch the screen position of the pointer relative to given camera's viewport.
	 *
	 * @param   camera  If unspecified, first/main global camera is used instead.
	 * @param   point   An existing point object to store the results (if you don't want a new one created).
	 * @return  The touch point's location relative to camera's viewport.
	 */
	@:access(flixel.FlxCamera)
	public function getPositionInCameraView(?camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (camera == null)
			camera = FlxG.camera;

		if (point == null)
			point = FlxPoint.get();

		point.x = (currentX - camera.x) / camera.zoom + camera.viewOffsetX;
		point.y = (currentY - camera.y) / camera.zoom + camera.viewOffsetY;

		return point;
	}

	/**
	 * Returns a FlxPoint with this input's x and y.
	 */
	public function getPosition(?point:FlxPoint):FlxPoint
	{
		if (point == null)
			point = FlxPoint.get();
		return point.set(x, y);
	}

	/**
	 * Checks to see if some FlxObject overlaps this FlxObject or FlxGroup.
	 * If the group has a LOT of things in it, it might be faster to use FlxG.overlaps().
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 *
	 * @param   objectOrGroup  The object or group being tested.
	 * @param   camera         Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return  Whether or not the two objects overlap.
	 */
	@:access(flixel.group.FlxTypedGroup.resolveGroup)
	public function overlaps(objectOrGroup:FlxBasic, ?camera:FlxCamera):Bool
	{
		var result = false;

		var group = FlxTypedGroup.resolveGroup(objectOrGroup);
		if (group != null)
		{
			group.forEachExists(function(basic:FlxBasic)
			{
				if (overlaps(basic, camera))
				{
					result = true;
					return;
				}
			});
		}
		else
		{
			getPosition(_cachedPoint);
			var object:FlxObject = cast objectOrGroup;
			result = object.overlapsPoint(_cachedPoint, true, camera);
		}

		return result;
	}

	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	public inline function setGlobalScreenPositionUnsafe(newX:Float, newY:Float):Void
	{
		inputX.change(newX / FlxG.scaleMode.scale.x);
		inputY.change(newY / FlxG.scaleMode.scale.y);

		updatePositions();
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("x", x), LabelValuePair.weak("y", y)]);
	}

	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, screenX, and screenY variables based on the default camera.
	 */
	function updatePositions():Void
	{
		getScreenPosition(FlxG.camera, _cachedPoint);
		screenX = Std.int(_cachedPoint.x);
		screenY = Std.int(_cachedPoint.y);

		getWorldPosition(FlxG.camera, _cachedPoint);
		x = Std.int(_cachedPoint.x);
		y = Std.int(_cachedPoint.y);
	}
	
	inline function get_currentX()
	{
		return inputX.currentValue;
	}
	
	inline function get_currentY()
	{
		return inputY.currentValue;
	}
	
	inline function get_lastX()
	{
		return inputX.lastValue;
	}
	
	inline function get_lastY()
	{
		return inputY.lastValue;
	}
	
	inline function get_moved():Bool
	{
		return inputX.moved || inputY.moved;
	}
	
	inline function get_justMoved():Bool
	{
		return inputX.justMoved || inputY.justMoved;
	}
	
	inline function get_stopped():Bool
	{
		return inputX.stopped && inputY.stopped;
	}
	
	inline function get_justStopped():Bool
	{
		return stopped && (inputX.justStopped || inputY.justStopped);
	}
	
	inline function get__globalScreenX()
	{
		return Std.int(currentX);
	}
	
	inline function set__globalScreenX(value:Int)
	{
		inputX.change(value);
		return value;
	}
	
	inline function get__globalScreenY()
	{
		return Std.int(currentY);
	}
	
	inline function set__globalScreenY(value:Int)
	{
		inputY.change(value);
		return value;
	}
}
