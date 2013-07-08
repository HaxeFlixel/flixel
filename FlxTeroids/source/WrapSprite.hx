package;

import org.flixel.FlxG;
import org.flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */
class WrapSprite extends FlxSprite
{
	
	public function new(?X:Int = 0, ?Y:Int = 0, ?Graphic:String = null) 
	{
		super(X, Y, Graphic);
		alterBoundingBox();
	}
	
	public function alterBoundingBox():Void
	{
		width = width * 0.75;
		height = height * 0.75;
		this.centerOffsets();
	}
	
	override public function update():Void 
	{
		wrap();
		super.update();
	}
	
	public function wrap():Void
	{
		if(x < -frameWidth + offset.x)
		{
			x = FlxG.width + offset.x;
		}
		else if(x > FlxG.width + offset.x)
		{
			x = -frameWidth + offset.x;
		}
		if(y < -frameHeight + offset.y)
		{
			y = FlxG.height + offset.y;
		}
		else if(y > FlxG.height + offset.y)
		{
			y = -frameHeight + offset.y;
		}
	}
	
}