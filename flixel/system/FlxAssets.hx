package flixel.system;

import haxe.macro.Expr;
#if !macro
import openfl.display.BitmapData;
import openfl.display.Graphics;
import openfl.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.AseAtlas;
import flixel.graphics.atlas.TexturePackerAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.graphics.frames.bmfont.BMFont;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import haxe.io.Bytes;
import haxe.Json;
import haxe.xml.Access;
import openfl.Assets;
import openfl.utils.ByteArray;

using StringTools;

@:keep @:bitmap("assets/images/logo/logo.png")
class GraphicLogo extends BitmapData {}

@:keep @:bitmap("assets/images/ui/virtual-input.png")
class GraphicVirtualInput extends BitmapData {}

@:file("assets/images/ui/virtual-input.txt")
class VirtualInputData extends #if (lime_legacy || nme) ByteArray #else ByteArrayData #end {}

typedef FlxTexturePackerJsonAsset = FlxJsonAsset<TexturePackerAtlas>;
typedef FlxAsepriteJsonAsset = FlxJsonAsset<AseAtlas>;
typedef FlxSoundAsset = OneOfThree<String, Sound, Class<Sound>>;
typedef FlxGraphicAsset = OneOfThree<FlxGraphic, BitmapData, String>;
typedef FlxGraphicSource = OneOfThree<BitmapData, Class<Dynamic>, String>;
typedef FlxTilemapGraphicAsset = OneOfFour<FlxFramesCollection, FlxGraphic, BitmapData, String>;
typedef FlxBitmapFontGraphicAsset = OneOfFour<FlxFrame, FlxGraphic, BitmapData, String>;

abstract FlxAngelCodeAsset(OneOfThree<Xml, String, Bytes>) from Xml from String from Bytes
{
	public inline function parse()
	{
		return BMFont.parse(cast this);
	}
}


@:deprecated("`FlxAngelCodeXmlAsset` is deprecated, use `FlxAngelCodeAsset` instead")
typedef FlxAngelCodeXmlAsset = FlxAngelCodeAsset;

@:deprecated("`FlxAngelCodeSource` is deprecated, use `FlxAngelCodeAsset` instead")
typedef FlxAngelCodeSource = FlxAngelCodeAsset;

@:deprecated("`FlxTexturePackerSource` is deprecated, use `FlxAtlasDataAsset` instead")
typedef FlxTexturePackerSource = FlxTexturePackerJsonAsset;

abstract FlxXmlAsset(OneOfTwo<Xml, String>) from Xml from String
{
	public function getXml()
	{
		if ((this is String))
		{
			final str:String = cast this;
			if (Assets.exists(str))
				return fromPath(str);

			return fromXmlString(str);
		}

		return cast(this, Xml);
	}

	static inline function fromPath<T>(path:String):Xml
	{
		return fromXmlString(Assets.getText(path));
	}

	static inline function fromXmlString<T>(data:String):Xml
	{
		return Xml.parse(data);
	}
}

abstract FlxJsonAsset<T>(OneOfTwo<T, String>) from T from String
{
	public function getData():T
	{
		if ((this is String))
		{
			final str:String = cast this;
			if (Assets.exists(str))
				return fromPath(str);

			return fromDataString(str);
		}

		return cast this;
	}

	static inline function fromPath<T>(path:String):T
	{
		return fromDataString(Assets.getText(path));
	}

	static inline function fromDataString<T>(data:String):T
	{
		return cast Json.parse(data);
	}
}

typedef FlxShader = #if nme Dynamic #else flixel.graphics.tile.FlxGraphicsShader #end;
#end

class FlxAssets
{
	/**
	 * The default sound format to be assumed when unspecified, only affects calls to
	 * `FlxAssets.getSound` which are not common. Currently set to ".ogg" on non-flash targets
	 * for backwards compatibility reasons.
	 */
	public static var defaultSoundExtension = #if flash "mp3" #else "ogg" #end;

