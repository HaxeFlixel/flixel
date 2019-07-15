package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.watch.Tracker.TrackerProfile;
import flixel.util.FlxSignal;
import massive.munit.Assert;

class DebuggerFrontEndTest
{
	@Test
	function testAddTrackerProfile()
	{
		FlxG.debugger.addTrackerProfile(new TrackerProfile(Array, ["length"]));
	}

	@Test
	function testDrawDebugChanged()
	{
		testBoolSignal(function() return FlxG.debugger.drawDebug, function(b) FlxG.debugger.drawDebug = b, FlxG.debugger.drawDebugChanged);
	}

	@Test
	function testVisibilityChanged()
	{
		// debugger is open because of LogStyle.WARNING / ERROR, reset to default
		FlxG.debugger.visible = false;

		testBoolSignal(function() return FlxG.debugger.visible, function(b) FlxG.debugger.visible = b, FlxG.debugger.visibilityChanged);
	}

	function testBoolSignal(getValue:Void->Bool, setValue:Bool->Void, signal:FlxSignal)
	{
		Assert.isFalse(getValue());

		var called = false;
		var valueInCallback:Null<Bool> = null;
		var callback = function()
		{
			called = true;
			valueInCallback = getValue();
		}

		signal.add(callback);

		// no change, no signal should dispatch
		setValue(false);
		Assert.isFalse(called);

		// change, value should be changed at time of dispatch
		setValue(true);
		Assert.isTrue(called);
		Assert.isTrue(valueInCallback);

		signal.remove(callback);
	}
}
