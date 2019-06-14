package;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import openfl.Assets;

class PlayState extends FlxState
{
	var _level:FlxTilemap;
	var _player1:FlxSprite;
	var _player2:FlxSprite;

	var _halfWidth:Int;
	var _textY:Int;

	override public function create():Void
	{
		FlxG.mouse.visible = false;

		// Set the background color to white
		FlxG.cameras.bgColor = FlxColor.WHITE;

		// Create the tilemap from the levelData we just created
		_level = new FlxTilemap();
		_level.loadMapFromCSV("assets/level.csv", FlxGraphic.fromClass(GraphicAuto), 0, 0, AUTO);
		add(_level);

		_halfWidth = Std.int(FlxG.width / 2);
		_textY = FlxG.height - 24;

		// Player1 is red and starts at 265, 200
		_player1 = createPlayer(265, 200, FlxColor.RED);
		add(_player1);

		// Player 2 is blue and starts at 65, 200
		_player2 = createPlayer(65, 200, FlxColor.BLUE);
		add(_player2);

		// Then we setup two cameras to follow each of the two players
		createCamera(_halfWidth, 0xFFFFCCCC, _player1);
		createCamera(0, 0xFFCCCCFF, _player2);

		// Some instructions
		var textBG:FlxSprite = new FlxSprite(0, _textY);
		textBG.makeGraphic(FlxG.width, 24, FlxColor.BLACK);
		add(textBG);

		var blueText:FlxText = new FlxText(0, _textY, _halfWidth, "WASD");
		blueText.setFormat(null, 16, FlxColor.BLUE, CENTER);
		add(blueText);

		var redText:FlxText = new FlxText(_halfWidth, _textY, _halfWidth, "Arrow keys", 16);
		redText.setFormat(null, 16, FlxColor.RED, CENTER);
		add(redText);
	}

	function createPlayer(X:Int, Y:Int, Color:Int):FlxSprite
	{
		var player:FlxSprite = new FlxSprite(X, Y);
		player.makeGraphic(10, 12, Color);
		player.maxVelocity.set(100, 200);
		player.acceleration.y = 200;
		player.drag.x = player.maxVelocity.x * 4;

		return player;
	}

	function createCamera(X:Int, Color:Int, Follow:FlxSprite):Void
	{
		var camera:FlxCamera = new FlxCamera(X, 0, _halfWidth, _textY);
		camera.setScrollBoundsRect(0, 0, _level.width - 8, _textY);
		camera.bgColor = Color;
		camera.follow(Follow);
		FlxG.cameras.add(camera);
	}

	override public function update(elapsed:Float):Void
	{
		// Collide everything
		FlxG.collide();

		// Player 1 controls
		_player1.acceleration.x = 0;

		if (FlxG.keys.pressed.LEFT)
		{
			_player1.acceleration.x = -_player1.maxVelocity.x * 4;
		}

		if (FlxG.keys.pressed.RIGHT)
		{
			_player1.acceleration.x = _player1.maxVelocity.x * 4;
		}

		if (FlxG.keys.justPressed.UP && _player1.isTouching(FlxObject.FLOOR))
		{
			_player1.velocity.y -= _player1.maxVelocity.y / 1.5;
		}

		// Player 2 controls
		_player2.acceleration.x = 0;

		if (FlxG.keys.pressed.A)
		{
			_player2.acceleration.x = -_player2.maxVelocity.x * 4;
		}

		if (FlxG.keys.pressed.D)
		{
			_player2.acceleration.x = _player2.maxVelocity.x * 4;
		}

		if (FlxG.keys.justPressed.W && _player2.isTouching(FlxObject.FLOOR))
		{
			_player2.velocity.y -= _player2.maxVelocity.y / 1.5;
		}

		super.update(elapsed);
	}
}
