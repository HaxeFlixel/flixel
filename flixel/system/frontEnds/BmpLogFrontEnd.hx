package flixel.system.frontEnds;

import flash.display.BitmapData;
import flixel.FlxG;

class BmpLogFrontEnd
{
	/**
	 * Just needed to create an instance.
	 */
	public function new() { }
	
	/**
	 * Add a variable to the bmpLog list in the debugger.
	 * This lets you see the pixels of a bitmapdata
	 * 
	 * @param	Pixels	BitmapData
	 */
	inline public function add(Pixels:BitmapData):Void
	{
		#if !FLX_NO_DEBUG
			#if FLX_BMP_DEBUG
				FlxG.game.debugger.bmpLog.add(Pixels);
			#end
		#end
	}		
}