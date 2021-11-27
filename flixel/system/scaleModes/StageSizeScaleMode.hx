package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `StageSizeScaleMode` is a scaling mode which maintains the game's scene at a fixed size.
 * This will clip off the edges of the scene for dimensions which are too small.
 * However, unlike `FixedScaleMode`, this mode will extend the width of the current scene to match the window scale.
 * The result is that objects that would be offscreen on smaller window sizes will be visible in larger ones.
 * 
 * Note that compared with `FixedScaleAdjustSizeScaleMode`, this scale mode aligns with the top left of the game's screen.
 * The coordinates 0,0 are always located at the top left of your game window.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new StageSizeScaleMode();`.
 */
class StageSizeScaleMode extends BaseScaleMode
{
	override public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = Width;
		FlxG.height = Height;

		scale.set(1, 1);
		FlxG.game.x = FlxG.game.y = 0;

		if (FlxG.camera != null)
		{
			var oldW = FlxG.camera.width;
			var oldH = FlxG.camera.height;

			var newW = Math.ceil(Width / FlxG.camera.zoom);
			var newH = Math.ceil(Height / FlxG.camera.zoom);

			FlxG.camera.setSize(newW, newH);
			FlxG.camera.flashSprite.x += (newW - oldW) / 2;
			FlxG.camera.flashSprite.y += (newH - oldH) / 2;
		}
	}
}
