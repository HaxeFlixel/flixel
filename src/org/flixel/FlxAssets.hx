package org.flixel;

import nme.Assets;
import nme.display.BitmapData;
import nme.display.Graphics;
import nme.text.Font;

/**
 * ...
 * @author Zaphod
 */

class FlxAssets
{
	public static var imgDefaultButton:String = "assets/data/button.png";
	public static var imgLogo:String = "assets/data/logo.png";
	public static var imgDefault:String = "assets/data/default.png";
	public static var imgAuto:String = "assets/data/autotiles.png";
	public static var imgAutoAlt:String = "assets/data/autotiles_alt.png";
	public static var imgLogoCorners:String = "assets/data/logo_corners.png";
	public static var imgLogoLight:String = "assets/data/logo_light.png";
	public static var imgHandle:String = "assets/data/handle.png";
	public static var imgDefaultCursor:String = "assets/data/cursor.png";
	public static var imgBounds:String = "assets/data/vis/bounds.png";
	public static var imgOpen:String = "assets/data/vcr/open.png";
	public static var imgRecordOff:String = "assets/data/vcr/record_off.png";
	public static var imgRecordOn:String = "assets/data/vcr/record_on.png";
	public static var imgStop:String = "assets/data/vcr/stop.png";
	public static var imgFlixel:String = "assets/data/vcr/flixel.png";
	public static var imgRestart:String = "assets/data/vcr/restart.png";
	public static var imgPause:String = "assets/data/vcr/pause.png";
	public static var imgPlay:String = "assets/data/vcr/play.png";
	public static var imgStep:String = "assets/data/vcr/step.png";
	
	public static var imgBase:String = "assets/data/base.png";
	public static var imgStick:String = "assets/data/stick.png";
	public static var imgButtonA:String = "assets/data/button_a.png";
	public static var imgButtonB:String = "assets/data/button_b.png";
	public static var imgButtonC:String = "assets/data/button_c.png";
	public static var imgButtonX:String = "assets/data/button_x.png";
	public static var imgButtonY:String = "assets/data/button_y.png";
	public static var imgButtonUp:String = "assets/data/button_up.png";
	public static var imgButtonDown:String = "assets/data/button_down.png";
	public static var imgButtonLeft:String = "assets/data/button_left.png";
	public static var imgButtonRight:String = "assets/data/button_right.png";
	
	public static var debuggerFont:String = "assets/data/courier.ttf";
	public static var defaultFont:String = "assets/data/nokiafc22.ttf";
	
	public static var sndBeep:String = "Beep";
	
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
	
	public static function getBitmapData(id:String):BitmapData
	{
		return Assets.getBitmapData(id);
	}
	
	/**
	 * Sound caching for android target
	 */
	public static function cacheSounds():Void
	{
		#if android
		Reflect.callMethod(nme.installer.Assets, "initialize", []);
		
		var resourceClasses:Hash<Dynamic> = cast Reflect.getProperty(nme.installer.Assets, "resourceClasses");
		var resourceTypes:Hash<String> = cast Reflect.getProperty(nme.installer.Assets, "resourceTypes");
		
		if (resourceTypes != null)
		{
			for (key in resourceTypes.keys())
			{
				if (resourceTypes.get(key) == "sound")
				{	
					FlxG.addSound(key);
				}
			}
		}
		#end
	}
}