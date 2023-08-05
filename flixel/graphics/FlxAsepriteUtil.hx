package flixel.graphics;

import flixel.animation.FlxAnimationController;
import flixel.math.FlxMath;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;

/**
 * Collection of helpers that deal with Aseprite files. Namely the json files exported for sprite sheets.
 */
class FlxAsepriteUtil
{
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frames via `FlxAtlasFrames.fromAseprite`.
	 * 
	 * @param   sprite   The sprite to load the ase atlas's frames
	 * @param   graphic  The png file associated with the atlas
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                     string asset path to a json
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlas(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset)
	{
		sprite.frames = FlxAtlasFrames.fromAseprite(graphic, data);
		return sprite;
	}
	
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frame data via `loadAseAtlas`,
	 * then, adds animations for any tags listed, via `addAseAtlasTagsByPrefix`.
	 * 
	 * Notes: Assumes that the frame names are prefixed by tag name, assumes that the `tagSuffix`
	 * does not appear anywhere in the tag name and assumes that no tags overlap. You can use the
	 * filename format `{outertag}:{frame}` for most cases.
	 * 
	 * It's recommended to disable the "Ignore Empty" option if you have empty frames (that is, 
	 * empty on every layer), while it will reduce the size of your json, this method will
	 * not be able to add those empty frames to an animation
	 * 
	 * @param   sprite       The sprite to load the ase atlas's frames
	 * @param   graphic      The png file associated with the atlas
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   tagSuffix    The delimeter on each frame name between the animation name and the
	 *                       frame number. Be sure to set your filename format to `{outertag}:{frame}`
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlasAndTagsByPrefix(sprite, graphic, data:FlxAsepriteJsonAsset, tagSuffix = ":", ?excludeTags)
	{
		data = data.getData();
		loadAseAtlas(sprite, graphic, data);
		return addAseAtlasTagsByPrefix(sprite, data, tagSuffix, excludeTags);
	}
	
	/**
	 * Loops through the given ase atlas's tags and adds animations for each, to the given sprite.
	 * Uses the frame names to determine which tag they belong to.
	 * 
	 * Notes: Assumes that the frame names are prefixed by tag name, assumes that the `tagSuffix`
	 * does not appear anywhere in the tag name and assumes that no tags overlap. You can use the
	 * filename format `{outertag}:{frame}` for most cases.
	 * 
	 * It's recommended to disable the "Ignore Empty" option if you have empty frames (that is, 
	 * empty on every layer), while it will reduce the size of your json, this method will
	 * not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite     The sprite to add the animations
	 * @param   data       Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                     string asset path to a json
	 * @param   tagSuffix  The delimeter on each frame name between the animation name and the
	 *                     frame number. Be sure to set your filename format to `{outertag}:{frame}`
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function addAseAtlasTagsByPrefix(sprite:FlxSprite, data, tagSuffix = ":", ?excludeTags)
	{
		addByPrefixHelper(sprite.animation, data, tagSuffix, excludeTags);
		return sprite;
	}
	
	// TODO: overload addAseAtlasTagsByPrefix to take FlxAnimationController?
	// This might mess with codeclimate
	
	static function addByPrefixHelper(animations:FlxAnimationController, data:FlxAsepriteJsonAsset, tagSuffix = ":", excludeTags:Null<Array<String>>)
	{
		final aseData = data.getData();
		for (tag in aseData.meta.frameTags)
		{
			final name = tag.name;
			if (excludeTags == null || !excludeTags.contains(name))
			{
				final expectedFrames = tag.to - tag.from + 1;
				animations.addByPrefix(name, name + tagSuffix);
				// Animations aren't added if no frames are found
				final anim = animations.getByName(name);
				final actualFrames = anim == null ? 0 : anim.numFrames;
				if (actualFrames != expectedFrames)
				{
					FlxG.log.warn('Tag "$name" expected $expectedFrames frames but found '
						+ '$actualFrames. Was the atlas exported with "Ignore Empty"/--ignore-empty'
						+ ', or are there multiple tags on a single frame?');
				}
			}
		}
	}
	
	/**
	 * Helper for parsing Aseprite atlas json files. Reads frame data via `loadAseAtlas`,
	 * then, adds animations for any tags listed, via `addAseAtlasTagsByIndex`.
	 * 
	 * Warning: It's important to disable the "Ignore Empty" option if you have empty frames (that
	 * is, empty on every layer) in tags, while it will reduce the size of your json, this method
	 * will not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite       The sprite to load the ase atlas's frames
	 * @param   graphic      The png file associated with the atlas
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function loadAseAtlasAndTagsByIndex(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset, ?excludeTags)
	{
		data = data.getData();
		loadAseAtlas(sprite, graphic, data);
		return addAseAtlasTagsByIndex(sprite, data, excludeTags);
	}
	
	/**
	 * Loops through the given ase atlas's tags and adds animations for each, to the given sprite.
	 * Uses the tag's `to` and `from` fields to determine.
	 * 
	 * Warning: It's important to disable the "Ignore Empty" option if you have empty frames (that
	 * is, empty on every layer) in tags, while it will reduce the size of your json, this method
	 * will not be able to add those empty frames to an animation.
	 * 
	 * @param   sprite       The sprite to add the animations
	 * @param   data         Can be an `AseAtlas` struct, a JSON string matching the `AseAtlas` or a
	 *                       string asset path to a json
	 * @param   excludeTags  A list of tags to ignore
	 * @return  The `FlxSprite` instance (nice for chaining stuff together, if you're into that).
	 * 
	 * @see flixel.graphics.FlxAsepriteUtil.AseAtlasMeta
	 * @since 5.4.0
	 */
	public static inline function addAseAtlasTagsByIndex(sprite:FlxSprite, data:FlxAsepriteJsonAsset, ?excludeTags)
	{
		addByIndexHelper(sprite.animation, data, excludeTags);
		return sprite;
	}
	
	// TODO: overload addAseAtlasTagsByIndex to take FlxAnimationController?
	// This might mess with codeclimate
	
	static function addByIndexHelper(animations:FlxAnimationController, data:FlxAsepriteJsonAsset, excludeTags:Null<Array<String>>)
	{
		final aseData = data.getData();
		final maxFrameNumber = animations.numFrames - 1;
		for (frameTag in aseData.meta.frameTags)
		{
			if (frameTag.to > maxFrameNumber)
			{
				FlxG.log.warn('Tag "${frameTag.name}" `to` field (${frameTag.to}) exceeds the max '
					+ 'frame number ($maxFrameNumber). Some animations may not be loaded correctly. '
					+ 'Was the atlas exported with "Ignore Empty"/--ignore-empty?');
			}
			
			final toFrame = FlxMath.minInt(frameTag.to, maxFrameNumber);
			animations.add(frameTag.name, [for (i in frameTag.from...toFrame + 1) i]);
		}
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
 * Internal helper used to enumerate the fields of an atlas that has frame data keyed by frame names.
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

/**
 * Metadata attached to aseprite's atlas json, containing info about how the .aseprite file was
 * set up.
 */
typedef AseAtlasMeta =
{
	/** The app used to save the file, often https://www.aseprite.org/ */
	var app:String;
	
	/** The version of Aseprite used to export the json */
	var version:String;
	
	/** Usually "I8" */
	var format:String;
	
	/** The dimensions of the image file */
	var size:AtlasSize;
	
	/** Usually "1" */
	var scale:String;
	
	/**
	 * The png file exported with this json, if one was
	 * 
	 * Note: Does not contain the relative filepath of that image (as of Aseprite 1.3-rc4)
	 */
	@:optional var image:String;
	
	/** A list of animation tags */
	@:optional var frameTags:Array<AseAtlasTag>;
	
	/** A list of rects, 9-slices and pivots used in the Aseprite file, to be used however you desire */
	@:optional var slices:Array<AseAtlasSlice>;
	
	/** A list of the layers used in the Aseprite file, to be used however you desire */
	@:optional var layers:Array<AseAtlasLayer>;
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
	 * The number of times to repeat this animation before aseprite's timeline switvhed to the next one.
	 * 
	 * Note: not currently used by flixel
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
	
	/** Ranges from 0 to 0xFF (255) */
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

typedef TexturePackerAtlasFrame = AtlasFrame & { ?duration:Int }
typedef AseAtlasFrame = AtlasFrame & { duration:Int }