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
import openfl.Assets;

/** Fonts **/
@:font("assets/fonts/nokiafc22.ttf")
private class FontDefault extends Font {}
#if !FLX_NO_DEBUG
@:font("assets/fonts/arial.ttf")
private class FontDebugger extends Font {}
#end

@:bitmap("assets/images/logo/logo.png")
class GraphicLogo extends BitmapData {}
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
	 * @param   filterExtensions   Example: [jpg, png, gif] will only add files with that extension. Null means: all extensions
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
				kind: FieldType.FVar(macro:String, macro $v{fileRef.value}),
				pos: Context.currentPos()
			});
		}
		return fields;
	}
	
	private static function getFileReferences(directory:String, subDirectories:Bool = false, ?filterExtensions:Array<String>):Array<FileReference>
	{
		var fileReferences:Array<FileReference> = [];
		var directoryInfo = FileSystem.readDirectory(directory);
		for (name in directoryInfo)
		{
			if (!FileSystem.isDirectory(directory + name))
			{
				if (filterExtensions != null)
				{
					var extension:String = name.split(".")[1]; // get the string after the dot
					if (filterExtensions.indexOf(extension) == -1)
						break;
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
	
#if (!FLX_NO_SOUND_SYSTEM && !doc)
	/**
	 * Calls FlxG.sound.cache() on all sounds that are embedded.
	 */
	#if (openfl <= "1.4.0")
	@:access(openfl.Assets)
	@:access(openfl.AssetType)
	#end
	public static function cacheSounds():Void
	{
		#if (openfl > "1.4.0")
		for (id in Assets.list(AssetType.SOUND)) 
		{
			FlxG.sound.cache(id);
		}
		#else
		Assets.initialize();
		
		var defaultLibrary = Assets.libraries.get("default");
		
		if (defaultLibrary == null) 
			return;
		
		var types:Map<String, Dynamic> = DefaultAssetLibrary.type;
		
		if (types == null) 
			return;
		
		for (key in types.keys())
		{
			if (types.get(key) == AssetType.SOUND)
			{
				FlxG.sound.cache(key);
			}
		}
		#end
	}
#end
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
#end