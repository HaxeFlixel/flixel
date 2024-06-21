package flixel.system;

import massive.munit.Assert;

class FlxBufferTest
{
	@Test
	function testAll()
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
}

typedef XY = { x:Float, y:Float }
@:forward
abstract XYAbs(XY) from XY
{
	public var sum(get, never):Float;
	inline function get_sum() { return this.x + this.y; }
	
	public function toString() { return '( ${this.x} | ${this.y} )'; }
}