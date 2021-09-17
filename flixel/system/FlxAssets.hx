package flixel.system;

#if !macro
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.media.Sound;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.graphics.frames.FlxFramesCollection;
import flixel.util.typeLimit.OneOfFour;
import flixel.util.typeLimit.OneOfThree;
import flixel.util.typeLimit.OneOfTwo;
import openfl.Assets;
import openfl.utils.ByteArray;

@:keep @:bitmap("assets/images/logo/logo.png")
class GraphicLogo extends BitmapData {}

@:keep @:bitmap("assets/images/ui/virtual-input.png")
class GraphicVirtualInput extends BitmapData {}

@:file("assets/images/ui/virtual-input.txt")
class VirtualInputData extends #if (lime_legacy || nme) ByteArray #else ByteArrayData #end {}

typedef FlxAngelCodeSource = OneOfTwo<Xml, String>;
typedef FlxTexturePackerSource = OneOfTwo<String, TexturePackerObject>;
typedef FlxSoundAsset = OneOfThree<String, Sound, Class<Sound>>;
typedef FlxGraphicAsset = OneOfThree<FlxGraphic, BitmapData, String>;
typedef FlxGraphicSource = OneOfThree<BitmapData, Class<Dynamic>, String>;
typedef FlxTilemapGraphicAsset = OneOfFour<FlxFramesCollection, FlxGraphic, BitmapData, String>;
typedef FlxBitmapFontGraphicAsset = OneOfFour<FlxFrame, FlxGraphic, BitmapData, String>;

typedef FlxShader =
	#if (openfl_legacy || nme)
	Dynamic;
	#elseif FLX_DRAW_QUADS
	flixel.graphics.tile.FlxGraphicsShader;
	#else
	openfl.display.Shader;
	#end
#end

class FlxAssets
{
	#if (macro || doc_gen)
	/**
	 * Reads files from a directory relative to this project and generates `public static inline`
	 * variables containing the string paths to the files in it.
	 *
	 * Example usage:
	 *
	 * ```haxe
	 * @:build(flixel.system.FlxAssets.buildFileReferences("assets/images"))
	 * class Images {}
	 * ```
	 *
	 * Mostly copied from:
	 * @author Mark Knol
	 * @see http://blog.stroep.nl/2014/01/haxe-macros/
	 *
	 * @param   directory          The directory to scan for files
	 * @param   subDirectories     Whether to include subdirectories
	 * @param   filterExtensions   Example: `["jpg", "png", "gif"]` will only add files with that extension.
	 */
	public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false,
			?filterExtensions:Array<String>, ?rename:String->String):Array<haxe.macro.Expr.Field>
	{
		#if doc_gen
		return [];
		#else
		return flixel.system.macros.FlxAssetPaths.buildFileReferences(directory, subDirectories, filterExtensions, rename);
		#end
	}
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

	public static inline function getSound(id:String):Sound
	{
		var extension = "";
		#if flash
		extension = ".mp3";
		#else
		extension = ".ogg";
		#end
		return Assets.getSound(id + extension);
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
