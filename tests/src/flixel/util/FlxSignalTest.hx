package flixel.util;

import flixel.FlxState;
import flixel.util.signals.FlxSignal;
import massive.munit.Assert;

class FlxSignalTest extends FlxTest
{
	var signal0:FlxSignal0;
	var signal1:FlxSignal1<Int>;
	var signal2:FlxSignal2<Int, Int>;
	var signal3:FlxSignal3<Int, Int, Int>;
	var signal4:FlxSignal4<Int, Int, Int, Int>;
	
	var flag:Bool = false;
	var counter:Int = 0;
	
	function callbackEmpty1() {}
	function callbackEmpty2() {}
	function callbackEmpty3() {}
	function callbackSetFlagTrue() { flag = true; }
	function callbackSetFlagFalse() { flag = false; }
	function callbackIncrementCounter() { counter++; }
	
	function addAllEmptyCallbacks():Void 
	{
		signal0.add(callbackEmpty1);
		signal0.add(callbackEmpty2);
		signal0.add(callbackEmpty3);
	}
	
	@Before
	function before():Void
	{
		signal0 = new FlxSignal0();
		signal1 = new FlxSignal1<Int>();
		signal2 = new FlxSignal2<Int, Int>();
		signal3 = new FlxSignal3<Int, Int, Int>();
		signal4 = new FlxSignal4<Int, Int, Int, Int>();
		
		flag = false;
		counter = 0;
	}
	
	@Test
	function testAddNull():Void
	{
		Assert.isNull(signal0.add(null));
		signal0.dispatch(); // crash if null could be added
	}
	
	@Test
	function testDispatchOneCallback():Void
	{
		signal0.add(callbackSetFlagTrue);
		
		signal0.dispatch();
		Assert.isTrue(flag);
	}
	
	@Test
	function testDispatchMultipleCallbacks():Void
	{
		var flag1:Bool = false;
		var flag2:Bool = false;
		var flag3:Bool = false;
		
		signal0.add(function() { flag1 = true; } );
		signal0.add(function() { flag2 = true; } );
		signal0.add(function() { flag3 = true; } );
		
		signal0.dispatch();
		
		Assert.isTrue(flag1);
		Assert.isTrue(flag2);
		Assert.isTrue(flag3);
	}
	
	@Test
	function testHasCallback():Void
	{
		signal0.add(callbackEmpty1);
		Assert.isTrue(signal0.has(callbackEmpty1));
	}
	
	@Test
	function testHasNull():Void
	{
		signal0.add(null);
		Assert.isFalse(signal0.has(null));
	}
	
	@Test
	function testRemoveOneCallback():Void
	{
		signal0.add(callbackEmpty1);
		signal0.remove(callbackEmpty1);
		Assert.isFalse(signal0.has(callbackEmpty1));
	}
	
	@Test
	function testRemoveMultipleCallbacks():Void
	{
		addAllEmptyCallbacks();
		signal0.remove(callbackEmpty2);
		
		Assert.isTrue(signal0.has(callbackEmpty1));
		Assert.isFalse(signal0.has(callbackEmpty2));
		Assert.isTrue(signal0.has(callbackEmpty3));
	}
	
	@Test
	function testRemoveNotAddedCallback():Void
	{
		addAllEmptyCallbacks();
		signal0.remove(callbackSetFlagTrue);
		
		Assert.isTrue(signal0.has(callbackEmpty1));
		Assert.isTrue(signal0.has(callbackEmpty2));
		Assert.isTrue(signal0.has(callbackEmpty3));
		Assert.isFalse(signal0.has(callbackSetFlagTrue));
	}
	
	@Test
	function testRemoveAll():Void
	{
		addAllEmptyCallbacks();
		signal0.removeAll();
		
		Assert.isFalse(signal0.has(callbackEmpty1));
		Assert.isFalse(signal0.has(callbackEmpty2));
		Assert.isFalse(signal0.has(callbackEmpty3));
	}

	@Test
	function testNoDispatch():Void
	{
		signal0.add(callbackSetFlagTrue);
		Assert.isFalse(flag);
	}	
		
	@Test
	function testDispatchOnceTrue():Void
	{
		signal0.add(callbackIncrementCounter, true);

		signal0.dispatch();
		signal0.dispatch();
		signal0.dispatch();
		
		Assert.areEqual(1, counter);
	}
	
	@Test
	function testDispatchOnceFalse():Void
	{
		signal0.add(callbackIncrementCounter, false);

		signal0.dispatch();
		signal0.dispatch();
		signal0.dispatch();
		
		Assert.areEqual(3, counter);
	}
	
	@Test
	function testActiveFalse():Void
	{
		signal0.add(callbackSetFlagTrue);
		signal0.active = false;
		signal0.dispatch();
		
		Assert.isFalse(flag);
	}
}

class DispatchState extends FlxState 
{
	private var _signal0:FlxSignal0;
	
	public function new(signal0:FlxSignal0)
	{
		_signal0 = signal0;
		super();
	}
	
	override public function create():Void
	{
		_signal0.dispatch();
	}
}