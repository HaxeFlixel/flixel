package flixel.system.scaleModes;

import flixel.FlxG;

/**
 * `FixedScaleAdjustSizeScaleMode` is a scaling mode which maintains the game's scene at a fixed size.
 * This will clip off the edges of the scene for dimensions which are too small.
 * However, unlike `FixedScaleMode`, this mode will extend the width of the current scene to match the window scale.
 * The result is that objects that would be offscreen on smaller window sizes will be visible in larger ones.
 * 
 * Note that compared with `StageSizeScaleMode`, this scale mode aligns with the center of the game's screen,
 * so the coordinates 0,0 may not be located at the top left of your game window.
 * 
 * To enable it in your project, use `FlxG.scaleMode = new FixedScaleAdjustSizeScaleMode();`.
 */
class FixedScaleAdjustSizeScaleMode extends BaseScaleMode
{
	var fixedWidth:Bool = false;
	var fixedHeight:Bool = false;

	public function new(fixedWidth:Bool = false, fixedHeight:Bool = false)
	{
		super();
		this.fixedWidth = fixedWidth;
		this.fixedHeight = fixedHeight;

		gameSize.set(FlxG.width * FlxG.initialZoom, FlxG.height * FlxG.initialZoom);
	}

	override public function onMeasure(Width:Int, Height:Int):Void
	{
		FlxG.width = fixedWidth ? FlxG.initialWidth : Math.ceil(Width / FlxG.initialZoom);
		FlxG.height = fixedHeight ? FlxG.initialHeight : Math.ceil(Height / FlxG.initialZoom);

		updateGameSize(Width, Height);
		updateDeviceSize(Width, Height);
		updateScaleOffset();
		updateGamePosition();
	}

	override function updateGameSize(Width:Int, Height:Int):Void
	{
		gameSize.x = FlxG.width * FlxG.initialZoom;
		gameSize.y = FlxG.height * FlxG.initialZoom;

		if (FlxG.camera != null)
		{
			var oldWidth:Float = FlxG.camera.width;
			var oldHeight:Float = FlxG.camera.height;

			FlxG.camera.setSize(FlxG.width, FlxG.height);
			FlxG.camera.scroll.x += 0.5 * (oldWidth - FlxG.width);
			FlxG.camera.scroll.y += 0.5 * (oldHeight - FlxG.height);
		}
	}
}
