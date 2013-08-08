package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxSpriteUtil;
import openfl.Assets;

class PlayState extends FlxState
{
	/**
	 * Some static constants for the size of the tilemap tiles
	 */
	inline static private var TILE_WIDTH:Int = 16;
	inline static private var TILE_HEIGHT:Int = 16;
	
	/**
	 * The FlxTilemap we're using
	 */ 
	private var _collisionMap:FlxTilemap;
	
	/**
	 * Box to show the user where they're placing stuff
	 */ 
	private var _highlightBox:FlxObject;
	
	/**
	 * Player modified from "Mode" demo
	 */ 
	private var _player:FlxSprite;
	
	/**
	 * Some interface buttons and text
	 */
	private var _autoAltButton:FlxButton;
	private var _resetButton:FlxButton;
	private var _helperText:FlxText;
	
	override public function create():Void
	{
		// Creates a new tilemap with no arguments
		_collisionMap = new FlxTilemap();
		
		/*
		 * FlxTilemaps are created using strings of comma seperated values (csv)
		 * This string ends up looking something like this:
		 *
		 * 0,0,0,0,0,0,0,0,0,0,
		 * 0,0,0,0,0,0,0,0,0,0,
		 * 0,0,0,0,0,0,1,1,1,0,
		 * 0,0,1,1,1,0,0,0,0,0,
		 * ...
		 *
		 * Each '0' stands for an empty tile, and each '1' stands for
		 * a solid tile
		 *
		 * When using the auto map generation, the '1's are converted into the corresponding frame
		 * in the tileset.
		 */
		
		// Initializes the map using the generated string, the tile images, and the tile size
		_collisionMap.loadMap(Assets.getText("assets/default_auto.txt"), "assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(_collisionMap);
		
		_highlightBox = new FlxObject(0, 0, TILE_WIDTH, TILE_HEIGHT);
		
		setupPlayer();
		
		// When switching between modes here, the map is reloaded with it's own data, so the positions of tiles are kept the same
		// Notice that different tilesets are used when the auto mode is switched
		_autoAltButton = new FlxButton(4, FlxG.height - 24, "AUTO", onAlt);
		add(_autoAltButton);
		
		_resetButton = new FlxButton(8 + _autoAltButton.width, FlxG.height - 24, "Reset", onReset); 
		add(_resetButton);
		
		_helperText = new FlxText(20 + _autoAltButton.width * 2, FlxG.height - 26, 300, "Click to place tiles, shift-click to remove\nArrow keys / WASD to move");
		add(_helperText);
	}
	
	private function setupPlayer():Void
	{
		_player = new FlxSprite(64, 220);
		_player.loadGraphic("assets/spaceman.png", true, true, 16);
		
		// Bounding box tweaks
		_player.setSize(14, 14);
		_player.offset.set(1, 1);
		
		// Basic player physics
		_player.drag.x = 640;
		_player.acceleration.y = 420;
		_player.maxVelocity.set(120, 200);
		
		// Animations
		_player.addAnimation("idle", [0]);
		_player.addAnimation("run", [1, 2, 3, 0], 12);
		_player.addAnimation("jump", [4]);
		
		add(_player);
	}
	
	override public function update():Void
	{
		// Tilemaps can be collided just like any other FlxObject, and flixel
		// automatically collides each individual tile with the object.
		FlxG.collide(_player, _collisionMap);
		
		_highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
		_highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
		
		if (FlxG.mouse.pressed)
		{
			// FlxTilemaps can be manually edited at runtime as well.
			// Setting a tile to 0 removes it, and setting it to anything else will place a tile.
			// If auto map is on, the map will automatically update all surrounding tiles.
			_collisionMap.setTile(Std.int(FlxG.mouse.x / TILE_WIDTH), Std.int(FlxG.mouse.y / TILE_HEIGHT), FlxG.keys.pressed.SHIFT ? 0 : 1);
		}
		
		updatePlayer();
		super.update();
	}
	
	private function updatePlayer():Void
	{
		FlxSpriteUtil.screenWrap(_player);
		
		// MOVEMENT
		_player.acceleration.x = 0;
		
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.A)
		{
			_player.facing = FlxObject.LEFT;
			_player.acceleration.x -= _player.drag.x;
		}
		else if (FlxG.keys.pressed.RIGHT || FlxG.keys.pressed.D)
		{
			_player.facing = FlxObject.RIGHT;
			_player.acceleration.x += _player.drag.x;
		}
		if ((FlxG.keys.justPressed.UP || FlxG.keys.justPressed.W) && _player.velocity.y == 0)
		{
			_player.y -= 1;
			_player.velocity.y = -200;
		}
		
		// ANIMATION
		if (_player.velocity.y != 0)
		{
			_player.play("jump");
		}
		else if (_player.velocity.x == 0)
		{
			_player.play("idle");
		}
		else
		{
			_player.play("run");
		}
	}
	
	override public function draw():Void
	{
		super.draw();
		_highlightBox.drawDebug();
	}
	
	private function onAlt():Void
	{
		switch (_collisionMap.auto)
		{
			case FlxTilemap.AUTO:
				_collisionMap.loadMap(FlxTilemap.arrayToCSV(_collisionMap.getData(true), _collisionMap.widthInTiles),
					"assets/alt_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
				_autoAltButton.label.text = "ALT";
					
			case FlxTilemap.ALT:
				_collisionMap.loadMap(FlxTilemap.arrayToCSV(_collisionMap.getData(true), _collisionMap.widthInTiles),
					"assets/empty_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
				_autoAltButton.label.text = "OFF";
					
			case FlxTilemap.OFF:
				_collisionMap.loadMap(FlxTilemap.arrayToCSV(_collisionMap.getData(true), _collisionMap.widthInTiles),
					"assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				_autoAltButton.label.text = "AUTO";
		}
	}
	
	private function onReset():Void
	{
		switch (_collisionMap.auto)
		{
			case FlxTilemap.AUTO:
				_collisionMap.loadMap(Assets.getText("assets/default_auto.txt"), "assets/auto_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
				_player.setPosition(64, 220);
				
			case FlxTilemap.ALT:
				_collisionMap.loadMap(Assets.getText("assets/default_alt.txt"), "assets/alt_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
				_player.setPosition(64, 128);
				
			case FlxTilemap.OFF:
				_collisionMap.loadMap(Assets.getText("assets/default_empty.txt"), "assets/empty_tiles.png", TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
				_player.setPosition(64, 64);
		}
	}
}