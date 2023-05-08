package flixel.system.frontEnds;

import haxe.Exception;
import haxe.PosInfos;
import flixel.FlxG;
import flixel.math.FlxPoint;
import flixel.system.debug.console.ConsoleUtil;
import massive.munit.Assert;

class ConsoleFrontEndTest
{
	@Test
	#if !debug @Ignore #end
	function testEnum()
	{
		FlxG.console.registerEnum(TestEnum);
		assertCommandSucceedsWith("TestEnum.A", TestEnum.A);
		FlxG.console.removeEnum(TestEnum);
		assertCommandFails("TestEnum.A");
	}
	
	@Test
	#if !debug @Ignore #end
	function testClass()
	{
		FlxG.console.registerClass(TestClass);
		assertCommandSucceedsWith("TestClass.func()", "success");
		FlxG.console.removeClass(TestClass);
		assertCommandFails("TestClass.func");
	}
	
	@Test
	#if !debug @Ignore #end
	function testFunction()
	{
		var func = ()->"success";
		FlxG.console.registerFunction("func", func);
		assertCommandSucceedsWith("func()", "success");
		FlxG.console.removeByAlias("func");
		assertCommandFails("func()");
		
		//test again with removeFunction
		FlxG.console.registerFunction("func", func);
		assertCommandSucceedsWith("func", "success");// omit (), should still work
		FlxG.console.removeFunction(func);
		assertCommandFails("func()");
	}
	
	@Test
	#if !debug @Ignore #end
	function testObject()
	{
		final p = new FlxPoint();
		FlxG.console.registerObject("p", p);
		assertCommandSucceedsWith("p.set(2, 4)", p);
		FlxG.console.removeByAlias("p");
		assertCommandFails("p.set(5, 10)");
		
		//test again with removeFunction
		FlxG.console.registerObject("p", p);
		assertCommandSucceedsWith("p.set(0, 0)", p);
		FlxG.console.removeObject("p");
		assertCommandFails("p.set(50, 100)");
	}
	
	static function tryRunCommand(cmd:String):CommandOutcome
	{
		try
		{
			return Success(ConsoleUtil.runCommand(cmd));
		}
		catch (e)
		{
			return Fail(e);
		}
	}
	
	inline static function commandSucceeds(cmd:String)
	{
		return tryRunCommand(cmd).match(Success(_));
	}
	
	inline static function commandSucceedsWith(cmd:String, expected:Any)
	{
		final result = tryRunCommand(cmd);
		switch (result)
		{
			case Success(actual): return expected == actual;
			case Fail(error): return false;
		}
	}
	
	inline static function commandFails(cmd:String)
	{
		return tryRunCommand(cmd).match(Fail(_));
	}
	
	inline static function assertCommandSucceeds(cmd:String, ?pos:PosInfos)
	{
		Assert.isTrue(commandSucceeds(cmd), pos);
	}
	
	inline static function assertCommandSucceedsWith(cmd:String, expected:Any, ?pos:PosInfos)
	{
		final result = tryRunCommand(cmd);
		switch (result)
		{
			case Success(actual): Assert.areEqual(expected, actual, pos);
			case Fail(error): Assert.fail('Expected $expected, got exception: ${error.message}', pos);
		}
	}
	
	inline static function assertCommandFails(cmd:String, ?pos:PosInfos)
	{
		return Assert.isFalse(commandSucceeds(cmd), pos);
	}
}

enum CommandOutcome
{
	Success(result:Any);
	Fail(error:Exception);
}

enum TestEnum { A; B; C; }

class TestClass
{
	static public function func() { return "success"; }
}