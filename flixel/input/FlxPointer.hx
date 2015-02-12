package flixel.input;

import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxStringUtil;

class FlxPointer
{
	public var x(default, null):Int = 0;
	public var y(default, null):Int = 0;
	
	public var screenX(default, null):Int = 0;
	public var screenY(default, null):Int = 0;
	
	private var _globalScreenX:Int = 0;
	private var _globalScreenY:Int = 0;
	
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
		if (point == null)
		{
			point = FlxPoint.get();
		}
		var screenPosition:FlxPoint = getScreenPosition(Camera);
		point.x = screenPosition.x + Camera.scroll.x;
		point.y = screenPosition.y + Camera.scroll.y;
		screenPosition.put();
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
		if (point == null)
		{
			point = FlxPoint.get();
		}
		
		point.x = (_globalScreenX - Camera.x + 0.5 * Camera.width * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;
		point.y = (_globalScreenY - Camera.y + 0.5 * Camera.height * (Camera.zoom - Camera.initialZoom)) / Camera.zoom;
		
		return point;
	}
	
	/**
	 * Returns a FlxPoint with this input's x and y.
	 */
	public inline function toPoint():FlxPoint
	{
		return FlxPoint.get(x, y);
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
			group.forEachExists(function(basic:FlxBasic) {
				if (overlaps(basic, Camera)) 
				{
					result = true;
					return;
				}
			});
		}
		else 
		{
			var point:FlxPoint = toPoint();
			result = cast(ObjectOrGroup, FlxObject).overlapsPoint(point, true, Camera);
			point.put();
		}
		
		return result;
	}
	
	/**
	 * Directly set the underyling screen position variable. WARNING! You should never use
	 * this unless you are trying to manually dispatch low-level mouse / touch events to the stage.
	 */
	public inline function setGlobalScreenPositionUnsafe(X:Int, Y:Int):Void 
	{
		_globalScreenX = X;
		_globalScreenY = Y;
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
		var screenPosition:FlxPoint = getScreenPosition();
		screenX = Std.int(screenPosition.x);
		screenY = Std.int(screenPosition.y);
		screenPosition.put();
		
		var worldPosition = getWorldPosition();
		x = Std.int(worldPosition.x);
		y = Std.int(worldPosition.y);
		worldPosition.put();
	}
}