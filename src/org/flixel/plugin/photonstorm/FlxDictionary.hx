package org.flixel.plugin.photonstorm;

/**
 * Dictionary class. Thanks to Joshua Granick for this crossplatform code (this code is taken from actuate animation library http://lib.haxe.org/p/actuate)
 */

#if flash
import flash.utils.TypedDictionary;
#end

class FlxDictionary<T> 
{
	
	#if flash
	private var dictionary:TypedDictionary<Dynamic, T>;
	#else
	private var hash:IntHash<T>;
	#end
	
	private static var nextObjectID:Int = 0;
	
	public function new() 
	{
		#if flash
		dictionary = new TypedDictionary<Dynamic, T>();
		#else
		hash = new IntHash<T>();
		#end
	}
	
	public inline function exists(key:Dynamic):Bool 
	{
		#if flash
		return dictionary.exists(key);
		#else
		return hash.exists(getID(key));
		#end
	}
	
	public inline function get(key:Dynamic):T 
	{
		#if flash
		return dictionary.get(key);
		#else
		return hash.get(getID(key));
		#end
	}
	
	
	private inline function getID(key:Dynamic):Int 
	{
		#if cpp
		return untyped __global__.__hxcpp_obj_id(key);
		#else
		if (key.___id___ == null) 
		{
			key.___id___ = nextObjectID++;
			if (nextObjectID == 0x3FFFFFFF) 
			{
				nextObjectID = 0;
			}
		}
		
		return key.___id___;
		#else
		return 0;
		#end
	}
	
	public inline function iterator():Iterator<T> 
	{
		#if flash
		var values:Array<T> = new Array<T>();
		
		for (key in dictionary.iterator())
		{
			values.push(dictionary.get(key));
		}
		
		return values.iterator();
		#else
		return hash.iterator();
		#end
	}
	
	public inline function delete(key:Dynamic):Void 
	{
		#if flash
		dictionary.delete(key);
		#else
		hash.remove(getID(key));
		#end
	}
	
	public inline function set(key:Dynamic, value:T):Void 
	{
		#if flash
		dictionary.set (key, value);
		#else
		hash.set(getID(key), value);
		#end
	}
	
}