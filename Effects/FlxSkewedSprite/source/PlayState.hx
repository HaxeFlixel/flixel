package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.util.FlxColor;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	override public function create():Void
	{
		FlxG.mouse.visible = false;

		// Sky-colored background
		FlxG.cameras.bgColor = FlxColor.CYAN;

		var grassY:Int = FlxG.height - 28;

		var grass1:Grass = new Grass(0, grassY, 0, 0);
		var grass2:Grass = new Grass(0, grassY, 1, -5);
		var grass3:Grass = new Grass(0, grassY, 2, 5);

		add(grass1);
		add(grass2);
		add(grass3);
	}
}
