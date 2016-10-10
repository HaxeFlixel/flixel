package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmoLoader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;
#if mobile
import flixel.ui.FlxVirtualPad;
#end

class PlayState extends FlxState
{
	private var _player:Player;
	private var _map:FlxOgmoLoader;
	private var _mWalls:FlxTilemap;
	private var _grpCoins:FlxTypedGroup<Coin>;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _hud:HUD;
	private var _money:Int = 0;
	private var _health:Int = 3;
	private var _inCombat:Bool = false;
	private var _combatHud:CombatHUD;
	private var _ending:Bool;
	private var _won:Bool;
	private var _paused:Bool;
	private var _sndCoin:FlxSound;
	
	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create():Void
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end
		
		_map = new FlxOgmoLoader(AssetPaths.room_001__oel);
		_mWalls = _map.loadTilemap(AssetPaths.tiles__png, 16, 16, "walls");
		_mWalls.follow();
		_mWalls.setTileProperties(1, FlxObject.NONE);
		_mWalls.setTileProperties(2, FlxObject.ANY);
		add(_mWalls);
		
		_grpCoins = new FlxTypedGroup<Coin>();
		add(_grpCoins);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		add(_grpEnemies);
		
		_player = new Player();
		
		_map.loadEntities(placeEntities, "entities");
		
		add(_player);
		
		FlxG.camera.follow(_player, TOPDOWN, 1);
		
		_hud = new HUD();
		add(_hud);
		
		_combatHud = new CombatHUD();
		add(_combatHud);
		
		_sndCoin = FlxG.sound.load(AssetPaths.coin__wav);
		
		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);		
		add(virtualPad);
		#end
		
		FlxG.camera.fade(FlxColor.BLACK, .33, true);
		
		super.create();
	}
	
	private function placeEntities(entityName:String, entityData:Xml):Void
	{
		var x:Int = Std.parseInt(entityData.get("x"));
		var y:Int = Std.parseInt(entityData.get("y"));
		if (entityName == "player")
		{
			_player.x = x;
			_player.y = y;
		}
		else if (entityName == "coin")
		{
			_grpCoins.add(new Coin(x + 4, y + 4));
		}
		else if (entityName == "enemy")
		{
			_grpEnemies.add(new Enemy(x + 4, y, Std.parseInt(entityData.get("etype"))));
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (_ending)
		{
			return;
		}
		
		if (!_inCombat)
		{
			FlxG.collide(_player, _mWalls);
			FlxG.overlap(_player, _grpCoins, playerTouchCoin);
			FlxG.collide(_grpEnemies, _mWalls);
			_grpEnemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(_player, _grpEnemies, playerTouchEnemy);
		}
		else if (!_combatHud.visible)
		{
			_health = _combatHud.playerHealth;
			_hud.updateHUD(_health, _money);
			if (_combatHud.outcome == DEFEAT)
			{
				_ending = true;
				FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
			}
			else
			{
				if (_combatHud.outcome == VICTORY)
				{
					_combatHud.e.kill();
					if (_combatHud.e.etype == 1)
					{
						_won = true;
						_ending = true;
						FlxG.camera.fade(FlxColor.BLACK, .33, false, doneFadeOut);
					}
				}
				else 
				{
					_combatHud.e.flicker();
				}
				#if mobile
				virtualPad.visible = true;
				#end
				_inCombat = false;
				_player.active = true;
				_grpEnemies.active = true;
			}
		}
	}
	
	private function doneFadeOut():Void 
	{
		FlxG.switchState(new GameOverState(_won, _money));
	}
	
	private function playerTouchEnemy(P:Player, E:Enemy):Void
	{
		if (P.alive && P.exists && E.alive && E.exists && !E.isFlickering())
		{
			startCombat(E);
		}
	}
	
	private function startCombat(E:Enemy):Void
	{
		_inCombat = true;
		_player.active = false;
		_grpEnemies.active = false;
		_combatHud.initCombat(_health, E);
		#if mobile
		virtualPad.visible = false;
		#end
	}
	
	private function checkEnemyVision(e:Enemy):Void
	{
		if (_mWalls.ray(e.getMidpoint(), _player.getMidpoint()))
		{
			e.seesPlayer = true;
			e.playerPos.copyFrom(_player.getMidpoint());
		}
		else
			e.seesPlayer = false;		
	}
	
	private function playerTouchCoin(P:Player, C:Coin):Void
	{
		if (P.alive && P.exists && C.alive && C.exists)
		{
			_sndCoin.play(true);
			_money++;
			_hud.updateHUD(_health, _money);
			C.kill();
		}
	}
}
