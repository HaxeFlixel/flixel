package flixel.math;

import massive.munit.Assert;

class FlxMathTest extends FlxTest
{
	
	@Test
	function testFastTrig()
	{
		var eps = 0.0011; // max error is 0.001090292749970 or so
		
		var angles = [for (i in 0...100) Math.random() * i];
		angles.push(0);
		angles.push(Math.PI);
		angles.push( -Math.PI);
		
		var maxError = 0.0;
		for (angle in angles)
		{
			var eSin = Math.abs(FlxMath.fastSin(angle) - Math.sin(angle));
			var eCos = Math.abs(FlxMath.fastCos(angle) - Math.cos(angle));
			if (eSin > maxError) maxError = eSin;
			if (eCos > maxError) maxError = eCos;
		}
		
		Assert.isTrue(eps > maxError);
	}
}