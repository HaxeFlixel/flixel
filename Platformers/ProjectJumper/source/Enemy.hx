package;

import flixel.FlxG;
import flixel.effects.particles.FlxEmitter;
import flixel.util.FlxSpriteUtil;

/**
 * @author David Bell
 */
class Enemy extends EnemyTemplate
{
	public static inline var RUN_SPEED:Int = 60;
	public static inline var GRAVITY:Int = 0;
	public static inline var JUMP_SPEED:Int = 60;
	public static inline var HEALTH:Int = 1;
	public static inline var SPAWNTIME:Float = 30;

	var _gibs:FlxEmitter;
	var _spawntimer:Float;

	public function new(X:Float, Y:Float, ThePlayer:Player, Gibs:FlxEmitter)
	{
		super(X, Y, ThePlayer);

		// These will let us reset the monster later
		_spawntimer = 0;

		// Set up the graphics
		loadGraphic("assets/art/spikemonsta.png", true);

		animation.add("walking", [0, 1], 10, true);
		animation.add("idle", [0]);

		drag.x = RUN_SPEED * 7;
		drag.y = JUMP_SPEED * 7;
		acceleration.y = GRAVITY;
		maxVelocity.x = RUN_SPEED;
		maxVelocity.y = JUMP_SPEED;
		health = HEALTH;

		_gibs = Gibs;
	}

	override public function update(elapsed:Float):Void
	{
		if (!alive)
		{
			_spawntimer += elapsed;

			if (_spawntimer >= SPAWNTIME)
			{
				reset(_startx, _starty);
			}

			return;
		}

		// Coast to 0 when not chasing the player
		acceleration.x = acceleration.y = 0;

		// distance on x axis to player
		var xdistance:Float = _player.x - x;
		// distance on y axis to player
		var ydistance:Float = _player.y - y;
		// absolute distance to player (squared, because there's no need to spend cycles calculating the square root)
		var distancesquared:Float = xdistance * xdistance + ydistance * ydistance;

		// that's somewhere around 16 tiles
		if (distancesquared < 65000)
		{
			if (_player.x < x)
			{
				// The sprite is facing the opposite direction than flixel is expecting, so hack it into the right direction
				facing = RIGHT;
				acceleration.x = -drag.x;
			}
			else if (_player.x > x)
			{
				facing = LEFT;
				acceleration.x = drag.x;
			}

			if (_player.y < y)
			{
				acceleration.y = -drag.y;
			}
			else if (_player.y > y)
			{
				acceleration.y = drag.y;
			}
		}

		// Animation
		if ((velocity.x == 0) && (velocity.y == 0))
		{
			animation.play("idle");
		}
		else
		{
			animation.play("walking");
		}

		super.update(elapsed);
	}

	override public function reset(X:Float, Y:Float):Void
	{
		super.reset(X, Y);

		health = HEALTH;
		_spawntimer = 0;
	}

	override public function hurt(Damage:Float):Void
	{
		// remember, right means facing left
		if (facing == RIGHT)
		{
			// Knock him to the right
			velocity.x = drag.x * 4;
		}
		// Don't really need the if part, but hey.
		else if (facing == LEFT)
		{
			velocity.x = -drag.x * 4;
		}

		FlxSpriteUtil.flicker(this, 0.5);
		FlxG.sound.play("assets/sounds/monhurt2" + Reg.SoundExtension, 1, false);

		super.hurt(Damage);
	}

	override public function kill():Void
	{
		if (!alive)
		{
			return;
		}

		if (_gibs != null)
		{
			_gibs.focusOn(this);
			_gibs.start(true, 2.80);
			FlxG.sound.play("assets/sounds/mondead2" + Reg.SoundExtension, 1, false);
		}

		super.kill();

		// We need to keep updating for the respawn timer, so set exists back on.
		exists = true;
		visible = false;
		// Shove it off the map just to avoid any accidents before it respawns
		x = -10;
		y = -10;
	}
}
