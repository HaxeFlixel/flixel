package org.flixel.addons;

import nme.Assets;
import haxe.xml.Fast;
import haxe.xml.Parser;
import org.flixel.FlxG;
import org.flixel.FlxPoint;
import org.flixel.FlxTilemap;

class OgmoLevelLoader
{
	// Helper variables to read level data
	private var xml:Xml;
	private var fastXml:Fast;

	public var width:Int;
	public var height:Int;

	/**
	 * Creates a new instance of OgmoLevelLoader and prepares the XML level data to be loaded.
	 * This object can either be contained or ovewritten. 
	 * 
	 * IMPORTANT: -> Tile layers must have the Export Mode set to "CSV".
	 * 			  -> First tile in spritesheet must be blank or debug. It will never get drawn so don't place them in Ogmo! 
	 * 			  	 (This is needed to support many other editors that use index 0 as empty.)
	 * 
	 * @param	A String or Class representing the location of xml level data.
	 */
	public function new(LevelData:Dynamic)
	{
		// Load xml file
		var str:String = "";
		if (Std.is(LevelData, Class)) // passed embedded resource?
		{
			str = Type.createInstance(LevelData, []);
		}
		else if (Std.is(LevelData, String))  // passed path to resource?
		{
			str = Assets.getText(LevelData);
		}

		xml = Parser.parse(str);
		fastXml = new Fast(xml.firstElement());

		width = Std.parseInt(fastXml.att.width);
		height = Std.parseInt(fastXml.att.height);

		FlxG.camera.setBounds(0, 0, width, height, true);
	}

	/**
	* Load a Tilemap. Tile layers must have the Export Mode set to "CSV".
	* Collision with entities should be handled with the reference returned from this function. Here's a tip:
	* 
		// IMPORTANT: Always collide the map with objects, not the other way around. 
		//			  This prevents odd collision errors (collision separation code off by 1 px).
		FlxG.collide(map, obj, notifyCallback);
	* 
	* @param	A String or Class representing the location of the image asset for the tilemap.
	* @param	The width of each individual tile.
	* @param	The height of each individual tile.
	* @param	The name of the layer the tilemap data is stored in Ogmo editor, usually "tiles" or "stage".
	* @return	A FlxTilemap, where you can collide your entities against.
	*/ 
	public function loadTilemap(TileGraphic:Dynamic, TileWidth:Int = 16, TileHeight:Int = 16, TileLayer:String = "tiles"):FlxTilemap
	{
		var tileMap:FlxTilemap = new FlxTilemap();
		tileMap.loadMap(fastXml.node.resolve(TileLayer).innerData, TileGraphic, TileWidth, TileHeight);
		return tileMap;
	}

	/**
	* Parse every entity in the specified layer and call a function that will spawn game objects based on their name. 
	* Optional data can be read from the xml object, here's an example that reads the position of an object:
	* 
		public function loadEntity( type:String, data:Xml ):Void
		{
			switch (type.toLowerCase())
			{
			case "player":
				player.x = Std.parseFloat(data.get("x"));
				player.y = Std.parseFloat(data.get("y"));
			default:
				throw "Unrecognized actor type '" + type + "' detected in level file.";
			}
		}
	* 
	* @param	A function that takes in the following parameters (name:String, data:Xml):Void (returns Void) that spawns entities based on their name.
	* @param	The name of the layer the entities are stored in Ogmo editor. Usually "entities" or "actors"
	*/ 
	public function loadEntities(entityLoadCallback:String -> Xml -> Void, EntityLayer:String = "entities"):Void
	{
		var actors = fastXml.node.resolve(EntityLayer);

		// iterate over actors
		for ( a in actors.elements ) 
		{
			entityLoadCallback(a.name, a.x);
		}
	}
}