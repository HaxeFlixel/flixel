package;

import flash.display.Sprite;
import flash.Lib;

import org.flixel.FlxGame;

/**
 * @author Joshua Granick
 */
class Main extends Sprite 
{
	
	public function new () 
	{
		super();
		
		var demo:FlxGame = new FlxTeroids();
		addChild(demo);
	}
	
	// Entry point
	public static function main() {
		
		Lib.current.addChild(new Main());
	}
	
}