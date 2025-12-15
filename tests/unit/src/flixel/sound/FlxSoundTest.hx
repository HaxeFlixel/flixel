package flixel.sound;

class FlxSoundTest
{
	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		var sound = new FlxSound();
		sound.load("assets/invalid");
		sound.play();
	}
}
