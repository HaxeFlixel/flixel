package flixel.util;

import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxMatrix;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.tile.FlxTileblock;

/**
 * FlxCollision
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
 */
class FlxCollision
{
	// Optimization: Local static vars to reduce allocations
	static var pointA:FlxPoint = new FlxPoint();
	static var pointB:FlxPoint = new FlxPoint();
	static var centerA:FlxPoint = new FlxPoint();
	static var centerB:FlxPoint = new FlxPoint();
	static var matrixA:FlxMatrix = new FlxMatrix();
	static var matrixB:FlxMatrix = new FlxMatrix();
	static var testMatrix:FlxMatrix = new FlxMatrix();
	static var boundsA:FlxRect = new FlxRect();
	static var boundsB:FlxRect = new FlxRect();
	static var intersect:FlxRect = new FlxRect();
	static var flashRect:Rectangle = new Rectangle();

	/**
	 * A Pixel Perfect Collision check between two FlxSprites. It will do a bounds check first, and if that passes it will run a
	 * pixel perfect match on the intersecting area. Works with rotated and animated sprites. May be slow, so use it sparingly.
	 *
	 * @param   contact         The first FlxSprite to test against
	 * @param   target          The second FlxSprite to test again, sprite order is irrelevant
	 * @param   alphaTolerance  The tolerance value above which alpha pixels are included. Default to 1 (anything that is not fully invisible).
	 * @param   camera          If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return  Whether the sprites collide
	 */
	public static function pixelPerfectCheck(contact:FlxSprite, target:FlxSprite, alphaTolerance:Int = 1, ?camera:FlxCamera):Bool
	{
		// if either of the angles are non-zero, consider the angles of the sprites in the pixel check
		final advanced = contact.angle != 0 || target.angle != 0
			|| contact.scale.x != 1 || contact.scale.y != 1
			|| target.scale.x != 1 || target.scale.y != 1;

		contact.getScreenBounds(boundsA, camera);
		target.getScreenBounds(boundsB, camera);

		boundsA.intersection(boundsB, intersect.set());

		if (intersect.isEmpty || intersect.width < 1 || intersect.height < 1)
		{
			return false;
		}

		//	Thanks to Chris Underwood for helping with the translate logic :)
		matrixA.identity();
		matrixA.translate(-(intersect.x - boundsA.x), -(intersect.y - boundsA.y));

		matrixB.identity();
		matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));

		contact.drawFrame();
		target.drawFrame();

		var testA:BitmapData = contact.framePixels;
		var testB:BitmapData = target.framePixels;

		var overlapWidth:Int = Std.int(intersect.width);
		var overlapHeight:Int = Std.int(intersect.height);

		// More complicated case, if either of the sprites is rotated
		if (advanced)
		{
			testMatrix.identity();

			// translate the matrix to the center of the sprite
			testMatrix.translate(-contact.origin.x, -contact.origin.y);

			// rotate the matrix according to angle
			testMatrix.rotate(contact.angle * FlxAngle.TO_RAD);
			testMatrix.scale(contact.scale.x, contact.scale.y);

			// translate it back!
			testMatrix.translate(boundsA.width / 2, boundsA.height / 2);

			// prepare an empty canvas
			var testA2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsA.width), Math.floor(boundsA.height), true, FlxColor.TRANSPARENT, false);

			// plot the sprite using the matrix
			testA2.draw(testA, testMatrix, null, null, null, false);
			testA = testA2;

			// (same as above)
			testMatrix.identity();
			testMatrix.translate(-target.origin.x, -target.origin.y);
			testMatrix.rotate(target.angle * FlxAngle.TO_RAD);
			testMatrix.scale(target.scale.x, target.scale.y);
			testMatrix.translate(boundsB.width / 2, boundsB.height / 2);

			var testB2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsB.width), Math.floor(boundsB.height), true, FlxColor.TRANSPARENT, false);
			testB2.draw(testB, testMatrix, null, null, null, false);
			testB = testB2;
		}

		boundsA.x = Std.int(-matrixA.tx);
		boundsA.y = Std.int(-matrixA.ty);
		boundsA.width = overlapWidth;
		boundsA.height = overlapHeight;

		boundsB.x = Std.int(-matrixB.tx);
		boundsB.y = Std.int(-matrixB.ty);
		boundsB.width = overlapWidth;
		boundsB.height = overlapHeight;

		boundsA.copyToFlash(flashRect);
		var pixelsA = testA.getPixels(flashRect);

		boundsB.copyToFlash(flashRect);
		var pixelsB = testB.getPixels(flashRect);

		var hit = false;

		// Analyze overlapping area of BitmapDatas to check for a collision (alpha values >= alphaTolerance)
		var alphaA:Int = 0;
		var alphaB:Int = 0;
		var overlapPixels:Int = overlapWidth * overlapHeight;
		var alphaIdx:Int = 0;

		// check even pixels
		for (i in 0...Math.ceil(overlapPixels / 2))
		{
			alphaIdx = i << 3;
			pixelsA.position = pixelsB.position = alphaIdx;
			alphaA = pixelsA.readUnsignedByte();
			alphaB = pixelsB.readUnsignedByte();

			if (alphaA >= alphaTolerance && alphaB >= alphaTolerance)
			{
				hit = true;
				break;
			}
		}

		if (!hit)
		{
			// check odd pixels
			for (i in 0...overlapPixels >> 1)
			{
				alphaIdx = (i << 3) + 4;
				pixelsA.position = pixelsB.position = alphaIdx;
				alphaA = pixelsA.readUnsignedByte();
				alphaB = pixelsB.readUnsignedByte();

				if (alphaA >= alphaTolerance && alphaB >= alphaTolerance)
				{
					hit = true;
					break;
				}
			}
		}

		if (advanced)
		{
			FlxBitmapDataPool.put(testA);
			FlxBitmapDataPool.put(testB);
		}

		return hit;
	}

	/**
	 * Checks to see if a point in 2D world space overlaps this `FlxSprite` object's
	 * current displayed pixels. This check is ALWAYS made in screen space, and
	 * factors in `scale`, `angle`, `offset`, `origin`, and `scrollFactor`.
	 *
	 * @param   worldX          The x coordinate of the point given in world space
	 * @param   worldY          The y coordinate of the point given in world space
	 * @param   sprite          The FlxSprite to check the point against
	 * @param   alphaTolerance  The alpha tolerance for with pixels are considered "solid".
	 *                          Defaults to 1 (anything that is not fully invisible).
	 * @return  Whether the x/y point overlaps with the sprite, false if not
	 */
	@:deprecated("Use sprite.pixelsOverlapPoint instead")
	public static function pixelPerfectPointCheck(worldX:Int, worldY:Int, target:FlxSprite, alphaTolerance = 1):Bool
	{
		if (FlxG.renderTile)
			target.drawFrame();
		
		return target.pixelsOverlapPoint(FlxPoint.weak(worldX, worldY), alphaTolerance);
	}

	/**
	 * Creates a "wall" around the given camera which can be used for FlxSprite collision
	 *
	 * @param   camera             The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
	 * @param   placeOutside       Whether to place the camera wall outside or inside
	 * @param   thickness          The thickness of the wall in pixels
	 * @param   adjustWorldBounds  Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
	 * @return  FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
	 */
	public static function createCameraWall(camera:FlxCamera, placeOutside = true, thickness:Int, adjustWorldBounds = false):FlxGroup
	{
		var left:FlxTileblock = null;
		var right:FlxTileblock = null;
		var top:FlxTileblock = null;
		var bottom:FlxTileblock = null;

		if (placeOutside)
		{
			left = new FlxTileblock(Math.floor(camera.x - thickness), Math.floor(camera.y), thickness, camera.height);
			right = new FlxTileblock(Math.floor(camera.x + camera.width), Math.floor(camera.y), thickness, camera.height);
			top = new FlxTileblock(Math.floor(camera.x - thickness), Math.floor(camera.y - thickness), camera.width + thickness * 2, thickness);
			bottom = new FlxTileblock(Math.floor(camera.x - thickness), camera.height, camera.width + thickness * 2, thickness);

			if (adjustWorldBounds)
			{
				FlxG.worldBounds.set(camera.x - thickness, camera.y - thickness, camera.width + thickness * 2, camera.height + thickness * 2);
			}
		}
		else
		{
			left = new FlxTileblock(Math.floor(camera.x), Math.floor(camera.y + thickness), thickness, camera.height - (thickness * 2));
			right = new FlxTileblock(Math.floor(camera.x + camera.width - thickness), Math.floor(camera.y + thickness), thickness,
				camera.height - (thickness * 2));
			top = new FlxTileblock(Math.floor(camera.x), Math.floor(camera.y), camera.width, thickness);
			bottom = new FlxTileblock(Math.floor(camera.x), camera.height - thickness, camera.width, thickness);

			if (adjustWorldBounds)
			{
				FlxG.worldBounds.set(camera.x, camera.y, camera.width, camera.height);
			}
		}

		var result = new FlxGroup();

		result.add(left);
		result.add(right);
		result.add(top);
		result.add(bottom);

		return result;
	}

	/**
	 * Calculates at which point where the given line, from start to end, first enters the rect.
	 * If the line starts inside the rect, a copy of start is returned.
	 * If the line never enters the rect, null is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the rect, null is returned
	 * and the supplied result is unchanged
	 * @since 5.0.0
	 *
	 * @param rect    The rect being entered
	 * @param start   The start of the line
	 * @param end     The end of the line
	 * @param result  Optional result vector, to avoid creating a new instance to be returned.
	 *                Only returned if the line enters the rect.
	 * @return The point of entry of the line into the rect, if possible.
	 */
	public static function calcRectEntry(rect:FlxRect, start:FlxPoint, end:FlxPoint, ?result:FlxPoint):Null<FlxPoint>
	{
		// We must ensure that weak refs are placed back in the pool
		inline function putWeakRefs()
		{
			start.putWeak();
			end.putWeak();
			rect.putWeak();
		}

		// helper to create a new instance if needed, when needed.
		// this allows us to return a value at any point and still put weak refs.
		// otherwise this would be a fragile mess of if-elses
		function getResult(x:Float, y:Float)
		{
			if (result == null)
				result = FlxPoint.get(x, y);
			else
				result.set(x, y);

			putWeakRefs();
			return result;
		}

		function nullResult()
		{
			putWeakRefs();
			return null;
		}

		// does the ray start inside the bounds
		if (rect.containsPoint(start))
			return getResult(start.x, start.y);

		// are both points above, below, left or right of the bounds
		if ((start.y < rect.top    && end.y < rect.top   )
		||  (start.y > rect.bottom && end.y > rect.bottom)
		||  (start.x > rect.right  && end.x > rect.right )
		||  (start.x < rect.left   && end.x < rect.left) )
		{
			return nullResult();
		}

		// check for purely vertical, i.e. has infinite slope
		if (start.x == end.x)
		{
			// determine if it exits top or bottom
			if (start.y < rect.top)
				return getResult(start.x, rect.top);

			return getResult(start.x, rect.bottom);
		}

		// Use y = mx + b formula to define out line, m = slope, b is y when x = 0
		var m = (start.y - end.y) / (start.x - end.x);
		// y - mx = b
		var b = start.y - m * start.x;
		// y = mx + b
		var leftY = m * rect.left + b;
		var rightY = m * rect.right + b;

		// if left and right intercepts are both above and below, there is no entry
		if ((leftY < rect.top && rightY < rect.top) || (leftY > rect.bottom && rightY > rect.bottom))
			return nullResult();

		// if ray moves right
		else if (start.x < end.x)
		{
			if (leftY < rect.top)
			{
				// ray exits on top
				// x = (y - b)/m
				return getResult((rect.top - b) / m, rect.top);
			}

			if (leftY > rect.bottom)
			{
				// ray exits on bottom
				// x = (y - b)/m
				return getResult((rect.bottom - b) / m, rect.bottom);
			}

			// ray exits to the left
			return getResult(rect.left, leftY);
		}

		// if ray moves left
		if (rightY < rect.top)
		{
			// ray exits on top
			// x = (y - b)/m
			return getResult((rect.top - b) / m, rect.top);
		}

		if (rightY > rect.bottom)
		{
			// ray exits on bottom
			// x = (y - b)/m
			return getResult((rect.bottom - b) / m, rect.bottom);
		}

		// ray exits to the right
		return getResult(rect.right, rightY);
	}

	/**
	 * Calculates at which point where the given line, from start to end, was last inside the rect.
	 * If the line ends inside the rect, a copy of end is returned.
	 * If the line is never inside the rect, null is returned.
	 *
	 * Note: If a result vector is supplied and the line is outside the rect, null is returned
	 * and the supplied result is unchanged
	 * @since 5.0.0
	 *
	 * @param rect    The rect being exited
	 * @param start   The start of the line
	 * @param end     The end of the line
	 * @param result  Optional result vector, to avoid creating a new instance to be returned.
	 *                Only returned if the line enters the rect.
	 * @return The point of exit of the line from the rect, if possible.
	 */
	public static inline function calcRectExit(rect, start, end, result)
	{
		return calcRectEntry(rect, end, start, result);
	}
}
