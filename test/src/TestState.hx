package;

import flixel.FlxState;
import flixel.FlxG;

class TestState extends FlxState
{

	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1b;
	}

    override public function update():Void
    {
        super.update();
    }

}