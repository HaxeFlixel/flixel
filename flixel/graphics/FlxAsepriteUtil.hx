package flixel.graphics;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxAssets;

class FlxAsepriteUtil
{
	public static function loadAseAtlas(sprite:FlxSprite, graphic, data:FlxAsepriteJsonAsset, tagSuffix:String = ":")
	{
		final aseData = data.getData();
		sprite.frames = FlxAtlasFrames.fromAseprite(graphic, aseData);
		
		for (frameTag in aseData.meta.frameTags)
			sprite.animation.addByPrefix(frameTag.name, frameTag.name + tagSuffix);
	}
}

typedef AtlasBase<T> = { frames:T }

typedef AseAtlasBase<T> = AtlasBase<T> &
{
	var meta:AseAtlasMeta;
}

typedef AseAtlasArray = AseAtlasBase<Array<AseAtlasFrame>>;
typedef TexturePackerAtlasArray = AtlasBase<Array<AseAtlasFrame>>;

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

typedef AseAtlasTag = { name: String, from:Int, to:Int, direction:String };

typedef AseAtlasSlice =
{
	var name:String;
	var color:String;
	
	/**
	 * Info of at what frames the slice changes size
	 */
	var keys: Array<AseAtlasSliceKey>;
}

typedef AseAtlasLayer =
{
	var name:String;
	
	/**
	 * The name of the parent layer
	 */
	@:optional var group:String;
	
	/**
	 * Ranges from 0 to 255
	 */
	@:optional var opacity:Int;
	
	/**
	 * The effect added to this layer to change how the colors blend with colors on lower layers
	 * @see AseBlendMode
	 */
	@:optional var blendMode:AseBlendMode;
	
	/**
	 * Any notes that were left on cels of this layer
	 */
	@:optional var cels:Array<{ frame:Int, data:String, ?color:String }>;
}

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

typedef AseAtlasSliceKey =
{
	/**
	 * The frame that the slice changes size
	 */
	var frame:Int;
	/**
	 * The size of the slice at this frame
	 */
	var bounds:AtlasRect;
};

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