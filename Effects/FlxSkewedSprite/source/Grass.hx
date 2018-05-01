package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;

/**
 * ...
 * @author Zaphod
 */
class Grass extends FlxSkewedSprite
{
	public var maxSkew:Float = 30;
	public var minSkew:Float = -30;
	public var skewSpeed:Float = 15;
	
	var _skewDirection:Int = 1;
	
	public function new(X:Float = 0, Y:Float = 0, Frame:Int = 0, StartSkew:Float = 0)
	{
		super(X, Y);
		
		loadGraphic("assets/grass.png", true, 300, 28);
		animation.frameIndex = Frame;
		
		antialiasing = true;
		skew.x = StartSkew;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		skew.x += _skewDirection * skewSpeed * elapsed;
		
		if (skew.x > maxSkew)
		{
			skew.x = maxSkew;
			_skewDirection = -1;
		}
		else if (skew.x < minSkew)
		{
			skew.x = minSkew;
			_skewDirection = 1;
		}
	}	
}