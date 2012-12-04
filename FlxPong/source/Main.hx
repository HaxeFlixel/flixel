/**
* FlxSnake
* @author Richard Davey
*/

package;

import org.flixel.FlxGame;
import nme.Lib;

class Main extends FlxGame
{
	
	public function new()
	{
		super(224, 160, MenuState, 2, 60, 60, true);
	}
	
	public static function main() 
	{
		var pong = new Main();
		Lib.current.stage.addChild(pong);
	}
}