	#if (macro || doc_gen)
	/**
	 * Reads files from a directory relative to this project and generates `public static inline`
	 * variables containing the string paths to the files in it.
	 * 
	 * **Example usage:**
	 * 
	 * ```haxe
	 * @:build(flixel.system.FlxAssets.buildFileReferences("assets/images/"))
	 * class Images {}
	 * ```
	 * 
	 * **Renaming Duplicates**
	 * 
	 * If you have files with the same names, whichever file is nested deeper or found later 
	 * will be ignored. You can provide `rename` function to deal with this case. The function takes a filepath 
	 * (a relative filepath from the `Project.xml`) and returns a field name used to access that path. 
	 * Returning `null` means "ignore the file".
	 * 
	 * ```haxe
	 * // assets structure:
	 * // assets/music/hero.ogg
	 * // assets/sounds/hero.ogg
	 * 
	 * // AssetPaths.hx
	 * @:build(flixel.system.FlxAssets.buildFileReferences("assets", true, null, null,
	 * 	function renameFileName(name:String):Null<String>
	 * 	{
	 * 		return name.toLowerCase()
	 * 			.split("/").join("_")
	 * 			.split("-").join("_")
	 * 			.split(" ").join("_")
	 * 			.split(".").join("__");
	 * 	}
	 * ))
	 * class AssetPaths {}
	 * 
	 * // somewhere in your code
	 * FlxG.sound.play(AssetPaths.assets_music_hero__ogg);
	 * FlxG.sound.play(AssetPaths.assets_sounds_hero__ogg);
	 * ```
	 * 
	 * @param   directory       The directory to scan for files
	 * @param   subDirectories  Whether to include subdirectories
	 * @param   include         A string or `EReg` of files to include
	 *                          Example: `"*.jpg\|*.png\|*.gif"` will only add files with that extension
	 * @param   exclude         A string or `EReg` of files to exclude. Example: `"*exclude/*\|*.ogg"`
	 *                          will exclude .ogg files and everything in the exclude folder
	 * @param   rename          A function that takes the file path and returns a valid haxe field name
	 * @param   listField       If not an empty string, it adds static public field with the given
	 *                          name with an array of every file in the directory
	 * 
	 * @see [Flixel 5.0.0 Migration guide - AssetPaths has less caveats](https://github.com/HaxeFlixel/flixel/wiki/Flixel-5.0.0-Migration-guide#assetpaths-has-less-caveats-2575)
	 * @see [Haxe Macros: Code completion for everything](http://blog.stroep.nl/2014/01/haxe-macros/)
	**/
	public static function buildFileReferences(directory = "assets/", subDirectories = false, ?include:Expr, ?exclude:Expr,
			?rename:String->Null<String>, listField = "allFiles"):Array<Field>
	{
		#if doc_gen
		return [];
		#else
		final buildRefs = flixel.system.macros.FlxAssetPaths.buildFileReferences;
		return buildRefs(directory, subDirectories, exprToRegex(include), exprToRegex(exclude), rename, listField);
		#end
	}

	#if !doc_gen
	static function exprToRegex(expr:Expr):EReg
	{
		switch (expr.expr)
		{
			case null | EConst(CIdent("null")):
				return null;
			case EConst(CString(s, _)):
				s = EReg.escape(s);
				s = StringTools.replace(s, "\\*", ".*");
				s = StringTools.replace(s, "\\|", "|");
				return new EReg("^" + s + "$", "");
			case EConst(CRegexp(r, opt)):
				return new EReg(r, opt);
			default:
				haxe.macro.Context.error("Value must be a string or regular expression.", expr.pos);
				return null;
		}
	}
	#end
	#end
	#if (!macro || doc_gen)
	// fonts
	public static var FONT_DEFAULT:String = "Nokia Cellphone FC Small";
	public static var FONT_DEBUGGER:String = "Monsterrat";

