package flixel.overlap;

import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.overlap.FlxOverlapData;

class FlxOverlap2D {
	
	private static var _normalAxis = FlxVector.get();
	private static var _vectorOffset = FlxVector.get();
	private static var _closestVector = FlxVector.get();
	
	private static var _delta = FlxVector.get();
	private static var _ray2circle = FlxVector.get();

	
	/**
	 * Check a circle against a polygon
	 * 
	 * @param	circle				The circle
	 * @param	polygon				The polygon
	 * @param	flip				Weather the two hitbox should be switched in overlapData
	 * @param	overlapData 		Additional information about the overlap. Pass down an FlxOverlapData to this if you need it.
	 * @param	updateTransforms 	Wether the hitboxes transformed parameters should be updated or not.
	 * @return	Whether any overlaps were detected.
	 */
	public static function testCircleVsPolygon (circle : FlxCircle, polygon : FlxPolygon, flip : Bool, overlapData : FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
	    var test1 : Float;
        var test2 : Float;
        var test : Float;
        
        var min1 : Float = 0;
        var max1 : Float = 0x3FFFFFFF;
        var min2 : Float = 0;
        var max2 : Float = 0x3FFFFFFF;
        var offset : Float;
        var vectors:Array<FlxVector>;
        var shortestDistance : Float = 0x3FFFFFFF;
        var distMin : Float;

        var distance : Float = 0xFFFFFFFF;
        var testDistance : Float = 0x3FFFFFFF;
		
		if (updateTransforms)
		{
			circle.updateTransformed();
			polygon.updateTransformed();
		}
		
        _vectorOffset.set( -circle.transformedX, -circle.transformedY);
        vectors = polygon.transformedVertices;
        
        if (vectors.length == 2) 
		{
            var temp = FlxVector.get(-(vectors[1].y - vectors[0].y), vectors[1].x - vectors[0].x);
            temp.truncate(0.0000000001);
            vectors.push( vectors[1].clone().addVector(temp) );
			temp.put();
        }
        
        for (i in 0 ... vectors.length) 
		{
            distance =  (circle.transformedX - (vectors[i].x)) * (circle.transformedX - (vectors[i].x)) + 
                        (circle.transformedY - (vectors[i].y)) * (circle.transformedY - (vectors[i].y));

            if (distance < testDistance) 
			{
                testDistance = distance;
                _closestVector.x = vectors[i].x;
                _closestVector.y = vectors[i].y;
            }   
        }
		
        //get the normal vector
        _normalAxis.set(_closestVector.x - circle.transformedX, _closestVector.y - circle.transformedY);
        _normalAxis.normalize();
        
        // project the polygon's points
        min1 = _normalAxis.dotProduct(vectors[0]);
        max1 = min1;
        
        for (j in 1 ... vectors.length) 
		{
            test = _normalAxis.dotProduct(vectors[j]); 
            if (test < min1) 
			{
                min1 = test;
            } 
            else if (test > max1) 
			{
                max1 = test;
            } 
        }
        
        max2 = circle.transformedRadius;
        min2 -= circle.transformedRadius;
        
        offset = _normalAxis.dotProduct(_vectorOffset);
        min1 += offset;
        max1 += offset;
        
        test1 = min1 - max2;
        test2 = min2 - max1;
        
        if (test1 > 0 || test2 > 0) 
		{
            return false;
        }
		
        distMin = -(max2 - min1);
        if (Math.abs(distMin) < shortestDistance)
		{
			if (overlapData != null)
			{
				if (flip) distMin *= -1;
				overlapData.unitVector = _normalAxis.clone();
				overlapData.overlap = distMin;
			}
            shortestDistance = Math.abs(distMin);
        }

        for (i in 0 ... vectors.length) 
		{
            findNormalAxis(vectors, i);
            
            min1 = _normalAxis.dotProduct(vectors[0]);
            max1 = min1;
            
            for (j in 1 ... vectors.length) 
			{
                test = _normalAxis.dotProduct(vectors[j]);
                if (test < min1)
				{
                    min1 = test;
                }
                else if (test > max1) 
				{
                    max1 = test;
                }
            }
            
            max2 = circle.transformedRadius;
            min2 = -circle.transformedRadius;
            
            offset = _normalAxis.dotProduct(_vectorOffset);
            min1 += offset;
            max1 += offset;
            
            test1 = min1 - max2;
            test2 = min2 - max1;
            
            if (test1 > 0 || test2 > 0) 
                return false;
            
            distMin = -(max2 - min1);
            if (Math.abs(distMin) < shortestDistance) 
			{
				if (overlapData != null)
				{
					if (flip) 
						distMin *= -1;
					overlapData.unitVector = _normalAxis.clone();
					overlapData.overlap = distMin;
				}
                shortestDistance = Math.abs(distMin);
            }
        }
        
		if (overlapData != null) 
		{
			overlapData.hitbox2 = flip ? polygon : circle;
			overlapData.hitbox1 = flip ? circle : polygon;
			overlapData.separation = FlxVector.get(-overlapData.unitVector.x * overlapData.overlap, -overlapData.unitVector.y * overlapData.overlap); //return the separation distance
			if (flip)
				overlapData.unitVector.negate();
		}
		
        return true;
	}
	
