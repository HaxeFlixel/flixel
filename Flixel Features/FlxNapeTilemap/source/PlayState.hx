package;

import flixel.addons.nape.FlxNapeState;
import flixel.addons.nape.FlxNapeTilemap;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import nape.geom.Vec2;
import openfl.Assets;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxNapeState
{
	var tilemap:FlxNapeTilemap;
	var player:Player;
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		tilemap = new FlxNapeTilemap();
		tilemap.loadMap(Assets.getText("assets/map.txt"), Assets.getBitmapData("assets/images/spritesheet.png"), 16, 16, null, 0, 0);
		//Set all tiles with index 1 as blocks
		tilemap.setupTileIndices([1]);
		
		var vertices:Array<Vec2> = new Array<Vec2>();
		
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
		
		player = new Player(50, 50);
		add(player);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update():Void
	{
		super.update();
	}	
}