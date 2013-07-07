package flixel.addons.display;

import flixel.FlxCamera;
import flixel.FlxG;

/**
 * ZoomCamera: A FlxCamera that centers its zoom on the target that it follows 
 * Flixel version: 2.5+
 * 
 * @link http://www.kwarp.com
 * @author greglieberman
 * @email greg@kwarp.com
 */
class FlxZoomCamera extends FlxCamera
{
	/**
	 * Tell the camera to LERP here eventually
	 */
	public var targetZoom:Float;
	
	/**
	 * This number is pretty arbitrary, make sure it's greater than zero!
	 */
	private var _zoomSpeed:Float;
	
	/**
	 * Determines how far to "look ahead" when the target is near the edge of the camera's bounds
	 * 0 = no effect, 1 = huge effect
	 */
	private var _zoomMargin:Float;
	
	public function new(X:Int, Y:Int, Width:Int, Height:Int, Zoom:Float = 0)
	{
		super(X, Y, Width, Height, FlxCamera.defaultZoom);
		
		_zoomSpeed = 25;
		_zoomMargin = 0.25;
		targetZoom = Zoom;
	}
	
	public override function update():Void
	{
		super.update();
		
		// Update camera zoom
		zoom += (targetZoom - zoom) / 2 * (FlxG.elapsed) * _zoomSpeed;
		
		// If we are zooming in, align the camera (x, y)
		if (target != null && zoom != 1)
		{
			alignCamera();
		}
		else
		{
			x = 0;
			y = 0;
		}
	}
	
	/**
	 * Align the camera x and y to center on the target 
	 * that it's following when zoomed in
	 * 
	 * This took many guesses! 
	 */
	private function alignCamera():Void
	{	
		// Target position in screen space
		var targetScreenX:Float = target.x - scroll.x;
		var targetScreenY:Float = target.y - scroll.y;
		
		// Center on the target, until the camera bumps up to its bounds
		// then gradually favor the edge of the screen based on _zoomMargin
		var ratioMinX:Float = (targetScreenX / (width / 2) ) - 1 - _zoomMargin;
		var ratioMinY:Float = (targetScreenY / (height / 2)) - 1 - _zoomMargin;
		var ratioMaxX:Float = (( -width + targetScreenX) / (width / 2) ) + 1 + _zoomMargin;
		var ratioMaxY:Float = (( -height + targetScreenY) / (height / 2)) + 1 + _zoomMargin;
		
		// Offsets are numbers between [-1, 1]
		var offsetX:Float = clamp(ratioMinX, -1, 0) + clamp(ratioMaxX, 0, 1);
		var offsetY:Float = clamp(ratioMinY, -1, 0) + clamp(ratioMaxY, 0, 1);
		
		// Offset the screen in any direction, based on zoom level
		// Example: a zoom of 2 offsets it half the screen at most
		x = -(width / 2) * (offsetX) * (zoom - FlxCamera.defaultZoom);
		y = -(height / 2) * (offsetY) * (zoom - FlxCamera.defaultZoom);
	}
	
	/**
	 * Given a value passed in, returns a Number between min and max (inclusive)
	 * 
	 * @param 	Value	The Number you want to evaluate
	 * @param 	Min		The minimum number that should be returned
	 * @param 	Max		The maximum number that should be returned
	 * @return 	Value clamped between min and max
	 * 
	 */
	private function clamp(Value:Float, Min:Float, Max:Float):Float
	{
		if (Value < Min) 
		{
			return Min;
		}
		if (Value > Max) 
		{
			return Max;
		}
		
		return Value;
	}
	
	override public function setScale(X:Float, Y:Float):Void 
	{
		_flashSprite.scaleX = X;
		_flashSprite.scaleY = Y;
	}
}