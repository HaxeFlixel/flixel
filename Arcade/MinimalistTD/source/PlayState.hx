package;

import flash.display.Sprite;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import Reg.TILE_SIZE;

enum MenuType
{
	General;
	Upgrade;
	Sell;
	ConfirmSell;
}

class PlayState extends FlxState
{
	/**
	 * Helper Sprite object to draw tower's range graphic
	 */
	static var RANGE_SPRITE:Sprite = null;

	// Public variables
	public var enemiesToKill:Int = 0;
	public var enemiesToSpawn:Int = 0;
	public var towerPrice:Int = 8;
	public var wave:Int = 0;

	// Public groups
	public var bullets:FlxTypedGroup<Bullet>;
	public var emitters:FlxTypedGroup<EnemyGibs>;
	public var enemies:FlxTypedGroup<Enemy>;
	public var towerIndicators:FlxTypedGroup<FlxSprite>;

	/**
	 * Controls how money is handled. Setting money automatically "balloons" the money HUD indicator.
	 */
	public var money(default, set):Int = 50;

	// Groups
	var _gui:FlxGroup;
	var _lives:FlxGroup;
	var _topGui:FlxGroup;
	var _towers:FlxTypedGroup<Tower>;
	var _upgradeMenu:FlxGroup;
	var _sellMenu:FlxGroup;
	var _sellConfirm:FlxGroup;

	// Sprites
	var _buildHelper:FlxSprite;
	var _goal:FlxSprite;
	var _towerRange:FlxSprite;

	// Text
	var _centerText:FlxText;
	var _enemyText:FlxText;
	var _moneyText:FlxText;
	var _tutText:FlxText;
	var _waveText:FlxText;
	var _areYouSure:FlxText;

	// Buttons
	var _damageButton:Button;
	var _firerateButton:Button;
	var _nextWaveButton:Button;
	var _rangeButton:Button;
	var _speedButton:Button;
	var _towerButton:Button;
	var _sellButton:Button;

	// Other objects
	var _map:FlxTilemap;
	var _towerSelected:Tower;

	// variables
	var _buildingMode:Bool = false;
	var _gameOver:Bool = false;
	var _numLives:Int = 9;
	var _spawnCounter:Int = 0;
	var _spawnInterval:Int = 1;
	var _speed:Int = 1;
	var _waveCounter:Int = 0;

	var _enemySpawnPosition = FlxPoint.get(TILE_SIZE * 3 + 4, 0);
	var _goalPosition = FlxPoint.get(245, 43);

