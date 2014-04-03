package flixel.util;

import flixel.FlxState;
import flixel.util.FlxSignal;
import massive.munit.Assert;

class FlxSignalTest extends FlxTest
{
	var signal:FlxSignal;
	var flag:Bool = false;
	var counter:Int = 0;
	
	function callbackEmpty1(_) {}
	function callbackEmpty2(_) {}
	function callbackEmpty3(_) {}
	function callbackSetFlagTrue(_) { flag = true; }
	function callbackSetFlagFalse(_) { flag = false; }
	function callbackIncrementCounter(_) { counter++; }
	
	function addAllCallbacks():Void 
	{
		signal.add(callbackEmpty1);
		signal.add(callbackEmpty2);
		signal.add(callbackEmpty3);
	}
	
	@Before
	function before():Void
	{
		signal = FlxSignal.get();
		flag = false;
		counter = 0;
	}
	
	@Test
	function testDispatchOneCallback():Void
	{
		signal.add(callbackSetFlagTrue);
		
		signal.dispatch();
		Assert.isTrue(flag);
	}
	
	@Test
	function testDispatchMultipleCallbacks():Void
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
	function testHasCallback():Void
	{
		signal.add(callbackEmpty1);
		Assert.isTrue(signal.has(callbackEmpty1));
	}
	
	@Test
	function testRemoveOneCallback():Void
	{
		signal.add(callbackEmpty1);
		signal.remove(callbackEmpty1);
		Assert.isFalse(signal.has(callbackEmpty1));
	}
	
	@Test
	function testRemoveMultipleCallbacks():Void
	{
		addAllCallbacks();
		signal.remove(callbackEmpty2);
		
		Assert.isTrue(signal.has(callbackEmpty1));
		Assert.isFalse(signal.has(callbackEmpty2));
		Assert.isTrue(signal.has(callbackEmpty3));
	}
	
	@Test
	function testRemoveAll():Void
	{
		addAllCallbacks();
		signal.removeAll();
		
		Assert.isFalse(signal.has(callbackEmpty1));
		Assert.isFalse(signal.has(callbackEmpty2));
		Assert.isFalse(signal.has(callbackEmpty3));
	}

	@Test
	function testNoDispatch():Void
	{
		signal.add(callbackSetFlagTrue);
		Assert.isFalse(flag);
	}
	
	@Test
	function testPersistTrue():Void
	{
		var signal = FlxSignal.get(true);
		signal.add(callbackSetFlagTrue);
		FlxG.switchState(new DispatchState(signal));
		
		delay(function() { Assert.isTrue(flag); });
	}
	
	@Test
	function testPersistFalse():Void
	{
		var signal = FlxSignal.get(false);
		signal.add(function(_) { flag = true; } );
		FlxG.switchState(new DispatchState(signal));
		
		delay(function() { Assert.isFalse(flag); });
	}
	
	@Test
	function testDispatchOnceTrue():Void
	{
		signal.add(callbackIncrementCounter, true);

		signal.dispatch();
		signal.dispatch();
		signal.dispatch();
		
		Assert.areEqual(1, counter);
	}
	
	@Test
	function testDispatchOnceFalse():Void
	{
		signal.add(callbackIncrementCounter, false);

		signal.dispatch();
		signal.dispatch();
		signal.dispatch();
		
		Assert.areEqual(3, counter);
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