package flixel.graphics.frames;

import massive.munit.Assert;

@:access(flixel.graphics.frames.FlxFrame.new)
class FlxFrameTest extends FlxTest
{
	@Test
	function testSort()
	{
		var indices = [3, 5, 8, 1, 6];
		var prefix = "tiles-";
		var postfix = ".png";

		var frames = [for (i in indices) createFrame(prefix + "00" + i + postfix)];
		FlxFrame.sort(frames, prefix.length, postfix.length);

		var resultingIndices:Array<Null<Int>> = [];
		for (frame in frames)
		{
			var withoutPostfix = frame.name.substring(0, frame.name.length - postfix.length);
			var index = Std.parseInt(withoutPostfix.charAt(withoutPostfix.length - 1));
			resultingIndices.push(index);
		}
		FlxAssert.arraysEqual([1, 3, 5, 6, 8], resultingIndices);
	}

	@Test // #1926
	function testSortNoPrefix()
	{
		var length = 5;
		var frames:Array<FlxFrame> = [for (i in 0...length) createFrame("split/" + i)];
		FlxFrame.sort(frames, 0, 0);

		for (i in 0...length)
			Assert.areEqual("split/" + i, frames[i].name);
	}

	function createFrame(name:String):FlxFrame
	{
		var frame = new FlxFrame(null);
		frame.name = name;
		return frame;
	}
}
