package flixel.graphics.tile;

import flixel.graphics.tile.FlxDrawTrianglesItem;
import flixel.util.FlxDestroyUtil;

class FlxDrawTriangleData implements IFlxDestroyable
{
	/**
	* A `Vector` of floats where each pair of numbers is treated as a coordinate location (an x, y pair).
	*/
	public var vertices = new DrawData<Float>();
	
	/**
	* A `Vector` of integers or indexes, where every three indexes define a triangle.
	*/
	public var indices = new DrawData<Int>();
	
	/**
	* A `Vector` of normalized coordinates used to apply texture mapping.
	*/
	public var uvs = new DrawData<Float>();
	
	public var colors = new DrawData<Int>();
	
	public function new () {}
	
	public function destroy()
	{
		vertices = null;
		indices = null;
		uvs = null;
		colors = null;
	}
	
	public function clear()
	{
		vertices = new DrawData<Float>();
		uvs = new DrawData<Float>();
		indices = new DrawData<Int>();
		colors = new DrawData<Int>();
	}
}