package org.flixel;

import org.flixel.FlxBasic;
import org.flixel.system.tileSheet.atlasgen.Atlas;
#if (cpp || neko)
import org.flixel.system.tileSheet.TileSheetData;
#end

class FlxLayer
{	
	static private var _drawStateCache:DrawStateCache = new DrawStateCache();
	
	private var _atlas:Atlas;
	#if (cpp || neko)
	private var _tileSheetData:TileSheetData;
	#end
	private var _drawStack:Array<DrawState>;
	
	public function new()
	{
		
	}
	
	public function createAtlas(TextureWidth:Int, TextureHeight:Int):Void
	{
		if (TextureWidth > 0 && TextureHeight > 0)
		{
			_atlas = new Atlas(TextureWidth, TextureHeight, 1, 1);
		}
	}
	
	public function destroy():Void 
	{
		if (_atlas != null)
		{
			_atlas.destroy();
		}
	}
	
	public function add(Object:FlxBasic):FlxBasic
	{
		return null;
	}
	
	public function remove(Object:FlxBasic):FlxBasic
	{
		return null;
	}
	
}

class DrawState
{
	public var flags:Int;
	public var blend:Int;
	public var drawData:Array<Array<Float>>;
	public var positionData:Array<Int>;
	public var hasDrawData:Bool;
	public var exists:Bool;
	
	public function new()
	{
		
	}
	
	public function reset():DrawState
	{
		
		
		return this;
	}
	
}

class DrawStateCache
{
	private var _states:Array<DrawState>;
	private var _length:Int;
	
	public function new()
	{
		_length = 0;
		_states = [];
	}
	
	public function add(state:DrawState):DrawState
	{
		_states[_length] = state;
		_length++;
		return state;
	}
	
	/*
	public function remove(state:DrawState):Void
	{
		
	}
	
	public function recycle(x:Float, y:Float, width:Float, height:Float):DrawState
	{
		var state:DrawState;
		var i:Int = 0;
		
		while (i < _length)
		{
			state = _states[i];
			if (state.exists == false)
			{
				state.reset(x, y, width, height, parent);
				return state;
			}
			i++;
		}
		
		return add(new DrawState(x, y, width, height, parent));
	}
	*/
}