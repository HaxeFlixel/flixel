package flixel.system.debug.log;

import flixel.FlxG;
import flixel.system.debug.log.LogStyle;
import haxe.PosInfos;
import massive.munit.Assert;

class FlxLogStyleTest
{
	var style:LogStyle;
	
	@Before
	function before():Void
	{
		style = new LogStyle();
	}
	
	@Test
	function testThrowException()
	{
		style.throwException = true;
		try
		{
			log();
			Assert.fail("Expected log() to throw an exception");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		style.throwException = false;
		try
		{
			log(style);
			Assert.assertionCount++;
		}
		catch(e)
		{
			Assert.fail("Unexpected exception thrown by log()");
		}
	}
	
	@Test
	function testOnLog()
	{
		var called = false;
		style.prefix = "Specific Prefix";
		style.onLog.addOnce(function (msg, ?_)
		{
			Assert.areEqual("Specific Message", msg);
			called = true;
		});
		
		log("Specific Message");
		Assert.isTrue(called, "Expected style.onLog to be dispatched");
	}
	
	@Test
	#if FLX_NO_DEBUG @Ignore("FLX_NO_DEBUG") #end
	@:haxe.warning("-WDeprecated")
	function testCallbackFunction()
	{
		var called = false;
		style.callbackFunction = ()->called = true;
		
		log();
		Assert.isTrue(called, "Expected callbackFunction to be caled, it was not");
	}
	
	@Test
	#if FLX_NO_DEBUG @Ignore("FLX_NO_DEBUG") #end
	function testOpenConsole()
	{
		FlxG.debugger.visible = false;
		
		style.openConsole = true;
		log();
		Assert.isTrue(FlxG.debugger.visible, "Expected debugger to be visible");
	}
	
	inline function log(msg:Any = "test", ?pos:PosInfos)
	{
		FlxG.log.advanced(msg, style, pos);
	}
}
