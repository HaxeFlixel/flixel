package;

import nme.display.Sprite;
import nme.Lib;

import org.flixel.FlxGame;

/**
 * @author Joshua Granick
 */
class Main extends Sprite 
{
	
	public function new () 
	{
		super();
		
		var demo:FlxGame = new CollisionDemo();
		addChild(demo);
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Main());
	}
	
}