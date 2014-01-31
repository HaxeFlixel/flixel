package flixel.system;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.text.Font;
import openfl.Assets;
import flixel.FlxG;

#if !FLX_NO_SOUND_SYSTEM
import flash.media.Sound;
#end

/** Fonts **/
@:font("assets/fonts/nokiafc22.ttf") private class FontDefault extends Font {}
#if !FLX_NO_DEBUG
@:font("assets/fonts/arial.ttf") private class FontDebugger extends Font {}
#end

/** Sounds **/
#if !FLX_NO_SOUND_SYSTEM
@:sound("assets/sounds/beep.wav") class BeepSound extends Sound {}
#end

@:bitmap("assets/images/logo/logo.png") class GraphicLogo extends BitmapData {}

class FlxAssets
{
	// debugger/buttons
	public static inline var IMG_VISUAL_DEBUG:String = "flixel/img/debugger/buttons/drawDebug.png";
	public static inline var IMG_WATCH_DEBUG:String = "flixel/img/debugger/buttons/watchDebug.png";
	public static inline var IMG_STATS_DEBUG:String = "flixel/img/debugger/buttons/statsDebug.png";
	public static inline var IMG_LOG_DEBUG:String = "flixel/img/debugger/buttons/logDebug.png";
	public static inline var IMG_CONSOLE:String = "flixel/img/debugger/buttons/console.png";
	public static inline var IMG_OPEN:String = "flixel/img/debugger/buttons/open.png";
	public static inline var IMG_RECORD_OFF:String = "flixel/img/debugger/buttons/record_off.png";
	public static inline var IMG_RECORD_ON:String = "flixel/img/debugger/buttons/record_on.png";
	public static inline var IMG_STOP:String = "flixel/img/debugger/buttons/stop.png";
	public static inline var IMG_RESTART:String = "flixel/img/debugger/buttons/restart.png";
	public static inline var IMG_PAUSE:String = "flixel/img/debugger/buttons/pause.png";
	public static inline var IMG_PLAY:String = "flixel/img/debugger/buttons/play.png";
	public static inline var IMG_STEP:String = "flixel/img/debugger/buttons/step.png";
	
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
	
	#if !FLX_NO_SOUND_SYSTEM
	/**
	 * Sound caching for android target
	 */
	@:access(openfl.Assets)
	@:access(openfl.AssetType)
	public static function cacheSounds():Void
	{
		#if android
		Assets.initialize();
		
		var defaultLibrary = Assets.libraries.get("default");
		
		if (defaultLibrary == null) return;
		
		var types:Map<String, Dynamic> = DefaultAssetLibrary.type;
		
		if (types == null) return;
		
		for (key in types.keys())
		{
			if (types.get(key) == AssetType.SOUND)
			{
				FlxG.sound.add(key);
			}
		}
		#end
	}
	#end
}