package ;
import flash.display.Bitmap;
import flash.media.Sound;
import openfl.Assets;

/**
 * ...
 * @author Zaphod
 */

class FlxAssets 
{

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
}