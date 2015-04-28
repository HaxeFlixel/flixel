package flixel.ui;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import massive.munit.Assert;

class FlxButtonTest extends FlxTest
{
	var button:FlxButton;

#if !js // assets (including the FlxButton default one) don't work in openfl-html5 tests
	@Before
	function before()
	{
		button = new FlxButton();
		destroyable = button;
	}
	
	@Test
	function testDefaultStatusAnimations()
	{
		assertStatusAnimationsExist();
	}
	
	@Test
	function testLoadGraphicStatusAnimations()
	{
		var graphic = new BitmapData(3, 1);
		button.loadGraphic(graphic, true, 1, 1);
		
		assertStatusAnimationsExist();
	}
	
	@Test
	function testLoadGraphicFromSpriteStatusAnimations()
	{
		var sprite = new FlxSprite();
		var graphic = new BitmapData(3, 1);
		sprite.loadGraphic(graphic, true, 1, 1);
		
		button.loadGraphicFromSprite(sprite);
		
		assertStatusAnimationsExist();
	}
	
	function assertStatusAnimationsExist()
	{
		var normalName:String = button.statusAnimations[FlxButton.NORMAL];
		var highlightName:String = button.statusAnimations[FlxButton.HIGHLIGHT];
		var pressedName:String = button.statusAnimations[FlxButton.PRESSED];
		
		Assert.isNotNull(button.animation.getByName(normalName));
		Assert.isNotNull(button.animation.getByName(highlightName));
		Assert.isNotNull(button.animation.getByName(pressedName));
	}
	
	@Test // #1479
	function testSetTextTwice()
	{
		setAndAssertText("Test");
		setAndAssertText("Test2");
	}
	
	@Test
	function testSetTextNull()
	{
		setAndAssertText(null);
	}
	
	function setAndAssertText(text:String)
	{
		button.text = text;
		Assert.areEqual(text, button.text);
		if (button.label != null)
			Assert.areEqual(text, button.label.text);
	}
#end
}