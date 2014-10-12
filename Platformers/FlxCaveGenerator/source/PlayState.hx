package;

import flixel.addons.tile.FlxCaveGenerator;
import flixel.addons.ui.FlxSlider;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.util.FlxSpriteUtil;
import haxe.Timer;

class PlayState extends FlxState
{
	private var _tilemap:FlxTilemap;
	private var _player:Player;
	private var _smoothingIterations:Int = 6;
	private var _wallRatio:Float = 0.5;
	private var _generationTime:FlxText;
	
	override public function create():Void 
	{
		FlxG.cameras.bgColor = FlxColor.BLACK;
		
		// Create the tilemap for the cave
		_tilemap = new FlxTilemap();
		
		// A little player character
		_player = new Player(0, 0);
		
		// Create some UI
		var UI_WIDTH:Int = 200;
		var UI_POS_X:Int = FlxG.width - UI_WIDTH;
		
		var uiBackground:FlxSprite = new FlxSprite(UI_POS_X, 0);
		uiBackground.makeGraphic(UI_WIDTH, 245, FlxColor.WHITE);
		uiBackground.alpha = 0.85;
		
		var title:FlxText = new FlxText(UI_POS_X, 2, UI_WIDTH, "FlxCaveGenerator");
		title.setFormat(null, 16, FlxColor.BROWN, CENTER, OUTLINE_FAST, FlxColor.BLACK);
		
		var smoothingSlider:FlxSlider = new FlxSlider(this, "_smoothingIterations", FlxG.width - 180, 50, 0, 15, 150);
		smoothingSlider.nameLabel.text = "Smoothing Iterations";
		
		var wallRatioSlider:FlxSlider = new FlxSlider(this, "_wallRatio", FlxG.width - 180, 120 , 0.35, 0.65, 150);
		wallRatioSlider.nameLabel.text = "Wall Ratio";
		
		var generationButton:FlxButton = new FlxButton(FlxG.width - 140, 190, "[R]egenerate", generateCave);
		
		_generationTime = new FlxText(UI_POS_X, 220, UI_WIDTH);
		_generationTime.setFormat(null, 8, FlxColor.BLACK, CENTER);
		
		// Add all the stuff in correct order
		add(_tilemap);
		add(_player);
		add(uiBackground);
		add(title);
		add(smoothingSlider);
		add(wallRatioSlider);
		add(generationButton);
		add(_generationTime);
		
		// Finally, generate a cave
		generateCave();
	}
	
	override public function update(elapsed:Float):Void
	{
		// Keyboard shortcut
		if (FlxG.keys.justReleased.R)
		{
			generateCave();
		}
		// Just a little fading effect for the text
		if (_generationTime.alpha < 1)
		{
			_generationTime.alpha += 0.05;
		}
		
		// Collide the player with the walls
		FlxG.collide(_tilemap, _player);
		
		// Make sure the player can't leave the screen area
		FlxSpriteUtil.screenWrap(_player);
		
		super.update(elapsed);
	}
	
	private function generateCave():Void
	{
		// Determine the width and height (in tiles) needed to fill the screen with tiles that are 8x8 pixels 
		var width:Int = Math.floor(FlxG.width / 8);
		var height:Int = Math.floor((FlxG.height) / 8);
		
		// Get the time before starting the generation to calculate the timer later
		var time1:Float = Timer.stamp();
		
		var caveData:String = FlxCaveGenerator.generateCaveString(width, height, _smoothingIterations, _wallRatio);
		
		// Calculate the time it took to create the cave and update the text
		var timeDiff:Float = FlxMath.roundDecimal(Timer.stamp() - time1, 4);
		_generationTime.text = "Generation time: " + Std.string(timeDiff) + "s";
		_generationTime.alpha = 0;
		
		// Loads the cave to the tilemap
		_tilemap.loadMapFromCSV(caveData, "assets/caveWallTiles.png", 8, 8, AUTO);
		_tilemap.updateBuffers();
		
		// Find an empty tile for the player
		var emptyTiles:Array<FlxPoint> = _tilemap.getTileCoords(0, false);
		var randomEmptyTile:FlxPoint = emptyTiles[FlxG.random.int(0, emptyTiles.length)];
		_player.setPosition(randomEmptyTile.x, randomEmptyTile.y);
	}
}