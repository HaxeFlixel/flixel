package flixel.atlas;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.interfaces.IFlxDestroyable;

/**
 * Atlas Node holds BitmapData and it's position on Atlas
 * @author Zaphod
 */
class FlxNode implements IFlxDestroyable
{
	public var left:FlxNode;
	public var right:FlxNode;
	
	public var rect:Rectangle;
	public var point:Point;
	public var key:String;
	public var filled:Bool;
	
	public var x(get, null):Int;
	public var y(get, null):Int;
	public var width(get, null):Int;
	public var height(get, null):Int;
	public var isEmpty(get, null):Bool;
	
	public function new(rect:Rectangle, filled:Bool = false, key:String = "") 
	{
		this.filled = filled;
		this.left = null;
		this.right = null;
		this.rect = rect;
		point = new Point(rect.x, rect.y);
		this.key = key;
	}
	
	public inline function destroy():Void
	{
		left = null;
		right = null;
		rect = null;
		point = null;
	}
	
	public inline function canPlace(width:Int, height:Int):Bool
	{
		return ((rect.width >= width) && (rect.height >= height));
	}
	
	private inline function get_isEmpty():Bool
	{
		return (!filled && (left == null) && (right == null));
	}
	
	private inline function get_x():Int
	{
		return Std.int(rect.x);
	}
	
	private inline function get_y():Int
	{
		return Std.int(rect.y);
	}
	
	private inline function get_width():Int
	{
		return Std.int(rect.width);
	}
	
	private inline function get_height():Int
	{
		return Std.int(rect.height);
	}
}