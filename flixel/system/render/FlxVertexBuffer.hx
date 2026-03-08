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
abstract FlxVertexBuffer(Graphics) from Graphics to Graphics
{
	/**
	 * Wipes all drawn vertices from the buffer
	 */
	public inline function clear():Void
	{
		this.clear();
	}
	
	/**
	 * Draws a hollow axis-aligned rectangle to the buffer
	 * @param   x          
	 * @param   y          
	 * @param   width      
	 * @param   height     
	 * @param   color      The Color of the outline
	 * @param   thickness  The thickness of the outline
	 */
	public function drawRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		this.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		this.drawRect(x, y, width, height);
	}
	
	/**
	 * Draws a solid axis-aligned rectangle to the buffer
	 */
	public function drawFilledRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor):Void
	{
		this.lineStyle();
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawRect(x, y, width, height);
		this.endFill();
	}
	
	/**
	 * Draws an antialiased solid circle to the buffer
	 */
	public function drawFilledCircle(x:Float, y:Float, radius:Float, color:FlxColor):Void
	{
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawCircle(x, y, radius);
		this.endFill();
	}
	
	/**
	 * Draws an antialiased line to the buffer
	 */
	public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness:Float = 1.0):Void
	{
		this.lineStyle(thickness, color.rgb, color.alphaFloat, false, null, null, MITER, 255);
		this.moveTo(x1, y1);
		this.lineTo(x2, y2);
	}
}