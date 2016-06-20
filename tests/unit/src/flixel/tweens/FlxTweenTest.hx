package flixel.tweens;

import flixel.tweens.FlxTween.TweenCallback;
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
		
		var tween = FlxTween.tween(this, { value: 50 }, 0.05, {
			type: FlxTween.LOOPING,
			onComplete: function (tween:FlxTween)
			{
				tween.active = false;
				new FlxTimer().start(0.05, function(_)
				{
					tweenActive = tween.active;
				});
			}
		});
		
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
		var tween = FlxTween.tween(this, { value: 100 }, 0.01, {
			onComplete: function (_)
				Assert.fail("Callback called")
		});
		tween.cancel();
		step();
	}

	@Test
	function testLinearChain()
	{
		testChain(4, function(tweens)
			tweens[0]
				.then(tweens[1])
				.then(tweens[2])
				.then(tweens[3])
		);
	}

	@Test // #1871
	function testNestedChain()
	{
		testChain(4, function(tweens)
			tweens[0]
				.then(tweens[1].then(tweens[2]))
				.then(tweens[3])
		);

		testChain(4, function(tweens)
			tweens[0]
				.then(tweens[1]
					.then(tweens[2]
						.then(tweens[3])))
		);
	}

	function testChain(numTweens:Int, createChain:Array<FlxTween>->Void)
	{
		var complete = [];
		var tweens = [];

		for (i in 0...numTweens)
		{
			complete.push(false);
			var duration = (numTweens / 10) - (i * 0.1);
			tweens.push(makeTween(duration, makeCallback(i, complete)));
		}

		createChain(tweens);
		
		for (i in 0...tweens.length)
		{
			finishTween(tweens[i]);
			Assert.isTrue(complete[i]);
		}
	}

	function makeCallback(n:Int, complete:Array<Bool>):TweenCallback
	{
		return function(_)
		{
			for (i in 0...complete.length)
			{
				var shouldBe = function(b:Bool)
				{
					if (complete[i] != b)
						Assert.fail('complete[$i] should be "$b" for tween $n');
				}
				
				// all tweens before this one should be complete
				shouldBe(i < n);
			}
			
			complete[n] = true;
		};
	}

	function makeTween(duration:Float, onComplete:TweenCallback):FlxTween
	{
		var foo = { f: 0 };
		return FlxTween.tween(foo, { f: 1 }, duration, { onComplete: onComplete });
	}
}