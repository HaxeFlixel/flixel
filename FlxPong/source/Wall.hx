package;
import nme.display.BitmapInt32;
import org.flixel.FlxSprite;

class Wall extends FlxSprite 
{
	#if flash
	public function new(X:Float, Y:Float, color:UInt, horizontalRotate:Bool = false) 
	#else
	public function new(X:Float, Y:Float, color:BitmapInt32, horizontalRotate:Bool = false) 
	#end
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