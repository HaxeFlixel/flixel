/*******************************************************************************
 * Copyright (c) 2012 by Adrien Fischer (original by Matt Tuttle based on Thomas Jahn's )
 * This content is released under the MIT License.
 * For questions mail me at adrien@revolugame.com
 ******************************************************************************/
package addons.tmx;

import nme.Assets;
import haxe.xml.Fast;

class TmxMap
{
    public var version      : String; 
	public var orientation  : String;
	
	public var width        : Int;
	public var height       : Int; 
	public var tileWidth    : Int; 
	public var tileHeight   : Int;
	
	public var fullWidth  	: Int;
	public var fullHeight 	: Int;

	public var properties   : TmxPropertySet;
	public var tilesets     : Hash<TmxTileSet>;
	public var layers       : Hash<TmxLayer>;
	public var objectGroups : Hash<TmxObjectGroup>;
	
	private var noLoadHash  :Hash<Bool>;

    public function new(data: Dynamic)
    {
        properties = new TmxPropertySet();
		var source:Fast = null;
		var node:Fast = null;
		
        if (Std.is(data, String)) source = new Fast(Xml.parse(Assets.getText(data)));
		else if (Std.is(data, Xml)) source = new Fast(data);
		else throw "Unknown TMX map format";
		
		source = source.node.map;
		
		//map header
		version = source.att.version;
		if (version == null) version = "unknown";
		
		orientation = source.att.orientation;
		if (orientation == null) orientation = "orthogonal";
		
		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);
		tileWidth = Std.parseInt(source.att.tilewidth);
		tileHeight = Std.parseInt(source.att.tileheight);
		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;
		
		tilesets 		= new Hash<TmxTileSet>();
		layers 			= new Hash<TmxLayer>();
		objectGroups 	= new Hash<TmxObjectGroup>();
		noLoadHash		= new Hash<Bool>();
		
		//read properties
		for (node in source.nodes.properties)
			properties.extend(node);
		
		var noLoadStr = properties.get("noload");
		if (noLoadStr != null)
		{
			var regExp = ~/[,;|]/;
			var noLoadArr = regExp.split(noLoadStr);
			for (s in noLoadArr)
				noLoadHash.set(s, true);
		}
		
		//load tilesets
		var name:String;
		for (node in source.nodes.tileset)
		{
			name = node.att.name;
			if(!noLoadHash.exists(name))
				tilesets.set(name, new TmxTileSet(node));
		}
		
		//load layer
		for (node in source.nodes.layer)
		{
			name = node.att.name;
			if(!noLoadHash.exists(name))
				layers.set(name, new TmxLayer(node, this));
		}
		
		//load object group
		for (node in source.nodes.objectgroup)
		{
			name = node.att.name;
			if(!noLoadHash.exists(name))
				objectGroups.set(name, new TmxObjectGroup(node, this));
		}
	}
		
	public function getTileSet(name:String):TmxTileSet
	{
		return tilesets.get(name);
	}
		
	public function getLayer(name:String):TmxLayer
	{
		return layers.get(name);
	}
		
	public function getObjectGroup(name:String):TmxObjectGroup
	{
		return objectGroups.get(name);
	}			
		
	//works only after TmxTileSet has been initialized with an image...
	public function getGidOwner(gid:Int):TmxTileSet
	{
		var last:TmxTileSet = null;
		var set:TmxTileSet;
		for (set in tilesets)
		{
			if(set.hasGid(gid))
				return set;
		}
		return null;
	}
}
