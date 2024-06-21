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
		
		// make sure it compiles
		for (i=>item in buffer)
		{
			item;
			i;
		}
		
		Assert.areEqual(0, buffer.shift().sum);
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
		
		// make sure it compiles
		for (i=>item in buffer)
		{
			item;
			i;
		}
		
		Assert.areEqual(0, buffer.shift().sum);
		Assert.areEqual(18, buffer.pop().sum);
	}
	
	@Test
	function testArgOrderVector()
	{
		final buffer = new FlxBuffer<{ d:Int, c:Int, b:Int, a:Int }>();
		buffer.push(0, 10, 20, 30);
		Assert.areEqual( 0, buffer.getD(0));
		Assert.areEqual(10, buffer.getC(0));
		Assert.areEqual(20, buffer.getB(0));
		Assert.areEqual(30, buffer.getA(0));
		
		buffer.push({ d:5, c:15, b:25, a:35 });
		Assert.areEqual( 5, buffer.getD(1));
		Assert.areEqual(15, buffer.getC(1));
		Assert.areEqual(25, buffer.getB(1));
		Assert.areEqual(35, buffer.getA(1));
		
		buffer.push({ a:6, b:16, c:26, d:36 });
		Assert.areEqual( 6, buffer.getA(2));
		Assert.areEqual(16, buffer.getB(2));
		Assert.areEqual(26, buffer.getC(2));
		Assert.areEqual(36, buffer.getD(2));
		
		final item = buffer.get(2);
		Assert.areEqual( 6, item.a);
		Assert.areEqual(16, item.b);
		Assert.areEqual(26, item.c);
		Assert.areEqual(36, item.d);
	}
	
	@Test
	function testArgOrderArray()
	{
		final buffer = new FlxBufferArray<{ d:Int, c:Int, b:Int, a:Int }>();
		buffer.push(0, 10, 20, 30);
		Assert.areEqual( 0, buffer.getD(0));
		Assert.areEqual(10, buffer.getC(0));
		Assert.areEqual(20, buffer.getB(0));
		Assert.areEqual(30, buffer.getA(0));
		
		buffer.push({ d:5, c:15, b:25, a:35 });
		Assert.areEqual( 5, buffer.getD(1));
		Assert.areEqual(15, buffer.getC(1));
		Assert.areEqual(25, buffer.getB(1));
		Assert.areEqual(35, buffer.getA(1));
		
		buffer.push({ a:6, b:16, c:26, d:36 });
		Assert.areEqual( 6, buffer.getA(2));
		Assert.areEqual(16, buffer.getB(2));
		Assert.areEqual(26, buffer.getC(2));
		Assert.areEqual(36, buffer.getD(2));
		
		final item = buffer.get(2);
		Assert.areEqual( 6, item.a);
		Assert.areEqual(16, item.b);
		Assert.areEqual(26, item.c);
		Assert.areEqual(36, item.d);
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