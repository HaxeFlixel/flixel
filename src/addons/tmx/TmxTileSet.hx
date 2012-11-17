/*******************************************************************************
 * Copyright (c) 2012 by Adrien Fischer (original by Matt Tuttle based on Thomas Jahn's )
 * This content is released under the MIT License.
 * For questions mail me at adrien@revolugame.com
 ******************************************************************************/
package addons.tmx;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.xml.Fast;

class TmxTileSet
{
	private var _tileProps:Array<TmxPropertySet>;
	
	public var firstGID:Int;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int;
	public var margin:Int;
	public var imageSource:String;
	
	//available only after immage has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;
	
	public function new(data:Dynamic)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;
		
		// Use the correct data format
		if (Std.is(data, Fast))
		{
			source = data;
		}
		else if (Std.is(data, ByteArray))
		{
			source = new Fast(Xml.parse(data.toString()));
			source = source.node.tileset;
		}
		else throw "Unknown TMX tileset format";
		
		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;
		
		// check for external source
		if (source.has.source)
		{
			
		}
		else // internal
		{
			var node:Fast = source.node.image;
			imageSource = node.att.source;
			
			name = source.att.name;
			if (source.has.tilewidth) tileWidth = Std.parseInt(source.att.tilewidth);
			if (source.has.tileheight) tileHeight = Std.parseInt(source.att.tileheight);
			if (source.has.spacing) spacing = Std.parseInt(source.att.spacing);
			if (source.has.margin) margin = Std.parseInt(source.att.margin);
			
			//read properties
			_tileProps = new Array<TmxPropertySet>();
			for (node in source.nodes.tile)
			{
				if(!node.has.id)
				    continue;
				    
				var id:Int = Std.parseInt(node.att.id);
				_tileProps[id] = new TmxPropertySet();
				for (prop in node.nodes.properties)
					_tileProps[id].extend(prop);
			}
		}
	}
	
	public function hasGid(gid:Int):Bool
	{
		return (gid >= firstGID) && (gid < firstGID + numTiles);
	}
	
	public function fromGid(gid:Int):Int
	{
		return gid - firstGID;
	}
	
	public function toGid(id:Int):Int
	{
		return firstGID + id;
	}

	public function getPropertiesByGid(gid:Int):TmxPropertySet
	{
		if (_tileProps != null)
			return _tileProps[gid - firstGID];
		return null;
	}
	
	public function getProperties(id:Int):TmxPropertySet
	{
		return _tileProps[id];
	}
	
	public function getRect(id:Int):Rectangle
	{
		//TODO: consider spacing & margin
		return new Rectangle((id % numCols) * tileWidth, (id / numCols) * tileHeight);
	}
}
