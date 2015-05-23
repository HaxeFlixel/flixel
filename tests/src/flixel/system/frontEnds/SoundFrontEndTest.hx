package flixel.system.frontEnds;

import flixel.FlxG;

class SoundFrontEndTest
{
	@Test // issue 1511
	function testPlayInvalidSoundPathNoCrash()
	{
		FlxG.sound.play("assets/invalid");
	}
	
	@Test // issue 1511
	function testPlayMusicInvalidSoundPathNoCrash()
	{
		FlxG.sound.playMusic("assets/invalid");
	}
	
	@Test // issue 1511
	function testLoadInvalidSoundPathNoCrash()
	{
		FlxG.sound.load("assets/invalid").play();
	}
}