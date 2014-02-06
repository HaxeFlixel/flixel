package flixel.util;

import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTileblock;

/**
 * FlxCollision
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/
class FlxCollision 
{
	public static inline var CAMERA_WALL_OUTSIDE:Int = 0;
	public static inline var CAMERA_WALL_INSIDE:Int = 1;
	
	// Optimization: Local static vars to reduce allocations
	private static var pointA:Point = new Point();
	private static var pointB:Point = new Point();
	private static var centerA:Point = new Point();
	private static var centerB:Point = new Point();
	private static var matrixA:Matrix = new Matrix();
	private static var matrixB:Matrix = new Matrix();
	private static var testMatrix:Matrix = new Matrix();
	private static var boundsA:Rectangle = new Rectangle();
	private static var boundsB:Rectangle = new Rectangle();
	
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
		//if either of the angles are non-zero, consider the angles of the sprites in the pixel check
		var considerRotation:Bool = (Contact.angle != 0) || (Target.angle != 0);
		
		Camera = (Camera != null) ? Camera : FlxG.camera;
		
		pointA.x = Contact.x - Std.int(Camera.scroll.x * Contact.scrollFactor.x) - Contact.offset.x;
		pointA.y = Contact.y - Std.int(Camera.scroll.y * Contact.scrollFactor.y) - Contact.offset.y;
		
		pointB.x = Target.x - Std.int(Camera.scroll.x * Target.scrollFactor.x) - Target.offset.x;
		pointB.y = Target.y - Std.int(Camera.scroll.y * Target.scrollFactor.y) - Target.offset.y;
		
		if (considerRotation)
		{
			// find the center of both sprites
			centerA.setTo(Contact.origin.x, Contact.origin.y);
			centerB.setTo(Target.origin.x, Target.origin.y);			
			
			// now make a bounding box that allows for the sprite to be rotated in 360 degrees
			boundsA.x = (pointA.x + centerA.x - centerA.length);
			boundsA.y = (pointA.y + centerA.y - centerA.length);
			boundsA.width = centerA.length * 2;
			boundsA.height = boundsA.width;
			
			boundsB.x = (pointB.x + centerB.x - centerB.length);
			boundsB.y = (pointB.y + centerB.y - centerB.length);
			boundsB.width = centerB.length * 2;
			boundsB.height = boundsB.width;
		}
		else
		{
			boundsA.x = pointA.x;
			boundsA.y = pointA.y;
			boundsA.width = Contact.frameWidth;
			boundsA.height = Contact.frameHeight;
			
			boundsB.x = pointB.x;
			boundsB.y = pointB.y;
			boundsB.width = Target.frameWidth;
			boundsB.height = Target.frameHeight;
		}
		
		var intersect:Rectangle = boundsA.intersection(boundsB);
		
		if (intersect.isEmpty() || intersect.width < 1 || intersect.height < 1)
		{
			return false;
		}
		
		//	Thanks to Chris Underwood for helping with the translate logic :)
		matrixA.identity();
		matrixA.translate(-(intersect.x - boundsA.x), -(intersect.y - boundsA.y));
		
		matrixB.identity();
		matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));
		
	#if !flash
		Contact.drawFrame();
		Target.drawFrame();
	#end
		
		var testA:BitmapData = Contact.framePixels;
		var testB:BitmapData = Target.framePixels;
		
		var overlapWidth:Int = Std.int(intersect.width);
		var overlapHeight:Int = Std.int(intersect.height);
		
		// More complicated case, if either of the sprites is rotated
		if (considerRotation)
		{
			testMatrix.identity();
			
			// translate the matrix to the center of the sprite
			testMatrix.translate(-Contact.origin.x, -Contact.origin.y);
			
			// rotate the matrix according to angle
			testMatrix.rotate(Contact.angle * FlxAngle.TO_RAD);
			
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
			testMatrix.translate(boundsB.width / 2, boundsB.height / 2);
			
			var testB2:BitmapData = FlxBitmapDataPool.get(Math.floor(boundsB.width), Math.floor(boundsB.height), true, FlxColor.TRANSPARENT, false);
			testB2.draw(testB, testMatrix, null, null, null, false);
			testB = testB2;
		}
		
		boundsA.x = Std.int(-matrixA.tx);
		boundsA.y = Std.int( -matrixA.ty);
		boundsA.width = overlapWidth;
		boundsA.height = overlapHeight;
		
		boundsB.x = Std.int(-matrixB.tx);
		boundsB.y = Std.int(-matrixB.ty);
		boundsB.width = overlapWidth;
		boundsB.height = overlapHeight;
		
		var pixelsA = testA.getPixels(boundsA);
		var pixelsB = testB.getPixels(boundsB);
		
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
			alphaA = pixelsA[alphaIdx];
			alphaB = pixelsB[alphaIdx];
			if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance) 
			{
				hit = true;
				break; 
			}
		}
		
		if (!hit) {
			// check odd pixels
			for (i in 0...overlapPixels >> 1) 
			{
				alphaIdx = (i << 3) + 4;
				alphaA = pixelsA[alphaIdx];
				alphaB = pixelsB[alphaIdx];
				if (alphaA >= AlphaTolerance && alphaB >= AlphaTolerance) 
				{
					hit = true;
					break; 
				}
			}
		}
		
		if (considerRotation) 
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
		if (FlxMath.pointInCoordinates(PointX, PointY, Math.floor(Target.x), Math.floor(Target.y), Std.int(Target.width), Std.int(Target.height)) == false)
		{
			return false;
		}
		
		#if flash
		// How deep is pointX/Y within the rect?
		var test:BitmapData = Target.framePixels;
		#else
		var test:BitmapData = Target.getFlxFrameBitmapData();
		#end
		
		var pixelAlpha:Int = 0;  
		pixelAlpha = FlxColorUtil.getAlpha(test.getPixel32(Math.floor(PointX - Target.x), Math.floor(PointY - Target.y)));
		
		#if !flash
		pixelAlpha = Std.int(pixelAlpha * Target.alpha);
		#end
		
		// How deep is pointX/Y within the rect?
		if (pixelAlpha >= AlphaTolerance)
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	
	/**
	 * Creates a "wall" around the given camera which can be used for FlxSprite collision
	 * 
	 * @param	Camera				The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
	 * @param	Placement			CAMERA_WALL_OUTSIDE or CAMERA_WALL_INSIDE
	 * @param	Thickness			The thickness of the wall in pixels
	 * @param	AdjustWorldBounds	Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
	 * @return	FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
	 */
	public static function createCameraWall(Camera:FlxCamera, Placement:Int, Thickness:Int, AdjustWorldBounds:Bool = false):FlxGroup
	{
		var left:FlxTileblock = null;
		var right:FlxTileblock = null;
		var top:FlxTileblock = null;
		var bottom:FlxTileblock = null;
		
		switch (Placement)
		{
			case FlxCollision.CAMERA_WALL_OUTSIDE:
				left = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				right = new FlxTileblock(Math.floor(Camera.x + Camera.width), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				top = new FlxTileblock(Math.floor(Camera.x - Thickness), Math.floor(Camera.y - Thickness), Camera.width + Thickness * 2, Thickness);
				bottom = new FlxTileblock(Math.floor(Camera.x - Thickness), Camera.height, Camera.width + Thickness * 2, Thickness);
				
				if (AdjustWorldBounds)
				{
					FlxG.worldBounds.set(Camera.x - Thickness, Camera.y - Thickness, Camera.width + Thickness * 2, Camera.height + Thickness * 2);
				}
			case FlxCollision.CAMERA_WALL_INSIDE:
				left = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				right = new FlxTileblock(Math.floor(Camera.x + Camera.width - Thickness), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				top = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y), Camera.width, Thickness);
				bottom = new FlxTileblock(Math.floor(Camera.x), Camera.height - Thickness, Camera.width, Thickness);
				
				if (AdjustWorldBounds)
				{
					FlxG.worldBounds.set(Camera.x, Camera.y, Camera.width, Camera.height);
				}
		}
		
		var result:FlxGroup = new FlxGroup(4);
		
		result.add(left);
		result.add(right);
		result.add(top);
		result.add(bottom);
		
		return result;
	}
}