	public static function testCircles(circle1:FlxCircle, circle2:FlxCircle, overlapData : FlxOverlapData = null, updateTransforms : Bool = true): Bool {
		
		if (updateTransforms)
		{
			circle1.updateTransformed();
			circle2.updateTransformed();
		}
		
        var totalRadius : Float = circle1.transformedRadius + circle2.transformedRadius;
        var distanceSquared : Float = (circle1.transformedX - circle2.transformedX) * (circle1.transformedX - circle2.transformedX) + (circle1.transformedY - circle2.transformedY) * (circle1.transformedY - circle2.transformedY); //find the distance between the two circles using Pythagorean theorem. No square roots for optimization
        
        if (distanceSquared < totalRadius * totalRadius) 
		{
            if (overlapData != null) 
			{
				var difference : Float = totalRadius - Math.sqrt(distanceSquared);
				overlapData.hitbox1 = circle1;
				overlapData.hitbox2 = circle2;
				overlapData.unitVector = FlxVector.get(circle1.transformedX - circle2.transformedX, circle1.transformedY - circle2.transformedY);
				overlapData.unitVector.normalize();
				overlapData.separation = FlxVector.get(overlapData.unitVector.x * difference, overlapData.unitVector.y * difference);
				overlapData.overlap = overlapData.separation.length;
			}
			return true;
        }
        return false;
    }
	
	public static function testPolygons(polygon1:FlxPolygon, polygon2:FlxPolygon, flip:Bool = false, overlapData:FlxOverlapData = null, updateTransforms : Bool = true):Bool
	{
		if (updateTransforms)
		{
			polygon1.updateTransformed();
			polygon2.updateTransformed();
		}
		
		var tempOverlap1 = new FlxOverlapData();
		var tempOverlap2 = new FlxOverlapData();
		
		var result1 = checkPolygons(polygon1, polygon2, flip, tempOverlap1,false);
		if(!result1) return false;
		var result2 = checkPolygons(polygon2, polygon1, !flip, tempOverlap2,false);
		if (!result2) return false;
		
		if (overlapData != null)
		{
			if (Math.abs(tempOverlap1.overlap) < Math.abs(tempOverlap2.overlap))
				overlapData.copyFrom(tempOverlap1);
			else
				overlapData.copyFrom(tempOverlap2);
		}
		
		tempOverlap1.separation.put();
		tempOverlap1.unitVector.put();
		tempOverlap2.separation.put();
		tempOverlap2.unitVector.put();
		
		return true;
	}
	
