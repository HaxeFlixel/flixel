package;

import flixel.FlxState;
import flixel.FlxG;

class TestState2 extends FlxState
{

	override public function create():Void
	{
		FlxG.cameras.bgColor = 0xff131c1c;
	}

    override public function update():Void
    {
        super.update();
    }

}