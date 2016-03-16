package flixel.input;

import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.util.FlxStringUtil;
import flixel.group.FlxGroup.FlxTypedGroup;

class FlxPointer
{
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	
	public var screenX(default, null):Int = 0;
	public var screenY(default, null):Int = 0;
	
	private var _globalScreenX:Int = 0;
	private var _globalScreenY:Int = 0;
	private static var _cachedPoint:FlxVector = FlxVector.get();
	
	public function new() {}
	
	/**
	 * Fetch the world position of the pointer on any given camera.
	 * NOTE: x and y also store the world position of the pointer on the main camera.
	 * 
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point	An existing point object to store the results (if you don't want a new one created). 
	 * @return 	The touch point's location in world space.
	 */
	public function getWorldPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		getScreenPosition(Camera, _cachedPoint);
		
		_cachedPoint.x = _cachedPoint.x + Camera.scroll.x;
		_cachedPoint.y = _cachedPoint.x + Camera.scroll.y;
		
		if (point == null)
		{
			point = FlxPoint.get(_cachedPoint.x, _cachedPoint.y);
		}
		else if(point != _cachedPoint)
		{
			point.copyFrom(_cachedPoint);
		}
		
		return point;
	}
	
	/**
	 * Fetch the screen position of the pointer on any given camera.
	 * NOTE: screenX and screenY also store the screen position of the pointer on the main camera.
	 * 
	 * @param 	Camera	If unspecified, first/main global camera is used instead.
	 * @param 	point		An existing point object to store the results (if you don't want a new one created). 
	 * @return 	The touch point's location in screen space.
	 */
	public function getScreenPosition(?Camera:FlxCamera, ?point:FlxPoint):FlxPoint
	{
		if (Camera == null)
		{
			Camera = FlxG.camera;
		}
		
		_cachedPoint.x = (_globalScreenX - Camera.x + 0.5 * Camera.width * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;
		_cachedPoint.y = (_globalScreenY - Camera.y + 0.5 * Camera.height * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;
		
		if (point == null)
		{
			point = FlxPoint.getFrom(_cachedPoint);
		}
		else if(point != _cachedPoint)
		{
			point.copyFrom(_cachedPoint);
		}
		
		return point;
	}
	
	/**
	 * Returns a FlxPoint with this input's x and y.
	 */
	public function getPosition(?point:FlxPoint):FlxPoint
	{
		_cachedPoint.x = x;
		_cachedPoint.y = y;
		
		if (point == null)
		{
			point = FlxPoint.getFrom(_cachedPoint);
		}
		else if(point != _cachedPoint)
		{
			point.copyFrom(_cachedPoint);
		}
		
		return point.set(x, y);
	}
	
	/**
	 * Checks to see if some FlxObject overlaps this FlxObject or FlxGroup.
	 * If the group has a LOT of things in it, it might be faster to use FlxG.overlaps().
	 * WARNING: Currently tilemaps do NOT support screen space overlap checks!
	 * 
	 * @param 	ObjectOrGroup The object or group being tested.
	 * @param 	Camera Specify which game camera you want. If null getScreenPosition() will just grab the first global camera.
	 * @return 	Whether or not the two objects overlap.
	 */
	public function overlaps(ObjectOrGroup:FlxBasic, ?Camera:FlxCamera):Bool
	{
		var result:Bool = false;
		
		var group = FlxTypedGroup.resolveGroup(ObjectOrGroup);
		if (group != null)
		{
			group.forEachExists(function(basic:FlxBasic)
			{
				if (overlaps(basic, Camera)) 
				{
					result = true;
					return;
				}
			});
		}
		else 
		{
			getPosition(_cachedPoint);
			var object:FlxObject = cast ObjectOrGroup;
			result = object.overlapsPoint(_cachedPoint, true, Camera);
		}
		
		return result;
	}
	
	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	public inline function setGlobalScreenPositionUnsafe(newX:Float, newY:Float):Void 
	{
		_globalScreenX = Std.int(newX / FlxG.scaleMode.scale.x);
		_globalScreenY = Std.int(newY / FlxG.scaleMode.scale.y);
		
		updatePositions();
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([ 
			LabelValuePair.weak("x", x),
			LabelValuePair.weak("y", y)]);
	}
	
	/**
	 * Helper function to update the cursor used by update() and playback().
	 * Updates the x, y, screenX, and screenY variables based on the default camera.
	 */
	private function updatePositions():Void
	{
		getScreenPosition(FlxG.camera, _cachedPoint);
		screenX = Std.int(_cachedPoint.x);
		screenY = Std.int(_cachedPoint.y);
		
		getWorldPosition(FlxG.camera, _cachedPoint);
		x = Std.int(_cachedPoint.x);
		y = Std.int(_cachedPoint.y);
	}
}