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
			
			drawItem = camera.getDrawTilesItem(graphic, isColored, _blendInt);
			
			var scaledWidth:Float = camera.width * camera.totalScaleX;
			var scaleHeight:Float = camera.height * camera.totalScaleY;
			
			_point.x = 0.5 * scaledWidth;
			_point.y = 0.5 * scaleHeight;
			
			_matrix.setTo(scaledWidth, 0, 0, scaleHeight, _point.x, _point.y);
			
			drawItem.setDrawData(frame.frame, frame.origin, _matrix, isColored, color, alpha * camera.alpha);
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
}
#end