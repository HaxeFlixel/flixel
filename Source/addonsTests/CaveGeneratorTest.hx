package addonsTests;

import addons.FlxCaveGenerator;
import org.flixel.FlxAssets;
import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxTilemap;

/**
 * ...
 * @author Zaphod
 */

class CaveGeneratorTest extends FlxState
{

	public function new() 
	{
		super();
	}
	
	override public function create():Void 
	{
		#if !neko
		FlxG.bgColor = 0xffffffff;
		#else
		FlxG.bgColor = {rgb:0xffffff, a:0xff};
		#end
		
		// Create cave of size 200x100 tiles
		var cave:FlxCaveGenerator = new FlxCaveGenerator(40, 30);

		// Generate the level and returns a matrix
		// 0 = empty, 1 = wall tile
		var caveMatrix:Array<Array<Int>> = cave.generateCaveLevel();

		// Converts the matrix into a string that is readable by FlxTileMap
		var dataStr:String = FlxCaveGenerator.convertMatrixToStr(caveMatrix);

		// Loads tilemap of tilesize 16x16
		var tileMap:FlxTilemap = new FlxTilemap();
		tileMap.loadMap(dataStr, FlxAssets.imgAuto, 0, 0, FlxTilemap.AUTO);
		add(tileMap);
	}
	
}