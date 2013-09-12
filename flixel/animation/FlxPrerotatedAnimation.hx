package flixel.animation;
import flixel.animation.FlxBaseAnimation;
import flixel.FlxSprite;

/**
 * ...
 * @author Zaphod
 */
class FlxPrerotatedAnimation extends FlxBaseAnimation
{
	private var rotations:Int;
	
	public function new(Sprite:FlxSprite)
	{
		super(Sprite);
		rotations = Math.round(360 / sprite.bakedRotation);
	}
	
	override public function update():Bool 
	{
		var dirty:Bool = false;
		var oldIndex:Int = curIndex;
		var angleHelper:Int = Math.floor((sprite.angle) % 360);
		
		while (angleHelper < 0)
		{
			angleHelper += 360;
		}
		
		curIndex = Math.floor(angleHelper / sprite.bakedRotation + 0.5);
		curIndex = Std.int(curIndex % rotations);
		
		if (oldIndex != curIndex)
		{
			dirty = true;
		}
		
		return dirty;
	}
	
	override public function clone(Sprite:FlxSprite):FlxPrerotatedAnimation 
	{
		return new FlxPrerotatedAnimation(Sprite);
	}
	
}