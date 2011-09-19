/**
 * FlxScreenGrab
 * -- Part of the Flixel Power Tools set
 * 
 * v1.0 Updated for the Flixel 2.5 Plugin system
 * 
 * @version 1.0 - April 28th 2011
 * @link http://www.photonstorm.com
 * @author Richard Davey / Photon Storm
*/

package org.flixel.plugin.photonstorm 
{
	import org.flixel.*;
	import flash.geom.Rectangle;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	
	/**
	 * Captures a screen grab of the game and stores it locally, optionally saving as a PNG.
	 */
	public class FlxScreenGrab extends FlxBasic
	{
		public static var screenshot:Bitmap;
		private static var hotkey:String = "";
		private static var autoSave:Boolean = false;
		private static var autoHideMouse:Boolean = false;
		private static var region:Rectangle;
		
		public function FlxScreenGrab() 
		{
		}
		
		/**
		 * Defines the region of the screen that should be captured. If you need it to be a fixed location then use this.<br />
		 * If you want to grab the whole SWF size, you don't need to set this as that is the default.<br />
		 * Remember that if your game is running in a zoom mode > 1 you need to account for this here.
		 * 
		 * @param	x		The x coordinate (in Flash display space, not Flixel game world)
		 * @param	y		The y coordinate (in Flash display space, not Flixel game world)
		 * @param	width	The width of the grab region
		 * @param	height	The height of the grab region
		 */
		public static function defineCaptureRegion(x:int, y:int, width:int, height:int):void
		{
			region = new Rectangle(x, y, width, height);
		}
		
		/**
		 * Clears a previously defined capture region
		 */
		public static function clearCaptureRegion():void
		{
			region = null;
		}
		
		/**
		 * Specify which key will capture a screen shot. Use the String value of the key in the same way FlxG.keys does (so "F1" for example)<br />
		 * Optionally save the image to a file immediately. This uses the file systems "Save as" dialog window and pauses your game during the process.<br />
		 * 
		 * @param	key			String The key you press to capture the screen (i.e. "F1", "SPACE", etc - see system.input.Keyboard.as source for reference)
		 * @param	saveToFile	Boolean If set to true it will immediately encodes the grab to a PNG and open a "Save As" dialog window when the hotkey is pressed
		 * @param	hideMouse	Boolean If set to true the mouse will be hidden before capture and displayed afterwards when the hotkey is pressed
		 */
		public static function defineHotKey(key:String, saveToFile:Boolean = false, hideMouse:Boolean = false):void
		{
			hotkey = key;
			autoSave = saveToFile;
			autoHideMouse = hideMouse;
		}
		
		/**
		 * Clears a previously defined hotkey
		 */
		public static function clearHotKey():void
		{
			hotkey = "";
			autoSave = false;
			autoHideMouse = false;
		}
		
		/**
		 * Takes a screen grab immediately of the given region or a previously defined region
		 * 
		 * @param	captureRegion	A Rectangle area to capture. This over-rides that set by "defineCaptureRegion". If neither are set the full SWF size is used.
		 * @param	saveToFile	Boolean If set to true it will immediately encode the grab to a PNG and open a "Save As" dialog window
		 * @param	hideMouse	Boolean If set to true the mouse will be hidden before capture and displayed again afterwards
		 * @return	Bitmap		The screen grab as a Flash Bitmap image
		 */
		public static function grab(captureRegion:Rectangle = null, saveToFile:Boolean = false, hideMouse:Boolean = false):Bitmap
		{
			var bounds:Rectangle;
			
			if (captureRegion)
			{
				bounds = new Rectangle(captureRegion.x, captureRegion.y, captureRegion.width, captureRegion.height);
			}
			else if (region)
			{
				bounds = new Rectangle(region.x, region.y, region.width, region.height);
			}
			else
			{
				bounds = new Rectangle(0, 0, FlxG.stage.stageWidth, FlxG.stage.stageHeight);
			}
			
			var theBitmap:Bitmap = new Bitmap(new BitmapData(bounds.width, bounds.height, true, 0x0));
			
			var m:Matrix = new Matrix(1, 0, 0, 1, -bounds.x, -bounds.y);
			
			if (autoHideMouse || hideMouse)
			{
				FlxG.mouse.hide();
			}
			
			theBitmap.bitmapData.draw(FlxG.stage, m);
			
			if (autoHideMouse || hideMouse)
			{
				FlxG.mouse.show();
			}
			
			screenshot = theBitmap;
			
			if (saveToFile || autoSave)
			{
				save();
			}
			
			return theBitmap;
		}
		
		private static function save(filename:String = ""):void
		{
			if (screenshot.bitmapData == null)
			{
				return;
			}
			
			var png:ByteArray = PNGEncoder.encode(screenshot.bitmapData);
			
			var file:FileReference = new FileReference();
			
			if (filename == "")
			{
				filename = "grab" + getTimer().toString() + ".png";
			}
			else if (filename.substr( -4) != ".png")
			{
				filename = filename.concat(".png");
			}
			
			file.save(png, filename);
		}
		
		override public function update():void
		{
			if (hotkey != "")
			{
				if (FlxG.keys.justReleased(hotkey))
				{
					trace("key pressed");
					grab();
				}
			}
		}
		
		override public function destroy():void
		{
			clearCaptureRegion();
			clearHotKey();
		}
		
	}

}