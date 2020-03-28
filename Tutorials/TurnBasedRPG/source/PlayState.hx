package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.system.FlxSound;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

using flixel.util.FlxSpriteUtil;

class PlayState extends FlxState
{
	var player:Player;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var coins:FlxTypedGroup<Coin>;
	var enemies:FlxTypedGroup<Enemy>;

	var hud:HUD;
	var money:Int = 0;
	var health:Int = 3;

	var inCombat:Bool = false;
	var combatHud:CombatHUD;

	var ending:Bool;
	var won:Bool;

	var coinSound:FlxSound;

	#if mobile
	public static var virtualPad:FlxVirtualPad;
	#end

	override public function create()
	{
		#if FLX_MOUSE
		FlxG.mouse.visible = false;
		#end

		map = new FlxOgmo3Loader(AssetPaths.turnBasedRPG__ogmo, AssetPaths.room_001__json);
		walls = map.loadTilemap(AssetPaths.tiles__png, "walls");
		walls.follow();
		walls.setTileProperties(1, FlxObject.NONE);
		walls.setTileProperties(2, FlxObject.ANY);
		add(walls);

		coins = new FlxTypedGroup<Coin>();
		add(coins);

		enemies = new FlxTypedGroup<Enemy>();
		add(enemies);

		player = new Player();
		map.loadEntities(placeEntities, "entities");
		add(player);

		FlxG.camera.follow(player, TOPDOWN, 1);

		hud = new HUD();
		add(hud);

		combatHud = new CombatHUD();
		add(combatHud);

		coinSound = FlxG.sound.load(AssetPaths.coin__wav);

		#if mobile
		virtualPad = new FlxVirtualPad(FULL, NONE);
		add(virtualPad);
		#end

		FlxG.camera.fade(FlxColor.BLACK, 0.33, true);

		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		var x = entity.x;
		var y = entity.y;

		switch (entity.name)
		{
			case "player":
				player.setPosition(x, y);

			case "coin":
				coins.add(new Coin(x + 4, y + 4));

			case "enemy":
				enemies.add(new Enemy(x + 4, y, REGULAR));

			case "boss":
				enemies.add(new Enemy(x + 4, y, BOSS));
		}
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (ending)
		{
			return;
		}

		if (inCombat)
		{
			if (!combatHud.visible)
			{
				health = combatHud.playerHealth;
				hud.updateHUD(health, money);
				if (combatHud.outcome == DEFEAT)
				{
					ending = true;
					FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
				}
				else
				{
					if (combatHud.outcome == VICTORY)
					{
						combatHud.enemy.kill();
						if (combatHud.enemy.type == BOSS)
						{
							won = true;
							ending = true;
							FlxG.camera.fade(FlxColor.BLACK, 0.33, false, doneFadeOut);
						}
					}
					else
					{
						combatHud.enemy.flicker();
					}
					inCombat = false;
					player.active = true;
					enemies.active = true;

					#if mobile
					virtualPad.visible = true;
					#end
				}
			}
		}
		else
		{
			FlxG.collide(player, walls);
			FlxG.overlap(player, coins, playerTouchCoin);
			FlxG.collide(enemies, walls);
			enemies.forEachAlive(checkEnemyVision);
			FlxG.overlap(player, enemies, playerTouchEnemy);
		}
	}

	function doneFadeOut()
	{
		FlxG.switchState(new GameOverState(won, money));
	}

	function playerTouchCoin(player:Player, coin:Coin)
	{
		if (player.alive && player.exists && coin.alive && coin.exists)
		{
			coin.kill();
			money++;
			hud.updateHUD(health, money);
			coinSound.play(true);
		}
	}

	function checkEnemyVision(enemy:Enemy)
	{
		if (walls.ray(enemy.getMidpoint(), player.getMidpoint()))
		{
			enemy.seesPlayer = true;
			enemy.playerPosition = player.getMidpoint();
		}
		else
		{
			enemy.seesPlayer = false;
		}
	}

	function playerTouchEnemy(player:Player, enemy:Enemy)
	{
		if (player.alive && player.exists && enemy.alive && enemy.exists && !enemy.isFlickering())
		{
			startCombat(enemy);
		}
	}

	function startCombat(enemy:Enemy)
	{
		inCombat = true;
		player.active = false;
		enemies.active = false;
		combatHud.initCombat(health, enemy);

		#if mobile
		virtualPad.visible = false;
		#end
	}
}
