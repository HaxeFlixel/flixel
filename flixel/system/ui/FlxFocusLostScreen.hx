package flixel.system.ui;

import openfl.display.Graphics;
import openfl.display.Sprite;
import flixel.FlxG;
import flixel.system.FlxAssets;

class FlxFocusLostScreen extends Sprite
{
	@:keep
	public function new()
	{
		super();
		draw();

		var logo:Sprite = new Sprite();
		FlxAssets.drawLogo(logo.graphics);
		logo.scaleX = logo.scaleY = 0.2;
		logo.x = logo.y = 5;
		logo.alpha = 0.35;
		addChild(logo);

		visible = false;
	}

	/**
	 * Redraws the big arrow on the focus lost screen.
	 */
	public function draw():Void
	{
		var gfx:Graphics = graphics;

		var screenWidth:Int = Std.int(FlxG.stage.stageWidth);
		var screenHeight:Int = Std.int(FlxG.stage.stageHeight);

		// Draw transparent black backdrop
		gfx.clear();
		gfx.moveTo(0, 0);
		gfx.beginFill(0, 0.5);
		gfx.drawRect(0, 0, screenWidth, screenHeight);
		gfx.endFill();

		// Draw white arrow
		var halfWidth:Int = Std.int(screenWidth / 2);
		var halfHeight:Int = Std.int(screenHeight / 2);
		var helper:Int = Std.int(Math.min(halfWidth, halfHeight) / 3);
		gfx.moveTo(halfWidth - helper, halfHeight - helper);
		gfx.beginFill(0xffffff, 0.65);
		gfx.lineTo(halfWidth + helper, halfHeight);
		gfx.lineTo(halfWidth - helper, halfHeight + helper);
		gfx.lineTo(halfWidth - helper, halfHeight - helper);
		gfx.endFill();

		this.x = -FlxG.scaleMode.offset.x;
		this.y = -FlxG.scaleMode.offset.y;
	}
}
