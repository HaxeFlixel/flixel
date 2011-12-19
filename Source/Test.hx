package;

<<<<<<< HEAD

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Shape;
import flash.display.Sprite;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.media.Sound;
import flash.text.TextFormat;
import flash.text.TextField;
import flash.Lib;
import flash.ui.Mouse;
import org.flixel.FlxG;
import org.flixel.FlxGame;
import org.flixel.FlxSound;
import org.flixel.FlxSprite;
import org.flixel.FlxText;
import org.flixel.FlxTileblock;
import org.flixel.FlxTilemap;
import org.flixel.system.FlxDebugger;
import org.flixel.system.FlxReplay;

=======
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.FPS;
import nme.display.Sprite;
import nme.Lib;

import org.flixel.FlxGame;
>>>>>>> dev

/**
 * @author Joshua Granick
 */
class Test extends Sprite 
{
<<<<<<< HEAD
	
	public function new () 
	{
		
		super ();
		
		initialize ();
		
		var demo:FlxGame = new ParticlesDemo();
		addChild(demo);
	}
	
	private function initialize ():Void {
		
=======
		
	public function new () 
	{
		super();
		initialize();
		
		var demo:FlxGame = new Mode();
		addChild(demo);
		
		var fps:FPS = new FPS();
		fps.textColor = 0xffffff;
		addChild(fps);
		fps.x = 20;
		fps.y = 20;
	}
	
	private function initialize():Void 
	{
>>>>>>> dev
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
<<<<<<< HEAD
	
	public static function main () {
		
		Lib.current.addChild (new Test());
=======
	public static function main() {
		
		Lib.current.addChild(new Test());
>>>>>>> dev
	}
	
}