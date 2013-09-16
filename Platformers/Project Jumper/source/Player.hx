package;

import openfl.Assets;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 **/
class Player extends FlxSprite 
{
	inline static public var RUN_SPEED:Int = 90;
	inline static public var GRAVITY:Int = 620;
	inline static public var JUMP_SPEED:Int = 250;
	inline static public var BULLET_SPEED:Int = 200;
	inline static public var GUN_DELAY:Float = 0.4;
	
	private var _gibs:FlxEmitter;
	private var _bullets:FlxGroup;
	private var _blt:Bullet;
	private var _cooldown:Float;
	private var _parent:PlayState;
	private var _onladder:Bool;
	
	private var _jump:Float;
	private var _canDJump:Bool;
	private var _xgridleft:Int;
	private var _xgridright:Int;
	private var _ygrid:Int;
	
	public var climbing:Bool;
	
	public function new(X:Int, Y:Int, Parent:PlayState, Gibs:FlxEmitter, Bullets:FlxGroup) 
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		_bullets = Bullets;
		
		//Set up the graphics
		loadGraphic("assets/art/lizardhead3.png", true, true, 16, 20);  
		animation.add("walking", [0, 1, 2, 3], 12, true);
		animation.add("idle", [3]);
		animation.add("jump", [2]);
		
		drag.set(RUN_SPEED * 8, RUN_SPEED * 8);
		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		height = 16;
		width = 12;
		offset.set(3, 4);
		
		// Initialize the cooldown so that helmutguy can shoot right away.
		_cooldown = GUN_DELAY; 
		_gibs = Gibs;
		// This is so we can look at properties of the playstate's tilemaps
		_parent = Parent;  
		_jump = 0;
		_onladder = false;
		
		// just to make sure it never gets caught undefined. That would be embarassing.
		climbing = false; 	
	}
	
	public override function update():Void
	{
		//^Reset to 0 when no button is pushed
		acceleration.x = 0; 
		
		if (climbing) 
		{
			// Stop falling if you're climbing a ladder
			acceleration.y = 0;  
		}
		else 
		{
			acceleration.y = GRAVITY;
		}
		
		if (FlxG.keyboard.pressed("LEFT", "A"))
		{
			facing = FlxObject.LEFT; 
			acceleration.x = -drag.x;
		}
		else if (FlxG.keyboard.pressed("RIGHT", "D"))
		{
			facing = FlxObject.RIGHT;
			acceleration.x = drag.x;				
		}
		
		// Climbing
		if (FlxG.keyboard.pressed("UP", "W"))
		{
			if (_onladder) 
			{
				climbing = true;
				_canDJump = true;
			}
			
			if (climbing && (_parent.ladders.getTile(_xgridleft, _ygrid - 1)) > 0) 
			{
				velocity.y = - RUN_SPEED;
			}
		}
		
		if (FlxG.keyboard.pressed("DOWN", "S"))
		{
			if (_onladder) 
			{
				climbing = true;
				_canDJump = true;
			}
			
			if (climbing) 
			{
				velocity.y = RUN_SPEED;
			}
		}
		
		if (FlxG.keyboard.pressed("C", "K"))
		{
			if (climbing)
			{
				_jump = 0;
				climbing = false;
				FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
			}
			
			if (velocity.y == 0)
			{
				FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
			}
		}
		
		if (FlxG.keys.justPressed.C && (velocity.y > 0) && _canDJump == true)
		{
			FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
			_jump = 0;
			_canDJump = false;
		}
		
		// You can also use space or any other key you want
		if (_jump >= 0 && FlxG.keyboard.pressed("C", "K")) 
		{
			climbing = false;
			_jump += FlxG.elapsed;
			
			// You can't jump for more than 0.25 seconds
			if (_jump > 0.25) 
			{
				_jump = -1;
			}
		}
		else 
		{
			_jump = -1;
		}

		if (_jump > 0)
		{
			// this number is how long before a short slow jump shifts to a faster, high jump
			if (_jump < 0.035)   
			{
				// This is the minimum height of the jump
				velocity.y = -.6 * maxVelocity.y; 
			}
				
			else 
			{
				velocity.y = -.8 * maxVelocity.y;
			}
		}
		
		// Shooting
		if (FlxG.keyboard.pressed("X", "J"))
		{
			//Let's put the shooting code in its own function to keep things organized
			shoot();  
		}
		
		// Animations
		if (velocity.x > 0 || velocity.x < 0 ) 
		{ 
			animation.play("walking"); 
		}
		else if (velocity.x == 0) 
		{ 
			animation.play("idle"); 
		}
		if (velocity.y < 0) 
		{ 
			animation.play("jump"); 
		}
		
		_cooldown += FlxG.elapsed;
		
		// Don't let helmuguy walk off the edge of the map
		if (x <= 0)
		{
			x = 0;
		}
		if ((x + width) > _parent.map.width)
		{
			x = _parent.map.width - width;
		}
		
		// Convert pixel positions to grid positions. int and floor are functionally the same, 
		_xgridleft = Std.int((x + 3) / 16);   
		_xgridright = Std.int((x + width - 3) / 16);
		// but I hear int is faster so let's go with that.
		_ygrid = Std.int((y + height - 1) / 16);   
		
		if (_parent.ladders.getTile(_xgridleft, _ygrid) > 0 && _parent.ladders.getTile(_xgridright, _ygrid) > 0) 
		{
			_onladder = true;
		}
		else 
		{
			_onladder = false;
			climbing = false;
		}
		
		if (isTouching(FlxObject.FLOOR) && !FlxG.keyboard.pressed("C", "K"))
		{
			_jump = 0;
			// Reset the double jump flag
			_canDJump = true;  
		}
		
		super.update();
	}
	
	private function shoot():Void 
	{
		// Prepare some variables to pass on to the bullet
		var bulletX:Int = Math.floor(x);
		var bulletY:Int = Math.floor(y + 4);
		var bXVeloc:Int = 0;
		var bYVeloc:Int = 0;
		
		if (_cooldown >= GUN_DELAY)
		{
			_blt = cast(_bullets.recycle(), Bullet);
			
			if (_blt != null)
			{
				if (facing == FlxObject.LEFT)
				{
					// nudge it a little to the side so it doesn't emerge from the middle of helmutguy
					bulletX -= Math.floor(_blt.width - 8); 
					bXVeloc = -BULLET_SPEED;
				}
				else
				{
					bulletX += Math.floor(width - 8);
					bXVeloc = BULLET_SPEED;
				}
				
				_blt.shoot(bulletX, bulletY, bXVeloc, bYVeloc);
				FlxG.sound.play("assets/sounds/shoot2" + Reg.SoundExtension, 1, false);
				// reset the shot clock
				_cooldown = 0; 
			}
		}
	}
	
	override public function kill():Void
	{
		if (!alive) 
		{
			return;
		}
		
		super.kill();
		
		FlxG.cameras.shake(0.005, 0.35);
		FlxG.cameras.flash(0xffDB3624, 0.35);
		
		if (_gibs != null)
		{
			_gibs.at(this);
			_gibs.start(true, 2.80);
		}
		
		FlxG.sound.play("assets/sounds/death" + Reg.SoundExtension, 1, false);
	}
}