package org.flixel;

import nme.Assets;
import nme.display.Graphics;
import nme.text.Font;

/**
 * ...
 * @author Zaphod
 */

class FlxAssets //extends Assets
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
	
	public static var nokiaFont(getNokiaFont, null):String;
	public static function getNokiaFont():String
	{
		return Assets.getFont("assets/data/nokiafc22.ttf").fontName;
	}
	
	public static var courierFont(getCourierFont, null):String;
	public static function getCourierFont():String
	{
		return Assets.getFont("assets/data/courier.ttf").fontName;
	}
	
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
	
	// TODO: write code for automatic sound caching for android target
	public static function cacheSounds():Void
	{
		#if android
		/*var resourseType:String;
		var resourseTypes:Hash<String> = cast Reflect.getProperty(Assets, "resourceTypes");
		
		if (resourseTypes != null)
		{
			for (key in resourseTypes.keys())
			{
				resourseType = resourseTypes.get(key);
				
				if (resourseType != null && resourseType == "sound")
				{
					FlxG.addSound(key);
				}
			}
		}*/
		#end
	}
}