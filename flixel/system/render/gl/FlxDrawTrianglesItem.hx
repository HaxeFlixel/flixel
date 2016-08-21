package flixel.system.render.gl;
import openfl.geom.ColorTransform;
import flixel.math.FlxMatrix;

import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.render.common.DrawItem.DrawData;
import flixel.system.render.common.FlxDrawBaseItem;

// TODO: add culling support???
// gl.enable(gl.CULL_FACE);
// gl.cullFace(gl.FRONT);

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
	
	override public function addQuad(frame:FlxFrame, matrix:FlxMatrix, ?transform:ColorTransform):Void 
	{
		// TODO: implement it...
		
		
	}
	
	// TODO: replace position argument with matrix?
	public function addTriangles(vertices:DrawData<Float>, indices:DrawData<Int>, uvtData:DrawData<Float>, ?colors:DrawData<Int>, ?position:FlxPoint, ?cameraBounds:FlxRect):Void
	{
		// TODO: implement it...
		
		
	}
	
	// TODO: replace position argument with matrix?
	public function addPolygon(buffer:DrawData<Float>, indices:DrawData<Int>, ?position:FlxPoint):Void
	{
		// TODO: implement it...
		
		
	}
	
	private function ensureElement():Void
	{
		// TODO: implement it...
		
		
	}
	
}