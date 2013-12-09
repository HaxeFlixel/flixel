package;

import openfl.Assets;
import flash.display.BlendMode;
import flixel.FlxG;
import flixel.FlxState;
import flixel.tile.FlxTilemap;
import flixel.text.FlxText;
import flixel.util.FlxPath;
import flixel.util.FlxPoint;
import flixel.addons.ui.FlxButtonPlus;

class MenuState extends FlxState
{
	private var path:FlxPath;
	private var enemy:Enemy;
	
	override public function create():Void
	{
		FlxG.mouse.show();
		//FlxG.mouse._cursorContainer.blendMode = BlendMode.INVERT;
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
		
		var playButton:FlxButtonPlus = new FlxButtonPlus(0, cast(FlxG.height / 2), playButtonCallback, null, "Play");
		R.modifyButton(playButton, 25);
		playButton.textNormal.color = 0xffFFFFFF;
		playButton.x = Std.int(FlxG.width / 2 - 12);
		add(playButton);
		
		path = map.findPath(new FlxPoint(5 * 8 + 4, 0), new FlxPoint(34 * 8 + 4, 29 * 8));
		
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