	/**
	 * Create a new playable game state.
	 */
	override public function create():Void
	{
		Reg.PS = this;

		FlxG.sound.playMusic("td2");

		FlxG.timeScale = 1;

		// Create map

		_map = new FlxTilemap();
		_map.loadMapFromCSV("tilemaps/play_tilemap.csv", Reg.tileImage);

		bullets = new FlxTypedGroup<Bullet>();
		emitters = new FlxTypedGroup<EnemyGibs>();
		enemies = new FlxTypedGroup<Enemy>();
		_towers = new FlxTypedGroup<Tower>();
		towerIndicators = new FlxTypedGroup<FlxSprite>();

		// Set up bottom default GUI

		var guiUnderlay = new FlxSprite(0, FlxG.height - 16);
		guiUnderlay.makeGraphic(FlxG.width, 16, FlxColor.WHITE);

		_gui = new FlxGroup();

		var height:Int = FlxG.height - 18;
		_towerButton = new Button(2, height, "Buy [T]ower ($" + towerPrice + ")", buildTowerCallback.bind(false), 120);
		_nextWaveButton = new Button(100, height, "[N]ext Wave", nextWaveCallback.bind(false), 143);
		_speedButton = new Button(FlxG.width - 20, height, "x1", speedButtonCallback.bind(false), 21);
		_sellButton = new Button(220, height, "[S]ell Mode", sellButtonCallback.bind(true));
		_sellButton.visible = false;

		_tutText = new FlxText(0, height - 10, FlxG.width, "Click on a Tower to Upgrade it!");
		_tutText.alignment = CENTER;
		_tutText.visible = false;

		_gui.add(_towerButton);
		_gui.add(_nextWaveButton);
		_gui.add(_speedButton);
		_gui.add(_sellButton);
		_gui.add(_tutText);

		// Set up upgrade menu, hidden initially, also part of bottom GUI

		_upgradeMenu = new FlxGroup();

		_rangeButton = new Button(14, height, "Range (##): $##", upgradeRangeCallback);
		_damageButton = new Button(100, height, "Damage (##): $##", upgradeDamageCallback);
		_firerateButton = new Button(200, height, "Firerate (##): $##", upgradeFirerateCallback);

		_upgradeMenu.add(new Button(2, height, "<", toggleMenus.bind(General), 10));
		_upgradeMenu.add(_rangeButton);
		_upgradeMenu.add(_damageButton);
		_upgradeMenu.add(_firerateButton);

		_upgradeMenu.visible = false;

		// Set up the sell mode display

		_sellMenu = new FlxGroup();

		var sellMessage = new FlxText(0, height + 3, FlxG.width, "Click on a tower to sell it");
		sellMessage.color = FlxColor.BLACK;
		sellMessage.alignment = CENTER;

		_sellMenu.add(sellMessage);
		_sellMenu.add(new Button(2, height, "<", sellMenuCancel.bind(false), 10));

		_sellMenu.visible = false;

		// Set up the sell confirmation display

		_sellConfirm = new FlxGroup();

		_areYouSure = new FlxText(20, height + 3, 200, "Tower value $###, really sell?");
		_areYouSure.color = FlxColor.BLACK;

		_sellConfirm.add(new Button(2, height, "<", sellMenuCancel.bind(false), 10));
		_sellConfirm.add(_areYouSure);
		_sellConfirm.add(new Button(220, height, "[Y]es", sellConfirmCallback.bind(true)));
		_sellConfirm.add(new Button(280, height, "[N]o", sellConfirmCallback.bind(false)));

		_sellConfirm.visible = false;

		// Set up top GUI

		_topGui = new FlxGroup();

		_moneyText = new FlxText(0, 2, FlxG.width - 4, "$: " + money);
		_moneyText.alignment = "right";

		_enemyText = new FlxText(80, 2, FlxG.width, "Wave");
		_enemyText.visible = false;

		_waveText = new FlxText(180, 2, FlxG.width, "Wave");
		_waveText.visible = false;

		_topGui.add(_moneyText);
		_topGui.add(_enemyText);
		_topGui.add(_waveText);

		// Set up goal

		_goal = new FlxSprite(_goalPosition.x, _goalPosition.y, "images/goal.png");

		_lives = new FlxGroup();

		for (xPos in 0...3)
		{
			for (yPos in 0...3)
			{
				var life = new FlxSprite(_goal.x + 5 + 4 * xPos, _goal.y + 5 + 4 * yPos);
				life.makeGraphic(2, 2, FlxColor.WHITE);
				_lives.add(life);
			}
		}

		// Set up miscellaneous items: center text, buildhelper, and the tower range image

		_centerText = new FlxText(-200, FlxG.height / 2 - 20, FlxG.width, "", 16);
		_centerText.alignment = CENTER;
		_centerText.borderStyle = SHADOW;

		#if flash
		_centerText.blend = BlendMode.INVERT;
		#end

		_buildHelper = new FlxSprite(0, 0, "images/checker.png");
		_buildHelper.visible = false;

		_towerRange = new FlxSprite(0, 0);
		_towerRange.visible = false;

		// Add everything to the state

		add(_map);
		add(bullets);
		add(emitters);
		add(enemies);
		add(_towerRange);
		add(_towers);
		add(towerIndicators);
		add(_goal);
		add(_lives);
		add(_buildHelper);
		add(guiUnderlay);
		add(_gui);
		add(_upgradeMenu);
		add(_sellMenu);
		add(_sellConfirm);
		add(_topGui);
		add(_centerText);

		// Call this to set up for first wave

		killedWave();

		// This is a good place to put watch statements during development.
		#if debug
		// FlxG.watch.add( _sellMenu, "visible" );
		#end
	}

	/**
	 * Called before each wave to set up _waveCounter and some UI elements.
	 */
	public function killedWave():Void
	{
		if (wave != 0)
			FlxG.sound.play("wavedefeated");

		_waveCounter = 3 * FlxG.updateFramerate;

		_nextWaveButton.visible = true;
		_enemyText.visible = false;
	}

