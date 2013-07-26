package flixel.system;

import flash.display.BitmapData;
import flash.display.Graphics;
import flash.text.Font;
import openfl.Assets;
import flixel.FlxG;

@:font("assets/fonts/nokiafc22.ttf") class DefaultFont extends Font { }
@:font("assets/fonts/arial.ttf") class DebuggerFont extends Font { }

class FlxAssets
{
	// debugger 
	inline static public var IMG_WINDOW_HANDLE:String = "images/debugger/windowHandle.png";
	inline static public var IMG_FLIXEL:String = "images/debugger/flixel.png";
	
	// debugger/buttons
	inline static public var IMG_VISUAL_DEBUG:String = "images/debugger/buttons/visualDebug.png";
	inline static public var IMG_OPEN:String = "images/debugger/buttons/open.png";
	inline static public var IMG_RECORD_OFF:String = "images/debugger/buttons/record_off.png";
	inline static public var IMG_RECORD_ON:String = "images/debugger/buttons/record_on.png";
	inline static public var IMG_STOP:String = "images/debugger/buttons/stop.png";
	inline static public var IMG_RESTART:String = "images/debugger/buttons/restart.png";
	inline static public var IMG_PAUSE:String = "images/debugger/buttons/pause.png";
	inline static public var IMG_PLAY:String = "images/debugger/buttons/play.png";
	inline static public var IMG_STEP:String = "images/debugger/buttons/step.png";
	
	// logo
	inline static public var IMG_LOGO:String = "images/logo/logo.png";
	inline static public var IMG_DEFAULT:String = "images/logo/default.png";
	
	// preloader
	inline static public var IMG_CORNERS:String = "images/preloader/corners.png";
	inline static public var IMG_LIGHT:String = "images/preloader/light.png";
	
	// tile
	inline static public var IMG_AUTO:String = "images/tile/autotiles.png";
	inline static public var IMG_AUTO_ALT:String = "images/tile/autotiles_alt.png";
	
	// ui
	inline static public var IMG_BUTTON:String = "images/ui/button.png";
	inline static public var IMG_CURSOR:String = "images/ui/cursor.png";

	// ui/gamepad
	inline static public var IMG_BUTTON_A:String = "images/ui/gamepad/button_a.png";
	inline static public var IMG_BUTTON_B:String = "images/ui/gamepad/button_b.png";
	inline static public var IMG_BUTTON_C:String = "images/ui/gamepad/button_c.png";
	inline static public var IMG_BUTTON_X:String = "images/ui/gamepad/button_x.png";
	inline static public var IMG_BUTTON_Y:String = "images/ui/gamepad/button_y.png";
	inline static public var IMG_BUTTON_UP:String = "images/ui/gamepad/button_up.png";
	inline static public var IMG_BUTTON_DOWN:String = "images/ui/gamepad/button_down.png";
	inline static public var IMG_BUTTON_LEFT:String = "images/ui/gamepad/button_left.png";
	inline static public var IMG_BUTTON_RIGHT:String = "images/ui/gamepad/button_right.png";
	
	// fonts
	inline static public var FONT_DEFAULT:String = "Nokia Cellphone FC Small";
	inline static public var FONT_DEBUGGER:String = "Arial";
	
	// sounds
	#if (flash || js)
	inline static public var SND_BEEP:String = "sounds/beep.mp3";
	#else
	inline static public var SND_BEEP:String = "sounds/beep.wav";
	#end
	
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