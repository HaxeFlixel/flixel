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
	 * TexturePackerData associated with bitmapdata
	 */
	public var data:TexturePackerData;
	
	private var _tilesheet:TileSheetData;
	/**
	 * Whether this Cached object should stay in cache after state change or not.
	 */
	public var persist:Bool = false;
	/**
	 * Asset name from openfl.Assets
	 */
	public var assetsKey:String;
	/**
	 * Class name for bitmapdata
	 */
	public var assetsClass:Class<BitmapData>;
	
	/**
	 * Says if bitmapdata of this Cache object has been dumped or not
	 */
	public var isDumped(default, null):Bool = false;
	
	/**
	 * Says if bitmapdata of this Cache object can be dumped for less memory usage
	 */
	public var canBeDumped(get, null):Bool;
	
	public var tilesheet(get_tilesheet, null):TileSheetData;
	
	/**
	 * Usage counter for this CachedGraphics object.
	 */
	public var useCount(get, set):Int;
	
	private var _useCount:Int = 0;
	
	/**
	 * Whether we should destroy this CachedGraphics object when useCount become zero.
	 * Default if false.
	 */
	public var destroyOnNoUse:Bool = false;
	
	public function new(key:String, bitmap:BitmapData, persist:Bool = false)
	{
		this.key = key;
		this.bitmap = bitmap;
		this.persist = persist;
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
	 * Use this method to restore cached bitmapdata (it it's possible).
	 * It's called automatically when RESIZE event occurs.
	 */
	public function onContext():Void
	{
		// no need to restore tilesheet if it haven't been dumped
		if (isDumped)
		{
			// restore everything
			undump();
			// and dump bitmapdata again
			dump();
		}
	}
	
	private function get_tilesheet():TileSheetData 
	{
		if (_tilesheet == null) 
		{
			if (isDumped)
				onContext();
			
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
	
	public function getRegionForFrame(frameName:String):TextureRegion
	{
		var region:TextureRegion = new TextureRegion(this);
		var frame:FlxFrame = tilesheet.getFrame(frameName);
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
		key = null;
		if (bitmap != null)
		{
			bitmap.dispose();
		}
		bitmap = null;
		if (data != null)
		{
			data.destroy();
		}
		data = null;
		if (_tilesheet != null)
		{
			_tilesheet.destroy();
		}
		_tilesheet = null;
		
		assetsKey = null;
		assetsClass = null;
	}
	
	private function get_canBeDumped():Bool
	{
		return (assetsClass != null || assetsKey != null);
	}
	
	private function get_useCount():Int
	{
		return _useCount;
	}
	
	private function set_useCount(Value:Int):Int
	{
		_useCount = Value;
		
		if (_useCount <= 0 && destroyOnNoUse && !persist)
		{
			FlxG.bitmap.remove(key);
		}
		
		return Value;
	}
}