	override public function update(elapsed:Float):Void
	{
		// Update enemies left indicator

		_enemyText.text = "Enemies left: " + enemiesToKill;

		// These elements expand when increased; this reduces their size back to normal

		if (_moneyText.size > 8)
			_moneyText.size--;

		if (_enemyText.size > 8)
			_enemyText.size--;

		if (_waveText.size > 8)
			_waveText.size--;

		// Check for key presses, which can substitute for button clicks.

		#if !mobile
		if (FlxG.keys.justReleased.T)
			buildTowerCallback(true);
		if (FlxG.keys.justReleased.SPACE)
			speedButtonCallback(true);
		if (FlxG.keys.justReleased.S)
			sellButtonCallback(true);
		if (FlxG.keys.justReleased.Y)
			sellConfirmCallback(true);
		if (FlxG.keys.justReleased.ESCAPE)
		{
			FlxG.sound.destroy(true);
			FlxG.switchState(new MenuState());
		}
		if (FlxG.keys.justReleased.N)
		{
			if (_sellConfirm.visible)
				sellConfirmCallback(false);
			else
				nextWaveCallback(true);
		}
		if (FlxG.keys.justReleased.ESCAPE)
			toggleMenus(General);
		if (FlxG.keys.justReleased.ONE)
			upgradeRangeCallback();
		if (FlxG.keys.justReleased.TWO)
			upgradeDamageCallback();
		if (FlxG.keys.justReleased.THREE)
			upgradeFirerateCallback();
		#end

		// If needed, updates the grid highlight square buildHelper and the range indicator

		#if !mobile
		if (_buildingMode)
		{
			_buildHelper.x = FlxG.mouse.x - (FlxG.mouse.x % TILE_SIZE);
			_buildHelper.y = FlxG.mouse.y - (FlxG.mouse.y % TILE_SIZE);
			updateRangeSprite(_buildHelper.getMidpoint(), 40);
		}
		#end

		// Controls mouse clicks, which either build a tower or offer the option to upgrade a tower.

		if (FlxG.mouse.justReleased)
		{
			if (_buildingMode)
			{
				buildTower();
			}
			else
			{
				var selectedTower:Bool = false;

				#if !mobile
				// If the user clicked on a tower, they get the upgrade menu, or the sell menu
				for (tower in _towers)
				{
					if (FlxMath.pointInCoordinates(Std.int(FlxG.mouse.x), Std.int(FlxG.mouse.y), Std.int(tower.x), Std.int(tower.y), Std.int(tower.width),
						Std.int(tower.height)))
					{
						_towerSelected = tower;

						if (_sellMenu.visible || _sellConfirm.visible)
						{
							sellConfirmCheck();
						}
						else
						{
							toggleMenus(Upgrade);
						}

						selectedTower = true;

						break; // We've found the selected tower, can stop cycling through them
					}
				}

				// If the user didn't click on any towers, we go back to the general menu

				if (!selectedTower && FlxG.mouse.y < FlxG.height - 20)
				{
					toggleMenus(General);
				}
				#else
				// If the user tapped NEAR a tower, they get the upgrade menu.
				var nearestTower:Tower = getNearestTower(FlxG.mouse.x, FlxG.mouse.y, 20);

				if (nearestTower != null)
				{
					_towerSelected = nearestTower;

					if (_sellMenu.visible || _sellConfirm.visible)
					{
						sellConfirmCheck();
					}
					else
					{
						toggleMenus(Upgrade);
					}

					selectedTower = true;
				}

				// If the user didn't click near any towers, we go back to the general menu

				if (!selectedTower && (FlxG.mouse.y < FlxG.height - 20))
				{
					toggleMenus(General);
				}
				#end
			}
		}

		// If an enemy hits the goal, it will lose life and the enemy explodes

		FlxG.overlap(enemies, _goal, hitGoal);

		// If a bullet hits an enemy, it will lose health

		FlxG.overlap(bullets, enemies, hitEnemy);

		// Controls wave spawning, enemy spawning,

		if (enemiesToKill == 0 && _towers.length > 0)
		{
			_waveCounter -= Std.int(FlxG.timeScale);
			_nextWaveButton.text = "[N]ext Wave in " + Math.ceil(_waveCounter / FlxG.updateFramerate);

			if (_waveCounter <= 0)
			{
				spawnWave();
			}
		}
		else
		{
			_spawnCounter += Std.int(FlxG.timeScale);

			if (_spawnCounter > _spawnInterval * FlxG.updateFramerate && enemiesToSpawn > 0)
			{
				spawnEnemy();
			}
		}

		super.update(elapsed);
	} // End update

