package ;
import flixel.FlxSprite;
import flixel.util.FlxPoint;
import flixel.util.FlxVector;

/**
 * ...
 * @author 
 */
class Seeker extends FlxSprite
{

	public var moving:Bool = false;
	
	private var dest:FlxPoint;
	private var vec:FlxVector;
	
	public function new(X:Float,Y:Float,?SimpleGraphic:Dynamic)
	{
		super(X, Y, SimpleGraphic);
		dest = new FlxPoint();
		vec = new FlxVector();
	}
	
	public function moveTo(X:Float, Y:Float, Speed:Float):Void {
		moving = true;
		dest.x = X;
		dest.y = Y;
		
		vec.x = dest.x - x;
		vec.y = dest.y - y;
		
		vec.normalize();
		
		velocity.x = (vec.x) * Speed;
		velocity.y = (vec.y) * Speed;
	}
	
	private function finishMoveTo():Void {
		x = dest.x;
		y = dest.y;
		velocity.x = 0;
		velocity.y = 0;
		moving = false;
	}
	
	public override function update():Void {
		var oldx:Float = vec.x;
		var oldy:Float = vec.y;
		super.update();
		vec.x = dest.x-x;
		vec.y = dest.y-y;
		if (signOf(oldx) != signOf(vec.x) || signOf(oldy) != signOf(vec.y)) {
			finishMoveTo();
		}
	}
	
	private function signOf(f:Float):Int {
		if (f < 0) { 
			return -1;
		}
		return 1;
	}
}