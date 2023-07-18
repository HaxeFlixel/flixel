package flixel.graphics;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;

/**
 * Collection of helpers that deal with Aseprite files. Namely the json files exported for sprite sheets.
 */
class FlxAsepriteUtil
{
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frames via `FlxAtlasFrames.fromAseprite`
	 * and returns the parsed AseAtlas to be used with other `FlxAsepriteUtil` helpers.
	 * 
	 * @param   sprite   The sprite to load the ase atlas's frames
	 * @param   graphic  The png file associated with the atlas
	 * @param   data     Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a string asset path to a json
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static function loadAseAtlas(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset)
	{
		sprite.frames = FlxAtlasFrames.fromAseprite(graphic, data);
		return sprite;
	}
	
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frame data via `FlxAtlasFrames.fromAseprite`,
	 * then, adds animations for any tags listed.
	 * 
	 * @param   sprite     The sprite to load the ase atlas's frames
	 * @param   graphic    The png file associated with the atlas
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a string asset path to a json
	 * @param   tagSuffix  The delimeter on each frame name that follows the animation name and precedes the frame number
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static function loadAseAtlasAndTags(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset, tagSuffix:String = ":")
	{
		final aseData = data.getData();
		loadAseAtlas(sprite, graphic, aseData);
		return addAseAtlasTags(sprite, aseData, tagSuffix);
	}
	
	/**
	 * Loops through the given ase atlas's tags and adds animations for each, to the gives sprite.
	 * 
	 * @param   sprite     The sprite to add the animations
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a string asset path to a json.
	 * @param   tagSuffix  The delimeter on each frame name that follows the animation name and precedes the frame number
	 * @return  This `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static function addAseAtlasTags(sprite:FlxSprite, data:FlxAsepriteJsonAsset, tagSuffix:String = ":")
	{
		final aseData = data.getData();
		for (frameTag in aseData.meta.frameTags)
			sprite.animation.addByPrefix(frameTag.name, frameTag.name + tagSuffix);
		
		return sprite;
	}
}

typedef AtlasBase<T> = { frames:T }

typedef AseAtlasBase<T> = AtlasBase<T> &
{
	var meta:AseAtlasMeta;
}

typedef AseAtlasArray = AseAtlasBase<Array<AseAtlasFrame>>;
typedef TexturePackerAtlasArray = AtlasBase<Array<AseAtlasFrame>>;

/**
 * Internal helper used to 
 */
abstract Hash<T>(Dynamic)
{
	public inline function keyValueIterator():KeyValueIterator<String, T>
	{
		var keys = Reflect.fields(this).iterator();
		return
		{
			hasNext: keys.hasNext,
			next: ()->
			{
				final key = keys.next();
				return { key:key, value:Reflect.field(this, key)};
			}
		};
	}
}

typedef AseAtlasHash = AseAtlasBase<Hash<AseAtlasFrame>>;
typedef TexturePackerAtlasHash = AtlasBase<Hash<TexturePackerAtlasFrame>>;

typedef HashOrArray<T> = flixel.util.typeLimit.OneOfTwo<Hash<T>, Array<T>>;

typedef AseAtlas = AseAtlasBase<HashOrArray<AseAtlasFrame>>;
typedef TexturePackerAtlas = AtlasBase<HashOrArray<TexturePackerAtlasFrame>>;

typedef AseAtlasMeta =
{
	var app:String;
	var version:String;
	var image:String;
	var format:String;
	var size:AtlasSize;
	var scale:String;
	var frameTags:Array<AseAtlasTag>;
	var slices:Array<AseAtlasSlice>;
	var layers:Array<AseAtlasLayer>;
}

typedef AseObject = 
{
	/** The color used to display this object */
	@:optional var color:AseAtlasColor;
	
	/** A message attached to this object */
	@:optional var data:String;
}

/**
 * Aseprite atlases use strings for colors (for some reason). This allows you to easily
 * convert to a more usable format.
 */
abstract AseAtlasColor(String) to String
{
	/** Converts the underlying string to an actual color usable by flixel tools */
	public function toFlxColor()
	{
		return flixel.util.FlxColor.fromString(this);
	}
	
	public function toString() return this;
}

/**
 * Tags are Aseprite's animation labels. They define a range of frames that all pertain to a
 * certain animation.
 */
typedef AseAtlasTag = AseObject &
{
	/** The name of this tag */
	var name:String;
	
	/** The tag's starting frame */
	var from:Int;
	
	/** The tag's ending frame */
	var to:Int;
	
	/** The tag's ending frame */
	var direction:AseAtlasTagDirection;
	
	/**
	 * The number of times to repeat this animation before
	 * 
	 * Note: not cuurently used by flixel
	 */
	@:optional var repeat:Int;
}

enum abstract AseAtlasTagDirection(String) to String
{
	var FORWARD = "forward";
	var REVERSE = "reverse";
	var PINGPONG = "pingpong";
	var PINGPONG_REVERSE = "pingpong_reverse";
	
