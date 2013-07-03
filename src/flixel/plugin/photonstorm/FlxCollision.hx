package flixel.plugin.photonstorm;

import flash.display.BitmapData;
import flash.display.BlendMode;
import flash.geom.ColorTransform;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup;
import flixel.tile.FlxTileblock;
import flixel.util.FlxColor;
import flixel.util.FlxMath;
import flixel.util.FlxRect;

/**
 * FlxCollision
 *
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/
class FlxCollision 
{
	inline static public var CAMERA_WALL_OUTSIDE:Int = 0;
	inline static public var CAMERA_WALL_INSIDE:Int = 1;
	
	static public var debug:BitmapData = new BitmapData(1, 1, false);
	
	/**
	 * A Pixel Perfect Collision check between two FlxSprites.
	 * It will do a bounds check first, and if that passes it will run a pixel perfect match on the intersecting area.
	 * Works with rotated and animated sprites.
	 * It's extremly slow on cpp targets, so I don't recommend you to use it on them.
	 * Not working on neko target and awfully slows app down
	 * 
	 * @param	Contact			The first FlxSprite to test against
	 * @param	Target			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	AlphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 * @param	Camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * @return	Boolean True if the sprites collide, false if not
	 */
	static public function pixelPerfectCheck(Contact:FlxSprite, Target:FlxSprite, AlphaTolerance:Int = 255, ?Camera:FlxCamera):Bool
	{
		var pointA:Point = new Point();
		var pointB:Point = new Point();
		
		if (Camera != null)
		{
			pointA.x = Contact.x - Std.int(Camera.scroll.x * Contact.scrollFactor.x) - Contact.offset.x;
			pointA.y = Contact.y - Std.int(Camera.scroll.y * Contact.scrollFactor.y) - Contact.offset.y;
			
			pointB.x = Target.x - Std.int(Camera.scroll.x * Target.scrollFactor.x) - Target.offset.x;
			pointB.y = Target.y - Std.int(Camera.scroll.y * Target.scrollFactor.y) - Target.offset.y;
		}
		else
		{
			pointA.x = Contact.x - Std.int(FlxG.camera.scroll.x * Contact.scrollFactor.x) - Contact.offset.x;
			pointA.y = Contact.y - Std.int(FlxG.camera.scroll.y * Contact.scrollFactor.y) - Contact.offset.y;
			
			pointB.x = Target.x - Std.int(FlxG.camera.scroll.x * Target.scrollFactor.x) - Target.offset.x;
			pointB.y = Target.y - Std.int(FlxG.camera.scroll.y * Target.scrollFactor.y) - Target.offset.y;
		}
		
		#if flash
		var boundsA:Rectangle = new Rectangle(pointA.x, pointA.y, Contact.framePixels.width, Contact.framePixels.height);
		var boundsB:Rectangle = new Rectangle(pointB.x, pointB.y, Target.framePixels.width, Target.framePixels.height);
		#else
		var boundsA:Rectangle = new Rectangle(pointA.x, pointA.y, Contact.frameWidth, Contact.frameHeight);
		var boundsB:Rectangle = new Rectangle(pointB.x, pointB.y, Target.frameWidth, Target.frameHeight);
		#end
		
		var intersect:Rectangle = boundsA.intersection(boundsB);
		
		if (intersect.isEmpty() || intersect.width == 0 || intersect.height == 0)
		{
			return false;
		}
		
		//	Normalise the values or it'll break the BitmapData creation below
		intersect.x = Math.floor(intersect.x);
		intersect.y = Math.floor(intersect.y);
		intersect.width = Math.ceil(intersect.width);
		intersect.height = Math.ceil(intersect.height);
		
		if (intersect.isEmpty())
		{
			return false;
		}
		
		//	Thanks to Chris Underwood for helping with the translate logic :)
		var matrixA:Matrix = new Matrix();
		matrixA.translate(-(intersect.x - boundsA.x), -(intersect.y - boundsA.y));
		
		var matrixB:Matrix = new Matrix();
		matrixB.translate(-(intersect.x - boundsB.x), -(intersect.y - boundsB.y));
		
		#if !flash
		Contact.drawFrame();
		Target.drawFrame();
		#end
		
		var testA:BitmapData = Contact.framePixels;
		var testB:BitmapData = Target.framePixels;
		var overlapArea:BitmapData = new BitmapData(Std.int(intersect.width), Std.int(intersect.height), false);
		
		#if flash
		overlapArea.draw(testA, matrixA, new ColorTransform(1, 1, 1, 1, 255, -255, -255, AlphaTolerance), BlendMode.NORMAL);
		overlapArea.draw(testB, matrixB, new ColorTransform(1, 1, 1, 1, 255, 255, 255, AlphaTolerance), BlendMode.DIFFERENCE);
		#else
		
		// TODO: try to fix this method for neko target
		var overlapWidth:Int = overlapArea.width;
		var overlapHeight:Int = overlapArea.height;
		var targetX:Int;
		var targetY:Int;
		var pixelColor:Int;
		var pixelAlpha:Int;
		var transformedAlpha:Int;
		var maxX:Int = testA.width + 1;
		var maxY:Int = testA.height + 1;
		
		for (i in 0...maxX)
		{
			targetX = Math.floor(i + matrixA.tx);
			
			if (targetX >= 0 && targetX < maxX)
			{
				for (j in 0...maxY)
				{
					targetY = Math.floor(j + matrixA.ty);
					
					if (targetY >= 0 && targetY < maxY)
					{
						pixelColor = testA.getPixel32(i, j);
						pixelAlpha = (pixelColor >> 24) & 0xFF;
						
						if (pixelAlpha >= AlphaTolerance)
						{
							overlapArea.setPixel32(targetX, targetY, 0xffff0000);
						}
						else
						{
							overlapArea.setPixel32(targetX, targetY, FlxColor.WHITE);
						}
					}
				}
			}
		}

		maxX = testB.width + 1;
		maxY = testB.height + 1;
		var secondColor:Int;
		
		for (i in 0...maxX)
		{
			targetX = Math.floor(i + matrixB.tx);
			
			if (targetX >= 0 && targetX < maxX)
			{
				for (j in 0...maxY)
				{
					targetY = Math.floor(j + matrixB.ty);
					
					if (targetY >= 0 && targetY < maxY)
					{
						pixelColor = testB.getPixel32(i, j);
						pixelAlpha = (pixelColor >> 24) & 0xFF;
						
						if (pixelAlpha >= AlphaTolerance)
						{
							secondColor = overlapArea.getPixel32(targetX, targetY);
							
							if (secondColor == 0xffff0000)
							{
								overlapArea.setPixel32(targetX, targetY, 0xff00ffff);
							}
							else
							{
								overlapArea.setPixel32(targetX, targetY, 0x00000000);
							}
						}
					}
				}
			}
		}
		
		#end
		
		// Developers: If you'd like to see how this works enable the debugger and display it in your game somewhere.
		debug = overlapArea;
		
		var overlap:Rectangle = overlapArea.getColorBoundsRect(0xffffffff, 0xff00ffff);
		overlap.offset(intersect.x, intersect.y);
		
		if (overlap.isEmpty())
		{
			return false;
		}
		else
		{
			return true;
		}
		
		return false;
	}
	
	/**
	 * A Pixel Perfect Collision check between a given x/y coordinate and an FlxSprite<br>
	 * 
	 * @param	PointX			The x coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	PointY			The y coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	Target			The FlxSprite to check the point against
	 * @param	AlphaTolerance	The alpha tolerance level above which pixels are counted as colliding. Default to 255 (must be fully transparent for collision)
	 * @return	Boolean True if the x/y point collides with the FlxSprite, false if not
	 */
	static public function pixelPerfectPointCheck(PointX:Int, PointY:Int, Target:FlxSprite, AlphaTolerance:Int = 255):Bool
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
		pixelAlpha = FlxColor.getAlpha(test.getPixel32(Math.floor(PointX - Target.x), Math.floor(PointY - Target.y)));
		
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
	static public function createCameraWall(Camera:FlxCamera, Placement:Int, Thickness:Int, AdjustWorldBounds:Bool = false):FlxGroup
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
					FlxG.worldBounds = new FlxRect(Camera.x - Thickness, Camera.y - Thickness, Camera.width + Thickness * 2, Camera.height + Thickness * 2);
				}
			case FlxCollision.CAMERA_WALL_INSIDE:
				left = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				right = new FlxTileblock(Math.floor(Camera.x + Camera.width - Thickness), Math.floor(Camera.y + Thickness), Thickness, Camera.height - (Thickness * 2));
				top = new FlxTileblock(Math.floor(Camera.x), Math.floor(Camera.y), Camera.width, Thickness);
				bottom = new FlxTileblock(Math.floor(Camera.x), Camera.height - Thickness, Camera.width, Thickness);
				
				if (AdjustWorldBounds)
				{
					FlxG.worldBounds = new FlxRect(Camera.x, Camera.y, Camera.width, Camera.height);
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