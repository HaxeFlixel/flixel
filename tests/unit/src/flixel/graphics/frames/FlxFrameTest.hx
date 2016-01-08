package flixel.graphics.frames;

import flixel.graphics.frames.FlxFrame;
import massive.munit.Assert;

class FlxFrameTest extends FlxTest
{
	@Test
	function testSortByName()
	{
		var indices = [3, 5, 8, 1, 6];
		var frames:Array<FlxFrame> = [];
		var prefix = "tiles-";
		var postfix = ".png";
		
		for (index in indices)
		{
			var frame = new FlxFrame(null);
			frame.name = prefix + "00" + index + postfix;
			frames.push(frame);
		}
		
		frames.sort(FlxFrame.sortByName.bind(_, _, prefix.length, postfix.length));
		
		var resultingIndices:Array<Null<Int>> = [];
		for (frame in frames)
		{
			var withoutPostfix = frame.name.substring(0, frame.name.length - postfix.length);
			var index = Std.parseInt(withoutPostfix.charAt(withoutPostfix.length - 1));
			resultingIndices.push(index);
		}
		FlxAssert.arraysEqual([1, 3, 5, 6, 8], resultingIndices);
	}
}