	/** Whether this plays forward */
	public inline function isForward() return this == FORWARD || this == PINGPONG;
	/** Whether this plays in reverse */
	public inline function isReverse() return !isForward();
	/** Whether this animation plays back and forth */
	public inline function isPingPong() return this == PINGPONG || this == PINGPONG_REVERSE;
}

/**
 * Aseprite atlases allow for the definition of rectangles that can change on various
 * frames of an animation.
 * 
 * Note: These values are not implemented, or understood by any of Flixel's tools, yet.
 */
typedef AseAtlasSlice = AseObject &
{
	/** The name of this slice */
	var name:String;
	
	/** The "keyframes" where the slice changes properties */
	var keys:Array<AseAtlasSliceKey>;
}

/**
 * The "keyframes" of a slice.
 */
typedef AseAtlasSliceKey = AseObject &
{
	/** The frame that the slice changes properties */
	var frame:Int;
	
	/** The size and postion of the slice at this frame */
	var bounds:AtlasRect;
	
	/** The center rect of the 9-slice of this slice, if 9-slice is enabled */
	@:optional var center:AtlasRect;
	
	/** The pivot point of this slice */
	@:optional var pivot:AtlasPos;
}

typedef AseAtlasLayer = AseObject &
{
	/** The name of the layer */
	var name:String;
	
	/** The name of the parent layer */
	@:optional var group:String;
	
	/** Ranges from 0 to 255 */
	@:optional var opacity:Int;
	
	/** The effect added to this layer to change how the colors blend with colors on lower layers */
	@:optional var blendMode:AseBlendMode;
	
	/**
	 * Any info that was left on cels of this layer.
	 * 
	 * Note: While `data`, `color` and `zIndex` are optional, a cel should always have
	 * at least one of them with a non-null value.
	 */
	@:optional var cels:Array<AseAtlasCel>;
}

/**
 * Any data attached to this frame cel.
 * 
 * Note: These values are not implemented, or understood by any of Flixel's tools, yet.
 */
typedef AseAtlasCel = AseObject &
{
	/** The frame number associated with this data */
	var frame:Int;
	
	/** The intended display z-index of this frame */
	@:optional var zIndex:Int;
}

/**
 * The different types of blend modes offered by Aseprite's atlases.
 * 
 * Note: These values are not implemented, or understood by any of Flixel's tools, yet.
 */
enum abstract AseBlendMode(String)
{
	var NORMAL = "normal";
	
	var DARKEN = "darken";
	var MULTIPLY = "multiply";
	var COLOR_BURN = "color_burn";
	
	var LIGHTEN = "lighten";
	var SCREEN = "screen";
	var COLOR_DODGE = "color_dodge";
	var ADDITION = "addition";
	
	var OVERLAY = "overlay";
	var SOFT_LIGHT = "soft_light";
	var HARD_LIGHT = "hard_light";
	
	var DIFFERENCE = "difference";
	var EXCLUSION = "exclusion";
	var SUBTRACT = "subtract";
	var DIVIDE = "divide";
	
	var HSL_HUE = "hsl_hue";
	var HSL_SATURATION = "hsl_saturation";
	var HSL_COLOR = "hsl_color";
	var HSL_LUMINOSITY = "hsl_luminosity";
}

/**
 * Size struct use for atlas json parsing, { w:Float, h:Float }
 */
typedef AtlasSize = { w:Int, h:Int };

/**
 * Position struct use for atlas json parsing, { x:Float, y:Float }
 */
typedef AtlasPos = { x:Int, y:Int };

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
	 * Should alwyas be false
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

typedef TexturePackerAtlasFrame = AtlasFrame & { ?duration:Int }
typedef AseAtlasFrame = AtlasFrame & { duration:Int }