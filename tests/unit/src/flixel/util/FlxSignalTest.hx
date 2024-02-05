package flixel.util;

import flixel.util.FlxSignal.FlxTypedSignal;
import massive.munit.Assert;

class FlxSignalTest extends FlxTest
{
	var signal0:FlxSignal;
	var signal1:FlxTypedSignal<Int->Void>;
	var signal2:FlxTypedSignal<Int->Int->Void>;
	var signal3:FlxTypedSignal<Int->Int->Int->Void>;
	var signal4:FlxTypedSignal<Int->Int->Int->Int->Void>;

	var flag:Bool = false;
	var counter:Int = 0;

	function callbackEmpty1() {}

	function callbackEmpty2() {}

	function callbackEmpty3() {}

	function callbackSetFlagTrue()
		flag = true;

	function callbackSetFlagFalse()
		flag = false;

	function callbackIncrementCounter()
		counter++;

	function callbackIncrementCounter_Int(v:Int):Void
		counter++;

	function addAllEmptyCallbacks():Void
	{
		signal0.add(callbackEmpty1);
		signal0.add(callbackEmpty2);
		signal0.add(callbackEmpty3);
	}

	@Before
	function before():Void
	{
		signal0 = new FlxSignal();
		signal1 = new FlxTypedSignal();
		signal2 = new FlxTypedSignal();
		signal3 = new FlxTypedSignal();
		signal4 = new FlxTypedSignal();

		flag = false;
		counter = 0;

		destroyable = signal0;
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

		signal0.add(function() flag1 = true);
		signal0.add(function() flag2 = true);
		signal0.add(function() flag3 = true);

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
		signal0.addOnce(callbackIncrementCounter);

		signal0.dispatch();
		signal0.dispatch();
		signal0.dispatch();

		Assert.areEqual(1, counter);
	}

	@Test
	function testDispatchOnceFalse():Void
	{
		signal0.add(callbackIncrementCounter);

		signal0.dispatch();
		signal0.dispatch();
		signal0.dispatch();

		Assert.areEqual(3, counter);
	}

	@Test
	function testDispatchOnce_signal1():Void
	{
		// see https://github.com/HaxeFoundation/hashlink/issues/578
		
		signal1.addOnce(callbackIncrementCounter_Int);
		
		signal1.dispatch(42);
		signal1.dispatch(42);
		signal1.dispatch(42);
		
		Assert.areEqual(1, counter);
	}

	@Test
	function testAddNull():Void
	{
		signal0.add(null);
		signal0.dispatch(); // crash if null could be added
	}

	@Test
	function testHasNull():Void
	{
		signal0.add(null);
		Assert.isFalse(signal0.has(null));
	}

	@Test // #1420
	function testRemoveCurrentDuringDispatch()
	{
		signal0.addOnce(callbackEmpty1);
		signal0.add(callbackSetFlagTrue);
		signal0.dispatch();

		Assert.isTrue(flag);
		Assert.isTrue(signal0.has(callbackSetFlagTrue));
		Assert.isFalse(signal0.has(callbackEmpty1));
	}

	@Test // #1420
	function testRemovePreviousDuringDispatch()
	{
		var timesCalled = 0;
		var removePrevious = function()
		{
			timesCalled++;
			signal0.remove(callbackSetFlagTrue);
		};

		signal0.add(callbackSetFlagTrue);
		signal0.add(removePrevious);
		signal0.dispatch();

		Assert.areEqual(1, timesCalled);
		Assert.isTrue(signal0.has(removePrevious));
		Assert.isFalse(signal0.has(callbackSetFlagTrue));
	}
}
