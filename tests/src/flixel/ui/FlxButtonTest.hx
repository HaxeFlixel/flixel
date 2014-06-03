package flixel.ui;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.ui.FlxButton;
import massive.munit.Assert;

class FlxButtonTest
{
	var button:FlxButton;
	
	@Before
	function before():Void
	{
		button = new FlxButton();
	}
	
	@Test
	function testDefaultStatusAnimations():Void
	{
		assertStatusAnimationsExist();
	}
	
	@Test
	function testLoadGraphicStatusAnimations():Void
	{
		var graphic = new BitmapData(3, 1);
		button.loadGraphic(graphic, true, 1, 1);
		
		assertStatusAnimationsExist();
	}
	
	@Test
	function testLoadGraphicFromSpriteStatusAnimations():Void
	{
		var sprite = new FlxSprite();
		var graphic = new BitmapData(3, 1);
		sprite.loadGraphic(graphic, true, 1, 1);
		
		button.loadGraphicFromSprite(sprite);
		
		assertStatusAnimationsExist();
	}
	
	function assertStatusAnimationsExist():Void
	{
		var normalName:String = button.statusAnimations[FlxButton.NORMAL];
		var highlightName:String = button.statusAnimations[FlxButton.HIGHLIGHT];
		var pressedName:String = button.statusAnimations[FlxButton.PRESSED];
		
		Assert.isNotNull(button.animation.getByName(normalName));
		Assert.isNotNull(button.animation.getByName(highlightName));
		Assert.isNotNull(button.animation.getByName(pressedName));
	}
}