package;


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


/**
 * @author Joshua Granick
 */
class Test extends Sprite 
{
	
	public function new () 
	{
		
		super ();
		
		initialize ();
		
		var demo:FlxGame = new ParticlesDemo();
		addChild(demo);
	}
	
	private function initialize ():Void {
		
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
	
	public static function main () {
		
		Lib.current.addChild (new Test());
	}
	
}