	#if mobile
	/**
	 * Used to get the nearest tower within a particular search radius. Makes selecting towers easier for touch screens.
	 *
	 * @param	X				The X position of the screen touch.
	 * @param	Y				The Y position of the screen touch.
	 * @param	SearchRadius	How far from the touch point to search.
	 * @return	The nearest tower, as a Tower object.
	 */
	function getNearestTower(X:Float, Y:Float, SearchRadius:Float):Tower
	{
		var minDistance:Float = SearchRadius;
		var closestTower:Tower = null;
		var searchPoint = FlxPoint.get(X, Y);

		for (tower in _towers)
		{
			var dist:Float = searchPoint.distanceTo(tower.getMidpoint());

			if (dist < minDistance)
			{
				closestTower = tower;
				minDistance = dist;
			}
		}

		return closestTower;
	}
	#end

	/**
	 * Called when an enemy collides with a goal. Explodes the enemy, damages the goal.
	 */
	function hitGoal(enemy:Enemy, goal:FlxSprite):Void
	{
		_numLives--;
		enemy.explode(false);

		if (_numLives >= 0)
			_lives.members[_numLives].kill();

		if (_numLives == 0)
			loseGame();

		FlxG.sound.play("hurt");
	}

	/**
	 * Called when a bullet hits an enemy. Damages the enemy, kills the bullet.
	 */
	function hitEnemy(bullet:Bullet, enemy:FlxSprite):Void
	{
		enemy.hurt(bullet.damage);
		bullet.kill();

		FlxG.sound.play("enemyhit");
	}

	/**
	 * Controls the displayed menu.
	 *
	 * @param	Menu	The desired menu; one of the enum constructors above this class.
	 */
	function toggleMenus(Menu:MenuType):Void
	{
		_sellConfirm.visible = false;
		_sellMenu.visible = false;
		_upgradeMenu.visible = false;
		_gui.visible = false;
		_towerRange.visible = false;

		switch (Menu)
		{
			case General:
				_towerSelected = null;
				_gui.visible = true;
				_buildingMode = false;
				_buildHelper.visible = false;
			case Upgrade:
				updateUpgradeLabels();
				_upgradeMenu.visible = true;
			case Sell:
				_sellMenu.visible = true;
			case ConfirmSell:
				_sellConfirm.visible = true;
		}

		playSelectSound();
	}

	/**
	 * A function that is called when the user enters build mode.
	 */
	function buildTowerCallback(Skip:Bool = false):Void
	{
		if (towerPrice > money)
			return;

		_buildingMode = !_buildingMode;
		#if !mobile
		_towerRange.visible = !_towerRange.visible;
		_buildHelper.visible = _buildingMode;
		#end

		playSelectSound();
	}

	/**
	 * A function that is called when the user changes game speed.
	 */
	function speedButtonCallback(Skip:Bool = false):Void
	{
		if (!_gui.visible && !Skip)
			return;

		if (_speed < 3)
			_speed += 1;
		else
			_speed = 1;

		FlxG.timeScale = _speed;
		_speedButton.text = "x" + _speed;

		playSelectSound();
	}

	/**
	 * A function that is called when the user wants to sell a tower.
	 */
	function sellButtonCallback(Skip:Bool = false):Void
	{
		if (!_gui.visible || _towers.length == 0)
			return;

		toggleMenus(Sell);

		if (_buildingMode)
		{
			_buildingMode = false;
			_towerRange.visible = false;
		}

		playSelectSound();
	}

	function sellConfirmCheck():Void
	{
		_areYouSure.text = "Tower value $" + _towerSelected.value + ", really sell?";

		toggleMenus(ConfirmSell);

		updateRangeSprite(_towerSelected.getMidpoint(), _towerSelected.range);
	}

	function sellConfirmCallback(Sure:Bool):Void
	{
		if (!_sellConfirm.visible)
			return;

		_towerRange.visible = false;

		if (Sure)
		{
			_towers.remove(_towerSelected, true);
			_towerSelected.visible = false;

			// Remove the indicator for this tower as well
			for (indicator in towerIndicators)
			{
				if (indicator.x == _towerSelected.getMidpoint().x - 1 && indicator.y == _towerSelected.getMidpoint().y - 1)
				{
					towerIndicators.remove(indicator, true);
					indicator.visible = false;
					indicator = null;
				}
			}

			// If there are no towers, having the tutorial text and sell button is a bit superfluous
			if (_towers.countLiving() == -1 && _towers.countDead() == -1)
			{
				_sellButton.visible = false;

				if (_tutText.visible)
					_tutText.visible = false;
			}

			// Give the player their money back
			money += _towerSelected.value;

			// Revert the next tower price
			towerPrice = Math.ceil(towerPrice / 1.3);

			// Null out the removed tower
			_towerSelected = null;

			// Go back to the general menu
			toggleMenus(General);
		}
		else
		{
			toggleMenus(General);
		}
	}

