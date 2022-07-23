package flixel.util;

import massive.munit.Assert;

class FlxSaveTest extends FlxTest
{
	static inline var SAVE_NAME = "test";

	var save:FlxSave;

	@Before
	function before()
	{
		save = new FlxSave();
		save.bind(SAVE_NAME);
	}

	@Test
	function testName()
	{
		Assert.areEqual(SAVE_NAME, save.name);
	}

	@Test
	function testBind()
	{
		Assert.isTrue(save.bind(SAVE_NAME));
	}

	@Test
	function testSaveData()
	{
		save.data.value = 1;
		save.close();
		step();
		save.bind(SAVE_NAME);

		Assert.isNotNull(save.data);
		Assert.areEqual(1, save.data.value);
	}

	@Test // #1302
	function testErase()
	{
		save.data.int = 1;
		save.erase();

		Assert.isNotNull(save.data);
		Assert.isNull(save.data.int);
	}
}
