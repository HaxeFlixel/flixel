package ;
<<<<<<< HEAD
import flash.display.Bitmap;
import flash.media.Sound;
import nme.installer.Assets;
=======
import nme.display.Bitmap;
import nme.media.Sound;
import nme.Assets;
>>>>>>> dev

/**
 * ...
 * @author Zaphod
 */

class FlxAssets 
{

<<<<<<< HEAD
	public static var imgDefaultButton:Class<Bitmap> = ImgDefaultButton;
	public static var imgLogo:Class<Bitmap> = ImgLogo;
//	public static var sndBeep:Class<Sound> = SndBeep;
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
		return ApplicationMain.getAsset("assets/data/beep.mp3");
	}
}

class ImgDefaultButton extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/data/button.png")); }
}

class ImgLogo extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/data/logo.png")); }
}

class ImgDefault extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/default.png")); }
}
//
class ImgAuto extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/autotiles.png")); }
}

class ImgAutoAlt extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/autotiles_alt.png")); }
}

class ImgLogoCorners extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/logo_corners.png")); }
}

class ImgLogoLight extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/logo_light.png")); }
}

class ImgHandle extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/handle.png")); }
}

class ImgDefaultCursor extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/cursor.png")); }
}

class ImgBounds extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vis/bounds.png")); }
}

class ImgOpen extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/open.png")); }
}

class ImgRecordOff extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/record_off.png")); }
}

class ImgRecordOn extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/record_on.png")); }
}

class ImgStop extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/stop.png")); }
}

class ImgFlixel extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/flixel.png")); }
}

class ImgRestart extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/restart.png")); }
}

class ImgPause extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/pause.png")); }
}

class ImgPlay extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/play.png")); }
}

class ImgStep extends Bitmap 
{
	public function new() { super(ApplicationMain.getAsset("assets/data/vcr/step.png")); }
=======
	public static var imgBullet:Class<Bitmap> = ImgBullet;
	public static var imgSpawnerGibs:Class<Bitmap> = ImgSpawnerGibs;
	public static var imgSpawner:Class<Bitmap> = ImgSpawner;
	public static var imgSpaceman:Class<Bitmap> = ImgSpaceman;
	public static var imgBot:Class<Bitmap> = ImgBot;
	public static var imgJet:Class<Bitmap> = ImgJet;
	public static var imgBotBullet:Class<Bitmap> = ImgBotBullet;
	public static var imgTechTiles:Class<Bitmap> = ImgTechTiles;
	public static var imgDirtTop:Class<Bitmap> = ImgDirtTop;
	public static var imgDirt:Class<Bitmap> = ImgDirt;
	public static var imgGibs:Class<Bitmap> = ImgGibs;
	public static var imgMiniFrame:Class<Bitmap> = ImgMiniFrame;
	public static var imgCursor:Class<Bitmap> = ImgCursor;
	
}

class ImgBullet extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/bullet.png")); }
}

class ImgSpawnerGibs extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/spawner_gibs.png")); }
}

class ImgSpawner extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/spawner.png")); }
}

class ImgSpaceman extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/spaceman.png")); }
}

class ImgBot extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/bot.png")); }
}

class ImgJet extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/jet.png")); }
}

class ImgBotBullet extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/bot_bullet.png")); }
}

class ImgTechTiles extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/tech_tiles.png")); }
}

class ImgDirtTop extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/dirt_top.png")); }
}

class ImgDirt extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/dirt.png")); }
}

class ImgGibs extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/gibs.png")); }
}

class ImgMiniFrame extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/miniframe.png")); }
}

class ImgCursor extends Bitmap
{
	public function new() { super(Assets.getBitmapData("assets/cursor.png")); }
>>>>>>> dev
}