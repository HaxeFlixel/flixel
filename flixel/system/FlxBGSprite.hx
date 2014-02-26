package flixel.system;

#if !flash
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.FlxG;
import flixel.util.FlxColor;

/**
 * The main "game object" class, the sprite is a FlxObject
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class FlxBGSprite extends FlxSprite
{
	public function new()
	{
		super();
		makeGraphic(1, 1, FlxColor.TRANSPARENT, true, FlxG.bitmap.getUniqueKey("bg_graphic_"));
		scrollFactor.set();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#if js
		var useAlpha:Bool = (alpha < 1);
		#end
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			#if !js
			drawItem = camera.getDrawStackItem(cachedGraphics, isColored, _blendInt);
			#else
			drawItem = camera.getDrawStackItem(cachedGraphics, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = camera.width * 0.5;
			_point.y = camera.height * 0.5;
			
			var csx:Float = camera.width;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = camera.height;
			
			currDrawData[currIndex++] = _point.x;
			currDrawData[currIndex++] = _point.y;
			
			currDrawData[currIndex++] = frame.tileID;
			
			currDrawData[currIndex++] = csx;
			currDrawData[currIndex++] = ssx;
			currDrawData[currIndex++] = -ssy;
			currDrawData[currIndex++] = csy;
			
			#if !js
			if (isColored)
			{
				currDrawData[currIndex++] = _red; 
				currDrawData[currIndex++] = _green;
				currDrawData[currIndex++] = _blue;
			}
			currDrawData[currIndex++] = alpha;
			#else
			if (useAlpha)
			{
				currDrawData[currIndex++] = alpha;
			}
			#end
			drawItem.position = currIndex;
			
			#if !FLX_NO_DEBUG
			FlxBasic._VISIBLECOUNT++;
			#end
		}
	}
}
#end