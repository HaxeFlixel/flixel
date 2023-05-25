package flixel.sound;

class FlxSoundTest
{
	@Test // #1511
	function testLoadEmbeddedInvalidSoundPathNoCrash()
	{
		var sound = new FlxSound();
		sound.loadEmbedded("assets/invalid");
		sound.play();
	}
}
