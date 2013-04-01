package org.flixel.system;

#if !flash
import org.flixel.FlxBasic;
import org.flixel.FlxCamera;
import org.flixel.FlxSprite;
import org.flixel.system.layer.DrawStackItem;
import org.flixel.system.layer.Node;
import org.flixel.system.layer.TileSheetData;
import org.flixel.FlxG;

/**
 * The main "game object" class, the sprite is a <code>FlxObject</code>
 * with a bunch of graphics options and abilities, like animation and stamping.
 */
class BGSprite extends FlxSprite
{
	public function new()
	{
		super();
		makeGraphic(1, 1, FlxG.TRANSPARENT, true, FlxG.getUniqueBitmapKey("bg_graphic_"));
		scrollFactor.make();
	}
	
	/**
	 * Called by game loop, updates then blits or renders current frame of animation to the screen
	 */
	override public function draw():Void
	{
		#if !flash
		if (_atlas == null)
		{
			return;
		}
		#end
		
		if (cameras == null)
		{
			cameras = FlxG.cameras;
		}
		var camera:FlxCamera;
		var i:Int = 0;
		var l:Int = cameras.length;
		
		var drawItem:DrawStackItem;
		var currDrawData:Array<Float>;
		var currIndex:Int;
		#if !js
		var isColored:Bool = isColored();
		#else
		var useAlpha:Bool = (alpha < 1);
		#end
		
		while(i < l)
		{
			camera = cameras[i++];
			
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			#if !js
			var isColoredCamera:Bool = camera.isColored();
			drawItem = camera.getDrawStackItem(_atlas, (isColored || isColoredCamera), _blendInt);
			#else
			drawItem = camera.getDrawStackItem(_atlas, useAlpha);
			#end
			currDrawData = drawItem.drawData;
			currIndex = drawItem.position;
			
			_point.x = camera.width * 0.5;
			_point.y = camera.height * 0.5;
			
			var csx:Float = camera.width;
			var ssy:Float = 0;
			var ssx:Float = 0;
			var csy:Float = camera.height;
			
			var x1:Float = (origin.x - _halfWidth);
			var y1:Float = (origin.y - _halfHeight);
			var x2:Float = x1 * csx + y1 * ssy;
			var y2:Float = -x1 * ssx + y1 * csy;
			
			currDrawData[currIndex++] = _point.x - x2;
			currDrawData[currIndex++] = _point.y - y2;
			
			currDrawData[currIndex++] = _flxFrame.tileID;
			
			currDrawData[currIndex++] = csx;
			currDrawData[currIndex++] = ssy;
			currDrawData[currIndex++] = -ssx;
			currDrawData[currIndex++] = csy;
			
			#if !js
			if (isColored || isColoredCamera)
			{
				if (isColoredCamera)
				{
					currDrawData[currIndex++] = _red * camera.red; 
					currDrawData[currIndex++] = _green * camera.green;
					currDrawData[currIndex++] = _blue * camera.blue;
				}
				else
				{
					currDrawData[currIndex++] = _red; 
					currDrawData[currIndex++] = _green;
					currDrawData[currIndex++] = _blue;
				}
			}
			currDrawData[currIndex++] = alpha;
			#else
			if (useAlpha)
			{
				currDrawData[currIndex++] = alpha;
			}
			#end
			drawItem.position = currIndex;
			
			FlxBasic._VISIBLECOUNT++;
		}
	}
}
#end