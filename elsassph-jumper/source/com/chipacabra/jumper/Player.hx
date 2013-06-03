package com.chipacabra.jumper;

import openfl.Assets;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 **/
class Player extends FlxSprite 
{
//	public static inline var RUN_SPEED:Int = 90;
	public static inline var RUN_SPEED:Int = 60;
	public static inline var GRAVITY:Int = 620;
	public static inline var JUMP_SPEED:Int = 250;
	public static inline var BULLET_SPEED:Int = 200;
	public static inline var GUN_DELAY:Float = 0.4;
	
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
	
	public function new(X:Int, Y:Int, Parent:PlayState, Gibs:FlxEmitter, Bullets:FlxGroup) // X,Y: Starting coordinates
	{
		super(X, Y);
		
		_bullets = Bullets;
		
		loadGraphic("assets/art/lizardhead3.png", true, true, 16, 20);  //Set up the graphics
		addAnimation("walking", [0, 1, 2, 3], 12, true);
		addAnimation("idle", [3]);
		addAnimation("jump", [2]);
		
		drag.x = RUN_SPEED * 8;
		drag.y = RUN_SPEED * 8;
		acceleration.y = GRAVITY;
		maxVelocity.x = RUN_SPEED;
		maxVelocity.y = JUMP_SPEED;
		height = 16;
		offset.y = 4;
		width = 12;
		offset.x = 3;
		
		_cooldown = GUN_DELAY; // Initialize the cooldown so that helmutguy can shoot right away.
		_gibs = Gibs;
		_parent = Parent;  // This is so we can look at properties of the playstate's tilemaps
		_jump = 0;
		_onladder = false;
		
		climbing = false; // just to make sure it never gets caught undefined. That would be embarassing.
		
	}
	
	/*override public function hitBottom(Contact:FlxObject, Velocity:Float):Void 
	{
		if (!FlxG.keys.C) // Don't let the player jump until he lets go of the button
		_jump = 0;
		_canDJump = true;  // Reset the double jump flag
		super.hitBottom(Contact, Velocity);
	}*/
	
	public override function update():Void
	{
		acceleration.x = 0; //Reset to 0 when no button is pushed
		
		if (climbing) 
		{
			acceleration.y = 0;  // Stop falling if you're climbing a ladder
		}
		else 
		{
			acceleration.y = GRAVITY;
		}
		
		if (FlxG.keys.LEFT)
		{
			facing = FlxObject.LEFT; 
			acceleration.x = -drag.x;
		}
		else if (FlxG.keys.RIGHT)
		{
			facing = FlxObject.RIGHT;
			acceleration.x = drag.x;				
		}
		
		// Climbing
		if (FlxG.keys.UP)
		{
			if (_onladder) 
			{
				climbing = true;
				_canDJump = true;
			}
			if (climbing && (_parent.ladders.getTile(_xgridleft, _ygrid - 1)) > 0) 
			{
				velocity.y = -RUN_SPEED;
			}
		}
		if (FlxG.keys.DOWN) 
		{
			if (_onladder) 
			{
				climbing = true;
				_canDJump = true;
			}
			if (climbing) velocity.y = RUN_SPEED;
		}
		
		if (FlxG.keys.justPressed("C"))
		{
			if (climbing)
			{
				_jump = 0;
				climbing = false;
				FlxG.play(Assets.getSound("assets/sounds/jump" + Jumper.SoundExtension), 1, false);
			}
			if (velocity.y == 0)
			{
				FlxG.play(Assets.getSound("assets/sounds/jump" + Jumper.SoundExtension), 1, false);
			}
		}
		
		if (FlxG.keys.justPressed("C") && (velocity.y > 0) && _canDJump == true)
		{
			FlxG.play(Assets.getSound("assets/sounds/jump" + Jumper.SoundExtension), 1, false);
			_jump = 0;
			_canDJump = false;
		}
		
		if((_jump >= 0) && (FlxG.keys.C)) //You can also use space or any other key you want
		{
			climbing = false;
			_jump += FlxG.elapsed;
			if(_jump > 0.25) _jump = -1; //You can't jump for more than 0.25 seconds
		}
		else _jump = -1;

		if (_jump > 0)
		{
			if(_jump < 0.035)   // this number is how long before a short slow jump shifts to a faster, high jump
			{
				velocity.y = -.6 * maxVelocity.y; //This is the minimum height of the jump
			}
				
			else 
			{
				velocity.y = -.8 * maxVelocity.y;
			}
		}
		//Shooting
		if (FlxG.keys.X)
		{
			shoot();  //Let's put the shooting code in its own function to keep things organized
		}
		//Animation

		if (velocity.x > 0 || velocity.x < 0 ) { play("walking"); }
		else if (velocity.x == 0) { play("idle"); }
		if (velocity.y < 0) { play("jump"); }
		
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
		
		_xgridleft = Std.int((x + 3) / 16);   // Convert pixel positions to grid positions. int and floor are functionally the same, 
		_xgridright = Std.int((x + width - 3) / 16);
		_ygrid = Std.int((y + height - 1) / 16);   // but I hear int is faster so let's go with that.
		
		if (_parent.ladders.getTile(_xgridleft, _ygrid) > 0 && _parent.ladders.getTile(_xgridright, _ygrid) > 0) 
		{
			_onladder = true;
		}
		else 
		{
			_onladder = false;
			climbing = false;
		}
		
		if (climbing)
		{
			/*collideTop = false;
			collideBottom = false;*/
		}
		else
		{
			/*collideTop = true;
			collideBottom = true;*/
		}
		
		if (isTouching(FlxObject.FLOOR) && !FlxG.keys.C)
		{
			_jump = 0;
			_canDJump = true;  // Reset the double jump flag
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
					bulletX -= Math.floor(_blt.width - 8); // nudge it a little to the side so it doesn't emerge from the middle of helmutguy
					bXVeloc = -BULLET_SPEED;
				}
				else
				{
					bulletX += Math.floor(width - 8);
					bXVeloc = BULLET_SPEED;
				}
				_blt.shoot(bulletX, bulletY, bXVeloc, bYVeloc);
				FlxG.play(Assets.getSound("assets/sounds/shoot2" + Jumper.SoundExtension), 1, false);
				_cooldown = 0; // reset the shot clock
			}
		}
	}
	
	/*override public function overlaps(Object:FlxObject):Bool
	{
		if (Object.alive)
		{
			return super.overlaps(Object);
		}
		else
		{
			return false;
		}
	}*/
	
	override public function kill():Void
	{
		if (!alive) return;
		//solid = false;
		super.kill();
		//exists = false;
		//visible = false;
		FlxG.shake(0.005, 0.35);
		FlxG.flash(0xffDB3624, 0.35);
		if (_gibs != null)
		{
			_gibs.at(this);
			_gibs.start(true, 2.80);
		}
		FlxG.play(Assets.getSound("assets/sounds/death" + Jumper.SoundExtension), 1, false);
	}
}