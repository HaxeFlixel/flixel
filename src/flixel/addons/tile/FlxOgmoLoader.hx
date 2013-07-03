package flixel.addons.tile;

import openfl.Assets;
import haxe.xml.Fast;
import haxe.xml.Parser;
import flixel.FlxG;
import flixel.util.FlxPoint;
import flixel.tile.FlxTilemap;

class FlxOgmoLoader
{
	public var width:Int;
	public var height:Int;

	// Helper variables to read level data
	private var _xml:Xml;
	private var _fastXml:Fast;
	
	/**
	 * Creates a new instance of OgmoLevelLoader and prepares the XML level data to be loaded.
	 * This object can either be contained or ovewritten. 
	 * 
	 * IMPORTANT: -> Tile layers must have the Export Mode set to "CSV".
	 * 			  -> First tile in spritesheet must be blank or debug. It will never get drawn so don't place them in Ogmo! 
	 * 			  	 (This is needed to support many other editors that use index 0 as empty.)
	 * 
	 * @param	LevelData	A String or Class representing the location of xml level data.
	 */
	public function new(LevelData:Dynamic)
	{
		// Load xml file
		var str:String = "";
		
		// Passed embedded resource?
		if (Std.is(LevelData, Class)) 
		{
			str = Type.createInstance(LevelData, []);
		}
		// Passed path to resource?
		else if (Std.is(LevelData, String))  
		{
			str = Assets.getText(LevelData);
		}

		_xml = Parser.parse(str);
		_fastXml = new Fast(_xml.firstElement());

		width = Std.parseInt(_fastXml.att.width);
		height = Std.parseInt(_fastXml.att.height);

		FlxG.camera.setBounds(0, 0, width, height, true);
	}

	/**
	* Load a Tilemap. Tile layers must have the Export Mode set to "CSV".
	* Collision with entities should be handled with the reference returned from this function. Here's a tip:
	* 
		// IMPORTANT: Always collide the map with objects, not the other way around. 
		//			  This prevents odd collision errors (collision separation code off by 1 px).
		<code>FlxG.collide(map, obj, notifyCallback);</code>
	* 
	* @param	TileGraphic		A String or Class representing the location of the image asset for the tilemap.
	* @param	TileWidth		The width of each individual tile.
	* @param	TileHeight		The height of each individual tile.
	* @param	TileLayer		The name of the layer the tilemap data is stored in Ogmo editor, usually "tiles" or "stage".
	* @return	A <code>FlxTilemap</code>, where you can collide your entities against.
	*/ 
	public function loadTilemap(TileGraphic:Dynamic, TileWidth:Int = 16, TileHeight:Int = 16, TileLayer:String = "tiles"):FlxTilemap
	{
		var tileMap:FlxTilemap = new FlxTilemap();
		tileMap.loadMap(_fastXml.node.resolve(TileLayer).innerData, TileGraphic, TileWidth, TileHeight);
		
		return tileMap;
	}

	/**
	* Parse every entity in the specified layer and call a function that will spawn game objects based on their name. 
	* Optional data can be read from the xml object, here's an example that reads the position of an object:
	* 
		<code>public function loadEntity( type:String, data:Xml ):Void
		{
			switch (type.toLowerCase())
			{
			case "player":
				player.x = Std.parseFloat(data.get("x"));
				player.y = Std.parseFloat(data.get("y"));
			default:
				throw "Unrecognized actor type '" + type + "' detected in level file.";
			}
		}</code>
	* 
	* @param	EntityLoadCallback		A function that takes in the following parameters (name:String, data:Xml):Void (returns Void) that spawns entities based on their name.
	* @param	EntityLayer				The name of the layer the entities are stored in Ogmo editor. Usually "entities" or "actors"
	*/ 
	public function loadEntities(EntityLoadCallback:String->Xml->Void, EntityLayer:String = "entities"):Void
	{
		var actors = _fastXml.node.resolve(EntityLayer);
		
		// Iterate over actors
		for (a in actors.elements) 
		{
			EntityLoadCallback(a.name, a.x);
		}
	}
}