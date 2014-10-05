package flixel.graphics.atlas;

import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.util.FlxDestroyUtil.IFlxDestroyable;

/**
 * Atlas node holds information about image on Atlas.
 * Plus it have few methods for easy frame data generation, 
 * which can be loaded in sprites and tilemap
 */
class FlxNode implements IFlxDestroyable
{
	/**
	 * Left child of this node
	 */
	public var left:FlxNode;
	/**
	 * Right child of this node
	 */
	public var right:FlxNode;
	
	/**
	 * Region of atlas which this node holds, includes spacings between nodes
	 */
	public var rect:Rectangle;
	/**
	 * Position of upper left corner of this node on atlas bitmapdata
	 */
	public var point:Point;
	/**
	 * The "name" of this node. You can get access to this node with it:
	 * atlas.getNode(key);
	 */
	public var key:String;
	/**
	 * Logical flag showing whether this node have image in it or not
	 */
	public var filled:Bool;
	/**
	 * Atlas object, which contains this node
	 */
	public var atlas:FlxAtlas;
	
	/**
	 * The x coordinate of the top-left corner of this node.
	 */
	public var x(get, null):Int;
	/**
	 * The y coordinate of the top-left corner of this node.
	 */
	public var y(get, null):Int;
	/**
	 * The width of this node.
	 */
	public var width(get, null):Int;
	/**
	 * The height of this node.
	 */
	public var height(get, null):Int;
	/**
	 * Logical flag, showing whether this node have any child nodes or image in it
	 */
	public var isEmpty(get, null):Bool;
	
	/**
	 * Helper rectangle object, showing actual size and position of image on atlas bitmapdata
	 */
	public var contentRect(get, null):Rectangle;
	/**
	 * The width of image in in this node (node.width - atlas.borderX)
	 */
	public var contentWidth(get, null):Int;
	/**
	 * The height of image in in this node (node.height - atlas.borderY)
	 */
	public var contentHeight(get, null):Int;
	
	private var _contentRect:Rectangle;
	
	/**
	 * Node constructot
	 * @param	rect	region of atlas this node holds
	 * @param	atlas	atlas this node belongs to
	 * @param	filled	whether this node contains image or not
	 * @param	key		the name of image in this node, and the name of this node
	 */
	public function new(rect:Rectangle, atlas:FlxAtlas, filled:Bool = false, key:String = "") 
	{
		this.filled = filled;
		this.left = null;
		this.right = null;
		this.rect = rect;
		point = new Point(rect.x, rect.y);
		this.key = key;
		this.atlas = atlas;
	}
	
	public inline function destroy():Void
	{
		key = null;
		left = null;
		right = null;
		rect = null;
		point = null;
		atlas = null;
		_contentRect = null;
	}
	
	/**
	 * Can we place node with specified width and height in this node
	 */
	public inline function canPlace(width:Int, height:Int):Bool
	{
		return ((rect.width >= width) && (rect.height >= height));
	}
	
	/**
	 * Generates TileFrames object for this node
	 * @param	tileSize		The size of tile in spritesheet
	 * @param	tileSpacing		Offsets between tiles in spritesheet
	 * @param	region			Region of node to use as a source of graphic. Default value is null, which means that the whole node will be used for it.
	 * @return	Created TileFrames object for this node
	 */
	public function getTileFrames(tileSize:Point, tileSpacing:Point = null, region:Rectangle = null):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(atlas.atlasBitmapData, false, atlas.name);
		
		if (region == null)
		{
			region = contentRect;
		}
		
		return FlxTileFrames.fromRectangle(graphic, tileSize, region, tileSpacing);
	}
	
	/**
	 * Generates ImageFrame object for this node.
	 * @return	ImageFrame for whole node
	 */
	public function getImageFrame():FlxImageFrame
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(atlas.atlasBitmapData, false, atlas.name);
		return FlxImageFrame.fromRectangle(graphic, contentRect);
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
	
	private inline function get_contentWidth():Int
	{
		return Std.int(rect.width - atlas.borderX);
	}
	
	private inline function get_contentHeight():Int
	{
		return Std.int(rect.height - atlas.borderY);
	}
	
	private inline function get_contentRect():Rectangle
	{
		if (_contentRect == null)
		{
			_contentRect = new Rectangle(x, y, contentWidth, contentHeight);
		}
		
		return _contentRect;
	}
}