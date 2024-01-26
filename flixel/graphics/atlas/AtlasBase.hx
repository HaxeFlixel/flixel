package flixel.graphics.atlas;

import haxe.DynamicAccess;

typedef AtlasBase<T> =
{
	frames:T
}

/**
 * Size struct use for atlas json parsing, { w:Float, h:Float }
 */
typedef AtlasSize =
{
	w:Int,
	h:Int
};

/**
 * Position struct use for atlas json parsing, { x:Float, y:Float }
 */
typedef AtlasPos =
{
	x:Int,
	y:Int
};

/**
 * Rectangle struct use for atlas json parsing, { x:Float, y:Float, w:Float, h:Float }
 */
typedef AtlasRect = AtlasPos & AtlasSize;

typedef AtlasFrame =
{
	/**
	 * The name of this frame, ommitted if using a hashed atlas
	 */
	@:optional var filename:String;
	
	/**
	 * Should always be false
	 */
	var rotated:Bool;
	
	/**
	 * The section of the atlas included in this frame
	 */
	var frame:AtlasRect;
	
	/**
	 * Whether the frame rect was trimmed of it's zero-alpha sections
	 */
	var trimmed:Bool;
	
	/**
	 * The size of the frame before it was trimmed, if not trimmed, this should match `frame`
	 */
	var sourceSize:AtlasSize;
	
	/**
	 * The frame rect relative relative to it's untrimmed rect, if not trimmed, this should
	 * be at (0, 0) and have the same size as `frame` and `sourceSize`
	 */
	var spriteSourceSize:AtlasRect;
}

abstract HashOrArray<T>(Dynamic) from DynamicAccess<T> from Array<T>
{
	public inline function isArray()
	{
		return (this is Array);
	}
	
	public inline function isHash()
	{
		return !isArray();
	}
	
	@:to
	public inline function toArray():Array<T>
	{
		return this;
	}
	
	@:to
	public inline function toHash():DynamicAccess<T>
	{
		return this;
	}
	
	public inline function iterator():Iterator<T>
	{
		if (isArray())
			return toArray().iterator();
		else
			return toHash().iterator();
	}
}
