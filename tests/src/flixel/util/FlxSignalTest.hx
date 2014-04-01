package flixel.util;

import flixel.FlxState;
import flixel.util.FlxSignal;
import massive.munit.Assert;
import massive.munit.async.AsyncFactory;

class FlxSignalTest extends FlxTest
{
	function func1(_) {}
	function func2(_) {}
	function func3(_) { }
	
	function addAllCallbacks():Void 
	{
		signal.add(func1);
		signal.add(func2);
		signal.add(func3);
	}
	
	var signal:FlxSignal;
	
	@Before
	function before():Void
	{
		signal = FlxSignal.get();
		persistFlag = false;
	}
	
	@Test
	function dispatch():Void
	{
		var flag:Bool = false;
		signal.add(function(_) { flag = true; } );
		
		signal.dispatch();
		Assert.isTrue(flag);
	}
	
	@Test
	function multiDispatch():Void
	{
		var flag1:Bool = false;
		var flag2:Bool = false;
		var flag3:Bool = false;
		
		signal.add(function(_) { flag1 = true; } );
		signal.add(function(_) { flag2 = true; } );
		signal.add(function(_) { flag3 = true; } );
		
		signal.dispatch();
		
		Assert.isTrue(flag1);
		Assert.isTrue(flag2);
		Assert.isTrue(flag3);
	}
	
	@Test
	function has():Void
	{
		signal.add(func1);
		Assert.isTrue(signal.has(func1));
	}
	
	@Test
	function remove():Void
	{
		signal.add(func1);
		signal.remove(func1);
		Assert.isFalse(signal.has(func1));
	}
	
	@Test
	function multiRemove():Void
	{
		addAllCallbacks();
		signal.remove(func2);
		
		Assert.isTrue(signal.has(func1));
		Assert.isFalse(signal.has(func2));
		Assert.isTrue(signal.has(func3));
	}
	
	@Test
	function removeAll():Void
	{
		addAllCallbacks();
		signal.removeAll();
		
		Assert.isFalse(signal.has(func1));
		Assert.isFalse(signal.has(func2));
		Assert.isFalse(signal.has(func3));
	}

	@Test
	function noDispatch():Void
	{
		var flag:Bool = false;
		signal.add(function(_) { flag = true; } );
		
		Assert.isFalse(flag);
	}
	
	var persistFlag:Bool = false;
	
	@AsyncTest
	function persist(factory:AsyncFactory):Void
	{
		var signal = FlxSignal.get(true);
		signal.add(function(_) { persistFlag = true; } );
		FlxG.switchState(new DispatchState(signal));
		
		var resultHandler:Dynamic = factory.createHandler(this, testPersistDispatch);
		TestMain.addAsync(resultHandler, 100);
	}
	
	function testPersistDispatch():Void
	{
		Assert.isTrue(persistFlag); 
	}
	
	@AsyncTest
	function noPersist(factory:AsyncFactory):Void
	{
		var signal = FlxSignal.get(false);
		signal.add(function(_) { persistFlag = true; } );
		FlxG.switchState(new DispatchState(signal));
		
		var resultHandler:Dynamic = factory.createHandler(this, testNoPersistDispatch);
		TestMain.addAsync(resultHandler, 100);
	}
	
	function testNoPersistDispatch():Void
	{
		Assert.isFalse(persistFlag); 
	}
}

class DispatchState extends FlxState 
{
	private var _signal:FlxSignal;
	
	public function new(signal:FlxSignal)
	{
		_signal = signal;
		super();
	}
	
	override public function create():Void
	{
		_signal.dispatch();
	}
}