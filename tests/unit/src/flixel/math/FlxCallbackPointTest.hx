package flixel.math;

import Math.PI;
import flixel.math.FlxMath.SQUARE_ROOT_OF_TWO as sqrt2;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import haxe.PosInfos;
import massive.munit.Assert;
import openfl.geom.Point;

class FlxCallbackPointTest extends FlxTest
{
	@Test
	@:haxe.warning("-WDeprecated")
	function testAll3Callbacks()
	{
		var sets = 0;
		var xSets = 0;
		var ySets = 0;
		
		function assertChecked(expectedSets:Int, ?expectedXSets:Int, ?expectedYSets:Int, ?pos:PosInfos)
		{
			if (expectedXSets == null)
				expectedXSets = expectedSets;
			
			if (expectedYSets == null)
				expectedYSets = expectedSets;
			
			Assert.areEqual(expectedSets , sets , 'The point was set [${    sets}] times compared to the expected [$expectedSets] times', pos);
			Assert.areEqual(expectedXSets, xSets, 'The point\'s X was set [$xSets] times compared to the expected [$expectedXSets] times', pos);
			Assert.areEqual(expectedYSets, ySets, 'The point\'s Y was set [$ySets] times compared to the expected [$expectedYSets] times', pos);
			
			sets = 0;
			xSets = 0;
			ySets = 0;
		}
		
		final p:FlxPoint = new FlxCallbackPoint((_)->xSets++, (_)->ySets++, (_)->sets++);
		final norm = new FlxPoint(sqrt2, sqrt2);
		final p2 = new FlxPoint(1, 1);
		final fp = new Point(1, 1);
		
		// These should not call set
		p.inCoords(0, 0, 10, 10)                ; assertChecked(0);
		p.inRect(new FlxRect(0, 0, 10, 10))     ; assertChecked(0);
		p.distanceTo(p2)                        ; assertChecked(0);
		p.distanceTo(p2.x, p2.y)                ; assertChecked(0);
		p.distanceSquaredTo(p2)                 ; assertChecked(0);
		p.distanceSquaredTo(p2.x, p2.y)         ; assertChecked(0);
		p.radiansTo(p2)                         ; assertChecked(0);
		p.radiansFrom(p2)                       ; assertChecked(0);
		p.degreesTo(p2)                         ; assertChecked(0);
		p.degreesFrom(p2)                       ; assertChecked(0);
		p.dot(p2)                               ; assertChecked(0);
		p.dotProduct(p2)                        ; assertChecked(0);
		p.dotProdWithNormalizing(p2)            ; assertChecked(0);
		p.isPerpendicular(p2)                   ; assertChecked(0);
		p.crossProductLength(p2)                ; assertChecked(0);
		p.isParallel(p2)                        ; assertChecked(0);
		p.isNormalized()                        ; assertChecked(0);
		p.rightNormal()                         ; assertChecked(0);
		p.leftNormal()                          ; assertChecked(0);
		p.negateNew()                           ; assertChecked(0);
		p.projectTo(p2)                         ; assertChecked(0);
		p.projectToNormalized(p2)               ; assertChecked(0);
		p.perpProduct(p2)                       ; assertChecked(0);
		p.ratio(norm, norm, p2)                 ; assertChecked(0);
		p.findIntersection(p2, p2, norm)        ; assertChecked(0);
		p.findIntersectionInBounds(p2, p2, norm); assertChecked(0);
		p.truncate(10)                          ; assertChecked(0);
		p.radiansBetween(p2)                    ; assertChecked(0);
		p.degreesBetween(p2)                    ; assertChecked(0);
		p.sign(p2, norm)                        ; assertChecked(0);
		p.dist(p2.x, p2.y)                      ; assertChecked(0);
		p.dist(p2)                              ; assertChecked(0);
		p.distSquared(p2)                       ; assertChecked(0);
		p.distSquared(p2.x, p2.y)               ; assertChecked(0);
		p.isValid()                             ; assertChecked(0);
		p.clone()                               ; assertChecked(0);
		p.equals(p2)                            ; assertChecked(0);
		p.toString()                            ; assertChecked(0);
		
		// These should call each set, once
		p.set(10, 5)                            ; assertChecked(1);
		p.add(1, 2)                             ; assertChecked(1);
		p.add(p2)                               ; assertChecked(1);
		p.addPoint(p2)                          ; assertChecked(1);
		p.subtract(2, 1)                        ; assertChecked(1);
		p.subtract(p2)                          ; assertChecked(1);
		p.subtractPoint(p2)                     ; assertChecked(1);
		p.scale(2, 2)                           ; assertChecked(1);
		p.scale(p2)                             ; assertChecked(1);
		p.scalePoint(p2)                        ; assertChecked(1);
		p.copyFrom(p2)                          ; assertChecked(1);
		p.copyFromFlash(fp)                     ; assertChecked(1);
		p.floor()                               ; assertChecked(1);
		p.ceil()                                ; assertChecked(1);
		p.round()                               ; assertChecked(1);
		p.pivotRadians(p2, PI / 3)              ; assertChecked(1);
		p.pivotDegrees(p2, 60)                  ; assertChecked(1);
		p.transform(new FlxMatrix())            ; assertChecked(1);
		p.zero()                                ; assertChecked(1);
		p.rotateByRadians(PI / 3)               ; assertChecked(1);
		p.rotateByDegrees(60)                   ; assertChecked(1);
		p.rotateWithTrig(1, 0)                  ; assertChecked(1);
		p.setPolarRadians(10, PI / 3)           ; assertChecked(1);
		p.setPolarDegrees(10, 45)               ; assertChecked(1);
		p.negate()                              ; assertChecked(1);
		p.truncate(10)                          ; assertChecked(1);
		p.bounce(norm)                          ; assertChecked(1);
		p.bounceWithFriction(norm, 0.5, 0.25)   ; assertChecked(1);
		// normalise only sets if p is not zero
		p.set(0, 0)                             ; assertChecked(1);
		p.normalize()                           ; assertChecked(0);
		p.set(10, 10)                           ; assertChecked(1);
		p.normalize()                           ; assertChecked(1);
		// Check setters/getters
		p.x++                                   ; assertChecked(1, 1, 0);
		p.y++                                   ; assertChecked(1, 0, 1);
		p.length = 90                           ; assertChecked(1);
		p.degrees = 90                          ; assertChecked(1);
		p.radians = 90                          ; assertChecked(1);
		// Check operators
		p += norm                               ; assertChecked(1);
		p -= norm                               ; assertChecked(1);
		p *= 2                                  ; assertChecked(1);
		final newP = ((p + norm) - norm) * 2    ; assertChecked(0);
		// check getters
		final sum = p.dx + p.dy + p.rx + p.ry + p.lx + p.ly + p.lengthSquared;
		assertChecked(0);
	}
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testLoneCallback()
	{
		var sets = 0;
		
		function assertChecked(expectedSets:Int, ?pos:PosInfos)
		{
			Assert.areEqual(expectedSets , sets , 'The point was set [$sets] times compared to the expected [$expectedSets] times', pos);
			
			sets = 0;
		}
		
		final p:FlxPoint = new FlxCallbackPoint((_)->sets++);
		final norm = new FlxPoint(sqrt2, sqrt2);
		final p2 = new FlxPoint(1, 1);
		final fp = new Point(1, 1);
		
		// These should not call set
		p.inCoords(0, 0, 10, 10)                ; assertChecked(0);
		p.inRect(new FlxRect(0, 0, 10, 10))     ; assertChecked(0);
		p.distanceTo(p2)                        ; assertChecked(0);
		p.distanceTo(p2.x, p2.y)                ; assertChecked(0);
		p.distanceSquaredTo(p2)                 ; assertChecked(0);
		p.distanceSquaredTo(p2.x, p2.y)         ; assertChecked(0);
		p.radiansTo(p2)                         ; assertChecked(0);
		p.radiansFrom(p2)                       ; assertChecked(0);
		p.degreesTo(p2)                         ; assertChecked(0);
		p.degreesFrom(p2)                       ; assertChecked(0);
		p.dot(p2)                               ; assertChecked(0);
		p.dotProduct(p2)                        ; assertChecked(0);
		p.dotProdWithNormalizing(p2)            ; assertChecked(0);
		p.isPerpendicular(p2)                   ; assertChecked(0);
		p.crossProductLength(p2)                ; assertChecked(0);
		p.isParallel(p2)                        ; assertChecked(0);
		p.isNormalized()                        ; assertChecked(0);
		p.rightNormal()                         ; assertChecked(0);
		p.leftNormal()                          ; assertChecked(0);
		p.negateNew()                           ; assertChecked(0);
		p.projectTo(p2)                         ; assertChecked(0);
		p.projectToNormalized(p2)               ; assertChecked(0);
		p.perpProduct(p2)                       ; assertChecked(0);
		p.ratio(norm, norm, p2)                 ; assertChecked(0);
		p.findIntersection(p2, p2, norm)        ; assertChecked(0);
		p.findIntersectionInBounds(p2, p2, norm); assertChecked(0);
		p.truncate(10)                          ; assertChecked(0);
		p.radiansBetween(p2)                    ; assertChecked(0);
		p.degreesBetween(p2)                    ; assertChecked(0);
		p.sign(p2, norm)                        ; assertChecked(0);
		p.dist(p2.x, p2.y)                      ; assertChecked(0);
		p.dist(p2)                              ; assertChecked(0);
		p.distSquared(p2)                       ; assertChecked(0);
		p.distSquared(p2.x, p2.y)               ; assertChecked(0);
		p.isValid()                             ; assertChecked(0);
		p.clone()                               ; assertChecked(0);
		p.equals(p2)                            ; assertChecked(0);
		p.toString()                            ; assertChecked(0);
		
		// These should call each set, once
		p.set(10, 5)                            ; assertChecked(1);
		p.add(1, 2)                             ; assertChecked(1);
		p.add(p2)                               ; assertChecked(1);
		p.addPoint(p2)                          ; assertChecked(1);
		p.subtract(2, 1)                        ; assertChecked(1);
		p.subtract(p2)                          ; assertChecked(1);
		p.subtractPoint(p2)                     ; assertChecked(1);
		p.scale(2, 2)                           ; assertChecked(1);
		p.scale(p2)                             ; assertChecked(1);
		p.scalePoint(p2)                        ; assertChecked(1);
		p.copyFrom(p2)                          ; assertChecked(1);
		p.copyFromFlash(fp)                     ; assertChecked(1);
		p.floor()                               ; assertChecked(1);
		p.ceil()                                ; assertChecked(1);
		p.round()                               ; assertChecked(1);
		p.pivotRadians(p2, PI / 3)              ; assertChecked(1);
		p.pivotDegrees(p2, 60)                  ; assertChecked(1);
		p.transform(new FlxMatrix())            ; assertChecked(1);
		p.zero()                                ; assertChecked(1);
		p.rotateByRadians(PI / 3)               ; assertChecked(1);
		p.rotateByDegrees(60)                   ; assertChecked(1);
		p.rotateWithTrig(1, 0)                  ; assertChecked(1);
		p.setPolarRadians(10, PI / 3)           ; assertChecked(1);
		p.setPolarDegrees(10, 45)               ; assertChecked(1);
		p.negate()                              ; assertChecked(1);
		p.truncate(10)                          ; assertChecked(1);
		p.bounce(norm)                          ; assertChecked(1);
		p.bounceWithFriction(norm, 0.5, 0.25)   ; assertChecked(1);
		// normalise only sets if p is not zero
		p.set(0, 0)                             ; assertChecked(1);
		p.normalize()                           ; assertChecked(0);
		p.set(10, 10)                           ; assertChecked(1);
		p.normalize()                           ; assertChecked(1);
		// Check setters/getters
		p.x++                                   ; assertChecked(1);
		p.y++                                   ; assertChecked(1);
		p.length = 90                           ; assertChecked(1);
		p.degrees = 90                          ; assertChecked(1);
		p.radians = 90                          ; assertChecked(1);
		// Check operators
		p += norm                               ; assertChecked(1);
		p -= norm                               ; assertChecked(1);
		p *= 2                                  ; assertChecked(1);
		final newP = ((p + norm) - norm) * 2    ; assertChecked(0);
		// check getters
		final sum = p.dx + p.dy + p.rx + p.ry + p.lx + p.ly + p.lengthSquared;
		assertChecked(0);
	}
	
	
	@Test
	@:haxe.warning("-WDeprecated")
	function testXandYCallbacks()
	{
		
		var xSets = 0;
		var ySets = 0;
		
		function assertChecked(expectedXSets:Int, ?expectedYSets:Int, ?pos:PosInfos)
		{
			if (expectedYSets == null)
				expectedYSets = expectedXSets;
			
			Assert.areEqual(expectedXSets, xSets, 'The point\'s X was set [$xSets] times compared to the expected [$expectedXSets] times', pos);
			Assert.areEqual(expectedYSets, ySets, 'The point\'s Y was set [$ySets] times compared to the expected [$expectedYSets] times', pos);
			
			xSets = 0;
			ySets = 0;
		}
		
		final p:FlxPoint = new FlxCallbackPoint((_)->xSets++, (_)->ySets++);
		final norm = new FlxPoint(sqrt2, sqrt2);
		final p2 = new FlxPoint(1, 1);
		final fp = new Point(1, 1);
		
		// These should not call set
		p.inCoords(0, 0, 10, 10)                ; assertChecked(0);
		p.inRect(new FlxRect(0, 0, 10, 10))     ; assertChecked(0);
		p.distanceTo(p2)                        ; assertChecked(0);
		p.distanceTo(p2.x, p2.y)                ; assertChecked(0);
		p.distanceSquaredTo(p2)                 ; assertChecked(0);
		p.distanceSquaredTo(p2.x, p2.y)         ; assertChecked(0);
		p.radiansTo(p2)                         ; assertChecked(0);
		p.radiansFrom(p2)                       ; assertChecked(0);
		p.degreesTo(p2)                         ; assertChecked(0);
		p.degreesFrom(p2)                       ; assertChecked(0);
		p.dot(p2)                               ; assertChecked(0);
		p.dotProduct(p2)                        ; assertChecked(0);
		p.dotProdWithNormalizing(p2)            ; assertChecked(0);
		p.isPerpendicular(p2)                   ; assertChecked(0);
		p.crossProductLength(p2)                ; assertChecked(0);
		p.isParallel(p2)                        ; assertChecked(0);
		p.isNormalized()                        ; assertChecked(0);
		p.rightNormal()                         ; assertChecked(0);
		p.leftNormal()                          ; assertChecked(0);
		p.negateNew()                           ; assertChecked(0);
		p.projectTo(p2)                         ; assertChecked(0);
		p.projectToNormalized(p2)               ; assertChecked(0);
		p.perpProduct(p2)                       ; assertChecked(0);
		p.ratio(norm, norm, p2)                 ; assertChecked(0);
		p.findIntersection(p2, p2, norm)        ; assertChecked(0);
		p.findIntersectionInBounds(p2, p2, norm); assertChecked(0);
		p.truncate(10)                          ; assertChecked(0);
		p.radiansBetween(p2)                    ; assertChecked(0);
		p.degreesBetween(p2)                    ; assertChecked(0);
		p.sign(p2, norm)                        ; assertChecked(0);
		p.dist(p2.x, p2.y)                      ; assertChecked(0);
		p.dist(p2)                              ; assertChecked(0);
		p.distSquared(p2)                       ; assertChecked(0);
		p.distSquared(p2.x, p2.y)               ; assertChecked(0);
		p.isValid()                             ; assertChecked(0);
		p.clone()                               ; assertChecked(0);
		p.equals(p2)                            ; assertChecked(0);
		p.toString()                            ; assertChecked(0);
		
		// These should call each set, once
		p.set(10, 5)                            ; assertChecked(1);
		p.add(1, 2)                             ; assertChecked(1);
		p.add(p2)                               ; assertChecked(1);
		p.addPoint(p2)                          ; assertChecked(1);
		p.subtract(2, 1)                        ; assertChecked(1);
		p.subtract(p2)                          ; assertChecked(1);
		p.subtractPoint(p2)                     ; assertChecked(1);
		p.scale(2, 2)                           ; assertChecked(1);
		p.scale(p2)                             ; assertChecked(1);
		p.scalePoint(p2)                        ; assertChecked(1);
		p.copyFrom(p2)                          ; assertChecked(1);
		p.copyFromFlash(fp)                     ; assertChecked(1);
		p.floor()                               ; assertChecked(1);
		p.ceil()                                ; assertChecked(1);
		p.round()                               ; assertChecked(1);
		p.pivotRadians(p2, PI / 3)              ; assertChecked(1);
		p.pivotDegrees(p2, 60)                  ; assertChecked(1);
		p.transform(new FlxMatrix())            ; assertChecked(1);
		p.zero()                                ; assertChecked(1);
		p.rotateByRadians(PI / 3)               ; assertChecked(1);
		p.rotateByDegrees(60)                   ; assertChecked(1);
		p.rotateWithTrig(1, 0)                  ; assertChecked(1);
		p.setPolarRadians(10, PI / 3)           ; assertChecked(1);
		p.setPolarDegrees(10, 45)               ; assertChecked(1);
		p.negate()                              ; assertChecked(1);
		p.truncate(10)                          ; assertChecked(1);
		p.bounce(norm)                          ; assertChecked(1);
		p.bounceWithFriction(norm, 0.5, 0.25)   ; assertChecked(1);
		// normalise only sets if p is not zero
		p.set(0, 0)                             ; assertChecked(1);
		p.normalize()                           ; assertChecked(0);
		p.set(10, 10)                           ; assertChecked(1);
		p.normalize()                           ; assertChecked(1);
		// Check setters/getters
		p.x++                                   ; assertChecked(1, 0);
		p.y++                                   ; assertChecked(0, 1);
		p.length = 90                           ; assertChecked(1);
		p.degrees = 90                          ; assertChecked(1);
		p.radians = 90                          ; assertChecked(1);
		// Check operators
		p += norm                               ; assertChecked(1);
		p -= norm                               ; assertChecked(1);
		p *= 2                                  ; assertChecked(1);
		final newP = ((p + norm) - norm) * 2    ; assertChecked(0);
		// check getters
		final sum = p.dx + p.dy + p.rx + p.ry + p.lx + p.ly + p.lengthSquared;
		assertChecked(0);
	}
}