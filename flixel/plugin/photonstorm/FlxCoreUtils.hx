package flixel.plugin.photonstorm;

import flash.display.Sprite;
import flash.errors.Error;
import flash.utils.ByteArray;
import flixel.FlxG;

/**
 * FlxCoreUtils
 * -- Part of the Flixel Power Tools set
 * 
 * v1.1 Added get mouseIndex and gameContainer
 * v1.0 First release with copyObject
 * 
 * @version 1.1 - August 4th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/
class FlxCoreUtils 
{
	/**
	 * Performs a complete object deep-copy and returns a duplicate (not a reference)
	 * 
	 * @param	Value	The object you want copied
	 * @return	A copy of this object
	 */
	public static function copyObject(Value:Dynamic):Dynamic
	{
		var buffer:ByteArray = new ByteArray();
		buffer.writeObject(Value);
		buffer.position = 0;
		var result:Dynamic = buffer.readObject();
		
		return result;
	}
	
	/**
	 * The Display List index of the mouse pointer
	 */
	public static var mouseIndex(get, never):Int;
	
	private static function get_mouseIndex():Int
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
	public static var gameContainer(get, never):Sprite;
	
	private static function get_gameContainer():Sprite
	{
		return cast(FlxG.camera.getContainerSprite().parent, Sprite);
	}
}