package flixel.sound;

import massive.munit.Assert;

class FlxSoundTest extends FlxTest
{
	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		var sound = new FlxSound();
		sound.load("assets/invalid");
		sound.play();
	}
}
