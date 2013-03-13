package org.flixel.addons;

import org.flixel.FlxCamera;
import org.flixel.FlxG;

/**
 * ZoomCamera: A FlxCamera that centers its zoom on the target that it follows 
 * Flixel version: 2.5+
 * 
 * @link http://www.kwarp.com
 * @author greglieberman
 * @email greg@kwarp.com
 * 
 */
class ZoomCamera extends FlxCamera
{
	/**
	 * Tell the camera to LERP here eventually
	 */
	public var targetZoom:Float;
	
	/**
	 * This number is pretty arbitrary, make sure it's greater than zero!
	 */
	private var zoomSpeed:Float;
	
	/**
	 * Determines how far to "look ahead" when the target is near the edge of the camera's bounds
	 * 0 = no effect, 1 = huge effect
	 */
	private var zoomMargin:Float;
	
	public function new(X:Int, Y:Int, Width:Int, Height:Int, Zoom:Float = 0)
	{
		super(X, Y, Width, Height, FlxCamera.defaultZoom);
		zoomSpeed = 25;
		zoomMargin = 0.25;
		targetZoom = Zoom;
	}
	
	public override function update():Void
	{
		super.update();
		
		// update camera zoom
		zoom += (targetZoom - zoom) / 2 * (FlxG.elapsed) * zoomSpeed;
		
		// if we are zooming in, align the camera (x, y)
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
		// target position in screen space
		var targetScreenX:Float = target.x - scroll.x;
		var targetScreenY:Float = target.y - scroll.y;
		
		// center on the target, until the camera bumps up to its bounds
		// then gradually favor the edge of the screen based on zoomMargin
		var ratioMinX:Float = (targetScreenX / (width / 2) ) - 1 - zoomMargin;
		var ratioMinY:Float = (targetScreenY / (height / 2)) - 1 - zoomMargin;
		var ratioMaxX:Float = (( -width + targetScreenX) / (width / 2) ) + 1 + zoomMargin;
		var ratioMaxY:Float = (( -height + targetScreenY) / (height / 2)) + 1 + zoomMargin;
		
		// offsets are numbers between [-1, 1]
		var offsetX:Float = clamp(ratioMinX, -1, 0) + clamp(ratioMaxX, 0, 1);
		var offsetY:Float = clamp(ratioMinY, -1, 0) + clamp(ratioMaxY, 0, 1);
		
		// offset the screen in any direction, based on zoom level
		// Example: a zoom of 2 offsets it half the screen at most
		x = -(width / 2) * (offsetX) * (zoom - FlxCamera.defaultZoom);
		y = -(height / 2) * (offsetY) * (zoom - FlxCamera.defaultZoom);
	}
	
	/**
	 * Given a value passed in, returns a Number between min and max (inclusive)
	 * 
	 * @param value		the Number you want to evaluate
	 * @param min		the minimum number that should be returned
	 * @param max		the maximum number that should be returned
	 * @return 			value clamped between min and max
	 * 
	 */
	private function clamp(value:Float, min:Float, max:Float):Float
	{
		if(value < min) return min;
		if(value > max) return max;
		return value;
	}
	
	override public function setScale(X:Float, Y:Float):Void 
	{
		_flashSprite.scaleX = X;
		_flashSprite.scaleY = Y;
	}
}