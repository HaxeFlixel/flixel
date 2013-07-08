package com.chipacabra.jumper;

import openfl.Assets;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;

/**
 * ...
 * @author David Bell
 */
class Enemy extends EnemyTemplate 
{
	public static inline var RUN_SPEED:Int = 60;
	public static inline var GRAVITY:Int = 0;
	public static inline var JUMP_SPEED:Int = 60;
	public static inline var HEALTH:Int = 1;
	public static inline var SPAWNTIME:Float = 30;
	
	//protected var _player:Player;
	private var _gibs:FlxEmitter;
	//protected var _startx:Number;
	//protected var _starty:Number;
	private var _spawntimer:Float;
	
	public function new(X:Float, Y:Float, ThePlayer:Player, Gibs:FlxEmitter) 
	{
		super(X, Y, ThePlayer);
		
		// These will let us reset the monster later
		//_startx = X;
		//_starty = Y;
		_spawntimer = 0;
		
		loadGraphic("assets/art/spikemonsta.png", true, true);  //Set up the graphics
		addAnimation("walking", [0, 1], 10, true);
		addAnimation("idle", [0]);
		//_player = ThePlayer;
		
		drag.x = RUN_SPEED * 7;
		drag.y = JUMP_SPEED * 7;
		acceleration.y = GRAVITY;
		maxVelocity.x = RUN_SPEED;
		maxVelocity.y = JUMP_SPEED;
		health = HEALTH;
		
		_gibs = Gibs;
		
	}
	
	public override function update():Void
	{
		if (!alive)
		{
			_spawntimer += FlxG.elapsed;
			if (_spawntimer >= SPAWNTIME)
			{
				reset(_startx,_starty);
			}
		return;
		}
		
		acceleration.x = acceleration.y = 0; // Coast to 0 when not chasing the player
		
		var xdistance:Float = _player.x - x; // distance on x axis to player
		var ydistance:Float = _player.y - y; // distance on y axis to player
		var distancesquared:Float = xdistance * xdistance + ydistance * ydistance; // absolute distance to player (squared, because there's no need to spend cycles calculating the square root)
		if (distancesquared < 65000) // that's somewhere around 16 tiles
		{
			if (_player.x < x)
			{
				facing = FlxObject.RIGHT; // The sprite is facing the opposite direction than flixel is expecting, so hack it into the right direction
				acceleration.x = -drag.x;
			}
			else if (_player.x > x)
			{
				facing = FlxObject.LEFT;
				acceleration.x = drag.x;
			}
			if (_player.y < y) { acceleration.y = -drag.y; }
			else if (_player.y > y) { acceleration.y = drag.y;}
		}
		//Animation
		if ((velocity.x == 0) && (velocity.y == 0)) 
		{ 
			play("idle"); 
		}
		else 
		{
			play("walking");
		}
		
		super.update();
	}
	
	override public function reset(X:Float, Y:Float):Void 
	{
		super.reset(X, Y);
		health = HEALTH;
		_spawntimer = 0;
	}
	
	override public function hurt(Damage:Float):Void 
	{
		if (facing == FlxObject.RIGHT) // remember, right means facing left
		{
			velocity.x = drag.x * 4; // Knock him to the right
		}
		else if (facing == FlxObject.LEFT) // Don't really need the if part, but hey.
		{
			velocity.x = -drag.x * 4;
		}
		flicker(.5);
		FlxG.play(Assets.getSound("assets/sounds/monhurt2" + Jumper.SoundExtension), 1, false);
		super.hurt(Damage);
	}
	
	override public function kill():Void 
	{
		if (!alive) { return; }
		
		if (_gibs != null)
		{
			_gibs.at(this);
			_gibs.start(true, 2.80);
			FlxG.play(Assets.getSound("assets/sounds/mondead2" + Jumper.SoundExtension), 1, false);
		}
		super.kill();
		//We need to keep updating for the respawn timer, so set exists back on.
		exists = true;
		visible = false;
		//Shove it off the map just to avoid any accidents before it respawns
		x = -10;
		y = -10;
	}

}