package org.flixel;

import nme.Assets;
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
}