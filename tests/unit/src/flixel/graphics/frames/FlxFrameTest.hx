package flixel.graphics.frames;

import flixel.FlxSprite;
import flixel.graphics.frames.FlxFrame;
import flixel.math.FlxRect;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;

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

	@Test
	function testOverlaps()
	{
		final frames = createFrames("overlaps", 100, 100, 10, 10, 0);
		final rect = FlxRect.get();
		
		inline function assertOverlaps(x = 0, y = 0, width = 50, height = 50, ?pos:PosInfos)
		{
			for (frame in frames)
				Assert.isTrue(frame.overlaps(rect.set(x, y, width, height)), 
					'expected overlap - rect: $rect frame: { offset: ${frame.offset}, rect: ${frame.frame} }', pos);
		}
		
		inline function assertNotOverlaps(x = 0, y = 0, width = 50, height = 50, ?pos:PosInfos)
		{
			for (frame in frames)
				Assert.isFalse(frame.overlaps(rect.set(x, y, width, height)),
					'expected NO overlap - rect: $rect frame: { offset: ${frame.offset}, rect: ${frame.frame} }', pos);
		}
		
		assertOverlaps(25, 25);
		assertNotOverlaps(-50, -50);
		assertOverlaps(-49, -49);
		assertNotOverlaps(100, 100);
		assertOverlaps(99, 99);
		Assert.isTrue(true);
	}
	
	@Test
	@Ignore// TODO: figure out exactly what offset is for
	function testOverlapsOffset()
	{
		final frames = createFrames("overlaps", 110, 110, 10, 10, 5);
		final rect = FlxRect.get();
		
		inline function assertOverlaps(x = 0, y = 0, width = 50, height = 50, ?pos:PosInfos)
		{
			for (frame in frames)
				Assert.isTrue(frame.overlaps(rect.set(x, y, width, height)), 
					'expected overlap - rect: $rect frame: { offset: ${frame.offset}, rect: ${frame.frame} }', pos);
		}
		
		inline function assertNotOverlaps(x = 0, y = 0, width = 50, height = 50, ?pos:PosInfos)
		{
			for (frame in frames)
				Assert.isFalse(frame.overlaps(rect.set(x, y, width, height)),
					'expected NO overlap - rect: $rect frame: { offset: ${frame.offset}, rect: ${frame.frame} }', pos);
		}
		
		assertOverlaps(25, 25);
		assertNotOverlaps(-50, -50);
		assertOverlaps(-49, -49);
		assertNotOverlaps(100, 100);
		assertOverlaps(99, 99);
		Assert.isTrue(true);
	}
	
	@Test
	function testUVRect()
	{
		final rect = FlxRect.get();
		rect.x = 10;
		rect.y = 20;
		rect.width = 90;
		rect.height = 100;
		
		final uvRect:FlxUVRect = rect;
		FlxAssert.areNear(uvRect.left, rect.x);
		FlxAssert.areNear(uvRect.top, rect.y);
		FlxAssert.areNear(uvRect.right, rect.width);
		FlxAssert.areNear(uvRect.bottom, rect.height);
	}

	function createFrames(name:String, width = 100, height = 100, cols = 10, rows = 10, buffer = 0):Array<FlxFrame>
	{
		final sprite = new FlxSprite(0, 0);
		sprite.loadGraphic(new BitmapData(width * cols, height * rows), true, width, height, true, name);
		if (buffer > 0)
		{
			for (frame in sprite.frames.frames)
			{
				frame.offset.set(buffer, buffer);
				frame.frame.x += buffer;
				frame.frame.y += buffer;
				frame.frame.width -= buffer * 2;
				frame.frame.height -= buffer * 2;
			}
		}
		
		return sprite.frames.frames;
	}
	function createFrame(name:String):FlxFrame
	{
		var frame = new FlxFrame(null);
		frame.name = name;
		return frame;
	}
}
