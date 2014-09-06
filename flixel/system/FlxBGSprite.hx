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
			
			drawItem = camera.getDrawStackItem(graphic, isColored, _blendInt);
			
			var scaledWidth:Float = camera.width * camera.totalScaleX;
			var scaleHeight:Float = camera.height * camera.totalScaleY;
			
			_point.x = 0.5 * scaledWidth;
			_point.y = 0.5 * scaleHeight;
			
			drawItem.setDrawData(_point, frame.tileID, scaledWidth, 0, 0, scaleHeight, isColored, color, alpha * camera.alpha);
			
			#if !FLX_NO_DEBUG
			FlxBasic.visibleCount++;
			#end
		}
	}
}
#end