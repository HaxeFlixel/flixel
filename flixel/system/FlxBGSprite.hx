package flixel.system;

//start FlxG.renderTile

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

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
		var cr:Float = colorTransform.redMultiplier;
		var cg:Float = colorTransform.greenMultiplier;
		var cb:Float = colorTransform.blueMultiplier;
		var ca:Float = colorTransform.alphaMultiplier;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			_matrix.identity();
			_matrix.scale(camera.width, camera.height);
			camera.drawPixels(frame, _matrix, cr, cg, cb, ca);
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
}

//end FlxG.renderTile