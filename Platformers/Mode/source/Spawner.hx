package;

import flixel.effects.particles.FlxEmitter;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxSpriteUtil;
import flixel.system.FlxAssets;

class Spawner extends FlxSprite
{
	var _timer:Float;
	var _bots:FlxTypedGroup<Enemy>;
	var _botBullets:FlxTypedGroup<EnemyBullet>;
	var _botGibs:FlxEmitter;
	var _gibs:FlxEmitter;
	var _player:Player;
	var _open:Bool;
	
	public function new(X:Int, Y:Int, Gibs:FlxEmitter, Bots:FlxTypedGroup<Enemy>, BotBullets:FlxTypedGroup<EnemyBullet>, BotGibs:FlxEmitter, ThePlayer:Player)
	{
		super(X, Y);
		loadGraphic(AssetPaths.spawner__png, true);
		_gibs = Gibs;
		_bots = Bots;
		_botBullets = BotBullets;
		_botGibs = BotGibs;
		_player = ThePlayer;
		_timer = FlxG.random.float(0, 20);
		_open = false;
		health = 8;

		animation.add("open", [1, 2, 3, 4, 5], 40, false);
		animation.add("close", [4, 3, 2, 1, 0], 40, false);
		animation.add("dead", [6]);
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
	
	override public function update(elapsed:Float):Void
	{
		_timer += elapsed;
		var limit:Int = 20;
		
		if (isOnScreen())
		{
			limit = 4;
		}
		if (_timer > limit)
		{
			_timer = 0;
			makeBot();
		}
		else if (_timer > limit - 0.35)
		{
			if (!_open)
			{
				_open = true;
				animation.play("open");
			}
		}
		else if (_timer > 1)
		{
			if (_open)
			{
				animation.play("close");
				_open = false;
			}
		}
		
		super.update(elapsed);
	}
	
	override public function hurt(Damage:Float):Void
	{
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/hit"));
		FlxSpriteUtil.flicker(this, 0.2, 0.02, true);
		Reg.score += 50;
		
		super.hurt(Damage);
	}
	
	override public function kill():Void
	{
		if (!alive)
		{
			return;
		}
		
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/asplode"));
		FlxG.sound.play(FlxAssets.getSound("assets/sounds/menu_hit_2"));
		
		super.kill();
		
		active = false;
		exists = true;
		solid = false;
		animation.play("dead");
		FlxG.camera.shake(0.007, 0.25);
		FlxG.camera.flash(0xffd8eba2, 0.65, turnOffSlowMo);
		FlxG.timeScale = 0.35;
		makeBot();
		_gibs.focusOn(this);
		_gibs.start(true,3);
		Reg.score += 1000;
	}
	
	function makeBot():Void
	{
		_bots.recycle(Enemy.new).init(Math.floor(x + width / 2), Math.floor(y + height / 2), _botBullets, _botGibs, _player);
	}
	
	function turnOffSlowMo():Void
	{
		FlxG.timeScale = 1.0;
	}
}