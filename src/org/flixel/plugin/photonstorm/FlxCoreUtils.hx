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

package org.flixel.plugin.photonstorm;
import flash.display.Sprite;
import flash.errors.Error;
import flash.utils.ByteArray;
import org.flixel.FlxG;

class FlxCoreUtils 
{
	/**
	 * Performs a complete object deep-copy and returns a duplicate (not a reference)
	 * 
	 * @param	value	The object you want copied
	 * @return	A copy of this object
	 */
	public static function copyObject(value:Dynamic):Dynamic
	{
		var buffer:ByteArray = new ByteArray();
		buffer.writeObject(value);
		buffer.position = 0;
		var result:Dynamic = buffer.readObject();
		return result;
	}
	
	public static var mouseIndex(get_mouseIndex, null):Int;
	
	/**
	 * Returns the Display List index of the mouse pointer
	 */
	private static function get_mouseIndex():Int
	{
		var mouseIndex:Int = -1;
		
		try
		{
			mouseIndex = FlxG.cameras.defaultCamera.getContainerSprite().parent.numChildren - 4;
		}
		catch (e:Error)
		{
			//trace
		}
		
		return mouseIndex;
	}
	
	public static var gameContainer(get_gameContainer, null):Sprite;
	
	/**
	 * Returns the Sprite that FlxGame extends (which contains the cameras, mouse, etc)
	 */
	private static function get_gameContainer():Sprite
	{
		return cast(FlxG.cameras.defaultCamera.getContainerSprite().parent, Sprite);
	}
	
}