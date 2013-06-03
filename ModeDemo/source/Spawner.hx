package;

import openfl.Assets;
import flash.display.BlendMode;
import org.flixel.FlxEmitter;
import org.flixel.FlxG;
import org.flixel.FlxGroup;
import org.flixel.FlxSprite;

class Spawner extends FlxSprite
{
	private var _timer:Float;
	private var _bots:FlxGroup;
	private var _botBullets:FlxGroup;
	private var _botGibs:FlxEmitter;
	private var _gibs:FlxEmitter;
	private var _player:Player;
	private var _open:Bool;
	
	public function new(X:Int, Y:Int, Gibs:FlxEmitter, Bots:FlxGroup, BotBullets:FlxGroup, BotGibs:FlxEmitter, ThePlayer:Player)
	{
		super(X, Y);
		loadGraphic("assets/spawner.png", true);
		_gibs = Gibs;
		_bots = Bots;
		_botBullets = BotBullets;
		_botGibs = BotGibs;
		_player = ThePlayer;
		_timer = FlxG.random() * 20;
		_open = false;
		health = 8;

		addAnimation("open", [1, 2, 3, 4, 5], 40, false);
		addAnimation("close", [4, 3, 2, 1, 0], 40, false);
		addAnimation("dead", [6]);
	}
	
	override public function destroy():Void
	{
		super.destroy();
		_bots = null;
		_botGibs = null;
		_botBullets = null;
		_gibs = null;
		_player = null;
	}
	
	override public function update():Void
	{
		_timer += FlxG.elapsed;
		var limit:Int = 20;
		if(onScreen())
		{
			limit = 4;
		}
		if(_timer > limit)
		{
			_timer = 0;
			makeBot();
		}
		else if(_timer > limit - 0.35)
		{
			if(!_open)
			{
				_open = true;
				play("open");
			}
		}
		else if(_timer > 1)
		{
			if(_open)
			{
				play("close");
				_open = false;
			}
		}
			
		super.update();
	}
	
	override public function hurt(Damage:Float):Void
	{
		FlxG.play("Hit");
		
		flicker(0.2);
		Reg.score += 50;
		super.hurt(Damage);
	}
	
	override public function kill():Void
	{
		if(!alive)
		{
			return;
		}
		FlxG.play("Asplode");
		FlxG.play("MenuHit2");
		
		super.kill();
		active = false;
		exists = true;
		solid = false;
		flicker(0);
		play("dead");
		FlxG.camera.shake(0.007, 0.25);
		FlxG.camera.flash(0xffd8eba2, 0.65, turnOffSlowMo);
		FlxG.timeScale = 0.35;
		makeBot();
		_gibs.at(this);
		_gibs.start(true,3);
		Reg.score += 1000;
	}
	
	private function makeBot():Void
	{
		cast(_bots.recycle(Enemy), Enemy).init(Math.floor(x + width / 2), Math.floor(y + height / 2), _botBullets, _botGibs, _player);
	}
	
	private function turnOffSlowMo():Void
	{
		FlxG.timeScale = 1.0;
	}
}