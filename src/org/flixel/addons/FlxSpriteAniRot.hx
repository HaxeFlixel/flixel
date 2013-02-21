/**
 * FlxSpriteAniRot
 * 
 * Creating animated and rotated sprite from an un-rotated animated image. 
 * THE ANIMATION MUST CONTAIN ONLY ONE ROW OF SPRITE FRAMES.
 * 
 * @version 1.0 - November 8th 2011
 * @link http://www.gameonaut.com
 * @author Simon Etienne Rozner / Gameonaut.com, ported to Haxe by Sam Batista
*/

// ONLY FOR BLITTING BASED ENGINES
#if flash
package org.flixel.addons;

import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import org.flixel.FlxG;

import org.flixel.FlxU;
import org.flixel.FlxSprite;

class FlxSpriteAniRot extends FlxSprite
{
	private var rotationRefA:Array<BitmapData>;
	private var rect:Rectangle;

	private var frameCounter:Int = 0;

	private static inline var _zeroPoint:Point = new Point(0, 0);

	public function new(AnimatedGraphic:Dynamic, Rotations:Int, X:Float = 0, Y:Float = 0)
	{
		super(X, Y);
		loadGraphic(AnimatedGraphic, true); //Just to get the number of frames

		var columns:Int = Std.int(Math.sqrt(Rotations));
		rect = new Rectangle(0, 0, width * columns, Std.int(height));

		rotationRefA = new Array<BitmapData>();

		//Load the graphic, create rotations every 10 degrees
		for (i in 0 ... frames)
		{
			loadRotatedGraphic(AnimatedGraphic, Rotations, i, true, false);//Create the rotation spritesheet for that frame
			var bmd:BitmapData = new BitmapData(Std.int(width * columns), Std.int(height), true, 0x00000000);//Create a bitmapData container
			bmd.copyPixels(_pixels, rect, _zeroPoint, pixels, _zeroPoint, true);//get the current pixel data
			rotationRefA.push(bmd);//store it for reference.
		}
		bakedRotation = 0;
	}

	override private function calcFrame():Void 
	{
		pixels.fillRect(rect, FlxG.TRANSPARENT);//clear out blank to avoid artefacts
		pixels.copyPixels(rotationRefA[_curIndex], rect, _zeroPoint, rotationRefA[_curIndex], _zeroPoint, true);
		super.calcFrame();
	}
}
#end