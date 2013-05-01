package ;
import org.flixel.addons.FlxSkewedSprite;
import org.flixel.FlxG;

/**
 * ...
 * @author Zaphod
 */

class Grass extends FlxSkewedSprite
{
	
	public var maxSkew:Float;
	public var minSkew:Float;
	public var skewSpeed:Float;
	
	private var _skewDirection:Int;
	
	public function new(?X:Float = 0, ?Y:Float = 0, ?Frame:Int = 0, ?StartSkew:Float = 0)
	{
		super(X, Y);
		
		loadGraphic("assets/grass.png", true, false, 300, 28);
		frame = Frame;
		
		minSkew = -30;
		maxSkew = 30;
		skewSpeed = 10;
		
		_skewDirection = 1;
		skew.x = StartSkew;
	}
	
	override public function update():Void 
	{
		super.update();
		
		skew.x += _skewDirection * skewSpeed * FlxG.elapsed;
		
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