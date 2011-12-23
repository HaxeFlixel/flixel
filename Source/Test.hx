package;

import nme.display.BitmapData;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
import nme.display.FPS;
import nme.display.Sprite;
import nme.display.Tilesheet;
import nme.events.Event;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.Lib;

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
		//Lib.current.stage.align = StageAlign.TOP_LEFT;
		//Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Test());
	}
	
}