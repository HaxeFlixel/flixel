package;

import flixel.addons.nape.FlxNapeSpace;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxState;
import nape.geom.Vec2;
import openfl.Assets;

class PlayState extends FlxState
{
	var tilemap:FlxNapeTilemap;
	var player:Player;
	
	override public function create():Void
	{
		FlxNapeSpace.init();
		
		tilemap = new FlxNapeTilemap();
		tilemap.loadMap(Assets.getText("assets/data/map.txt"), Assets.getBitmapData("assets/images/spritesheet.png"), 16, 16, null, 0, 0);
		//Set all tiles with index 1 as blocks
		tilemap.setupTileIndices([1]);
		
		var vertices = new Array<Vec2>();
		
		//Create slope polygon facing north-west
		vertices.push(Vec2.get(16, 0));
		vertices.push(Vec2.get(16, 16));
		vertices.push(Vec2.get(0, 16));
		tilemap.placeCustomPolygon([2], vertices);
		
		//Move top right vertex left to make the slope face north-east
		vertices[0] = Vec2.get(0, 0);
		tilemap.placeCustomPolygon([3], vertices);
		
		//Move bottom right vertex up to make the slope face south-east
		vertices[1] = Vec2.get(16, 0);
		tilemap.placeCustomPolygon([4], vertices);
		
		//Move bottom left vertex right to make the slope face south-west
		vertices[2] = Vec2.get(16, 16);
		tilemap.placeCustomPolygon([5], vertices);
		
		add(tilemap);
		add(player = new Player(50, 50));
		
		FlxNapeSpace.drawDebug = true;
	}
}