package flixel.sound;

import flixel.FlxG;
import massive.munit.Assert;

class FlxSoundGroupTest
{
	@Test
	function testLengthAfterAdd()
	{
		var group = new FlxSoundGroup();
		var sound = new FlxSound();
		group.add(sound);
		Assert.areEqual(1, group.sounds.length);
		FlxG.sound.defaultSoundGroup.add(sound);
		Assert.areEqual(0, group.sounds.length);
		Assert.areEqual(1, FlxG.sound.defaultSoundGroup.sounds.length);
	}
	
	@:haxe.warning("-WDeprecated")
	function testSetter()
	{
		var group = new FlxSoundGroup();
		var sound = new FlxSound();
		sound.group = group;
		Assert.areEqual(1, group.sounds.length);
		sound.group = FlxG.sound.defaultSoundGroup;
		Assert.areEqual(0, group.sounds.length);
		Assert.areEqual(1, FlxG.sound.defaultSoundGroup.sounds.length);
	}
}