	function sellMenuCancel(Skip:Bool = false):Void
	{
		toggleMenus(General);
	}

	/**
	 * A function that is called when the user selects to call the next wave.
	 */
	function nextWaveCallback(Skip:Bool = false):Void
	{
		if (!_gui.visible && !Skip)
			return;

		if (enemiesToKill > 0)
			return;

		spawnWave();
		playSelectSound();
	}

	/**
	 * A function that is called when the user elects to restart, which is only possible after losing.
	 */
	function resetCallback(Skip:Bool = false):Void
	{
		if (!_gui.visible && !Skip)
			return;

		FlxG.resetState();
		playSelectSound();
	}

	/**
	 * A function that attempts to build a tower when the user clicks on the playable space. Must have money,
	 * and be building in a valid place (not on another tower, the road, or the GUI).
	 */
	function buildTower():Void
	{
		// Can't place towers on GUI
		if (FlxG.mouse.y > FlxG.height - 16)
		{
			return;
		}

		// Can't buy towers without money
		if (money < towerPrice)
		{
			FlxG.sound.play("deny");

			toggleMenus(General);
			return;
		}

		// Snap to grid
		var xPos:Float = FlxG.mouse.x - (FlxG.mouse.x % TILE_SIZE);
		var yPos:Float = FlxG.mouse.y - (FlxG.mouse.y % TILE_SIZE);

		// Can't place towers on other towers
		for (tower in _towers)
		{
			if (tower.x == xPos && tower.y == yPos)
			{
				FlxG.sound.play("deny");

				toggleMenus(General);
				return;
			}
		}

		// Can't place towers on the road
		if (_map.getTile(Std.int(xPos / TILE_SIZE), Std.int(yPos / TILE_SIZE)) == 0)
		{
			FlxG.sound.play("deny");

			toggleMenus(General);
			return;
		}

		_towers.add(new Tower(xPos, yPos, towerPrice));

		// After the first tower is bought, sell mode becomes available.
		if (_sellButton.visible == false)
			_sellButton.visible = true;

		// If this is the first tower the player has built, they get the tutorial text.
		// This is made invisible after they've bought an upgrade.
		if (_tutText.visible == false && _towers.length == 1)
			_tutText.visible = true;

		FlxG.sound.play("build");

		money -= towerPrice;
		towerPrice += Std.int(towerPrice * 0.3);
		_towerButton.text = "Buy [T]ower ($" + towerPrice + ")";
		toggleMenus(General);
	}

	/**
	 * The select sound gets played from a lot of places, so it's in a convenient function.
	 */
	function playSelectSound():Void
	{
		FlxG.sound.play("select");
	}

	/**
	 * Used to display either the wave number or Game Over message via the animated fly-in, fly-out text.
	 *
	 * @param	End		Whether or not this is the end of the game. If true, message will say "Game Over! :("
	 */
	function announceWave(End:Bool = false):Void
	{
		_centerText.x = -200;
		_centerText.text = "Wave " + wave;

		if (End)
			_centerText.text = "Game Over! :(";

		FlxTween.tween(_centerText, {x: 0}, 2, {ease: FlxEase.expoOut, onComplete: hideText});

		_waveText.text = "Wave: " + wave;
		_waveText.size = 16;
		_waveText.visible = true;
	}

	/**
	 * Hides the center text message display on announceWave, once the first tween is complete.
	 */
	function hideText(Tween:FlxTween):Void
	{
		FlxTween.tween(_centerText, {x: FlxG.width}, 2, {ease: FlxEase.expoIn});
	}

	/**
	 * Spawns the next wave. This increments the wave variable, displays the center text message,
	 * sets the number of enemies to spawn and kill, hides the next wave button, and shows the
	 * notification of the number of enemies.
	 */
	function spawnWave():Void
	{
		if (_gameOver)
			return;

		wave++;
		announceWave();
		enemiesToKill = 5 + wave;
		enemiesToSpawn = enemiesToKill;

		_nextWaveButton.visible = false;

		_enemyText.visible = true;
		_enemyText.size = 16;
	}

