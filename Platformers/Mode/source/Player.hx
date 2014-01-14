package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxTypedGroup;
import flixel.ui.FlxButton;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;

class Player extends FlxSprite
{
	public var isReadyToJump:Bool = true;
	public var flickering:Bool = false;

	private var _jumpPower:Int = 200;
	private var _aim:Int;
	private var _restart:Float = 0;
	private var _gibs:FlxEmitter;
	private var _bullets:FlxTypedGroup<Bullet>;
	
	/**
	 * This is the player object class.  Most of the comments I would put in here
	 * would be near duplicates of the Enemy class, so if you're confused at all
	 * I'd recommend checking that out for some ideas!
	 */
	public function new(X:Int, Y:Int, Bullets:FlxTypedGroup<Bullet>, Gibs:FlxEmitter)
	{
		super(X, Y);
		
		loadGraphic(Reg.SPACEMAN, true, true, 8);
		
		// Bounding box tweaks
		width = 6;
		height = 7;
		offset.set(1, 1);
		
		// Basic player physics
		var runSpeed:Int = 80;
		drag.x = runSpeed * 8;
		acceleration.y = 420;
		maxVelocity.set(runSpeed, _jumpPower);
		
		// Animations
		animation.add("idle", [0]);
		animation.add("run", [1, 2, 3, 0], 12);
		animation.add("jump", [4]);
		animation.add("idle_up", [5]);
		animation.add("run_up", [6, 7, 8, 5], 12);
		animation.add("jump_up", [9]);
		animation.add("jump_down", [10]);
		
		// Bullet stuff
		_bullets = Bullets;
		_gibs = Gibs;
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_bullets = null;
		_gibs = null;
	}
	
	override public function update():Void
	{
		// Game restart timer
		if (!alive)
		{
			_restart += FlxG.elapsed;
			
			if (_restart > 2)
			{
				FlxG.resetState();
			}
			
			return;
		}
		
		// Make a little noise if you just touched the floor
		if (justTouched(FlxObject.FLOOR) && (velocity.y > 50))
		{
			FlxG.sound.play("Land");
		}
		
		// MOVEMENT
		acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT)
		{
			facing = FlxObject.LEFT;
			acceleration.x -= drag.x;
		}
		else if (FlxG.keys.pressed.RIGHT)
		{
			facing = FlxObject.RIGHT;
			acceleration.x += drag.x;
		}
		
		if (FlxG.keys.justPressed.X && isReadyToJump && velocity.y == 0)
		{
			velocity.y = -_jumpPower;
			FlxG.sound.play("Jump");
		}
		
		// AIMING
		if (FlxG.keys.pressed.UP)
		{
			_aim = FlxObject.UP;
		}
		else if (FlxG.keys.pressed.DOWN)
		{
			_aim = FlxObject.DOWN;
		}
		else
		{
			_aim = facing;
		}
		
		// ANIMATION
		if (velocity.y != 0)
		{
			if (_aim == FlxObject.UP) 
			{
				animation.play("jump_up");
			}
			else if (_aim == FlxObject.DOWN) 
			{
				animation.play("jump_down");
			}
			else 
			{
				animation.play("jump");
			}
		}
		else if (velocity.x == 0)
		{
			if (_aim == FlxObject.UP) 
			{
				animation.play("idle_up");
			}
			else 
			{
				animation.play("idle");
			}
		}
		else
		{
			if (_aim == FlxObject.UP) 
			{
				animation.play("run_up");
			}
			else 
			{
				animation.play("run");
			}
		}
		
		// SHOOTING
		if (FlxG.keys.justPressed.C)
		{
			if (flickering)
			{
				FlxG.sound.play("Jam");
			}
			else
			{
				getMidpoint(_point);
				_bullets.recycle(Bullet).shoot(_point, _aim);
				
				if (_aim == FlxObject.DOWN)
				{
					velocity.y -= 36;
				}
			}
		}
		
        super.update();
	}
	
	override public function hurt(Damage:Float):Void
	{
		Damage = 0;
		
		if (flickering)
		{
			return;
		}
		
		FlxG.sound.play("Hurt");
		
		flicker(1.3);
		
		if (Reg.score > 1000) 
		{
			Reg.score -= 1000;
		}
		
		if (velocity.x > 0)
		{
			velocity.x = -maxVelocity.x;
		}
		else
		{
			velocity.x = maxVelocity.x;
		}
		
		super.hurt(Damage);
	}
	
	private function flicker(Duration:Float):Void
	{
		FlxSpriteUtil.flicker(this, Duration, 0.02, true);
		FlxTimer.start(Duration, function f(T:FlxTimer) { flickering = false; } );
		flickering = true;
	}
	
	override public function kill():Void
	{
		if (!alive)
		{
			return;
		}
		
		solid = false;
		FlxG.sound.play("Asplode");
		FlxG.sound.play("MenuHit2");
		
		super.kill();
		
		exists = true;
		visible = false;
		velocity.set();
		acceleration.set();
		FlxG.camera.shake(0.005, 0.35);
		FlxG.camera.flash(0xffd8eba2, 0.35);
		
		if (_gibs != null)
		{
			_gibs.at(this);
			_gibs.start(true, 5, 0, 50);
		}
	}
}