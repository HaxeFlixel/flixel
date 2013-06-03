package;

import flash.display.BitmapData;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import openfl.display.FPS;
import flash.display.Sprite;
import flash.events.Event;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.Lib;

import org.flixel.FlxGame;

/**
 * @author Joshua Granick
 */
class Test extends Sprite 
{
	
	public function new () 
	{
		super();
		initialize();
		
		var demo:FlxGame = new Jumper();
		addChild(demo);
		
		var fps:FPS = new FPS();
		fps.textColor = 0xffffff;
		addChild(fps);
		fps.x = 20;
		fps.y = 20;
	}
	
	private function initialize():Void 
	{
		//Lib.current.stage.align = StageAlign.TOP_LEFT;
		//Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Test());
	}
	
}