	public static function checkPolygons(polygon1:FlxPolygon, polygon2:FlxPolygon, flip : Bool, overlapData:FlxOverlapData = null, updateTransforms : Bool = true):Bool {

        var test1 : Float;
        var test2 : Float;
        var testNum : Float;
        var min1 : Float;
        var max1 : Float;
        var min2 : Float;
        var max2 : Float;
        var offset : Float;
        var vectors1:Array<FlxVector>;
        var vectors2:Array<FlxVector>;
        var shortestDistance : Float = 0x3FFFFFFF;
		
		if (updateTransforms)
		{
			polygon1.updateTransformed();
			polygon2.updateTransformed();
		}
		
        vectors1 = polygon1.transformedVertices;
        vectors2 = polygon2.transformedVertices;
		
        if(vectors1.length == 2) {
            var temp = FlxVector.get(-(vectors1[1].y - vectors1[0].y), vectors1[1].x - vectors1[0].x);
            temp.truncate(0.0000000001);
            vectors1.push(vectors1[1].addVector(temp));
			temp.put();
        }
        if(vectors2.length == 2) {
            var temp = FlxVector.get(-(vectors2[1].y - vectors2[0].y), vectors2[1].x - vectors2[0].x);
            temp.truncate(0.0000000001);
            vectors2.push(vectors2[1].addVector(temp));
			temp.put();
        }
        
        for (i in 0 ... vectors1.length) 
		{
            findNormalAxis(vectors1, i);
            
            min1 = _normalAxis.dotProduct(vectors1[0]);
            max1 = min1;
            
            for (j in 1 ... vectors1.length) 
			{
                testNum = _normalAxis.dotProduct(vectors1[j]);
                if (testNum < min1) 
				{
                    min1 = testNum;
                }
                if (testNum > max1) 
				{
                    max1 = testNum;
                }
            }
            
            min2 = _normalAxis.dotProduct(vectors2[0]);
            max2 = min2;
            
            for (j in 1 ... vectors2.length) 
			{
                testNum = _normalAxis.dotProduct(vectors2[j]);
                if (testNum < min2) 
				{
                    min2 = testNum;
                }
                if (testNum > max2) 
				{
                    max2 = testNum;
                }
            }
            
            test1 = min1 - max2;
            test2 = min2 - max1;
            if (test1 > 0 || test2 > 0)
                return false;

            var distMin : Float = -(max2 - min1);
            if (Math.abs(distMin) < shortestDistance) 
			{
				if (overlapData != null)
				{
					if (flip) 
						distMin *= -1;
					overlapData.unitVector = _normalAxis.clone();
					overlapData.overlap = distMin;
				}
                shortestDistance = Math.abs(distMin);
            }
        }
		
		if (overlapData != null)
		{
			overlapData.hitbox1 = flip ? polygon2 : polygon1;
			overlapData.hitbox2 = flip ? polygon1 : polygon2;
			overlapData.separation = FlxVector.get(-overlapData.unitVector.x * overlapData.overlap, -overlapData.unitVector.y * overlapData.overlap); //return the separation, apply it to a polygon to separate the two shapes.
			if (flip) 
				overlapData.unitVector.negate();
        }
        return true;
    }
	
	public static function testCircleVsHitboxList (circle : FlxCircle, hitboxList : FlxHitboxList, flip : Bool, overlapData : FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		if (updateTransforms)
		{
			circle.updateTransformed();
			hitboxList.updateTransformed();
		}
		
		for (hitbox in hitboxList.members)
		{
			if (hitbox != hitboxList && circle.test(hitbox, overlapData, false))
			{
				if (overlapData != null && flip)
				{
					overlapData.hitbox1 = overlapData.hitbox2;
					overlapData.hitbox2 = circle;
					overlapData.separation.negate();
					overlapData.unitVector.negate();
				}
				return true;
			}
		}
		return false;
	}
	
	public static function testPolygonVsHitboxList (polygon : FlxPolygon, hitboxList : FlxHitboxList, flip : Bool, overlapData : FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		if (updateTransforms)
		{
			polygon.updateTransformed();
			hitboxList.updateTransformed();
		}
		
		for (hitbox in hitboxList.members)
		{
			if (hitbox != hitboxList && polygon.test(hitbox, overlapData, false))
			{
				if (overlapData != null && flip)
				{
					overlapData.hitbox1 = overlapData.hitbox2;
					overlapData.hitbox2 = polygon;
					overlapData.separation.negate();
					overlapData.unitVector.negate();
				}
				return true;
			}
		}
		return false;
	}
	
	public static function testHitboxLists (hitboxList1 : FlxHitboxList, hitboxList2 : FlxHitboxList, flip : Bool, overlapData : FlxOverlapData = null, updateTransforms : Bool = true) : Bool
	{
		if (updateTransforms)
		{
			hitboxList1.updateTransformed();
			hitboxList2.updateTransformed();
		}
		
		for (hitbox in hitboxList2.members)
		{
			if (hitbox != hitboxList1 && hitboxList1.test(hitbox, overlapData, false))
			{
				if (overlapData != null && flip)
				{
					var temp = overlapData.hitbox1;
					overlapData.hitbox1 = overlapData.hitbox2;
					overlapData.hitbox2 = temp;
					overlapData.separation.negate();
					overlapData.unitVector.negate();
				}
				return true;
			}
		}
		return false;
	}
	
	
	//Not currently used, tests if two FlxRect overlaps. Will be used in FlxQuadTree
	public inline static function testRects(rect1:FlxRect, rect2:FlxRect):Bool
	{
		return ((rect1.x + rect1.width > rect2.x) && (rect1.x < rect2.x + rect2.width) && (rect1.y + rect1.height > rect2.y) && (rect1.y < rect2.y + rect2.height));
	}
	
