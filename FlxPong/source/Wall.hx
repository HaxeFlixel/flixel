package;

import org.flixel.FlxSprite;

class Wall extends FlxSprite 
{
	public function new(X:Float, Y:Float, color:Int, horizontalRotate:Bool = false) 
	{
		super(X, Y);
		this.makeGraphic(112, 16, color, false, null);
		
		//Lol, why would I need a horizontal wall in a pong game? I'll leave for humor. 
		if (horizontalRotate)
		{
			this.angle = 90;
		}
	}
}