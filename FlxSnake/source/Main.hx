/**
* FlxSnake
* @author Richard Davey
*/

package;

import org.flixel.FlxGame;
import flash.Lib;

class Main extends FlxGame
{
	
	public function new()
	{
		super(320, 240, FlxSnake, 2);
	}
	
	public static function main() 
	{
		var snake = new Main();
		Lib.current.stage.addChild(snake);
	}
	
}