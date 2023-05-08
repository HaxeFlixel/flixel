package flixel.sound;

import massive.munit.Assert;

class FlxSoundGroupTest
{
	@Test
	function testLengthAfterAdd()
	{
		var group = new FlxSoundGroup();
		group.add(new FlxSound());
		Assert.areEqual(1, group.sounds.length);
	}
}
