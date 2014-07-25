package flixel.system;

#if FLX_RENDER_TILE
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.system.layer.DrawStackItem;
import flixel.FlxG;
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
		var drawItem:DrawStackItem;
		
		for (camera in cameras)
		{
			if (!camera.visible || !camera.exists)
			{
				continue;
			}
			
			drawItem = camera.getDrawStackItem(cachedGraphics, isColored, _blendInt);
			
			_point.x = camera.width * 0.5;
			_point.y = camera.height * 0.5;
			
			setDrawData(drawItem, camera, camera.width, 0, 0, camera.height);
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
}
#end