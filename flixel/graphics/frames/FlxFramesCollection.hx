package flixel.graphics.frames;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;

/**
 * Base class for all frame collections
 */
class FlxFramesCollection implements IFlxDestroyable
{
	/**
	 * Array with all frames of this collection.
	 */
	public var frames:Array<FlxFrame>;
	
	/**
	 * Number of frames in this collection.
	 */
	public var numFrames(get, never):Int;
	
	/**
	 * Hash of frames for this frame collection.
	 * Used only in AtlasFrames and FontFrames (not implemented yet), 
	 * but you can try to use it for other types of collections
	 * (give names to your frames)
	 */
	public var framesHash:Map<String, FlxFrame>;
	
	/**
	 * Graphic object this frames belongs to.
	 */
	public var parent:FlxGraphic;
	
	/**
	 * Type of this frame collection.
	 * Used for faster type detection (less casting)
	 */
	public var type(default, null):FlxFrameCollectionType;
	
	public function new(parent:FlxGraphic, type:FlxFrameCollectionType = null)
	{
		this.parent = parent;
		this.type = type;
		frames = [];
		framesHash = new Map<String, FlxFrame>();
		
		if (parent != null)
		{
			parent.addFrameCollection(this);
		}
	}
	
	/**
	 * Finds frame in framesHash by its name.
	 * 
	 * @param	name	The name of the frame to find.
	 * @return	frame with specified name (if there is one).
	 */
	public inline function getByName(name:String):FlxFrame
	{
		return framesHash.get(name);
	}
	
	/**
	 * Finds frame in frames array by its index.
	 * 
	 * @param	index	index of the frame in frames array
	 * @return	frame with specified index in this frames collection (if there is one).
	 */
	public inline function getByIndex(index:Int):FlxFrame
	{
		return frames[index];
	}
	
	/**
	 * Finds frame index by its name.
	 * 
	 * @param	name	name of the frame.
	 * @return	index of the frame with specified name.
	 */
	public inline function getIndexByName(name:String):Int
	{
		var numFrames:Int = frames.length;
		var frame:FlxFrame;
		
		for (i in 0...numFrames)
		{
			if (frames[i].name == name)
			{
				return i;
			}
		}
		
		return -1;
	}
	
	/**
	 * Find index of specified frame in frames array.
	 * 
	 * @param	frame	frame to find.
	 * @return	index of specified frame.
	 */
	public inline function getFrameIndex(frame:FlxFrame):Int
	{
		return frames.indexOf(frame);
	}
	
	public function destroy():Void
	{
		frames = FlxDestroyUtil.destroyArray(frames);
		framesHash = null;
		parent = null;
		type = null;
	}
	
	/**
	 * Adds empty frame into this frame collection. 
	 * An emty frame is doing almost nothing for all the time.
	 * 
	 * @param	size	dimensions of the frame to add.
	 * @return	Newly added empty frame.
	 */
	public function addEmptyFrame(size:FlxRect):FlxEmptyFrame
	{
		var frame:FlxEmptyFrame = new FlxEmptyFrame(parent);	
		frame.frame = new FlxRect();
		frame.sourceSize.set(size.width, size.height);
		frames.push(frame);
		return frame;
	}
	
	/**
	 * Adds new regular (not rotated) FlxFrame to this frame collection.
	 * 
	 * @param	region	region of image which new frame will display.
	 * @return	newly created FlxFrame object for specified region of image.
	 */
	public function addSpriteSheetFrame(region:FlxRect):FlxFrame
	{
		var frame:FlxFrame = new FlxFrame(parent);	
		#if FLX_RENDER_TILE
		var flashRect:Rectangle = region.copyToFlash(new Rectangle());
		frame.tileID = parent.tilesheet.addTileRect(flashRect, new Point(0.5 * region.width, 0.5 * region.height));
		#end
		frame.frame = region;
		frame.sourceSize.set(region.width, region.height);
		frame.offset.set(0, 0);
		frame.center.set(0.5 * region.width, 0.5 * region.height);
		frames.push(frame);
		return frame;
	}
	
	/**
	  * Adds new frame to this frame collection. This method runs additional check, and can add rotated frames (from texture atlases).
	  * @param	frame			region of image
	  * @param	sourceSize		original size of packed image (if image had been cropped, then original size will be bigger than frame size)
	  * @param	offset			how frame region is located on original frame image (offset from top left corner of original image)
	  * @param	name			name for this frame (name of packed image file)
	  * @param	angle			rotation of packed image (can be 0, 90, -90).
	  * @return	Newly created and added frame object.
	  */
	public function addAtlasFrame(frame:FlxRect, sourceSize:FlxPoint, offset:FlxPoint, name:String = null, angle:FlxFrameAngle = 0):FlxFrame
	{
		var texFrame:FlxFrame = null;
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			texFrame = new FlxRotatedFrame(parent, angle);
		}
		else
		{
			texFrame = new FlxFrame(parent);
		}
		
		texFrame.name = name;
		texFrame.sourceSize.set(sourceSize.x, sourceSize.y);
		texFrame.offset.set(offset.x, offset.y);
		texFrame.frame = frame;
		
		sourceSize.put();
		offset.put();
		
		if (angle != FlxFrameAngle.ANGLE_0)
		{
			texFrame.center.set(frame.height * 0.5 + texFrame.offset.x, frame.width * 0.5 + texFrame.offset.y);
		}
		else
		{
			texFrame.center.set(frame.width * 0.5 + texFrame.offset.x, frame.height * 0.5 + texFrame.offset.y);
		}
		
		#if FLX_RENDER_TILE
		var flashRect:Rectangle = frame.copyToFlash(new Rectangle());
		texFrame.tileID = parent.tilesheet.addTileRect(flashRect, new Point(0.5 * frame.width, 0.5 * frame.height));
		#end
		
		frames.push(texFrame);
		
		if (name != null)
		{
			framesHash.set(name, texFrame);
		}
		
		return texFrame;
	}
	
	public function destroyBitmaps():Void
	{
		for (frame in frames)
		{
			frame.destroyBitmaps();
		}
	}
	
	private inline function get_numFrames():Int
	{
		return frames.length;
	}
}

/**
 * Just enumeration of all types of frame collections.
 * Added for faster type detection with less usage of casting.
 */
enum FlxFrameCollectionType 
{
	IMAGE;
	TILES;
	ATLAS;
	FONT;
	BAR(type:flixel.ui.FlxBar.FlxBarFillDirection);
	CLIPPED;
	USER(type:String);
	FILTER;
}