package flixel.system;

import flash.display.BitmapData;
import flash.display.Graphics;
import openfl.Assets;

class FlxAssets
{
	inline static public var imgDefaultButton:String = "assets/data/button.png";
	inline static public var imgLogo:String = "assets/data/logo.png";
	inline static public var imgDefault:String = "assets/data/default.png";
	inline static public var imgAuto:String = "assets/data/autotiles.png";
	inline static public var imgAutoAlt:String = "assets/data/autotiles_alt.png";
	inline static public var imgLogoCorners:String = "assets/data/logo_corners.png";
	inline static public var imgLogoLight:String = "assets/data/logo_light.png";
	inline static public var imgHandle:String = "assets/data/handle.png";
	inline static public var imgDefaultCursor:String = "assets/data/cursor.png";
	inline static public var imgBounds:String = "assets/data/vis/bounds.png";
	inline static public var imgOpen:String = "assets/data/vcr/open.png";
	inline static public var imgRecordOff:String = "assets/data/vcr/record_off.png";
	inline static public var imgRecordOn:String = "assets/data/vcr/record_on.png";
	inline static public var imgStop:String = "assets/data/vcr/stop.png";
	inline static public var imgFlixel:String = "assets/data/vcr/flixel.png";
	inline static public var imgRestart:String = "assets/data/vcr/restart.png";
	inline static public var imgPause:String = "assets/data/vcr/pause.png";
	inline static public var imgPlay:String = "assets/data/vcr/play.png";
	inline static public var imgStep:String = "assets/data/vcr/step.png";
	
	inline static public var imgBase:String = "assets/data/base.png";
	inline static public var imgStick:String = "assets/data/stick.png";
	inline static public var imgButtonA:String = "assets/data/button_a.png";
	inline static public var imgButtonB:String = "assets/data/button_b.png";
	inline static public var imgButtonC:String = "assets/data/button_c.png";
	inline static public var imgButtonX:String = "assets/data/button_x.png";
	inline static public var imgButtonY:String = "assets/data/button_y.png";
	inline static public var imgButtonUp:String = "assets/data/button_up.png";
	inline static public var imgButtonDown:String = "assets/data/button_down.png";
	inline static public var imgButtonLeft:String = "assets/data/button_left.png";
	inline static public var imgButtonRight:String = "assets/data/button_right.png";
	
	inline static public var debuggerFont:String = "assets/data/courier.ttf";
	inline static public var defaultFont:String = "assets/data/nokiafc22.ttf";
	
	inline static public var sndBeep:String = "Beep";
	
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
		return Assets.getBitmapData(id);
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
	
	static public function addBitmapDataToCache(Key:String, Bmd:BitmapData):Void
	{
		Reflect.callMethod(Assets, Reflect.field(Assets, "initialize"), []);
		var resourceTypes:Map<String, String> = cast Reflect.getProperty(Assets, "resourceTypes");
		
		resourceTypes.set(Key, "image");
		Assets.cachedBitmapData.set(Key, Bmd);
	}
}