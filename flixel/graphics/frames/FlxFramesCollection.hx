package flixel.graphics.frames;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFrame.FlxFrameType;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxDestroyUtil;
import flixel.util.FlxStringUtil;

/**
 * Base class for all frame collections.
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
	 * Used only in `FlxAtlasFrames` and `FlxBitmapFont` (not implemented yet),
	 * but you can try to use it for other types of collections
	 * (give names to your frames).
	 */
	@:deprecated("`framesHash` is deprecated, use `getByName()` or `exists()`")
	public var framesHash(get, set):Map<String, FlxFrame>;
	
	/**
	 * Hash of frames, by name, for this frame collection.
	 */
	var framesByName(default, null):Map<String, FlxFrame>;

	/**
	 * Graphic object this frames belongs to.
	 */
	public var parent:FlxGraphic;

	/**
	 * Type of this frame collection.
	 * Used for faster type detection (less casting).
	 */
	public var type(default, null):FlxFrameCollectionType;

	/**
	 * How much space was trimmed around the original frames.
	 * Use `addBorder()` to add borders.
	 */
	public var border(default, null):FlxPoint;

	public function new(parent:FlxGraphic, ?type:FlxFrameCollectionType, ?border:FlxPoint)
	{
		this.parent = parent;
		this.type = type;
		this.border = (border == null) ? FlxPoint.get() : border;
		frames = [];
		framesByName = new Map<String, FlxFrame>();

		if (parent != null)
			parent.addFrameCollection(this);
	}

	/**
	 * Finds a frame in the collection by its name.
	 *
	 * @param   name   The name of the frame to find.
	 * @return  Frame with specified name (if there is one).
	 */
	public inline function getByName(name:String):FlxFrame
	{
		return framesByName.get(name);
	}
	
	/**
	 * Whether the collection has frame with the specified name.
	 *
	 * @param   name   The name of the frame to find.
	 * @return  Whether the collection has frame with the specified name.
	 */
	public inline function exists(name:String):Bool
	{
		return framesByName.exists(name);
	}

	/**
	 * Finds frame in frames array by its index.
	 *
	 * @param   index   Index of the frame in the frames array.
	 * @return  Frame with specified index in this frames collection (if there is one).
	 */
	public inline function getByIndex(index:Int):FlxFrame
	{
		return frames[index];
	}

	/**
	 * Finds frame index by its name.
	 *
	 * @param   name  Name of the frame.
	 * @return  Index of the frame with specified name.
	 */
	public function getIndexByName(name:String):Int
	{
		for (i in 0...frames.length)
		{
			if (frames[i].name == name)
				return i;
		}

		return -1;
	}

	/**
	 * Finds the index of the specified frame in the frames array.
	 *
	 * @param   frame   Frame to find.
	 * @return  Index of the specified frame.
	 */
	public inline function getFrameIndex(frame:FlxFrame):Int
	{
		return frames.indexOf(frame);
	}

	public function destroy():Void
	{
		frames = FlxDestroyUtil.destroyArray(frames);
		border = FlxDestroyUtil.put(border);
		framesByName = null;
		parent = null;
		type = null;
	}

	/**
	 * Adds empty frame into this frame collection.
	 * An empty frame is doing almost nothing for all the time.
	 *
	 * @param   size   Dimensions of the frame to add.
	 * @return  Newly added empty frame.
	 */
	public function addEmptyFrame(size:FlxRect):FlxFrame
	{
		var frame = new FlxFrame(parent);
		frame.type = FlxFrameType.EMPTY;
		frame.frame = FlxRect.get();
		frame.sourceSize.set(size.width, size.height);
		frames.push(frame);
		return frame;
	}

	/**
	 * Adds new regular (not rotated) `FlxFrame` to this frame collection.
	 *
	 * @param   region   Region of image which new frame will display.
	 * @return  Newly created `FlxFrame` object for specified region of image.
	 */
	public function addSpriteSheetFrame(region:FlxRect):FlxFrame
	{
		var frame = new FlxFrame(parent);
		frame.frame = checkFrame(region);
		frame.sourceSize.set(region.width, region.height);
		frame.offset.set(0, 0);
		return pushFrame(frame);
	}

	/**
	 * Adds new frame to this frame collection.
	 * This method runs additional check, and can add rotated frames (from texture atlases).
	 *
	 * @param   frame        Region of image.
	 * @param   sourceSize   Original size of packed image
	 *                       (if image had been cropped, then original size will be bigger than frame size).
	 * @param   offset       How frame region is located on original frame image
	 *                       (offset from top left corner of original image).
	 * @param   name         Name for this frame (name of packed image file).
	 * @param   angle        Rotation of packed image (can be `0`, `90` or `-90`).
	 * @param   flipX        If packed image should be horizontally flipped.
	 * @param   flipY        If packed image should be vertically flipped.
	 * @param	duration	 The duration of this frame in seconds. If 0, the anim controller will decide the duration.
	 * @return  Newly created and added frame object.
	 */
	public function addAtlasFrame(frame:FlxRect, sourceSize:FlxPoint, offset:FlxPoint, ?name:String, angle:FlxFrameAngle = 0, flipX = false, flipY = false,
			duration = 0.0):FlxFrame
	{
		if (name != null && exists(name))
			return getByName(name);

		var texFrame:FlxFrame = new FlxFrame(parent, angle, flipX, flipY, duration);
		texFrame.name = name;
		texFrame.sourceSize.set(sourceSize.x, sourceSize.y);
		texFrame.offset.set(offset.x, offset.y);
		texFrame.frame = checkFrame(frame, name);

		sourceSize = FlxDestroyUtil.put(sourceSize);
		offset = FlxDestroyUtil.put(offset);

		return pushFrame(texFrame);
	}

	/**
	 * Retrieves all frames with names starting with the specified prefix in an Array.
	 * 
	 * @param   prefix  The name prefix to look for.
	 * @since 5.3.0
	 */
	public function getAllByPrefix(prefix:String)
	{
		final list = new Array<FlxFrame>();
		forEachByPrefix(prefix, (frame)->list.push(frame), false);
		return list;
	}
	
	/**
	 * Calls the given function on each frame whose name matches the specified prefix.
	 * 
	 * Note: This method is inlined so that optimizations are made when a literal anonymous
	 * functions or inlined functions are passed in, or when literal `false` is used for
	 * `warnIfEmpty`. Meaning, this is often more performant than `getAllByPrefix`.
	 * 
	 * @param   prefix  The name prefix to look for.
	 * @since 5.3.0
	 */
	public inline function forEachByPrefix(prefix:String, func:(FlxFrame)->Void, warnIfEmpty = true, ?warningMsg:String)
	{
		var warn = warnIfEmpty;
		for (name => frame in framesByName)
		{
			if (name.indexOf(prefix) == 0)
			{
				warn = false;
				func(frame);
			}
		}
		
		if (warn)
			FlxG.log.warn(warningMsg != null ? warningMsg : 'no frames found with the prefix "$prefix"');
	}
	
	/**
	 * Sets the target frame's offset to the specified values. This mainly exists because certain
	 * atlas exporters don't give the correct offset. If no frame with the specified name exists,
	 * a warning is logged.
	 * 
	 * @param   name     The name of the frame.
	 * @param   offsetX  The new horizontal offset of the frame.
	 * @param   offsetY  The new vertical offset of the frame.
	 * 
	 * @since 5.3.0
	 */
	public function setFrameOffset(name:String, offsetX:Float, offsetY:Float)
	{
		if (exists(name))
			getByName(name).offset.set(offsetX, offsetY);
		else
			FlxG.log.warn('No frame called $name');
	}

	/**
	 * Adjusts the target frame's offset by the specified values. This mainly exists because certain
	 * atlas exporters don't give the correct offset. If no frame with the specified name exists,
	 * a warning is logged.
	 * 
	 * @param   name     The name of the frame.
	 * @param   offsetX  The horizontal adjustment added to the frame's current offset.
	 * @param   offsetY  The vertical adjustment added to the frame's current offset.
	 * 
	 * @since 5.3.0
	 */
	public function addFrameOffset(name:String, offsetX:Float, offsetY:Float)
	{
		if (exists(name))
			getByName(name).offset.add(offsetX, offsetY);
		else
			FlxG.log.warn('No frame called $name');
	}

	/**
	 * Sets all frames with the specified name prefix to the specified offset. This mainly
	 * exists because certain atlas exporters don't give the correct offset.
	 * 
	 * @param   prefix       The prefix used to determine which frames are affected.
	 * @param   offsetX      The new horizontal offset of the frame.
	 * @param   offsetY      The new vertical offset of the frame.
	 * @param   warnIfEmpty  Whether to log a warning if no frames with the prefix are found.
	 * 
	 * @since 5.3.0
	 */
	public function setFramesOffsetByPrefix(prefix:String, offsetX:Float, offsetY:Float, warnIfEmpty = true)
	{
		forEachByPrefix(prefix, (frame)->{ frame.offset.set(offsetX, offsetY); }, warnIfEmpty);
	}

	/**
	 * Adjusts all frames with the specified name prefix by the specified offset. This mainly
	 * exists because certain atlas exporters don't give the correct offset.
	 * 
	 * @param   prefix       The prefix used to determine which frames are affected.
	 * @param   offsetX      The horizontal adjustment added to the frame's current offset.
	 * @param   offsetY      The vertical adjustment added to the frame's current offset.
	 * @param   warnIfEmpty  Whether to log a warning if no frames with the prefix are found.
	 * 
	 * @since 5.3.0
	 */
	public function addFramesOffsetByPrefix(prefix:String, offsetX:Float, offsetY:Float, warnIfEmpty = true)
	{
		forEachByPrefix(prefix, (frame)->{ frame.offset.add(offsetX, offsetY); }, warnIfEmpty);
	}

	/**
	 * Sets the target frame's offset to the specified values. This mainly exists because certain
	 * atlas exporters don't give the correct offset. If no frame with the specified name exists,
	 * a warning is logged.
	 * 
	 * @param   name      The name of the frame.
	 * @param   duration  The new duration of the frame.
	 * 
	 * @since 5.3.0
	 */
	public function setFrameDuration(name:String, duration:Float)
	{
		if (exists(name))
			getByName(name).duration = duration;
		else
			FlxG.log.warn('No frame called $name');
	}
	
	/**
	 * Checks if frame's area fits into atlas image, and trims if it's out of atlas image bounds.
	 *
	 * @param   frame   Frame area to check.
	 * @param   name    Optional frame name for debugging info.
	 * @return  Checked and trimmed frame rectangle.
	 */
	function checkFrame(frame:FlxRect, ?name:String):FlxRect
	{
		var x:Float = FlxMath.bound(frame.x, 0, parent.width);
		var y:Float = FlxMath.bound(frame.y, 0, parent.height);

		var r:Float = FlxMath.bound(frame.right, 0, parent.width);
		var b:Float = FlxMath.bound(frame.bottom, 0, parent.height);

		frame.set(x, y, r - x, b - y);

		if (frame.width <= 0 || frame.height <= 0)
			FlxG.log.warn("The frame " + name + " has incorrect data and results in an image with the size of (0, 0)");

		return frame;
	}

	/**
	 * Helper method for a adding frame to the collection.
	 *
	 * @param   frameObj       Frame to add.
	 * @param   overwriteHash  If true, any new frames with matching names will replace old ones.
	 * @return  Added frame.
	 */
	public function pushFrame(frameObj:FlxFrame, overwriteHash = false):FlxFrame
	{
		final name:String = frameObj.name;
		if (name != null && exists(name) && !overwriteHash)
			return getByName(name);

		frames.push(frameObj);
		frameObj.cacheFrameMatrix();

		if (name != null)
			framesByName.set(name, frameObj);

		return frameObj;
	}

	/**
	 * Generates new frames collection from this collection but trims frames by specified borders.
	 *
	 * @param   border   How much space trim around the frames.
	 * @return  Generated frames collection.
	 */
	public function addBorder(border:FlxPoint):FlxFramesCollection
	{
		throw "To be overriden in subclasses";
		return null;
	}

	public function toString():String
	{
		return FlxStringUtil.getDebugString([LabelValuePair.weak("frames", frames), LabelValuePair.weak("type", type)]);
	}

	inline function get_numFrames():Int
	{
		return frames.length;
	}
	
	inline function get_framesHash()
	{
		return framesByName;
	}
	
	inline function set_framesHash(value)
	{
		return framesByName = value;
	}
}

/**
 * An enumeration of all types of frame collections.
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
