package flixel.graphics.frames;

import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;

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
	function testGetPixelAt()
	{
		final p = 3;
		final bitmap = new BitmapData(p * 2, p * 2, false);
		bitmap.fillRect(new Rectangle(0, 0, p, p), FlxColor.RED);
		bitmap.fillRect(new Rectangle(p, 0, p, p), FlxColor.GREEN);
		bitmap.fillRect(new Rectangle(0, p, p, p), FlxColor.BLUE);
		bitmap.fillRect(new Rectangle(p, p, p, p), FlxColor.WHITE);
		
		final frame = new FlxSprite(0, 0, bitmap).frame;
		
		function getColorName(color)
		{
			return switch color
			{
				case FlxColor.RED: "RED";
				case FlxColor.GREEN: "GREEN";
				case FlxColor.BLUE: "BLUE";
				case FlxColor.WHITE: "WHITE";
				default: color.toHexString();
			}
		}
		
		function assertPixelAt(x:Int, y:Int, expected:FlxColor, ?pos:PosInfos)
		{
			final actual = frame.getPixelAt((x + 0.5) * p, (y + 0.5) * p);
			final msg = 'Pixel($x,$y) was [${getColorName(actual)}], expected [${getColorName(expected)}]';
			Assert.areEqual(expected, actual, msg, pos);
			
			// test overloads
			final actual = frame.getPixelAt(FlxPoint.weak((x + 0.5) * p, (y + 0.5) * p));
			final msg = 'Pixel(P($x,$y)) was [${getColorName(actual)}], expected [${getColorName(expected)}]';
			Assert.areEqual(expected, actual, msg, pos);
		}
		
		
		assertPixelAt(0, 0, FlxColor.RED);
		assertPixelAt(1, 0, FlxColor.GREEN);
		assertPixelAt(0, 1, FlxColor.BLUE);
		assertPixelAt(1, 1, FlxColor.WHITE);
		
		// flipXY shouldn't affect this
		frame.flipX = true;
		assertPixelAt(0, 0, FlxColor.RED);
		assertPixelAt(1, 0, FlxColor.GREEN);
		assertPixelAt(0, 1, FlxColor.BLUE);
		assertPixelAt(1, 1, FlxColor.WHITE);
		
		frame.angle = ANGLE_90;
		assertPixelAt(0, 0, FlxColor.BLUE);
		assertPixelAt(1, 0, FlxColor.RED);
		assertPixelAt(0, 1, FlxColor.WHITE);
		assertPixelAt(1, 1, FlxColor.GREEN);
		
		frame.angle = ANGLE_NEG_90;
		assertPixelAt(0, 0, FlxColor.GREEN);
		assertPixelAt(1, 0, FlxColor.WHITE);
		assertPixelAt(0, 1, FlxColor.RED);
		assertPixelAt(1, 1, FlxColor.BLUE);
		
		frame.angle = ANGLE_270;
		assertPixelAt(0, 0, FlxColor.GREEN);
		assertPixelAt(1, 0, FlxColor.WHITE);
		assertPixelAt(0, 1, FlxColor.RED);
		assertPixelAt(1, 1, FlxColor.BLUE);
	}
	
	@Test
	function testToSourcePos()
	{
		final frame = createFrames("toSourcePos", 10, 10, 4, 4, 2).pop();
		
		function assertSourcePosOf(x:Float, y:Float, expectedX:Float, expectedY:Float, margin = 0.001, ?pos:PosInfos)
		{
			final actual = frame.toSourcePosition(FlxPoint.weak(x, y));
			FlxAssert.areNear(expectedX, actual.x, margin, 'X Value [${actual.x}] is not within [$margin] of [$expectedX]', pos);
			FlxAssert.areNear(expectedY, actual.y, margin, 'Y Value [${actual.y}] is not within [$margin] of [$expectedY]', pos);
		}
		
		assertSourcePosOf(0, 0, 32, 32);
		assertSourcePosOf(3, 0, 35, 32);
		assertSourcePosOf(0, 3, 32, 35);
		assertSourcePosOf(3, 3, 35, 35);
		
		// flipXY shouldn't affect this
		frame.flipX = true;
		assertSourcePosOf(0, 0, 32, 32);
		assertSourcePosOf(3, 0, 35, 32);
		assertSourcePosOf(0, 3, 32, 35);
		assertSourcePosOf(3, 3, 35, 35);
		frame.flipX = false;
		
		frame.angle = ANGLE_90;
		assertSourcePosOf(0, 0, 32, 38);
		assertSourcePosOf(3, 0, 32, 35);
		assertSourcePosOf(0, 3, 35, 38);
		assertSourcePosOf(3, 3, 35, 35);
		
		frame.angle = ANGLE_NEG_90;
		assertSourcePosOf(0, 0, 38, 32);
		assertSourcePosOf(3, 0, 38, 35);
		assertSourcePosOf(0, 3, 35, 32);
		assertSourcePosOf(3, 3, 35, 35);
		
		frame.angle = ANGLE_270;
		assertSourcePosOf(0, 0, 38, 32);
		assertSourcePosOf(3, 0, 38, 35);
		assertSourcePosOf(0, 3, 35, 32);
		assertSourcePosOf(3, 3, 35, 35);
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
