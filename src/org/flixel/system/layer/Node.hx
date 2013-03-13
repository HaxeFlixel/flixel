package org.flixel.system.layer;

import nme.display.BitmapData;
import nme.geom.Point;
import nme.geom.Rectangle;

import org.flixel.system.layer.TileSheetData;

/**
 * Atlas Node holds BitmapData and it's position on Atlas
 * @author Zaphod
 */
class Node
{
	public var atlas:Atlas;
	
	public var item:BitmapData;
	public var left:Node;
	public var right:Node;
	
	public var rect:Rectangle;
	public var point:Point;
	public var key:String;
	
	public function new(atlas:Atlas, rect:Rectangle, item:BitmapData = null, key:String = "") 
	{
		this.atlas = atlas;
		this.item = item;
		this.left = null;
		this.right = null;
		this.rect = rect;
		point = new Point(rect.x, rect.y);
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
	
	#if !flash
	public function addSpriteFramesData(frameWidth:Int, frameHeight:Int, origin:Point = null, startX:Int = 0, startY:Int = 0, endX:Int = 0, endY:Int = 0, xSpacing:Int = 0, ySpacing:Int = 0):FlxSpriteFrames
	{
		if (endX == 0)
		{
			endX += item.width;
		}
		if (endY == 0)
		{
			endY += item.height;
		}
		return atlas._tileSheetData.addSpriteFramesData(frameWidth, frameHeight, origin, startX + this.x, startY + this.y, endX + this.x, endY + this.y, xSpacing, ySpacing);
	}
	
	public function addTileRect(tileRect:Rectangle, point:Point = null):Int
	{
		tileRect.x += this.x;
		tileRect.y += this.y;
		return atlas._tileSheetData.addTileRect(tileRect, point);
	}
	#end
	
	public function destroy():Void
	{
		this.atlas = null;
		this.item = null;
		this.left = null;
		this.right = null;
		this.rect = null;
		this.point = null;
	}
}