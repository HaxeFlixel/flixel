package;

import openfl.Assets;
import flash.geom.Rectangle;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.ui.FlxButton;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.util.FlxSave;
import flixel.util.FlxColor;
import flixel.util.FlxVector;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;

class MenuState extends FlxState
{
	inline static private var TILE_SIZE:Int = 8;
	
	private var path:FlxPath;
	private var enemy:Enemy;
	
	override public function create():Void
	{
		useMouse = true;
		
		#if flash
		FlxG.mouse.cursorContainer.blendMode = BlendMode.INVERT;
		#end
		
		#if mobile
		useMouse = false;
		#end
		
		FlxG.cameras.bgColor = FlxColor.WHITE;
		
		var map:FlxTilemap = new FlxTilemap();
		map.loadMap(Assets.getText("assets/tilemap/mapCSV_Group3_Map1.csv"), "images/tileset.png", TILE_SIZE, TILE_SIZE);
		add(map);
		
		var headline:FlxText = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.color = FlxColor.WHITE;
		headline.alignment = "center";
		add(headline);
		
		var credits:FlxText = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26 by Gama11");
		add(credits);
		
		var playButton:Button = new Button( 0, Std.int(FlxG.height / 2), "Play", playButtonCallback );
		playButton.textNormal.color = FlxColor.WHITE;
		playButton.x = Std.int(FlxG.width / 2 - 12);
		add(playButton);
		
		path = map.findPath(new FlxPoint(5 * TILE_SIZE + 4, 0), new FlxPoint(34 * TILE_SIZE + 4, 29 * TILE_SIZE));
		
		enemy = new Enemy();
		enemy.init(8 * 5, 0);
		enemy.followPath(path, 50, 0, true);
		add(enemy); 
	}
	
	private function playButtonCallback():Void
	{
		//FlxG.switchState(new PlayState());
	}
	
	override public function destroy():Void
	{
		path = null;
		enemy = null;
		
		super.destroy();
	}

	override public function update():Void
	{
		// Check if the enemy has reached the end of the path yet
		if (enemy.y >= 28 * TILE_SIZE) 
		{
			// If so, reset his position to the start
			enemy.x = 5 * TILE_SIZE + 4;
			enemy.y = 0;
			enemy.followPath(path, 50, 0, true);
		}
		
		super.update();
	}	
}