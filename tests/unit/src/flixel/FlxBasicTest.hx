package flixel;

import massive.munit.Assert;

class FlxBasicTest extends FlxBasic
{
	var basic1:FlxBasic;
	var basic2:FlxBasic;

	@Before
	function before()
	{
		basic1 = new FlxBasic();
		basic2 = new FlxBasic();
	}

	@Test
	function testAddToState()
	{
		FlxG.state.add(basic1);
		FlxG.state.add(basic2);

		var basic1Index:Int = FlxG.state.members.indexOf(basic1);
		Assert.areNotEqual(-1, basic1Index);

		var basic2Index:Int = FlxG.state.members.indexOf(basic2);
		Assert.areNotEqual(-1, basic2Index);
	}

	@Test
	function testRemoveFromState()
	{
		FlxG.state.remove(basic1);

		var basic1Index:Int = FlxG.state.members.indexOf(basic1);
		Assert.areEqual(-1, basic1Index);

		FlxG.state.add(basic1);

		var basic1Index:Int = FlxG.state.members.indexOf(basic1);
		Assert.areNotEqual(-1, basic1Index);
	}
}
