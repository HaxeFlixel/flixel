package flixel.util;

import flash.display.Sprite;
import flash.Lib;
import flash.net.URLRequest;
import flixel.FlxG;
import haxe.io.Error;

/**
 * A class containing random functions that didn't 
 * fit in any other class of the util package.
 */
class FlxMisc 
{
	/**
	 * Opens a web page in a new tab or window.
	 * 
	 * @param	URL		The address of the web page.
	 */
	inline static public function openURL(URL:String):Void
	{
		Lib.getURL(new URLRequest(URL), "_blank");
	}
	
	/**
	 * Check to see if two objects have the same class name.
	 * @param	Object1		The first object you want to check.
	 * @param	Object2		The second object you want to check.
	 * @return	Whether they have the same class name or not.
	 */
	@:extern inline static public function compareClassNames(Object1:Dynamic, Object2:Dynamic):Bool
	{
		return Type.getClassName(Object1) == Type.getClassName(Object2);
	}
	
	/**
	 * Performs a complete object deep-copy and returns a duplicate (not a reference).
	 * This works best on anonymous objects, arrays, and classes with no function calls on their constructors.
	 * 
	 * @param	Value	The object you want copied
	 * @return	A copy of this object
	 */
	public static function deepCopy<T>( v:T ) : T 
	{ 
		if (!Reflect.isObject(v)) // simple type 
		{ 
			return v; 
		} 
		else if( Std.is( v, Array ) ) // array 
		{ 
			var r = Type.createInstance(Type.getClass(v), []); 
			untyped 
			{ 
				for( ii in 0...v.length ) 
				r.push(deepCopy(v[ii])); 
			} 
			return r; 
		} 
		else if( Type.getClass(v) == null ) // anonymous object 
		{ 
			var obj : Dynamic = {}; 
			for( ff in Reflect.fields(v) ) 
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
			return obj; 
		} 
		else // class 
		{ 
			var obj = Type.createEmptyInstance(Type.getClass(v));
			for( ff in Reflect.fields(v) ) 
				Reflect.setField(obj, ff, deepCopy(Reflect.field(v, ff))); 
			return obj; 
		} 
		return null; 
	} 
	
	/**
	 * The Display List index of the mouse pointer
	 */
	static public var mouseIndex(get, never):Int;
	
	static private function get_mouseIndex():Int
	{
		var mouseIndex:Int = -1;
		
		try
		{
			mouseIndex = FlxG.camera.getContainerSprite().parent.numChildren - 4;
		}
		catch (e:Error)
		{
			//trace
		}
		
		return mouseIndex;
	}
	
	/**
	 * Returns the Sprite that FlxGame extends (which contains the cameras, mouse, etc)
	 */
	static public var gameContainer(get, never):Sprite;
	
	inline static private function get_gameContainer():Sprite
	{
		return cast(FlxG.camera.getContainerSprite().parent, Sprite);
	}
}