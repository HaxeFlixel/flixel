package states;

import flixel.addons.nape.FlxNapeSprite;
import flixel.addons.nape.FlxNapeState;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import flash.display.BitmapData;
import flixel.FlxG;
import openfl.Assets;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class Pixelizer extends FlxNapeState
{
	var shooter:Shooter;

	override public function create():Void
	{
		super.create();

		// Sets gravity.
		// FlxNapeSpace.space.gravity.setxy(0, 1500);

		createWalls(-2000, -2000, 1640, 480);
		createPixels();

		shooter = new Shooter();
		add(shooter);
	}

	function createPixels()
	{
		var image:BitmapData = Assets.getBitmapData("assets/logo.png");

		for (x in 0...30)
		{
			for (y in 0...30)
			{
				var spr:FlxNapeSprite = new FlxNapeSprite(x * 4, y * 4);
				spr.makeGraphic(4, 4, 0xFFFFFFFF);
				spr.createRectangularBody();
				add(spr);
			}
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.G)
			napeDebugEnabled = false;
	}
}
