package flixel.system;

import flixel.system.FlxBuffer;
import massive.munit.Assert;

class FlxBufferTest
{
	@Test
	function testVector()
	{
		final bufferStr = new FlxBuffer<{ x:String, y:String }>();
		for (i in 0...100)
			bufferStr.push({ x: Std.string(i % 10), y: Std.string(Std.int(i / 10)) });
		
		bufferStr.shift();
		bufferStr.pop();
		
		// make sure it compiles
		for (i=>item in bufferStr)
		{
			item;
			i;
		}
		
		final bufferTD = new FlxBuffer<{ x:Float, y:Float }>();
		final bufferTD2 = new FlxBuffer<XY>();
		Assert.areEqual(1, bufferTD.push(5, 10));
		Assert.areEqual(5, bufferTD.getX(0));
		Assert.areEqual(10, bufferTD.getY(0));
		
		final buffer = new FlxBuffer<XYAbs>();
		for (i in 0...100)
			buffer.push({ x: i % 10, y: Std.int(i / 10) });
		
		Assert.areEqual(5, buffer.getX(15));
		Assert.areEqual(1, buffer.getY(15));
		Assert.areEqual(6, buffer.getSum(15));
		
		buffer.set(0, { x: 1000, y: 1000 });
		FlxAssert.allEqual(2000.0, [buffer.getSum(0), buffer.get(0).sum]);
		buffer.insert(1, { x: 500, y: 500 });
		FlxAssert.allEqual(1000.0, [buffer.getSum(1), buffer.get(1).sum]);
		
		// make sure it compiles
		for (i=>item in buffer)
		{
			item;
			i;
		}
		
		Assert.areEqual(2000, buffer.shift().sum);
		Assert.areEqual(18, buffer.pop().sum);
	}
	
	@Test
	function testArray()
	{
		final bufferStr = new FlxBufferArray<{ x:String, y:String }>();
		for (i in 0...100)
			bufferStr.push({ x: Std.string(i % 10), y: Std.string(Std.int(i / 10)) });
		
		bufferStr.shift();
		bufferStr.pop();
		
		// make sure it compiles
		for (i=>item in bufferStr)
		{
			item;
			i;
		}
		
		final bufferTD = new FlxBufferArray<{ x:Float, y:Float }>();
		final bufferTD2 = new FlxBufferArray<XY>();
		Assert.areEqual(1, bufferTD.push(5, 10));
		Assert.areEqual(5, bufferTD.getX(0));
		Assert.areEqual(10, bufferTD.getY(0));
		
		final buffer = new FlxBufferArray<XYAbs>();
		for (i in 0...100)
			buffer.push({ x: i % 10, y: Std.int(i / 10) });
		
		Assert.areEqual(5, buffer.getX(15));
		Assert.areEqual(1, buffer.getY(15));
		Assert.areEqual(6, buffer.getSum(15));
		
		buffer.set(0, { x: 1000, y: 1000 });
		FlxAssert.allEqual(2000.0, [buffer.getSum(0), buffer.get(0).sum]);
		buffer.insert(1, { x: 500, y: 500 });
		FlxAssert.allEqual(1000.0, [buffer.getSum(1), buffer.get(1).sum]);
		
		// make sure it compiles
		for (i=>item in buffer)
		{
			item;
			i;
		}
		
		Assert.areEqual(2000, buffer.shift().sum);
		Assert.areEqual(18, buffer.pop().sum);
	}
	
