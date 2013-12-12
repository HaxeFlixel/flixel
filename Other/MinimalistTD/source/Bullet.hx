package;

import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxVelocity;

class Bullet extends FlxSprite 
{
	public var damage:Int;
	
	private var _target:Enemy;
	
	public function new() 
	{
		super();
		makeGraphic(3, 3);
		blend = BlendMode.INVERT;
	}
	
	public function init( X:Float, Y:Float, Target:Enemy, Damage:Int ):Void
	{
		reset( X, Y );
		_target = Target;
		damage = Damage;
	}
 
	override public function update():Void
	{
		if ( !onScreen( FlxG.camera ) ) {
			kill();
		}
		
		if ( _target.alive ) {
			FlxVelocity.moveTowardsObject( this, _target, 200 );
		}
		
		super.update();
	}
}