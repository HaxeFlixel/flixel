package flixel.atlas;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;

/**
 * Atlas Node holds BitmapData and it's position on Atlas
 * @author Zaphod
 */
class FlxNode
{
	public var left:FlxNode;
	public var right:FlxNode;
	
	public var rect:Rectangle;
	public var point:Point;
	public var key:String;
	public var filled:Bool;
	
	public function new(rect:Rectangle, filled:Bool = false, key:String = "") 
	{
		this.filled = filled;
		this.left = null;
		this.right = null;
		this.rect = rect;
		point = new Point(rect.x, rect.y);
		this.key = key;
	}
	
	public var isEmpty(get_isEmpty, null):Bool;
	
	private function get_isEmpty():Bool
	{
		return (filled == false && left == null && right == null);
	}
	
	public function canPlace(width:Int, height:Int):Bool
	{
		return (rect.width >= width && rect.height >= height);
	}
	
	public var x(get_x, null):Int;
	public var y(get_y, null):Int;
	public var width(get_width, null):Int;
	public var height(get_height, null):Int;
	
	private function get_x():Int
	{
		return Std.int(rect.x);
	}
	
	private function get_y():Int
	{
		return Std.int(rect.y);
	}
	
	private function get_width():Int
	{
		return Std.int(rect.width);
	}
	
	private function get_height():Int
	{
		return Std.int(rect.height);
	}
	
	public function destroy():Void
	{
		this.left = null;
		this.right = null;
		this.rect = null;
		this.point = null;
	}
}