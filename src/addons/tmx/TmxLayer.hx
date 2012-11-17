/*******************************************************************************
 * Copyright (c) 2012 by Adrien Fischer (original by Matt Tuttle based on Thomas Jahn's )
 * This content is released under the MIT License.
 * For questions mail me at adrien@revolugame.com
 ******************************************************************************/
package addons.tmx;

import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Lib;
import haxe.xml.Fast;

class TmxLayer
{
	public var map:TmxMap;
	public var name:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var opacity:Float;
	public var visible:Bool;
	public var properties:TmxPropertySet;
	
	public var csvData(getCsvData, null):String;
	public var tileArray(get1DArr, null):Array<Int>;
	
	private var _xmlData:Fast;
	
	public function new(source:Fast, parent:TmxMap)
	{
		properties = new TmxPropertySet();
		map = parent;
		name = source.att.name;
		x = (source.has.x) ? Std.parseInt(source.att.x) : 0;
		y = (source.has.y) ? Std.parseInt(source.att.y) : 0;
		width = Std.parseInt(source.att.width); 
		height = Std.parseInt(source.att.height); 
		visible = (source.has.visible && source.att.visible == "1") ? true : false;
		opacity = (source.has.opacity) ? Std.parseFloat(source.att.opacity) : 0;
		
		//load properties
		var node:Fast;
		for (node in source.nodes.properties)
			properties.extend(node);
		
		//load tile GIDs
		_xmlData = source.node.data;
		if (_xmlData == null)
			throw "Error loading TmxLayer level data";
	}
	
	private function getCsvData():String 
	{
		if (csvData == null)
		{
			if (_xmlData.att.encoding == "csv")
				csvData = _xmlData.innerData;
			else
				throw "Must use CSV encoding in order to get CSV data.";
		}
		return csvData;
	}
	private function get1DArr():Array<Int>
	{
		if (tileArray == null)
		{
			var mapData:ByteArray = getByteArrayData();
			if (mapData == null)
				throw "Must use Base64 encoding (with or without zlip compression) in order to get 1D Array.";
			
			tileArray = new Array<Int>();
			while(mapData.position < mapData.length)
			{
				tileArray.push(mapData.readInt());
			}
		}
		return tileArray;
	}
	
	private function getByteArrayData():ByteArray
	{
		var result:ByteArray = null;
		if (_xmlData.att.encoding == "base64")
		{
			var chunk:String = _xmlData.innerData;
			var compressed:Bool = false;
			if (_xmlData.has.compression)
			{
				switch(_xmlData.att.compression)
				{
					case "zlib":
						compressed = true;
					default:
						throw "TmxLayer - data compression type not supported!";
				}
			}
			result = base64ToByteArray(chunk);
			if(compressed)
				result.uncompress();
			result.endian = Endian.LITTLE_ENDIAN;
		}
		return result;
	}
	
	private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	private static function base64ToByteArray(data:String):ByteArray
	{
		var output:ByteArray = new ByteArray();
		//initialize lookup table
		var lookup:Array<Int> = new Array<Int>();
		var c:Int;
		for (c in 0...BASE64_CHARS.length)
		{
			lookup[BASE64_CHARS.charCodeAt(c)] = c;
		}
		
		var i:Int = 0;
		while (i < data.length - 3)
		{
			// Ignore whitespace
			if (data.charAt(i) == " " || data.charAt(i) == "\n")
			{
				i++; continue;
			}
			
			//read 4 bytes and look them up in the table
			var a0:Int = lookup[data.charCodeAt(i)];
			var a1:Int = lookup[data.charCodeAt(i + 1)];
			var a2:Int = lookup[data.charCodeAt(i + 2)];
			var a3:Int = lookup[data.charCodeAt(i + 3)];
			
			// convert to and write 3 bytes
			if(a1 < 64)
				output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
			if(a2 < 64)
				output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
			if(a3 < 64)
				output.writeByte(((a2 & 0x03) << 6) + a3);
			
			i += 4;
		}
		
		// Rewind & return decoded data
		output.position = 0;
		return output;
	}
}
