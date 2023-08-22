package flixel.graphics.atlas;

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

/**
 * Internal helper used to enumerate the fields of an atlas that has frame data keyed by frame names.
 */
abstract Hash<T>(Dynamic)
{
	public inline function keyValueIterator():KeyValueIterator<String, T>
	{
		var keys = Reflect.fields(this).iterator();
		return {
			hasNext: keys.hasNext,
			next: () ->
			{
				final key = keys.next();
				return {key: key, value: Reflect.field(this, key)};
			}
		};
	}
}

typedef HashOrArray<T> = flixel.util.typeLimit.OneOfTwo<AtlasBase.Hash<T>, Array<T>>;
