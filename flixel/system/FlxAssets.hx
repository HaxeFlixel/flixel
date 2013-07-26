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
	inline static public var IMG_WINDOW_HANDLE:String = "img/debugger/windowHandle.png";
	inline static public var IMG_FLIXEL:String = "img/debugger/flixel.png";
	
	// debugger/buttons
	inline static public var IMG_VISUAL_DEBUG:String = "img/debugger/buttons/visualDebug.png";
	inline static public var IMG_OPEN:String = "img/debugger/buttons/open.png";
	inline static public var IMG_RECORD_OFF:String = "img/debugger/buttons/record_off.png";
	inline static public var IMG_RECORD_ON:String = "img/debugger/buttons/record_on.png";
	inline static public var IMG_STOP:String = "img/debugger/buttons/stop.png";
	inline static public var IMG_RESTART:String = "img/debugger/buttons/restart.png";
	inline static public var IMG_PAUSE:String = "img/debugger/buttons/pause.png";
	inline static public var IMG_PLAY:String = "img/debugger/buttons/play.png";
	inline static public var IMG_STEP:String = "img/debugger/buttons/step.png";
	
	// logo
	inline static public var IMG_LOGO:String = "img/logo/logo.png";
	inline static public var IMG_DEFAULT:String = "img/logo/default.png";
	
	// preloader
	inline static public var IMG_CORNERS:String = "img/preloader/corners.png";
	inline static public var IMG_LIGHT:String = "img/preloader/light.png";
	
	// tile
	inline static public var IMG_AUTO:String = "img/tile/autotiles.png";
	inline static public var IMG_AUTO_ALT:String = "img/tile/autotiles_alt.png";
	
	// ui
	inline static public var IMG_BUTTON:String = "img/ui/button.png";
	inline static public var IMG_CURSOR:String = "img/ui/cursor.png";

	// ui/gamepad
	inline static public var IMG_BUTTON_A:String = "img/ui/gamepad/button_a.png";
	inline static public var IMG_BUTTON_B:String = "img/ui/gamepad/button_b.png";
	inline static public var IMG_BUTTON_C:String = "img/ui/gamepad/button_c.png";
	inline static public var IMG_BUTTON_X:String = "img/ui/gamepad/button_x.png";
	inline static public var IMG_BUTTON_Y:String = "img/ui/gamepad/button_y.png";
	inline static public var IMG_BUTTON_UP:String = "img/ui/gamepad/button_up.png";
	inline static public var IMG_BUTTON_DOWN:String = "img/ui/gamepad/button_down.png";
	inline static public var IMG_BUTTON_LEFT:String = "img/ui/gamepad/button_left.png";
	inline static public var IMG_BUTTON_RIGHT:String = "img/ui/gamepad/button_right.png";
	
	// fonts
	inline static public var FONT_DEFAULT:String = "Nokia Cellphone FC Small";
	inline static public var FONT_DEBUGGER:String = "Arial";
	
	// sounds
	#if (flash || js)
	inline static public var SND_BEEP:String = "snd/beep.mp3";
	#else
	inline static public var SND_BEEP:String = "snd/beep.wav";
	#end
	
	static public function init():Void
	{
		Font.registerFont(FontDefault);
		
		#if !FLX_NO_DEBUG
		Font.registerFont(FontDebugger);
		#end
	}
	
	static public function drawLogo(graph:Graphics):Void
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
	
	inline static public function getBitmapData(id:String):BitmapData
	{
		return Assets.getBitmapData(id, false);
	}
	
	/**
	 * Sound caching for android target
	 */
	static public function cacheSounds():Void
	{
		#if android
		Reflect.callMethod(Assets, Reflect.field(Assets, "initialize"), []);
		
		var resourceClasses:Map<String, Dynamic> = cast Reflect.getProperty(Assets, "resourceClasses");
		var resourceTypes:Map<String, String> = cast Reflect.getProperty(Assets, "resourceTypes");
		
		if (resourceTypes != null)
		{
			for (key in resourceTypes.keys())
			{
				if (resourceTypes.get(key) == "sound")
				{	
					FlxG.sound.add(key);
				}
			}
		}
		#end
	}
}