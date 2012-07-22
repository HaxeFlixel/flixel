package org.flixel.system.tileSheet.atlasgen;

import nme.display.BitmapData;
import nme.geom.Rectangle;
/**
 * Atlas Node holds BitmapData and it's position on Atlas
 * @author Zaphod
 */
class Node
{
	public var item:BitmapData;
	public var left:Node;
	public var right:Node;
	
	public var rect:Rectangle;
	public var key:String;
	
	public function new(rect:Rectangle, ?item:BitmapData = null, ?key:String = "") 
	{
		this.item = item;
		this.left = null;
		this.right = null;
		this.rect = rect;
		this.key = key;
	}
	
	public var isEmpty(get_isEmpty, null):Bool;
	
	private function get_isEmpty():Bool
	{
		return (item == null && left == null && right == null);
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
		this.item = null;
		this.left = null;
		this.right = null;
		this.rect = null;
	}
	
}