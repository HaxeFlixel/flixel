package;

import nme.display.Sprite;
import nme.Lib;

/**
 * ...
 * @author Zaphod
 */

class Main extends Sprite
{
	
	public static function main() 
	{
		new Main();
	}
	
	public function new() 
	{
		super();
		Lib.current.addChild(new ControllerTest());
	}
}