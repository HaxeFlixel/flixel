package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;

/**
 * @author Zaphod
 */
class PlayState extends FlxState
{
	static var _justDied:Bool = false;

	var _level:FlxTilemap;
	var _player:FlxSprite;
	var _exit:FlxSprite;
	var _scoreText:FlxText;
	var _status:FlxText;
	var _coins:FlxGroup;

	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xffaaaaaa;

		_level = new FlxTilemap();
		_level.loadMapFromCSV("assets/level.csv", FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
		add(_level);

		// Create the _level _exit
		_exit = new FlxSprite(35 * 8 + 1, 25 * 8);
		_exit.makeGraphic(14, 16, FlxColor.GREEN);
		_exit.exists = false;
		add(_exit);

		// Create _coins to collect (see createCoin() function below for more info)
		_coins = new FlxGroup();

		// Top left _coins
		createCoin(18, 4);
		createCoin(12, 4);
		createCoin(9, 4);
		createCoin(8, 11);
		createCoin(1, 7);
		createCoin(3, 4);
		createCoin(5, 2);
		createCoin(15, 11);
		createCoin(16, 11);

		// Bottom left _coins
		createCoin(3, 16);
		createCoin(4, 16);
		createCoin(1, 23);
		createCoin(2, 23);
		createCoin(3, 23);
		createCoin(4, 23);
		createCoin(5, 23);
		createCoin(12, 26);
		createCoin(13, 26);
		createCoin(17, 20);
		createCoin(18, 20);

		// Top right _coins
		createCoin(21, 4);
		createCoin(26, 2);
		createCoin(29, 2);
		createCoin(31, 5);
		createCoin(34, 5);
		createCoin(36, 8);
		createCoin(33, 11);
		createCoin(31, 11);
		createCoin(29, 11);
		createCoin(27, 11);
		createCoin(25, 11);
		createCoin(36, 14);

		// Bottom right _coins
		createCoin(38, 17);
		createCoin(33, 17);
		createCoin(28, 19);
		createCoin(25, 20);
		createCoin(18, 26);
		createCoin(22, 26);
		createCoin(26, 26);
		createCoin(30, 26);

		add(_coins);

		// Create _player
		_player = new FlxSprite(FlxG.width / 2 - 5);
		_player.makeGraphic(8, 8, FlxColor.RED);
		_player.maxVelocity.set(80, 200);
		_player.acceleration.y = 200;
		_player.drag.x = _player.maxVelocity.x * 4;
		add(_player);

		_scoreText = new FlxText(2, 2, 80, "SCORE: " + (_coins.countDead() * 100));
		_scoreText.setFormat(null, 8, FlxColor.WHITE, null, NONE, FlxColor.BLACK);
		add(_scoreText);

		_status = new FlxText(FlxG.width - 160 - 2, 2, 160, "Collect coins.");
		_status.setFormat(null, 8, FlxColor.WHITE, RIGHT, NONE, FlxColor.BLACK);

		if (_justDied)
		{
			_status.text = "Aww, you died!";
		}

		add(_status);
	}

	override public function update(elapsed:Float):Void
	{
		_player.acceleration.x = 0;

		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_player.acceleration.x = -_player.maxVelocity.x * 4;
		}

		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x = _player.maxVelocity.x * 4;
		}

		if (FlxG.keys.anyJustPressed([SPACE, UP, W]) && _player.isTouching(FLOOR))
		{
			_player.velocity.y = -_player.maxVelocity.y / 2;
		}

		super.update(elapsed);

		FlxG.overlap(_coins, _player, getCoin);
		FlxG.collide(_level, _player);
		FlxG.overlap(_exit, _player, win);

		if (_player.y > FlxG.height)
		{
			_justDied = true;
			FlxG.resetState();
		}
	}

	/**
	 * Creates a new coin located on the specified tile
	 */
	function createCoin(X:Int, Y:Int):Void
	{
		var coin:FlxSprite = new FlxSprite(X * 8 + 3, Y * 8 + 2);
		coin.makeGraphic(2, 4, 0xffffff00);
		_coins.add(coin);
	}

	function win(Exit:FlxObject, Player:FlxObject):Void
	{
		_status.text = "Yay, you won!";
		_scoreText.text = "SCORE: 5000";
		_player.kill();
	}

	function getCoin(Coin:FlxObject, Player:FlxObject):Void
	{
		Coin.kill();
		_scoreText.text = "SCORE: " + (_coins.countDead() * 100);

		if (_coins.countLiving() == 0)
		{
			_status.text = "Find the exit";
			_exit.exists = true;
		}
	}
}
