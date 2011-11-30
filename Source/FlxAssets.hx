package ;
import flash.display.Bitmap;
import flash.media.Sound;
import nme.installer.Assets;

/**
 * ...
 * @author Zaphod
 */

class FlxAssets 
{

	public static var imgAltTiles:Class<Bitmap> = ImgAltTiles;
	public static var imgAutoTiles:Class<Bitmap> = ImgAutoTiles;
	public static var imgEmptyTiles:Class<Bitmap> = ImgEmptyTiles;
	public static var imgSpaceman:Class<Bitmap> = ImgSpaceman;

	
}

class ImgAltTiles extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/alt_tiles.png")); }
}

class ImgAutoTiles extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/auto_tiles.png")); }
}

class ImgEmptyTiles extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/empty_tiles.png")); }
}

class ImgSpaceman extends Bitmap
{
	public function new() { super(ApplicationMain.getAsset("assets/spaceman.png")); }
}