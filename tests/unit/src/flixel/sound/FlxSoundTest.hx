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
	
	@Test
	@Ignore("Unable to unit test sounds")
	function testPlay()
	{
		var sound = new FlxSound();
		sound.load("flxiel/sounds/flixel");
		sound.play();
		// step();
		
		Assert.isTrue(sound.playing);
	}
}
