package flixel.ui;

import flixel.FlxG;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import massive.munit.Assert;
import openfl.display.BitmapData;

@:access(flixel.ui.FlxBar)
class FlxBarTest extends FlxTest
{
	var bar:FlxBar;

	@Before
	function before()
	{
		bar = new FlxBar(0, 0, LEFT_TO_RIGHT, 16, 8);
		bar.createFilledBar(FlxColor.BLUE, FlxColor.RED);
		bar.value = 50;
		destroyable = bar;
	}

	@After
	function afterBar()
	{
		bar.destroy();
	}

	@Test
	function testFillDirectionUpdatesImmediately()
	{
		bar.fillDirection = RIGHT_TO_LEFT;
		var pixels = paintBar(bar);
		Assert.areEqual(FlxColor.BLUE, pixels.getPixel32(0, 0));
		Assert.areEqual(FlxColor.RED, pixels.getPixel32(15, 0));
		pixels.dispose();
		assertMatchesNewBar(RIGHT_TO_LEFT, 50);
	}

	@Test
	function testBorderedBarAfterChangingDirection()
	{
		bar.destroy();
		bar = new FlxBar(0, 0, RIGHT_TO_LEFT, 640, 25);
		bar.createFilledBar(FlxColor.BLUE, FlxColor.RED, true, FlxColor.WHITE, 5);
		destroyable = bar;
		bar.value = 50;
		bar.fillDirection = LEFT_TO_RIGHT;
		bar.value = 35;
		var expectedBar = new FlxBar(0, 0, LEFT_TO_RIGHT, 640, 25);
		expectedBar.createFilledBar(FlxColor.BLUE, FlxColor.RED, true, FlxColor.WHITE, 5);
		expectedBar.value = 35;
		assertMatchesBar(expectedBar);
	}

	@Test
	function testFillDirectionDoesNotRetainPreviousOffsets()
	{
		var directions = Type.allEnums(FlxBarFillDirection);
		for (style in 0...3)
		{
			bar.destroy();
			bar = createBar(LEFT_TO_RIGHT, 17, 9, style);
			destroyable = bar;
			for (previous in directions)
			{
				for (direction in directions)
				{
					bar.fillDirection = previous;
					bar.value = 50;
					bar.fillDirection = direction;
					assertMatchesNewBar(direction, 50, style);
					for (value in [25, 50, 100, 0])
					{
						bar.value = value;
						assertMatchesNewBar(direction, value, style);
					}
				}
			}
		}
	}

	@Test
	function testFillDirectionPreservesValueAndCallbacks()
	{
		var emptyCalls = 0;
		var filledCalls = 0;
		bar.setCallbacks(function() emptyCalls++, function() filledCalls++);
		for (value in [0, 50, 100])
		{
			bar.fillDirection = LEFT_TO_RIGHT;
			bar.value = value;
			emptyCalls = 0;
			filledCalls = 0;
			bar.fillDirection = BOTTOM_TO_TOP;
			Assert.areEqual(value, bar.value);
			Assert.areEqual(0, emptyCalls);
			Assert.areEqual(0, filledCalls);
		}
	}

	function createBar(direction:FlxBarFillDirection, width:Int, height:Int, style:Int):FlxBar
	{
		var result = new FlxBar(0, 0, direction, width, height);
		if (style == 2)
			result.createGradientBar([FlxColor.BLUE, FlxColor.CYAN], [FlxColor.RED, FlxColor.YELLOW]);
		else
			result.createFilledBar(FlxColor.BLUE, FlxColor.RED, style == 1);
		return result;
	}

	function assertMatchesNewBar(direction:FlxBarFillDirection, value:Float, style:Int = 0)
	{
		var expectedBar = createBar(direction, bar.barWidth, bar.barHeight, style);
		expectedBar.value = value;
		assertMatchesBar(expectedBar);
	}

	function assertMatchesBar(expectedBar:FlxBar)
	{
		var expected = paintBar(expectedBar);
		var actual = paintBar(bar);
		var difference = expected.compare(actual);
		var matches = difference == 0;
		if (Std.isOfType(difference, BitmapData))
			cast(difference, BitmapData).dispose();
		expected.dispose();
		actual.dispose();
		expectedBar.destroy();
		Assert.isTrue(matches, 'Unexpected pixels for ${bar.fillDirection} at ${bar.value}');
	}

	function paintBar(bar:FlxBar):BitmapData
	{
		if (FlxG.renderBlit)
			return bar.pixels.clone();
		var bitmap = bar.frame.paint();
		if (bar.percent > 0)
			bar._frontFrame.paint(bitmap, null, true);
		return bitmap;
	}
}
