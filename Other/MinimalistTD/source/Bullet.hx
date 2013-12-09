package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxVelocity;

class Bullet extends FlxSprite 
{
	public var target:Enemy;
	public var damage:Int;
	
	public function new() 
	{
		super();
		makeGraphic(3, 3);
		blend = BlendMode.INVERT;
	}
	
	public function init(X:Float, Y:Float, Target:Enemy, Damage:Int):Void
	{
		reset(X, Y);
		target = Target;
		damage = Damage;
	}
 
	override public function update():Void
	{
		if (!onScreen(FlxG.camera)) kill();
		if (target.alive) FlxVelocity.moveTowardsObject(this, target, 200);
		
		super.update();
	}
}