package;

import flixel.input.keyboard.FlxKey;
import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.group.FlxGroup;
import flixel.FlxObject;
import flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 */
class Player extends FlxSprite 
{
	public static inline var RUN_SPEED:Int = 90;
	public static inline var GRAVITY:Int = 620;
	public static inline var JUMP_SPEED:Int = 250;
	public static inline var JUMPS_ALLOWED:Int = 2;
	public static inline var BULLET_SPEED:Int = 200;
	public static inline var GUN_DELAY:Float = 0.4;
	
	var _gibs:FlxEmitter;
	var _bullets:FlxTypedGroup<Bullet>;
	var _blt:Bullet;
	var _cooldown:Float;
	var _parent:PlayState;
	
	var _jumpTime:Float = -1;
	var _timesJumped:Int = 0;
	var _jumpKeys:Array<FlxKey> = [C, K, SPACE];
	
	var _xgridleft:Int = 0;
	var _xgridright:Int = 0;
	var _ygrid:Int = 0;
	
	public var climbing:Bool = false;
	var _onLadder:Bool = false;
	
	public function new(X:Int, Y:Int, Parent:PlayState, Gibs:FlxEmitter, Bullets:FlxTypedGroup<Bullet>) 
	{
		// X,Y: Starting coordinates
		super(X, Y);
		
		_bullets = Bullets;
		
		//Set up the graphics
		loadGraphic("assets/art/lizardhead3.png", true, 16, 20);
		
		animation.add("walking", [0, 1, 2, 3], 12, true);
		animation.add("idle", [3]);
		animation.add("jump", [2]);
		
		drag.set(RUN_SPEED * 8, RUN_SPEED * 8);
		maxVelocity.set(RUN_SPEED, JUMP_SPEED);
		acceleration.y = GRAVITY;
		setSize(12, 16);
		offset.set(3, 4);
		
		// Initialize the cooldown so that helmutguy can shoot right away.
		_cooldown = GUN_DELAY; 
		_gibs = Gibs;
		// This is so we can look at properties of the playstate's tilemaps
		_parent = Parent;  
	}
	
	public override function update(elapsed:Float):Void
	{
		// Reset to 0 when no button is pushed
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
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			flipX = true;
			acceleration.x = -drag.x;
		}
		else if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			flipX = false;
			acceleration.x = drag.x;
		}
		
		jump(elapsed);
		
		// Can only climb when not jumping
		if (_jumpTime < 0)
		{
			climb();
		}
		
		// Shooting
		if (FlxG.keys.anyPressed([X, J]))
		{
			//Let's put the shooting code in its own function to keep things organized
			shoot();
		}
		
		// Animations
		if (velocity.x > 0 || velocity.x < 0) 
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
		
		_cooldown += elapsed;
		
		// Don't let helmuguy walk off the edge of the map
		if (x <= 0)
		{
			x = 0;
		}
		if ((x + width) > _parent.map.width)
		{
			x = _parent.map.width - width;
		}
		
		// Convert pixel positions to grid positions. Std.int and floor are functionally the same, 
		_xgridleft = Std.int((x + 3) / 16);   
		_xgridright = Std.int((x + width - 3) / 16);
		// but I hear int is faster so let's go with that.
		_ygrid = Std.int((y + height - 1) / 16);   
		
		if (_parent.ladders.getTile(_xgridleft, _ygrid) > 0 && _parent.ladders.getTile(_xgridright, _ygrid) > 0) 
		{
			_onLadder = true;
		}
		else 
		{
			_onLadder = false;
			climbing = false;
		}
		
		if (isTouching(FlxObject.FLOOR) && !FlxG.keys.anyPressed(_jumpKeys))
		{
			_jumpTime = -1;
			// Reset the double jump flag
			_timesJumped = 0;  
		}
		
		super.update(elapsed);
	}
	
	function climb():Void
	{
		if (FlxG.keys.anyPressed([UP, W]))
		{
			if (_onLadder) 
			{
				climbing = true;
				_timesJumped = 0;
			}
			
			if (climbing && (_parent.ladders.getTile(_xgridleft, _ygrid - 1)) > 0) 
			{
				velocity.y = - RUN_SPEED;
			}
		}
		else if (FlxG.keys.anyPressed([DOWN, S]))
		{
			if (_onLadder) 
			{
				climbing = true;
				_timesJumped = 0;
			}
			
			if (climbing) 
			{
				velocity.y = RUN_SPEED;
			}
		}
	}
	
	function jump(elapsed:Float):Void
	{
		if (FlxG.keys.anyJustPressed(_jumpKeys))
		{
			if ((velocity.y == 0) || (_timesJumped < JUMPS_ALLOWED)) // Only allow two jumps
			{
				FlxG.sound.play("assets/sounds/jump" + Reg.SoundExtension, 1, false);
				_timesJumped++;
				_jumpTime = 0;
				_onLadder = false;
			}
		}
		
		// You can also use space or any other key you want
		if ((FlxG.keys.anyPressed(_jumpKeys)) && (_jumpTime >= 0)) 
		{
			climbing = false;
			_jumpTime += elapsed;
			
			// You can't jump for more than 0.25 seconds
			if (_jumpTime > 0.25)
			{
				_jumpTime = -1;
			}
			else if (_jumpTime > 0)
			{
				velocity.y = - 0.6 * maxVelocity.y;
			}
		}
		else
			_jumpTime = -1.0;
	}
	
	function shoot():Void 
	{
		// Prepare some variables to pass on to the bullet
		var bulletX:Int = Math.floor(x);
		var bulletY:Int = Math.floor(y + 4);
		var bXVeloc:Int = 0;
		var bYVeloc:Int = 0;
		
		if (_cooldown >= GUN_DELAY)
		{
			_blt = _bullets.recycle(Bullet.new);
			
			if (_blt != null)
			{
				if (flipX)
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
			_gibs.focusOn(this);
			_gibs.start(true, 2.80);
		}
		
		FlxG.sound.play("assets/sounds/death" + Reg.SoundExtension, 1, false);
	}
}
