
package flixel.group;

import flixel.FlxBasic;
import massive.munit.Assert;

class FlxContainerTest extends FlxGroupTest
{
	override function makeGroup():FlxGroup
	{
		var group = new FlxContainer();
		for (i in 0...10)
		{
			group.add(new FlxBasic());
		}
		return group;
	}
}