	public static function rayCircle(ray:FlxRay, circle:FlxCircle, rayData : FlxRayData = null, updateTransform : Bool = true):Bool
	{
		if (updateTransform)
			circle.updateTransformed();
		
		_delta.set(ray.end.x - ray.start.x, ray.end.y - ray.start.y);
		_ray2circle.set(ray.start.x - circle.transformedX, ray.start.y - circle.transformedY);
		
		var a = (_delta.x * _delta.x) + (_delta.y * _delta.y);
		var b = 2 * _delta.dotProduct(_ray2circle);
		var c = _ray2circle.x * _ray2circle.x + _ray2circle.y * _ray2circle.y - circle.transformedRadius * circle.transformedRadius;
		
        var d:Float = b * b - 4 * a * c;
		
		if (d >= 0)
		{
			d = Math.sqrt(d);
            
            var t1:Float = (-b - d) / (2 * a);
            var t2:Float = (-b + d) / (2 * a);
			
			if ((t1 >= 0) && (ray.isInfinite || t1 <= 1.0))
			{
				if (rayData != null)
				{
					rayData.hitbox = circle;
					rayData.ray = ray;
					rayData.start = t1;
					rayData.end = t2;
				}
				return true;
			}
		}
		return false;
	}
	
	public static function rayPolygon(ray:FlxRay, polygon:FlxPolygon, rayData : FlxRayData = null, updateTransform : Bool = true):Bool
	{
		if (updateTransform)
			polygon.updateTransformed();
		
		_delta.set(ray.end.x - ray.start.x, ray.end.y - ray.start.y);
		var vertices = polygon.transformedVertices;
		
		var min_u:Float = Math.POSITIVE_INFINITY;
		var max_u:Float = 0.0;
		
		if (vertices.length > 2)
		{
			var v1 = vertices[vertices.length - 1];
			var v2 = vertices[0];
			
			var r = intersectRayRay(ray.start, _delta, v1, v2.subtractNew(v1));
			if (r != null && r.ub >= 0.0 && r.ub <= 1.0 && r.ua >= 0)
			{
				if (r.ua < min_u) min_u = r.ua;
				if (r.ua > max_u) max_u = r.ua;
			}
			
			for (i in 1...vertices.length)
			{
				v1 = vertices[i - 1];
				v2 = vertices[i];
				
				r = intersectRayRay(ray.start, _delta, v1, v2.subtractNew(v1));
				if (r != null && r.ub >= 0.0 && r.ub <= 1.0 && r.ua >= 0)
				{
					if (r.ua < min_u) min_u = r.ua;
					if (r.ua > max_u) max_u = r.ua;
				}
			}
			
			if ((ray.isInfinite && min_u != Math.POSITIVE_INFINITY) || min_u <= 1.0)
			{
				if (rayData != null)
				{
					rayData.hitbox = polygon;
					rayData.ray = ray;
					rayData.start = min_u;
					rayData.end = max_u;
				}
				return true;
			}
		}
		return false;
	}
	
	public static function rayHitboxList(ray : FlxRay, hitboxList : FlxHitboxList, rayData : FlxRayData = null, updateTransform = true) : Bool
	{
		if (updateTransform)
			hitboxList.updateTransformed();
			
		var result = false;
		
		var tempRayData : FlxRayData = null;
		if (rayData != null)
		{
			rayData.start = Math.POSITIVE_INFINITY;
			tempRayData = new FlxRayData();
		}
		
		for (hitbox in hitboxList.members)
		{
			if (hitbox != hitboxList && hitbox.testRay(ray, tempRayData, false) && tempRayData.start < rayData.start) 
			{
				rayData.start = tempRayData.start;
				rayData.hitbox = tempRayData.hitbox;
				rayData.end = tempRayData.end;
				result = true;
			}
		}
		return result;
	}
	
	//Internal function, intersects two rays.
	private static function intersectRayRay(a:FlxVector, adelta:FlxVector, b:FlxVector, bdelta:FlxVector) : { ua:Float, ub:Float }
	{
		var d = bdelta.y * adelta.x - bdelta.x * adelta.y;
		
		if (d == 0.0) return null;
		
		var ua = (bdelta.x * (a.y - b.y) - bdelta.y * (a.x - b.x)) / d;
		var ub = (adelta.x * (a.y - b.y) - adelta.y * (a.x - b.x)) / d;
		
		return { ua : ua, ub : ub };
	}
	
	
		// Internal api - find the normal axis of a vert in the list at index
    private static function findNormalAxis(vertices:Array<FlxVector>, index:Int)
	{
        var vector1 = vertices[index];
        var vector2 = (index >= vertices.length - 1) ? vertices[0] : vertices[index + 1];
        
        _normalAxis.set(-(vector2.y - vector1.y), vector2.x - vector1.x);
		_normalAxis.normalize();
    }
}