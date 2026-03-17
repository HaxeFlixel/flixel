package flixel.system.render;

import flixel.util.FlxColor;
import openfl.display.BlendMode;
import openfl.display.Graphics;
import openfl.geom.ColorTransform;
import openfl.geom.Point;
import openfl.geom.Rectangle;

/**
 * Helper for interfacing with a openfl Graphics, in 7.0.0 this will change from
 * an abstract to a class wrapping graphic that implements an interface. All
 * references to Graphic need to be removed first
 */
@:forward
abstract FlxCanvas(Graphics) from Graphics to Graphics
{
	/**
	 * Wipes all drawn graphics from teh canvas
	 */
	public inline function clear():Void
	{
		this.clear();
	}
	
	/**
     * Draws a hollow axis-aligned rectangle to the canvas.
     * 
     * @param   x           The x position of the rectangle.
     * @param   y           The y position of the rectangle.
     * @param   width       The width of the rectangle (in pixels).
     * @param   height      The height of the rectangle (in pixels).
     * @param   color       The color (in 0xAARRGGBB hex format) of the rectangle's outline.
     * @param   thickness   The thickness of the rectangle's outline.
     */
	public function drawRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		this.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		this.drawRect(x, y, width, height);
	}
	
    /**
     * Draws a solid axis-aligned rectangle to the canvas.
     * 
     * @param   x           The x position of the rectangle.
     * @param   y           The y position of the rectangle.
     * @param   width       The width of the rectangle (in pixels).
     * @param   height      The height of the rectangle (in pixels).
     * @param   color       The color (in 0xAARRGGBB hex format) of the rectangle's fill.
     */
	public function drawFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		this.lineStyle();
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawRect(x, y, width, height);
		this.endFill();
	}
	
	/**
	 * Draws a filled circle to the canvas.
     * 
	 * @param   x        The x position of the circle.
	 * @param   y        The y position of the circle.
	 * @param   radius   The radius of the circle.
	 * @param   color    The color (in 0xAARRGGBB hex format) of the circle's fill.
	 */
	public function drawFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void
	{
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawCircle(x, y, radius);
		this.endFill();
	}
	
	/**
	 * Draws a line to the canvas.
     * 
	 * @param   x1          The start x position of the line.
	 * @param   y1          The start y position of the line.
	 * @param   x2          The end x position of the line.
	 * @param   y2          The end y position of the line.
	 * @param   color       The color (in 0xAARRGGBB hex format) of the line.
	 * @param   thickness   The thickness of the line.
	 */
	public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		this.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		this.moveTo(x1, y1);
		this.lineTo(x2, y2);
	}
}
