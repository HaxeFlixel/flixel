package;

import nme.Assets;
import nme.geom.Rectangle;
import nme.net.SharedObject;
import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxPath;
import org.flixel.FlxPoint;
import org.flixel.FlxSave;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.FlxTilemap;
import org.flixel.FlxU;
import org.flixel.plugin.photonstorm.FlxButtonPlus;
import nme.display.BlendMode;

class MenuState extends FlxState
{
	private var path:FlxPath;
	private var enemy:Enemy;
	
	override public function create():Void
	{
		FlxG.mouse.show();
		FlxG.mouse._cursorContainer.blendMode = BlendMode.INVERT;
		FlxG.bgColor = FlxG.WHITE;
		
		var map:FlxTilemap = new FlxTilemap();
		map.loadMap(Assets.getText("assets/tilemap/mapCSV_Group3_Map1.csv"), "assets/img/tileset.png", 8, 8);
		add(map);
		
		var headline:FlxText = new FlxText(0, 40, FlxG.width, "Minimalist TD", 16);
		headline.color = FlxG.WHITE;
		headline.alignment = "center";
		add(headline);
		
		var credits:FlxText = new FlxText(2, FlxG.height - 12, FlxG.width, "Made in 48h for Ludum Dare 26");
		add(credits);
		
		var playButton:FlxButtonPlus = new FlxButtonPlus(0, cast(FlxG.height / 2), playButtonCallback, null, "Play");
		R.modifyButton(playButton, 25);
		playButton.textNormal.color = FlxG.WHITE;
		playButton.x = cast(FlxG.width / 2- 12);
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