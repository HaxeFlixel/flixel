package;

import openfl.Assets;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;

class MenuState extends FlxState
{
	private var path:FlxPath;
	private var enemy:Enemy;
	
	override public function create():Void
	{
		FlxG.mouse.show();
		FlxG.mouse.cursorContainer.blendMode = BlendMode.INVERT;
		FlxG.camera.bgColor = 0xffFFFFFF;
		
		var map:FlxTilemap = new FlxTilemap();
		map.loadMap( Assets.getText("tilemaps/mapCSV_Group3_Map1.csv"), Assets.getBitmapData("images/tileset.png"), 8, 8);
		add(map);
		
		var headline:FlxText = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.color = 0xffFFFFFF;
		headline.alignment = "center";
		add(headline);
		
		var credits:FlxText = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26");
		add(credits);
		
		var playButton:Button = new Button(0, Std.int( FlxG.height / 2 ), "Play", playButtonCallback);
		playButton.textNormal.color = 0xffFFFFFF;
		playButton.x = ( FlxG.width - playButton.width ) / 2;
		add(playButton);
		
		path = FlxPath.recycle();
		path.nodes = map.findPath(new FlxPoint(5 * 8 + 4, 0), new FlxPoint(34 * 8 + 4, 29 * 8));
		
		enemy = new Enemy(8 * 5, 0);
		enemy.followPath(path, 50, 0, true);
		add(enemy);
	}
	
	private function playButtonCallback():Void
	{
		FlxG.switchState(new GameState());
	}
	
	override public function destroy():Void
	{
		super.destroy();
	}

	override public function update():Void
	{
		if (enemy.y >= 28 * 8) {
			enemy.x = 5 * 8 + 4;
			enemy.y = 0;
			enemy.followPath(path, 50, 0, true);
		}
		
		super.update();
	}	
}