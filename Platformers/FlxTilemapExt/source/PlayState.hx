package;

import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxTileFrames;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	private var _player:FlxSprite;
	private var _blocks:FlxGroup;
	private var _hud:FlxGroup;
	private var _objects:FlxGroup;
	private var _levelText:FlxText;
	private var level:FlxTilemapExt;
	
	override public function create():Void
	{
		FlxG.mouse.visible = false;
		FlxG.cameras.bgColor = 0xff050509;

		level = new FlxTilemapExt();
		_hud = new FlxGroup();
			
		// Create player (a red box)
		_player = new FlxSprite(70, 20);
		_player.makeGraphic(8, 14, FlxColor.RED);
		
		// Max velocities on player. If it's a platformer, Y should be high, like 220.
		// Otherwise, set them to something like 80.
		_player.maxVelocity.set(120, 220);
		
		// Simulate Gravity on the Player
		_player.acceleration.y = 200;
		
		_player.drag.x = _player.maxVelocity.x * 4;
		add(_player);
		
		// Load in the Level and Define Arrays for different slope types
		add(level.loadMapFromCSV("assets/slopemap.txt", "assets/colortiles.png", 10, 10));
		
		// tile tearing problem fix
		var levelTiles = FlxTileFrames.fromBitmapAddSpacesAndBorders("assets/colortiles.png",
			new FlxPoint(10, 10), new FlxPoint(2, 2), new FlxPoint(2, 2));
		level.frames = levelTiles;
		level.useScaleHack = false;
		
		var tempNW:Array<Int> = [5, 9, 10, 13, 15];
		var tempNE:Array<Int> = [6, 11, 12, 14, 16];
		var tempSW:Array<Int> = [7, 17, 18, 21, 23];
		var tempSE:Array<Int> = [8, 19, 20, 22, 24];
		
		level.setSlopes(tempNW, tempNE, tempSW, tempSE);
		
		//set tiles steepness
		level.setGentle([10, 11, 18, 19], [9, 12, 17, 20]);
		level.setSteep([13, 14, 21, 22], [15, 16, 23, 24]);
		
		//set cloud tiles
		level.setTileProperties(4, FlxObject.NONE, fallInClouds);
		
		//set wallJump tiles
		level.setTileProperties(3, level.getTileCollisions(3), wallJump);
		
		// Make the Camera follow the player.
		FlxG.camera.setScrollBoundsRect(0, 0, 500, 500, true);
		FlxG.camera.follow(_player, PLATFORMER);
		
		//HUD
		add(_hud);
		
		_levelText = new FlxText(FlxG.width - 100, 0, 100);
		_levelText.setFormat(null, 8, 0xFFFFFFFF, RIGHT);
		_levelText.text = "G -> Gravity";
		_levelText.scrollFactor.set();
		_hud.add(_levelText);
	}
	
	private function fallInClouds(Tile:FlxObject, Object:FlxObject):Void
	{
		if (FlxG.keys.anyPressed([DOWN, S]))
		{
			Tile.allowCollisions = FlxObject.NONE;
		}
		else if (Object.y >= Tile.y)
		{
			Tile.allowCollisions = FlxObject.CEILING;
		}
	}
	
	private function wallJump(Tile:FlxObject, Object:FlxObject):Void
	{
		Object.velocity.y *= 0.9;
		Object.touching |= FlxObject.FLOOR | FlxObject.CEILING;
	}
	
	private function wallJumpReflect():Void
	{
		if (_player.isTouching(FlxObject.RIGHT))
		{
			_player.velocity.x = -_player.maxVelocity.x;
		}
		else if (_player.isTouching(FlxObject.LEFT))
		{
			_player.velocity.x = _player.maxVelocity.x;
		}
	}
	
	override public function update(elapsed:Float):Void
	{
		_player.acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_player.acceleration.x = -_player.maxVelocity.x * ((_player.isTouching(FlxObject.FLOOR)) ? 4 : 3);
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x = _player.maxVelocity.x * ((_player.isTouching(FlxObject.FLOOR)) ? 4 : 3);
		}
		
		//Jump
		if (FlxG.keys.anyPressed([SPACE, W, UP]) && _player.isTouching(FlxObject.FLOOR) && _player.acceleration.y > 0)
		{
			_player.velocity.y = -_player.maxVelocity.y / 2;
			
			wallJumpReflect();
		}
		else if (FlxG.keys.anyPressed([S, DOWN]) && _player.isTouching(FlxObject.CEILING) && _player.acceleration.y < 0)
		{
			_player.velocity.y = _player.maxVelocity.y / 2;
			
			wallJumpReflect();
		}
		
		//Turn gravity direction
		if (FlxG.keys.anyJustPressed([G]))
		{
			_player.acceleration.y = -_player.acceleration.y;
		}
		
		super.update(elapsed);
		
		FlxG.collide(level, _player);
	}	
}