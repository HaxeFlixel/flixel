package flixel.system.frontEnds;

import flixel.FlxG;
import massive.munit.Assert;

class SoundFrontEndTest
{
	#if FLX_SOUND_SYSTEM
	@Test // #1511
	function testPlayInvalidSoundPathNoCrash()
	{
		FlxG.sound.play("assets/invalid");
	}

	@Test // #1511
	function testPlayMusicInvalidSoundPathNoCrash()
	{
		FlxG.sound.playMusic("assets/invalid");
	}

	@Test // #1511
	function testLoadInvalidSoundPathNoCrash()
	{
		FlxG.sound.load("assets/invalid").play();
	}

	@Test // #1511
	function testSoundCurve()
	{
		Assert.areEqual(1.0, FlxG.sound.applySoundCurve(1));
		Assert.areEqual(1.0, FlxG.sound.reverseSoundCurve(1));
		
		FlxG.sound.applySoundCurve = function (volume)
		{
			final clampedVolume = Math.max(0, Math.min(1, volume));
			return Math.exp(Math.log(0.001) * (1 - volume));
		};
		
		FlxG.sound.reverseSoundCurve = function (volume)
		{
			final clampedVolume = Math.max(0.001, Math.min(1, volume));
			return 1 - (Math.log(clampedVolume) / Math.log(0.001));
		};
		
		FlxAssert.areNear(1.0, FlxG.sound.applySoundCurve(1));
		FlxAssert.areNear(1.0, FlxG.sound.reverseSoundCurve(1));
		FlxAssert.areNear(0.001, FlxG.sound.applySoundCurve(0));
		FlxAssert.areNear(0.0, FlxG.sound.reverseSoundCurve(0));
		FlxAssert.areNear(0.031, FlxG.sound.applySoundCurve(0.5));
		FlxAssert.areNear(0.899, FlxG.sound.reverseSoundCurve(0.5));
		FlxAssert.areNear(0.5, FlxG.sound.reverseSoundCurve(FlxG.sound.applySoundCurve(0.5)));
	}
	#end
}
