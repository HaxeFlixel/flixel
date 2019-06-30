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
		FlxTween.tween(this, {value: 1000}, 1);
		FlxTween.tween(this, {value: -1000}, 1, {startDelay: 1});

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

		var tween = FlxTween.tween(this, {value: 50}, 0.05, {
			type: LOOPING,
			onComplete: function(tween:FlxTween)
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

		var resumeSuccessful:Bool = false;

		tween.active = true;
		tween.onComplete = function(_)
		{
			resumeSuccessful = true;
		};

		step(10);
		Assert.isTrue(resumeSuccessful);
	}

	@Test
	function testScaleIsValidWithStartDelay()
	{
		FlxTween.num(0, 1, 0.2, {startDelay: 0.1}, function(f:Float)
		{
			Assert.isNotNaN(f);
			Assert.isNotNull(f);
		});
		step();
	}

	@Test
	function testCancelNoCallback()
	{
		var tween = FlxTween.tween(this, {value: 100}, 0.01, {
			onComplete: function(_) Assert.fail("Callback called")
		});
		tween.cancel();
		step();
	}

	@Test
	function testCancelChainFirstTweenUnfinished()
	{
		var chain = createChain(4);

		while (!chain.updated[0])
			step();

		Assert.isFalse(chain.completed[0]);

		chain.tweens[0].cancelChain();

		for (i in 0...chain.count)
			finishTween(chain.tweens[i]);

		for (i in 1...chain.count)
			Assert.isFalse(chain.updated[i] || chain.completed[i]);
	}

	@Test
	function testCancelChainFirstTweenFinished()
	{
		var chain = createChain(4);

		while (!chain.updated[1])
			step();

		Assert.isTrue(chain.updated[0] && chain.completed[0]);
		Assert.isFalse(chain.completed[1]);

		chain.tweens[0].cancelChain();

		for (i in 1...chain.count)
			finishTween(chain.tweens[i]);

		for (i in 2...chain.count)
			Assert.isFalse(chain.updated[i] || chain.completed[i]);
	}

	function createChain(count:Int)
	{
		var updated = [for (i in 0...count) false];
		var completed = [for (i in 0...count) false];
		var tweens = [
			for (i in 0...count)
				makeTween(0.1, function(_) completed[i] = true, function(_) updated[i] = true)
		];

		for (i in 1...count)
			tweens[0].wait(0.1).then(tweens[i]);

		return {
			count: count,
			updated: updated,
			completed: completed,
			tweens: tweens
		}
	}

	@Test
	function testCancelYieldToChain()
	{
		var completed1 = false;
		var tween1 = makeTween(0.1, function(_) completed1 = true);

		var completed2 = false;
		var tween2 = makeTween(0.1, function(_) completed2 = true);

		tween1.then(tween2);
		tween1.cancel();
		finishTween(tween2);

		Assert.isFalse(completed1);
		Assert.isTrue(completed2);
	}

	@Test
	function testLinearChain()
	{
		testChain(4, function(tweens) tweens[0].then(tweens[1]).then(tweens[2]).then(tweens[3]));
	}

	@Test // #1871
	function testNestedChain()
	{
		testChain(4, function(tweens) tweens[0].then(tweens[1].then(tweens[2])).then(tweens[3]));

		testChain(4, function(tweens) tweens[0].then(tweens[1].then(tweens[2].then(tweens[3]))));
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

	@Test
	function testCompleteAll()
	{
		var tween = makeTween(0.1, function(_) {});
		FlxTween.globalManager.completeAll();

		Assert.isTrue(tween.finished);
	}

	@Test // #1955
	function testCompleteAllInactive()
	{
		var tween = makeTween(0.1, function(_) {});
		tween.active = false;
		FlxTween.globalManager.completeAll();

		Assert.isFalse(tween.finished);
	}

	@Test // #665
	@:access(flixel.tweens.FlxTweenManager.remove)
	function testManipulateListInCallback()
	{
		var tween2Updated = false;
		var tween3Updated = false;

		var tween2:FlxTween = null;
		// short duration, so finished after one step()
		var tween1 = makeTween(0.0001, function(_) FlxTween.globalManager.remove(tween2));
		tween2 = makeTween(0.2, null, function(_) tween2Updated = true);
		makeTween(0.2, null, function(_) tween3Updated = true);

		step();
		Assert.isTrue(tween1.finished);
		Assert.isTrue(tween2Updated);
		Assert.isTrue(tween3Updated);
	}

	function makeTween(duration:Float, onComplete:TweenCallback, ?onUpdate:TweenCallback):FlxTween
	{
		var foo = {f: 0};
		return FlxTween.tween(foo, {f: 1}, duration, {onComplete: onComplete, onUpdate: onUpdate});
	}
}
