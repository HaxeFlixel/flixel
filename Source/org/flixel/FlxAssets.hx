package org.flixel;

import nme.display.Bitmap;
import nme.media.Sound;
import nme.Assets;

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
		return Assets.getSound("assets/data/beep.mp3");
	}
	
}

class ImgDefaultButton extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/data/button.png")); }
}

class ImgLogo extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/data/logo.png")); }
}

/*class SndBeep extends Sound 
{ 
	public function new() { super(ApplicationMain.getAsset("assets/data/beep.mp3")); } 
}*/

class ImgDefault extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/default.png")); }
}
//
class ImgAuto extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/autotiles.png")); }
}

class ImgAutoAlt extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/autotiles_alt.png")); }
}

class ImgLogoCorners extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/logo_corners.png")); }
}

class ImgLogoLight extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/logo_light.png")); }
}

class ImgHandle extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/handle.png")); }
}

class ImgDefaultCursor extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/cursor.png")); }
}

class ImgBounds extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vis/bounds.png")); }
}

class ImgOpen extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/open.png")); }
}

class ImgRecordOff extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/record_off.png")); }
}

class ImgRecordOn extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/record_on.png")); }
}

class ImgStop extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/stop.png")); }
}

class ImgFlixel extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/flixel.png")); }
}

class ImgRestart extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/restart.png")); }
}

class ImgPause extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/pause.png")); }
}

class ImgPlay extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/play.png")); }
}

class ImgStep extends Bitmap 
{
	public function new() { super(Assets.getBitmapData("assets/data/vcr/step.png")); }
}