package flixel.text;

import flash.errors.Error;
import flixel.text.FlxText;
import massive.munit.Assert;

class FlxTextTest extends FlxTest
{
	var text:FlxText;
	
	@Before
	function before():Void
	{
		text = new FlxText();
	}
	
	@Test
	function testFontDefaultValue():Void
	{
		Assert.areEqual(text.font, "Nokia Cellphone FC Small");
	}
	
	@Test
	function testDestroy():Void
	{
		try
		{
			text.destroy();
			text.destroy();
		}
		catch (e:Error)
		{
			Assert.fail(e.message);
		}
	}
}