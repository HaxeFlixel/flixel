package flixel.system.debug;

import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.display.Graphics;

abstract FlxDebugDrawGraphic(Graphics) from Graphics to Graphics
{
	inline function useHardware(sizeSquared:Float)
	{
		return FlxG.renderTile && sizeSquared > 100 * 100;
	}
	
	public function drawBoundingBox(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness = 1.0)
	{
		if (useHardware(width * height))
		{
			this.beginFill(color.rgb, color.alphaFloat);
			this.drawRect(x, y, thickness, height); // left
			this.drawRect(x + thickness, y, width - thickness * 2, thickness); // top
			this.drawRect(x + width - thickness, y, thickness, height); // right
			this.drawRect(x + thickness, y + height - thickness, width - thickness * 2, thickness); // bottom
			this.endFill();
		}
		else
		{
			this.lineStyle(thickness, color.rgb, color.alphaFloat);
			final half = thickness * 0.5;
			
			this.drawRect(x + half, y + half, width - thickness, height - thickness);
		}
	}
	
	public function drawLine(x1:Float, y1:Float, x2:Float, y2:Float, color:FlxColor, thickness = 1.0)
	{
		this.lineStyle(thickness, color.rgb, color.alphaFloat);
		
		this.moveTo(x1, y1);
		this.lineTo(x2, y2);
	}
	
	public function drawRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor)
	{
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawRect(x, y, width, height);
		this.endFill();
	}
}
