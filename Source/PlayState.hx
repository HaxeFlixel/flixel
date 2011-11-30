package;

import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxObject;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;



class PlayState extends FlxState
{
	// Some static constants for the size of the tilemap tiles
	private var TILE_WIDTH:Int;
	private var TILE_HEIGHT:Int;
	
	// The FlxTilemap we're using
	private var collisionMap:FlxTilemap;
	
	// Box to show the user where they're placing stuff
	private var highlightBox:FlxObject;
	
	// Player modified from "Mode" demo
	private var player:FlxSprite;
	
	// Some interface buttons and text
	private var autoAltBtn:FlxButton;
	private var resetBtn:FlxButton;
	private var quitBtn:FlxButton;
	private var helperTxt:FlxText;
	
	public function new()
	{
		TILE_WIDTH = 16;
		TILE_HEIGHT = 16;
		
		super();
	}
	
	override public function create():Void
	{
		FlxG.framerate = 50;
		FlxG.flashFramerate = 50;
		
		// Creates a new tilemap with no arguments
		collisionMap = new FlxTilemap();
		
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
		var textBytes = ApplicationMain.getAsset("assets/default_auto.txt");
		var testing:String = textBytes.readUTFBytes(textBytes.length);
		collisionMap.loadMap(testing, FlxAssets.imgAutoTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
		add(collisionMap);
		
		highlightBox = new FlxObject(0, 0, TILE_WIDTH, TILE_HEIGHT);
		
		setupPlayer();
		
		// When switching between modes here, the map is reloaded with it's own data, so the positions of tiles are kept the same
		// Notice that different tilesets are used when the auto mode is switched
		autoAltBtn = new FlxButton(4, FlxG.height - 24, "AUTO", function():Void
		{
			switch(collisionMap.auto)
			{
				case FlxTilemap.AUTO:
					collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
						FlxAssets.imgAltTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
					autoAltBtn.label.text = "ALT";
					
				case FlxTilemap.ALT:
					collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
						FlxAssets.imgEmptyTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
					autoAltBtn.label.text = "OFF";
					
				case FlxTilemap.OFF:
					collisionMap.loadMap(FlxTilemap.arrayToCSV(collisionMap.getData(true), collisionMap.widthInTiles),
						FlxAssets.imgAutoTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
					autoAltBtn.label.text = "AUTO";
			}
			
		});
		add(autoAltBtn);
		
		resetBtn = new FlxButton(8 + autoAltBtn.width, FlxG.height - 24, "Reset", function():Void
		{
			var textBytes = ApplicationMain.getAsset("assets/default_auto.txt");
			var testing:String = textBytes.readUTFBytes(textBytes.length);
			
			switch(collisionMap.auto)
			{
				case FlxTilemap.AUTO:
					collisionMap.loadMap(testing, FlxAssets.imgAutoTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.AUTO);
					player.x = 64;
					player.y = 220;
					
				case FlxTilemap.ALT:
					textBytes = ApplicationMain.getAsset("assets/default_alt.txt");
					testing = textBytes.readUTFBytes(textBytes.length);
					collisionMap.loadMap(testing, FlxAssets.imgAltTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.ALT);
					player.x = 64;
					player.y = 128;
					
				case FlxTilemap.OFF:
					textBytes = ApplicationMain.getAsset("assets/default_empty.txt");
					testing = textBytes.readUTFBytes(textBytes.length);
					collisionMap.loadMap(testing, FlxAssets.imgEmptyTiles, TILE_WIDTH, TILE_HEIGHT, FlxTilemap.OFF);
					player.x = 64;
					player.y = 64;
			}
		});
		add(resetBtn);
		
		quitBtn = new FlxButton(FlxG.width - resetBtn.width - 4, FlxG.height - 24, "Quit",
			function():Void { FlxG.fade(0xff000000, 0.22, function():Void { FlxG.switchState(new MenuState()); } ); } );
		add(quitBtn);
		
		helperTxt = new FlxText(12 + autoAltBtn.width * 2, FlxG.height - 30, 150, "Click to place tiles\nShift-Click to remove tiles\nArrow keys to move");
		add(helperTxt);
	}
	
	override public function update():Void
	{
		// Tilemaps can be collided just like any other FlxObject, and flixel
		// automatically collides each individual tile with the object.
		FlxG.collide(player, collisionMap);
		
		highlightBox.x = Math.floor(FlxG.mouse.x / TILE_WIDTH) * TILE_WIDTH;
		highlightBox.y = Math.floor(FlxG.mouse.y / TILE_HEIGHT) * TILE_HEIGHT;
		
		if (FlxG.mouse.pressed())
		{
			// FlxTilemaps can be manually edited at runtime as well.
			// Setting a tile to 0 removes it, and setting it to anything else will place a tile.
			// If auto map is on, the map will automatically update all surrounding tiles.
			collisionMap.setTile(Std.int(FlxG.mouse.x / TILE_WIDTH), Std.int(FlxG.mouse.y / TILE_HEIGHT), FlxG.keys.SHIFT?0:1);
		}
		
		updatePlayer();
		super.update();
	}
	
	public override function draw():Void
	{
		super.draw();
		highlightBox.drawDebug();
	}
	
	private function setupPlayer():Void
	{
		player = new FlxSprite(64, 220);
		player.loadGraphic(FlxAssets.imgSpaceman, true, true, 16);
		
		//bounding box tweaks
		player.width = 14;
		player.height = 14;
		player.offset.x = 1;
		player.offset.y = 1;
		
		//basic player physics
		player.drag.x = 640;
		player.acceleration.y = 420;
		player.maxVelocity.x = 80;
		player.maxVelocity.y = 200;
		
		//animations
		player.addAnimation("idle", [0]);
		player.addAnimation("run", [1, 2, 3, 0], 12);
		player.addAnimation("jump", [4]);
		
		add(player);
	}
	
	private function updatePlayer():Void
	{
		wrap(player);
		
		//MOVEMENT
		player.acceleration.x = 0;
		if(FlxG.keys.LEFT)
		{
			player.facing = FlxObject.LEFT;
			player.acceleration.x -= player.drag.x;
		}
		else if(FlxG.keys.RIGHT)
		{
			player.facing = FlxObject.RIGHT;
			player.acceleration.x += player.drag.x;
		}
		if(FlxG.keys.justPressed("UP") && player.velocity.y == 0)
		{
			player.y -= 1;
			player.velocity.y = -200;
		}
		
		//ANIMATION
		if(player.velocity.y != 0)
		{
			player.play("jump");
		}
		else if(player.velocity.x == 0)
		{
			player.play("idle");
		}
		else
		{
			player.play("run");
		}
	}
	
	private function wrap(obj:FlxObject):Void
	{
		obj.x = (obj.x + obj.width / 2 + FlxG.width) % FlxG.width - obj.width / 2;
		obj.y = (obj.y + obj.height / 2) % FlxG.height - obj.height / 2;
	}
}