package flixel.graphics.tile;

import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import openfl.geom.Matrix;

class FlxDrawStackItem
{
	public var graphics:FlxGraphic;
	public var drawData:Array<Float> = [];
	public var position:Int = 0;
	public var next:FlxDrawStackItem;
	
	public var colored:Bool = false;
	public var blending:Int = 0;
	
	public var initialized:Bool = false;
	
	public var antialiasing:Bool = false;
	
	public function new() {}
	
	public inline function reset():Void
	{
		graphics = null;
		initialized = false;
		antialiasing = false;
		position = 0;
	}
	
	public inline function dispose():Void
	{
		graphics = null;
		drawData = null;
		next = null;
	}
	
	public inline function setDrawData(coordinate:FlxPoint, ID:Float, matrix:Matrix,
		isColored:Bool = false, color:FlxColor = FlxColor.WHITE, alpha:Float = 1):Void
	{
		drawData[position++] = coordinate.x;
		drawData[position++] = coordinate.y;
		
		drawData[position++] = ID;
		
		drawData[position++] = matrix.a;
		drawData[position++] = matrix.b;
		drawData[position++] = matrix.c;
		drawData[position++] = matrix.d;
		
		if (isColored)
		{
			drawData[position++] = color.redFloat; 
			drawData[position++] = color.greenFloat;
			drawData[position++] = color.blueFloat;
		}
		
		drawData[position++] = alpha;
		
		coordinate.putWeak();
	}
}