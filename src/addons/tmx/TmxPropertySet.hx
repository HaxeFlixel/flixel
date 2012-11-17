/*******************************************************************************
 * Copyright (c) 2012 by Adrien Fischer (original by Matt Tuttle based on Thomas Jahn's )
 * This content is released under the MIT License.
 * For questions mail me at adrien@revolugame.com
 ******************************************************************************/
package addons.tmx;

import haxe.xml.Fast;

class TmxPropertySet implements Dynamic<String>
{
	
	public function new()
	{
		keys = new Hash<String>();
	}
	
	public inline function get(key:String):String 
	{
		return resolve(key);
	}
	public inline function contains(key:String):Bool
	{
		return keys.exists(key);
	}
	
	
	public inline function resolve(name:String):String
	{
		return keys.get(name);
	}
	
	public function extend(source:Fast)
	{
		var prop:Fast;
		for (prop in source.nodes.property)
		{
			keys.set(prop.att.name, prop.att.value);
		}
	}
	
	private var keys:Hash<String>;
}