	public static function drawLogo(graph:Graphics):Void
	{
		// draw green area
		graph.beginFill(0x00b922);
		graph.moveTo(50, 13);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(87, 51);
		graph.lineTo(51, 87);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(13, 50);
		graph.lineTo(50, 13);
		graph.endFill();

		// draw yellow area
		graph.beginFill(0xffc132);
		graph.moveTo(0, 0);
		graph.lineTo(25, 0);
		graph.lineTo(50, 13);
		graph.lineTo(13, 50);
		graph.lineTo(0, 25);
		graph.lineTo(0, 0);
		graph.endFill();

		// draw red area
		graph.beginFill(0xf5274e);
		graph.moveTo(100, 0);
		graph.lineTo(75, 0);
		graph.lineTo(51, 13);
		graph.lineTo(87, 50);
		graph.lineTo(100, 25);
		graph.lineTo(100, 0);
		graph.endFill();

		// draw blue area
		graph.beginFill(0x3641ff);
		graph.moveTo(0, 100);
		graph.lineTo(25, 100);
		graph.lineTo(50, 87);
		graph.lineTo(13, 51);
		graph.lineTo(0, 75);
		graph.lineTo(0, 100);
		graph.endFill();

		// draw light-blue area
		graph.beginFill(0x04cdfb);
		graph.moveTo(100, 100);
		graph.lineTo(75, 100);
		graph.lineTo(51, 87);
		graph.lineTo(87, 51);
		graph.lineTo(100, 75);
		graph.lineTo(100, 100);
		graph.endFill();
	}

	public static inline function getBitmapData(id:String):BitmapData
	{
		if (Assets.exists(id))
			return Assets.getBitmapData(id, false);
		FlxG.log.error('Could not find a BitmapData asset with ID \'$id\'.');
		return null;
	}

	/**
	 * Generates BitmapData from specified class. Less typing.
	 *
	 * @param	source	BitmapData class to generate BitmapData object from.
	 * @return	Newly instantiated BitmapData object.
	 */
	public static inline function getBitmapFromClass(source:Class<Dynamic>):BitmapData
	{
		return Type.createInstance(source, []);
	}

	/**
	 * Takes Dynamic object as a input and tries to convert it to BitmapData:
	 * 1) if the input is BitmapData, then it will return this BitmapData;
	 * 2) if the input is Class<BitmapData>, then it will create BitmapData from this class;
	 * 3) if the input is String, then it will get BitmapData from openfl.Assets;
	 * 4) it will return null in any other case.
	 *
	 * @param	Graphic	input data to get BitmapData object for.
	 * @return	BitmapData for specified Dynamic object.
	 */
	public static function resolveBitmapData(Graphic:FlxGraphicSource):BitmapData
	{
		if ((Graphic is BitmapData))
		{
			return cast Graphic;
		}
		else if ((Graphic is Class))
		{
			return FlxAssets.getBitmapFromClass(cast Graphic);
		}
		else if ((Graphic is String))
		{
			return FlxAssets.getBitmapData(Graphic);
		}

		return null;
	}

	/**
	 * Takes Dynamic object as a input and tries to find appropriate key String for its BitmapData:
	 * 1) if the input is BitmapData, then it will return second (optional) argument (the Key);
	 * 2) if the input is Class<BitmapData>, then it will return the name of this class;
	 * 3) if the input is String, then it will return it;
	 * 4) it will return null in any other case.
	 *
	 * @param	Graphic	input data to get string key for.
	 * @param	Key	optional key string.
	 * @return	Key String for specified Graphic object.
	 */
	public static function resolveKey(Graphic:FlxGraphicSource, ?Key:String):String
	{
		if (Key != null)
		{
			return Key;
		}

		if ((Graphic is BitmapData))
		{
			return Key;
		}
		else if ((Graphic is Class))
		{
			return FlxG.bitmap.getKeyForClass(cast Graphic);
		}
		else if ((Graphic is String))
		{
			return Graphic;
		}

		return null;
	}

	/**
	 * Loads an OpenFL sound asset from the given asset id. If an extension not provided the 
	 * `defaultSoundExtension` is used (defaults to "ogg" on non-flash targets).
	 * 
	 * @param   id  The asset id of the local sound file.
	 * @return  The sound file.
	 */
	public static function getSound(id:String):Sound
	{
		if (!id.endsWith(".mp3") && !id.endsWith(".ogg") && !id.endsWith(".wav"))
			id += "." + defaultSoundExtension;

		return Assets.getSound(id);
	}

	public static function getVirtualInputFrames():FlxAtlasFrames
	{
		var bitmapData = new GraphicVirtualInput(0, 0);
		#if html5 // dirty hack for openfl/openfl#682
		Reflect.setProperty(bitmapData, "width", 399);
		Reflect.setProperty(bitmapData, "height", 183);
		#end
		var graphic:FlxGraphic = FlxGraphic.fromBitmapData(bitmapData);
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
	}
	#end
}
