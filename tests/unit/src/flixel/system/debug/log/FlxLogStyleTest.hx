package flixel.system.debug.log;

import flixel.FlxG;
import flixel.system.debug.log.FlxLogStyle;
import haxe.PosInfos;
import massive.munit.Assert;

class FlxLogStyleTest
{
	var style:FlxLogStyle;
	
	@Before
	function before():Void
	{
		style = new FlxLogStyle();
	}
	
	@Test
	function testThrowException()
	{
		style.throwException = true;
		try
		{
			log('testThrowException-1');
			Assert.fail("Expected log() to throw an exception");
		}
		catch(e)
		{
			Assert.assertionCount++;
		}
		
		style.throwException = false;
		try
		{
			log('testThrowException-2');
			Assert.assertionCount++;
		}
		catch(e)
		{
			Assert.fail('Unexpected exception thrown by log() - "${e.message}"');
		}
	}
	
	@Test
	function testOnLog()
	{
		var called = false;
		style.prefix = "some-prefix";
		style.onLog.addOnce(function (msg, ?_)
		{
			Assert.areEqual("testOnLog", msg);
			called = true;
		});
		
		log("testOnLog");
		Assert.isTrue(called, "Expected style.onLog to be dispatched");
	}
	
	@Test
	#if FLX_NO_DEBUG @Ignore("FLX_NO_DEBUG") #end
	@:haxe.warning("-WDeprecated")
	function testCallbackFunction()
	{
		var called = false;
		style.callbackFunction = ()->called = true;
		
		log('testCallbackFunction');
		Assert.isTrue(called, "Expected callbackFunction to be caled, it was not");
	}
	
	@Test
	#if FLX_NO_DEBUG @Ignore("FLX_NO_DEBUG") #end
	function testOpenConsole()
	{
		FlxG.debugger.visible = false;
		
		style.openConsole = true;
		log("testOpenConsole");
		Assert.isTrue(FlxG.debugger.visible, "Expected debugger to be visible");
	}
	
	inline function log(msg:Any, fireOnce = false, ?pos:PosInfos)
	{
		FlxG.log.advanced(msg, style, fireOnce, pos);
	}
}
