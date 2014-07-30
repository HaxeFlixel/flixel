package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.util.FlxColor;
import nape.phys.Material;

class Player extends FlxNapeSprite
{
	static inline var speed:Int = 200;
	
	public function new(X:Float, Y:Float)
	{
		super(X, Y);
		makeGraphic(16, 16, FlxColor.BLUE);
		createRectangularBody(16, 16);
		body.allowRotation = false;
		setBodyMaterial(0, 0, 0);
		pixelPerfectRender = false;
	}
	
	override public function update():Void 
	{
		if (FlxG.keys.anyPressed([A, LEFT]))
		{
			body.velocity.x = -speed;
		}
		else if (FlxG.keys.anyPressed([D, RIGHT]))
		{
			body.velocity.x = speed;
		}
		else
		{
			body.velocity.x = 0;
		}
		
		if (FlxG.keys.anyPressed([W, UP]))
		{
			body.velocity.y = -speed;
		}
		else if (FlxG.keys.anyPressed([S, DOWN]))
		{
			body.velocity.y = speed;
		}
		else
		{
			body.velocity.y = 0;
		}
		
		super.update();
	}
}