	/**
	 * Spawns an enemy. Decrements the enemiesToSpawn variable, and recycles an enemy from enemies and then initiates
	 * it and gives it a path to follow.
	 */
	function spawnEnemy():Void
	{
		enemiesToSpawn--;

		var enemy = enemies.recycle(Enemy.new.bind(0, 0));
		enemy.init(_enemySpawnPosition.x, _enemySpawnPosition.y - 12);
		enemy.followPath(_map.findPath(_enemySpawnPosition, _goalPosition.copyTo().add(5, 5)), 20 + Reg.PS.wave);
		_spawnCounter = 0;
	}

	/**
	 * Called when you lose. Of course!
	 */
	function loseGame():Void
	{
		_gameOver = true;

		enemies.kill();
		towerIndicators.kill();
		_towers.kill();
		_upgradeMenu.kill();
		_towerRange.kill();

		announceWave(true);

		_towerButton.text = "[R]estart";
		_towerButton.onDown.callback = resetCallback.bind(false);

		FlxG.sound.play("gameover");
	}

	/**
	 * Called either when building, or upgrading, a tower.
	 */
	function updateRangeSprite(Center:FlxPoint, Range:Int):Void
	{
		_towerRange.setPosition(Center.x - Range, Center.y - Range);
		_towerRange.makeGraphic(Range * 2, Range * 2, FlxColor.TRANSPARENT);

		// Using and re-using a static sprite like this reduces garbage creation.

		RANGE_SPRITE = new Sprite();
		RANGE_SPRITE.graphics.beginFill(0xFFFFFF);
		RANGE_SPRITE.graphics.drawCircle(Range, Range, Range);
		RANGE_SPRITE.graphics.endFill();

		_towerRange.pixels.draw(RANGE_SPRITE);

		#if flash
		_towerRange.blend = BlendMode.INVERT;
		#else
		_towerRange.alpha = 0.5;
		#end

		_towerRange.visible = true;
	}

	/**
	 * Called when the user attempts to update range. If they have enough money, the upgradeRange() function
	 * for this tower is called, and the money is decreased.
	 */
	function upgradeRangeCallback():Void
	{
		if (!_upgradeMenu.visible)
			return;

		if (money >= _towerSelected.rangePrice)
		{
			money -= _towerSelected.rangePrice;
			_towerSelected.upgradeRange();
			upgradeHelper();
		}
	}

	/**
	 * Called when the user attempts to update damage. If they have enough money, the upgradeDamage() function
	 * for this tower is called, and the money is decreased.
	 */
	function upgradeDamageCallback():Void
	{
		if (!_upgradeMenu.visible)
			return;

		if (money >= _towerSelected.damagePrice)
		{
			money -= _towerSelected.damagePrice;
			_towerSelected.upgradeDamage();
			upgradeHelper();
		}
	}

	/**
	 * Called when the user attempts to update fire rate. If they have enough money, the upgradeFirerate() function
	 * for this tower is called, and the money is decreased.
	 */
	function upgradeFirerateCallback():Void
	{
		if (!_upgradeMenu.visible)
			return;

		if (money >= _towerSelected.fireRatePrice)
		{
			money -= _towerSelected.fireRatePrice;
			_towerSelected.upgradeFirerate();
			upgradeHelper();
		}
	}

	/**
	 * Called after an upgrade. Updates button text, plays a sound, and sets the upgrade bought flag to true.
	 */
	function upgradeHelper():Void
	{
		updateUpgradeLabels();
		playSelectSound();

		if (_tutText.visible)
			_tutText.visible = false;
	}

	/**
	 * Update button labels for upgrades, and makes sure the range indicator sprite is updated.
	 */
	function updateUpgradeLabels():Void
	{
		_rangeButton.text = "Range (" + _towerSelected.rangeLevel + "): $" + _towerSelected.rangePrice;
		_damageButton.text = "Damage (" + _towerSelected.damageLevel + "): $" + _towerSelected.damagePrice;
		_firerateButton.text = "Firerate (" + _towerSelected.fireRateLevel + "): $" + _towerSelected.fireRatePrice;

		updateRangeSprite(_towerSelected.getMidpoint(), _towerSelected.range);
	}

	function set_money(NewMoney:Int):Int
	{
		money = NewMoney;
		_moneyText.text = "$: " + money;
		_moneyText.size = 16;

		return money;
	}
}
