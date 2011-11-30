package;

import nme.display.Sprite;
import nme.display.StageAlign;
import nme.display.StageScaleMode;
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
		
		var demo:FlxGame = new ParticlesDemo();
		addChild(demo);
	}
	
	private function initialize():Void 
	{
		Lib.current.stage.align = StageAlign.TOP_LEFT;
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Test());
	}
	
}