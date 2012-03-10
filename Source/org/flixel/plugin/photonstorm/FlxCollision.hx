/**
 * FlxCollision
 * -- Part of the Flixel Power Tools set
 * 
 * v1.6 Fixed bug in pixelPerfectCheck that stopped non-square rotated objects from colliding properly (thanks to joon on the flixel forums for spotting)
 * v1.5 Added createCameraWall
 * v1.4 Added pixelPerfectPointCheck()
 * v1.3 Update fixes bug where it wouldn't accurately perform collision on AutoBuffered rotated sprites, or sprites with offsets
 * v1.2 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.6 - October 8th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;

import nme.display.BitmapData;
import nme.display.Sprite;
import nme.geom.ColorTransform;
import nme.geom.Matrix;
import nme.geom.Point;
import nme.geom.Rectangle;
import nme.display.BlendMode;
import org.flixel.FlxCamera;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxRect;
import org.flixel.FlxSprite;
import org.flixel.FlxTileblock;
import org.flixel.plugin.photonstorm.FlxColor;

class FlxCollision 
{
	public static var debug:BitmapData = new BitmapData(1, 1, false);
	
	#if flash
	public static var CAMERA_WALL_OUTSIDE:UInt = 0;
	public static var CAMERA_WALL_INSIDE:UInt = 1;
	#else
	public static var CAMERA_WALL_OUTSIDE:Int = 0;
	public static var CAMERA_WALL_INSIDE:Int = 1;
	#end
	
	public function new() 
	{
		
	}
	
	/**
	 * A Pixel Perfect Collision check between two FlxSprites.
	 * It will do a bounds check first, and if that passes it will run a pixel perfect match on the intersecting area.
	 * Works with rotated, scaled and animated sprites.
	 * Not working on cpp target (need further investigation) plus it's extremly slow on cpp targets, so I don't recommend you to use it with them.
	 * 
	 * @param	contact			The first FlxSprite to test against
	 * @param	target			The second FlxSprite to test again, sprite order is irrelevant
	 * @param	alphaTolerance	The tolerance value above which alpha pixels are included. Default to 255 (must be fully opaque for collision).
	 * @param	camera			If the collision is taking place in a camera other than FlxG.camera (the default/current) then pass it here
	 * 
	 * @return	Boolean True if the sprites collide, false if not
	 */
	public static function pixelPerfectCheck(contact:FlxSprite, target:FlxSprite, ?alphaTolerance:Int = 255, ?camera:FlxCamera = null):Bool
	{
		var pointA:Point = new Point();
		var pointB:Point = new Point();
		
		if (camera != null)
		{
			pointA.x = contact.x - Std.int(camera.scroll.x * contact.scrollFactor.x) - contact.offset.x;
			pointA.y = contact.y - Std.int(camera.scroll.y * contact.scrollFactor.y) - contact.offset.y;
			
			pointB.x = target.x - Std.int(camera.scroll.x * target.scrollFactor.x) - target.offset.x;
			pointB.y = target.y - Std.int(camera.scroll.y * target.scrollFactor.y) - target.offset.y;
		}
		else
		{
			pointA.x = contact.x - Std.int(FlxG.camera.scroll.x * contact.scrollFactor.x) - contact.offset.x;
			pointA.y = contact.y - Std.int(FlxG.camera.scroll.y * contact.scrollFactor.y) - contact.offset.y;
			
			pointB.x = target.x - Std.int(FlxG.camera.scroll.x * target.scrollFactor.x) - target.offset.x;
			pointB.y = target.y - Std.int(FlxG.camera.scroll.y * target.scrollFactor.y) - target.offset.y;
		}
		
		var boundsA:Rectangle = new Rectangle(pointA.x, pointA.y, contact.framePixels.width, contact.framePixels.height);
		var boundsB:Rectangle = new Rectangle(pointB.x, pointB.y, target.framePixels.width, target.framePixels.height);
		
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
		
		#if cpp
		contact.drawFrame();
		target.drawFrame();
		#end
		
		var testA:BitmapData = contact.framePixels;
		var testB:BitmapData = target.framePixels;
		var overlapArea:BitmapData = new BitmapData(Math.floor(intersect.width), Math.floor(intersect.height), false);
		
		#if flash
		overlapArea.draw(testA, matrixA, new ColorTransform(1, 1, 1, 1, 255, -255, -255, alphaTolerance), BlendMode.NORMAL);
		overlapArea.draw(testB, matrixB, new ColorTransform(1, 1, 1, 1, 255, 255, 255, alphaTolerance), BlendMode.DIFFERENCE);
		#else
		var overlapWidth:Int = overlapArea.width;
		var overlapHeight:Int = overlapArea.height;
		var targetX:Int;
		var targetY:Int;
		var pixelColor:Int;
		var pixelAlpha:Int;
		var transformedAlpha:Int;
		var maxX:Int = testA.width + 1;
		var maxY:Int = testA.height + 1;
		for (i in 0...(maxX))
		{
			targetX = Math.floor(i + matrixA.tx);
			if (targetX < maxX)
			{
				for (j in 0...(maxY))
				{
					targetY = Math.floor(j + matrixA.ty);
					if (targetY < maxY)
					{
						pixelColor = testA.getPixel32(i, j);
						pixelAlpha = (pixelColor >> 24) & 0xFF;
						if (pixelAlpha >= alphaTolerance)
						{
							overlapArea.setPixel32(targetX, targetY, 0xffff0000);
						}
						else
						{
							overlapArea.setPixel32(targetX, targetY, 0xffffffff);
						}
					}
				}
			}
		}
		
		maxX = testB.width + 1;
		maxY = testB.height + 1;
		var secondColor:Int;
		for (i in 0...(maxX))
		{
			targetX = Math.floor(i + matrixB.tx);
			if (targetX < maxX)
			{
				for (j in 0...(maxY))
				{
					targetY = Math.floor(j + matrixB.ty);
					if (targetY < maxY)
					{
						pixelColor = testB.getPixel32(i, j);
						pixelAlpha = (pixelColor >> 24) & 0xFF;
						if (pixelAlpha >= alphaTolerance)
						{
							secondColor = overlapArea.getPixel32(targetX, targetY);
							if (secondColor == 0xffff0000)
							{
								overlapArea.setPixel32(targetX, targetY, 0xff00ffff);
							}
							else
							{
								overlapArea.setPixel32(targetX, targetY, 0xffffffff - secondColor);
							}
						}
					}
				}
			}
		}
		#end
		
		//	Developers: If you'd like to see how this works, display it in your game somewhere. Or you can comment it out to save a tiny bit of performance
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
	}
	
	/**
	 * A Pixel Perfect Collision check between a given x/y coordinate and an FlxSprite<br>
	 * 
	 * @param	pointX			The x coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	pointY			The y coordinate of the point given in local space (relative to the FlxSprite, not game world coordinates)
	 * @param	target			The FlxSprite to check the point against
	 * @param	alphaTolerance	The alpha tolerance level above which pixels are counted as colliding. Default to 255 (must be fully transparent for collision)
	 * 
	 * @return	Boolean True if the x/y point collides with the FlxSprite, false if not
	 */
	#if flash
	public static function pixelPerfectPointCheck(pointX:UInt, pointY:UInt, target:FlxSprite, ?alphaTolerance:Int = 255):Bool
	#else
	public static function pixelPerfectPointCheck(pointX:Int, pointY:Int, target:FlxSprite, ?alphaTolerance:Int = 255):Bool
	#end
	{
		//	Intersect check
		if (FlxMath.pointInCoordinates(pointX, pointY, Math.floor(target.x), Math.floor(target.y), Math.floor(target.width), Math.floor(target.height)) == false)
		{
			return false;
		}
		
		#if flash
		//	How deep is pointX/Y within the rect?
		var test:BitmapData = target.framePixels;
		if (Std.int(FlxColor.getAlpha(test.getPixel32(Math.floor(pointX - target.x), Math.floor(pointY - target.y)))) >= alphaTolerance)
		{
			return true;
		}
		else
		{
			return false;
		}
		#else
		var indexX:Int = target.frame * target.frameWidth;
		var indexY:Int = 0;

		//Handle sprite sheets
		var widthHelper:Int = (target.flipped != 0) ? target.flipped : target.pixels.width;
		if(indexX >= widthHelper)
		{
			indexY = Math.floor(indexX / widthHelper) * target.frameHeight;
			indexX %= widthHelper;
		}
		
		//handle reversed sprites
		if ((target.flipped != 0) && (target.facing == FlxObject.LEFT))
		{
			indexX = (target.flipped << 1) - indexX - target.frameWidth;
		}
		
		var pixelColor:Int = target.pixels.getPixel32(Math.floor(indexX + pointX - target.x), Math.floor(indexY + pointY - target.y));
		var pixelAlpha:Int = (pixelColor >> 24) & 0xFF;
		return (pixelAlpha >= alphaTolerance);
		#end
	}
	
	/**
	 * Creates a "wall" around the given camera which can be used for FlxSprite collision
	 * 
	 * @param	camera				The FlxCamera to use for the wall bounds (can be FlxG.camera for the current one)
	 * @param	placement			CAMERA_WALL_OUTSIDE or CAMERA_WALL_INSIDE
	 * @param	thickness			The thickness of the wall in pixels
	 * @param	adjustWorldBounds	Adjust the FlxG.worldBounds based on the wall (true) or leave alone (false)
	 * 
	 * @return	FlxGroup The 4 FlxTileblocks that are created are placed into this FlxGroup which should be added to your State
	 */
	#if flash
	public static function createCameraWall(camera:FlxCamera, placement:UInt, thickness:UInt, ?adjustWorldBounds:Bool = false):FlxGroup
	#else
	public static function createCameraWall(camera:FlxCamera, placement:Int, thickness:Int, ?adjustWorldBounds:Bool = false):FlxGroup
	#end
	{
		var left:FlxTileblock = null;
		var right:FlxTileblock = null;
		var top:FlxTileblock = null;
		var bottom:FlxTileblock = null;
		
		switch (placement)
		{
			case CAMERA_WALL_OUTSIDE:
				left = new FlxTileblock(Math.floor(camera.x - thickness), Math.floor(camera.y + thickness), thickness, camera.height - (thickness * 2));
				right = new FlxTileblock(Math.floor(camera.x + camera.width), Math.floor(camera.y + thickness), thickness, camera.height - (thickness * 2));
				top = new FlxTileblock(Math.floor(camera.x - thickness), Math.floor(camera.y - thickness), camera.width + thickness * 2, thickness);
				bottom = new FlxTileblock(Math.floor(camera.x - thickness), camera.height, camera.width + thickness * 2, thickness);
				
				if (adjustWorldBounds)
				{
					FlxG.worldBounds = new FlxRect(camera.x - thickness, camera.y - thickness, camera.width + thickness * 2, camera.height + thickness * 2);
				}
				
			case CAMERA_WALL_INSIDE:
				left = new FlxTileblock(Math.floor(camera.x), Math.floor(camera.y + thickness), thickness, camera.height - (thickness * 2));
				right = new FlxTileblock(Math.floor(camera.x + camera.width - thickness), Math.floor(camera.y + thickness), thickness, camera.height - (thickness * 2));
				top = new FlxTileblock(Math.floor(camera.x), Math.floor(camera.y), camera.width, thickness);
				bottom = new FlxTileblock(Math.floor(camera.x), camera.height - thickness, camera.width, thickness);
				
				if (adjustWorldBounds)
				{
					FlxG.worldBounds = new FlxRect(camera.x, camera.y, camera.width, camera.height);
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