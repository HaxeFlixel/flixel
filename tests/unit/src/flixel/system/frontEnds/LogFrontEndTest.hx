package flixel.system.frontEnds;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;
import massive.munit.Assert;

class LogFrontEndTest
{
	@Test
	// #if FLX_NO_DEBUG @Ignore("FLX_NO_DEBUG") #end
	@:haxe.warning("-WDeprecated")
	function testEquality()
	{
		final oldLog = FlxG.log.styles.normal;
		Assert.areEqual(FlxG.log.styles.normal, LogStyle.NORMAL);
		FlxG.log.styles.normal = new LogStyle();
		Assert.areEqual(FlxG.log.styles.normal, LogStyle.NORMAL);
		LogStyle.NORMAL = oldLog;
		Assert.areEqual(FlxG.log.styles.normal, LogStyle.NORMAL);
	}
	
	@Test
	function testThrowDefault()
	{
		#if FLX_THROW_ERRORS
		Assert.isTrue(FlxG.log.styles.error.throwException);
		#else
		Assert.isFalse(FlxG.log.styles.error.throwException);
		#end
	}
	
	@Test
	function testRedirectTraces()
	{
		final oldValue = FlxG.log.redirectTraces;
		
		FlxG.log.redirectTraces = true;
		var called = false;
		FlxG.log.styles.normal.onLog.addOnce((_,?_)->called = true);
		trace("test");
		Assert.isTrue(called, "Expected trace to call log.normal, when it did not");
		
		// reset value
		FlxG.log.redirectTraces = oldValue;
	}
}
