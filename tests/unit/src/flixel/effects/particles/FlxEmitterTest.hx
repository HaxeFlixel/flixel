package flixel.effects.particles;

import massive.munit.Assert;

class FlxEmitterTest extends FlxTest
{
	var emitter:FlxEmitter;

	@Before
	function before():Void
	{
		emitter = new FlxEmitter();
		destroyable = emitter;
	}

	@Test
	function testStartShouldNotReviveMembers():Void
	{
		emitter.makeParticles(1, 1, 1);
		// precondition
		Assert.isFalse(emitter.exists);
		emitter.forEach(function(each)
		{
			Assert.isFalse(each.exists);
		});
		// exercise
		emitter.start();
		// verify
		Assert.isTrue(emitter.exists);
		emitter.forEach(function(each)
		{
			Assert.isFalse(each.exists);
		});
	}
}
