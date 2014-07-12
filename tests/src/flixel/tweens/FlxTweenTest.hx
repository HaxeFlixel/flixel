package flixel.tweens;

import flixel.tweens.FlxTween;
import haxe.Timer;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxTweenTest extends FlxTest
{
	var value:Int;
	
	function testIssue1104():Void
	{
		FlxTween.tween(this, { value:  1000 }, 1);
		FlxTween.tween(this, { value: -1000 }, 1,  { startDelay: 1 } );
		
		// check that there is actually some tweening going on
		step(10);
		var sampleValue = value;
		
		step(10);
		Assert.areNotEqual(value, sampleValue);
	}
}