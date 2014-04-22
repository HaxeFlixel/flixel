package;

import flixel.addons.nape.FlxNapeSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import openfl.Assets;

/**
 * @author TiagoLr ( ~~~ProG4mr~~~ )
 */
class Orb extends FlxNapeSprite
{
	public var shadow:FlxSprite;
	
	public function new ()
	{
		super(FlxG.width / 2, FlxG.height / 2, Assets.getBitmapData("assets/Orb.png"));
		createCircularBody(18);
		body.allowRotation = false;
		setDrag(0.98, 1);
	}
	
	override public function update():Void 
	{
		super.update();
		
		if (FlxG.camera.target != null && FlxG.camera.followLead.x == 0) // target check is used for debug purposes.
		{
			x = Math.round(x); // Smooths camera and orb shadow following. Does not work well with camera lead.
			y = Math.round(y); // Smooths camera and orb shadow following. Does not work well with camera lead.
		}
		
		shadow.x = Math.round(x);
		shadow.y = Math.round(y);
	}
}