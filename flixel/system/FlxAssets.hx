package flixel.system;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.text.Font;
import openfl.Assets;
import flixel.FlxG;

@:font("assets/fonts/nokiafc22.ttf") private class FontDefault extends Font { }
#if !FLX_NO_DEBUG
@:font("assets/fonts/arial.ttf") private class FontDebugger extends Font { }
#end

class FlxAssets
{
	// debugger 
	inline public static var IMG_WINDOW_HANDLE:String = "flixel/img/debugger/windowHandle.png";
	inline public static var IMG_FLIXEL:String = "flixel/img/debugger/flixel.png";
	
	// debugger/buttons
	inline public static var IMG_VISUAL_DEBUG:String = "flixel/img/debugger/buttons/drawDebug.png";
	inline public static var IMG_WATCH_DEBUG:String = "flixel/img/debugger/buttons/watchDebug.png";
	inline public static var IMG_STATS_DEBUG:String = "flixel/img/debugger/buttons/statsDebug.png";
	inline public static var IMG_LOG_DEBUG:String = "flixel/img/debugger/buttons/logDebug.png";
	inline public static var IMG_CONSOLE:String = "flixel/img/debugger/buttons/console.png";
	inline public static var IMG_OPEN:String = "flixel/img/debugger/buttons/open.png";
	inline public static var IMG_RECORD_OFF:String = "flixel/img/debugger/buttons/record_off.png";
	inline public static var IMG_RECORD_ON:String = "flixel/img/debugger/buttons/record_on.png";
	inline public static var IMG_STOP:String = "flixel/img/debugger/buttons/stop.png";
	inline public static var IMG_RESTART:String = "flixel/img/debugger/buttons/restart.png";
	inline public static var IMG_PAUSE:String = "flixel/img/debugger/buttons/pause.png";
	inline public static var IMG_PLAY:String = "flixel/img/debugger/buttons/play.png";
	inline public static var IMG_STEP:String = "flixel/img/debugger/buttons/step.png";
	
	// logo
	inline public static var IMG_LOGO:String = "flixel/img/logo/logo.png";
	inline public static var IMG_DEFAULT:String = "flixel/img/logo/default.png";
	
	// preloader
	inline public static var IMG_CORNERS:String = "flixel/img/preloader/corners.png";
	inline public static var IMG_LIGHT:String = "flixel/img/preloader/light.png";
	
	// tile
	inline public static var IMG_AUTO:String = "flixel/img/tile/autotiles.png";
	inline public static var IMG_AUTO_ALT:String = "flixel/img/tile/autotiles_alt.png";
	
	// ui
	inline public static var IMG_BUTTON:String = "flixel/img/ui/button.png";
	inline public static var IMG_CURSOR:String = "flixel/img/ui/cursor.png";

	// ui/analog
	inline public static var IMG_BASE:String = "flixel/img/ui/analog/base.png";
	inline public static var IMG_THUMB:String = "flixel/img/ui/analog/thumb.png";

	// ui/virtualpad
	inline public static var IMG_BUTTON_A:String = "flixel/img/ui/virtualpad/a.png";
	inline public static var IMG_BUTTON_B:String = "flixel/img/ui/virtualpad/b.png";
	inline public static var IMG_BUTTON_C:String = "flixel/img/ui/virtualpad/c.png";
	inline public static var IMG_BUTTON_X:String = "flixel/img/ui/virtualpad/x.png";
	inline public static var IMG_BUTTON_Y:String = "flixel/img/ui/virtualpad/y.png";
	inline public static var IMG_BUTTON_UP:String = "flixel/img/ui/virtualpad/up.png";
	inline public static var IMG_BUTTON_DOWN:String = "flixel/img/ui/virtualpad/down.png";
	inline public static var IMG_BUTTON_LEFT:String = "flixel/img/ui/virtualpad/left.png";
	inline public static var IMG_BUTTON_RIGHT:String = "flixel/img/ui/virtualpad/right.png";
	
	// sounds
	inline public static var SND_BEEP:String = "flixel/snd/beep.wav";
	inline public static var SND_FLIXEL:String = "flixel/snd/flixel.wav";
	
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