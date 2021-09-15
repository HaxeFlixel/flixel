package flixel.util;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.math.FlxVector;
import flixel.math.FlxMatrix;
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
	static var pointA:FlxVector = new FlxVector();
	static var pointB:FlxVector = new FlxVector();
	static var centerA:FlxVector = new FlxVector();
	static var centerB:FlxVector = new FlxVector();
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
	 * @param	Contact			The first FlxSprite to test against
	 * @param	Target			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	AlphaTolerance	The tolerance value above which alpha pixels are included. Default to 1 (anything that is not fully invisible).
	 * @param	Camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return	Whether the sprites collide
	 */
	public static function pixelPerfectCheck(Contact:FlxSprite, Target:FlxSprite, AlphaTolerance:Int = 1, ?Camera:FlxCamera):Bool
	{
		// if either of the angles are non-zero, consider the angles of the sprites in the pixel check
		var advanced = (Contact.angle != 0) || (Target.angle != 0)
			|| Contact.scale.x != 1 || Contact.scale.y != 1
			|| Target.scale.x != 1 || Target.scale.y != 1;

		Contact.getScreenBounds(boundsA, Camera);
		Target.getScreenBounds(boundsB, Camera);

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

		Contact.drawFrame();
		Target.drawFrame();

		var testA:BitmapData = Contact.framePixels;
		var testB:BitmapData = Target.framePixels;

		var overlapWidth:Int = Std.int(intersect.width);
		var overlapHeight:Int = Std.int(intersect.height);

		// More complicated case, if either of the sprites is rotated
		if (advanced)
		{
			testMatrix.identity();

			// translate the matrix to the center of the sprite
			testMatrix.translate(-Contact.origin.x, -Contact.origin.y);

			// rotate the matrix according to angle
			testMatrix.rotate(Contact.angle * FlxAngle.TO_RAD);
			testMatrix.scale(Contact.scale.x, Contact.scale.y);

			// translate it back!
			testMatrix.translate(boundsA.width / 2, boundsA.height / 2);
			

			// prepare an empty canvas
			var testA2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsA.width), Math.floor(boundsA.height), true, FlxColor.TRANSPARENT, false);

			// plot the sprite using the matrix
			testA2.draw(testA, testMatrix, null, null, null, false);
			testA = testA2;

			// (same as above)
			testMatrix.identity();
			testMatrix.translate(-Target.origin.x, -Target.origin.y);
			testMatrix.rotate(Target.angle * FlxAngle.TO_RAD);
			testMatrix.scale(Target.scale.x, Target.scale.y);
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

		// Analyze overlapping area of BitmapDatas to check for a collision (alpha values >= AlphaTolerance)
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

			if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance)
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

				if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance)
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
	 * A Pixel Perfect Collision check between a given x/y coordinate and an FlxSprite
	 *
	 * @param	PointX			The x coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	PointY			The y coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	Target			The FlxSprite to check the point against
	 * @param	AlphaTolerance	The alpha tolerance level above which pixels are counted as colliding. Default to 1 (anything that is not fully invisible).
	 * @return	Boolean True if the x/y point collides with the FlxSprite, false if not
	 */
	public static function pixelPerfectPointCheck(PointX:Int, PointY:Int, Target:FlxSprite, AlphaTolerance:Int = 1):Bool
	{
		// Intersect check
		if (!FlxMath.pointInCoordinates(PointX, PointY, Math.floor(Target.x), Math.floor(Target.y), Std.int(Target.width), Std.int(Target.height)))
		{
			return false;
		}

		if (FlxG.renderTile)
		{
			Target.drawFrame();
		}

		// How deep is pointX/Y within the rect?
		var test:BitmapData = Target.framePixels;

		var pixelAlpha = FlxColor.fromInt(test.getPixel32(Math.floor(PointX - Target.x), Math.floor(PointY - Target.y))).alpha;

		if (FlxG.renderTile)
		{
			pixelAlpha = Std.int(pixelAlpha * Target.alpha);
		}

		// How deep is pointX/Y within the rect?
		return pixelAlpha >= AlphaTolerance;
	}

	/**
	 * Creates a "wall" around the given camera which can be used for FlxSprite collision
	 *
	 * @param	Camera				The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
	 * @param	Placement			Whether to place the camera wall outside or inside
	 * @param	Thickness			The thickness of the wall in pixels
	 * @param	AdjustWorldBounds	Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
	 * @return	FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
	 */
	public static function createCameraWall(Camera:FlxCamera, PlaceOutside:Bool = true, Thickness:Int, AdjustWorldBounds:Bool = false):FlxGroup
	{
		var left:FlxTileblock = null;
		var right:FlxTileblock = null;
		var top:FlxTileblock = null;
		var bottom:FlxTileblock = null;

		if (PlaceOutside)
		{
			left = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			right = new FlxTileblock(Math.floor(Camera.x + Camera.width), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			top = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y - Thickness), Camera.width + Thickness * 2, Thickness);
			bottom = new FlxTileblock(Math.floor(Camera.x - Thickness), Camera.height, Camera.width + Thickness * 2, Thickness);

			if (AdjustWorldBounds)
			{
				FlxG.worldBounds.set(Camera.x - Thickness, Camera.y - Thickness, Camera.width + Thickness * 2, Camera.height + Thickness * 2);
			}
		}
		else
		{
			left = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
			right = new FlxTileblock(Math.floor(Camera.x + Camera.width - Thickness), Math.floor(Camera.y + Thickness), Thickness,
				Camera.height - (Thickness * 2));
			top = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y), Camera.width, Thickness);
			bottom = new FlxTileblock(Math.floor(Camera.x), Camera.height - Thickness, Camera.width, Thickness);

			if (AdjustWorldBounds)
			{
				FlxG.worldBounds.set(Camera.x, Camera.y, Camera.width, Camera.height);
			}
		}

		var result = new FlxGroup();

		result.add(left);
		result.add(right);
		result.add(top);
		result.add(bottom);

		return result;
	}
}
