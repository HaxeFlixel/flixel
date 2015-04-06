package flixel.system;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import sys.FileSystem;
using StringTools;
#else
import flash.display.BitmapData;
import flash.display.Graphics;
import flash.media.Sound;
import flash.text.Font;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxTileFrames;
import openfl.Assets;
import openfl.utils.ByteArray;

@:keep @:font("assets/fonts/nokiafc22.ttf")
private class FontDefault extends Font {}
#if !FLX_NO_DEBUG
@:keep @:font("assets/fonts/nokiafc22.ttf")
private class FontDebugger extends Font {}
#end

@:keep @:bitmap("assets/images/logo/logo.png")
class GraphicLogo extends BitmapData {}

@:keep @:bitmap("assets/images/ui/virtual-input.png")
class GraphicVirtualInput extends BitmapData {}

@:file("assets/images/ui/virtual-input.txt")
class VirtualInputData extends ByteArray {}
#end

class FlxAssets
{
#if macro
	/**
	 * Reads files from a directory relative to this project and generates public static inlined
	 * variables containing the string paths to the files in it. 
	 * 
	 * Example usage:
	 * @:build(flixel.system.FlxAssets.buildFileReferences("assets/images"))
	 * class Images {}
	 * 
	 * Mostly copied from:
	 * @author Mark Knol
	 * @see http://blog.stroep.nl/2014/01/haxe-macros/
	 * 
	 * @param   directory          The directory to scan for files
	 * @param   subDirectories     Whether to include subdirectories
	 * @param   filterExtensions   Example: ["jpg", "png", "gif"] will only add files with that extension. Null means: all extensions
	 */
	macro public static function buildFileReferences(directory:String = "assets/", subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<Field>
	{
		if (!directory.endsWith("/"))
			directory += "/";
			
		var fileReferences:Array<FileReference> = getFileReferences(directory, subDirectories, filterExtensions);
		
		var fields:Array<Field> = Context.getBuildFields();
			
		for (fileRef in fileReferences)
		{
			// create new field based on file references!
			fields.push({
				name: fileRef.name,
				doc: fileRef.documentation,
				access: [Access.APublic, Access.AStatic, Access.AInline],
				kind: FieldType.FVar(macro:String, macro $v{ fileRef.value }),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	private static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var resolvedPath = #if ios Context.resolvePath(directory) #else directory #end;
		var directoryInfo = FileSystem.readDirectory(resolvedPath);
		for (name in directoryInfo)
		{
			if (!FileSystem.isDirectory(resolvedPath + name))
			{
				// ignore invisible files
				if (name.startsWith("."))
					continue;
				
				if (filterExtensions != null)
				{
					var extension:String = name.split(".")[1]; // get the string after the dot
					if (filterExtensions.indexOf(extension) == -1)
						continue;
				}
				
				fileReferences.push(new FileReference(directory + name));
			}
			else if (subDirectories)
			{
				fileReferences = fileReferences.concat(getFileReferences(directory + name + "/", true, filterExtensions));
			}
		}
		
		return fileReferences;
	}
#else
	// fonts
	public static var FONT_DEFAULT:String = "Nokia Cellphone FC Small";
	public static var FONT_DEBUGGER:String = "Arial";
	
	public static function init():Void
	{
		Font.registerFont(FontDefault);
		
		#if !FLX_NO_DEBUG
		Font.registerFont(FontDebugger);
		#end
	}
	
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
		return Assets.getBitmapData(id, false);
	}
	
	/**
	 * Generates BitmapData from specified class. Less typing.
	 * 
	 * @param	source	BitmapData class to generate BitmapData object from.
	 * @return	Newly instantiated BitmapData object.
	 */
	public static inline function getBitmapFromClass(source:Class<Dynamic>):BitmapData
	{
		return Type.createInstance(source, [0, 0]);
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
		if (Std.is(Graphic, BitmapData))
		{
			return cast(Graphic, BitmapData);
		}
		else if (Std.is(Graphic, Class))
		{
			return FlxAssets.getBitmapFromClass(cast Graphic);
		}
		else if (Std.is(Graphic, String))
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
		
		if (Std.is(Graphic, BitmapData))
		{
			return Key;
		}
		else if (Std.is(Graphic, Class))
		{
			return FlxG.bitmap.getKeyForClass(cast Graphic);
		}
		else if (Std.is(Graphic, String))
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
		var graphic:FlxGraphic = FlxGraphic.fromClass(GraphicVirtualInput);
		return FlxAtlasFrames.fromSpriteSheetPacker(graphic, Std.string(new VirtualInputData()));
	}
#end
}

#if macro
private class FileReference
{
	public var name:String;
	public var value:String;
	public var documentation:String;
	
	public function new(value:String)
	{
		this.value = value;
		
		// replace some forbidden names to underscores, since variables cannot have these symbols.
		this.name = value.split("-").join("_").split(".").join("__");
		var split:Array<String> = name.split("/");
		this.name = split[split.length - 1];
		
		// auto generate documentation
		this.documentation = "\"" + value + "\" (auto generated).";
	}
}
#else
typedef FlxAngelCodeSource = OneOfTwo<Xml, String>;
typedef FlxSoundAsset = OneOfThree<String, Sound, Class<Sound>>;
typedef FlxGraphicAsset = OneOfThree<FlxGraphic, BitmapData, String>;
typedef FlxGraphicSource = OneOfThree<BitmapData, Class<Dynamic>, String>;
typedef FlxTilemapGraphicAsset = OneOfFour<FlxTileFrames, FlxGraphic, BitmapData, String>;

private abstract OneOfTwo<T1, T2>(Dynamic) from T1 from T2 to T1 to T2 { }
private abstract OneOfThree<T1, T2, T3>(Dynamic) from T1 from T2 from T3 to T1 to T2 to T3 {}
private abstract OneOfFour<T1, T2, T3, T4>(Dynamic) from T1 from T2 from T3 from T4 to T1 to T2 to T3 to T4 { }
private abstract OneOfFive<T1, T2, T3, T4, T5>(Dynamic) from T1 from T2 from T3 from T4 from T5 to T1 to T2 to T3 to T4 to T5 { }
#end
