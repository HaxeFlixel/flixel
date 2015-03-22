package;

import flixel.addons.tile.FlxTilemapExt;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup;
import flixel.text.FlxText;
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
		_player = new FlxSprite(70);
		_player.makeGraphic(8, 10, FlxColor.RED);
		
		// Max velocities on player.  If it's a platformer, Y should be high, like 200.
		// Otherwise, set them to something like 80.
		_player.maxVelocity.set(120, 200);
		
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
		
		var tempFL:Array<Int> = [5, 13, 21];
		var tempFR:Array<Int> = [6, 14, 22];
		var tempCL:Array<Int> = [7, 15, 23];
		var tempCR:Array<Int> = [8, 16, 24];
		
		var tempC:Array<Int> = [4, 12, 20];
		
		level.setSlopes(tempFL, tempFR, tempCL, tempCR);
		level.setClouds(tempC);
		
		// Make the Camera follow the player.
		FlxG.camera.setScrollBoundsRect(0, 0, 970, 500, true);
		FlxG.camera.follow(_player, PLATFORMER);
		
		//HUD
		add(_hud);
		
		_levelText = new FlxText(FlxG.width - 100, 0, 100);
		_levelText.setFormat(null, 8, 0xFFFFFFFF, RIGHT);
		_levelText.text = "Slope Test";
		_levelText.scrollFactor.set();
		_hud.add(_levelText);
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
			_player.acceleration.x = -_player.maxVelocity.x * 4;
		}
		if (FlxG.keys.anyPressed([RIGHT, D]))
		{
			_player.acceleration.x = _player.maxVelocity.x * 4;
		}
		if (FlxG.keys.anyPressed([SPACE, W, UP]) && _player.isTouching(FlxObject.FLOOR))
		{
			_player.velocity.y = -_player.maxVelocity.y / 2;
		}
		
		super.update(elapsed);
		
		FlxG.collide(level, _player);	
	}	
}