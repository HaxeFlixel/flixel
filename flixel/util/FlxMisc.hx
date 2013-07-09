package flixel.util;

import flash.Lib;
import flash.net.URLRequest;
import flash.display.Sprite;
import flash.utils.ByteArray;
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
	 * Just grabs the current "ticks" or time in milliseconds that has passed since Flash Player started up.
	 * Useful for finding out how long it takes to execute specific blocks of code.
	 * @return	Time in milliseconds that has passed since Flash Player started up.
	 */
	inline static public function getTicks():Int
	{
		return FlxGame._mark;
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
	
	// TODO: fix issue with compiling this function
	// "flash.utils.ByteArray has no field writeObject"
	// "flash.utils.ByteArray has no field readObject"
		
	/**
	 * Performs a complete object deep-copy and returns a duplicate (not a reference)
	 * 
	 * @param	Value	The object you want copied
	 * @return	A copy of this object
	 */
	//static public function copyObject(Value:Dynamic):Dynamic
	//{
		
		//var buffer:ByteArray = new ByteArray();
		//buffer.writeObject(Value);
		//buffer.position = 0;
		//var result:Dynamic = buffer.readObject();

		//return result;
	//}
	
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