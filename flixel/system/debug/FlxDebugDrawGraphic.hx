package flixel.system.debug;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.math.FlxPoint;
import openfl.display.Graphics;

abstract FlxDebugDrawGraphic(Graphics) from Graphics to Graphics
{
	inline function useFill()
	{
		// true for testing
		return true;
		//return #if (cpp || hl) false #else FlxG.renderTile #end;
	}
	
	public function drawBoundingBox(x:Float, y:Float, width:Float, height:Float, color:FlxColor, thickness = 1.0)
	{
		if (useFill())
		{
			this.beginFill(color.rgb, color.alphaFloat);
			
			this.drawRect(x - thickness, y - thickness, thickness, height + thickness);
			this.drawRect(x, y - thickness, width + thickness, thickness);
			this.drawRect(x + width, y, thickness, height - thickness);
			this.drawRect(x, y + height - thickness, width + thickness, thickness);
			
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
		if (useFill())
		{
			this.beginFill(color.rgb, color.alphaFloat);
			final normal = FlxPoint.get(x2 - x1, y2 - y1).leftNormal();
			normal.length = thickness;
			
			this.moveTo(x1 + normal.x, y1 + normal.y);
			this.lineTo(x2 + normal.x, y2 + normal.y);
			this.lineTo(x2 - normal.x, y2 - normal.y);
			this.lineTo(x1 - normal.x, y1 - normal.y);
			
			this.endFill();
			normal.put();
		}
		else
		{
			
			this.lineStyle(thickness, color.rgb, color.alphaFloat);
			
			this.moveTo(x1, y1);
			this.lineTo(x2, y2);
		}
	}
	
	public function drawRect(x:Float, y:Float, width:Float, height:Float, color:FlxColor)
	{
		// always use fill
		this.beginFill(color.rgb, color.alphaFloat);
		this.drawRect(x, y, width, height);
		this.endFill();
	}
}
