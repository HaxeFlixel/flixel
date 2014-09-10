package flixel;

import flash.display.BitmapData;
import flixel.animation.FlxAnimation;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import massive.munit.Assert;

class FlxSpriteTest extends FlxTest
{
	var sprite1:FlxSprite;
	var sprite2:FlxSprite;
	
	@Before
	function before():Void 
	{
		sprite1 = new FlxSprite();
		sprite1.makeGraphic(100, 80);
		
		sprite2 = new FlxSprite();
		sprite2.makeGraphic(100, 80);
		
		destroyable = sprite1;
	}
	
	@Test
	function testSize():Void 
	{
		Assert.areEqual(100, sprite1.width);
		Assert.areEqual(80, sprite1.height);
	}
	
	@Test
	function testSpriteDefaultValues():Void 
	{
		Assert.isNotNull(sprite1);
		Assert.isNotNull(sprite2);
		
		Assert.isTrue(sprite1.active);
		Assert.isTrue(sprite1.visible);
		Assert.isTrue(sprite1.alive);
		Assert.isTrue(sprite1.exists);
		
		Assert.isTrue(sprite2.active);
		Assert.isTrue(sprite2.visible);
		Assert.isTrue(sprite2.alive);
		Assert.isTrue(sprite2.exists);
	}
	
	@Test
	function testAddToState():Void 
	{
		FlxG.state.add(sprite1);
		FlxG.state.add(sprite2);
		
		var sprite1Index:Int = FlxG.state.members.indexOf(sprite1);
		Assert.areNotEqual(-1, sprite1Index);
		
		var sprite2Index:Int = FlxG.state.members.indexOf(sprite2);
		Assert.areNotEqual(-1, sprite2Index);
	}

	@Test
	function testRemoveFromState():Void 
	{
		FlxG.state.remove(sprite1);
		
		var sprite1Index:Int = FlxG.state.members.indexOf(sprite1);
		Assert.areEqual(-1, sprite1Index);
		
		FlxG.state.add(sprite1);
		
		var sprite1Index:Int = FlxG.state.members.indexOf(sprite1);
		Assert.areNotEqual(-1, sprite1Index);
	}

	@Test
	function testMakeGraphicColor():Void
	{
		var color = FlxColor.RED;
		var colorSprite = new FlxSprite();
		colorSprite.makeGraphic(100, 100, color);
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(0, 0));
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(90, 90));
		
		color = FlxColor.GREEN;
		colorSprite = new FlxSprite();
		colorSprite.makeGraphic(120, 120, color);
		Assert.areEqual(color.to24Bit(), colorSprite.pixels.getPixel(119, 119));
	}

	@Test
	function testHeight():Void
	{
		var heightSprite = new FlxSprite();
		var bitmapData = new BitmapData (1, 1);
		heightSprite.loadGraphic(bitmapData);
		
		Assert.areEqual(1, heightSprite.height);
		
		heightSprite = new FlxSprite();
		bitmapData = new BitmapData(100, 100, true, 0xFFFF0000);
		heightSprite.loadGraphic(bitmapData);
		
		Assert.areEqual(100, heightSprite.height);
		
		heightSprite.height = 456;
		
		Assert.areEqual(456, heightSprite.height);
	}
	
	@Test
	function testWidth():Void
	{
		var widthSprite = new FlxSprite();
		var bitmapData = new BitmapData(1, 1);
		widthSprite.loadGraphic(bitmapData);
		
		Assert.areEqual(1, widthSprite.width);
		
		widthSprite = new FlxSprite();
		bitmapData = new BitmapData(100, 100, true, 0xFFFF0000);
		widthSprite.loadGraphic(bitmapData);
		
		Assert.areEqual(100, widthSprite.width);
		
		widthSprite.width = 323;
		
		Assert.areEqual(323, widthSprite.width);
	}
	
	@Test
	function testSetSize():Void
	{
		var sizeSprite = new FlxSprite();
		var bitmapData = new BitmapData(100, 130);
		sizeSprite.loadGraphic(bitmapData);
		
		Assert.areEqual(100, sizeSprite.width);
		Assert.areEqual(130, sizeSprite.height);
		
		sizeSprite.setSize(233,333);
		
		Assert.areEqual(233, sizeSprite.width);
		Assert.areEqual(333, sizeSprite.height);
	}
	
	@Test
	function testXAfterAddingToState():Void
	{
		var xSprite = new FlxSprite(33, 445);
		FlxG.state.add(xSprite);
		
		Assert.areEqual(xSprite.x, 33);
	}
	
	@Test
	function testYAfterAddingToState():Void
	{
		var ySprite = new FlxSprite(433, 444);
		FlxG.state.add(ySprite);
		
		Assert.areEqual(ySprite.y, 444);
	}
	
	@Test
	function testSetPositionAfterAddingToState()
	{
		var positionSprite = new FlxSprite(433,444);
		FlxG.state.add(positionSprite);
		
		positionSprite.setPosition(333, 332);
		
		Assert.areEqual(positionSprite.x, 333);
		Assert.areEqual(positionSprite.y, 332);
		
		positionSprite.setPosition(453, 545);
		
		Assert.areEqual(positionSprite.x, 453);
		Assert.areEqual(positionSprite.y, 545);
	}
	
	@Test
	function testOverlap():Void
	{
		Assert.isTrue(FlxG.overlap(sprite1, sprite2));
		
		//Move the sprites away from eachother
		sprite1.velocity.x = 2000;
		sprite2.velocity.x = -2000;
		
		FlxG.state.add(sprite1);
		FlxG.state.add(sprite2);
		
		step(60);
		Assert.isFalse(FlxG.overlap(sprite1, sprite2)); 
	}
	
	@Test
	function testLoadGraphicFromSpriteCopyAnimations():Void
	{
		var graphic = new BitmapData(3, 1);
		sprite1.loadGraphic(graphic, true, 1, 1);
		sprite1.animation.add("animation", [0, 1, 2]);
		
		sprite2.loadGraphicFromSprite(sprite1);
		
		var animation:FlxAnimation = sprite2.animation.getByName("animation");
		Assert.areEqual(3, animation.numFrames);
	}
	
	@Test // issue 1203
	function testColorWithAlphaComparison():Void
	{
		sprite1.color = FlxColor.RED;
		Assert.areEqual(FlxColor.RED, sprite1.color);
	}
}