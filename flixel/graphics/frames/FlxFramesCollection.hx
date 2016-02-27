package flixel.graphics.frames;

import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

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
	
	/**
	 * How much space were trimmed around original frames.
	 * Use addBorder() method to add borders.
	 */
	public var border(default, null):FlxPoint;
	
	public function new(parent:FlxGraphic, type:FlxFrameCollectionType = null, border:FlxPoint = null)
	{
		this.parent = parent;
		this.type = type;
		this.border = (border == null) ? FlxPoint.get() : border;
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
	public function getIndexByName(name:String):Int
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
		border = FlxDestroyUtil.put(border);
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
	public function addEmptyFrame(size:FlxRect):FlxFrame
	{
		var frame:FlxFrame = new FlxFrame(parent);
		frame.type = FlxFrameType.EMPTY;
		frame.frame = FlxRect.get();
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
		frame.frame = region;
		frame.sourceSize.set(region.width, region.height);
		frame.offset.set(0, 0);
		return pushFrame(frame);
	}
	
	/**
	 * Adds new frame to this frame collection. This method runs additional check, and can add rotated frames (from texture atlases).
	 * @param	frame			region of image
	 * @param	sourceSize		original size of packed image (if image had been cropped, then original size will be bigger than frame size)
	 * @param	offset			how frame region is located on original frame image (offset from top left corner of original image)
	 * @param	name			name for this frame (name of packed image file)
	 * @param	angle			rotation of packed image (can be 0, 90, -90).
	 * @param	flipX			if packed image should be horizontally flipped
	 * @param	flipY			if packed iamge should be vertically flipped
	 * @return	Newly created and added frame object.
	 */
	public function addAtlasFrame(frame:FlxRect, sourceSize:FlxPoint, offset:FlxPoint, name:String = null, angle:FlxFrameAngle = 0, flipX:Bool=false, flipY:Bool=false):FlxFrame
	{
		if (name != null && framesHash.exists(name))
		{
			return framesHash.get(name);
		}
		
		var texFrame:FlxFrame = new FlxFrame(parent, angle, flipX, flipY);
		texFrame.name = name;
		texFrame.sourceSize.set(sourceSize.x, sourceSize.y);
		texFrame.offset.set(offset.x, offset.y);
		texFrame.frame = frame;
		
		sourceSize = FlxDestroyUtil.put(sourceSize);
		offset = FlxDestroyUtil.put(offset);
		
		return pushFrame(texFrame);
	}
	
	/**
	 * Helper method for adding frame into collection
	 * 
	 * @param	frameObj	frame to add
	 * @return	added frame
	 */
	public function pushFrame(frameObj:FlxFrame):FlxFrame
	{
		var name:String = frameObj.name;
		if (name != null && framesHash.exists(name))
		{
			return framesHash.get(name);
		}
		
		frames.push(frameObj);
		frameObj.cacheFrameMatrix();
		
		if (name != null)
		{
			framesHash.set(name, frameObj);
		}
		
		return frameObj;
	}
	
	/**
	 * Generates new frames collection from this collection but trims frames by specified borders.
	 * 
	 * @param	border	How much space trim around frame's
	 * @return	Generated frames collection.	
	 */
	public function addBorder(border:FlxPoint):FlxFramesCollection
	{
		throw "To be overriden in subclasses";
		return null;
	}
	
	public function toString():String
	{
		return FlxStringUtil.getDebugString([
			LabelValuePair.weak("frames", frames),
			LabelValuePair.weak("type", type)]);
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
	USER(type:String);
	FILTER;
}