package flixel.system.render.gl;

import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.DrawItem.DrawData;
import flixel.system.render.FlxDrawBaseItem;

/**
 * ...
 * @author Zaphod
 */
class FlxDrawTrianglesItem extends FlxDrawBaseItem<FlxDrawTrianglesItem>
{

	public function new() 
	{
		super();
	}
	
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?cameraBounds:FlxRect):Void
	{
		
	}
	
}