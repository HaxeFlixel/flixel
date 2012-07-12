package;

import nme.Lib;
import org.flixel.FlxGame;

class BrickMain extends FlxGame 
{
	public function new()
	{
		super(312, 152, PlayState, 1);
	}
	
	public static function main()
	{
		Lib.current.stage.addChild(new BrickMain());
	}
}