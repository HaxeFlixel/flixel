package flixel.graphics.atlas;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxImageFrame;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
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
	public var rect:FlxRect;
	/**
	 * The "name" of this node. You can get access to this node with it:
	 * atlas.getNode(key);
	 */
	public var key:String;
	/**
	 * Logical flag showing whether this node have image in it or not
	 */
	public var filled(default, null):Bool;
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
	public var width(get, set):Int;
	/**
	 * The height of this node.
	 */
	public var height(get, set):Int;
	/**
	 * Logical flag, showing whether this node have any child nodes or image in it
	 */
	public var isEmpty(get, null):Bool;
	
	public var rotated(default, null):Bool;
	
	/**
	 * Node constructot
	 * @param	rect	region of atlas this node holds
	 * @param	atlas	atlas this node belongs to
	 * @param	filled	whether this node contains image or not
	 * @param	key		the name of image in this node, and the name of this node
	 */
	public function new(rect:FlxRect, atlas:FlxAtlas, filled:Bool = false, key:String = "", rotated:Bool = false) 
	{
		this.filled = filled;
		this.left = null;
		this.right = null;
		this.rect = rect;
		this.key = key;
		this.atlas = atlas;
		this.rotated = rotated;
	}
	
	public inline function destroy():Void
	{
		key = null;
		left = null;
		right = null;
		rect = null;
		atlas = null;
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
	 * @param	tileBorder		Border to add around tiles (helps to avoid "tearing" problem)
	 * @return	Created TileFrames object for this node
	 */
	public function getTileFrames(tileSize:FlxPoint, tileSpacing:FlxPoint = null, tileBorder:FlxPoint = null):FlxTileFrames
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(atlas.bitmapData, false, atlas.name);
		var frame:FlxFrame = atlas.getAtlasFrames().getByName(key);
		
		if (frame != null)
		{
			var tileFrames:FlxTileFrames = FlxTileFrames.fromFrame(frame, tileSize, tileSpacing);
			if (tileBorder != null)
			{
				tileFrames = tileFrames.addBorder(tileBorder);
			}
			return tileFrames;
		}
		
		return null;
	}
	
	/**
	 * Generates ImageFrame object for this node.
	 * @return	ImageFrame for whole node
	 */
	public function getImageFrame():FlxImageFrame
	{
		var graphic:FlxGraphic = FlxG.bitmap.add(atlas.bitmapData, false, atlas.name);
		var frame = atlas.getAtlasFrames().getByName(key);
		
		if (frame != null)
		{
			return FlxImageFrame.fromFrame(frame);
		}
		
		return null;
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
	
	private function set_width(value:Int):Int
	{
		rect.width = value;
		return value;
	}
	
	private inline function get_height():Int
	{
		return Std.int(rect.height);
	}
	
	private function set_height(value:Int):Int
	{
		rect.height = value;
		return value;
	}
}