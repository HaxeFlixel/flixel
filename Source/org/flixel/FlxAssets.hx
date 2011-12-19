package org.flixel;
<<<<<<< HEAD
import flash.display.Bitmap;
import flash.media.Sound;
=======

import nme.display.Bitmap;
import nme.media.Sound;
import nme.Assets;
import nme.text.Font;
>>>>>>> dev

/**
 * ...
 * @author Zaphod
 */

class FlxAssets 
{

	public static var imgDefaultButton:Class<Bitmap> = ImgDefaultButton;
	public static var imgLogo:Class<Bitmap> = ImgLogo;
	public static var imgDefault:Class<Bitmap> = ImgDefault;
	public static var imgAuto:Class<Bitmap> = ImgAuto;
	public static var imgAutoAlt:Class<Bitmap> = ImgAutoAlt;
	public static var imgLogoCorners:Class<Bitmap> = ImgLogoCorners;
	public static var imgLogoLight:Class<Bitmap> = ImgLogoLight;
	public static var imgHandle:Class<Bitmap> = ImgHandle;
	public static var imgDefaultCursor:Class<Bitmap> = ImgDefaultCursor;
	public static var imgBounds:Class<Bitmap> = ImgBounds;
	public static var imgOpen:Class<Bitmap> = ImgOpen;
	public static var imgRecordOff:Class<Bitmap> = ImgRecordOff;
	public static var imgRecordOn:Class<Bitmap> = ImgRecordOn;
	public static var imgStop:Class<Bitmap> = ImgStop;
	public static var imgFlixel:Class<Bitmap> = ImgFlixel;
	public static var imgRestart:Class<Bitmap> = ImgRestart;
	public static var imgPause:Class<Bitmap> = ImgPause;
	public static var imgPlay:Class<Bitmap> = ImgPlay;
	public static var imgStep:Class<Bitmap> = ImgStep;
	
	public static var sndBeep(getSndBeep, null):Sound;
	public static function getSndBeep():Sound
	{
<<<<<<< HEAD
		return ApplicationMain.getAsset("assets/data/beep.mp3");
=======
		return Assets.getSound("assets/data/beep.mp3");
	}
	
	public static var nokiaFont(getNokiaFont, null):String;
	public static function getNokiaFont():String
	{
		return Assets.getFont("assets/data/nokiafc22.ttf").fontName;
	}
	
	public static var courierFont(getCourierFont, null):String;
	public static function getCourierFont():String
	{
		return Assets.getFont("assets/data/courier.ttf").fontName;
>>>>>>> dev
	}
	
}

class ImgDefaultButton extends Bitmap
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/button.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/button.png")); }
>>>>>>> dev
}

class ImgLogo extends Bitmap
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/logo.png")); }
}

/*class SndBeep extends Sound 
{ 
	public function new() { super(ApplicationMain.getAsset("assets/data/beep.mp3")); } 
}*/

class ImgDefault extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/default.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/logo.png")); }
}

class ImgDefault extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/default.png")); }
>>>>>>> dev
}
//
class ImgAuto extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/autotiles.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/autotiles.png")); }
>>>>>>> dev
}

class ImgAutoAlt extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/autotiles_alt.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/autotiles_alt.png")); }
>>>>>>> dev
}

class ImgLogoCorners extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/logo_corners.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/logo_corners.png")); }
>>>>>>> dev
}

class ImgLogoLight extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/logo_light.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/logo_light.png")); }
>>>>>>> dev
}

class ImgHandle extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/handle.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/handle.png")); }
>>>>>>> dev
}

class ImgDefaultCursor extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/cursor.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/cursor.png")); }
>>>>>>> dev
}

class ImgBounds extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vis/bounds.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vis/bounds.png")); }
>>>>>>> dev
}

class ImgOpen extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/open.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/open.png")); }
>>>>>>> dev
}

class ImgRecordOff extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/record_off.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/record_off.png")); }
>>>>>>> dev
}

class ImgRecordOn extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/record_on.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/record_on.png")); }
>>>>>>> dev
}

class ImgStop extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/stop.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/stop.png")); }
>>>>>>> dev
}

class ImgFlixel extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/flixel.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/flixel.png")); }
>>>>>>> dev
}

class ImgRestart extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/restart.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/restart.png")); }
>>>>>>> dev
}

class ImgPause extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/pause.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/pause.png")); }
>>>>>>> dev
}

class ImgPlay extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/play.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/play.png")); }
>>>>>>> dev
}

class ImgStep extends Bitmap 
{
<<<<<<< HEAD
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/step.png")); }
=======
	public function new() { super(Assets.getBitmapData("assets/data/vcr/step.png")); }
>>>>>>> dev
}