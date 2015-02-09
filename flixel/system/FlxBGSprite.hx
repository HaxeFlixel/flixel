package flixel.system;

#if FLX_RENDER_TILE
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.FlxG;
import flixel.graphics.tile.FlxDrawTilesItem;
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
		var drawItem:FlxDrawTilesItem;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			_matrix.identity();
			_matrix.scale(camera.width, camera.height);
			camera.drawPixels(frame, _matrix, colorTransform);
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
}
#end