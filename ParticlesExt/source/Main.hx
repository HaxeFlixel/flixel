package;

import flash.display.Sprite;
import flash.Lib;

/**
 * ...
 * @author Zaphod
 */

class Main extends Sprite
{
	
	static function main() 
	{
		new Main();
	}
	
	public function new() 
	{
		super();
		flash.Lib.current.addChild(new ParticleTest());
	}
}