	@Test
	function testArgOrder()
	{
		final bVector = new FlxBuffer<{ d:Int, c:Int, b:Int, a:Int }>();
		final bArray  = new FlxBufferArray<{ d:Int, c:Int, b:Int, a:Int }>();
		
		bVector.push(0, 10, 20, 30);
		bArray.push(0, 10, 20, 30);
		FlxAssert.allEqual( 0.0, [ bVector.getD(0), bVector.get(0).d, bArray.getD(0), bArray.get(0).d]);
		FlxAssert.allEqual(10.0, [ bVector.getC(0), bVector.get(0).c, bArray.getC(0), bArray.get(0).c]);
		FlxAssert.allEqual(20.0, [ bVector.getB(0), bVector.get(0).b, bArray.getB(0), bArray.get(0).b]);
		FlxAssert.allEqual(30.0, [ bVector.getA(0), bVector.get(0).a, bArray.getA(0), bArray.get(0).a]);
		
		bVector.push({ d:5, c:15, b:25, a:35 });
		bArray.push({ d:5, c:15, b:25, a:35 });
		FlxAssert.allEqual( 5.0, [ bVector.getD(1), bVector.get(1).d, bArray.getD(1), bArray.get(1).d]);
		FlxAssert.allEqual(15.0, [ bVector.getC(1), bVector.get(1).c, bArray.getC(1), bArray.get(1).c]);
		FlxAssert.allEqual(25.0, [ bVector.getB(1), bVector.get(1).b, bArray.getB(1), bArray.get(1).b]);
		FlxAssert.allEqual(35.0, [ bVector.getA(1), bVector.get(1).a, bArray.getA(1), bArray.get(1).a]);
		
		bVector.insert(1, { d:7, c:17, b:27, a:37 });
		bArray.insert(1, { d:7, c:17, b:27, a:37 });
		FlxAssert.allEqual( 7.0, [ bVector.getD(1), bVector.get(1).d, bArray.getD(1), bArray.get(1).d]);
		FlxAssert.allEqual(17.0, [ bVector.getC(1), bVector.get(1).c, bArray.getC(1), bArray.get(1).c]);
		FlxAssert.allEqual(27.0, [ bVector.getB(1), bVector.get(1).b, bArray.getB(1), bArray.get(1).b]);
		FlxAssert.allEqual(37.0, [ bVector.getA(1), bVector.get(1).a, bArray.getA(1), bArray.get(1).a]);
		
		bVector.set(2, { d:8, c:18, b:28, a:38 });
		bArray.set(2, { d:8, c:18, b:28, a:38 });
		FlxAssert.allEqual( 8.0, [ bVector.getD(2), bVector.get(2).d, bArray.getD(2), bArray.get(2).d]);
		FlxAssert.allEqual(18.0, [ bVector.getC(2), bVector.get(2).c, bArray.getC(2), bArray.get(2).c]);
		FlxAssert.allEqual(28.0, [ bVector.getB(2), bVector.get(2).b, bArray.getB(2), bArray.get(2).b]);
		FlxAssert.allEqual(38.0, [ bVector.getA(2), bVector.get(2).a, bArray.getA(2), bArray.get(2).a]);
	}
	
	@Test
	function testSlice()
	{
		final bVector = new FlxBuffer<XYAbs>();
		final bArray = new FlxBufferArray<XYAbs>();
		final array = new Array<XYAbs>();
		for (i in 0...100)
		{
			final item:XYAbs = { x: i % 10, y: Std.int(i / 10) };
			bVector.push(item);
			bArray.push(item);
			array.push(item);
		}
		
		FlxAssert.allEqual(100,
			[ bVector.length, bVector.slice(0).length
			,  bArray.length,  bArray.slice(0).length
			,   array.length,   array.slice(0).length
			]);
		FlxAssert.allEqual(900.0,
			[ getTotalSum(bVector), getTotalSum(bVector.slice(0))
			, getTotalSum( bArray), getTotalSum( bArray.slice(0))
			, getTotalSum(  array), getTotalSum(  array.slice(0))
			]);
		FlxAssert.allEqual(575.0,
			[ getTotalSum(bVector.slice(50))
			, getTotalSum( bArray.slice(50))
			, getTotalSum(  array.slice(50))
			]);
		FlxAssert.allEqual(450.0,
			[ getTotalSum(bVector.slice(25, 75)), getTotalSum(bVector.slice(25, -25))
			, getTotalSum( bArray.slice(25, 75)), getTotalSum( bArray.slice(25, -25))
			, getTotalSum(  array.slice(25, 75)), getTotalSum(  array.slice(25, -25))
			]);
	}
	
	public overload extern inline function getTotalSum(buffer:FlxBuffer<XYAbs>)
	{
		return getTotalSum((cast buffer.iterator():Iterator<XYAbs>));
	}
	
	public overload extern inline function getTotalSum(buffer:FlxBufferArray<XYAbs>)
	{
		return getTotalSum((cast buffer.iterator():Iterator<XYAbs>));
	}
	
	public overload extern inline function getTotalSum(array:Array<XYAbs>)
	{
		return getTotalSum(array.iterator());
	}
	
	public overload extern inline function getTotalSum(iter:Iterator<XYAbs>)
	{
		// return Lambda.fold(buffer, (item, total)->total + item.sum, 0);
		var total = 0.0;
		for (item in iter)
			total += item.sum;
		return total;
	}
}

typedef XY = { x:Float, y:Float }
@:forward
abstract XYAbs(XY) from XY
{
	public var sum(get, never):Float;
	inline function get_sum() { return this.x + this.y; }
	
	public function toString() { return '( ${this.x} | ${this.y} )'; }
}