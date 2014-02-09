package flixel.util.loaders;

import flash.display.BitmapData;
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.system.layer.frames.FlxFrame;
import flixel.system.layer.TileSheetData;

class CachedGraphics
{
	/**
	 * Key in BitmapFrontEnd cache
	 */
	public var key:String;
	/**
	 * Cached BitmapData object
	 */
	public var bitmap:BitmapData;
	/**
	 * Asset name from openfl.Assets
	 */
	public var assetsKey:String;
	/**
	 * Class name for the BitmapData
	 */
	public var assetsClass:Class<BitmapData>;
	/**
	 * TexturePackerData associated with the BitmapData
	 */
	public var data:TexturePackerData;
	
	/**
	 * Whether this cached object should stay in cache after state changes or not.
	 */
	public var persist:Bool = false;
	/**
	 * Whether we should destroy this CachedGraphics object when useCount become zero.
	 * Default is false.
	 */
	public var destroyOnNoUse(default, set):Bool = false;
	
	/**
	 * Whether the BitmapData of this cached object has been dumped or not.
	 */
	public var isDumped(default, null):Bool = false;
	/**
	 * Whether the BitmapData of this cached object can be dumped for decreased memory usage.
	 */
	public var canBeDumped(get, never):Bool;
	
	public var tilesheet(get, null):TileSheetData;
	
	/**
	 * Usage counter for this CachedGraphics object.
	 */
	public var useCount(default, set):Int = 0;
	
	private var _tilesheet:TileSheetData;
	
	public function new(Key:String, Bitmap:BitmapData, Persist:Bool = false)
	{
		key = Key;
		bitmap = Bitmap;
		persist = Persist;
	}
	
	/**
	 * Dumps bits of bitmapdata = less memory, but you can't read / write pixels on it anymore 
	 * (but you can call onContext() method which will restore it again)
	 */
	public function dump():Void
	{
		#if !(flash || js)
		if (canBeDumped)
		{
			bitmap.dumpBits();
			isDumped = true;
		}
		#end
	}
	
	/**
	 * Undumps bits of bitmapdata - regenerates it and regenerate tilesheet data for this object
	 */
	public function undump():Void
	{
		#if !(flash || js)
		if (isDumped)
		{
			var newBitmap:BitmapData = getBitmapFromSystem();
			
			if (newBitmap != null)
			{
				bitmap = newBitmap;
				if (_tilesheet != null)
				{
					// regenerate tilesheet
					_tilesheet.onContext(newBitmap);
				}
			}
			
			isDumped = false;
		}
		#end
	}
	
	/**
	 * Use this method to restore cached bitmapdata (if it's possible).
	 * It's called automatically when the RESIZE event occurs.
	 */
	public function onContext():Void
	{
		// no need to restore tilesheet if it haven't been dumped
		if (isDumped)
		{
			undump();	// restore everything
			dump();	// and dump bitmapdata again
		}
	}
	
	public function getRegionForFrame(FrameName:String):TextureRegion
	{
		var region:TextureRegion = new TextureRegion(this);
		var frame:FlxFrame = tilesheet.getFrame(FrameName);
		
		if (frame != null)
		{
			region.region.startX = Std.int(frame.frame.x);
			region.region.startY = Std.int(frame.frame.y);
			region.region.width = Std.int(frame.frame.width);
			region.region.height = Std.int(frame.frame.height);
		}
		
		return region;
	}
	
	public function destroy():Void
	{
		if (bitmap != null)
		{
			bitmap.dispose();
			bitmap = null;
		}
		
		data = FlxG.safeDestroy(data);
		tilesheet = FlxG.safeDestroy(tilesheet);
		key = null;
		assetsKey = null;
		assetsClass = null;
	}
	
	private function get_tilesheet():TileSheetData 
	{
		if (_tilesheet == null) 
		{
			if (isDumped) 
			{
				onContext();
			}
			
			_tilesheet = new TileSheetData(bitmap);
		}
		
		return _tilesheet;
	}
	
	private function getBitmapFromSystem():BitmapData
	{
		var newBitmap:BitmapData = null;
		if (assetsClass != null)
		{
			newBitmap = Type.createInstance(cast(assetsClass, Class<Dynamic>), []);
		}
		else if (assetsKey != null)
		{
			newBitmap = FlxAssets.getBitmapData(assetsKey);
		}
		
		return newBitmap;
	}
	
	private inline function get_canBeDumped():Bool
	{
		return ((assetsClass != null) || (assetsKey != null));
	}
	
	private function set_useCount(Value:Int):Int
	{
		if ((Value <= 0) && destroyOnNoUse && !persist)
		{
			FlxG.bitmap.remove(key);
		}
		
		return useCount = Value;
	}
	
	private function set_destroyOnNoUse(Value:Bool):Bool
	{
		if (Value && useCount == 0 && key != null && !persist)
		{
			FlxG.bitmap.remove(key);
		}
		
		return destroyOnNoUse = Value;
	}
}
