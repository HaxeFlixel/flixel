package;

import flash.display.BitmapData;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.tile.FlxTilemap;
import openfl.Assets;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	override public function create():Void
	{
		// lets create atlas
		var atlas:FlxAtlas = new FlxAtlas("myAtlas", 512, 512);
		
		// and add nodes (images) on it
		var tilesNode:FlxNode = createNodeAndDisposeBitmap("assets/area02_level_tiles2.png", atlas);
		var monsterNode:FlxNode = createNodeAndDisposeBitmap("assets/lurkmonsta.png", atlas);
		var playerNode:FlxNode = createNodeAndDisposeBitmap("assets/lizardhead3.png", atlas);
		
		// now we can create some helper object which can be loaded in sprites and tilemaps
		var tileSize = FlxPoint.get(16, 16);
		var tileFrames:FlxTileFrames = tilesNode.getTileFrames(tileSize);
		
		// lets try load this object in newly created tilemap
		var tilemap:FlxTilemap = new FlxTilemap();
		tilemap.loadMap("assets/mapCSV_Group1_Map1.csv", tileFrames);
		add(tilemap);
		
		// lets try this feature on sprites also
		var monsterSize:FlxPoint = new FlxPoint(16, 17);
		var monsterFrames:FlxTileFrames = monsterNode.getTileFrames(monsterSize);
		
		var monster:FlxSprite = new FlxSprite();
		monster.frames = monsterFrames;
		add(monster);
		
		// why not animate some sprite?
		var playerSize = FlxPoint.get(16, 20);
		var playerFrames:FlxTileFrames = playerNode.getTileFrames(playerSize);
		
		var player:FlxSprite = new FlxSprite(100, 0);
		player.frames = playerFrames;
		player.animation.add("walking", [0, 1, 2, 3], 12, true);
		player.animation.play("walking");
		add(player);
	}
	
	/**
	 * Helper method for getting FlxNodes for images, but with image disposing (for memory savings)
	 * @param	source	path to the image
	 * @param	atlas	atlas to load image onto
	 * @return	created FlxNode object for image
	 */
	private function createNodeAndDisposeBitmap(source:String, atlas:FlxAtlas):FlxNode
	{
		var bitmap:BitmapData = Assets.getBitmapData(source);
		var node:FlxNode = atlas.addNode(bitmap, source);
		Assets.cache.bitmapData.remove(source);
		bitmap.dispose();
		return node;
	}
}