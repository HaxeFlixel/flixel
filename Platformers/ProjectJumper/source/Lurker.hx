package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.util.FlxSpriteUtil;
/**
 * ...
 * @author David Bell
 */
class Lurker extends EnemyTemplate
{
	public static inline var RUN_SPEED:Int = 30;
	public static inline var GRAVITY:Int = 300;
	public static inline var HEALTH:Int = 2;
	public static inline var SPAWNTIME:Float = 45;
	public static inline var JUMP_SPEED:Int = 60;
	public static inline var BURNTIME:Int = 5;
	public static inline var GUN_DELAY:Int = 1;
	public static inline var BULLET_SPEED:Int =100;
	
	private var _spawntimer:Float;
	private var _burntimer:Float;
	private var _playdeathsound:Bool;
	private var _bullets:FlxTypedGroup<Bullet>;
	private var _cooldown:Float;
	
	public function new(X:Float, Y:Float, ThePlayer:Player, Bullets:FlxTypedGroup<Bullet>)
	{
		super(X, Y, ThePlayer);
		
		_spawntimer = 0;
		_burntimer = 0;
		_playdeathsound = true;
		_bullets = Bullets;
		_cooldown = 0;
		
		loadGraphic("assets/art/lurkmonsta.png", true, 16, 17);
		
		animation.add("walking", [0, 1], 18, true);
		animation.add("burning", [2, 3], 18, true);
		animation.add("wrecked", [4, 5], 18, true);
		animation.add("idle", [0]);
		drag.x = RUN_SPEED * 9;
		drag.y = JUMP_SPEED * 7;
		acceleration.y = GRAVITY;
		maxVelocity.x = RUN_SPEED;
		maxVelocity.y = JUMP_SPEED;
		health = HEALTH;
		offset.x = 3;
		width = 10;
	}
	
	override public function update(elapsed:Float):Void
	{
		if (touching == FlxObject.DOWN)
		{
			if (health <= 0 && _playdeathsound)
			{
				FlxG.sound.play("assets/sounds/mondead2" + Reg.SoundExtension, 1, false);
				_playdeathsound = false;
			}
		}
		
		// Animation
		if ((velocity.x == 0) && (velocity.y == 0))
		{ 
			animation.play("idle");
		}
		else if (health < HEALTH)
		{ 
			if (velocity.y == 0)
			{ 
				animation.play("wrecked");
			}
			else 
			{
				animation.play("burning");
			} 
		}
		else 
		{ 
			animation.play("walking"); 
		}
		
		if (health > 0)
		{
			if (velocity.y == 0)
			{
				acceleration.y = -acceleration.y;
			}
			if (x != _startx)
			{
				acceleration.x = (_startx - x);
			}
			
			var xdistance:Float = _player.x - x;
			var ydistance:Float = _player.y - y;
			var distancesquared:Float = xdistance * xdistance + ydistance * ydistance;
			
			if (distancesquared < 45000)
			{
				shoot(_player);
			}
		}
		
		if (health <= 0)
		{
			maxVelocity.y = JUMP_SPEED * 4;
			acceleration.y = GRAVITY * 3;
			velocity.x = 0;
			_burntimer += elapsed;
			
			if (_burntimer >= BURNTIME)
			{
				super.kill();
				x = -10;
				y = -10;
				visible = false;
				acceleration.y = 0;
			}
			
			_spawntimer += elapsed;
			
			if (_spawntimer >= SPAWNTIME)
			{
				reset(_startx, _starty);
			}
		}
		
		_cooldown += elapsed;
		super.update(elapsed);
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		
		health = HEALTH;
		_spawntimer = 0;
		_burntimer = 0;
		acceleration.y = GRAVITY;
		maxVelocity.y = JUMP_SPEED;
		_playdeathsound = true;
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (x > _player.x)
		{
			velocity.x = drag.x * 4;
		}
		else
		{
			velocity.x = -drag.x * 4;
		}
		
		FlxSpriteUtil.flicker(this, 0.5);
		FlxG.sound.play("assets/sounds/monhurt2" + Reg.SoundExtension, 1, false);
		health -= 1;
	}
	
	private function shoot(P:Player):Void 
	{
		// Bullet code will go here
		var bulletX:Int = Math.floor(x);
		var bulletY:Int = Math.floor(y + 4);
		
		if (_cooldown > GUN_DELAY)
		{
			var bullet = _bullets.getFirstAvailable();
			if (bullet == null)
			{
				bullet = new Bullet();
				_bullets.add(bullet);
			}
			
			if (P.x < x)
			{
				// nudge it a little to the side so it doesn't emerge from the middle of helmutguy
				bulletX -= Math.floor(bullet.width - 8);
			}
			else
			{
				bulletX += Math.floor(width - 8);
			}
			
			bullet.angleshoot(bulletX, bulletY, BULLET_SPEED, FlxPoint.get(P.x, P.y));
			FlxG.sound.play("assets/sounds/badshoot" + Reg.SoundExtension, 1, false);
			// reset the shot clock
			_cooldown = 0;
		}
	}
	
	override public function kill():Void 
	{
		if (!alive)
		{ 
			return;
		}
		
		exists = true;
		solid = true;
		visible = true;
		acceleration.y = GRAVITY;
		velocity.x = 0;
	}
}
