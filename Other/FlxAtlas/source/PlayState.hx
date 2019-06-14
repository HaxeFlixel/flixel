package;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.atlas.FlxNode;
import flixel.graphics.frames.FlxTileFrames;
import flixel.math.FlxPoint;
import flixel.text.FlxText;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import openfl.Assets;

using flixel.util.FlxSpriteUtil;

/**
 * ...
 * @author Zaphod
 */
class PlayState extends FlxState
{
	override public function create():Void
	{
		// let's create an atlas.
		// they change size automatically
		var atlas:FlxAtlas = new FlxAtlas("myAtlas");

		// and add nodes (images) to it
		var tilesNode:FlxNode = createNodeAndDisposeBitmap("assets/area02_level_tiles2.png", atlas);
		var monsterNode:FlxNode = createNodeAndDisposeBitmap("assets/lurkmonsta.png", atlas);
		var playerNode:FlxNode = createNodeAndDisposeBitmap("assets/lizardhead3.png", atlas);

		// now we can create some helper object which can be loaded in sprites and tilemaps
		var tileSize = FlxPoint.get(16, 16);
		var tileFrames:FlxTileFrames = tilesNode.getTileFrames(tileSize);

		// let's try load this object in newly created tilemap
		var tilemap:FlxTilemap = new FlxTilemap();
		tilemap.loadMapFromCSV("assets/mapCSV_Group1_Map1.csv", tileFrames);
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

		// display the generated atlas (you could also view the cache via "viewCache" / "vc" in the console)
		var yPos = FlxG.height - atlas.height - 70;
		add(new FlxText(10, yPos, 0, 'myAtlas (${atlas.width}x${atlas.height}):', 16));

		var atlasBmd = atlas.bitmapData.clone();
		var atlasSprite = new FlxSprite(20, yPos + 40, atlasBmd);
		atlasSprite.drawRect(0, 0, atlasSprite.width - 1, atlasSprite.height - 1, FlxColor.TRANSPARENT, {thickness: 1, color: FlxColor.RED});
		add(atlasSprite);
	}

	/**
	 * Helper method for getting FlxNodes for images, but with image disposing (for memory savings)
	 * @param	source	path to the image
	 * @param	atlas	atlas to load image onto
	 * @return	created FlxNode object for image
	 */
	function createNodeAndDisposeBitmap(source:String, atlas:FlxAtlas):FlxNode
	{
		var bitmap:BitmapData = Assets.getBitmapData(source);
		var node:FlxNode = atlas.addNode(bitmap, source);
		Assets.cache.removeBitmapData(source);
		bitmap.dispose();
		return node;
	}
}
