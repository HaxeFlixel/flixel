package flixel.tweens;

import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import massive.munit.Assert;

class FlxTweenTest extends FlxTest
{
	var value:Int;
	
	@Before
	function before()
	{
		value = 0;
	}
	
	@Test
	function testIssue1104()
	{
		FlxTween.tween(this, { value:  1000 }, 1);
		FlxTween.tween(this, { value: -1000 }, 1,  { startDelay: 1 } );
		
		// check that there is actually some tweening going on
		step(10);
		var sampleValue = value;
		
		step(10);
		Assert.areNotEqual(value, sampleValue);
	}
	
	@Test
	function testPauseLoopingTweenInOnComplete()
	{
		var tweenActive:Bool = false;
		
		var tween = FlxTween.tween(this, { value: 50 }, 0.05, { type: FlxTween.LOOPING, onComplete:
			function (tween:FlxTween)
			{
				tween.active = false;
				new FlxTimer().start(0.05, function(_)
				{
					tweenActive = tween.active;
				});
			}
		} );
		
		step(10);
		Assert.isFalse(tweenActive);
		
		var resumeSuccesful:Bool = false;
		
		tween.active = true;
		tween.onComplete = function (_)
		{
			resumeSuccesful = true;
		};
		
		step(10);
		Assert.isTrue(resumeSuccesful);
	}
	
	@Test
	function testScaleIsValidWithStartDelay()
	{
		FlxTween.num(0, 1, 0.2, { startDelay: 0.1 }, function (f:Float)
		{
			Assert.isNotNaN(f);
			Assert.isNotNull(f);
		});
		step();
	}
	
	@Test
	function testCancelNoCallback()
	{
		var tween = FlxTween.tween(this, { value: 100 }, 0.01, { onComplete: function (_)
		{
			Assert.fail("Callback called");
		}});
		tween.cancel();
		step();
	}
}