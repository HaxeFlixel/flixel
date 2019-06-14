package;

import flixel.FlxG;
import flixel.math.FlxVector;

/**
 * The physics of light. Contains light bouncing and color combining.
 * @author MSGHero
 */
class Optics
{
	public static inline var MAX_REFLECTIONS:Int = 2; // the maximum number of times light will reflect off a surface
	public static inline var SPEED_OF_LIGHT:Int = 1000; // equivalent to 299,792,458 meters per second

	public static function getLightPath(firstRay:Segment, mirrors:Array<Segment>):Array<Segment>
	{
		var pathSegment:Segment = firstRay; // haven't found the endpoint of the segment yet, so it's a ray of light
		var closestIntersection:FlxVector = null;
		var tempIntersection = FlxVector.get();
		var intersectingVector:FlxVector = null;
		var minDist2:Float;
		var dist2:Float;
		var normal = FlxVector.get();

		var path:Array<Segment> = [];

		for (i in 0...MAX_REFLECTIONS + 1)
		{
			if (path.length == 0)
			{
				if (pathSegment.vector.isZero())
					break; // in case the user exactly clicks on the start position
			}
			else
			{
				// need the normal of the intersected segment to reflect off of
				// have to check if the left or right normal is appropriate:

				if (pathSegment.vector.dotProduct(intersectingVector.leftNormal(normal)) > 0)
				{
					intersectingVector.rightNormal(normal); // right normal is the correct one to use in this case, otherwise the left normal is correct
				}

				// new segment goes from the previous intersection point in the direction of the reflection
				var reflectVector = pathSegment.vector.clone().bounce(normal.normalize(), 1);
				if (reflectVector.isZero())
					break; // in case something weird happens
				pathSegment = new Segment(closestIntersection, reflectVector,
					pathSegment.color); // the color doesn't change between segments of the same light

				closestIntersection = null;
			}

			pathSegment.vector.length = FlxG.width + FlxG.height; // force the vector to intersect a mirror by making it really long
			minDist2 = Math.POSITIVE_INFINITY;

			// find the closest mirror segment that intersects the light segment
			for (mirror in mirrors)
			{
				pathSegment.findIntersection(mirror, tempIntersection);

				if (tempIntersection.isValid()) // // "if the segments intersect"
				{
					// find the intersection point closest to the segment's start point

					dist2 = pathSegment.start.distSquared(tempIntersection);

					// if the light has just reflected off an obstacle, there would be zero distance between the path and that obstacle, so ignore that obstacle
					if (dist2 < FlxVector.EPSILON_SQUARED)
						continue;

					// find the closest intersection by checking each squared distance
					if (closestIntersection == null)
					{
						intersectingVector = mirror.vector;
						closestIntersection = FlxVector.get(tempIntersection.x, tempIntersection.y);
						minDist2 = dist2;
					}
					else if (dist2 < minDist2)
					{
						intersectingVector = mirror.vector;
						closestIntersection.copyFrom(tempIntersection);
						minDist2 = dist2;
					}
				}
			}

			pathSegment.vector.set(closestIntersection.x - pathSegment.start.x,
				closestIntersection.y - pathSegment.start.y); // set the endpoint to be the intersection point/point of reflection

			path.push(pathSegment);
		}

		return path;
	}

	public static function combineColors(path:Array<Segment>, lights:Array<Segment>):Void
	{
		// look for any intersections with existing colors
		var tempIntersection = FlxVector.get();
		var segment:Segment;
		var i = 0;
		while (i < path.length)
		{
			segment = path[i];

			// the first intersection we come across in the array isn't guaranteed to be the first one the light actually comes across
			// (it is most of the time, but you can't rely on that)
			// so we go through each intersecting beam and pick the closest intersection, which is the first intersection

			var minLight:Segment = null,
				firstIntersection:FlxVector = null,
				minDist2:Float = Math.POSITIVE_INFINITY;

			for (light in lights)
			{
				if (segment.color & light.color > 0 && segment.color | light.color != Color.WHITE)
					continue; // ignore if the segments share color components, unless they make white

				segment.findIntersection(light, tempIntersection);

				// if the segments actually intersect
				if (tempIntersection.isValid())
				{
					// find the distance between the intersection point and the starting point, which is what we're trying to minimize
					var temp = tempIntersection.subtractNew(segment.start);
					var dist2 = temp.lengthSquared;
					temp.put();

					if (dist2 < minDist2)
					{
						minLight = light;
						firstIntersection = tempIntersection.clone();
						minDist2 = dist2;
					}
				}
			}

			// if we found an intersection
			if (minLight != null)
			{
				// from here on, the path will be a secondary color
				// so the current segment needs to be broken up into two: pre-intersect (primary color) and post-intersect (secondary color)
				// same thing goes with white/black (tertiary colors)

				var newColor = segment.color | minLight.color;

				var end = segment.getEnd();
				segment.setEnd(firstIntersection);

				var newSegment = new Segment(firstIntersection, FlxVector.get(), newColor);
				newSegment.setEnd(end);

				if (segment.vector.isZero())
				{
					// happens when the two segments are collinear, like if the user clicks twice without moving the mouse
					path[i] = newSegment; // in which case the combined-color segment should just replace the zero-length one
				}
				else
				{
					path.insert(i + 1, newSegment);
				}

				// update the rest of the path with the new color
				var oldIndex = i;
				while (++i < path.length)
				{
					path[i].color = newColor;
				}

				// ... but after the path changes color once, it could conceivably change color again (red intersect blue -> purple; purple intersect green -> white)
				// again, this almost never happens, but it _could_ happen in the last level, so we should deal with it
				// we deal with it by staying in the while loop instead of exiting early
				i = oldIndex;
			}

			++i;
		}

		tempIntersection.put();
	}
}
