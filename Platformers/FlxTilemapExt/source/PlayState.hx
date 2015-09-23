package;

import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
import flixel.tile.FlxTile;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import openfl.Assets;

class PlayState extends FlxState
{
	/**
	 * Reference to the player
	 */
	private var _player:FlxSprite;
	/**
	 * Major game object storage
	 */
	private var _blocks:FlxGroup;
	private var _hud:FlxGroup;
	/**
	 * Meta groups, to help speed up collisions
	 */
	private var _objects:FlxGroup;
	/**
	 * HUD / User Interface stuff
	 */
	private var _levelText:FlxText;
	/**
	 * Tilemap Stuff
	 */
	private var level:FlxTilemapExt;
	
	override public function create():Void
	{
		level = new FlxTilemapExt();
		
		FlxG.mouse.visible = false;
		
		_hud = new FlxGroup();

		FlxG.cameras.bgColor = 0xff050509;
		
		// Create player (a red box)
		_player = new FlxSprite(70, 20);
		_player.makeGraphic(8, 14, FlxColor.LIME);
		
		// Max velocities on player.  If it's a platformer, Y should be high, like 200.
		// Otherwise, set them to something like 80.
		_player.maxVelocity.set(120, 220);
		
		// Simulate Gravity on the Player
		_player.acceleration.y = 200;
		
		_player.drag.x = _player.maxVelocity.x * 4;
		add(_player);
		
		// Load in the Level and Define Arrays for different slope types
		add(level.loadMapFromCSV(Assets.getText("assets/slopemap.txt"), "assets/colortiles.png", 10, 10));
		
		// tile tearing problem fix
		var levelTiles:FlxTileFrames = FlxTileFrames.fromBitmapAddSpacesAndBorders("assets/colortiles.png", new FlxPoint(10, 10), new FlxPoint(2, 2), new FlxPoint(2, 2));
		level.frames = levelTiles;
		level.useScaleHack = false;
		
		var tempFL:Array<Int> = [5, 9, 10, 13, 15];
		var tempFR:Array<Int> = [6, 11, 12, 14, 16];
		var tempCL:Array<Int> = [7, 17, 18, 21, 23];
		var tempCR:Array<Int> = [8, 19, 20, 22, 24];
		
		//var tempC:Array<Int> = [4];
		
		level.setSlopes(tempFL, tempFR, tempCL, tempCR);
		//level.setClouds(tempC);
		
		level.setSlopes22([10, 11, 18, 19], [9, 12, 17, 20]);
		level.setSlopes67([13, 14, 21, 22], [15, 16, 23, 24]);
		
		level.setTileProperties(4, FlxObject.NONE, downClouds);
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
	
	private function downClouds(Tile:FlxObject, Object:FlxObject):Void
	{
		Tile.allowCollisions = (FlxG.keys.anyPressed([DOWN, S])) ? FlxObject.NONE : FlxObject.CEILING;
	}
	
	private function wallJump(Tile:FlxObject, Object:FlxObject):Void
	{
		if (Object.velocity.y > 0)
		{
			Object.velocity.y *= 0.9;
			Object.touching |= FlxObject.FLOOR;
		}
	}
	
	override public function destroy():Void
	{
		super.destroy();
		
		_blocks = null;
		_hud = null;
		
		// Meta groups, to help speed up collisions
		_objects = null;
	}
	
	override public function update(elapsed:Float):Void
	{
		_player.acceleration.x = 0;
		
		if (FlxG.keys.anyPressed([LEFT, A]))
		{
			_player.acceleration.x = -_player.maxVelocity.x * ((_player.isTouching(FlxObject.FLOOR))?4:3);
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x = _player.maxVelocity.x * ((_player.isTouching(FlxObject.FLOOR))?4:3);
		}
		if (FlxG.keys.anyPressed([SPACE, W, UP]) && _player.isTouching(FlxObject.FLOOR))
		{
			_player.velocity.y = -_player.maxVelocity.y / 2;
			if (_player.isTouching(FlxObject.RIGHT))
			{
				_player.velocity.x = -_player.maxVelocity.x;
			}
			else if (_player.isTouching(FlxObject.LEFT))
			{
				_player.velocity.x = _player.maxVelocity.x;
			}
		}
		
		if (FlxG.keys.anyJustPressed([G])) {
			_player.acceleration.y = -_player.acceleration.y;
		}
		
		super.update(elapsed);
		
		FlxG.collide(level, _player);
	}	
}