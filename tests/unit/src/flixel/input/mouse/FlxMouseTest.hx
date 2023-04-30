package flixel.input.mouse;

#if FLX_NATIVE_CURSOR
import flash.ui.Mouse;
import flash.ui.MouseCursor;
#end
import massive.munit.Assert;

class FlxMouseTest
{
	#if FLX_NATIVE_CURSOR
	@Test
	function testDisableSystemCursorAfterMultipleEnables()
	{
		Assert.areNotEqual(MouseCursor.AUTO, Mouse.cursor);

		FlxG.mouse.useSystemCursor = true;
		Assert.areEqual(MouseCursor.AUTO, Mouse.cursor);

		FlxG.mouse.useSystemCursor = true;
		Assert.areEqual(MouseCursor.AUTO, Mouse.cursor);

		FlxG.mouse.useSystemCursor = false;
		Assert.areNotEqual(MouseCursor.AUTO, Mouse.cursor);
	}
	#end
}
