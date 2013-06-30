package flixel.addons.display;

#if flash
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import flixel.FlxSprite;
import flixel.util.FlxColor;

/**
 * Creating animated and rotated sprite from an un-rotated animated image. 
 * THE ANIMATION MUST CONTAIN ONLY ONE ROW OF SPRITE FRAMES.
 * 
 * @version 1.0 - November 8th 2011
 * @link http://www.gameonaut.com
 * @author Simon Etienne Rozner / Gameonaut.com, ported to Haxe by Sam Batista
*/
class FlxSpriteAniRot extends FlxSprite
{
	static private var _zeroPoint:Point;
	
	private var rotationRefA:Array<BitmapData>;
	private var rect:Rectangle;

	private var frameCounter:Int = 0;

	public function new(AnimatedGraphic:Dynamic, Rotations:Int, X:Float = 0, Y:Float = 0)
	{
		_zeroPoint = new Point(0, 0);
		
		super(X, Y);
		// Just to get the number of frames
		loadGraphic(AnimatedGraphic, true); 
		
		var columns:Int = Std.int(Math.sqrt(Rotations));
		rect = new Rectangle(0, 0, width * columns, Std.int(height));
		
		rotationRefA = new Array<BitmapData>();
		
		// Load the graphic, create rotations every 10 degrees
		for (i in 0 ... frames)
		{
			// Create the rotation spritesheet for that frame
			loadRotatedGraphic(AnimatedGraphic, Rotations, i, true, false);
			// Create a bitmapData container
			var bmd:BitmapData = new BitmapData(Std.int(width * columns), Std.int(height), true, 0x00000000);
			// Get the current pixel data
			bmd.copyPixels(_pixels, rect, _zeroPoint, pixels, _zeroPoint, true);
			// Store it for reference.
			rotationRefA.push(bmd);
		}
		bakedRotation = 0;
	}

	override private function calcFrame():Void 
	{
		// Clear out blank to avoid artefacts
		pixels.fillRect(rect, FlxColor.TRANSPARENT);
		pixels.copyPixels(rotationRefA[_curIndex], rect, _zeroPoint, rotationRefA[_curIndex], _zeroPoint, true);
		super.calcFrame();
	}
}
#end