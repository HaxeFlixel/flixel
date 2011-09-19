/**
* FlxCoreUtils
* -- Part of the Flixel Power Tools set
* 
* v1.0 First release with copyObject
* 
* @version 1.0 - June 6th 2011
* @link http://www.photonstorm.com
* @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm;
import flash.utils.ByteArray;

class FlxCoreUtils 
{
	
	public function new() { }
	
	public static function copyObject(value:Dynamic):Dynamic
	{
		var buffer:ByteArray = new ByteArray();
		buffer.writeObject(value);
		buffer.position = 0;
		var result:Dynamic = buffer.readObject();
		return result;
	}
	
}