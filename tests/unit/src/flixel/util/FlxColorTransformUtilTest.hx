package flixel.util;

import haxe.PosInfos;
import massive.munit.Assert;
import openfl.geom.ColorTransform;

using flixel.util.FlxColorTransformUtil;

class FlxColorTransformUtilTest extends FlxTest
{
	var color:ColorTransform;
	
	@Before
	function before():Void
	{
		color = new ColorTransform();
	}
	
	@Test
	function testReset()
	{
		color.set(0, 0.5, 1.0, 1.5, -0.5, 0, 0.5, 1.0);
		color.reset().reset();
		assertCTEquals(1.0, 1.0, 1.0, 1.0, 0.0, 0.0, 0.0, 0.0);
	}
	
	@Test
	function testSetRGBA()
	{
		color.set(0.0, 0.5, 1.0, 1.5, -0.5, 0.0, 0.5, 1.0);
		assertCTEquals(0, 0.5, 1.0, 1.5, -0.5, 0, 0.5, 1.0);
		
		//test optional alpha args
		#if !flash
		color.set(0, 0.25, 0.5, -0.5, 0, 0.5);
		assertCTEquals(0, 0.25, 0.5, 1.0, -0.5, 0, 0.5, 0);
		#else
		color.set(0, 0.25, 0.5, 1.0, -0.5, 0, 0.5);
		assertCTEquals(0, 0.25, 0.5, 1.0, -0.5, 0, 0.5, 0);
		#end
	}
	
	@Test
	function testSetColor()
	{
		color.set(0xFFBB7733, 0xCC884400);
		assertCTEquals(0xBB/0xFF, 0x77/0xFF, 0x33/0xFF, 1.0, 0x88, 0x44, 0.0, 0xCC);
		color.set(0xEEAA6622);
		assertCTEquals(0xAA/0xFF, 0x66/0xFF, 0x22/0xFF, 0xEE/0xFF, 0, 0, 0, 0);
		final c:FlxColor = 0xDD995511;
		// test chaining
		color.set(0x0).set(c);
		assertCTEquals(c.redFloat, c.greenFloat, c.blueFloat, c.alphaFloat, 0, 0, 0, 0);
	}
	
	@Test
	function testScaleMultipliersRGBA()
	{
		color.scaleMultipliers(0.4, 0.5, 0.6, 1.5);
		assertCTEquals(0.4, 0.5, 0.6, 1.5, 0, 0, 0, 0);
		color.scaleMultipliers(0.4, 0.5, 0.6);
		assertCTEquals(0.16, 0.25, 0.36, 1.5, 0, 0, 0, 0);
	}
	
	@Test
	function testScaleMultipliersColor()
	{
		color.scaleMultipliers(0x115599dd);
		assertCTEquals(0x55/0xFF, 0x99/0xFF, 0xDD/0xFF, 0x11/0xFF, 0, 0, 0, 0);
		final c:FlxColor = 0x115599dd;
		color.reset();
		// test chaining
		color.scaleMultipliers(c).scaleMultipliers(c);
		inline function sqr(n:Float) return n*n;
		assertCTEquals(sqr(c.redFloat), sqr(c.greenFloat), sqr(c.blueFloat), sqr(c.alphaFloat), 0, 0, 0, 0);
	}
	
	@Test
	function testSetMultipliersRGBA()
	{
		color.setMultipliers(0, 0.5, 1.0, 1.5);
		assertCTEquals(0, 0.5, 1.0, 1.5, 0, 0, 0, 0);
		
		color.reset();
		//test optional alpha args
		color.setMultipliers(0, 0.25, 0.5);
		assertCTEquals(0, 0.25, 0.5, 1.0, 0, 0, 0, 0);
	}
	
	@Test
	function testSetMultipliersColor()
	{
		color.set(0xFFBB7733);
		assertCTEquals(0xBB/0xFF, 0x77/0xFF, 0x33/0xFF, 1.0, 0, 0, 0, 0);
		final c:FlxColor = 0xDD995511;
		// test chaining
		color.set(0x0).set(c);
		assertCTEquals(c.redFloat, c.greenFloat, c.blueFloat, c.alphaFloat, 0, 0, 0, 0);
	}
	
	@Test
	function testSetOffsetsRGBA()
	{
		color.setOffsets(0.4, 0.5, 0.6, 1.5);
		assertCTEquals(1, 1, 1, 1, 0.4, 0.5, 0.6, 1.5);
		
		color.reset();
		//test optional alpha args
		color.setOffsets(0, 0, 0).setOffsets(0.4, 0.5, 0.6);
		assertCTEquals(1, 1, 1, 1, 0.4, 0.5, 0.6, 0.0);
	}
	
	@Test
	function testSetOffsetsColor()
	{
		color.setOffsets(0xFFBB7733);
		assertCTEquals(1, 1, 1, 1, 0xBB, 0x77, 0x33, 0xFF);
		final c:FlxColor = 0xDD995511;
		// test chaining
		color.setOffsets(0x0).setOffsets(c);
		assertCTEquals(1, 1, 1, 1, c.red, c.green, c.blue, c.alpha);
	}
	
