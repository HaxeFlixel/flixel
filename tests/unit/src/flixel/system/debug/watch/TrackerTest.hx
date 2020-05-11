package flixel.system.debug.watch;

import flixel.FlxG;
import flixel.math.FlxPoint;

class TrackerTest extends FlxTest
{
	@Test // #1879
	function testSetVisibleCrash()
	{
		FlxG.debugger.track(new FlxPoint()).setVisible(true);
	}
}
