package flixel.system.ui;

import flash.display.Graphics;
import flash.display.Sprite;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.system.FlxAssets;

class FlxFocusLostScreen extends Sprite
{
	public function new()
	{
		super();
		
		var gfx:Graphics = graphics;
		var screenWidth:Int = Std.int(FlxG.width * FlxCamera.defaultZoom);
		var screenHeight:Int = Std.int(FlxG.height * FlxCamera.defaultZoom);
		
		// Draw transparent black backdrop
		gfx.moveTo(0, 0);
		gfx.beginFill(0, 0.5);
		gfx.lineTo(screenWidth, 0);
		gfx.lineTo(screenWidth, screenHeight);
		gfx.lineTo(0, screenHeight);
		gfx.lineTo(0, 0);
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
		
		var logo:Sprite = new Sprite();
		FlxAssets.drawLogo(logo.graphics);
		logo.scaleX = helper / 1000;
		
		if (logo.scaleX < 0.2)
		{
			logo.scaleX = 0.2;
		}
		
		logo.scaleY = logo.scaleX;
		logo.x = logo.y = 5;
		logo.alpha = 0.35;
		addChild(logo);
		
		visible = false;
	}
}