	@Test
	function testHasRGBMultipliers()
	{
		inline function assertHas(r,g,b, ?pos)
		{
			color.set(r,g,b, 0, 0, 0, 0, 0);
			Assert.isTrue(color.hasRGBMultipliers(), "Expected RGB multipliers, found none", pos);
		}
		
		inline function assertNotHas(r,g,b, ?pos)
		{
			color.set(r,g,b, 0, 0, 0, 0, 0);
			Assert.isFalse(color.hasRGBMultipliers(), "Expected NO RGB multipliers, found none", pos);
		}
		
		assertNotHas(1.0, 1.0, 1.0);
		assertHas(0.999, 1.0, 1.0);
		assertHas(1.0, 0.999, 1.0);
		assertHas(1.0, 1.0, 0.999);
		assertHas(1.5, 1.0, 1.0);
	}
	
	@Test
	function testHasRGBAMultipliers()
	{
		inline function assertHas(r,g,b,a, ?pos)
		{
			color.set(r,g,b,a, 0, 0, 0, 0);
			Assert.isTrue(color.hasRGBAMultipliers(), "Expected RGBA multipliers, found none", pos);
		}
		
		inline function assertNotHas(r,g,b,a, ?pos)
		{
			color.set(r,g,b,a, 0, 0, 0, 0);
			Assert.isFalse(color.hasRGBAMultipliers(), "Expected NO RGBA multipliers, found none", pos);
		}
		
		assertNotHas(1.0, 1.0, 1.0, 1.0);
		assertHas(0.999, 1.0, 1.0, 1.0);
		assertHas(1.0, 0.999, 1.0, 1.0);
		assertHas(1.0, 1.0, 0.999, 1.0);
		assertHas(1.0, 1.0, 1.0, 0.999);
		assertHas(1.5, 1.0, 1.0, 1.0);
	}
	
	@Test
	function testHasRGBOffsets()
	{
		inline function assertHas(r,g,b, ?pos)
		{
			color.set(0, 0, 0, 0, r,g,b,0);
			Assert.isTrue(color.hasRGBOffsets(), "Expected RGB offsets, found none", pos);
		}
		
		inline function assertNotHas(r,g,b, ?pos)
		{
			color.set(0, 0, 0, 0, r,g,b,0);
			Assert.isFalse(color.hasRGBOffsets(), "Expected NO RGB offsets, found none", pos);
		}
		
		assertNotHas(0.0, 0.0, 0.0);
		assertHas(0.001, 0.0, 0.0);
		assertHas(0.0, 0.001, 0.0);
		assertHas(0.0, 0.0, 0.001);
		assertHas(-0.5, 0.0, 0.0);
	}
	
	@Test
	function testHasRGBAOffsets()
	{
		inline function assertHas(r,g,b,a, ?pos)
		{
			color.set(0, 0, 0, 0, r,g,b,a);
			Assert.isTrue(color.hasRGBAOffsets(), "Expected RGBA offsets, found none", pos);
		}
		
		inline function assertNotHas(r,g,b,a, ?pos)
		{
			color.set(0, 0, 0, 0, r,g,b,a);
			Assert.isFalse(color.hasRGBAOffsets(), "Expected NO RGBA offsets, found none", pos);
		}
		
		assertNotHas(0.0, 0.0, 0.0, 0.0);
		assertHas(0.001, 0.0, 0.0, 0.0);
		assertHas(0.0, 0.001, 0.0, 0.0);
		assertHas(0.0, 0.0, 0.001, 0.0);
		assertHas(0.0, 0.0, 0.0, 0.001);
		assertHas(-0.5, 0.0, 0.0, 0.0);
	}
	
	function assertCTEquals(rM:Float, gM:Float, bM:Float, aM:Float, rO:Float, gO:Float, bO:Float, aO:Float, margin = 0.001, ?pos:PosInfos)
	{
		FlxAssert.areNear(color.redMultiplier, rM, margin, 'red multiplier [${color.redMultiplier}] is not within $margin of [$rM]', pos);
		FlxAssert.areNear(color.greenMultiplier, gM, margin, 'green multiplier [${color.greenMultiplier}] is not within $margin of [$gM]', pos);
		FlxAssert.areNear(color.blueMultiplier, bM, margin, 'blue multiplier [${color.blueMultiplier}] is not within $margin of [$bM]', pos);
		FlxAssert.areNear(color.alphaMultiplier, aM, margin, 'alpha multiplier [${color.alphaMultiplier}] is not within $margin of [$aM]', pos);
		FlxAssert.areNear(color.redOffset, rO, margin, 'red offset [${color.redOffset}] is not within $margin of [$rO]', pos);
		FlxAssert.areNear(color.greenOffset, gO, margin, 'green offset [${color.greenOffset}] is not within $margin of [$gO]', pos);
		FlxAssert.areNear(color.blueOffset, bO, margin, 'blue offset [${color.blueOffset}] is not within $margin of [$bO]', pos);
		FlxAssert.areNear(color.alphaOffset, aO, margin, 'alpha offset [${color.alphaOffset}] is not within $margin of [$aO]', pos);
	}
}
